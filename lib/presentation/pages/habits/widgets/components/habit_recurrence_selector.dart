import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fréquence',
          style: TextStyle(
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
                  child: Text(_recurrenceLabel(recurrence)),
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

  String _recurrenceLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.dailyInterval:
        return 'Quotidienne';
      case RecurrenceType.weeklyDays:
        return 'Hebdomadaire';
      case RecurrenceType.monthly:
        return 'Mensuelle';
      case RecurrenceType.timesPerWeek:
        return 'Plusieurs fois par semaine';
      case RecurrenceType.timesPerDay:
        return 'Plusieurs fois par jour';
      case RecurrenceType.monthlyDay:
        return 'Jour fixe du mois';
      case RecurrenceType.quarterly:
        return 'Trimestrielle';
      case RecurrenceType.yearly:
        return 'Annuelle';
      case RecurrenceType.hourlyInterval:
        return 'Toutes les X heures';
      case RecurrenceType.timesPerHour:
        return 'Plusieurs fois par heure';
      case RecurrenceType.weekends:
        return 'Week-ends';
      case RecurrenceType.weekdays:
        return 'Jours de semaine';
    }
  }
}
