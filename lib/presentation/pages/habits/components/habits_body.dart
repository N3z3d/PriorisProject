import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habits_list.dart';
import 'package:prioris/presentation/pages/habits/components/habit_add_form.dart';
import 'package:prioris/presentation/pages/habits/components/habits_error_state.dart';
import 'package:prioris/presentation/pages/habits/components/habits_loading_state.dart';

/// Body component for Habits page following SRP
/// Handles tab view rendering and state display
class HabitsBody extends StatelessWidget {
  final TabController tabController;
  final List<Habit> habits;
  final bool isLoading;
  final String? error;
  final Function(Habit) onAddHabit;
  final Function(String, String) onDeleteHabit;
  final Function(Habit) onRecordHabit;
  final Function() onNavigateToAdd;

  const HabitsBody({
    super.key,
    required this.tabController,
    required this.habits,
    required this.isLoading,
    this.error,
    required this.onAddHabit,
    required this.onDeleteHabit,
    required this.onRecordHabit,
    required this.onNavigateToAdd,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        _buildHabitsTab(),
        _buildAddTab(),
      ],
    );
  }

  Widget _buildHabitsTab() {
    if (isLoading) {
      return const HabitsLoadingState();
    }

    if (error != null) {
      return HabitsErrorState(
        error: error!,
        onRetry: () {},
      );
    }

    return HabitsList(
      habits: habits,
      onDeleteHabit: onDeleteHabit,
      onRecordHabit: onRecordHabit,
      onNavigateToAdd: onNavigateToAdd,
    );
  }

  Widget _buildAddTab() {
    return HabitAddForm(
      onSubmit: onAddHabit,
    );
  }
}
