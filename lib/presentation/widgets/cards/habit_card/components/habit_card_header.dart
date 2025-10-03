import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/badges/habit_type_badge.dart';
import 'habit_card_actions.dart';

/// Header section of HabitCard containing type badge and action buttons.
///
/// Responsibilities:
/// - Display habit type badge on the left
/// - Display action buttons on the right
/// - Maintain proper spacing and alignment
///
/// SOLID: SRP - Single responsibility (header layout)
class HabitCardHeader extends StatelessWidget {
  const HabitCardHeader({
    super.key,
    required this.habit,
    required this.todayValue,
    required this.progressColor,
    this.onRecord,
    this.onEdit,
    this.onDelete,
    this.isRecording = false,
  });

  final Habit habit;
  final dynamic todayValue;
  final VoidCallback? onRecord;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color progressColor;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HabitTypeBadge(type: habit.type),

        const Spacer(),

        HabitCardActions(
          habit: habit,
          todayValue: todayValue,
          progressColor: progressColor,
          onRecord: onRecord,
          onEdit: onEdit,
          onDelete: onDelete,
          isRecording: isRecording,
        ),
      ],
    );
  }
}
