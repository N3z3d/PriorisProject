import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habit_card.dart';
import 'package:prioris/presentation/pages/habits/components/habits_empty_state.dart';
import 'package:prioris/presentation/widgets/common/lists/virtualized_list.dart';

/// List component for habits following SRP
/// Responsible only for rendering the habits list
class HabitsList extends StatelessWidget {
  final List<Habit> habits;
  final Function(String, String) onDeleteHabit;
  final Function(Habit) onRecordHabit;
  final VoidCallback onCreateHabit;
  final Function(Habit) onEditHabit;

  const HabitsList({
    super.key,
    required this.habits,
    required this.onDeleteHabit,
    required this.onRecordHabit,
    required this.onCreateHabit,
    required this.onEditHabit,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return HabitsEmptyState(
        onCreateHabit: onCreateHabit,
      );
    }

    return VirtualizedList<Habit>(
      items: habits,
      padding: const EdgeInsets.all(16),
      cacheExtent: 500,
      itemBuilder: (context, habit, index) => HabitCard(
        habit: habit,
        onDelete: () => onDeleteHabit(habit.id, habit.name),
        onRecord: () => onRecordHabit(habit),
        onEdit: () => onEditHabit(habit),
        onTap: () => _handleTap(context, habit),
      ),
      emptyWidget: HabitsEmptyState(
        onCreateHabit: onCreateHabit,
      ),
    );
  }

  void _handleTap(BuildContext context, Habit habit) {
    // Pending: Show habit details or perform action
  }
}
