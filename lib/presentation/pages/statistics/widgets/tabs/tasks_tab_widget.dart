import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/completion_time_stats_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/tasks_stats_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/elo_distribution_widget.dart';

/// Widget affichant l'onglet Tâches des statistiques.
class TasksTabWidget extends StatelessWidget {
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
          TasksStatsWidget(tasks: tasks),
          const SizedBox(height: 24),
          EloDistributionWidget(tasks: tasks),
          const SizedBox(height: 24),
          CompletionTimeStatsWidget(tasks: tasks),
        ],
      ),
    );
  }
}
