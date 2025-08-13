import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Widget pour la récurrence d'une habitude (fréquence et options)
class HabitRecurrenceForm extends StatelessWidget {
  final RecurrenceType? selectedRecurrenceType;
  final ValueChanged<RecurrenceType?> onRecurrenceTypeChanged;
  final int intervalDays;
  final ValueChanged<int> onIntervalDaysChanged;
  final List<int> selectedWeekdays;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final int timesTarget;
  final ValueChanged<int> onTimesTargetChanged;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Récurrence',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType?>(
          value: selectedRecurrenceType,
          decoration: const InputDecoration(
            labelText: 'Fréquence',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('Quotidien (par défaut)'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.dailyInterval,
              child: Text('Tous les X jours'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.weeklyDays,
              child: Text('Certains jours de la semaine'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.timesPerWeek,
              child: Text('X fois par semaine'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.timesPerDay,
              child: Text('X fois par jour'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.monthly,
              child: Text('📅 Mensuelle (1er du mois)'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.monthlyDay,
              child: Text('📅 Jour spécifique du mois'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.quarterly,
              child: Text('📅 Trimestrielle'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.yearly,
              child: Text('📅 Annuelle'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.hourlyInterval,
              child: Text('⏰ Toutes les X heures'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.timesPerHour,
              child: Text('⏰ X fois par heure'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.weekends,
              child: Text('🌅 Seulement le weekend'),
            ),
            DropdownMenuItem(
              value: RecurrenceType.weekdays,
              child: Text('💼 Seulement en semaine'),
            ),
          ],
          onChanged: onRecurrenceTypeChanged,
        ),
        if (selectedRecurrenceType == RecurrenceType.dailyInterval) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Tous les '),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: intervalDays.toString(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => onIntervalDaysChanged(int.tryParse(value) ?? 1),
                ),
              ),
              const Text(' jour(s)'),
            ],
          ),
        ],
        if (selectedRecurrenceType == RecurrenceType.weeklyDays) ...[
          const SizedBox(height: 12),
          const Text('Jours de la semaine :'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (int i = 0; i < 7; i++)
                FilterChip(
                  label: Text(['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][i]),
                  selected: selectedWeekdays.contains(i),
                  onSelected: (selected) {
                    final newList = List<int>.from(selectedWeekdays);
                    if (selected) {
                      newList.add(i);
                    } else {
                      newList.remove(i);
                    }
                    onWeekdaysChanged(newList);
                  },
                ),
            ],
          ),
        ],
        if (selectedRecurrenceType == RecurrenceType.timesPerWeek || 
            selectedRecurrenceType == RecurrenceType.timesPerDay) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: timesTarget.toString(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => onTimesTargetChanged(int.tryParse(value) ?? 1),
                ),
              ),
              Text(selectedRecurrenceType == RecurrenceType.timesPerWeek 
                  ? ' fois par semaine' 
                  : ' fois par jour'),
            ],
          ),
        ],
      ],
    );
  }
} 
