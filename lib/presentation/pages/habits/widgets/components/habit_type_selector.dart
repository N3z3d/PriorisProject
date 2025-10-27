import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitTypeSelector extends StatelessWidget {
  const HabitTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final HabitType selectedType;
  final ValueChanged<HabitType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type d\'habitude',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TypeOption(
                label: 'Oui / Non',
                icon: Icons.check_circle,
                type: HabitType.binary,
                isSelected: selectedType == HabitType.binary,
                onTap: () => onTypeSelected(HabitType.binary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeOption(
                label: 'Quantité',
                icon: Icons.show_chart,
                type: HabitType.quantitative,
                isSelected: selectedType == HabitType.quantitative,
                onTap: () => onTypeSelected(HabitType.quantitative),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.icon,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final HabitType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.accentColor : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
