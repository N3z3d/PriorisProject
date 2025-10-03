import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/buttons/action_button.dart';

/// Actions row for HabitCard (record, edit, delete buttons).
///
/// Responsibilities:
/// - Display action buttons based on provided callbacks
/// - Show appropriate icons and tooltips based on habit type and state
/// - Handle loading state for recording action
///
/// SOLID: SRP - Single responsibility (action buttons rendering)
class HabitCardActions extends StatelessWidget {
  const HabitCardActions({
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
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRecord != null)
          ActionButton(
            icon: _getRecordIcon(),
            color: progressColor,
            onTap: onRecord!,
            tooltip: _getRecordTooltip(),
            isLoading: isRecording,
          ),

        if (onEdit != null)
          ActionButton(
            icon: Icons.edit_outlined,
            color: AppTheme.infoColor,
            onTap: onEdit!,
            tooltip: 'Modifier',
          ),

        if (onDelete != null)
          ActionButton(
            icon: Icons.delete_outline,
            color: AppTheme.errorColor,
            onTap: onDelete!,
            tooltip: 'Supprimer',
          ),
      ],
    );
  }

  IconData _getRecordIcon() {
    if (isRecording) return Icons.hourglass_empty;

    if (habit.type == HabitType.binary) {
      return todayValue == true
          ? Icons.check_circle
          : Icons.add_circle_outline;
    }

    return Icons.edit;
  }

  String _getRecordTooltip() {
    if (habit.type == HabitType.binary) {
      return todayValue == true
          ? 'Marquer comme non fait'
          : 'Marquer comme fait';
    }
    return 'Enregistrer une valeur';
  }
}
