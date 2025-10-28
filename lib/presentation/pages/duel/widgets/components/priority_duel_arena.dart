import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_layouts.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/elo_badge.dart';

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
    return _buildLayoutForCardCount();
  }

  Widget _buildLayoutForCardCount() {
    // Adapter pour la nouvelle signature (winner + losers)
    Future<void> handleWinnerSelection(Task winner, List<Task> losers) async {
      // Pour compatibilité: on utilise le premier perdant
      // Le controller gérera les comparaisons multiples si nécessaire
      if (losers.isNotEmpty) {
        await onSelectTask(winner, losers.first);
      }
    }

    switch (tasks.length) {
      case 2:
        return DuelTwoCardsLayout(
          tasks: tasks,
          hideEloScores: hideEloScores,
          onSelectWinner: handleWinnerSelection,
        );
      case 3:
        return DuelThreeCardsLayout(
          tasks: tasks,
          hideEloScores: hideEloScores,
          onSelectWinner: handleWinnerSelection,
        );
      case 4:
        return DuelFourCardsLayout(
          tasks: tasks,
          hideEloScores: hideEloScores,
          onSelectWinner: handleWinnerSelection,
        );
      default:
        // Fallback: utilise layout 3 cartes avec les premières tâches
        return DuelThreeCardsLayout(
          tasks: tasks.take(3).toList(),
          hideEloScores: hideEloScores,
          onSelectWinner: handleWinnerSelection,
        );
    }
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
                  : EloBadge(score: task.eloScore, compact: true),
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
