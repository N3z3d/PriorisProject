import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/animations/premium_micro_interactions.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/layouts/swipeable_card.dart';
import 'package:prioris/presentation/widgets/indicators/premium_status_indicator.dart';

class ListItemCard extends StatefulWidget {
  const ListItemCard({
    super.key,
    required this.item,
    this.onToggleCompletion,
    this.onEdit,
    this.onDelete,
    this.onMenuAction,
    this.isSyncing = false,
  });

  final ListItem item;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String action)? onMenuAction;
  final bool isSyncing;

  @override
  State<ListItemCard> createState() => _ListItemCardState();
}

class _ListItemCardState extends State<ListItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _actionsController;
  late final Animation<double> _actionsAnimation;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _actionsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _actionsAnimation = CurvedAnimation(
      parent: _actionsController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _actionsController.dispose();
    super.dispose();
  }

  void _toggleActions() {
    setState(() => _showActions = !_showActions);
    if (_showActions) {
      HapticFeedback.lightImpact();
      _actionsController.forward();
    } else {
      _actionsController.reverse();
    }
  }

  void _hideActions() {
    if (!_showActions) return;
    setState(() => _showActions = false);
    _actionsController.reverse();
  }

  void _onSwipeAction() {
    HapticFeedback.mediumImpact();
    _hideActions();
  }

  void _handleSwipeLeft() {
    _onSwipeAction();
    widget.onDelete?.call();
  }

  void _handleSwipeRight() {
    _onSwipeAction();
    widget.onToggleCompletion?.call();
  }

  void _handleCardTap() {
    _hideActions();
    widget.onEdit?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeableCard(
      onSwipeLeft: _handleSwipeLeft,
      onSwipeRight: _handleSwipeRight,
      leftActionColor: AppTheme.errorColor,
      rightActionColor: widget.item.isCompleted
          ? AppTheme.warningColor
          : AppTheme.successColor,
      leftActionIcon: Icons.delete,
      rightActionIcon: widget.item.isCompleted ? Icons.undo : Icons.check,
      leftActionLabel: 'Supprimer',
      rightActionLabel: widget.item.isCompleted ? 'Rouvrir' : 'Compléter',
      onTap: _handleCardTap,
      child: _ListItemCardView(
        item: widget.item,
        isSyncing: widget.isSyncing,
        actionsAnimation: _actionsAnimation,
        onToggleCompletion: widget.onToggleCompletion,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
        onMenuAction: widget.onMenuAction,
        onCardTap: _handleCardTap,
        onLongPress: _toggleActions,
        onHideActions: _hideActions,
      ),
    );
  }
}

class _ListItemCardView extends StatelessWidget {
  const _ListItemCardView({
    required this.item,
    required this.isSyncing,
    required this.actionsAnimation,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
    required this.onMenuAction,
    required this.onCardTap,
    required this.onLongPress,
    required this.onHideActions,
  });

  final ListItem item;
  final bool isSyncing;
  final Animation<double> actionsAnimation;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String action)? onMenuAction;
  final VoidCallback onCardTap;
  final VoidCallback onLongPress;
  final VoidCallback onHideActions;

  @override
  Widget build(BuildContext context) {
    return PremiumMicroInteractions.hoverable(
      enableScaleEffect: true,
      scaleFactorHover: 1.02,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: _buildDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onCardTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final background = item.isCompleted
        ? AppTheme.successColor.withValues(alpha: 0.05)
        : AppTheme.surfaceColor;
    final borderColor = item.isCompleted
        ? AppTheme.successColor.withValues(alpha: 0.2)
        : AppTheme.grey200;
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppTheme.cardShadow,
      border: Border.all(color: borderColor, width: 1.5),
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        PremiumMicroInteractions.pressable(
          onPressed: () => onToggleCompletion?.call(),
          enableHaptics: true,
          enableScaleEffect: true,
          scaleFactor: 0.95,
          child: _CompletionButton(isCompleted: item.isCompleted),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: item.isCompleted
                      ? AppTheme.textTertiary
                      : AppTheme.textPrimary,
                  decoration:
                      item.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              if (item.description != null || item.category != null) ...[
                const SizedBox(height: 4),
                _ItemSubtitle(
                  description: item.description,
                  category: item.category,
                  eloScore: item.eloScore,
                ),
              ],
            ],
          ),
        ),
        _TrailingSection(
          item: item,
          isSyncing: isSyncing,
          actionsAnimation: actionsAnimation,
          onEdit: onEdit,
          onDelete: onDelete,
          onMenuAction: onMenuAction,
          onHideActions: onHideActions,
        ),
      ],
    );
  }
}

class _CompletionButton extends StatelessWidget {
  const _CompletionButton({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isCompleted ? AppTheme.successColor : AppTheme.primaryColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? AppTheme.successColor : Colors.transparent,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }
}

class _ItemSubtitle extends StatelessWidget {
  const _ItemSubtitle({
    required this.description,
    required this.category,
    required this.eloScore,
  });

  final String? description;
  final String? category;
  final double eloScore;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null)
            Text(
              description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (category != null) ...[
            const SizedBox(height: 8),
            _CategoryBadge(category: category!, eloScore: eloScore),
          ],
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.category,
    required this.eloScore,
  });

  final String category;
  final double eloScore;

  @override
  Widget build(BuildContext context) {
    final color = _eloColor(eloScore);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
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
    return SizedBox(
      width: 100,
      height: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: isSyncing
                ? const _SyncIndicator()
                : PremiumStatusIndicator(
                    key: ValueKey('status-${item.id}'),
                    status: item.isCompleted
                        ? StatusType.completed
                        : StatusType.pending,
                    showLabel: false,
                    size: 20,
                    enableAnimation: false,
                    enableHaptics: false,
                  ),
          ),
          const SizedBox(height: 4),
          _EloBadge(score: item.eloScore),
          AnimatedBuilder(
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
          ),
        ],
      ),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('list-item-sync-spinner'),
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1.8,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.grey600),
        ),
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
      children: [
        if (onEdit != null)
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
        if (onEdit != null && onDelete != null) const SizedBox(width: 8),
        if (onDelete != null)
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
        if (onMenuAction != null) ...[
          const SizedBox(width: 8),
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
        ],
      ],
    );
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
