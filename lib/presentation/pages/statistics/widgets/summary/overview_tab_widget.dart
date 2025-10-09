import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/progress_calculation_service.dart';
import 'package:prioris/domain/services/insights/insights_generation_service.dart';
import 'package:prioris/presentation/pages/statistics/services/statistics_calculation_service.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/category_performance_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/smart_insights_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/main_metrics_widget.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/charts/premium_progress_chart.dart';
import 'package:prioris/presentation/widgets/metrics/premium_metrics_dashboard.dart';

/// Widget affichant l'onglet Vue d'ensemble des statistiques.
///
/// Il regroupe :
/// - les métriques principales (MainMetricsWidget)
/// - le graphique de progression (PremiumProgressChart)
/// - les insights intelligents (SmartInsightsWidget)
/// - la performance par catégorie (CategoryPerformanceWidget)
class OverviewTabWidget extends StatelessWidget {
  /// Période sélectionnée pour les calculs.
  final String selectedPeriod;

  /// Liste des habitudes à analyser.
  final List<Habit> habits;

  /// Liste des tâches à analyser.
  final List<Task> tasks;

  const OverviewTabWidget({
    super.key,
    required this.selectedPeriod,
    required this.habits,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _getMainMetrics(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return PremiumMetricsDashboard(
                  metrics: snapshot.data!,
                  enableAnimations: true,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 32),
          PremiumProgressChart(
            data: _getProgressData(),
            title: 'Progression gǸnǸrale',
            subtitle: '�%volution de vos performances sur la pǸriode sǸlectionnǸe',
            primaryColor: AppTheme.primaryColor,
            gradientColor: AppTheme.primaryVariant,
            height: 300,
          ),
          const SizedBox(height: 32),
          SmartInsightsWidget(
            insights: _getSmartInsights(),
          ),
          const SizedBox(height: 32),
          CategoryPerformanceWidget(
            categories: _getCategoryPerformance(),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getMainMetrics() async {
    return StatisticsCalculationService.calculateMainMetrics(habits, tasks);
  }

  List<ChartDataPoint> _getProgressData() {
    final points = ProgressCalculationService.generateProgressData(
      selectedPeriod,
      habits,
      tasks,
    );

    if (points.isEmpty) {
      final labels = ProgressCalculationService.generatePeriodLabels(selectedPeriod);
      return labels.map((label) => ChartDataPoint(label: label, value: 0)).toList();
    }

    return points
        .map(
          (point) => ChartDataPoint(
            label: point.label,
            value: point.value,
            date: point.date,
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> _getSmartInsights() {
    return InsightsGenerationService.generateSmartInsights(habits, tasks);
  }

  Map<String, double> _getCategoryPerformance() {
    return StatisticsCalculationService.calculateCategoryPerformance(habits, tasks);
  }
}
