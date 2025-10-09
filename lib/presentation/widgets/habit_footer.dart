import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitFooter extends StatelessWidget {
  final Habit habit;

  const HabitFooter({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_hasCategory) _buildCategoryChip(context),
        const Spacer(),
        _buildRecurrenceChip(context),
      ],
    );
  }

  bool get _hasCategory => habit.category?.isNotEmpty == true;

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      ),
      child: Text(
        habit.category!,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildRecurrenceChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat, size: 12, color: AppTheme.textTertiary),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            _recurrenceText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String get _recurrenceText {
    final type = habit.recurrenceType;
    if (type == null) {
      return 'Quotidien';
    }

    switch (type) {
      case RecurrenceType.dailyInterval:
        return _formatDailyInterval();
      case RecurrenceType.weeklyDays:
        return _formatWeeklyDays();
      case RecurrenceType.timesPerWeek:
        return '${habit.timesTarget ?? 1} fois/semaine';
      case RecurrenceType.timesPerDay:
        return '${habit.timesTarget ?? 1} fois/jour';
      case RecurrenceType.monthly:
        return 'Mensuel (1er)';
      case RecurrenceType.monthlyDay:
        return 'Mensuel (${habit.monthlyDay ?? 1})';
      case RecurrenceType.quarterly:
        return 'Trimestriel';
      case RecurrenceType.yearly:
        return _formatYearly();
      case RecurrenceType.hourlyInterval:
        return 'Toutes les ${(habit.hourlyInterval ?? 1)}h';
      case RecurrenceType.timesPerHour:
        return '${habit.timesTarget ?? 1} fois/heure';
      case RecurrenceType.weekends:
        return 'Weekend seulement';
      case RecurrenceType.weekdays:
        return 'Semaine seulement';
    }
  }

  String _formatDailyInterval() {
    final days = habit.intervalDays ?? 1;
    return days == 1 ? 'Quotidien' : 'Tous les $days jours';
  }

  String _formatWeeklyDays() {
    final weekdays = habit.weekdays ?? [];
    if (weekdays.isEmpty) {
      return 'Aucun jour';
    }
    const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return weekdays.map((index) => dayNames[index]).join(', ');
  }

  String _formatYearly() {
    final month = habit.yearlyMonth ?? 1;
    final day = habit.yearlyDay ?? 1;
    return 'Annuel ($day/$month)';
  }
}
