import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Premium Micro-Interactions System
///
/// Features:
/// - Subtle hover effects with spring animations
/// - Haptic feedback integration
/// - Accessibility-aware animations
/// - Premium scaling and glow effects
/// - Performance-optimized with reduced motion support
class PremiumMicroInteractions {
  /// Creates a pressable widget with premium micro-interactions
  static Widget pressable({
    required Widget child,
    required VoidCallback onPressed,
    bool enableHaptics = true,
    bool enableScaleEffect = true,
    bool enableGlowEffect = false,
    double scaleFactor = 0.97,
    Duration duration = const Duration(milliseconds: 150),
    Color? glowColor,
  }) {
    return _PressableWidget(
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      enableScaleEffect: enableScaleEffect,
      enableGlowEffect: enableGlowEffect,
      scaleFactor: scaleFactor,
      duration: duration,
      glowColor: glowColor,
      child: child,
    );
  }

  /// Creates a hoverable widget with premium hover effects
  static Widget hoverable({
    required Widget child,
    bool enableScaleEffect = true,
    bool enableGlowEffect = false,
    double scaleFactorHover = 1.03,
    Duration duration = const Duration(milliseconds: 200),
    Color? glowColor,
  }) {
    return _HoverableWidget(
      enableScaleEffect: enableScaleEffect,
      enableGlowEffect: enableGlowEffect,
      scaleFactorHover: scaleFactorHover,
      duration: duration,
      glowColor: glowColor,
      child: child,
    );
  }

  /// Creates a shimmer loading effect for premium placeholders
  static Widget shimmer({
    required Widget child,
    bool enabled = true,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!enabled) return child;

    return _ShimmerWidget(
      baseColor: baseColor ?? AppTheme.grey200,
      highlightColor: highlightColor ?? AppTheme.grey100,
      duration: duration,
      child: child,
    );
  }

  /// Creates a bounce animation for success feedback
  static Widget bounce({
    required Widget child,
    bool trigger = false,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return _BounceWidget(
      trigger: trigger,
      duration: duration,
      child: child,
    );
  }

  /// Creates a staggered entrance animation for lists
  static Widget staggeredEntrance({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return _StaggeredEntranceWidget(
      index: index,
      delay: delay,
      duration: duration,
      child: child,
    );
  }
}

// Internal pressable widget implementation
class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool enableHaptics;
  final bool enableScaleEffect;
  final bool enableGlowEffect;
  final double scaleFactor;
  final Duration duration;
  final Color? glowColor;

  const _PressableWidget({
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
  State<_PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<_PressableWidget>
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
      onTapDown: (_) {
        if (widget.enableScaleEffect && !_shouldReduceMotion()) {
          _controller.forward();
        }
        if (widget.enableHaptics) {
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        if (widget.enableScaleEffect && !_shouldReduceMotion()) {
          _controller.reverse();
        }
        widget.onPressed();
      },
      onTapCancel: () {
        if (widget.enableScaleEffect && !_shouldReduceMotion()) {
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
        },
      ),
    );
  }
}

// Internal hoverable widget implementation
class _HoverableWidget extends StatefulWidget {
  final Widget child;
  final bool enableScaleEffect;
  final bool enableGlowEffect;
  final double scaleFactorHover;
  final Duration duration;
  final Color? glowColor;

  const _HoverableWidget({
    required this.child,
    required this.enableScaleEffect,
    required this.enableGlowEffect,
    required this.scaleFactorHover,
    required this.duration,
    this.glowColor,
  });

  @override
  State<_HoverableWidget> createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<_HoverableWidget>
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

// Internal shimmer widget implementation
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const _ShimmerWidget({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.3, 0.4],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              tileMode: TileMode.clamp,
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

// Internal bounce widget implementation
class _BounceWidget extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;

  const _BounceWidget({
    required this.child,
    required this.trigger,
    required this.duration,
  });

  @override
  State<_BounceWidget> createState() => _BounceWidgetState();
}

class _BounceWidgetState extends State<_BounceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(_BounceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Internal staggered entrance widget implementation
class _StaggeredEntranceWidget extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const _StaggeredEntranceWidget({
    required this.child,
    required this.index,
    required this.delay,
    required this.duration,
  });

  @override
  State<_StaggeredEntranceWidget> createState() => _StaggeredEntranceWidgetState();
}

class _StaggeredEntranceWidgetState extends State<_StaggeredEntranceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}