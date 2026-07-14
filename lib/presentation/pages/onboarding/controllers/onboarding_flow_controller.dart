import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_task_parser.dart';
import 'package:prioris/presentation/pages/onboarding/services/onboarding_persistence.dart';

/// Acte courant du flux d'onboarding actif.
enum OnboardingStep { capture, duel, reveal }

/// État immuable du flux d'onboarding (capture → duel → reveal).
class OnboardingFlowState {
  static const Object _unset = Object();

  final OnboardingStep step;
  final List<Task> currentPair;
  final int duelIndex;
  final Task? revealedTask;
  final bool isProcessing;

  /// État terminal : l'onboarding est achevé, le gate peut basculer vers
  /// HomePage. Piloté par [OnboardingFlowController.completeOnboarding] — c'est
  /// le seul signal de sortie du gate (et non le compteur de tâches, qui change
  /// dès la capture et démonterait le flux en cours).
  final bool finished;

  const OnboardingFlowState({
    this.step = OnboardingStep.capture,
    this.currentPair = const [],
    this.duelIndex = 0,
    this.revealedTask,
    this.isProcessing = false,
    this.finished = false,
  });

  const OnboardingFlowState.initial() : this();

  OnboardingFlowState copyWith({
    OnboardingStep? step,
    List<Task>? currentPair,
    int? duelIndex,
    Object? revealedTask = _unset,
    bool? isProcessing,
    bool? finished,
  }) {
    return OnboardingFlowState(
      step: step ?? this.step,
      currentPair: currentPair ?? this.currentPair,
      duelIndex: duelIndex ?? this.duelIndex,
      revealedTask: identical(revealedTask, _unset)
          ? this.revealedTask
          : revealedTask as Task?,
      isProcessing: isProcessing ?? this.isProcessing,
      finished: finished ?? this.finished,
    );
  }
}

/// Orchestre l'onboarding actif menant à l'activation event.
///
/// Invariant central : **les trois actes travaillent sur la même source**,
/// [_capturedTasks]. Les duels y tirent leurs paires et le reveal y calcule son
/// vainqueur — jamais dans les tâches préexistantes de l'utilisateur. C'est ce
/// qui garantit qu'un onboarding ne peut ni corrompre l'ELO réel, ni révéler
/// une tâche qui n'a jamais participé aux duels.
///
/// Ce qui est *persisté* dépend du mode ([OnboardingPersistence]) ; ce qui est
/// *calculé* n'en dépend pas : l'ELO évolue à l'identique dans les deux modes,
/// sinon le reveal du mode sandbox dégénérerait (toutes les tâches à 1200).
class OnboardingFlowController extends StateNotifier<OnboardingFlowState> {
  final Ref _ref;
  final DuelFlowService _duelService;
  final IOnboardingRepository _onboardingRepository;
  final math.Random _random;

  /// Nombre de duels guidés avant la révélation.
  static const int totalDuels = 5;

  /// Minimum *technique* de tâches pour former une paire de duel.
  ///
  /// Garde défensive du contrôleur, distincte du seuil *produit* d'activation
  /// (5, possédé par l'UI [OnboardingCaptureStep.requiredTasks] cf. AC3). Deux
  /// concepts différents → deux constantes, pas une duplication numérique.
  static const int minTasksToStart = 2;

  static const OnboardingTaskParser _parser = OnboardingTaskParser();

  List<Task> _capturedTasks = const [];
  OnboardingPersistence? _persistence;

  OnboardingFlowController(
    this._ref, {
    DuelFlowService? duelService,
    IOnboardingRepository? onboardingRepository,
    OnboardingPersistence? persistence,
    math.Random? random,
  })  : _duelService = duelService ?? DuelService(_ref),
        _onboardingRepository =
            onboardingRepository ?? _ref.read(onboardingRepositoryProvider),
        _persistence = persistence,
        _random = random ?? math.Random(),
        super(const OnboardingFlowState.initial());

  /// Les tâches de l'onboarding, avec leur ELO courant. Source de vérité des
  /// actes 2 et 3.
  List<Task> get capturedTasks => List.unmodifiable(_capturedTasks);

  /// Acte 1 → Acte 2 : matérialise les tâches saisies puis lance le premier duel.
  ///
  /// [listName] est le nom de la liste dédiée créée en mode réel ; il vient de
  /// l'UI, seule détentrice du contexte de localisation.
  Future<void> submitCapturedTasks(
    String rawText, {
    required String listName,
  }) async {
    if (state.isProcessing) return; // Anti ré-entrance (double-tap).
    final titles = _parseTitles(rawText);
    if (titles.length < minTasksToStart) {
      return; // L'UI verrouille le bouton ; garde défensive.
    }

    state = state.copyWith(isProcessing: true);
    try {
      final persistence = await _resolvePersistence();
      if (!mounted) return;
      _capturedTasks = await persistence.captureTasks(titles, listName: listName);
      if (!mounted) return;
      await _loadNextDuel(startIndex: 0);
    } catch (error) {
      LoggerService.instance
          .error('Onboarding capture failed: $error', context: 'Onboarding');
    } finally {
      _resetProcessing();
    }
  }

  /// Acte 2 : enregistre un choix de duel et avance (ou révèle).
  Future<void> recordDuelChoice(Task winner, Task loser) async {
    if (state.isProcessing) return; // Anti ré-entrance (double-tap carte).
    state = state.copyWith(isProcessing: true);
    try {
      final persistence = await _resolvePersistence();
      if (!mounted) return;
      await persistence.recordDuel(winner, loser);
      if (!mounted) return;
      _applyDuelOutcome(winner, loser);

      final nextIndex = state.duelIndex + 1;
      if (nextIndex >= totalDuels) {
        await _revealTopTask(duelsCompleted: nextIndex);
      } else {
        await _loadNextDuel(startIndex: nextIndex);
      }
    } catch (error) {
      LoggerService.instance
          .error('Onboarding duel failed: $error', context: 'Onboarding');
    } finally {
      _resetProcessing();
    }
  }

  /// Acte 3 : marque l'onboarding terminé et libère le gate vers HomePage.
  Future<void> completeOnboarding() async {
    if (state.isProcessing) return; // Anti ré-entrance (double-tap bouton).
    state = state.copyWith(isProcessing: true);
    await _finishOnboarding();
  }

  /// Acte 3 : marque la tâche révélée comme faite puis termine l'onboarding.
  Future<void> markRevealedTaskDoneAndComplete() async {
    if (state.isProcessing) return; // Anti ré-entrance (double-tap bouton).
    state = state.copyWith(isProcessing: true);
    final task = state.revealedTask;
    try {
      if (task != null) {
        final persistence = await _resolvePersistence();
        if (!mounted) return;
        await persistence.markTaskDone(task);
        if (!mounted) return;
      }
    } catch (error) {
      LoggerService.instance
          .error('Onboarding markDone failed: $error', context: 'Onboarding');
    }
    await _finishOnboarding();
  }

  /// Résout le mode **une seule fois**, à l'entrée du flux, puis le fige.
  ///
  /// Le comptage sous-jacent attend le chargement effectif des données : le
  /// résoudre paresseusement (et non à la construction du notifier) évite de
  /// classer `real` un utilisateur dont les listes ne sont pas encore chargées.
  Future<OnboardingPersistence> _resolvePersistence() async {
    final cached = _persistence;
    if (cached != null) return cached;

    final mode = await _ref.read(onboardingModeProvider.future);
    final resolved = mode == OnboardingMode.sandbox
        ? const SandboxOnboardingPersistence()
        : RealOnboardingPersistence(
            listsWriter: _ref.read(onboardingListsWriterProvider),
            duelService: _duelService,
          );
    _persistence = resolved;
    return resolved;
  }

  /// Persiste le flag durable et signale l'état terminal au gate.
  Future<void> _finishOnboarding() async {
    try {
      await _onboardingRepository.markCompleted();
      if (!mounted) return;
      _ref.invalidate(onboardingCompletedProvider);
      _ref.invalidate(shouldShowOnboardingProvider);
      state = state.copyWith(finished: true, isProcessing: false);
    } catch (error) {
      LoggerService.instance
          .error('Onboarding finish failed: $error', context: 'Onboarding');
      _resetProcessing();
    }
  }

  /// Réinitialise le verrou si une exception l'a laissé actif (évite un
  /// deadlock doux : cartes/boutons figés sans erreur affichée). Ne touche
  /// jamais un notifier démonté.
  void _resetProcessing() {
    if (mounted && state.isProcessing) {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Reporte l'issue du duel sur les tâches captées.
  ///
  /// Les deux nouveaux scores sont calculés à partir des scores *d'origine* des
  /// deux adversaires — d'où les copies : muter le vainqueur d'abord fausserait
  /// le calcul du perdant.
  void _applyDuelOutcome(Task winner, Task loser) {
    final updatedWinner = winner.copyWith()..updateEloScore(loser, true);
    final updatedLoser = loser.copyWith()..updateEloScore(winner, false);

    _capturedTasks = [
      for (final task in _capturedTasks)
        if (task.id == updatedWinner.id)
          updatedWinner
        else if (task.id == updatedLoser.id)
          updatedLoser
        else
          task,
    ];
  }

  /// Tire la prochaine paire **exclusivement** dans les tâches de l'onboarding.
  List<Task> _nextPair() {
    if (_capturedTasks.length < minTasksToStart) return const [];
    final pool = List<Task>.from(_capturedTasks)..shuffle(_random);
    return pool.take(2).toList(growable: false);
  }

  Future<void> _loadNextDuel({required int startIndex}) async {
    final pair = _nextPair();
    if (pair.length < 2) {
      await _revealTopTask(duelsCompleted: startIndex);
      return;
    }
    state = state.copyWith(
      step: OnboardingStep.duel,
      currentPair: pair,
      duelIndex: startIndex,
      isProcessing: false,
    );
  }

  Future<void> _revealTopTask({required int duelsCompleted}) async {
    final top = _capturedTasks.isEmpty
        ? null
        : _capturedTasks.reduce((a, b) => a.eloScore >= b.eloScore ? a : b);

    // L'activation event ne matérialise que le *vrai* moment de valeur :
    // les duels guidés complétés. Le chemin de repli dégénéré (paire
    // indisponible) révèle pour ne pas bloquer l'utilisateur, mais n'émet pas
    // de faux activation event.
    if (duelsCompleted >= totalDuels) {
      _emitActivationEvent(duelsCompleted);
      // « activation event = log + flag persisté » de façon atomique.
      // Persister dès l'entrée au reveal (et non au seul tap « Continuer »)
      // évite un réaffichage / re-log si l'utilisateur ferme l'app pile au
      // moment révélateur. completeOnboarding réécrira le flag (idempotent).
      // Seule écriture légitime du mode sandbox : sans elle, l'utilisateur
      // existant se referait l'onboarding à chaque lancement.
      await _onboardingRepository.markCompleted();
      if (!mounted) return;
    }
    state = state.copyWith(
      step: OnboardingStep.reveal,
      revealedTask: top,
      isProcessing: false,
    );
  }

  void _emitActivationEvent(int duelsCompleted) {
    // Activation event = log structuré + flag persisté (completeOnboarding).
    // Le branchement sur un vrai funnel analytics (PostHog) est déféré à
    // l'Epic 12 — story 12-4-funnel-activation.
    LoggerService.instance.info(
      'activation_event tasksCreated=${_capturedTasks.length} '
      'duelsCompleted=$duelsCompleted',
      context: 'Onboarding',
    );
  }

  List<String> _parseTitles(String raw) => _parser.parse(raw);
}

final onboardingFlowControllerProvider = StateNotifierProvider.autoDispose<
    OnboardingFlowController, OnboardingFlowState>((ref) {
  return OnboardingFlowController(ref);
});
