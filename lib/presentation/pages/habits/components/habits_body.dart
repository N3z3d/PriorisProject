import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habits_error_state.dart';
import 'package:prioris/presentation/pages/habits/components/habits_list.dart';
import 'package:prioris/presentation/pages/habits/components/habits_loading_state.dart';

class HabitsBody extends StatelessWidget {
  final List<Habit> habits;
  final bool isLoading;
  final String? error;
  final void Function(String, String) onDeleteHabit;
  final void Function(Habit) onRecordHabit;
  final VoidCallback onCreateHabit;
  final void Function(Habit) onEditHabit;

  const HabitsBody({
    super.key,
    required this.habits,
    required this.isLoading,
    this.error,
    required this.onDeleteHabit,
    required this.onRecordHabit,
    required this.onCreateHabit,
    required this.onEditHabit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const HabitsLoadingState();
    }

    if (error != null) {
      return HabitsErrorState(
        error: error!,
        onRetry: () {},
      );
    }

    final sortedHabits = [...habits]..sort((a, b) {
        final aCompleted = a.isCompletedToday();
        final bCompleted = b.isCompletedToday();
        if (aCompleted == bCompleted) {
          return a.name.compareTo(b.name);
        }
        return aCompleted ? 1 : -1;
      });

    return HabitsList(
      habits: sortedHabits,
      onDeleteHabit: onDeleteHabit,
      onRecordHabit: onRecordHabit,
      onCreateHabit: onCreateHabit,
      onEditHabit: onEditHabit,
    );
  }
}
