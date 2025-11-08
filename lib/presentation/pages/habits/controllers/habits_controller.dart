import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/services/core/language_service.dart';
import 'package:prioris/l10n/app_localizations.dart';

class HabitsController extends StateNotifier<HabitsControllerState> {
  HabitsController(this._ref) : super(const HabitsControllerState());

  final Ref _ref;

  AppLocalizations get _l10n {
    final locale = _ref.read(currentLocaleProvider);
    return lookupAppLocalizations(locale);
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _ref.read(habitsStateProvider.notifier).addHabit(habit);
      state = state.copyWith(
        lastAction: HabitAction.added,
        lastActionMessage: _l10n.habitsActionCreateSuccess,
        actionResult: ActionResult.success,
      );
    } catch (error) {
      state = state.copyWith(
        lastAction: HabitAction.added,
        lastActionMessage: _l10n.habitsActionCreateError(error.toString()),
        actionResult: ActionResult.error,
      );
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _ref.read(habitsStateProvider.notifier).updateHabit(habit);
      state = state.copyWith(
        lastAction: HabitAction.edited,
        lastActionMessage: _l10n.habitsActionUpdateSuccess(habit.name),
        actionResult: ActionResult.success,
      );
    } catch (error) {
      state = state.copyWith(
        lastAction: HabitAction.edited,
        lastActionMessage: _l10n.habitsActionUpdateError(error.toString()),
        actionResult: ActionResult.error,
      );
    }
  }

  Future<void> deleteHabit(String habitId, String habitName) async {
    try {
      await _ref.read(habitsStateProvider.notifier).deleteHabit(habitId);
      state = state.copyWith(
        lastAction: HabitAction.deleted,
        lastActionMessage: _l10n.habitsActionDeleteSuccess(habitName),
        actionResult: ActionResult.success,
      );
    } catch (error) {
      state = state.copyWith(
        lastAction: HabitAction.deleted,
        lastActionMessage: _l10n.habitsActionDeleteError(error.toString()),
        actionResult: ActionResult.error,
      );
    }
  }

  void recordHabit(Habit habit) {
    state = state.copyWith(
      lastAction: HabitAction.recorded,
      lastActionMessage: _l10n.habitsActionRecordSuccess(habit.name),
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
