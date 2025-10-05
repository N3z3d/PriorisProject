import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/buttons/models/fab_animation_config.dart';

/// Mixin for managing FAB animations lifecycle
///
/// SRP: Single responsibility - manages animation controllers and their lifecycle
/// DIP: Depends on abstractions (AnimationController) not concrete implementations
mixin FABAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController scaleController;
  late AnimationController shimmerController;
  late AnimationController glowController;
  late Animation<double> scaleAnimation;
  late Animation<double> shimmerAnimation;
  late Animation<double> glowAnimation;
  late Animation<Offset> shimmerOffset;

  FABAnimationConfig get animationConfig => FABAnimationConfig.defaults();

  /// Override to check if animations are enabled
  bool get enableAnimations;

  /// Override to check if button is pressed (for shimmer scheduling)
  bool get isButtonPressed;

  /// Initialize all animation controllers and animations
  void initializeAnimations() {
    _initScaleAnimation();
    _initShimmerAnimation();
    _initGlowAnimation();

    if (enableAnimations) {
      startIdleAnimations();
    }
  }

  void _initScaleAnimation() {
    scaleController = AnimationController(
      duration: animationConfig.scaleDuration,
      vsync: this,
    );
    scaleAnimation = Tween<double>(
      begin: animationConfig.scaleBegin,
      end: animationConfig.scaleEnd,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: animationConfig.scaleCurve,
    ));
  }

  void _initShimmerAnimation() {
    shimmerController = AnimationController(
      duration: animationConfig.shimmerDuration,
      vsync: this,
    );
    shimmerAnimation = Tween<double>(
      begin: animationConfig.shimmerBegin,
      end: animationConfig.shimmerEnd,
    ).animate(CurvedAnimation(
      parent: shimmerController,
      curve: animationConfig.shimmerCurve,
    ));
    shimmerOffset = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: shimmerController,
      curve: animationConfig.shimmerCurve,
    ));
  }

  void _initGlowAnimation() {
    glowController = AnimationController(
      duration: animationConfig.glowDuration,
      vsync: this,
    );
    glowAnimation = Tween<double>(
      begin: animationConfig.glowBegin,
      end: animationConfig.glowEnd,
    ).animate(CurvedAnimation(
      parent: glowController,
      curve: animationConfig.glowCurve,
    ));
  }

  /// Start idle animations (glow loop and periodic shimmer)
  void startIdleAnimations() {
    if (!mounted) return;

    if (!glowController.isAnimating) {
      glowController.repeat(reverse: true);
    }

    _scheduleShimmerEffect();
  }

  void _scheduleShimmerEffect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || isButtonPressed) return;

      try {
        shimmerController.forward().then((_) {
          if (!mounted) return;
          shimmerController.reset();
          Future.delayed(const Duration(seconds: 8), () {
            if (mounted) startIdleAnimations();
          });
        });
      } catch (e) {
        // Controller disposed, ignore
      }
    });
  }

  /// Stop all animations safely
  void stopAnimations() {
    try {
      if (glowController.isAnimating) glowController.stop();
      if (shimmerController.isAnimating) shimmerController.stop();
      if (scaleController.isAnimating) scaleController.stop();
    } catch (e) {
      // Already disposed, ignore
    }
  }

  /// Dispose all animation controllers
  void disposeAnimations() {
    stopAnimations();
    scaleController.dispose();
    shimmerController.dispose();
    glowController.dispose();
  }
}
