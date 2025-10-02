import 'package:flutter/material.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';

/// Premium Physics Animation Builder - Handles physics-based animations
/// Responsibility: Spring, elastic, and gravity animation builders
class PremiumPhysicsAnimations {
  // Animation configuration constants
  static const double defaultScale = 0.95;
  static const double defaultElasticity = 0.8;
  static const double defaultGravity = 1.0;

  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);

  /// Creates a spring scale animation wrapper
  static Widget springScale({
    required Widget child,
    VoidCallback? onTap,
    double scale = defaultScale,
    Duration duration = defaultDuration,
  }) {
    if (onTap == null) {
      return child; // Return plain child if no tap callback
    }

    return PhysicsAnimations.springScale(
      onTap: onTap,
      child: child,
    );
  }

  /// Creates an elastic bounce animation wrapper
  static Widget elasticBounce({
    required Widget child,
    bool trigger = false,
    double elasticity = defaultElasticity,
    Duration duration = defaultDuration,
  }) {
    return PhysicsAnimations.elasticBounce(
      trigger: trigger,
      child: child,
    );
  }

  /// Creates a gravity bounce animation wrapper
  static Widget gravityBounce({
    required Widget child,
    bool trigger = false,
    double gravity = defaultGravity,
    Duration duration = slowDuration,
  }) {
    return PhysicsAnimations.gravityBounce(
      trigger: trigger,
      child: child,
    );
  }
}
