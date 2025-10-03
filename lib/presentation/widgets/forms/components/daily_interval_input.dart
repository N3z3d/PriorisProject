import 'package:flutter/material.dart';

/// Input pour spécifier un intervalle en jours
///
/// **SRP** : Gère uniquement l'input de l'intervalle quotidien
class DailyIntervalInput extends StatelessWidget {
  const DailyIntervalInput({
    super.key,
    required this.intervalDays,
    required this.onChanged,
  });

  final int intervalDays;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onChanged: (value) => onChanged(int.tryParse(value) ?? 1),
          ),
        ),
        const Text(' jour(s)'),
      ],
    );
  }
}
