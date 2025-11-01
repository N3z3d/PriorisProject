import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_arena.dart';

export 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart' show DuelCardSize;

/// Layout pour un duel a 2 cartes avec badge VS strictement centre.
///
/// Responsive:
/// - Mobile (<720px): Vertical (1 carte par ligne), VS entre les cartes.
/// - Desktop (>=720px): Horizontal avec badge VS parfaitement centre.
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: _buildCard(tasks[0])),
          const SizedBox(height: 32),
          const Center(child: PriorityVsBadge()),
          const SizedBox(height: 32),
          Center(child: _buildCard(tasks[1])),
        ],
      ),
    );
  }

  /// Layout horizontal pour desktop avec badge VS parfaitement centre.
  Widget _buildHorizontalLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _buildCard(tasks[0]),
                ),
              ),
              const SizedBox(width: 40),
              const Center(child: PriorityVsBadge()),
              const SizedBox(width: 40),
              Flexible(
                flex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _buildCard(tasks[1]),
                ),
              ),
            ],
          ),
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
      cardSize: DuelCardSize.standard, // Standard size for 2-card duels
    );
  }
}

/// Layout pour un duel a 3 cartes (responsive).
///
/// Responsive:
/// - Mobile (<720px): Vertical (1 carte/ligne)
/// - Tablette (720-1024px): disposition horizontale wrap (2 puis 1).
/// - Desktop (>=1024px): disposition horizontale (3 cartes).
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < tasks.length; i++) ...[
            Center(child: _buildCard(tasks[i])),
            if (i < tasks.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: tasks.map((task) {
            return ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 280,
                minWidth: 240,
              ),
              child: _buildCard(task),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tasks.map((task) {
              return Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _buildCard(task),
                ),
              );
            }).toList(),
          ),
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
      cardSize: DuelCardSize.compact3,
    );
  }
}

/// Layout pour un duel a 4 cartes (grille responsive).
///
/// Responsive:
/// - Mobile (<720px): vertical (1 carte par ligne).
/// - Tablette (720-1024px): grille 2x2.
/// - Desktop (>=1024px): grille 2x2 avec largeur limitee.
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
          // Tablette & Desktop: Grille 2A-2
          return _buildGridLayout(constraints);
        }
      },
    );
  }

  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < tasks.length; i++) ...[
            Center(child: _buildCard(tasks[i])),
            if (i < tasks.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildGridLayout(BoxConstraints constraints) {
    final isWide = constraints.maxWidth >= 1024;
    final cardMaxWidth = isWide ? 280.0 : 260.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Wrap(
            spacing: 20,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: tasks
                .map(
                  (task) => ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 220,
                      maxWidth: cardMaxWidth,
                    ),
                    child: _buildCard(task),
                  ),
                )
                .toList(),
          ),
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
      cardSize: DuelCardSize.compact4,
    );
  }
}




