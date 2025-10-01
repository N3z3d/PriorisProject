import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/particle_system_interface.dart';
import '../core/particle_models.dart';

/// Système de particules spécialisé pour les étoiles scintillantes
/// Respecte le Single Responsibility Principle
class SparkleParticleSystem implements IParticleSystem {
  final SparkleConfig config;

  const SparkleParticleSystem(this.config);

  @override
  Widget createEffect({
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    return _SparkleEffectWidget(
      trigger: trigger,
      config: config,
      onComplete: onComplete,
    );
  }
}

/// Factory pour créer des systèmes de sparkles
class SparkleSystemFactory implements IParticleSystemFactory {
  @override
  String get systemType => 'sparkle';

  @override
  IParticleSystem createSystem(ParticleSystemConfig baseConfig) {
    final sparkleConfig = SparkleConfig(
      sparkleCount: baseConfig.particleCount,
      duration: baseConfig.duration,
      colors: baseConfig.colors,
    );

    return SparkleParticleSystem(sparkleConfig);
  }
}

/// Widget interne pour l'effet de sparkles
class _SparkleEffectWidget extends StatefulWidget {
  final bool trigger;
  final SparkleConfig config;
  final VoidCallback? onComplete;

  const _SparkleEffectWidget({
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<_SparkleEffectWidget> createState() => _SparkleEffectWidgetState();
}

class _SparkleEffectWidgetState extends State<_SparkleEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _sparkles = [];
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
    )..addListener(_updateSparkles);
  }

  @override
  void didUpdateWidget(_SparkleEffectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startSparkle();
    }
  }

  /// Démarre l'effet de sparkles
  void _startSparkle() {
    HapticFeedback.lightImpact();
    _createSparkles();
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  /// Crée les particules sparkles
  void _createSparkles() {
    _sparkles.clear();

    for (int i = 0; i < widget.config.sparkleCount; i++) {
      _sparkles.add(_createSparkleParticle());
    }
  }

  /// Crée une particule sparkle individuelle
  Particle _createSparkleParticle() {
    final color = widget.config.colors[_random.nextInt(widget.config.colors.length)];

    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        _random.nextDouble() * 400,
      ),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 50,
        (_random.nextDouble() - 0.5) * 50,
      ),
      size: _random.nextDouble() * widget.config.maxSize + 2,
      color: color,
      rotationSpeed: (_random.nextDouble() - 0.5) * 5,
      life: widget.config.duration.inMilliseconds / 1000.0,
      maxLife: widget.config.duration.inMilliseconds / 1000.0,
    );
  }

  /// Met à jour les sparkles avec l'effet de scintillement
  void _updateSparkles() {
    if (!mounted) return;

    const dt = 1.0 / 60.0;

    for (var sparkle in _sparkles) {
      sparkle.update(dt);
      _applyTwinkleEffect(sparkle);
    }

    _sparkles.removeWhere((s) => s.isDead);
    setState(() {});
  }

  /// Applique l'effet de scintillement aux sparkles
  void _applyTwinkleEffect(Particle sparkle) {
    // Effet de scintillement sinusoïdal
    final twinkle = (sin(sparkle.life * widget.config.twinkleIntensity) + 1) / 2;
    sparkle.opacity = twinkle * (sparkle.life / sparkle.maxLife);
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
            painter: _SparklePainter(_sparkles),
          ),
        );
      },
    );
  }
}

/// Painter spécialisé pour les sparkles
class _SparklePainter extends CustomPainter {
  final List<Particle> sparkles;

  const _SparklePainter(this.sparkles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var sparkle in sparkles) {
      _drawSparkleParticle(canvas, sparkle);
    }
  }

  /// Dessine une particule sparkle sous forme d'étoile
  void _drawSparkleParticle(Canvas canvas, Particle sparkle) {
    final paint = Paint()
      ..color = sparkle.color.withValues(alpha: sparkle.opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(sparkle.position.dx, sparkle.position.dy);
    canvas.rotate(sparkle.rotation);

    // Dessiner une étoile à 4 branches
    final path = _createStarPath(sparkle.size);
    canvas.drawPath(path, paint);

    // Ajouter un effet de lueur
    if (sparkle.opacity > 0.5) {
      final glowPaint = Paint()
        ..color = sparkle.color.withValues(alpha: sparkle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawPath(path, glowPaint);
    }

    canvas.restore();
  }

  /// Crée un chemin en forme d'étoile
  Path _createStarPath(double size) {
    final path = Path();
    const starPoints = 4;

    for (int i = 0; i < starPoints * 2; i++) {
      final angle = (i * pi / starPoints);
      final radius = (i % 2 == 0) ? size : size * 0.4; // Alternance entre pointes et creux
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}