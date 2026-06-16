import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/domain/habit/repositories/habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';

class _MockHabitRepositoryWithCapture implements HabitRepository {
  Habit? capturedUpdate;
  bool shouldThrow = false;

  @override
  Future<List<Habit>> getAllHabits() async =>
      capturedUpdate != null ? [capturedUpdate!] : [];

  @override
  Future<void> updateHabit(Habit habit) async {
    if (shouldThrow) throw Exception('Supabase error');
    capturedUpdate = habit;
  }

  @override
  Future<void> addHabit(Habit habit) async {}
  @override
  Future<void> clearAllHabits() async {}
  @override
  Future<void> deleteHabit(String habitId) async {}
  @override
  Future<List<Habit>> getHabitsByCategory(String category) async => [];
  @override
  Future<void> saveHabit(Habit habit) async {}
}

Habit _buildHabit({bool completedToday = false}) {
  final completions = <String, dynamic>{};
  if (completedToday) {
    final today = DateTime.now();
    final key =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    completions[key] = true;
  }
  return Habit(
    id: 'habit-1',
    name: "Boire de l'eau",
    type: HabitType.binary,
    completions: completions,
  );
}

void main() {
  group('HabitsController.recordHabit', () {
    test('T1 — appelle updateHabit avec isCompletedToday() == true', () async {
      final mockRepo = _MockHabitRepositoryWithCapture();
      final habit = _buildHabit();

      final container = ProviderContainer(
        overrides: [habitRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(habits: [habit]);

      await container.read(habitsControllerProvider.notifier).recordHabit(habit);

      expect(mockRepo.capturedUpdate, isNotNull,
          reason: 'updateHabit doit être appelé');
      expect(mockRepo.capturedUpdate!.isCompletedToday(), isTrue,
          reason: 'La completion doit être true après recordHabit');

      final controllerState = container.read(habitsControllerProvider);
      expect(controllerState.actionResult, ActionResult.success);
      expect(controllerState.lastAction, HabitAction.recorded);
    });

    test('T2 — toggle : déjà complété aujourd\'hui → devient false', () async {
      final mockRepo = _MockHabitRepositoryWithCapture();
      final habit = _buildHabit(completedToday: true);

      final container = ProviderContainer(
        overrides: [habitRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(habits: [habit]);

      await container.read(habitsControllerProvider.notifier).recordHabit(habit);

      expect(mockRepo.capturedUpdate!.isCompletedToday(), isFalse,
          reason: 'Toggle : si déjà complété, doit passer à false');
    });

    test('T3 — erreur repository → actionResult == error', () async {
      final mockRepo = _MockHabitRepositoryWithCapture()..shouldThrow = true;
      final habit = _buildHabit();

      final container = ProviderContainer(
        overrides: [habitRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(habitsControllerProvider.notifier).recordHabit(habit);

      final controllerState = container.read(habitsControllerProvider);
      expect(controllerState.actionResult, ActionResult.error);
      expect(controllerState.lastAction, HabitAction.recorded);
    });

    test('T4 — habitsStateProvider mis à jour après recordHabit réussi',
        () async {
      final mockRepo = _MockHabitRepositoryWithCapture();
      final habit = _buildHabit();

      final container = ProviderContainer(
        overrides: [habitRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(habits: [habit]);

      await container.read(habitsControllerProvider.notifier).recordHabit(habit);

      final habits = container.read(habitsStateProvider).habits;
      expect(habits.first.isCompletedToday(), isTrue,
          reason: 'HabitsNotifier.state doit refléter la completion');
    });
  });
}
