import 'package:flutter/material.dart';
import 'package:prioris/presentation/pages/statistics/services/statistics_calculation_service.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

class CategoryPerformanceWidget extends StatelessWidget {
  final Map<String, double> categories;

  const CategoryPerformanceWidget({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildContent(),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      const Text(
        'Performance par categorie',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      ...categories.entries.map(_buildCategorySection),
    ];
  }

  Widget _buildCategorySection(MapEntry<String, double> entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(entry),
          const SizedBox(height: 8),
          _buildProgressBar(entry.value),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(MapEntry<String, double> entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          entry.key,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          '${entry.value.toInt()}%',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percentage) {
    return LinearProgressIndicator(
      value: (percentage / 100).clamp(0.0, 1.0),
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        StatisticsCalculationService.getProgressColor(percentage),
      ),
      minHeight: 8,
    );
  }
}
