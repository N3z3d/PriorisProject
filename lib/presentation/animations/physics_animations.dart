import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Système d'animations avancées avec physique réaliste
class PhysicsAnimations {
  /// Animation de spring avec paramètres personnalisables
  static Widget springAnimation({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 800),
    double dampingRatio = 0.8,
    double stiffness = 100.0,
    VoidCallback? onComplete,
  }) {
    return _SpringAnimation(
      trigger: trigger,
      duration: duration,
      dampingRatio: dampingRatio,
      stiffness: stiffness,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Animation de bounce élastique
  static Widget elasticBounce({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 1200),
    double bounceHeight = 1.3,
    int bounceCount = 3,
    VoidCallback? onComplete,
  }) {
    return _ElasticBounceAnimation(
      trigger: trigger,
      duration: duration,
      bounceHeight: bounceHeight,
      bounceCount: bounceCount,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Animation de scale avec effet de ressort
  static Widget springScale({
    required Widget child,
    required VoidCallback onTap,
    double scaleFactor = 0.9,
    Duration duration = const Duration(milliseconds: 600),
    Curve springCurve = Curves.elasticOut,
  }) {
    return _SpringScaleAnimation(
      onTap: onTap,
      scaleFactor: scaleFactor,
      duration: duration,
      springCurve: springCurve,
      child: child,
    );
  }

  /// Animation de rotation avec inertie
  static Widget inertialRotation({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 1500),
    double initialVelocity = 10.0,
    double friction = 0.05,
    VoidCallback? onComplete,
  }) {
    return _InertialRotationAnimation(
      trigger: trigger,
      duration: duration,
      initialVelocity: initialVelocity,
      friction: friction,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Animation de pendule
  static Widget pendulum({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    double angle = 0.3,
    int cycles = 5,
    bool autoStart = true,
  }) {
    return _PendulumAnimation(
      duration: duration,
      angle: angle,
      cycles: cycles,
      autoStart: autoStart,
      child: child,
    );
  }

  /// Animation de gravité avec rebond
  static Widget gravityBounce({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 2000),
    double height = 100.0,
    double bounceDamping = 0.7,
    int bounceCount = 3,
    VoidCallback? onComplete,
  }) {
    return _GravityBounceAnimation(
      trigger: trigger,
      duration: duration,
      height: height,
      bounceDamping: bounceDamping,
      bounceCount: bounceCount,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Animation de vague physique
  static Widget physicsWave({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double amplitude = 15.0,
    double frequency = 2.0,
    double damping = 0.02,
    bool autoStart = true,
  }) {
    return _PhysicsWaveAnimation(
      duration: duration,
      amplitude: amplitude,
      frequency: frequency,
      damping: damping,
      autoStart: autoStart,
      child: child,
    );
  }

  /// Animation de particule flottante
  static Widget floatingParticle({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    double maxOffset = 20.0,
    double randomnessFactor = 0.3,
    bool autoStart = true,
  }) {
    return _FloatingParticleAnimation(
      duration: duration,
      maxOffset: maxOffset,
      randomnessFactor: randomnessFactor,
      autoStart: autoStart,
      child: child,
    );
  }
}

/// Animation de spring personnalisée
class _SpringAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;
  final double dampingRatio;
  final double stiffness;
  final VoidCallback? onComplete;

  const _SpringAnimation({
    required this.child,
    required this.trigger,
    required this.duration,
    required this.dampingRatio,
    required this.stiffness,
    this.onComplete,
  });

  @override
  State<_SpringAnimation> createState() => _SpringAnimationState();
}

class _SpringAnimationState extends State<_SpringAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Courbe de spring personnalisée
    final springCurve = _createSpringCurve(
      widget.dampingRatio,
      widget.stiffness,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: springCurve,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  Curve _createSpringCurve(double dampingRatio, double stiffness) {
    return ElasticOutCurve(dampingRatio / 10);
  }

  @override
  void didUpdateWidget(_SpringAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    HapticFeedback.mediumImpact();
    await _controller.forward();
    await _controller.reverse();
    widget.onComplete?.call();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Animation de bounce élastique
class _ElasticBounceAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;
  final double bounceHeight;
  final int bounceCount;
  final VoidCallback? onComplete;

  const _ElasticBounceAnimation({
    required this.child,
    required this.trigger,
    required this.duration,
    required this.bounceHeight,
    required this.bounceCount,
    this.onComplete,
  });

  @override
  State<_ElasticBounceAnimation> createState() => _ElasticBounceAnimationState();
}

class _ElasticBounceAnimationState extends State<_ElasticBounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final bounceItems = <TweenSequenceItem<double>>[];
    for (int i = 0; i < widget.bounceCount; i++) {
      bounceItems.addAll([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0,
            end: widget.bounceHeight * pow(0.7, i),
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 1.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: widget.bounceHeight * pow(0.7, i),
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 1.0,
        ),
      ]);
    }
    
    _bounceAnimation = TweenSequence<double>(bounceItems
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(_ElasticBounceAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startBounce();
    }
  }

  void _startBounce() async {
    HapticFeedback.heavyImpact();
    await _controller.forward(from: 0);
    widget.onComplete?.call();
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
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Animation de scale avec ressort
class _SpringScaleAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;
  final Duration duration;
  final Curve springCurve;

  const _SpringScaleAnimation({
    required this.child,
    required this.onTap,
    required this.scaleFactor,
    required this.duration,
    required this.springCurve,
  });

  @override
  State<_SpringScaleAnimation> createState() => _SpringScaleAnimationState();
}

class _SpringScaleAnimationState extends State<_SpringScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.springCurve,
    ));
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animation de rotation avec inertie
class _InertialRotationAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;
  final double initialVelocity;
  final double friction;
  final VoidCallback? onComplete;

  const _InertialRotationAnimation({
    required this.child,
    required this.trigger,
    required this.duration,
    required this.initialVelocity,
    required this.friction,
    this.onComplete,
  });

  @override
  State<_InertialRotationAnimation> createState() =>
      _InertialRotationAnimationState();
}

class _InertialRotationAnimationState extends State<_InertialRotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.initialVelocity * (1 - widget.friction),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));
  }

  @override
  void didUpdateWidget(_InertialRotationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startRotation();
    }
  }

  void _startRotation() async {
    HapticFeedback.mediumImpact();
    await _controller.forward(from: 0);
    widget.onComplete?.call();
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

/// Animation de pendule
class _PendulumAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double angle;
  final int cycles;
  final bool autoStart;

  const _PendulumAnimation({
    required this.child,
    required this.duration,
    required this.angle,
    required this.cycles,
    required this.autoStart,
  });

  @override
  State<_PendulumAnimation> createState() => _PendulumAnimationState();
}

class _PendulumAnimationState extends State<_PendulumAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pendulumAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _pendulumAnimation = Tween<double>(
      begin: -widget.angle,
      end: widget.angle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
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

/// Animation de gravité avec rebond
class _GravityBounceAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;
  final double height;
  final double bounceDamping;
  final int bounceCount;
  final VoidCallback? onComplete;

  const _GravityBounceAnimation({
    required this.child,
    required this.trigger,
    required this.duration,
    required this.height,
    required this.bounceDamping,
    required this.bounceCount,
    this.onComplete,
  });

  @override
  State<_GravityBounceAnimation> createState() => _GravityBounceAnimationState();
}

class _GravityBounceAnimationState extends State<_GravityBounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final List<TweenSequenceItem<double>> items = [];
    
    // Chute initiale
    items.add(TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: widget.height,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 2.0,
    ));

    // Rebonds avec amortissement
    for (int i = 0; i < widget.bounceCount; i++) {
      final currentHeight = widget.height * pow(widget.bounceDamping, i + 1);
      
      // Remontée
      items.add(TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.height * pow(widget.bounceDamping, i),
          end: currentHeight,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1.0,
      ));
      
      // Retombée
      items.add(TweenSequenceItem(
        tween: Tween<double>(
          begin: currentHeight,
          end: widget.height * pow(widget.bounceDamping, i + 1),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1.0,
      ));
    }

    _bounceAnimation = TweenSequence<double>(items).animate(_controller);
  }

  @override
  void didUpdateWidget(_GravityBounceAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startBounce();
    }
  }

  void _startBounce() async {
    HapticFeedback.heavyImpact();
    await _controller.forward(from: 0);
    widget.onComplete?.call();
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

/// Animation de vague physique
class _PhysicsWaveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;
  final double frequency;
  final double damping;
  final bool autoStart;

  const _PhysicsWaveAnimation({
    required this.child,
    required this.duration,
    required this.amplitude,
    required this.frequency,
    required this.damping,
    required this.autoStart,
  });

  @override
  State<_PhysicsWaveAnimation> createState() => _PhysicsWaveAnimationState();
}

class _PhysicsWaveAnimationState extends State<_PhysicsWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi * widget.frequency,
    ).animate(_controller);

    if (widget.autoStart) {
      _controller.repeat();
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
      animation: _waveAnimation,
      builder: (context, child) {
        final dampedAmplitude = widget.amplitude * 
            exp(-widget.damping * _controller.value * 10);
        final offset = sin(_waveAnimation.value) * dampedAmplitude;
        
        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Animation de particule flottante
class _FloatingParticleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double maxOffset;
  final double randomnessFactor;
  final bool autoStart;

  const _FloatingParticleAnimation({
    required this.child,
    required this.duration,
    required this.maxOffset,
    required this.randomnessFactor,
    required this.autoStart,
  });

  @override
  State<_FloatingParticleAnimation> createState() =>
      _FloatingParticleAnimationState();
}

class _FloatingParticleAnimationState extends State<_FloatingParticleAnimation>
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
      milliseconds: (widget.duration.inMilliseconds * 
          (1 + _random.nextDouble() * widget.randomnessFactor)).round(),
    );
    
    final yDuration = Duration(
      milliseconds: (widget.duration.inMilliseconds * 
          (1 + _random.nextDouble() * widget.randomnessFactor)).round(),
    );

    _xController = AnimationController(duration: xDuration, vsync: this);
    _yController = AnimationController(duration: yDuration, vsync: this);

    _xAnimation = Tween<double>(
      begin: -widget.maxOffset,
      end: widget.maxOffset,
    ).animate(CurvedAnimation(
      parent: _xController,
      curve: Curves.easeInOut,
    ));

    _yAnimation = Tween<double>(
      begin: -widget.maxOffset * 0.5,
      end: widget.maxOffset * 0.5,
    ).animate(CurvedAnimation(
      parent: _yController,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
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