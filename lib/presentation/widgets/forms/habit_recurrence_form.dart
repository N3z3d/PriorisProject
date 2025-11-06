import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/forms/components/daily_interval_input.dart';
import 'package:prioris/presentation/widgets/forms/components/recurrence_type_dropdown.dart';
import 'package:prioris/presentation/widgets/forms/components/times_target_input.dart';
import 'package:prioris/presentation/widgets/forms/components/weekdays_selector.dart';

/// Widget pour la récurrence d'une habitude (fréquence et options)
///
/// **SRP** : Compose les composants de récurrence, délègue le rendu aux sous-composants
class HabitRecurrenceForm extends StatelessWidget {
  const HabitRecurrenceForm({
    super.key,
    required this.selectedRecurrenceType,
    required this.onRecurrenceTypeChanged,
    required this.intervalDays,
    required this.onIntervalDaysChanged,
    required this.selectedWeekdays,
    required this.onWeekdaysChanged,
    required this.timesTarget,
    required this.onTimesTargetChanged,
  });

  final RecurrenceType? selectedRecurrenceType;
  final ValueChanged<RecurrenceType?> onRecurrenceTypeChanged;
  final int intervalDays;
  final ValueChanged<int> onIntervalDaysChanged;
  final List<int> selectedWeekdays;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final int timesTarget;
  final ValueChanged<int> onTimesTargetChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final frequencyLabel = l10n?.frequency ?? 'Fréquence';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          frequencyLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        RecurrenceTypeDropdown(
          value: selectedRecurrenceType,
          onChanged: onRecurrenceTypeChanged,
        ),
        if (selectedRecurrenceType == RecurrenceType.dailyInterval) ...[
          const SizedBox(height: 12),
          DailyIntervalInput(
            intervalDays: intervalDays,
            onChanged: onIntervalDaysChanged,
          ),
        ],
        if (selectedRecurrenceType == RecurrenceType.weeklyDays) ...[
          const SizedBox(height: 12),
          WeekdaysSelector(
            selectedWeekdays: selectedWeekdays,
            onChanged: onWeekdaysChanged,
          ),
        ],
        if (selectedRecurrenceType == RecurrenceType.timesPerWeek ||
            selectedRecurrenceType == RecurrenceType.timesPerDay) ...[
          const SizedBox(height: 12),
          TimesTargetInput(
            timesTarget: timesTarget,
            onChanged: onTimesTargetChanged,
            recurrenceType: selectedRecurrenceType!,
          ),
        ],
      ],
    );
  }
}
