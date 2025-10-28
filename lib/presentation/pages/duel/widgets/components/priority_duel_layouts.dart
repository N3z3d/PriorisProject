import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_arena.dart';

/// Layout pour un duel à 2 cartes avec badge VS strictement centré
///
/// Responsive:
/// - Mobile (<720px): Vertical (1 carte/ligne), VS entre les cartes
/// - Desktop (≥720px): Horizontal avec VS parfaitement centré
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
        if (constraints.maxWidth < 720) {
          return _buildVerticalLayout();
        }
        return _buildHorizontalLayout();
      },
    );
  }

  /// Layout vertical pour mobile (1 carte par ligne)
  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCard(tasks[0]),
          const SizedBox(height: 24),
          const Center(child: PriorityVsBadge()),
          const SizedBox(height: 24),
          _buildCard(tasks[1]),
        ],
      ),
    );
  }

  /// Layout horizontal pour desktop avec VS parfaitement centré
  Widget _buildHorizontalLayout() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildCard(tasks[0]),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: PriorityVsBadge(),
          ),
          Flexible(
            flex: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildCard(tasks[1]),
            ),
          ),
        ],
      ),
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
///
/// Responsive:
/// - Mobile (<720px): Vertical (1 carte/ligne)
/// - Tablette (720-1024px): Horizontal wrap (2 puis 1)
/// - Desktop (≥1024px): Horizontal (3 cartes)
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
        if (constraints.maxWidth < 720) {
          // Mobile: 1 carte/ligne
          return _buildVerticalLayout();
        } else if (constraints.maxWidth < 1024) {
          // Tablette: 2 cartes/ligne
          return _buildTabletLayout();
        } else {
          // Desktop: 3 cartes/ligne
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < tasks.length; i++) ...[
            _buildCard(tasks[i]),
            if (i < tasks.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: tasks.map(_buildCard).toList(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: tasks.map((task) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: _buildCard(task),
          );
        }).toList(),
      ),
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

/// Layout pour un duel à 4 cartes (grille responsive)
///
/// Responsive:
/// - Mobile (<720px): Vertical (1 carte/ligne)
/// - Tablette (720-1024px): Grille 2×2
/// - Desktop (≥1024px): Grille 2×2 avec max width
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
        if (constraints.maxWidth < 720) {
          // Mobile: 1 carte/ligne
          return _buildVerticalLayout();
        } else {
          // Tablette & Desktop: Grille 2×2
          return _buildGridLayout(constraints);
        }
      },
    );
  }

  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < tasks.length; i++) ...[
            _buildCard(tasks[i]),
            if (i < tasks.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildGridLayout(BoxConstraints constraints) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.85,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: tasks.map(_buildCard).toList(),
        ),
      ),
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
