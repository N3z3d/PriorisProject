import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_arena.dart';

export 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart' show DuelCardSize;

typedef _WinnerSelection = Future<void> Function(Task winner, List<Task> losers);

Widget _buildScrollableWinnerList({
  required List<Task> tasks,
  required double spacing,
  required Widget Function(Task task) buildCard,
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < tasks.length; i++) ...[
          Center(child: buildCard(tasks[i])),
          if (i < tasks.length - 1) SizedBox(height: spacing),
        ],
      ],
    ),
  );
}

Widget _buildSelectableDuelCard({
  required Task task,
  required List<Task> allTasks,
  required bool hideEloScores,
  required _WinnerSelection onSelectWinner,
  required DuelCardSize size,
}) {
  final losers = allTasks.where((candidate) => candidate.id != task.id).toList();
  return DuelTaskCard(
    key: ValueKey('duel-card-${task.id}'),
    task: task,
    hideElo: hideEloScores,
    onTap: () => onSelectWinner(task, losers),
    cardSize: size,
  );
}

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
    return _buildSelectableDuelCard(
      task: task,
      allTasks: tasks,
      hideEloScores: hideEloScores,
      onSelectWinner: onSelectWinner,
      size: DuelCardSize.standard,
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
    return _buildScrollableWinnerList(
      tasks: tasks,
      spacing: 20,
      buildCard: _buildCard,
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
    return _buildSelectableDuelCard(
      task: task,
      allTasks: tasks,
      hideEloScores: hideEloScores,
      onSelectWinner: onSelectWinner,
      size: DuelCardSize.compact3,
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
    return _buildScrollableWinnerList(
      tasks: tasks,
      spacing: 20,
      buildCard: _buildCard,
    );
  }

  Widget _buildGridLayout(BoxConstraints constraints) {
    final isUltraWide = constraints.maxWidth >= 1400;
    final crossAxisCount = isUltraWide ? 4 : 2;
    final maxWidth = isUltraWide ? 1400.0 : 960.0;
    final cardMaxWidth = isUltraWide ? 260.0 : 280.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            itemCount: tasks.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 220,
                    maxWidth: cardMaxWidth,
                  ),
                  child: _buildCard(task),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Task task) {
    return _buildSelectableDuelCard(
      task: task,
      allTasks: tasks,
      hideEloScores: hideEloScores,
      onSelectWinner: onSelectWinner,
      size: DuelCardSize.compact4,
    );
  }
}




