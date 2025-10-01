import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Interface pour les composants avec effet de verre - ISP Compliance
abstract class IGlassComponents {
  Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color color,
    double blur,
    double opacity,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  });

  Widget glassFAB({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
    double elevation,
    String? heroTag,
  });
}

/// Composants interactifs avec effet de glassmorphisme - SRP: Responsable uniquement des composants UI interactifs
/// OCP: Extensible via l'interface IGlassComponents
/// LSP: Peut être substitué par toute implémentation de IGlassComponents
class GlassComponents implements IGlassComponents {

  /// Bouton avec effet de verre
  @override
  Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color color = Colors.white,
    double blur = 10.0,
    double opacity = 0.2,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return GlassButton(
      onPressed: onPressed,
      color: color,
      blur: blur,
      opacity: opacity,
      padding: padding,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Crée un FloatingActionButton avec effet de verre
  @override
  Widget glassFAB({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
    double elevation = 6.0,
    String? heroTag,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      elevation: elevation,
      backgroundColor: backgroundColor?.withValues(alpha: 0.1) ??
                      Colors.white.withValues(alpha: 0.1),
      foregroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Widget de bouton avec effet de verre - SRP: Responsable uniquement du comportement d'un bouton avec animations
/// OCP: Fermé à la modification, ouvert à l'extension via composition
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.color,
    required this.blur,
    required this.opacity,
    this.padding,
    this.borderRadius,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

/// État du bouton avec gestion des animations - SRP: Responsable uniquement de l'état et des animations du bouton
/// DIP: Dépend des abstractions Flutter (AnimationController, Animation)
class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initialise les animations du bouton - SRP: Responsable uniquement de l'initialisation des animations
  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity * 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gère l'appui sur le bouton - SRP: Responsable uniquement de la réaction au tap down
  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  /// Gère le relâchement du bouton - SRP: Responsable uniquement de la réaction au tap up
  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  /// Gère l'annulation du tap - SRP: Responsable uniquement de la réaction au tap cancel
  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadiusTokens.radiusMd,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: _opacityAnimation.value),
                    borderRadius: widget.borderRadius ?? BorderRadiusTokens.radiusMd,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}