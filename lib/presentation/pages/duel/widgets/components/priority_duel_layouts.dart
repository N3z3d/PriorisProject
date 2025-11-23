import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_arena.dart';

export 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart' show DuelCardSize;

// --- Définitions & Constantes ---

typedef WinnerSelectionCallback = Future<void> Function(Task winner, List<Task> losers);

const double _kMobileBreakpoint = 720.0;
const double _kSpacing = 20.0;

// --- Dispatcher Principal ---

/// Sélectionne automatiquement le layout en fonction du nombre de tâches.
class DuelLayoutDispatcher extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final WinnerSelectionCallback onSelectWinner;

  const DuelLayoutDispatcher({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectWinner,
  });

  @override
  Widget build(BuildContext context) {
    return switch (tasks.length) {
      2 => DuelTwoCardsLayout(tasks: tasks, hideEloScores: hideEloScores, onSelectWinner: onSelectWinner),
      3 => DuelThreeCardsLayout(tasks: tasks, hideEloScores: hideEloScores, onSelectWinner: onSelectWinner),
      4 => DuelFourCardsLayout(tasks: tasks, hideEloScores: hideEloScores, onSelectWinner: onSelectWinner),
      _ => Center(child: Text('Nombre de tâches non supporté : ${tasks.length}')),
    };
  }
}

// --- Composants Partagés ---

/// Wrapper qui gère la logique de sélection (clic) et les données du duel.
class _DuelCardWrapper extends StatelessWidget {
  final Task task;
  final List<Task> allTasks;
  final bool hideEloScores;
  final DuelCardSize size;
  final WinnerSelectionCallback onSelectWinner;

  const _DuelCardWrapper({
    required this.task,
    required this.allTasks,
    required this.hideEloScores,
    required this.size,
    required this.onSelectWinner,
  });

  @override
  Widget build(BuildContext context) {
    return DuelTaskCard(
      key: ValueKey('duel-card-${task.id}'),
      task: task,
      hideElo: hideEloScores,
      cardSize: size,
      onTap: () {
        final losers = allTasks.where((t) => t.id != task.id).toList();
        onSelectWinner(task, losers);
      },
    );
  }
}

/// Layout vertical standard pour mobile (liste déroulante).
class _VerticalDuelList extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final WinnerSelectionCallback onSelectWinner;
  final DuelCardSize cardSize;

  const _VerticalDuelList({
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectWinner,
    this.cardSize = DuelCardSize.standard,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400), // évite l'étirement sur tablette portrait
                child: _DuelCardWrapper(
                  task: tasks[i],
                  allTasks: tasks,
                  hideEloScores: hideEloScores,
                  size: cardSize,
                  onSelectWinner: onSelectWinner,
                ),
              ),
            ),
            if (i < tasks.length - 1) const SizedBox(height: _kSpacing),
          ],
        ],
      ),
    );
  }
}

// --- Implémentations des Layouts ---

class DuelTwoCardsLayout extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final WinnerSelectionCallback onSelectWinner;

  const DuelTwoCardsLayout({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectWinner,
  }) : assert(tasks.length == 2);

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    if (viewportWidth < _kMobileBreakpoint) {
      return _buildVerticalLayout();
    }
    return _buildHorizontalLayout();
  }

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

  Widget _buildHorizontalLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: _buildCard(tasks[0]),
              ),
            ),
            const SizedBox(width: 40),
            const PriorityVsBadge(),
            const SizedBox(width: 40),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: _buildCard(tasks[1]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Task task) => _DuelCardWrapper(
        task: task,
        allTasks: tasks,
        hideEloScores: hideEloScores,
        size: DuelCardSize.standard,
        onSelectWinner: onSelectWinner,
      );
}

class DuelThreeCardsLayout extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final WinnerSelectionCallback onSelectWinner;

  const DuelThreeCardsLayout({
    super.key,
    required this.tasks,
    required this.hideEloScores,
    required this.onSelectWinner,
  }) : assert(tasks.length == 3);

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    if (viewportWidth < _kMobileBreakpoint) {
      return _VerticalDuelList(
        tasks: tasks,
        hideEloScores: hideEloScores,
        onSelectWinner: onSelectWinner,
        cardSize: DuelCardSize.compact3,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: tasks.map((task) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300, minWidth: 240),
                child: _DuelCardWrapper(
                  task: task,
                  allTasks: tasks,
                  hideEloScores: hideEloScores,
                  size: DuelCardSize.compact3,
                  onSelectWinner: onSelectWinner,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class DuelFourCardsLayout extends StatelessWidget {
  final List<Task> tasks;
  final bool hideEloScores;
  final WinnerSelectionCallback onSelectWinner;

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
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        if (viewportWidth < _kMobileBreakpoint) {
          return _VerticalDuelList(
            tasks: tasks,
            hideEloScores: hideEloScores,
            onSelectWinner: onSelectWinner,
            cardSize: DuelCardSize.compact4,
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: _buildGrid(),
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
      itemCount: tasks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: _kSpacing,
        crossAxisSpacing: _kSpacing,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _DuelCardWrapper(
          task: task,
          allTasks: tasks,
          hideEloScores: hideEloScores,
          size: DuelCardSize.compact4,
          onSelectWinner: onSelectWinner,
        );
      },
    );
  }
}
