import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_layouts.dart';
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
    return _buildLayoutForCardCount();
  }

  Widget _buildLayoutForCardCount() {
    // Adapter pour la nouvelle signature (winner + losers)
    Future<void> handleWinnerSelection(Task winner, List<Task> losers) async {
      // Pour compatibilite: on utilise le premier perdant
      // Le controller gerera les comparaisons multiples si necessaire
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
        // Fallback: utilise layout 3 cartes avec les premieres taches
        return DuelThreeCardsLayout(
          tasks: tasks.take(3).toList(),
          hideEloScores: hideEloScores,
          onSelectWinner: handleWinnerSelection,
        );
    }
  }
}

/// Premium ranking arena with enhanced visual styling and animations
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
      proxyDecorator: _proxyDecorator,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _RankingItem(
          key: ValueKey('ranking-item-${task.id}'),
          task: task,
          index: index,
          hideEloScores: hideEloScores,
        );
      },
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.05,
          child: Transform.rotate(
            angle: 0.01,
            child: Opacity(
              opacity: 0.9,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _RankingItem extends StatefulWidget {
  final Task task;
  final int index;
  final bool hideEloScores;

  const _RankingItem({
    super.key,
    required this.task,
    required this.index,
    required this.hideEloScores,
  });

  @override
  State<_RankingItem> createState() => _RankingItemState();
}

class _RankingItemState extends State<_RankingItem> {
  bool _isHovered = false;

  Color _getRankColor(int rank) {
    if (rank == 0) return const Color(0xFFD97706); // Gold
    if (rank == 1) return const Color(0xFF9CA3AF); // Silver
    if (rank == 2) return const Color(0xFFCD7F32); // Bronze
    return AppTheme.primaryColor;
  }

  IconData _getRankIcon(int rank) {
    if (rank < 3) return Icons.workspace_premium_rounded;
    return Icons.drag_indicator_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(widget.index);
    return MouseRegion(
      onEnter: (_) => _toggleHover(true),
      onExit: (_) => _toggleHover(false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: _containerDecoration(rankColor),
          child: _buildTile(context, rankColor),
        ),
      ),
    );
  }

  void _toggleHover(bool value) {
    if (_isHovered != value) {
      setState(() => _isHovered = value);
    }
  }

  BoxDecoration _containerDecoration(Color rankColor) {
    return BoxDecoration(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: _isHovered
            ? rankColor.withValues(alpha: 0.3)
            : AppTheme.dividerColor.withValues(alpha: 0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: _isHovered
              ? rankColor.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: _isHovered ? 16 : 8,
          offset: Offset(0, _isHovered ? 6 : 3),
        ),
      ],
    );
  }

  ListTile _buildTile(BuildContext context, Color rankColor) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      leading: _buildLeadingBadge(textTheme, rankColor),
      title: Text(
        widget.task.title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontSize: 15,
        ),
      ),
      subtitle: widget.hideEloScores ? null : _buildEloSubtitle(textTheme),
      trailing: _buildDragHandle(),
    );
  }

  Widget _buildLeadingBadge(TextTheme textTheme, Color rankColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            rankColor.withValues(alpha: 0.15),
            rankColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rankColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getRankIcon(widget.index),
            size: 16,
            color: rankColor,
          ),
          const SizedBox(height: 2),
          Text(
            '${widget.index + 1}',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: rankColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEloSubtitle(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        'ELO ${widget.task.eloScore.toStringAsFixed(0)}',
        style: textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return ReorderableDragStartListener(
      index: widget.index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.surfaceColor : AppTheme.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? AppTheme.dividerColor.withValues(alpha: 0.6)
                : AppTheme.dividerColor.withValues(alpha: 0.3),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (barIndex) {
            return Padding(
              padding: EdgeInsets.only(bottom: barIndex == 2 ? 0 : 3),
              child: Container(
                width: 12,
                height: 2,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(
                    alpha: _isHovered ? 0.9 : 0.6,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Premium VS badge with gradient, animated pulse, and sophisticated styling
class PriorityVsBadge extends StatefulWidget {
  const PriorityVsBadge({super.key});

  @override
  State<PriorityVsBadge> createState() => _PriorityVsBadgeState();
}

class _PriorityVsBadgeState extends State<PriorityVsBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.25).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildDividerLines(),
          _buildAnimatedBadge(context),
        ],
      ),
    );
  }

  Widget _buildDividerLines() {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(child: _dividerGradient(AppTheme.primaryColor.withValues(alpha: 0.0), AppTheme.primaryColor.withValues(alpha: 0.3))),
          const SizedBox(width: 60),
          Expanded(child: _dividerGradient(AppTheme.primaryColor.withValues(alpha: 0.3), AppTheme.primaryColor.withValues(alpha: 0.0))),
        ],
      ),
    );
  }

  Widget _dividerGradient(Color start, Color end) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
        ),
      ),
    );
  }

  Widget _buildAnimatedBadge(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildBadgeShell(context),
        );
      },
    );
  }

  Widget _buildBadgeShell(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.accentColor.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 2,
          color: AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: _glowAnimation.value),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor,
          ],
        ).createShader(bounds),
        child: Text(
          'VS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
