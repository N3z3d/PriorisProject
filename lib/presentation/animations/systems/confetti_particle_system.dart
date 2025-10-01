import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/particle_system_interface.dart';
import '../core/particle_models.dart';

/// Système de particules spécialisé pour les confettis
/// Respecte le Single Responsibility Principle
class ConfettiParticleSystem implements IParticleSystem {
  final ConfettiConfig config;

  const ConfettiParticleSystem(this.config);

  @override
  Widget createEffect({
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    return _ConfettiExplosionWidget(
      trigger: trigger,
      config: config,
      onComplete: onComplete,
    );
  }
}

/// Factory pour créer des systèmes de confettis
class ConfettiSystemFactory implements IParticleSystemFactory {
  @override
  String get systemType => 'confetti';

  @override
  IParticleSystem createSystem(ParticleSystemConfig baseConfig) {
    final confettiConfig = ConfettiConfig(
      particleCount: baseConfig.particleCount,
      duration: baseConfig.duration,
      colors: baseConfig.colors,
    );

    return ConfettiParticleSystem(confettiConfig);
  }
}

/// Widget interne pour l'explosion de confettis
class _ConfettiExplosionWidget extends StatefulWidget {
  final bool trigger;
  final ConfettiConfig config;
  final VoidCallback? onComplete;

  const _ConfettiExplosionWidget({
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<_ConfettiExplosionWidget> createState() => _ConfettiExplosionWidgetState();
}

class _ConfettiExplosionWidgetState extends State<_ConfettiExplosionWidget>
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
    )..addListener(_updateParticles);
  }

  @override
  void didUpdateWidget(_ConfettiExplosionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startExplosion();
    }
  }

  /// Démarre l'explosion de confettis
  void _startExplosion() {
    HapticFeedback.heavyImpact();
    _createParticles();
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  /// Crée les particules de confettis
  void _createParticles() {
    _particles.clear();

    for (int i = 0; i < widget.config.particleCount; i++) {
      _particles.add(_createConfettiParticle());
    }
  }

  /// Crée une particule de confetti individuelle
  Particle _createConfettiParticle() {
    final angle = _random.nextDouble() * 2 * pi;
    final speed = _random.nextDouble() * 200 + 100;
    final size = _random.nextDouble() * 8 + 4;
    final color = widget.config.colors[_random.nextInt(widget.config.colors.length)];

    return Particle(
      position: const Offset(200, 200), // Centre de l'écran
      velocity: Offset(
        cos(angle) * speed,
        sin(angle) * speed - 50, // Tendance vers le haut
      ),
      size: size,
      color: color,
      rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      life: widget.config.duration.inMilliseconds / 1000.0,
      maxLife: widget.config.duration.inMilliseconds / 1000.0,
    );
  }

  /// Met à jour les particules de confettis
  void _updateParticles() {
    if (!mounted) return;

    const dt = 1.0 / 60.0; // 60 FPS

    for (var particle in _particles) {
      particle.update(dt);
      _applyConfettiPhysics(particle, dt);
    }

    _particles.removeWhere((p) => p.isDead);
    setState(() {});
  }

  /// Applique la physique spécifique aux confettis
  void _applyConfettiPhysics(Particle particle, double dt) {
    // Appliquer la gravité
    ParticlePhysics.applyGravity(particle, widget.config.gravityStrength, dt);

    // Appliquer la friction horizontale
    particle.velocity = Offset(
      particle.velocity.dx * widget.config.friction,
      particle.velocity.dy,
    );
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
            painter: _ConfettiPainter(_particles),
          ),
        );
      },
    );
  }
}

/// Painter spécialisé pour les confettis
class _ConfettiPainter extends CustomPainter {
  final List<Particle> particles;

  const _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      _drawConfettiParticle(canvas, particle);
    }
  }

  /// Dessine une particule de confetti individuelle
  void _drawConfettiParticle(Canvas canvas, Particle particle) {
    final paint = Paint()
      ..color = particle.color.withValues(alpha: particle.opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(particle.position.dx, particle.position.dy);
    canvas.rotate(particle.rotation);

    // Dessiner un rectangle tourné pour simuler un confetti
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: particle.size * 2,
      height: particle.size,
    );

    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}