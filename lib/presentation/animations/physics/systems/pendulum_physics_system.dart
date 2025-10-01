import 'dart:math';
import 'package:flutter/material.dart';
import '../interfaces/physics_system_interface.dart';
import '../configs/physics_configs.dart';

/// Pendulum Physics System implementing realistic pendulum motion
class PendulumPhysicsSystem implements IAnimatedPhysicsSystem {
  static const String _systemId = 'pendulum_physics';
  static const String _systemName = 'Pendulum Physics System';

  bool _isActive = false;

  @override
  String get systemId => _systemId;
  @override
  String get systemName => _systemName;
  @override
  bool get isActive => _isActive;

  @override
  Future<void> initialize() async {
    if (_isActive) return;
    _isActive = true;
  }

  @override
  Future<void> dispose() async {
    _isActive = false;
  }

  @override
  Widget createAnimation({required Widget child, required PhysicsAnimationConfig config}) {
    if (config is! PendulumPhysicsConfig) {
      throw PhysicsSystemException('Invalid config type for pendulum system', _systemId);
    }

    return _PendulumAnimationWidget(config: config, system: this, child: child);
  }
}

class _PendulumAnimationWidget extends StatefulWidget {
  final PendulumPhysicsConfig config;
  final PendulumPhysicsSystem system;
  final Widget child;

  const _PendulumAnimationWidget({
    required this.config,
    required this.system,
    required this.child,
  });

  @override
  State<_PendulumAnimationWidget> createState() => _PendulumAnimationWidgetState();
}

class _PendulumAnimationWidgetState extends State<_PendulumAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pendulumAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.config.duration, vsync: this);

    _pendulumAnimation = Tween<double>(
      begin: -widget.config.angle,
      end: widget.config.angle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.config.autoStart) {
      _controller.repeat(reverse: true);
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
      animation: _pendulumAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _pendulumAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}