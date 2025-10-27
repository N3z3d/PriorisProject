import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';

void main() {
  test('HabitsController.addHabit persists habit and reports success', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(habitsControllerProvider.notifier);
    final habit = Habit(
      id: 'habit-001',
      name: 'Lecture matinale',
      category: 'Business',
      type: HabitType.binary,
      createdAt: DateTime(2024, 1, 1),
    );

    await controller.addHabit(habit);

    final habitsState = container.read(habitsStateProvider);
    expect(habitsState.habits.any((h) => h.id == habit.id), isTrue);

    final controllerState = container.read(habitsControllerProvider);
    expect(controllerState.lastAction, HabitAction.added);
    expect(controllerState.lastActionMessage, 'Habitude créée ✅');
    expect(controllerState.actionResult, ActionResult.success);
  });
}
