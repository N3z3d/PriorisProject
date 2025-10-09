import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

class RecurrenceTypeDropdown extends StatelessWidget {
  const RecurrenceTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final RecurrenceType? value;
  final ValueChanged<RecurrenceType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<RecurrenceType?>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Frequence',
        border: OutlineInputBorder(),
      ),
      items: _buildItems(),
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<RecurrenceType?>> _buildItems() {
    const definitions = <_RecurrenceDefinition>[
      _RecurrenceDefinition(null, 'Quotidien (par defaut)'),
      _RecurrenceDefinition(RecurrenceType.dailyInterval, 'Tous les X jours'),
      _RecurrenceDefinition(RecurrenceType.weeklyDays, 'Certains jours de la semaine'),
      _RecurrenceDefinition(RecurrenceType.timesPerWeek, 'X fois par semaine'),
      _RecurrenceDefinition(RecurrenceType.timesPerDay, 'X fois par jour'),
      _RecurrenceDefinition(RecurrenceType.monthly, 'Mensuelle (1er du mois)'),
      _RecurrenceDefinition(RecurrenceType.monthlyDay, 'Jour specifique du mois'),
      _RecurrenceDefinition(RecurrenceType.quarterly, 'Trimestrielle'),
      _RecurrenceDefinition(RecurrenceType.yearly, 'Annuelle'),
      _RecurrenceDefinition(RecurrenceType.hourlyInterval, 'Toutes les X heures'),
      _RecurrenceDefinition(RecurrenceType.timesPerHour, 'X fois par heure'),
      _RecurrenceDefinition(RecurrenceType.weekends, 'Seulement le weekend'),
      _RecurrenceDefinition(RecurrenceType.weekdays, 'Seulement en semaine'),
    ];

    return definitions
        .map(
          (definition) => DropdownMenuItem<RecurrenceType?>(
            value: definition.type,
            child: Text(definition.label),
          ),
        )
        .toList();
  }
}

class _RecurrenceDefinition {
  final RecurrenceType? type;
  final String label;

  const _RecurrenceDefinition(this.type, this.label);
}
