part of '../list_item_card.dart';

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({
    required this.item,
    required this.actionsAnimation,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
    required this.onMenuAction,
    required this.onHideActions,
  });

  final ListItem item;
  final Animation<double> actionsAnimation;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String action)? onMenuAction;
  final VoidCallback onHideActions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          _buildToggleButton(),
          const Spacer(),
          _buildAnimatedActions(),
        ],
      ),
    );
  }

  Widget _buildAnimatedActions() {
    return AnimatedBuilder(
      animation: actionsAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: actionsAnimation,
          axisAlignment: 1,
          child: FadeTransition(
            opacity: actionsAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _ActionButtons(
                onEdit: onEdit,
                onDelete: onDelete,
                onMenuAction: onMenuAction,
                onHideActions: onHideActions,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButton() {
    if (onToggleCompletion == null) {
      return const SizedBox.shrink();
    }

    final isCompleted = item.isCompleted;
    final color = isCompleted ? AppTheme.successColor : AppTheme.primaryColor;

    return PremiumMicroInteractions.pressable(
      onPressed: onToggleCompletion!,
      enableHaptics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(isCompleted ? Icons.undo : Icons.check, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              isCompleted ? 'Rouvrir' : 'Compléter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailingSection extends StatelessWidget {
  const _TrailingSection({
    required this.item,
    required this.isSyncing,
    required this.actionsAnimation,
    required this.onEdit,
    required this.onDelete,
    required this.onMenuAction,
    required this.onHideActions,
  });

  final ListItem item;
  final bool isSyncing;
  final Animation<double> actionsAnimation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String action)? onMenuAction;
  final VoidCallback onHideActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildStatusIndicator(),
        const SizedBox(height: 6),
        _EloBadge(score: item.eloScore),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: actionsAnimation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: actionsAnimation,
              axisAlignment: 1,
              child: FadeTransition(
                opacity: actionsAnimation,
                child: _ActionButtons(
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onMenuAction: onMenuAction,
                  onHideActions: onHideActions,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: isSyncing
          ? const _SyncIndicator()
          : PremiumStatusIndicator(
              key: ValueKey('status-${item.id}'),
              status:
                  item.isCompleted ? StatusType.completed : StatusType.pending,
              showLabel: false,
              size: 20,
              enableAnimation: false,
              enableHaptics: false,
            ),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 1.8,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.grey600),
      ),
    );
  }
}

class _EloBadge extends StatelessWidget {
  const _EloBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final color = _eloColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        score.round().toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onEdit,
    required this.onDelete,
    required this.onMenuAction,
    required this.onHideActions,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String action)? onMenuAction;
  final VoidCallback onHideActions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _buildButtons(),
    );
  }

  List<Widget> _buildButtons() {
    final widgets = <Widget>[];

    void addSpacing() {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(width: 8));
      }
    }

    if (onEdit != null) {
      widgets.add(
        _IconActionButton(
          icon: Icons.edit,
          color: AppTheme.primaryColor,
          background: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          onPressed: () {
            onHideActions();
            onEdit!.call();
          },
        ),
      );
    }

    if (onDelete != null) {
      addSpacing();
      widgets.add(
        _IconActionButton(
          icon: Icons.delete,
          color: AppTheme.errorColor,
          background: AppTheme.errorColor.withValues(alpha: 0.1),
          borderColor: AppTheme.errorColor.withValues(alpha: 0.3),
          onPressed: () {
            onHideActions();
            onDelete!.call();
          },
        ),
      );
    }

    if (onMenuAction != null) {
      addSpacing();
      widgets.add(
        PopupMenuButton<String>(
          onOpened: onHideActions,
          onSelected: onMenuAction!,
          tooltip: 'Autres actions',
          icon: const Icon(
            Icons.more_horiz,
            size: 20,
            color: AppTheme.textSecondary,
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'rename',
              child: Text('Renommer'),
            ),
            PopupMenuItem(
              value: 'move',
              child: Text('Déplacer...'),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Text('Dupliquer'),
            ),
          ],
        ),
      );
    }

    return widgets;
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.borderColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PremiumMicroInteractions.pressable(
      onPressed: onPressed,
      enableHaptics: true,
      enableScaleEffect: true,
      scaleFactor: 0.9,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

Color _eloColor(double elo) {
  if (elo >= 1400) {
    return AppTheme.successColor;
  }
  if (elo >= 1200) {
    return AppTheme.warningColor;
  }
  return AppTheme.errorColor;
}
