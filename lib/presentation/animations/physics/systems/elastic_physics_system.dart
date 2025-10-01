import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../interfaces/physics_system_interface.dart';
import '../configs/physics_configs.dart';

/// Elastic Physics System implementing realistic elastic deformation
///
/// This system focuses on elastic behavior including:
/// - Elastic deformation and recovery
/// - Material stress-strain relationships
/// - Progressive damping through multiple bounces
/// - Tension-based elastic restoration
///
/// Physics principles used:
/// - Hooke's Law: F = -kx (elastic force)
/// - Elastic potential energy: U = ½kx²
/// - Damped oscillations with material properties
/// - Young's modulus approximation for material behavior
class ElasticPhysicsSystem
    implements IAnimatedPhysicsSystem, ITriggerablePhysicsSystem {

  static const String _systemId = 'elastic_physics';
  static const String _systemName = 'Elastic Physics System';

  bool _isActive = false;
  bool _isAnimating = false;

  @override
  String get systemId => _systemId;

  @override
  String get systemName => _systemName;

  @override
  bool get isActive => _isActive;

  @override
  bool get isAnimating => _isAnimating;

  @override
  Future<void> initialize() async {
    if (_isActive) return;

    try {
      _isActive = true;
    } catch (e) {
      throw PhysicsSystemException(
        'Failed to initialize elastic physics system: $e',
        _systemId,
        e,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _isActive = false;
    _isAnimating = false;
  }

  @override
  Widget createAnimation({
    required Widget child,
    required PhysicsAnimationConfig config,
  }) {
    if (!_isActive) {
      throw PhysicsSystemException(
        'Elastic system not initialized',
        _systemId,
      );
    }

    if (config is! ElasticPhysicsConfig) {
      throw PhysicsSystemException(
        'Invalid config type for elastic system. Expected ElasticPhysicsConfig.',
        _systemId,
      );
    }

    return _ElasticAnimationWidget(
      config: config,
      system: this,
      child: child,
    );
  }

  @override
  Future<void> trigger({
    required PhysicsAnimationConfig config,
    VoidCallback? onComplete,
  }) async {
    if (config is! ElasticPhysicsConfig) {
      throw PhysicsSystemException(
        'Invalid config type for elastic system',
        _systemId,
      );
    }

    _isAnimating = true;

    try {
      HapticFeedback.heavyImpact();
      await Future.delayed(config.duration);
      onComplete?.call();
    } finally {
      _isAnimating = false;
    }
  }

  @override
  void stop() {
    _isAnimating = false;
  }

  /// Calculate elastic deformation based on material properties
  double calculateElasticDeformation({
    required double force,
    required double tension,
    required double elasticity,
  }) {
    // Elastic deformation: δ = F/k where k is related to tension
    final stiffness = tension * elasticity;
    return force / (stiffness + 1); // +1 to prevent division by zero
  }

  /// Calculate energy loss through elastic hysteresis
  double calculateEnergyLoss({
    required double initialEnergy,
    required double elasticity,
    required int cycleCount,
  }) {
    // Energy loss per cycle due to material hysteresis
    final lossPerCycle = 1 - elasticity;
    return initialEnergy * pow(elasticity, cycleCount);
  }
}

/// Widget implementing elastic bounce animation with material physics
class _ElasticAnimationWidget extends StatefulWidget {
  final ElasticPhysicsConfig config;
  final ElasticPhysicsSystem system;
  final Widget child;

  const _ElasticAnimationWidget({
    required this.config,
    required this.system,
    required this.child,
  });

  @override
  State<_ElasticAnimationWidget> createState() => _ElasticAnimationWidgetState();
}

class _ElasticAnimationWidgetState extends State<_ElasticAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elasticAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _elasticAnimation = _createElasticBounceSequence();

    if (widget.config.trigger) {
      _startAnimation();
    }
  }

  /// Create elastic bounce sequence with realistic material behavior
  Animation<double> _createElasticBounceSequence() {
    final List<TweenSequenceItem<double>> items = [];

    double currentHeight = widget.config.bounceHeight;
    final elasticity = widget.config.elasticity;
    final tension = widget.config.tension;

    for (int i = 0; i < widget.config.bounceCount; i++) {
      // Calculate energy loss for this bounce
      final energyLoss = widget.system.calculateEnergyLoss(
        initialEnergy: currentHeight,
        elasticity: elasticity,
        cycleCount: i,
      );

      final targetHeight = currentHeight * energyLoss;

      // Stretch (loading) phase - elastic deformation
      items.add(TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: targetHeight,
        ).chain(CurveTween(curve: _ElasticLoadingCurve(tension))),
        weight: 1.0,
      ));

      // Recovery (unloading) phase - elastic restoration
      items.add(TweenSequenceItem(
        tween: Tween<double>(
          begin: targetHeight,
          end: 1.0,
        ).chain(CurveTween(curve: _ElasticUnloadingCurve(tension, elasticity))),
        weight: 1.0,
      ));

      currentHeight = targetHeight;

      // Stop if deformation is too small (material yield point)
      if (currentHeight < 1.01) break;
    }

    return TweenSequence<double>(items).animate(_controller);
  }

  @override
  void didUpdateWidget(_ElasticAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.config.trigger && !oldWidget.config.trigger) {
      _startAnimation();
    }
  }

  Future<void> _startAnimation() async {
    widget.system._isAnimating = true;

    try {
      HapticFeedback.heavyImpact();
      await _controller.forward(from: 0);
      widget.config.onComplete?.call();
    } finally {
      widget.system._isAnimating = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elasticAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _elasticAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Custom curve simulating elastic material loading (stress-strain curve)
class _ElasticLoadingCurve extends Curve {
  final double tension;

  const _ElasticLoadingCurve(this.tension);

  @override
  double transformInternal(double t) {
    // Elastic loading follows a power law based on material tension
    final exponent = 1.0 + (tension / 100.0); // Normalize tension
    return pow(t, exponent).toDouble();
  }

  @override
  String toString() => '_ElasticLoadingCurve(tension: $tension)';
}

/// Custom curve simulating elastic material unloading with hysteresis
class _ElasticUnloadingCurve extends Curve {
  final double tension;
  final double elasticity;

  const _ElasticUnloadingCurve(this.tension, this.elasticity);

  @override
  double transformInternal(double t) {
    // Elastic unloading with hysteresis loop
    final hysteresis = 1.0 - elasticity;
    final unloadingRate = 1.0 / (1.0 + tension / 200.0);

    // Create non-linear unloading with energy loss
    final baseUnloading = pow(t, unloadingRate).toDouble();
    final hysteresisEffect = hysteresis * sin(pi * t) * (1 - t);

    return baseUnloading + hysteresisEffect;
  }

  @override
  String toString() => '_ElasticUnloadingCurve(tension: $tension, elasticity: $elasticity)';
}