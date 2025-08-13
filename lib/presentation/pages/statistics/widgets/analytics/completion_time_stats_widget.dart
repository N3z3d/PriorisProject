import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';

/// Modèle pour les statistiques de temps de complétion par catégorie
class CompletionTimeStats {
  final String category;
  final String time;
  final double percentage;

  const CompletionTimeStats({
    required this.category,
    required this.time,
    required this.percentage,
  });
}

/// Widget affichant les statistiques de temps de complétion par catégorie
/// [tasks] : Liste des tâches à analyser
class CompletionTimeStatsWidget extends StatelessWidget {
  final List<Task> tasks;

  const CompletionTimeStatsWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final completionTimes = _calculateCompletionTimeStats();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⏱️ Temps de Complétion par Catégorie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...completionTimes.map((stats) => _buildCompletionTimeItem(stats)),
          ],
        ),
      ),
    );
  }

  /// Calcule les statistiques de temps de complétion par catégorie
  List<CompletionTimeStats> _calculateCompletionTimeStats() {
    final stats = <CompletionTimeStats>[];
    final result = TaskCalculationService.calculateCompletionTimeStats(tasks);
    final rawCategoryTimes = result['categoryTimes'];
    final Map<String, double> categoryTimes = {};
    if (rawCategoryTimes is Map) {
      rawCategoryTimes.forEach((key, value) {
        if (key is String && (value is double || value is int)) {
          categoryTimes[key] = value.toDouble();
        }
      });
    }
    if (categoryTimes.isEmpty) {
      return [
        const CompletionTimeStats(
          category: 'Aucune tâche terminée',
          time: '0 jours',
          percentage: 0.0,
        ),
      ];
    }
    categoryTimes.forEach((category, averageTime) {
      final percentage = _calculatePercentage(averageTime);
      stats.add(CompletionTimeStats(
        category: category,
        time: '${averageTime.toStringAsFixed(1)} jours',
        percentage: percentage,
      ));
    });
    stats.sort((a, b) => a.percentage.compareTo(b.percentage));
    return stats;
  }

  /// Calcule le pourcentage basé sur le temps de complétion
  double _calculatePercentage(double averageTime) {
    // Plus le temps est court, plus le pourcentage est élevé
    if (averageTime <= 1.0) return 100.0;
    if (averageTime <= 2.0) return 85.0;
    if (averageTime <= 3.0) return 70.0;
    if (averageTime <= 5.0) return 50.0;
    if (averageTime <= 7.0) return 30.0;
    return 15.0;
  }

  Widget _buildCompletionTimeItem(CompletionTimeStats stats) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stats.category,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                stats.time,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: stats.percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
} 
