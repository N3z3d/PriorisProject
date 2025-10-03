import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Input pour le nombre de fois (par semaine/jour)
///
/// **SRP** : Gère uniquement l'input du nombre de répétitions
class TimesTargetInput extends StatelessWidget {
  const TimesTargetInput({
    super.key,
    required this.timesTarget,
    required this.onChanged,
    required this.recurrenceType,
  });

  final int timesTarget;
  final ValueChanged<int> onChanged;
  final RecurrenceType recurrenceType;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onChanged: (value) => onChanged(int.tryParse(value) ?? 1),
          ),
        ),
        Text(_getSuffix()),
      ],
    );
  }

  String _getSuffix() {
    return recurrenceType == RecurrenceType.timesPerWeek
        ? ' fois par semaine'
        : ' fois par jour';
  }
}
