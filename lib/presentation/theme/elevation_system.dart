import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Système d'élévation sophistiqué pour l'UI
class ElevationSystem {
  /// Niveaux d'élévation prédéfinis
  static const double level0 = 0.0;
  static const double level1 = 2.0;
  static const double level2 = 4.0;
  static const double level3 = 8.0;
  static const double level4 = 12.0;
  static const double level5 = 16.0;
  static const double level6 = 24.0;

  /// Ombres personnalisées pour chaque niveau
  static List<BoxShadow> getShadow(double elevation, {Color? color}) {
    final shadowColor = color ?? Colors.black;
    
    if (elevation <= 0) return [];
    
    // Ombre ambiante (douce et étendue)
    final ambientShadow = BoxShadow(
      color: shadowColor.withValues(alpha: 0.04 + (elevation * 0.002)),
      blurRadius: elevation * 2.5,
      offset: const Offset(0, 0),
      spreadRadius: elevation * 0.5,
    );
    
    // Ombre directionnelle (plus nette et décalée)
    final directionalShadow = BoxShadow(
      color: shadowColor.withValues(alpha: 0.08 + (elevation * 0.003)),
      blurRadius: elevation * 1.5,
      offset: Offset(0, elevation * 0.4),
      spreadRadius: -elevation * 0.1,
    );
    
    // Ombre de profondeur (très douce, pour la profondeur)
    final depthShadow = BoxShadow(
      color: shadowColor.withValues(alpha: 0.02 + (elevation * 0.001)),
      blurRadius: elevation * 4,
      offset: Offset(0, elevation * 0.8),
      spreadRadius: elevation * 0.2,
    );
    
    return [ambientShadow, directionalShadow, depthShadow];
  }

  /// Obtenir une décoration avec élévation sophistiquée (gradient-free professional design)
  static BoxDecoration getElevatedDecoration({
    required double elevation,
    Color? backgroundColor,
    Color? shadowColor,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: borderRadius ?? BorderRadiusTokens.radiusMd,
      border: border,
      boxShadow: getShadow(elevation, color: shadowColor),
    );
  }

  /// Widget pour appliquer une élévation animée
  static Widget animatedElevation({
    required Widget child,
    required double elevation,
    required double hoveredElevation,
    Duration duration = const Duration(milliseconds: 200),
    Color? backgroundColor,
    Color? shadowColor,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return _AnimatedElevationWidget(
      elevation: elevation,
      hoveredElevation: hoveredElevation,
      duration: duration,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }

  /// Élévation contextuelle basée sur l'état
  static double contextualElevation({
    required bool isSelected,
    required bool isHovered,
    required bool isPressed,
    double baseElevation = level1,
  }) {
    if (isPressed) return baseElevation * 0.5;
    if (isSelected) return baseElevation * 2.0;
    if (isHovered) return baseElevation * 1.5;
    return baseElevation;
  }
}

/// Widget interne pour l'élévation animée
class _AnimatedElevationWidget extends StatefulWidget {
  final Widget child;
  final double elevation;
  final double hoveredElevation;
  final Duration duration;
  final Color? backgroundColor;
  final Color? shadowColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const _AnimatedElevationWidget({
    required this.child,
    required this.elevation,
    required this.hoveredElevation,
    required this.duration,
    this.backgroundColor,
    this.shadowColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<_AnimatedElevationWidget> createState() => _AnimatedElevationWidgetState();
}

class _AnimatedElevationWidgetState extends State<_AnimatedElevationWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  double get _currentElevation {
    if (_isPressed) return widget.elevation * 0.5;
    if (_isHovered) return widget.hoveredElevation;
    return widget.elevation;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          decoration: ElevationSystem.getElevatedDecoration(
            elevation: _currentElevation,
            backgroundColor: widget.backgroundColor,
            shadowColor: widget.shadowColor,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}