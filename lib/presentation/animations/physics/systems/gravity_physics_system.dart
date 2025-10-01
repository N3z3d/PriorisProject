import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../interfaces/physics_system_interface.dart';
import '../configs/physics_configs.dart';

/// Gravity Physics System implementing realistic gravitational dynamics
///
/// This system focuses on gravity-based animations including:
/// - Free fall motion under gravity
/// - Realistic bouncing with energy loss
/// - Coefficient of restitution calculations
/// - Multiple bounce sequences with damping
///
/// Physics equations used:
/// - Kinematic equations: s = ut + ½gt²
/// - Velocity after time: v = u + gt
/// - Energy conservation: KE = ½mv²
/// - Coefficient of restitution: e = √(h₂/h₁)
class GravityPhysicsSystem
    implements IAnimatedPhysicsSystem, ICalculatablePhysicsSystem, ITriggerablePhysicsSystem {

  static const String _systemId = 'gravity_physics';
  static const String _systemName = 'Gravity Physics System';

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
        'Failed to initialize gravity physics system: $e',
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
        'Gravity system not initialized',
        _systemId,
      );
    }

    if (config is! GravityPhysicsConfig) {
      throw PhysicsSystemException(
        'Invalid config type for gravity system. Expected GravityPhysicsConfig.',
        _systemId,
      );
    }

    return _GravityAnimationWidget(
      config: config,
      system: this,
      child: child,
    );
  }

  @override
  PhysicsState calculateState({
    required double time,
    required PhysicsParameters parameters,
  }) {
    if (parameters is! GravityPhysicsParameters) {
      throw PhysicsSystemException(
        'Invalid parameters type for gravity system',
        _systemId,
      );
    }

    return _calculateGravityState(time, parameters);
  }

  @override
  void updateParameters(PhysicsParameters parameters) {
    if (parameters is! GravityPhysicsParameters) {
      throw PhysicsSystemException(
        'Invalid parameters type for gravity system',
        _systemId,
      );
    }

    _validateGravityParameters(parameters);
  }

  @override
  Future<void> trigger({
    required PhysicsAnimationConfig config,
    VoidCallback? onComplete,
  }) async {
    if (config is! GravityPhysicsConfig) {
      throw PhysicsSystemException(
        'Invalid config type for gravity system',
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

  /// Calculate gravity physics state including bounces
  PhysicsState _calculateGravityState(double time, GravityPhysicsParameters params) {
    final gravity = params.gravity;
    final restitution = params.restitution;
    final mass = params.mass;

    assert(gravity > 0, 'Gravity must be positive');
    assert(restitution >= 0 && restitution <= 1, 'Restitution must be between 0 and 1');
    assert(mass > 0, 'Mass must be positive');

    // Calculate time for each bounce phase
    double position = 0;
    double velocity = 0;
    double currentTime = time;

    // Initial fall
    final fallTime = sqrt(2 * 100 / gravity); // Assume 100px initial height

    if (currentTime <= fallTime) {
      // Free fall phase: s = ½gt²
      position = 0.5 * gravity * currentTime * currentTime;
      velocity = gravity * currentTime;
    } else {
      // Handle bounces
      position = 100; // Ground level
      currentTime -= fallTime;

      double bounceVelocity = sqrt(2 * gravity * 100); // Impact velocity
      int bounceCount = 0;

      while (currentTime > 0 && bounceCount < 10) { // Max 10 bounces
        bounceVelocity *= restitution; // Energy loss
        if (bounceVelocity < 0.1) break; // Stop if velocity too small

        final bounceHeight = (bounceVelocity * bounceVelocity) / (2 * gravity);
        final bounceUpTime = bounceVelocity / gravity;
        final bounceDownTime = bounceUpTime;
        final totalBounceTime = bounceUpTime + bounceDownTime;

        if (currentTime <= bounceUpTime) {
          // Rising phase
          position = 100 - (bounceVelocity * currentTime - 0.5 * gravity * currentTime * currentTime);
          velocity = -(bounceVelocity - gravity * currentTime);
        } else if (currentTime <= totalBounceTime) {
          // Falling phase
          final fallTime = currentTime - bounceUpTime;
          position = 100 - (bounceHeight - 0.5 * gravity * fallTime * fallTime);
          velocity = gravity * fallTime;
        } else {
          currentTime -= totalBounceTime;
          bounceCount++;
          continue;
        }
        break;
      }
    }

    final acceleration = gravity;

    return PhysicsState(
      position: Offset(0, position),
      velocity: Offset(0, velocity),
      acceleration: Offset(0, acceleration),
      rotation: 0,
      scale: 1.0,
      time: time,
    );
  }

  void _validateGravityParameters(GravityPhysicsParameters params) {
    if (params.gravity <= 0) {
      throw PhysicsSystemException('Gravity must be positive', _systemId);
    }
    if (params.restitution < 0 || params.restitution > 1) {
      throw PhysicsSystemException('Restitution must be between 0 and 1', _systemId);
    }
    if (params.mass <= 0) {
      throw PhysicsSystemException('Mass must be positive', _systemId);
    }
  }
}

/// Widget implementing gravity animation with realistic bouncing
class _GravityAnimationWidget extends StatefulWidget {
  final GravityPhysicsConfig config;
  final GravityPhysicsSystem system;
  final Widget child;

  const _GravityAnimationWidget({
    required this.config,
    required this.system,
    required this.child,
  });

  @override
  State<_GravityAnimationWidget> createState() => _GravityAnimationWidgetState();
}

class _GravityAnimationWidgetState extends State<_GravityAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _bounceAnimation = _createBounceSequence();

    if (widget.config.trigger) {
      _startAnimation();
    }
  }

  /// Create bounce sequence based on physics
  Animation<double> _createBounceSequence() {
    final List<TweenSequenceItem<double>> items = [];

    // Initial fall
    items.add(TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: widget.config.height,
      ).chain(CurveTween(curve: _GravityFallCurve())),
      weight: 2.0,
    ));

    // Calculate bounces with realistic physics
    double currentHeight = widget.config.height;
    for (int i = 0; i < widget.config.bounceCount; i++) {
      final nextHeight = currentHeight * widget.config.restitution;

      if (nextHeight < 0.1) break; // Stop if bounce is too small

      // Rise
      items.add(TweenSequenceItem(
        tween: Tween<double>(
          begin: currentHeight,
          end: currentHeight - nextHeight,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1.0,
      ));

      // Fall
      items.add(TweenSequenceItem(
        tween: Tween<double>(
          begin: currentHeight - nextHeight,
          end: currentHeight,
        ).chain(CurveTween(curve: _GravityFallCurve())),
        weight: 1.0,
      ));

      currentHeight = currentHeight - nextHeight * (1 - widget.config.bounceDamping);
    }

    return TweenSequence<double>(items).animate(_controller);
  }

  @override
  void didUpdateWidget(_GravityAnimationWidget oldWidget) {
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
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: widget.child,
        );
      },
    );
  }
}

/// Custom curve that simulates realistic gravity acceleration
class _GravityFallCurve extends Curve {
  const _GravityFallCurve();

  @override
  double transformInternal(double t) {
    // Quadratic curve representing s = ½gt²
    return t * t;
  }

  @override
  String toString() => '_GravityFallCurve()';
}