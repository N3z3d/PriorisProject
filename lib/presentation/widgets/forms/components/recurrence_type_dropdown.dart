import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Dropdown pour sélectionner le type de récurrence d'une habitude
///
/// **SRP** : Gère uniquement le choix du type de récurrence
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
      onChanged: onChanged,
    );
  }
}
