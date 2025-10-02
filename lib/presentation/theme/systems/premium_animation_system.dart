import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/systems/builders/export.dart';

/// Premium Animation System - Coordinates animation builders following SRP
/// Responsibility: Delegating animation creation to specialized builders
class PremiumAnimationSystem implements IPremiumAnimationSystem {
  bool _isInitialized = false;

  // Default animation constants
  static const Duration _defaultDuration = Duration(milliseconds: 300);
  static const double _defaultScale = 0.95;
  static const double _defaultElasticity = 0.8;
  static const double _defaultGravity = 1.0;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ PHYSICS ANIMATIONS ============

  @override
  Widget createSpringScale({
    required Widget child,
    VoidCallback? onTap,
    double scale = _defaultScale,
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();
    return PremiumPhysicsAnimations.springScale(
      child: child,
      onTap: onTap,
      scale: scale,
      duration: duration,
    );
  }

  @override
  Widget createElasticBounce({
    required Widget child,
    bool trigger = false,
    double elasticity = _defaultElasticity,
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();
    return PremiumPhysicsAnimations.elasticBounce(
      child: child,
      trigger: trigger,
      elasticity: elasticity,
      duration: duration,
    );
  }

  @override
  Widget createGravityBounce({
    required Widget child,
    bool trigger = false,
    double gravity = _defaultGravity,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _ensureInitialized();
    return PremiumPhysicsAnimations.gravityBounce(
      child: child,
      trigger: trigger,
      gravity: gravity,
      duration: duration,
    );
  }

  // ============ TRANSITION ANIMATIONS ============

  @override
  Widget createFadeTransition({
    required Widget child,
    bool trigger = true,
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();
    return PremiumTransitionAnimations.fade(
      child: child,
      trigger: trigger,
      duration: duration,
    );
  }

  @override
  Widget createSlideTransition({
    required Widget child,
    bool trigger = true,
    Offset offset = const Offset(0, 1),
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();
    return PremiumTransitionAnimations.slide(
      child: child,
      trigger: trigger,
      offset: offset,
      duration: duration,
    );
  }

  // ============ ADVANCED ANIMATIONS ============

  /// Creates a staggered animation for lists
  Widget createStaggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = _defaultDuration,
    Curve curve = Curves.easeOutBack,
  }) {
    _ensureInitialized();
    return PremiumAdvancedAnimations.staggeredList(
      children: children,
      staggerDelay: staggerDelay,
      itemDuration: itemDuration,
      curve: curve,
    );
  }

  /// Creates a pulse animation
  Widget createPulse({
    required Widget child,
    bool trigger = true,
    double minScale = 0.95,
    double maxScale = 1.05,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    _ensureInitialized();
    return PremiumAdvancedAnimations.pulse(
      child: child,
      trigger: trigger,
      minScale: minScale,
      maxScale: maxScale,
      duration: duration,
    );
  }

  /// Creates a shake animation
  Widget createShake({
    required Widget child,
    bool trigger = false,
    double offset = 10.0,
    int count = 3,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _ensureInitialized();
    return PremiumAdvancedAnimations.shake(
      child: child,
      trigger: trigger,
      offset: offset,
      count: count,
      duration: duration,
    );
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'PremiumAnimationSystem must be initialized before use.',
      );
    }
  }
}