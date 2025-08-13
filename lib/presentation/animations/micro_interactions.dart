import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Système de micro-interactions pour améliorer l'UX
class MicroInteractions {
  
  /// Animation de bounce au tap
  static Widget bounceOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scaleFactor = 0.95,
  }) {
    return _BounceAnimation(
      onTap: onTap,
      scaleFactor: scaleFactor,
      child: child,
    );
  }

  /// Animation de pulse continue
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return _PulseAnimation(
      duration: duration,
      minScale: minScale,
      maxScale: maxScale,
      child: child,
    );
  }

  /// Animation de shake pour les erreurs
  static Widget shakeOnError({
    required Widget child,
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    return _ShakeAnimation(
      trigger: trigger,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Animation de success avec check
  static Widget successAnimation({
    required Widget child,
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    return _SuccessAnimation(
      trigger: trigger,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Ripple effect personnalisé
  static Widget rippleEffect({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        splashColor: rippleColor?.withValues(alpha: 0.3),
        highlightColor: rippleColor?.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  /// Animation de slide et fade
  static Widget slideAndFade({
    required Widget child,
    required bool visible,
    Offset slideFrom = const Offset(0, 0.1),
  }) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : slideFrom,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
    );
  }
}

/// Widget de bounce animation
class _BounceAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;

  const _BounceAnimation({
    required this.child,
    required this.onTap,
    required this.scaleFactor,
  });

  @override
  State<_BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<_BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
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

  void _handleTap() async {
    HapticFeedback.lightImpact();
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Widget de pulse animation
class _PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const _PulseAnimation({
    required this.child,
    required this.duration,
    required this.minScale,
    required this.maxScale,
  });

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
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
      begin: widget.minScale,
      end: widget.maxScale,
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
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Widget de shake animation
class _ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final VoidCallback? onComplete;

  const _ShakeAnimation({
    required this.child,
    required this.trigger,
    this.onComplete,
  });

  @override
  State<_ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<_ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void didUpdateWidget(_ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _shake();
    }
  }

  void _shake() async {
    HapticFeedback.mediumImpact();
    await _controller.forward();
    _controller.reset();
    widget.onComplete?.call();
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
        final offset = sin(_animation.value * pi * 4) * 10;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Widget de success animation
class _SuccessAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final VoidCallback? onComplete;

  const _SuccessAnimation({
    required this.child,
    required this.trigger,
    this.onComplete,
  });

  @override
  State<_SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<_SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_SuccessAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _animate();
    }
  }

  void _animate() async {
    HapticFeedback.heavyImpact();
    await _scaleController.forward();
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _scaleController.reverse();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            );
          },
        ),
        if (widget.trigger)
          AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _checkAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}