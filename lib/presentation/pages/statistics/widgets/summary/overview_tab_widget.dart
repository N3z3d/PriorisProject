import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/main_metrics_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/progress_chart_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/smart_insights_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/category_performance_widget.dart';
import 'package:prioris/presentation/pages/statistics/services/statistics_calculation_service.dart';
import 'package:prioris/domain/services/insights/insights_generation_service.dart';

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
          // Métriques principales
          MainMetricsWidget(
            metricsFuture: _getMainMetrics(),
          ),
          const SizedBox(height: 24),
          
          // Graphique de progression globale
          ProgressChartWidget(
            data: _getProgressData(),
            periodLabels: _getPeriodLabels(),
          ),
          const SizedBox(height: 24),
          
          // Insights intelligents
          SmartInsightsWidget(
            insights: _getSmartInsights(),
          ),
          const SizedBox(height: 24),
          
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

  /// Génère les données de progression pour le graphique
  List<FlSpot> _getProgressData() {
    // Données simulées basées sur la période sélectionnée
    switch (selectedPeriod) {
      case '7_days':
        return const [
          FlSpot(0, 65),
          FlSpot(1, 70),
          FlSpot(2, 68),
          FlSpot(3, 75),
          FlSpot(4, 80),
          FlSpot(5, 85),
          FlSpot(6, 88),
        ];
      case '30_days':
        return List.generate(30, (index) => FlSpot(index.toDouble(), 70 + (index * 0.6)));
      case '90_days':
        return List.generate(90, (index) => FlSpot(index.toDouble(), 65 + (index * 0.3)));
      case '365_days':
        return List.generate(365, (index) => FlSpot(index.toDouble(), 60 + (index * 0.08)));
      default:
        return const [
          FlSpot(0, 65),
          FlSpot(1, 70),
          FlSpot(2, 68),
          FlSpot(3, 75),
          FlSpot(4, 80),
          FlSpot(5, 85),
          FlSpot(6, 88),
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
