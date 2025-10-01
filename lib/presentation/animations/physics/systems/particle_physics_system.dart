import 'dart:math';
import 'package:flutter/material.dart';
import '../interfaces/physics_system_interface.dart';
import '../configs/physics_configs.dart';

/// Particle Physics System implementing floating particle motion with turbulence
class ParticlePhysicsSystem implements IAnimatedPhysicsSystem {
  static const String _systemId = 'particle_physics';
  static const String _systemName = 'Particle Physics System';

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
    if (config is! ParticlePhysicsConfig) {
      throw PhysicsSystemException('Invalid config type for particle system', _systemId);
    }

    return _ParticleAnimationWidget(config: config, system: this, child: child);
  }
}

class _ParticleAnimationWidget extends StatefulWidget {
  final ParticlePhysicsConfig config;
  final ParticlePhysicsSystem system;
  final Widget child;

  const _ParticleAnimationWidget({
    required this.config,
    required this.system,
    required this.child,
  });

  @override
  State<_ParticleAnimationWidget> createState() => _ParticleAnimationWidgetState();
}

class _ParticleAnimationWidgetState extends State<_ParticleAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _xController;
  late AnimationController _yController;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    final xDuration = Duration(
      milliseconds: (widget.config.duration.inMilliseconds *
          (1 + _random.nextDouble() * widget.config.randomnessFactor)).round(),
    );

    final yDuration = Duration(
      milliseconds: (widget.config.duration.inMilliseconds *
          (1 + _random.nextDouble() * widget.config.randomnessFactor)).round(),
    );

    _xController = AnimationController(duration: xDuration, vsync: this);
    _yController = AnimationController(duration: yDuration, vsync: this);

    _xAnimation = Tween<double>(
      begin: -widget.config.maxOffset,
      end: widget.config.maxOffset,
    ).animate(CurvedAnimation(parent: _xController, curve: Curves.easeInOut));

    _yAnimation = Tween<double>(
      begin: -widget.config.maxOffset * 0.5,
      end: widget.config.maxOffset * 0.5,
    ).animate(CurvedAnimation(parent: _yController, curve: Curves.easeInOut));

    if (widget.config.autoStart) {
      _xController.repeat(reverse: true);
      _yController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_xAnimation, _yAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_xAnimation.value, _yAnimation.value),
          child: widget.child,
        );
      },
    );
  }
}