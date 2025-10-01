import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../interfaces/physics_system_interface.dart';
import '../configs/physics_configs.dart';

/// Inertial Physics System implementing rotational dynamics with friction
class InertialPhysicsSystem implements IAnimatedPhysicsSystem, ITriggerablePhysicsSystem {
  static const String _systemId = 'inertial_physics';
  static const String _systemName = 'Inertial Physics System';

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
    _isActive = true;
  }

  @override
  Future<void> dispose() async {
    _isActive = false;
    _isAnimating = false;
  }

  @override
  Widget createAnimation({required Widget child, required PhysicsAnimationConfig config}) {
    if (config is! InertialPhysicsConfig) {
      throw PhysicsSystemException('Invalid config type for inertial system', _systemId);
    }

    return _InertialAnimationWidget(config: config, system: this, child: child);
  }

  @override
  Future<void> trigger({required PhysicsAnimationConfig config, VoidCallback? onComplete}) async {
    if (config is! InertialPhysicsConfig) {
      throw PhysicsSystemException('Invalid config type for inertial system', _systemId);
    }

    _isAnimating = true;
    try {
      HapticFeedback.mediumImpact();
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
}

class _InertialAnimationWidget extends StatefulWidget {
  final InertialPhysicsConfig config;
  final InertialPhysicsSystem system;
  final Widget child;

  const _InertialAnimationWidget({
    required this.config,
    required this.system,
    required this.child,
  });

  @override
  State<_InertialAnimationWidget> createState() => _InertialAnimationWidgetState();
}

class _InertialAnimationWidgetState extends State<_InertialAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.config.duration, vsync: this);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.config.initialVelocity * (1 - widget.config.friction),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    if (widget.config.trigger) _startAnimation();
  }

  Future<void> _startAnimation() async {
    widget.system._isAnimating = true;
    try {
      HapticFeedback.mediumImpact();
      await _controller.forward(from: 0);
      widget.config.onComplete?.call();
    } finally {
      widget.system._isAnimating = false;
    }
  }

  @override
  void didUpdateWidget(_InertialAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.trigger && !oldWidget.config.trigger) {
      _startAnimation();
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
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}