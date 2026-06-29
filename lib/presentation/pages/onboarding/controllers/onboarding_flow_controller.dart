import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_task_parser.dart';

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
/// Réutilise [DuelFlowService] pour le calcul ELO (aucune duplication) et
/// [IOnboardingRepository] pour le flag durable d'activation (ADR-001).
class OnboardingFlowController extends StateNotifier<OnboardingFlowState> {
  final Ref _ref;
  final DuelFlowService _duelService;
  final IOnboardingRepository _onboardingRepository;

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

  OnboardingFlowController(
    this._ref, {
    DuelFlowService? duelService,
    IOnboardingRepository? onboardingRepository,
  })  : _duelService = duelService ?? DuelService(_ref),
        _onboardingRepository =
            onboardingRepository ?? _ref.read(onboardingRepositoryProvider),
        super(const OnboardingFlowState.initial());

  /// Acte 1 → Acte 2 : persiste les tâches saisies puis lance le premier duel.
  Future<void> submitCapturedTasks(String rawText) async {
    if (state.isProcessing) return; // Anti ré-entrance (double-tap).
    final titles = _parseTitles(rawText);
    if (titles.length < minTasksToStart) {
      return; // L'UI verrouille le bouton ; garde défensive.
    }

    state = state.copyWith(isProcessing: true);
    try {
      _capturedTasks = await _persistTasks(titles);
      if (!mounted) return;
      _ref.invalidate(allTasksProvider);
      _ref.invalidate(allPrioritizationTasksProvider);
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
      await _duelService.processWinner(winner, loser);
      if (!mounted) return;
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
        await _duelService.updateTask(task.copyWith(isCompleted: true));
        if (!mounted) return;
      }
    } catch (error) {
      LoggerService.instance
          .error('Onboarding markDone failed: $error', context: 'Onboarding');
    }
    await _finishOnboarding();
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

  Future<List<Task>> _persistTasks(List<String> titles) async {
    final repository = _ref.read(taskRepositoryProvider);
    final created = <Task>[];
    for (final title in titles) {
      final task = Task(title: title);
      await repository.saveTask(task);
      created.add(task);
    }
    return created;
  }

  Future<void> _loadNextDuel({required int startIndex}) async {
    final pair = await _duelService.loadDuelTasks(count: 2);
    if (!mounted) return;
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
    _ref.invalidate(allPrioritizationTasksProvider);
    final tasks = await _ref.read(allPrioritizationTasksProvider.future);
    if (!mounted) return;
    final top = tasks.isEmpty
        ? null
        : tasks.reduce((a, b) => a.eloScore >= b.eloScore ? a : b);
    // L'activation event ne matérialise que le *vrai* moment de valeur :
    // les duels guidés complétés. Le chemin de repli dégénéré (paire
    // indisponible) révèle pour ne pas bloquer l'utilisateur, mais n'émet pas
    // de faux activation event.
    if (duelsCompleted >= totalDuels) {
      _emitActivationEvent(duelsCompleted);
      // AC4 : « activation event = log + flag persisté » de façon atomique.
      // Persister dès l'entrée au reveal (et non au seul tap « Continuer »)
      // évite un réaffichage / re-log si l'utilisateur ferme l'app pile au
      // moment révélateur. completeOnboarding réécrira le flag (idempotent).
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
    // l'Epic 15 — story 15-4-funnel-activation.
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
