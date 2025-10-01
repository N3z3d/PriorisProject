import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/particle_system_interface.dart';
import '../core/particle_models.dart';

/// Système de particules spécialisé pour les feux d'artifice
/// Respecte le Single Responsibility Principle
class FireworksParticleSystem implements IParticleSystem {
  final FireworksConfig config;

  const FireworksParticleSystem(this.config);

  @override
  Widget createEffect({
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    return _FireworksEffectWidget(
      trigger: trigger,
      config: config,
      onComplete: onComplete,
    );
  }
}

/// Factory pour créer des systèmes de feux d'artifice
class FireworksSystemFactory implements IParticleSystemFactory {
  @override
  String get systemType => 'fireworks';

  @override
  IParticleSystem createSystem(ParticleSystemConfig baseConfig) {
    final fireworksConfig = FireworksConfig(
      fireworkCount: (baseConfig.particleCount / 10).ceil(), // Moins de feux d'artifice
      duration: baseConfig.duration,
      colors: baseConfig.colors,
    );

    return FireworksParticleSystem(fireworksConfig);
  }
}

/// Représente un feu d'artifice individuel avec ses particules
class FireworkBurst {
  final List<Particle> particles;
  final Color color;
  final Offset center;
  bool isActive;

  FireworkBurst({
    required this.particles,
    required this.color,
    required this.center,
    this.isActive = true,
  });

  /// Met à jour toutes les particules du feu d'artifice
  void update(double dt, double friction) {
    for (var particle in particles) {
      particle.update(dt);
      ParticlePhysics.applyFriction(particle, friction);
    }

    // Supprime les particules mortes
    particles.removeWhere((p) => p.isDead);

    // Marque le feu d'artifice comme inactif s'il n'a plus de particules
    if (particles.isEmpty) {
      isActive = false;
    }
  }
}

/// Widget interne pour l'effet de feux d'artifice
class _FireworksEffectWidget extends StatefulWidget {
  final bool trigger;
  final FireworksConfig config;
  final VoidCallback? onComplete;

  const _FireworksEffectWidget({
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<_FireworksEffectWidget> createState() => _FireworksEffectWidgetState();
}

class _FireworksEffectWidgetState extends State<_FireworksEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<FireworkBurst> _fireworks = [];
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
    )..addListener(_updateFireworks);
  }

  @override
  void didUpdateWidget(_FireworksEffectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startFireworks();
    }
  }

  /// Démarre l'effet de feux d'artifice
  void _startFireworks() {
    HapticFeedback.heavyImpact();
    _createFireworks();
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  /// Crée tous les feux d'artifice
  void _createFireworks() {
    _fireworks.clear();

    for (int i = 0; i < widget.config.fireworkCount; i++) {
      _fireworks.add(_createFireworkBurst());
    }
  }

  /// Crée un feu d'artifice individuel
  FireworkBurst _createFireworkBurst() {
    final center = Offset(
      _random.nextDouble() * 300 + 50,
      _random.nextDouble() * 200 + 100,
    );
    final color = widget.config.colors[_random.nextInt(widget.config.colors.length)];
    final particles = <Particle>[];

    // Créer les particules en cercle pour un effet d'explosion radiale
    for (int i = 0; i < widget.config.particlesPerFirework; i++) {
      particles.add(_createFireworkParticle(center, color, i));
    }

    return FireworkBurst(
      particles: particles,
      color: color,
      center: center,
    );
  }

  /// Crée une particule individuelle pour un feu d'artifice
  Particle _createFireworkParticle(Offset center, Color color, int index) {
    final angle = (index / widget.config.particlesPerFirework) * 2 * pi;
    final speed = _random.nextDouble() * 100 + 50;
    final size = _random.nextDouble() * 4 + 2;

    return Particle(
      position: center,
      velocity: Offset(
        cos(angle) * speed,
        sin(angle) * speed,
      ),
      size: size,
      color: color,
      life: widget.config.duration.inMilliseconds / 1000.0,
      maxLife: widget.config.duration.inMilliseconds / 1000.0,
    );
  }

  /// Met à jour tous les feux d'artifice
  void _updateFireworks() {
    if (!mounted) return;

    const dt = 1.0 / 60.0;

    for (var firework in _fireworks) {
      if (firework.isActive) {
        firework.update(dt, widget.config.friction);
      }
    }

    // Supprime les feux d'artifice inactifs
    _fireworks.removeWhere((f) => !f.isActive);
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
            painter: _FireworksPainter(_fireworks),
          ),
        );
      },
    );
  }
}

/// Painter spécialisé pour les feux d'artifice
class _FireworksPainter extends CustomPainter {
  final List<FireworkBurst> fireworks;

  const _FireworksPainter(this.fireworks);

  @override
  void paint(Canvas canvas, Size size) {
    for (var firework in fireworks) {
      if (firework.isActive) {
        _drawFireworkBurst(canvas, firework);
      }
    }
  }

  /// Dessine un feu d'artifice complet
  void _drawFireworkBurst(Canvas canvas, FireworkBurst firework) {
    for (var particle in firework.particles) {
      _drawFireworkParticle(canvas, particle);
    }

    // Ajouter un effet de lueur au centre si le feu d'artifice vient d'exploser
    if (firework.particles.isNotEmpty) {
      final avgLife = firework.particles
          .map((p) => p.life / p.maxLife)
          .reduce((a, b) => a + b) / firework.particles.length;

      if (avgLife > 0.8) {
        _drawCenterGlow(canvas, firework.center, firework.color, avgLife);
      }
    }
  }

  /// Dessine une particule de feu d'artifice avec traînée
  void _drawFireworkParticle(Canvas canvas, Particle particle) {
    final paint = Paint()
      ..color = particle.color.withValues(alpha: particle.opacity)
      ..style = PaintingStyle.fill;

    // Dessiner la particule principale
    canvas.drawCircle(particle.position, particle.size, paint);

    // Dessiner une traînée
    if (particle.opacity > 0.5) {
      _drawParticleTrail(canvas, particle);
    }
  }

  /// Dessine la traînée d'une particule
  void _drawParticleTrail(Canvas canvas, Particle particle) {
    final trailPaint = Paint()
      ..color = particle.color.withValues(alpha: particle.opacity * 0.3)
      ..strokeWidth = particle.size * 0.5
      ..strokeCap = StrokeCap.round;

    final trailStart = particle.position - particle.velocity.scale(0.1, 0.1);
    canvas.drawLine(trailStart, particle.position, trailPaint);
  }

  /// Dessine un effet de lueur au centre du feu d'artifice
  void _drawCenterGlow(Canvas canvas, Offset center, Color color, double intensity) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: intensity * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, 15 * intensity, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}