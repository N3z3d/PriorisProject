import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/particle_models.dart';

/// Widget pour l'effet d'ondulation
/// Respecte SRP : gestion unique de l'animation d'ondulation
class RippleEffectWidget extends StatefulWidget {
  final bool trigger;
  final CelebrationConfig config;
  final VoidCallback? onComplete;

  const RippleEffectWidget({
    super.key,
    required this.trigger,
    required this.config,
    this.onComplete,
  });

  @override
  State<RippleEffectWidget> createState() => _RippleEffectWidgetState();
}

class _RippleEffectWidgetState extends State<RippleEffectWidget>
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
  void didUpdateWidget(RippleEffectWidget oldWidget) {
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
            painter: RipplePainter(
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

/// Painter pour les ondulations
/// Respecte SRP : rendu visuel des ondulations uniquement
class RipplePainter extends CustomPainter {
  final List<Animation<double>> radiusAnimations;
  final List<Animation<double>> opacityAnimations;
  final Color color;

  const RipplePainter(this.radiusAnimations, this.opacityAnimations, this.color);

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
