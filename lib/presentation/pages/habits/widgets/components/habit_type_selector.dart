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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Je veux',
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildChip(
              context,
              label: 'Cocher quand c\'est fait',
              icon: Icons.check_circle_outline,
              value: HabitType.binary,
            ),
            _buildChip(
              context,
              label: 'Mesurer une quantité',
              icon: Icons.stacked_line_chart,
              value: HabitType.quantitative,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _descriptionFor(selectedType),
          key: const ValueKey('habit-type-description'),
          style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.85),
                height: 1.4,
              ),
        ),
      ],
    );
  }

  String _descriptionFor(HabitType type) {
    switch (type) {
      case HabitType.binary:
        return 'Suivez vos routines en cochant chaque fois que c\'est fait.';
      case HabitType.quantitative:
        return 'Suivez une quantité mesurable avec un objectif et une unité.';
    }
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required HabitType value,
  }) {
    final isSelected = selectedType == value;
    return ChoiceChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? AppTheme.accentColor
              : AppTheme.dividerColor.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      selectedColor: AppTheme.accentColor,
      backgroundColor: AppTheme.surfaceColor,
      pressElevation: 0,
      onSelected: (_) => onTypeSelected(value),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
