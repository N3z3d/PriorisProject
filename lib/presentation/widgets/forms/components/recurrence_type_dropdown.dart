import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';

class RecurrenceTypeDropdown extends StatelessWidget {
  const RecurrenceTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final RecurrenceType? value;
  final ValueChanged<RecurrenceType?> onChanged;

  static const List<RecurrenceType> _orderedTypes = <RecurrenceType>[
    RecurrenceType.dailyInterval,
    RecurrenceType.weeklyDays,
    RecurrenceType.timesPerWeek,
    RecurrenceType.timesPerDay,
    RecurrenceType.monthly,
    RecurrenceType.monthlyDay,
    RecurrenceType.quarterly,
    RecurrenceType.yearly,
    RecurrenceType.hourlyInterval,
    RecurrenceType.timesPerHour,
    RecurrenceType.weekends,
    RecurrenceType.weekdays,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<RecurrenceType?>(
      value: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: _buildItems(l10n),
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<RecurrenceType?>> _buildItems(AppLocalizations? l10n) {
    final items = <DropdownMenuItem<RecurrenceType?>>[
      DropdownMenuItem(
        value: null,
        child: Text(_defaultLabel(l10n)),
      ),
    ];

    for (final type in _orderedTypes) {
      items.add(
        DropdownMenuItem(
          value: type,
          child: Text(_labelForType(type, l10n)),
        ),
      );
    }
    return items;
  }

  String _defaultLabel(AppLocalizations? l10n) {
    if (l10n == null) {
      return 'Daily (default)';
    }
    final defaultText = l10n.defaultValue.toLowerCase();
    return '${l10n.daily} ($defaultText)';
  }

  String _labelForType(RecurrenceType type, AppLocalizations? l10n) {
    switch (type) {
      case RecurrenceType.dailyInterval:
        return l10n?.habitRecurrenceEveryXDays ?? 'Every X days';
      case RecurrenceType.weeklyDays:
        return l10n?.habitRecurrenceSpecificWeekdays ??
            'Specific days of the week';
      case RecurrenceType.timesPerWeek:
        return l10n?.habitRecurrenceTimesPerWeek ??
            'Several times per week';
      case RecurrenceType.timesPerDay:
        return l10n?.habitRecurrenceTimesPerDay ?? 'Several times per day';
      case RecurrenceType.monthly:
        return l10n?.habitRecurrenceMonthly ?? 'Monthly';
      case RecurrenceType.monthlyDay:
        return l10n?.habitRecurrenceMonthlyDay ??
            'Specific day of the month';
      case RecurrenceType.quarterly:
        return l10n?.habitRecurrenceQuarterly ?? 'Quarterly';
      case RecurrenceType.yearly:
        return l10n?.habitRecurrenceYearly ?? 'Yearly';
      case RecurrenceType.hourlyInterval:
        return l10n?.habitRecurrenceHourlyInterval ?? 'Every X hours';
      case RecurrenceType.timesPerHour:
        return l10n?.habitRecurrenceTimesPerHour ??
            'Several times per hour';
      case RecurrenceType.weekends:
        return l10n?.habitRecurrenceWeekends ?? 'Weekends';
      case RecurrenceType.weekdays:
        return l10n?.habitRecurrenceWeekdays ?? 'Weekdays';
    }
  }
}
