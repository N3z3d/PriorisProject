import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';

/// Widget affichant la distribution des scores ELO des tâches (PieChart)
/// [tasks] : Liste des tâches à analyser
class EloDistributionWidget extends StatelessWidget {
  final List<Task> tasks;

  const EloDistributionWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final distribution = _calculateEloDistribution();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Distribution ELO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(distribution),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calcule la distribution des scores ELO
  Map<String, int> _calculateEloDistribution() {
    final stats = TaskCalculationService.calculateEloStatistics(tasks);
    return (stats['distribution'] as Map<String, int>? ?? {'easy': 0, 'medium': 0, 'hard': 0});
  }

  /// Construit les sections du graphique camembert
  List<PieChartSectionData> _buildPieSections(Map<String, int> distribution) {
    final total = tasks.length;
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'Aucune tâche',
          color: Colors.grey,
          radius: 50,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: distribution['easy']!.toDouble(),
        title: 'Facile\n1000-1200',
        color: AppTheme.successColor,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: distribution['medium']!.toDouble(),
        title: 'Moyen\n1200-1400',
        color: AppTheme.primaryColor,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: distribution['hard']!.toDouble(),
        title: 'Difficile\n1400+',
        color: AppTheme.errorColor,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }
} 
