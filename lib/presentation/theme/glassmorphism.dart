import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Système de glassmorphisme pour un design moderne
class Glassmorphism {
  
  /// Widget de carte avec effet de verre
  static Widget glassCard({
    required Widget child,
    double blur = 10.0,
    double opacity = 0.1,
    Color color = Colors.white,
    BorderRadius? borderRadius,
    Border? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacity),
              borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
              border: border ?? Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: boxShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Fond avec effet de flou
  static Widget blurredBackground({
    required Widget child,
    required Widget background,
    double blur = 20.0,
  }) {
    return Stack(
      children: [
        background,
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ),
        child,
      ],
    );
  }

  /// Modal dialog avec effet de glassmorphisme
  static Widget glassModal({
    required Widget child,
    double blur = 15.0,
    double opacity = 0.05,
    Color backgroundColor = Colors.black,
    double backgroundOpacity = 0.5,
    bool barrierDismissible = true,
    VoidCallback? onDismiss,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: barrierDismissible ? onDismiss : null,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: backgroundColor.withValues(alpha: backgroundOpacity),
          ),
        ),
        Center(
          child: glassCard(
            child: child,
            blur: blur,
            opacity: opacity,
            padding: const EdgeInsets.all(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom sheet avec effet de glassmorphisme
  static Widget glassBottomSheet({
    required Widget child,
    double blur = 12.0,
    double opacity = 0.08,
    double height = 400,
    bool enableDragHandle = true,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadiusTokens.radiusTopLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadiusTokens.radiusTopLg,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                if (enableDragHandle)
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadiusTokens.radiusXs,
                    ),
                  ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menu déroulant avec effet de glassmorphisme
  static Widget glassDropdown({
    required Widget child,
    double blur = 8.0,
    double opacity = 0.1,
    double? width,
    double? height,
    Alignment alignment = Alignment.topLeft,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: width ?? 200,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadiusTokens.radiusSm,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                borderRadius: BorderRadiusTokens.radiusSm,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Toast notification avec effet de glassmorphisme
  static Widget glassToast({
    required Widget child,
    double blur = 6.0,
    double opacity = 0.12,
    ToastPosition position = ToastPosition.top,
  }) {
    return Positioned(
      top: position == ToastPosition.top ? 80 : null,
      bottom: position == ToastPosition.bottom ? 80 : null,
      left: 16,
      right: 16,
      child: glassCard(
        child: child,
        blur: blur,
        opacity: opacity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  /// Effet de morphisme professionnel avec couleur unie
  static Widget professionalMorphism({
    required Widget child,
    Color? backgroundColor,
    double blur = 15.0,
    double opacity = 0.15,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
            borderRadius: borderRadius ?? BorderRadiusTokens.radiusXl,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /// Bouton avec effet de verre
  static Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color color = Colors.white,
    double blur = 10.0,
    double opacity = 0.2,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return _GlassButton(
      onPressed: onPressed,
      color: color,
      blur: blur,
      opacity: opacity,
      padding: padding,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Surface avec effet de reflet professionnel
  static Widget professionalReflectiveSurface({
    required Widget child,
    double reflectionOpacity = 0.08,
    Color? reflectionColor,
    BorderRadius? borderRadius,
  }) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 40, // Fixed height instead of full gradient
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius != null 
                ? BorderRadius.only(
                    topLeft: borderRadius.topLeft,
                    topRight: borderRadius.topRight,
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
              color: (reflectionColor ?? Colors.white).withValues(alpha: reflectionOpacity),
            ),
          ),
        ),
      ],
    );
  }
}

/// Énumération pour position des toasts
enum ToastPosition {
  top,
  bottom,
}

/// Widget de bouton avec effet de verre
class _GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const _GlassButton({
    required this.child,
    required this.onPressed,
    required this.color,
    required this.blur,
    required this.opacity,
    this.padding,
    this.borderRadius,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity * 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadiusTokens.radiusMd,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: _opacityAnimation.value),
                    borderRadius: widget.borderRadius ?? BorderRadiusTokens.radiusMd,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animations fluides prédéfinies
class FluidAnimations {
  
  /// Animation de vague
  static Widget wave({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double amplitude = 10.0,
  }) {
    return _WaveAnimation(
      duration: duration,
      amplitude: amplitude,
      child: child,
    );
  }

  /// Animation de flottement
  static Widget float({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    double offset = 10.0,
  }) {
    return _FloatAnimation(
      duration: duration,
      offset: offset,
      child: child,
    );
  }

  /// Animation de rotation douce
  static Widget gentleRotation({
    required Widget child,
    Duration duration = const Duration(seconds: 10),
    double angle = 0.05,
  }) {
    return _GentleRotationAnimation(
      duration: duration,
      angle: angle,
      child: child,
    );
  }
}

/// Widget d'animation de vague
class _WaveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;

  const _WaveAnimation({
    required this.child,
    required this.duration,
    required this.amplitude,
  });

  @override
  State<_WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<_WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            sin(_animation.value) * widget.amplitude,
            0,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Widget d'animation de flottement
class _FloatAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const _FloatAnimation({
    required this.child,
    required this.duration,
    required this.offset,
  });

  @override
  State<_FloatAnimation> createState() => _FloatAnimationState();
}

class _FloatAnimationState extends State<_FloatAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            sin(_animation.value) * widget.offset,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Widget d'animation de rotation douce
class _GentleRotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double angle;

  const _GentleRotationAnimation({
    required this.child,
    required this.duration,
    required this.angle,
  });

  @override
  State<_GentleRotationAnimation> createState() => _GentleRotationAnimationState();
}

class _GentleRotationAnimationState extends State<_GentleRotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: -widget.angle,
      end: widget.angle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}