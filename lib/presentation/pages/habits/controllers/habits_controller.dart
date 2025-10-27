import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

class HabitsController extends StateNotifier<HabitsControllerState> {
  HabitsController(this._ref) : super(const HabitsControllerState());

  final Ref _ref;

  Future<void> addHabit(Habit habit) async {
    try {
      await _ref.read(habitsStateProvider.notifier).addHabit(habit);
      state = state.copyWith(
        lastAction: HabitAction.added,
        lastActionMessage: 'Habitude créée ✅',
        actionResult: ActionResult.success,
      );
    } catch (error) {
      state = state.copyWith(
        lastAction: HabitAction.added,
        lastActionMessage: 'Erreur lors de la création : $error',
        actionResult: ActionResult.error,
      );
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _ref.read(habitsStateProvider.notifier).updateHabit(habit);
      state = state.copyWith(
        lastAction: HabitAction.edited,
        lastActionMessage: 'Habitude "${habit.name}" mise à jour',
        actionResult: ActionResult.success,
      );
    } catch (error) {
      state = state.copyWith(
        lastAction: HabitAction.edited,
        lastActionMessage: 'Erreur lors de la mise à jour : $error',
        actionResult: ActionResult.error,
      );
    }
  }

  Future<void> deleteHabit(String habitId, String habitName) async {
    try {
      await _ref.read(habitsStateProvider.notifier).deleteHabit(habitId);
      state = state.copyWith(
        lastAction: HabitAction.deleted,
        lastActionMessage: 'Habitude "$habitName" supprimée',
        actionResult: ActionResult.success,
      );
    } catch (error) {
      state = state.copyWith(
        lastAction: HabitAction.deleted,
        lastActionMessage: 'Impossible de supprimer l\'habitude : $error',
        actionResult: ActionResult.error,
      );
    }
  }

  void recordHabit(Habit habit) {
    state = state.copyWith(
      lastAction: HabitAction.recorded,
      lastActionMessage: 'Habitude "${habit.name}" enregistrée',
      actionResult: ActionResult.success,
    );
  }

  void clearLastAction() {
    state = state.copyWith(
      lastAction: null,
      lastActionMessage: null,
      actionResult: null,
    );
  }
}

class HabitsControllerState {
  const HabitsControllerState({
    this.lastAction,
    this.lastActionMessage,
    this.actionResult,
  });

  final HabitAction? lastAction;
  final String? lastActionMessage;
  final ActionResult? actionResult;

  static const _sentinel = Object();

  HabitsControllerState copyWith({
    Object? lastAction = _sentinel,
    Object? lastActionMessage = _sentinel,
    Object? actionResult = _sentinel,
  }) {
    return HabitsControllerState(
      lastAction: identical(lastAction, _sentinel)
          ? this.lastAction
          : lastAction as HabitAction?,
      lastActionMessage: identical(lastActionMessage, _sentinel)
          ? this.lastActionMessage
          : lastActionMessage as String?,
      actionResult: identical(actionResult, _sentinel)
          ? this.actionResult
          : actionResult as ActionResult?,
    );
  }
}

enum HabitAction { added, deleted, recorded, edited }

enum ActionResult { success, error }

final habitsControllerProvider =
    StateNotifierProvider<HabitsController, HabitsControllerState>(
  HabitsController.new,
);
