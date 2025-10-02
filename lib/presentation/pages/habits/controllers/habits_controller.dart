import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Controller for Habits page following SRP and Clean Architecture
/// Handles state management and business logic separation from UI
class HabitsController extends StateNotifier<HabitsControllerState> {
  final Ref _ref;
  late TabController tabController;

  HabitsController(this._ref, TickerProvider vsync) 
      : super(const HabitsControllerState()) {
    tabController = TabController(length: 2, vsync: vsync);
    _loadInitialData();
  }

  void _loadInitialData() {
    final habits = _ref.read(reactiveHabitsProvider);
    final isLoading = _ref.read(habitsLoadingProvider);
    final error = _ref.read(habitsErrorProvider);

    if (habits.isEmpty && !isLoading && error == null) {
      _ref.read(habitsStateProvider.notifier).loadHabits();
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final habitRepo = _ref.read(habitRepositoryProvider);
      await habitRepo.saveHabit(habit);
      state = state.copyWith(
        lastAction: HabitAction.added,
        lastActionMessage: 'Habitude "${habit.name}" créée avec succès !',
        actionResult: ActionResult.success,
      );
    } catch (e) {
      state = state.copyWith(
        lastAction: HabitAction.added,
        lastActionMessage: 'Erreur lors de la création: $e',
        actionResult: ActionResult.error,
      );
    }
  }

  Future<void> deleteHabit(String habitId, String habitName) async {
    try {
      final habitRepo = _ref.read(habitRepositoryProvider);
      await habitRepo.deleteHabit(habitId);
      state = state.copyWith(
        lastAction: HabitAction.deleted,
        lastActionMessage: 'Habitude "$habitName" supprimée',
        actionResult: ActionResult.success,
      );
    } catch (e) {
      state = state.copyWith(
        lastAction: HabitAction.deleted,
        lastActionMessage: 'Erreur lors de la suppression: $e',
        actionResult: ActionResult.error,
      );
    }
  }

  void recordHabit(Habit habit) {
    state = state.copyWith(
      lastAction: HabitAction.recorded,
      lastActionMessage: 'Habitude "${habit.name}" enregistrée !',
      actionResult: ActionResult.success,
    );
  }

  void navigateToAddTab() {
    tabController.animateTo(1);
  }

  void clearLastAction() {
    state = state.copyWith(
      lastAction: null,
      lastActionMessage: null,
      actionResult: null,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}

/// State for HabitsController
class HabitsControllerState {
  final HabitAction? lastAction;
  final String? lastActionMessage;
  final ActionResult? actionResult;

  const HabitsControllerState({
    this.lastAction,
    this.lastActionMessage,
    this.actionResult,
  });

  HabitsControllerState copyWith({
    HabitAction? lastAction,
    String? lastActionMessage,
    ActionResult? actionResult,
  }) {
    return HabitsControllerState(
      lastAction: lastAction ?? this.lastAction,
      lastActionMessage: lastActionMessage ?? this.lastActionMessage,
      actionResult: actionResult ?? this.actionResult,
    );
  }
}

/// Action types for habits
enum HabitAction { added, deleted, recorded, edited }

/// Result types for actions
enum ActionResult { success, error }

/// Provider for HabitsController
final habitsControllerProvider = StateNotifierProvider.family<HabitsController, HabitsControllerState, TickerProvider>(
  (ref, vsync) => HabitsController(ref, vsync),
);
