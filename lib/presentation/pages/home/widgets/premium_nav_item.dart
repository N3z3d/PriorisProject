import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';
import 'package:prioris/presentation/pages/home/models/navigation_item.dart';

/// Widget de navigation premium avec animations et accessibilité
class PremiumNavItem extends StatefulWidget {
  final NavigationItem item;
  final bool isActive;
  final VoidCallback onTap;

  const PremiumNavItem({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<PremiumNavItem> createState() => _PremiumNavItemState();
}

class _PremiumNavItemState extends State<PremiumNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _syncAnimationWithState();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _syncAnimationWithState() {
    if (widget.isActive) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(PremiumNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _handleActiveStateChange();
    }
  }

  void _handleActiveStateChange() {
    if (widget.isActive) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAccessibleContainer(
      child: _buildFocusableActionDetector(
        child: _buildInkWellButton(
          child: _buildAnimatedContent(),
        ),
      ),
    );
  }

  Widget _buildAccessibleContainer({required Widget child}) {
    return Semantics(
      button: true,
      label: widget.item.label,
      selected: widget.isActive,
      hint: widget.isActive
          ? 'Section actuelle'
          : 'Appuyez pour naviguer vers ${widget.item.label}',
      child: Container(
        constraints: BoxConstraints(
          minWidth: AccessibilityService.minTouchTargetSize,
          minHeight: AccessibilityService.minTouchTargetSize,
        ),
        child: child,
      ),
    );
  }

  Widget _buildFocusableActionDetector({required Widget child}) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: child,
    );
  }

  Widget _buildInkWellButton({required Widget child}) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadiusTokens.radiusMd,
      focusColor: widget.item.color.withValues(alpha: 0.2),
      hoverColor: widget.item.color.withValues(alpha: 0.1),
      splashColor: widget.item.color.withValues(alpha: 0.3),
      child: child,
    );
  }

  Widget _buildAnimatedContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconSection(),
              const SizedBox(height: 4),
              _buildLabelSection(),
              _buildActiveIndicator(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildIconBackground(),
        _buildAnimatedIcon(),
      ],
    );
  }

  Widget _buildIconBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: widget.isActive
            ? widget.item.color.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadiusTokens.radiusLg,
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Icon(
        widget.isActive ? widget.item.activeIcon : widget.item.icon,
        size: 24,
        color: widget.isActive
            ? widget.item.color
            : AppTheme.textTertiary,
      ),
    );
  }

  Widget _buildLabelSection() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 12,
        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
        color: widget.isActive
            ? widget.item.color
            : AppTheme.textTertiary,
      ),
      child: Text(widget.item.label),
    );
  }

  Widget _buildActiveIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isActive ? 24 : 0,
      height: 2,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: widget.item.color,
        borderRadius: BorderRadiusTokens.radiusNone,
      ),
    );
  }
}
