import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/stat_item.dart';

class TasksStatsWidget extends StatelessWidget {
  final List<Task> tasks;

  const TasksStatsWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = _TaskStatsMetrics.fromTasks(tasks);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildContent(metrics),
        ),
      ),
    );
  }

  List<Widget> _buildContent(_TaskStatsMetrics metrics) {
    return [
      const Text(
        'Task statistics',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      _buildRow(
        StatItem(
          value: '${metrics.completed}',
          label: 'Completed tasks',
          icon: Icons.task_alt,
        ),
        StatItem(
          value: '${metrics.pending}',
          label: 'In progress',
          icon: Icons.pending_actions,
        ),
      ),
      const SizedBox(height: 16),
      _buildRow(
        StatItem(
          value: metrics.averageElo.toStringAsFixed(0),
          label: 'Average ELO',
          icon: Icons.emoji_events,
        ),
        StatItem(
          value: '${metrics.averageTimeDays.toStringAsFixed(1)}d',
          label: 'Average time',
          icon: Icons.schedule,
        ),
      ),
    ];
  }

  Widget _buildRow(StatItem left, StatItem right) {
    return Row(
      children: [
        Expanded(child: left),
        Expanded(child: right),
      ],
    );
  }
}

class _TaskStatsMetrics {
  final int completed;
  final int pending;
  final double averageElo;
  final double averageTimeDays;

  const _TaskStatsMetrics({
    required this.completed,
    required this.pending,
    required this.averageElo,
    required this.averageTimeDays,
  });

  factory _TaskStatsMetrics.fromTasks(List<Task> tasks) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final pending = tasks.length - completed;
    final averageElo = TaskCalculationService.calculateAverageElo(tasks);
    final averageTime = TaskCalculationService.calculateAverageCompletionTime(tasks);
    return _TaskStatsMetrics(
      completed: completed,
      pending: pending,
      averageElo: averageElo,
      averageTimeDays: averageTime,
    );
  }
}
