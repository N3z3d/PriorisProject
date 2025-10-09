import 'package:flutter/material.dart';
import 'package:prioris/domain/services/calculation/progress_calculation_service.dart';
import 'package:prioris/presentation/widgets/charts/premium_progress_chart.dart';

/// Widget vitrine pour le graphique de progression.
///
/// Il enveloppe [PremiumProgressChart] dans une carte prête à l'emploi
/// avec titre, sous-titre et logique de repli lorsque les données sont vides.
class ProgressChartWidget extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String period;
  final String title;
  final String subtitle;
  final double height;
  final bool enableAnimation;

  const ProgressChartWidget({
    super.key,
    required this.data,
    this.period = '7_days',
    this.title = '�Y"^ �%volution des Performances',
    this.subtitle = 'Visualisez vos progr��s r��cents et identifiez les tendances.',
    this.height = 260,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartData = data.isEmpty ? _buildFallbackData() : data;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: height,
              child: PremiumProgressChart(
                data: chartData,
                title: '',
                subtitle: '',
                enableAnimation: enableAnimation,
                showGrid: true,
                height: height,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartDataPoint> _buildFallbackData() {
    final labels = ProgressCalculationService.generatePeriodLabels(period);
    return labels
        .map((label) => ChartDataPoint(label: label, value: 0))
        .toList();
  }
}
