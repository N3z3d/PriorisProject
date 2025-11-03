import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final options = _options(l10n);
    final option = options[selectedType]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.habitFormTypePrompt,
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<HabitType>(
          key: const ValueKey('habit-type-dropdown'),
          value: selectedType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surfaceColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.accentColor,
                width: 1.6,
              ),
            ),
          ),
          dropdownColor: AppTheme.surfaceColor,
          icon: const Icon(Icons.expand_more_rounded),
          items: options.entries
              .map(
                (entry) => DropdownMenuItem<HabitType>(
                  value: entry.key,
                  child: Text(
                    entry.value.choiceLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onTypeSelected(value);
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              option.icon,
              size: 18,
              color: AppTheme.accentColor.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.description,
                key: const ValueKey('habit-type-description'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.85),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Map<HabitType, _HabitTypeOption> _options(AppLocalizations l10n) => {
      HabitType.binary: _HabitTypeOption(
        choiceLabel: l10n.habitFormTypeBinaryOption,
        description: l10n.habitFormTypeBinaryDescription,
        icon: Icons.check_circle_outline,
      ),
      HabitType.quantitative: _HabitTypeOption(
        choiceLabel: l10n.habitFormTypeQuantOption,
        description: l10n.habitFormTypeQuantDescription,
        icon: Icons.stacked_line_chart,
      ),
    };

class _HabitTypeOption {
  const _HabitTypeOption({
    required this.choiceLabel,
    required this.description,
    required this.icon,
  });

  final String choiceLabel;
  final String description;
  final IconData icon;
}
