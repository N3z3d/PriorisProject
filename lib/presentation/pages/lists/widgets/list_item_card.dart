import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/animations/premium_micro_interactions.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/layouts/swipeable_card.dart';
import 'package:prioris/presentation/widgets/indicators/premium_status_indicator.dart';

part 'components/list_item_card_sections.dart';
part 'components/list_item_card_actions.dart';

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
