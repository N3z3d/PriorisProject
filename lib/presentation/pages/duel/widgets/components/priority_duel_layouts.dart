import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_arena.dart';

/// Layout pour un duel à 2 cartes avec badge VS
class DuelTwoCardsLayout extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final Future<void> Function(Task winner, List<Task> losers) onSelectWinner;

  const DuelTwoCardsLayout({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectWinner,
  }) : assert(tasks.length == 2);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth < 720 ? 20.0 : 32.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCard(tasks[0]),
            const PriorityVsBadge(),
            _buildCard(tasks[1]),
          ],
        );
      },
    );
  }

  Widget _buildCard(Task task) {
    final losers = tasks.where((t) => t.id != task.id).toList();
    return DuelTaskCard(
      key: ValueKey('duel-card-${task.id}'),
      task: task,
      hideElo: hideEloScores,
      onTap: () => onSelectWinner(task, losers),
    );
  }
}

/// Layout pour un duel à 3 cartes (responsive)
class DuelThreeCardsLayout extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final Future<void> Function(Task winner, List<Task> losers) onSelectWinner;

  const DuelThreeCardsLayout({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectWinner,
  }) : assert(tasks.length == 3);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        if (isNarrow) {
          return _buildVerticalLayout();
        }
        return _buildHorizontalLayout();
      },
    );
  }

  Widget _buildHorizontalLayout() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: tasks.map(_buildCard).toList(),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < tasks.length; i++) ...[
          _buildCard(tasks[i]),
          if (i < tasks.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildCard(Task task) {
    final losers = tasks.where((t) => t.id != task.id).toList();
    return DuelTaskCard(
      key: ValueKey('duel-card-${task.id}'),
      task: task,
      hideElo: hideEloScores,
      onTap: () => onSelectWinner(task, losers),
    );
  }
}

/// Layout pour un duel à 4 cartes (grille 2×2)
class DuelFourCardsLayout extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final Future<void> Function(Task winner, List<Task> losers) onSelectWinner;

  const DuelFourCardsLayout({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectWinner,
  }) : assert(tasks.length == 4);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardWidth = (constraints.maxWidth - 32) / 2;
        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: tasks.map(_buildCard).toList(),
        );
      },
    );
  }

  Widget _buildCard(Task task) {
    final losers = tasks.where((t) => t.id != task.id).toList();
    return DuelTaskCard(
      key: ValueKey('duel-card-${task.id}'),
      task: task,
      hideElo: hideEloScores,
      onTap: () => onSelectWinner(task, losers),
    );
  }
}
