import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Internal hoverable widget implementation
class HoverableWidget extends StatefulWidget {
  final Widget child;
  final bool enableScaleEffect;
  final bool enableGlowEffect;
  final double scaleFactorHover;
  final Duration duration;
  final Color? glowColor;

  const HoverableWidget({
    super.key,
    required this.child,
    required this.enableScaleEffect,
    required this.enableGlowEffect,
    required this.scaleFactorHover,
    required this.duration,
    this.glowColor,
  });

  @override
  State<HoverableWidget> createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<HoverableWidget>
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
      end: widget.scaleFactorHover,
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
    return MouseRegion(
      onEnter: (_) {
        if (!_shouldReduceMotion()) {
          _controller.forward();
        }
      },
      onExit: (_) {
        if (!_shouldReduceMotion()) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          Widget result = Transform.scale(
            scale: widget.enableScaleEffect && !_shouldReduceMotion()
                ? _scaleAnimation.value
                : 1.0,
            child: widget.child,
          );

          if (widget.enableGlowEffect && !_shouldReduceMotion()) {
            result = Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: (widget.glowColor ?? AppTheme.primaryColor)
                        .withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 15 * _glowAnimation.value,
                    spreadRadius: 3 * _glowAnimation.value,
                  ),
                ],
              ),
              child: result,
            );
          }

          return result;
        },
      ),
    );
  }
}
