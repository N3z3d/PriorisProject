import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import '../services/duel_service.dart';

/// Controller pour la page Duel appliquant SRP et MVVM
///
/// Responsabilité unique: Gérer l'état du duel et orchestrer les actions utilisateur
class DuelController extends StateNotifier<DuelState> {
  final DuelService _duelService;
  // ignore: unused_field - Utilisé pour l'injection de dépendances
  final Ref _ref;

  DuelController(this._ref, {DuelService? duelService})
      : _duelService = duelService ?? DuelService(_ref),
        super(const DuelState.initial());

  /// Initialise les données nécessaires au duel
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Charger les listes via le service
      await _duelService.ensureListsLoaded();

      // Charger le premier duel
      await loadNewDuel();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de l\'initialisation: $e',
      );
    }
  }

  /// Charge un nouveau duel
  Future<void> loadNewDuel() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final tasks = await _duelService.loadDuelTasks();

      if (tasks.length >= 2) {
        state = state.copyWith(
          currentDuel: [tasks[0], tasks[1]],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          currentDuel: null,
          isLoading: false,
          errorMessage: 'Pas assez de tâches pour créer un duel',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors du chargement: $e',
      );
    }
  }

  /// Sélectionne le gagnant du duel
  Future<void> selectWinner(Task winner, Task loser) async {
    state = state.copyWith(isLoading: true);

    try {
      await _duelService.processWinner(winner, loser);

      // Charger le prochain duel
      await loadNewDuel();

      state = state.copyWith(
        lastWinner: winner,
        lastLoser: loser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de la sélection: $e',
      );
    }
  }

  /// Sélectionne une tâche aléatoirement
  Future<void> selectRandomTask() async {
    if (state.currentDuel == null || state.currentDuel!.length < 2) return;

    final randomTask = _duelService.selectRandom(state.currentDuel!);
    final otherTask = state.currentDuel!.firstWhere((t) => t.id != randomTask.id);

    await selectWinner(randomTask, otherTask);
  }

  /// Met à jour une tâche
  Future<void> updateTask(Task updatedTask) async {
    state = state.copyWith(isLoading: true);

    try {
      await _duelService.updateTask(updatedTask);

      // Recharger le duel
      await loadNewDuel();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur mise à jour: $e',
      );
    }
  }

  /// Bascule la visibilité des scores ELO
  void toggleEloVisibility() {
    state = state.copyWith(hideEloScores: !state.hideEloScores);
  }

  /// Efface le dernier résultat
  void clearLastResult() {
    state = state.copyWith(
      lastWinner: null,
      lastLoser: null,
    );
  }
}

/// État immutable pour le Duel (applique Immutability Pattern)
class DuelState {
  final List<Task>? currentDuel;
  final bool isLoading;
  final String? errorMessage;
  final bool hideEloScores;
  final Task? lastWinner;
  final Task? lastLoser;

  const DuelState({
    this.currentDuel,
    this.isLoading = false,
    this.errorMessage,
    this.hideEloScores = false,
    this.lastWinner,
    this.lastLoser,
  });

  const DuelState.initial()
      : currentDuel = null,
        isLoading = false,
        errorMessage = null,
        hideEloScores = false,
        lastWinner = null,
        lastLoser = null;

  DuelState copyWith({
    List<Task>? currentDuel,
    bool? isLoading,
    String? errorMessage,
    bool? hideEloScores,
    Task? lastWinner,
    Task? lastLoser,
  }) {
    return DuelState(
      currentDuel: currentDuel ?? this.currentDuel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hideEloScores: hideEloScores ?? this.hideEloScores,
      lastWinner: lastWinner,
      lastLoser: lastLoser,
    );
  }
}

/// Provider pour DuelController
final duelControllerProvider =
    StateNotifierProvider<DuelController, DuelState>((ref) {
  return DuelController(ref);
});
