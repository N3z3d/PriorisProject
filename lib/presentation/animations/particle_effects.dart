import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Système d'effets de particules pour les célébrations
class ParticleEffects {
  /// Effet de confettis pour les tâches importantes accomplies
  static Widget confettiExplosion({
    required bool trigger,
    int particleCount = 50,
    Duration duration = const Duration(seconds: 3),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _ConfettiExplosion(
      trigger: trigger,
      particleCount: particleCount,
      duration: duration,
      colors: colors ?? _defaultConfettiColors,
      onComplete: onComplete,
    );
  }

  /// Effet d'étoiles scintillantes pour les streaks d'habitudes
  static Widget sparkleEffect({
    required bool trigger,
    int sparkleCount = 20,
    Duration duration = const Duration(seconds: 2),
    double maxSize = 8.0,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _SparkleEffect(
      trigger: trigger,
      sparkleCount: sparkleCount,
      duration: duration,
      maxSize: maxSize,
      colors: colors ?? _defaultSparkleColors,
      onComplete: onComplete,
    );
  }

  /// Feux d'artifice pour les accomplissements majeurs
  static Widget fireworksEffect({
    required bool trigger,
    int fireworkCount = 5,
    Duration duration = const Duration(seconds: 4),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _FireworksEffect(
      trigger: trigger,
      fireworkCount: fireworkCount,
      duration: duration,
      colors: colors ?? _defaultFireworkColors,
      onComplete: onComplete,
    );
  }

  /// Effet de pluie de particules douces
  static Widget gentleParticleRain({
    required bool trigger,
    int particleCount = 30,
    Duration duration = const Duration(seconds: 5),
    double fallSpeed = 1.0,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _GentleParticleRain(
      trigger: trigger,
      particleCount: particleCount,
      duration: duration,
      fallSpeed: fallSpeed,
      colors: colors ?? _defaultGentleColors,
      onComplete: onComplete,
    );
  }

  /// Effet de cercles concentriques expansifs
  static Widget rippleEffect({
    required bool trigger,
    int rippleCount = 3,
    Duration duration = const Duration(milliseconds: 1500),
    double maxRadius = 100.0,
    Color color = Colors.blue,
    VoidCallback? onComplete,
  }) {
    return _RippleEffect(
      trigger: trigger,
      rippleCount: rippleCount,
      duration: duration,
      maxRadius: maxRadius,
      color: color,
      onComplete: onComplete,
    );
  }

  /// Effet de coeur flottant pour les favoris
  static Widget floatingHearts({
    required bool trigger,
    int heartCount = 8,
    Duration duration = const Duration(seconds: 3),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _FloatingHearts(
      trigger: trigger,
      heartCount: heartCount,
      duration: duration,
      colors: colors ?? _defaultHeartColors,
      onComplete: onComplete,
    );
  }

  /// Couleurs par défaut pour les différents effets
  static const List<Color> _defaultConfettiColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  static const List<Color> _defaultSparkleColors = [
    Colors.white,
    Colors.yellow,
    Colors.amber,
    Colors.lightBlue,
  ];

  static const List<Color> _defaultFireworkColors = [
    Colors.red,
    Colors.blue,
    Colors.white,
    Colors.yellow,
    Colors.purple,
  ];

  static const List<Color> _defaultGentleColors = [
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.pink,
    Colors.amber,
  ];

  static const List<Color> _defaultHeartColors = [
    Colors.pink,
    Colors.red,
    Colors.purple,
    Colors.pinkAccent,
  ];
}

/// Classe représentant une particule
class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;
  double rotation;
  double rotationSpeed;
  double life;
  double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.opacity = 1.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    required this.life,
    required this.maxLife,
  });

  void update(double dt) {
    position += velocity * dt;
    rotation += rotationSpeed * dt;
    life -= dt;
    opacity = (life / maxLife).clamp(0.0, 1.0);
  }

  bool get isDead => life <= 0;
}

/// Widget d'explosion de confettis
class _ConfettiExplosion extends StatefulWidget {
  final bool trigger;
  final int particleCount;
  final Duration duration;
  final List<Color> colors;
  final VoidCallback? onComplete;

  const _ConfettiExplosion({
    required this.trigger,
    required this.particleCount,
    required this.duration,
    required this.colors,
    this.onComplete,
  });

  @override
  State<_ConfettiExplosion> createState() => _ConfettiExplosionState();
}

class _ConfettiExplosionState extends State<_ConfettiExplosion>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
        _updateParticles();
      });
  }

  @override
  void didUpdateWidget(_ConfettiExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startExplosion();
    }
  }

  void _startExplosion() {
    HapticFeedback.heavyImpact();
    particles.clear();
    
    // Créer les particules
    for (int i = 0; i < widget.particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 200 + 100;
      final size = _random.nextDouble() * 8 + 4;
      
      particles.add(Particle(
        position: const Offset(200, 200), // Centre de l'écran
        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed - 50, // Légère tendance vers le haut
        ),
        size: size,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        life: widget.duration.inMilliseconds / 1000.0,
        maxLife: widget.duration.inMilliseconds / 1000.0,
      ));
    }
    
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  void _updateParticles() {
    if (!mounted) return;
    
    const dt = 1.0 / 60.0; // 60 FPS
    for (var particle in particles) {
      particle.update(dt);
      // Appliquer la gravité
      particle.velocity = Offset(
        particle.velocity.dx * 0.98, // Friction horizontale
        particle.velocity.dy + 200 * dt, // Gravité
      );
    }
    particles.removeWhere((p) => p.isDead);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _ParticlePainter(particles),
      ),
    );
  }
}

/// Widget d'effet d'étoiles scintillantes
class _SparkleEffect extends StatefulWidget {
  final bool trigger;
  final int sparkleCount;
  final Duration duration;
  final double maxSize;
  final List<Color> colors;
  final VoidCallback? onComplete;

  const _SparkleEffect({
    required this.trigger,
    required this.sparkleCount,
    required this.duration,
    required this.maxSize,
    required this.colors,
    this.onComplete,
  });

  @override
  State<_SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<_SparkleEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
        _updateSparkles();
      });
  }

  @override
  void didUpdateWidget(_SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startSparkle();
    }
  }

  void _startSparkle() {
    HapticFeedback.lightImpact();
    sparkles.clear();
    
    // Créer les sparkles
    for (int i = 0; i < widget.sparkleCount; i++) {
      sparkles.add(Particle(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 400,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 50,
          (_random.nextDouble() - 0.5) * 50,
        ),
        size: _random.nextDouble() * widget.maxSize + 2,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        rotationSpeed: (_random.nextDouble() - 0.5) * 5,
        life: widget.duration.inMilliseconds / 1000.0,
        maxLife: widget.duration.inMilliseconds / 1000.0,
      ));
    }
    
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  void _updateSparkles() {
    if (!mounted) return;
    
    const dt = 1.0 / 60.0;
    for (var sparkle in sparkles) {
      sparkle.update(dt);
      // Effet de scintillement
      sparkle.opacity = (sin(sparkle.life * 10) + 1) / 2 * (sparkle.life / sparkle.maxLife);
    }
    sparkles.removeWhere((s) => s.isDead);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _SparklePainter(sparkles),
      ),
    );
  }
}

/// Widget d'effet de feux d'artifice
class _FireworksEffect extends StatefulWidget {
  final bool trigger;
  final int fireworkCount;
  final Duration duration;
  final List<Color> colors;
  final VoidCallback? onComplete;

  const _FireworksEffect({
    required this.trigger,
    required this.fireworkCount,
    required this.duration,
    required this.colors,
    this.onComplete,
  });

  @override
  State<_FireworksEffect> createState() => _FireworksEffectState();
}

class _FireworksEffectState extends State<_FireworksEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<List<Particle>> fireworks = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
        _updateFireworks();
      });
  }

  @override
  void didUpdateWidget(_FireworksEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startFireworks();
    }
  }

  void _startFireworks() {
    HapticFeedback.heavyImpact();
    fireworks.clear();
    
    // Créer plusieurs feux d'artifice
    for (int f = 0; f < widget.fireworkCount; f++) {
      List<Particle> firework = [];
      final center = Offset(
        _random.nextDouble() * 300 + 50,
        _random.nextDouble() * 200 + 100,
      );
      final color = widget.colors[_random.nextInt(widget.colors.length)];
      
      // Créer les particules pour ce feu d'artifice
      for (int i = 0; i < 20; i++) {
        final angle = (i / 20) * 2 * pi;
        final speed = _random.nextDouble() * 100 + 50;
        
        firework.add(Particle(
          position: center,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          size: _random.nextDouble() * 4 + 2,
          color: color,
          life: widget.duration.inMilliseconds / 1000.0,
          maxLife: widget.duration.inMilliseconds / 1000.0,
        ));
      }
      fireworks.add(firework);
    }
    
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  void _updateFireworks() {
    if (!mounted) return;
    
    const dt = 1.0 / 60.0;
    for (var firework in fireworks) {
      for (var particle in firework) {
        particle.update(dt);
        // Appliquer friction
        particle.velocity = particle.velocity * 0.99;
      }
      firework.removeWhere((p) => p.isDead);
    }
    fireworks.removeWhere((f) => f.isEmpty);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _FireworksPainter(fireworks),
      ),
    );
  }
}

/// Widget d'effet de pluie de particules douces
class _GentleParticleRain extends StatefulWidget {
  final bool trigger;
  final int particleCount;
  final Duration duration;
  final double fallSpeed;
  final List<Color> colors;
  final VoidCallback? onComplete;

  const _GentleParticleRain({
    required this.trigger,
    required this.particleCount,
    required this.duration,
    required this.fallSpeed,
    required this.colors,
    this.onComplete,
  });

  @override
  State<_GentleParticleRain> createState() => _GentleParticleRainState();
}

class _GentleParticleRainState extends State<_GentleParticleRain>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
        _updateRain();
      });
  }

  @override
  void didUpdateWidget(_GentleParticleRain oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startRain();
    }
  }

  void _startRain() {
    HapticFeedback.lightImpact();
    particles.clear();
    
    // Créer les particules
    for (int i = 0; i < widget.particleCount; i++) {
      particles.add(Particle(
        position: Offset(
          _random.nextDouble() * 400,
          -_random.nextDouble() * 100,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 20,
          _random.nextDouble() * 50 + 30 * widget.fallSpeed,
        ),
        size: _random.nextDouble() * 6 + 2,
        color: widget.colors[_random.nextInt(widget.colors.length)]
            .withValues(alpha: 0.7),
        life: widget.duration.inMilliseconds / 1000.0,
        maxLife: widget.duration.inMilliseconds / 1000.0,
      ));
    }
    
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  void _updateRain() {
    if (!mounted) return;
    
    const dt = 1.0 / 60.0;
    for (var particle in particles) {
      particle.update(dt);
    }
    particles.removeWhere((p) => p.isDead || p.position.dy > 600);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _ParticlePainter(particles),
      ),
    );
  }
}

/// Widget d'effet d'ondulation
class _RippleEffect extends StatefulWidget {
  final bool trigger;
  final int rippleCount;
  final Duration duration;
  final double maxRadius;
  final Color color;
  final VoidCallback? onComplete;

  const _RippleEffect({
    required this.trigger,
    required this.rippleCount,
    required this.duration,
    required this.maxRadius,
    required this.color,
    this.onComplete,
  });

  @override
  State<_RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<_RippleEffect>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _radiusAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _radiusAnimations = [];
    _opacityAnimations = [];

    for (int i = 0; i < widget.rippleCount; i++) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      
      final radiusAnimation = Tween<double>(
        begin: 0,
        end: widget.maxRadius,
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
  void didUpdateWidget(_RippleEffect oldWidget) {
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
      widget.duration + Duration(milliseconds: (_controllers.length - 1) * 200),
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
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _RipplePainter(_radiusAnimations, _opacityAnimations, widget.color),
      ),
    );
  }
}

/// Widget d'effet de coeurs flottants
class _FloatingHearts extends StatefulWidget {
  final bool trigger;
  final int heartCount;
  final Duration duration;
  final List<Color> colors;
  final VoidCallback? onComplete;

  const _FloatingHearts({
    required this.trigger,
    required this.heartCount,
    required this.duration,
    required this.colors,
    this.onComplete,
  });

  @override
  State<_FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<_FloatingHearts>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> hearts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
        _updateHearts();
      });
  }

  @override
  void didUpdateWidget(_FloatingHearts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startHearts();
    }
  }

  void _startHearts() {
    HapticFeedback.lightImpact();
    hearts.clear();
    
    for (int i = 0; i < widget.heartCount; i++) {
      hearts.add(Particle(
        position: Offset(
          _random.nextDouble() * 300 + 50,
          400 + _random.nextDouble() * 100,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 30,
          -_random.nextDouble() * 50 - 30,
        ),
        size: _random.nextDouble() * 20 + 15,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        life: widget.duration.inMilliseconds / 1000.0,
        maxLife: widget.duration.inMilliseconds / 1000.0,
      ));
    }
    
    _controller.forward(from: 0).then((_) {
      widget.onComplete?.call();
    });
  }

  void _updateHearts() {
    if (!mounted) return;
    
    const dt = 1.0 / 60.0;
    for (var heart in hearts) {
      heart.update(dt);
      // Mouvement sinusoïdal horizontal
      heart.velocity = Offset(
        sin(heart.life * 5) * 20,
        heart.velocity.dy * 0.99,
      );
    }
    hearts.removeWhere((h) => h.isDead);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _HeartPainter(hearts),
      ),
    );
  }
}

/// Painter pour les particules génériques
class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour les sparkles
class _SparklePainter extends CustomPainter {
  final List<Particle> sparkles;

  _SparklePainter(this.sparkles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var sparkle in sparkles) {
      final paint = Paint()
        ..color = sparkle.color.withValues(alpha: sparkle.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(sparkle.position.dx, sparkle.position.dy);
      canvas.rotate(sparkle.rotation);

      // Dessiner une étoile
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = (i * pi / 2);
        final x = cos(angle) * sparkle.size;
        final y = sin(angle) * sparkle.size;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour les feux d'artifice
class _FireworksPainter extends CustomPainter {
  final List<List<Particle>> fireworks;

  _FireworksPainter(this.fireworks);

  @override
  void paint(Canvas canvas, Size size) {
    for (var firework in fireworks) {
      for (var particle in firework) {
        final paint = Paint()
          ..color = particle.color.withValues(alpha: particle.opacity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          particle.position,
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour les ondulations
class _RipplePainter extends CustomPainter {
  final List<Animation<double>> radiusAnimations;
  final List<Animation<double>> opacityAnimations;
  final Color color;

  _RipplePainter(this.radiusAnimations, this.opacityAnimations, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < radiusAnimations.length; i++) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacityAnimations[i].value)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        center,
        radiusAnimations[i].value,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour les coeurs
class _HeartPainter extends CustomPainter {
  final List<Particle> hearts;

  _HeartPainter(this.hearts);

  @override
  void paint(Canvas canvas, Size size) {
    for (var heart in hearts) {
      final paint = Paint()
        ..color = heart.color.withValues(alpha: heart.opacity)
        ..style = PaintingStyle.fill;

      // Dessiner un coeur simplifié
      final path = Path();
      final x = heart.position.dx;
      final y = heart.position.dy;
      final s = heart.size / 20; // Scale factor

      path.moveTo(x, y + 5 * s);
      path.cubicTo(x, y, x - 10 * s, y - 5 * s, x - 10 * s, y);
      path.cubicTo(x - 10 * s, y + 5 * s, x, y + 10 * s, x, y + 15 * s);
      path.cubicTo(x, y + 10 * s, x + 10 * s, y + 5 * s, x + 10 * s, y);
      path.cubicTo(x + 10 * s, y - 5 * s, x, y, x, y + 5 * s);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}