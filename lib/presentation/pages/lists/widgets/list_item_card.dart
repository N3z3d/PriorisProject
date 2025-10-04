import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/layouts/swipeable_card.dart';
import 'package:prioris/presentation/widgets/indicators/premium_status_indicator.dart';
import 'package:prioris/presentation/animations/premium_micro_interactions.dart';

/// Widget pour afficher une carte d'élément de liste
///
/// Affiche les informations d'un élément avec des actions de gestion
/// et un design moderne.
class ListItemCard extends StatefulWidget {
  const ListItemCard({
    super.key,
    required this.item,
    this.onToggleCompletion,
    this.onEdit,
    this.onDelete,
  });

  final ListItem item;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<ListItemCard> createState() => _ListItemCardState();
}

class _ListItemCardState extends State<ListItemCard>
    with SingleTickerProviderStateMixin {
  bool _showActions = false;
  late AnimationController _actionsAnimationController;
  late Animation<double> _actionsAnimation;

  @override
  void initState() {
    super.initState();
    _actionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _actionsAnimation = CurvedAnimation(
      parent: _actionsAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _actionsAnimationController.dispose();
    super.dispose();
  }

  void _toggleActions() {
    setState(() {
      _showActions = !_showActions;
    });
    
    if (_showActions) {
      _actionsAnimationController.forward();
      HapticFeedback.lightImpact();
    } else {
      _actionsAnimationController.reverse();
    }
  }

  void _hideActions() {
    if (_showActions) {
      setState(() {
        _showActions = false;
      });
      _actionsAnimationController.reverse();
    }
  }

  void _onSwipeAction() {
    HapticFeedback.mediumImpact();
    _hideActions();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeableCard(
      onSwipeLeft: _handleSwipeLeft,
      onSwipeRight: _handleSwipeRight,
      leftActionColor: AppTheme.errorColor,
      rightActionColor: widget.item.isCompleted ? AppTheme.warningColor : AppTheme.successColor,
      leftActionIcon: Icons.delete,
      rightActionIcon: widget.item.isCompleted ? Icons.undo : Icons.check,
      leftActionLabel: 'Supprimer',
      rightActionLabel: widget.item.isCompleted ? 'Rouvrir' : 'Compléter',
      onTap: _handleCardTap,
      child: _buildCardContent(),
    );
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

  Widget _buildCardContent() {
    return PremiumMicroInteractions.hoverable(
      enableScaleEffect: true,
      scaleFactorHover: 1.02,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: _buildCardDecoration(),
        child: _buildCardInterior(),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: widget.item.isCompleted
          ? AppTheme.successColor.withValues(alpha: 0.05)
          : AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppTheme.cardShadow,
      border: Border.all(
        color: widget.item.isCompleted
            ? AppTheme.successColor.withValues(alpha: 0.2)
            : AppTheme.grey200,
        width: 1.5,
      ),
    );
  }

  Widget _buildCardInterior() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _handleCardTap,
        onLongPress: _toggleActions,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _buildCardRow(),
        ),
      ),
    );
  }

  Widget _buildCardRow() {
    return Row(
      children: [
        PremiumMicroInteractions.pressable(
          onPressed: () => widget.onToggleCompletion?.call(),
          enableHaptics: true,
          enableScaleEffect: true,
          scaleFactor: 0.95,
          child: _buildCompletionButton(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.item.isCompleted
                      ? AppTheme.textTertiary
                      : AppTheme.textPrimary,
                  decoration: widget.item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              if (_buildSubtitle() != null) ...[
                const SizedBox(height: 4),
                _buildSubtitle()!,
              ],
            ],
          ),
        ),
        _buildTrailing(),
      ],
    );
  }

  /// Construit le bouton de complétion
  Widget _buildCompletionButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Fond uni professionnel pour les checkboxes
        color: widget.item.isCompleted
            ? AppTheme.successColor
            : Colors.transparent,
        border: Border.all(
          color: widget.item.isCompleted
              ? AppTheme.successColor
              : AppTheme.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.item.isCompleted ? AppTheme.successColor : AppTheme.primaryColor)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: widget.item.isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            )
          : null,
    );
  }

  /// Construit le sous-titre de l'élément
  /// 
  /// FIX OVERFLOW: Utilise un IntrinsicHeight pour éviter le débordement RenderFlex
  Widget? _buildSubtitle() {
    if (widget.item.description == null && widget.item.category == null) return null;

    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.item.description != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.item.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (widget.item.category != null) ...[
            const SizedBox(height: 8),
            _buildCategoryBadge(),
          ],
        ],
      ),
    );
  }

  /// Construit le badge de catégorie
  Widget _buildCategoryBadge() {
    final color = _getEloColor(widget.item.eloScore);
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.item.category!,
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

  /// Construit la partie droite de la carte avec actions contextuelles
  Widget _buildTrailing() {
    return SizedBox(
      width: 100, // Augmenté pour accommoder le status indicator
      height: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Status Indicator
          PremiumStatusIndicator(
            status: widget.item.isCompleted ? StatusType.completed : StatusType.inProgress,
            showLabel: false,
            size: 20,
            enableAnimation: true,
          ),
          const SizedBox(height: 4),
          _buildEloScore(),
          // Actions révélées uniquement contextuellement
          AnimatedBuilder(
            animation: _actionsAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _actionsAnimation,
                axisAlignment: 1.0,
                child: FadeTransition(
                  opacity: _actionsAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _buildActionButtons(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Construit l'affichage du score ELO
  Widget _buildEloScore() {
    final color = _getEloColor(widget.item.eloScore);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${widget.item.eloScore.round()}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Construit les boutons d'action avec feedback amélioré
  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onEdit != null) _buildEditButtonContainer(),
        if (widget.onEdit != null && widget.onDelete != null) const SizedBox(width: 8),
        if (widget.onDelete != null) _buildDeleteButtonContainer(),
      ],
    );
  }

  /// Build edit button with premium interactions
  Widget _buildEditButtonContainer() {
    return PremiumMicroInteractions.pressable(
      onPressed: () {
        _hideActions();
        widget.onEdit?.call();
      },
      enableHaptics: true,
      enableScaleEffect: true,
      scaleFactor: 0.9,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.edit,
          size: 16,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// Build delete button with premium interactions
  Widget _buildDeleteButtonContainer() {
    return PremiumMicroInteractions.pressable(
      onPressed: () {
        _hideActions();
        widget.onDelete?.call();
      },
      enableHaptics: true,
      enableScaleEffect: true,
      scaleFactor: 0.9,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.delete,
          size: 16,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }

  /// Obtient la couleur pour un score ELO
  Color _getEloColor(double elo) {
    if (elo >= 1400) {
      return AppTheme.successColor;
    } else if (elo >= 1200) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }
} 
