import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/l10n/app_localizations.dart';

class HabitRecurrenceSelector extends StatelessWidget {
  const HabitRecurrenceSelector({
    super.key,
    required this.selectedRecurrence,
    required this.onRecurrenceChanged,
  });

  final RecurrenceType selectedRecurrence;
  final ValueChanged<RecurrenceType> onRecurrenceChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.frequency,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType>(
          value: selectedRecurrence,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(
              Icons.schedule,
              color: AppTheme.accentColor,
            ),
          ),
          items: RecurrenceType.values
              .map(
                (recurrence) => DropdownMenuItem(
                  value: recurrence,
                  child: Text(_recurrenceLabel(recurrence, l10n)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onRecurrenceChanged(value);
            }
          },
        ),
      ],
    );
  }

  String _recurrenceLabel(RecurrenceType type, AppLocalizations l10n) {
    switch (type) {
      case RecurrenceType.dailyInterval:
        return l10n.habitRecurrenceDaily;
      case RecurrenceType.weeklyDays:
        return l10n.habitRecurrenceWeekly;
      case RecurrenceType.monthly:
        return l10n.habitRecurrenceMonthly;
      case RecurrenceType.timesPerWeek:
        return l10n.habitRecurrenceTimesPerWeek;
      case RecurrenceType.timesPerDay:
        return l10n.habitRecurrenceTimesPerDay;
      case RecurrenceType.monthlyDay:
        return l10n.habitRecurrenceMonthlyDay;
      case RecurrenceType.quarterly:
        return l10n.habitRecurrenceQuarterly;
      case RecurrenceType.yearly:
        return l10n.habitRecurrenceYearly;
      case RecurrenceType.hourlyInterval:
        return l10n.habitRecurrenceHourlyInterval;
      case RecurrenceType.timesPerHour:
        return l10n.habitRecurrenceTimesPerHour;
      case RecurrenceType.weekends:
        return l10n.habitRecurrenceWeekends;
      case RecurrenceType.weekdays:
        return l10n.habitRecurrenceWeekdays;
    }
  }
}
