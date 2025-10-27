import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class PriorityDuelArena extends StatelessWidget {
  final DuelMode mode;
  final List<Task> tasks;
  final bool hideEloScores;
  final Future<void> Function(Task winner, Task loser) onSelectTask;
  final void Function(int oldIndex, int newIndex) onReorderRanking;

  const PriorityDuelArena({
    super.key,
    required this.mode,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectTask,
    required this.onReorderRanking,
  }) : assert(tasks.length >= 2);

  @override
  Widget build(BuildContext context) {
    return mode == DuelMode.ranking
        ? PriorityRankingArena(
            tasks: tasks,
            hideEloScores: hideEloScores,
            onReorder: onReorderRanking,
          )
        : PriorityWinnerArena(
            tasks: tasks,
            hideEloScores: hideEloScores,
            onSelectTask: onSelectTask,
          );
  }
}

class PriorityWinnerArena extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final Future<void> Function(Task winner, Task loser) onSelectTask;

  const PriorityWinnerArena({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectTask,
  }) : assert(tasks.length >= 2);

  @override
  Widget build(BuildContext context) {
    final primary = tasks[0];
    final secondary = tasks[1];
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth < 720 ? 20.0 : 32.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCandidate(primary, secondary),
            const PriorityVsBadge(),
            _buildCandidate(secondary, primary),
          ],
        );
      },
    );
  }

  Widget _buildCandidate(Task task, Task opponent) {
    return DuelTaskCard(
      key: ValueKey('priority-duel-card-${task.id}'),
      task: task,
      hideElo: hideEloScores,
      onTap: () => onSelectTask(task, opponent),
    );
  }
}

class PriorityRankingArena extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final void Function(int oldIndex, int newIndex) onReorder;

  const PriorityRankingArena({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          key: ValueKey('ranking-item-${task.id}'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            elevation: 3,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                foregroundColor: AppTheme.primaryColor,
                child: Text('${index + 1}'),
              ),
              title: Text(
                task.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: hideEloScores
                  ? null
                  : Text(
                      'ELO ${task.eloScore.toStringAsFixed(0)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
              trailing: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle_rounded),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PriorityVsBadge extends StatelessWidget {
  const PriorityVsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final divider = AppTheme.dividerColor.withValues(alpha: 0.8);
    return SizedBox(
      height: 64,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Row(
              children: [
                Expanded(child: Container(height: 1, color: divider)),
                Expanded(child: Container(height: 1, color: divider)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'VS',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
