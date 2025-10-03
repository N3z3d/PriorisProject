import 'package:flutter/material.dart';

/// Sélecteur de jours de la semaine
///
/// **SRP** : Gère uniquement la sélection des jours de la semaine
class WeekdaysSelector extends StatelessWidget {
  const WeekdaysSelector({
    super.key,
    required this.selectedWeekdays,
    required this.onChanged,
  });

  final List<int> selectedWeekdays;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jours de la semaine :'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 0; i < 7; i++)
              FilterChip(
                label: Text(_getWeekdayLabel(i)),
                selected: selectedWeekdays.contains(i),
                onSelected: (selected) => _handleSelection(selected, i),
              ),
          ],
        ),
      ],
    );
  }

  String _getWeekdayLabel(int index) {
    return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][index];
  }

  void _handleSelection(bool selected, int weekday) {
    final newList = List<int>.from(selectedWeekdays);
    if (selected) {
      newList.add(weekday);
    } else {
      newList.remove(weekday);
    }
    onChanged(newList);
  }
}
