import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/main_metrics_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/smart_insights_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/category_performance_widget.dart';
import 'package:prioris/presentation/pages/statistics/services/statistics_calculation_service.dart';
import 'package:prioris/domain/services/insights/insights_generation_service.dart';
import 'package:prioris/presentation/widgets/charts/premium_progress_chart.dart';
import 'package:prioris/presentation/widgets/metrics/premium_metrics_dashboard.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget affichant l'onglet Vue d'ensemble des statistiques
/// 
/// Ce widget regroupe tous les widgets de l'onglet Vue d'ensemble :
/// - Métriques principales (MainMetricsWidget)
/// - Graphique de progression (ProgressChartWidget)
/// - Insights intelligents (SmartInsightsWidget)
/// - Performance par catégorie (CategoryPerformanceWidget)
class OverviewTabWidget extends StatelessWidget {
  /// Période sélectionnée pour les calculs
  final String selectedPeriod;
  
  /// Liste des habitudes à analyser
  final List<Habit> habits;
  
  /// Liste des tâches à analyser
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
          // Premium Metrics Dashboard
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

          // Premium Progress Chart
          PremiumProgressChart(
            data: _getProgressData(),
            title: 'Progression générale',
            subtitle: 'Évolution de vos performances sur la période sélectionnée',
            primaryColor: AppTheme.primaryColor,
            gradientColor: AppTheme.primaryVariant,
            height: 300,
          ),
          const SizedBox(height: 32),

          // Insights intelligents
          SmartInsightsWidget(
            insights: _getSmartInsights(),
          ),
          const SizedBox(height: 32),

          // Performance par catégorie
          CategoryPerformanceWidget(
            categories: _getCategoryPerformance(),
          ),
        ],
      ),
    );
  }

  /// Récupère les métriques principales
  Future<Map<String, dynamic>> _getMainMetrics() async {
    return StatisticsCalculationService.calculateMainMetrics(habits, tasks);
  }

  /// Génère les données de progression pour le graphique premium
  List<ChartDataPoint> _getProgressData() {
    // Données simulées basées sur la période sélectionnée
    switch (selectedPeriod) {
      case '7_days':
        return [
          const ChartDataPoint(label: 'Lun', value: 65),
          const ChartDataPoint(label: 'Mar', value: 70),
          const ChartDataPoint(label: 'Mer', value: 68),
          const ChartDataPoint(label: 'Jeu', value: 75),
          const ChartDataPoint(label: 'Ven', value: 80),
          const ChartDataPoint(label: 'Sam', value: 85),
          const ChartDataPoint(label: 'Dim', value: 88),
        ];
      case '30_days':
        return List.generate(
          30,
          (index) => ChartDataPoint(
            label: '${index + 1}',
            value: 70 + (index * 0.6),
          ),
        );
      case '90_days':
        return List.generate(
          90,
          (index) => ChartDataPoint(
            label: '${index + 1}',
            value: 65 + (index * 0.3),
          ),
        );
      case '365_days':
        return List.generate(
          365,
          (index) => ChartDataPoint(
            label: '${index + 1}',
            value: 60 + (index * 0.08),
          ),
        );
      default:
        return [
          const ChartDataPoint(label: 'Lun', value: 65),
          const ChartDataPoint(label: 'Mar', value: 70),
          const ChartDataPoint(label: 'Mer', value: 68),
          const ChartDataPoint(label: 'Jeu', value: 75),
          const ChartDataPoint(label: 'Ven', value: 80),
          const ChartDataPoint(label: 'Sam', value: 85),
          const ChartDataPoint(label: 'Dim', value: 88),
        ];
    }
  }

  /// Génère les labels de période pour l'axe X
  List<String> _getPeriodLabels() {
    switch (selectedPeriod) {
      case '7_days':
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      case '30_days':
        return List.generate(30, (index) => '${index + 1}');
      case '90_days':
        return List.generate(90, (index) => '${index + 1}');
      case '365_days':
        return List.generate(365, (index) => '${index + 1}');
      default:
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    }
  }

  /// Génère les insights intelligents
  List<Map<String, dynamic>> _getSmartInsights() {
    return InsightsGenerationService.generateSmartInsights(habits, tasks);
  }

  /// Calcule la performance par catégorie
  Map<String, double> _getCategoryPerformance() {
    return StatisticsCalculationService.calculateCategoryPerformance(habits, tasks);
  }
} 
