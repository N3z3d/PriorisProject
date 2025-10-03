import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/particle_models.dart';

/// Widget pour les coeurs flottants
/// Respecte SRP : gestion unique de l'animation des coeurs flottants
class FloatingHeartsWidget extends StatefulWidget {
  final bool trigger;
  final CelebrationConfig config;
  final VoidCallback? onComplete;

  const FloatingHeartsWidget({
    super.key,
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<FloatingHeartsWidget> createState() => _FloatingHeartsWidgetState();
}

class _FloatingHeartsWidgetState extends State<FloatingHeartsWidget>
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
  void didUpdateWidget(FloatingHeartsWidget oldWidget) {
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
            painter: HeartPainter(_hearts),
          ),
        );
      },
    );
  }
}

/// Painter pour les coeurs
/// Respecte SRP : rendu visuel des coeurs uniquement
class HeartPainter extends CustomPainter {
  final List<Particle> hearts;

  const HeartPainter(this.hearts);

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
