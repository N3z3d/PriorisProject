import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import '../services/duel_service.dart';

/// Contrôleur principal du flux Priorisé.
class DuelController extends StateNotifier<DuelState> {
  final DuelFlowService _duelService;
  final Ref _ref;

  DuelController(this._ref, {DuelFlowService? duelService})
      : _duelService = duelService ?? DuelService(_ref),
        super(const DuelState.initial());

  DuelSettings get _currentSettings => _ref.read(duelSettingsProvider);

  DuelSettingsNotifier get _settingsNotifier =>
      _ref.read(duelSettingsProvider.notifier);

  /// Initialise les données et charge le premier duel.
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await _duelService.ensureListsLoaded();
      await _settingsNotifier.ensureLoaded();

      final settings = _currentSettings;
      state = state.copyWith(settings: settings);
      await _loadNewDuelWithSettings(settings);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erreur lors de l'initialisation: $e",
      );
    }
  }

  /// Recharge un duel en tenant compte des paramètres utilisateurs.
  Future<void> loadNewDuel() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _settingsNotifier.ensureLoaded();
      final settings = _currentSettings;
      state = state.copyWith(settings: settings);
      await _loadNewDuelWithSettings(settings);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors du chargement: $e',
      );
    }
  }

  /// Enregistre un duel 1v1.
  Future<void> selectWinner(Task winner, Task loser) async {
    if (_currentSettings.mode != DuelMode.winner) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _duelService.processWinner(winner, loser);
      await loadNewDuel();
      state = state.copyWith(
        lastWinner: winner,
        lastLoser: loser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de la selection: $e',
      );
    }
  }

  /// Enregistre un classement complet.
  Future<void> submitRanking(List<Task> orderedTasks) async {
    if (_currentSettings.mode != DuelMode.ranking) {
      return;
    }
    if (orderedTasks.length < 2) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _duelService.processRanking(orderedTasks);
      await loadNewDuel();
      state = state.copyWith(
        lastWinner: orderedTasks.first,
        lastLoser: orderedTasks.last,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erreur lors de l'enregistrement du classement: $e",
      );
    }
  }

  /// Choisit un résultat aléatoire pour la manche en cours.
  Future<void> selectRandomTask() async {
    final duel = state.currentDuel;
    if (duel == null || duel.length < 2) return;

    if (_currentSettings.mode == DuelMode.winner) {
      // En mode Duel: sélectionne un gagnant parmi toutes les cartes
      final randomWinner = _duelService.selectRandom(duel);
      final others = duel.where((task) => task.id != randomWinner.id).toList();

      // Compare le gagnant avec tous les autres
      for (final loser in others) {
        await _duelService.processWinner(randomWinner, loser);
      }

      await loadNewDuel();
      state = state.copyWith(
        lastWinner: randomWinner,
        lastLoser: others.isNotEmpty ? others.last : null,
      );
    } else if (_currentSettings.mode == DuelMode.ranking) {
      // En mode Classement: génère un ordre aléatoire
      final shuffled = List<Task>.from(duel)..shuffle();
      await submitRanking(shuffled);
    }
  }

  /// Met à jour une tâche depuis le duel.
  Future<void> updateTask(Task updatedTask) async {
    state = state.copyWith(isLoading: true);

    try {
      await _duelService.updateTask(updatedTask);
      await loadNewDuel();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur mise a jour: $e',
      );
    }
  }

  /// Bascule la visibilité des scores ELO.
  Future<void> toggleEloVisibility() async {
    await _settingsNotifier.toggleHideElo();
    state = state.copyWith(settings: _currentSettings);
  }

  Future<void> updateMode(DuelMode mode) async {
    await _settingsNotifier.updateMode(mode);
    final settings = _currentSettings;
    state = state.copyWith(settings: settings);
    await _loadNewDuelWithSettings(settings);
  }

  Future<void> updateCardsPerRound(int cardsPerRound) async {
    await _settingsNotifier.updateCardsPerRound(cardsPerRound);
    final settings = _currentSettings;
    state = state.copyWith(settings: settings);
    await _loadNewDuelWithSettings(settings);
  }

  /// Nettoie les informations sur le dernier duel.
  void clearLastResult() {
    state = state.copyWith(
      lastWinner: null,
      lastLoser: null,
    );
  }

  Future<void> _loadNewDuelWithSettings(DuelSettings settings) async {
    final tasks =
        await _duelService.loadDuelTasks(count: settings.cardsPerRound);
    if (tasks.length >= 2) {
      // Prend autant de cartes que disponible (minimum 2, maximum demandé)
      final duel = tasks;
      state = state.copyWith(
        currentDuel: duel,
        isLoading: false,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(
      currentDuel: null,
      isLoading: false,
      errorMessage:
          'Pas assez de taches eligibles pour creer un duel',
    );
  }
}

/// État immutable du duel.
class DuelState {
  static const Object _unset = Object();

  final List<Task>? currentDuel;
  final bool isLoading;
  final String? errorMessage;
  final DuelSettings settings;
  final Task? lastWinner;
  final Task? lastLoser;

  const DuelState({
    this.currentDuel,
    this.isLoading = false,
    this.errorMessage,
    this.settings = const DuelSettings.defaults(),
    this.lastWinner,
    this.lastLoser,
  });

  const DuelState.initial()
      : currentDuel = null,
        isLoading = false,
        errorMessage = null,
        settings = const DuelSettings.defaults(),
        lastWinner = null,
        lastLoser = null;

  DuelState copyWith({
    List<Task>? currentDuel,
    bool? isLoading,
    Object? errorMessage = _unset,
    DuelSettings? settings,
    Task? lastWinner,
    Task? lastLoser,
  }) {
    return DuelState(
      currentDuel: currentDuel ?? this.currentDuel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      settings: settings ?? this.settings,
      lastWinner: lastWinner,
      lastLoser: lastLoser,
    );
  }

  bool get hideEloScores => settings.hideEloScores;
}

final duelControllerProvider =
    StateNotifierProvider<DuelController, DuelState>((ref) {
  return DuelController(ref);
});
