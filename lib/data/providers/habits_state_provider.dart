import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/data/repositories/habit_repository.dart';

/// État consolidé des habitudes
class HabitsState {
  final List<Habit> habits;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  const HabitsState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
    required this.lastUpdated,
  });

  HabitsState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// StateNotifier pour gérer les habitudes
class HabitsNotifier extends StateNotifier<HabitsState> {
  final Ref _ref;

  HabitsNotifier(this._ref)
      : super(HabitsState(lastUpdated: DateTime.now()));

  /// Charge les habitudes depuis le repository
  Future<void> loadHabits() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = _ref.read(habitRepositoryProvider);
      final habits = await repository.getAllHabits();

      state = state.copyWith(
        habits: habits,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Ajoute une nouvelle habitude
  Future<void> addHabit(Habit habit) async {
    try {
      final repository = _ref.read(habitRepositoryProvider);
      await repository.saveHabit(habit);

      // Recharge les habitudes pour avoir l'état le plus récent
      await loadHabits();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Supprime une habitude
  Future<void> deleteHabit(String habitId) async {
    try {
      final repository = _ref.read(habitRepositoryProvider);
      await repository.deleteHabit(habitId);

      // Met à jour l'état local immédiatement
      final updatedHabits = state.habits.where((h) => h.id != habitId).toList();
      state = state.copyWith(
        habits: updatedHabits,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Met à jour une habitude existante
  Future<void> updateHabit(Habit habit) async {
    try {
      final repository = _ref.read(habitRepositoryProvider);
      await repository.updateHabit(habit);

      // Met à jour l'état local
      final updatedHabits = state.habits
          .map((h) => h.id == habit.id ? habit : h)
          .toList();
      state = state.copyWith(
        habits: updatedHabits,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// PROVIDERS CONSOLIDÉS
// ============================================================================

/// Provider principal : StateNotifier consolidé pour les habitudes
final habitsStateProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier(ref);
});

/// Provider pour les habitudes (réactif)
final reactiveHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitsStateProvider).habits;
});

/// Provider pour l'état de chargement
final habitsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(habitsStateProvider).isLoading;
});

/// Provider pour les erreurs
final habitsErrorProvider = Provider<String?>((ref) {
  return ref.watch(habitsStateProvider).error;
});

// ============================================================================
// EXTENSIONS POUR SIMPLIFIER L'UTILISATION
// ============================================================================

/// Extension pour simplifier l'utilisation des habitudes
extension HabitsProviderX on WidgetRef {
  /// Ajoute une habitude de manière réactive
  Future<void> addHabitReactive(Habit habit) async {
    await read(habitsStateProvider.notifier).addHabit(habit);
  }

  /// Supprime une habitude de manière réactive
  Future<void> deleteHabitReactive(String habitId) async {
    await read(habitsStateProvider.notifier).deleteHabit(habitId);
  }

  /// Met à jour une habitude de manière réactive
  Future<void> updateHabitReactive(Habit habit) async {
    await read(habitsStateProvider.notifier).updateHabit(habit);
  }

  /// Charge les habitudes si pas encore fait
  void loadHabitsIfNeeded() {
    final state = read(habitsStateProvider);
    if (state.habits.isEmpty && !state.isLoading) {
      read(habitsStateProvider.notifier).loadHabits();
    }
  }

  /// Efface l'erreur des habitudes
  void clearHabitsError() {
    read(habitsStateProvider.notifier).clearError();
  }
}
