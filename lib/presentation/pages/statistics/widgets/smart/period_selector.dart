import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final List<Map<String, String>> periods;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.periods = const [
      {'value': '7_days', 'label': '7 jours'},
      {'value': '30_days', 'label': '30 jours'},
      {'value': '90_days', 'label': '3 mois'},
      {'value': '365_days', 'label': '1 an'},
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildLabel(),
          const SizedBox(width: 12),
          Expanded(child: _buildPeriodChips()),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      'Periode :',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildPeriodChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map(_buildPeriodChip).toList(),
      ),
    );
  }

  Widget _buildPeriodChip(Map<String, String> period) {
    final value = period['value']!;
    final label = period['label']!;
    final isSelected = selectedPeriod == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onPeriodChanged(value),
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
          backgroundColor: AppTheme.grey100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
              width: 1.5,
            ),
          ),
          elevation: isSelected ? 2 : 0,
          pressElevation: 4,
        ),
      ),
    );
  }
}
