import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/domain/habit/repositories/habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';

class _MockHabitRepo implements HabitRepository {
  Habit? captured;
  int updateCount = 0;
  bool shouldThrow = false;
  Completer<void>? gate;

  @override
  Future<void> updateHabit(Habit habit) async {
    updateCount++;
    if (gate != null) await gate!.future;
    if (shouldThrow) throw Exception('Supabase error');
    captured = habit;
  }

  @override
  Future<List<Habit>> getAllHabits() async =>
      captured != null ? [captured!] : [];
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

Habit _quantHabit({double? today}) {
  final habit = Habit(
    id: 'habit-q',
    name: 'Boire',
    type: HabitType.quantitative,
    targetValue: 8,
    unit: 'verres',
  );
  if (today != null) habit.recordValue(today);
  return habit;
}

ProviderContainer _container(_MockHabitRepo repo) {
  final container = ProviderContainer(
    overrides: [habitRepositoryProvider.overrideWithValue(repo)],
  );
  return container;
}

void main() {
  group('HabitsController.recordQuantitativeValue', () {
    test('Q1 — succès : persiste la valeur via updateHabit + état success',
        () async {
      final repo = _MockHabitRepo();
      final habit = _quantHabit();
      final container = _container(repo);
      addTearDown(container.dispose);
      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(habits: [habit]);

      await container
          .read(habitsControllerProvider.notifier)
          .recordQuantitativeValue(habit, 5);

      expect(repo.captured, isNotNull);
      expect(repo.captured!.getTodayValue(), 5.0);
      final state = container.read(habitsControllerProvider);
      expect(state.actionResult, ActionResult.success);
      expect(state.lastAction, HabitAction.recorded);
      expect(state.recordingHabitIds, isEmpty,
          reason: 'La garde de ré-entrance doit être libérée en fin de flux');
    });

    test('Q2 — garde de type : une habitude binaire est ignorée (no-op)',
        () async {
      final repo = _MockHabitRepo();
      final binary = Habit(id: 'b', name: 'Yoga', type: HabitType.binary);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container
          .read(habitsControllerProvider.notifier)
          .recordQuantitativeValue(binary, 5);

      expect(repo.updateCount, 0);
      expect(container.read(habitsControllerProvider).actionResult, isNull);
    });

    test('Q3 — ré-entrance : un second appel concurrent est ignoré', () async {
      final repo = _MockHabitRepo()..gate = Completer<void>();
      final habit = _quantHabit();
      final container = _container(repo);
      addTearDown(container.dispose);
      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(habits: [habit]);

      final notifier = container.read(habitsControllerProvider.notifier);
      final first = notifier.recordQuantitativeValue(habit, 5);
      await Future<void>.delayed(Duration.zero);
      final second = notifier.recordQuantitativeValue(habit, 6);
      await second;

      expect(repo.updateCount, 1,
          reason: 'Le second appel doit court-circuiter (déjà en cours)');

      repo.gate!.complete();
      await first;
      expect(repo.updateCount, 1);
    });

    test('Q4 — rollback (previous == null) : la valeur du jour est retirée',
        () async {
      final repo = _MockHabitRepo()..shouldThrow = true;
      final habit = _quantHabit(); // aucune valeur aujourd'hui
      final container = _container(repo);
      addTearDown(container.dispose);
      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(habits: [habit]);

      await container
          .read(habitsControllerProvider.notifier)
          .recordQuantitativeValue(habit, 5);

      expect(habit.getTodayValue(), isNull,
          reason: 'Pas de valeur fantôme après un échec réseau');
      expect(container.read(habitsControllerProvider).actionResult,
          ActionResult.error);
    });

    test('Q5 — rollback (previous != null) : restaure la valeur précédente',
        () async {
      final repo = _MockHabitRepo()..shouldThrow = true;
      final habit = _quantHabit(today: 3); // valeur du jour = 3
      final container = _container(repo);
      addTearDown(container.dispose);
      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(habits: [habit]);

      await container
          .read(habitsControllerProvider.notifier)
          .recordQuantitativeValue(habit, 5);

      expect((habit.getTodayValue() as num).toDouble(), 3.0,
          reason: 'La valeur précédente doit être restaurée après échec');
      expect(container.read(habitsControllerProvider).actionResult,
          ActionResult.error);
    });
  });
}
