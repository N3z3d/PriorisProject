import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../interfaces/physics_system_interface.dart';
import '../configs/physics_configs.dart';

/// Spring Physics System implementing realistic spring dynamics
///
/// This system follows Single Responsibility Principle by focusing solely on
/// spring-based animations and physics calculations.
///
/// Physics equations used:
/// - Hooke's Law: F = -kx (spring force)
/// - Damped harmonic oscillator: m*a + c*v + k*x = 0
/// - Natural frequency: ω₀ = √(k/m)
/// - Damping ratio: ζ = c/(2*√(km))
class SpringPhysicsSystem
    implements IAnimatedPhysicsSystem, ICalculatablePhysicsSystem, ITriggerablePhysicsSystem {

  static const String _systemId = 'spring_physics';
  static const String _systemName = 'Spring Physics System';

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
      // Initialize spring physics constants and validation
      _isActive = true;
    } catch (e) {
      throw PhysicsSystemException(
        'Failed to initialize spring physics system: $e',
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
        'Spring system not initialized',
        _systemId,
      );
    }

    if (config is! SpringPhysicsConfig) {
      throw PhysicsSystemException(
        'Invalid config type for spring system. Expected SpringPhysicsConfig.',
        _systemId,
      );
    }

    return _SpringAnimationWidget(
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
    if (parameters is! SpringPhysicsParameters) {
      throw PhysicsSystemException(
        'Invalid parameters type for spring system',
        _systemId,
      );
    }

    return _calculateSpringState(time, parameters);
  }

  @override
  void updateParameters(PhysicsParameters parameters) {
    // Implementation for real-time parameter updates
    if (parameters is! SpringPhysicsParameters) {
      throw PhysicsSystemException(
        'Invalid parameters type for spring system',
        _systemId,
      );
    }

    // Validate parameters
    _validateSpringParameters(parameters);
  }

  @override
  Future<void> trigger({
    required PhysicsAnimationConfig config,
    VoidCallback? onComplete,
  }) async {
    if (config is! SpringPhysicsConfig) {
      throw PhysicsSystemException(
        'Invalid config type for spring system',
        _systemId,
      );
    }

    _isAnimating = true;

    try {
      // Trigger haptic feedback for spring animation
      HapticFeedback.mediumImpact();

      // Simulate animation completion (in real implementation, this would be handled by AnimationController)
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

  /// Calculate spring physics state using damped harmonic oscillator equations
  PhysicsState _calculateSpringState(double time, SpringPhysicsParameters params) {
    final mass = params.mass;
    final k = params.stiffness;
    final c = params.damping;

    // Validate parameters
    assert(mass > 0, 'Mass must be positive');
    assert(k > 0, 'Stiffness must be positive');
    assert(c >= 0, 'Damping must be non-negative');

    // Calculate natural frequency and damping ratio
    final omega0 = sqrt(k / mass);
    final zeta = c / (2 * sqrt(k * mass));

    double position, velocity;

    if (zeta < 1) {
      // Under-damped oscillation
      final omegaD = omega0 * sqrt(1 - zeta * zeta);
      final exponential = exp(-zeta * omega0 * time);

      position = exponential * cos(omegaD * time);
      velocity = exponential * (-zeta * omega0 * cos(omegaD * time) - omegaD * sin(omegaD * time));
    } else if (zeta == 1) {
      // Critically damped
      final exponential = exp(-omega0 * time);
      position = exponential * (1 + omega0 * time);
      velocity = exponential * omega0 * (1 - omega0 * time);
    } else {
      // Over-damped
      final r1 = omega0 * (-zeta + sqrt(zeta * zeta - 1));
      final r2 = omega0 * (-zeta - sqrt(zeta * zeta - 1));

      position = 0.5 * (exp(r1 * time) + exp(r2 * time));
      velocity = 0.5 * (r1 * exp(r1 * time) + r2 * exp(r2 * time));
    }

    // Calculate acceleration using F = ma
    final acceleration = (-k * position - c * velocity) / mass;

    return PhysicsState(
      position: Offset(position, 0),
      velocity: Offset(velocity, 0),
      acceleration: Offset(acceleration, 0),
      rotation: position * 0.1, // Small rotation based on displacement
      scale: 1.0 + position * 0.2, // Scale variation based on spring compression
      time: time,
    );
  }

  void _validateSpringParameters(SpringPhysicsParameters params) {
    if (params.mass <= 0) {
      throw PhysicsSystemException('Mass must be positive', _systemId);
    }
    if (params.stiffness <= 0) {
      throw PhysicsSystemException('Stiffness must be positive', _systemId);
    }
    if (params.damping < 0) {
      throw PhysicsSystemException('Damping must be non-negative', _systemId);
    }
  }
}

/// Widget implementing spring animation with realistic physics
class _SpringAnimationWidget extends StatefulWidget {
  final SpringPhysicsConfig config;
  final SpringPhysicsSystem system;
  final Widget child;

  const _SpringAnimationWidget({
    required this.config,
    required this.system,
    required this.child,
  });

  @override
  State<_SpringAnimationWidget> createState() => _SpringAnimationWidgetState();
}

class _SpringAnimationWidgetState extends State<_SpringAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late SpringPhysicsParameters _physicsParams;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _physicsParams = SpringPhysicsParameters(
      mass: widget.config.mass,
      damping: widget.config.dampingRatio,
      stiffness: widget.config.stiffness,
    );

    // Create spring curve based on physics parameters
    final springCurve = _createRealisticSpringCurve();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.config.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: springCurve,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi * widget.config.rotationFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: springCurve,
    ));

    // Start animation if triggered
    if (widget.config.trigger) {
      _startAnimation();
    }
  }

  /// Create realistic spring curve based on physics parameters
  Curve _createRealisticSpringCurve() {
    final zeta = widget.config.dampingRatio;

    if (zeta < 0.8) {
      // Under-damped: oscillatory behavior
      return ElasticOutCurve(zeta);
    } else if (zeta < 1.2) {
      // Critically damped: smooth approach
      return Curves.fastOutSlowIn;
    } else {
      // Over-damped: slow approach
      return Curves.easeOut;
    }
  }

  @override
  void didUpdateWidget(_SpringAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.config.trigger && !oldWidget.config.trigger) {
      _startAnimation();
    }
  }

  Future<void> _startAnimation() async {
    widget.system._isAnimating = true;

    try {
      HapticFeedback.mediumImpact();
      await _controller.forward();
      await _controller.reverse();

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
      animation: _controller,
      builder: (context, child) {
        // Calculate physics state for current time
        final currentTime = _controller.value * widget.config.duration.inMilliseconds / 1000.0;
        final physicsState = widget.system.calculateState(
          time: currentTime,
          parameters: _physicsParams,
        );

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.translate(
              offset: physicsState.position,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}