import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Internal pressable widget implementation
class PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool enableHaptics;
  final bool enableScaleEffect;
  final bool enableGlowEffect;
  final double scaleFactor;
  final Duration duration;
  final Color? glowColor;

  const PressableWidget({
    super.key,
    required this.child,
    required this.onPressed,
    required this.enableHaptics,
    required this.enableScaleEffect,
    required this.enableGlowEffect,
    required this.scaleFactor,
    required this.duration,
    this.glowColor,
  });

  @override
  State<PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<PressableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _shouldReduceMotion() {
    return MediaQuery.maybeOf(context)?.disableAnimations == true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => _buildAnimatedChild(),
      ),
    );
  }

  void _handleTapDown() {
    if (widget.enableScaleEffect && !_shouldReduceMotion()) {
      _controller.forward();
    }
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp() {
    if (widget.enableScaleEffect && !_shouldReduceMotion()) {
      _controller.reverse();
    }
    widget.onPressed();
  }

  void _handleTapCancel() {
    if (widget.enableScaleEffect && !_shouldReduceMotion()) {
      _controller.reverse();
    }
  }

  Widget _buildAnimatedChild() {
    final scale = widget.enableScaleEffect && !_shouldReduceMotion()
        ? _scaleAnimation.value
        : 1.0;

    Widget result = Transform.scale(
      scale: scale,
      child: widget.child,
    );

    if (widget.enableGlowEffect && !_shouldReduceMotion()) {
      result = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (widget.glowColor ?? AppTheme.primaryColor)
                  .withOpacity(0.3 * _glowAnimation.value),
              blurRadius: 20 * _glowAnimation.value,
              spreadRadius: 5 * _glowAnimation.value,
            ),
          ],
        ),
        child: result,
      );
    }

    return result;
  }
}

