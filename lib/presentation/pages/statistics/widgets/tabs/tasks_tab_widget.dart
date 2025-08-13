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
          EloDistributionWidget(tasks: tasks),
          const SizedBox(height: 24),
          
          // Temps de complétion
          CompletionTimeStatsWidget(tasks: tasks),
        ],
      ),
    );
  }
} 
