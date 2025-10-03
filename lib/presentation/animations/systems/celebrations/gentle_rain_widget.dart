import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/particle_models.dart';

/// Widget pour la pluie douce
/// Respecte SRP : gestion unique de l'animation de pluie douce
class GentleRainWidget extends StatefulWidget {
  final bool trigger;
  final CelebrationConfig config;
  final VoidCallback? onComplete;

  const GentleRainWidget({
    super.key,
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<GentleRainWidget> createState() => _GentleRainWidgetState();
}

class _GentleRainWidgetState extends State<GentleRainWidget>
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
  void didUpdateWidget(GentleRainWidget oldWidget) {
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
            painter: ParticlePainter(_particles),
          ),
        );
      },
    );
  }
}

/// Painter générique pour les particules
/// Respecte SRP : rendu visuel des particules uniquement
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  const ParticlePainter(this.particles);

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
