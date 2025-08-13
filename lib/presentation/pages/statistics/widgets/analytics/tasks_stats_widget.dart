import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/stat_item.dart';

/// Widget affichant les statistiques des tâches (terminées, en cours, ELO, temps)
/// [tasks] : Liste des tâches à analyser
class TasksStatsWidget extends StatelessWidget {
  final List<Task> tasks;

  const TasksStatsWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    final averageElo = TaskCalculationService.calculateAverageElo(tasks);
    final averageTime = TaskCalculationService.calculateAverageCompletionTime(tasks);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Statistiques des Tâches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    value: '$completedTasks',
                    label: 'Tâches terminées',
                    icon: Icons.task_alt,
                  ),
                ),
                Expanded(
                  child: StatItem(
                    value: '$pendingTasks',
                    label: 'En cours',
                    icon: Icons.pending_actions,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    value: averageElo.toStringAsFixed(0),
                    label: 'ELO moyen',
                    icon: Icons.emoji_events,
                  ),
                ),
                Expanded(
                  child: StatItem(
                    value: '${averageTime.toStringAsFixed(1)}j',
                    label: 'Temps moyen',
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
