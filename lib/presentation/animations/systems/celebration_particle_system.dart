import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/particle_system_interface.dart';
import '../core/particle_models.dart';

/// Types d'effets de célébration disponibles
enum CelebrationType {
  hearts,
  ripple,
  gentleRain,
}

/// Système de particules spécialisé pour les célébrations
/// Respecte le Single Responsibility Principle
class CelebrationParticleSystem implements IParticleSystem {
  final CelebrationConfig config;
  final CelebrationType type;

  const CelebrationParticleSystem(this.config, this.type);

  @override
  Widget createEffect({
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    switch (type) {
      case CelebrationType.hearts:
        return _FloatingHeartsWidget(
          trigger: trigger,
          config: config,
          onComplete: onComplete,
        );
      case CelebrationType.ripple:
        return _RippleEffectWidget(
          trigger: trigger,
          config: config,
          onComplete: onComplete,
        );
      case CelebrationType.gentleRain:
        return _GentleRainWidget(
          trigger: trigger,
          config: config,
          onComplete: onComplete,
        );
    }
  }
}

/// Factory pour créer des systèmes de célébration
class CelebrationSystemFactory implements IParticleSystemFactory {
  final CelebrationType type;

  const CelebrationSystemFactory(this.type);

  @override
  String get systemType => 'celebration_${type.name}';

  @override
  IParticleSystem createSystem(ParticleSystemConfig baseConfig) {
    final celebrationConfig = CelebrationConfig(
      itemCount: baseConfig.particleCount,
      duration: baseConfig.duration,
      colors: baseConfig.colors,
    );

    return CelebrationParticleSystem(celebrationConfig, type);
  }
}

/// Widget pour les coeurs flottants
class _FloatingHeartsWidget extends StatefulWidget {
  final bool trigger;
  final CelebrationConfig config;
  final VoidCallback? onComplete;

  const _FloatingHeartsWidget({
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<_FloatingHeartsWidget> createState() => _FloatingHeartsWidgetState();
}

class _FloatingHeartsWidgetState extends State<_FloatingHeartsWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _hearts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    )..addListener(_updateHearts);
  }

  @override
  void didUpdateWidget(_FloatingHeartsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startHearts();
    }
  }

  void _startHearts() {
    HapticFeedback.lightImpact();
    _createHearts();
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  void _createHearts() {
    _hearts.clear();

    for (int i = 0; i < widget.config.itemCount; i++) {
      _hearts.add(_createHeartParticle());
    }
  }

  Particle _createHeartParticle() {
    final color = widget.config.colors[_random.nextInt(widget.config.colors.length)];

    return Particle(
      position: Offset(
        _random.nextDouble() * 300 + 50,
        400 + _random.nextDouble() * 100,
      ),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 30,
        -_random.nextDouble() * 50 - 30,
      ),
      size: _random.nextDouble() * 20 + 15,
      color: color,
      life: widget.config.duration.inMilliseconds / 1000.0,
      maxLife: widget.config.duration.inMilliseconds / 1000.0,
    );
  }

  void _updateHearts() {
    if (!mounted) return;

    const dt = 1.0 / 60.0;

    for (var heart in _hearts) {
      heart.update(dt);
      // Mouvement sinusoïdal horizontal
      ParticlePhysics.applySinusoidalMovement(heart, 20);
      // Ralentissement vertical
      heart.velocity = Offset(heart.velocity.dx, heart.velocity.dy * 0.99);
    }

    _hearts.removeWhere((h) => h.isDead);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : 400,
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : 600,
          child: CustomPaint(
            painter: _HeartPainter(_hearts),
          ),
        );
      },
    );
  }
}

/// Widget pour l'effet d'ondulation
class _RippleEffectWidget extends StatefulWidget {
  final bool trigger;
  final CelebrationConfig config;
  final VoidCallback? onComplete;

  const _RippleEffectWidget({
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<_RippleEffectWidget> createState() => _RippleEffectWidgetState();
}

class _RippleEffectWidgetState extends State<_RippleEffectWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _radiusAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final rippleCount = (widget.config.itemCount / 5).ceil(); // Moins d'ondulations
    _controllers = [];
    _radiusAnimations = [];
    _opacityAnimations = [];

    for (int i = 0; i < rippleCount; i++) {
      final controller = AnimationController(
        duration: widget.config.duration,
        vsync: this,
      );

      final radiusAnimation = Tween<double>(
        begin: 0,
        end: widget.config.maxRadius,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      final opacityAnimation = Tween<double>(
        begin: 0.8,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      _controllers.add(controller);
      _radiusAnimations.add(radiusAnimation);
      _opacityAnimations.add(opacityAnimation);
    }
  }

  @override
  void didUpdateWidget(_RippleEffectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startRipples();
    }
  }

  void _startRipples() async {
    HapticFeedback.mediumImpact();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].forward(from: 0);
        }
      });
    }

    await Future.delayed(
      widget.config.duration + Duration(milliseconds: (_controllers.length - 1) * 200),
    );
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : 400,
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : 600,
          child: CustomPaint(
            painter: _RipplePainter(
              _radiusAnimations,
              _opacityAnimations,
              widget.config.colors.first,
            ),
          ),
        );
      },
    );
  }
}

/// Widget pour la pluie douce
class _GentleRainWidget extends StatefulWidget {
  final bool trigger;
  final CelebrationConfig config;
  final VoidCallback? onComplete;

  const _GentleRainWidget({
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<_GentleRainWidget> createState() => _GentleRainWidgetState();
}

class _GentleRainWidgetState extends State<_GentleRainWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    )..addListener(_updateRain);
  }

  @override
  void didUpdateWidget(_GentleRainWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startRain();
    }
  }

  void _startRain() {
    HapticFeedback.lightImpact();
    _createRainParticles();
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  void _createRainParticles() {
    _particles.clear();

    for (int i = 0; i < widget.config.itemCount; i++) {
      _particles.add(_createRainParticle());
    }
  }

  Particle _createRainParticle() {
    final color = widget.config.colors[_random.nextInt(widget.config.colors.length)]
        .withValues(alpha: 0.7);

    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        -_random.nextDouble() * 100,
      ),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 20,
        _random.nextDouble() * 50 + 30 * widget.config.fallSpeed,
      ),
      size: _random.nextDouble() * 6 + 2,
      color: color,
      life: widget.config.duration.inMilliseconds / 1000.0,
      maxLife: widget.config.duration.inMilliseconds / 1000.0,
    );
  }

  void _updateRain() {
    if (!mounted) return;

    const dt = 1.0 / 60.0;

    for (var particle in _particles) {
      particle.update(dt);
    }

    _particles.removeWhere((p) => p.isDead || p.position.dy > 600);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : 400,
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : 600,
          child: CustomPaint(
            painter: _ParticlePainter(_particles),
          ),
        );
      },
    );
  }
}

/// Painter pour les coeurs
class _HeartPainter extends CustomPainter {
  final List<Particle> hearts;

  const _HeartPainter(this.hearts);

  @override
  void paint(Canvas canvas, Size size) {
    for (var heart in hearts) {
      _drawHeart(canvas, heart);
    }
  }

  void _drawHeart(Canvas canvas, Particle heart) {
    final paint = Paint()
      ..color = heart.color.withValues(alpha: heart.opacity)
      ..style = PaintingStyle.fill;

    final path = _createHeartPath(heart.position, heart.size);
    canvas.drawPath(path, paint);
  }

  Path _createHeartPath(Offset position, double size) {
    final path = Path();
    final x = position.dx;
    final y = position.dy;
    final s = size / 20; // Scale factor

    path.moveTo(x, y + 5 * s);
    path.cubicTo(x, y, x - 10 * s, y - 5 * s, x - 10 * s, y);
    path.cubicTo(x - 10 * s, y + 5 * s, x, y + 10 * s, x, y + 15 * s);
    path.cubicTo(x, y + 10 * s, x + 10 * s, y + 5 * s, x + 10 * s, y);
    path.cubicTo(x + 10 * s, y - 5 * s, x, y, x, y + 5 * s);

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour les ondulations
class _RipplePainter extends CustomPainter {
  final List<Animation<double>> radiusAnimations;
  final List<Animation<double>> opacityAnimations;
  final Color color;

  const _RipplePainter(this.radiusAnimations, this.opacityAnimations, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < radiusAnimations.length; i++) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacityAnimations[i].value)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radiusAnimations[i].value, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter générique pour les particules
class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  const _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}