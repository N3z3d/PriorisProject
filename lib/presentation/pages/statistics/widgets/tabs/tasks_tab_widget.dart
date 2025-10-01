import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/tasks_stats_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/elo_distribution_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/completion_time_stats_widget.dart';

/// Widget affichant l'onglet Tâches des statistiques
/// 
/// Ce widget regroupe tous les widgets de l'onglet Tâches :
/// - Statistiques des tâches (TasksStatsWidget)
/// - Distribution ELO (EloDistributionWidget)
/// - Temps de complétion (CompletionTimeStatsWidget)
class TasksTabWidget extends StatelessWidget {
  /// Liste des tâches à analyser
  final List<Task> tasks;

  const TasksTabWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques des tâches
          TasksStatsWidget(tasks: tasks),
          const SizedBox(height: 24),
          
          // Distribution ELO
          EloDistributionWidget(data: _getEloDistributionData()),
          const SizedBox(height: 24),
          
          // Temps de complétion
          CompletionTimeStatsWidget(tasks: tasks),
        ],
      ),
    );
  }

  /// Génère les données de distribution ELO pour le graphique
  List<Map<String, dynamic>> _getEloDistributionData() {
    if (tasks.isEmpty) return [];

    // Grouper les tâches par intervalles d'ELO
    final eloRanges = <String, int>{
      '1000-1199': 0,
      '1200-1399': 0,
      '1400-1599': 0,
      '1600-1799': 0,
      '1800+': 0,
    };

    for (final task in tasks) {
      final elo = task.elo?.value ?? 1200;
      if (elo < 1200) {
        eloRanges['1000-1199'] = (eloRanges['1000-1199'] ?? 0) + 1;
      } else if (elo < 1400) {
        eloRanges['1200-1399'] = (eloRanges['1200-1399'] ?? 0) + 1;
      } else if (elo < 1600) {
        eloRanges['1400-1599'] = (eloRanges['1400-1599'] ?? 0) + 1;
      } else if (elo < 1800) {
        eloRanges['1600-1799'] = (eloRanges['1600-1799'] ?? 0) + 1;
      } else {
        eloRanges['1800+'] = (eloRanges['1800+'] ?? 0) + 1;
      }
    }

    return eloRanges.entries.map((entry) => {
      'range': entry.key,
      'count': entry.value,
    }).toList();
  }
} 
