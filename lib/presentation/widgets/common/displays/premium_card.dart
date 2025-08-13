import 'package:flutter/material.dart';
import 'package:prioris/presentation/mixins/animation_lifecycle_mixin.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget de carte premium avec effets glassmorphism et animations
/// 
/// Offre une expérience visuelle moderne avec :
/// - Effet glassmorphism subtil
/// - Animations fluides au hover
/// - Ombres premium
/// - Bordures raffinées
class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final bool? isGlassmorphism;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool? isHoverable;
  final Duration? animationDuration;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.isGlassmorphism = false,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.isHoverable = true,
    this.animationDuration,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin, AnimationLifecycleMixin<PremiumCard> {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Enregistrer le controller pour la gestion du cycle de vie
    registerAnimationController(_animationController);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    // Le mixin gère la disposition des controllers
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.isHoverable!) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityAwareAnimationWidget(
      onVisibilityChanged: (visible) {
        onVisibilityChanged(visible);
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
          margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius ?? BorderRadiusTokens.cardPremium,
                    color: widget.isGlassmorphism!
                        ? AppTheme.professionalGlassBackground
                        : widget.backgroundColor ?? AppTheme.cardColor,
                    border: Border.all(
                      color: _isHovered 
                          ? AppTheme.primaryColor.withValues(alpha: 0.3)
                          : AppTheme.grey200,
                      width: 1,
                    ),
                    boxShadow: widget.isGlassmorphism!
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05 + _elevationAnimation.value * 0.02),
                              blurRadius: 10 + _elevationAnimation.value * 2,
                              offset: Offset(0, 2 + _elevationAnimation.value),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08 + _elevationAnimation.value * 0.02),
                              blurRadius: 5 + _elevationAnimation.value,
                              offset: Offset(0, 1 + _elevationAnimation.value * 0.5),
                              spreadRadius: -1,
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: widget.borderRadius ?? BorderRadiusTokens.cardPremium,
                    child: Container(
                      padding: widget.padding ?? const EdgeInsets.all(20),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}

/// Widget bouton premium avec couleurs professionnelles et animations
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool? isSecondary;
  final bool? isOutlined;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool? isLoading;
  final Size? minimumSize;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isOutlined = false,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.minimumSize,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePress(bool isPressed) {
    setState(() {
      // _isPressed = isPressed; // This line is removed
    });

    if (isPressed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _handlePress(true),
            onTapUp: (_) => _handlePress(false),
            onTapCancel: () => _handlePress(false),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isOutlined!
                    ? null
                    : widget.isSecondary!
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? BorderRadiusTokens.lg),
                border: widget.isOutlined!
                    ? Border.all(
                        color: widget.isSecondary!
                            ? AppTheme.secondaryColor
                            : AppTheme.primaryColor,
                        width: 1.5,
                      )
                    : null,
                boxShadow: widget.isOutlined!
                    ? []
                    : [
                        BoxShadow(
                          color: (widget.isSecondary!
                                  ? AppTheme.secondaryColor
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: -2,
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading! ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? BorderRadiusTokens.lg),
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    constraints: BoxConstraints(
                      minWidth: widget.minimumSize?.width ?? 0,
                      minHeight: widget.minimumSize?.height ?? 48,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading!)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isOutlined!
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                              ),
                            ),
                          )
                        else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            color: widget.isOutlined!
                                ? (widget.isSecondary!
                                    ? AppTheme.secondaryColor
                                    : AppTheme.primaryColor)
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (!widget.isLoading!)
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.isOutlined!
                                  ? (widget.isSecondary!
                                      ? AppTheme.secondaryColor
                                      : AppTheme.primaryColor)
                                  : Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 
