import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/dialogs/interfaces/premium_dialog_interfaces.dart';

/// Animation service for premium logout dialog
///
/// Handles all animation-related functionality following Single Responsibility Principle:
/// - Entrance/exit animations with sophisticated curves
/// - Glow effects for premium feel
/// - Particle system management
/// - Reduced motion accessibility compliance
class PremiumLogoutAnimations implements IPremiumLogoutAnimations {
  AnimationController? _entranceController;
  AnimationController? _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _glowAnimation;

  bool _showParticles = false;
  bool _isDisposed = false;

  @override
  void initializeAnimations({
    required TickerProvider vsync,
    required Duration animationDuration,
  }) {
    _entranceController = AnimationController(
      duration: animationDuration,
      vsync: vsync,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController!,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController!,
      curve: Curves.easeInOut,
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _entranceController!,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void startEntranceAnimation({
    required bool respectReducedMotion,
    required bool disableAnimations,
  }) {
    if (_entranceController == null || _glowController == null) {
      throw StateError('Animations must be initialized before starting');
    }

    if (!respectReducedMotion || !disableAnimations) {
      _entranceController!.forward();
      _glowController!.repeat(reverse: true);
    } else {
      // Skip animations for accessibility
      _entranceController!.value = 1.0;
    }
  }

  @override
  void triggerSuccessParticles() {
    _showParticles = true;

    // Auto-hide particles after animation duration
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isDisposed) {
        _showParticles = false;
      }
    });
  }

  @override
  Future<void> exitWithAnimation({required bool shouldReduceMotion}) async {
    if (_entranceController == null) return;

    if (!shouldReduceMotion) {
      await _entranceController!.reverse();
    }
  }

  @override
  Animation<double> get scaleAnimation {
    if (_entranceController == null) {
      throw StateError('Animations must be initialized first');
    }
    return _scaleAnimation;
  }

  @override
  Animation<double> get fadeAnimation {
    if (_entranceController == null) {
      throw StateError('Animations must be initialized first');
    }
    return _fadeAnimation;
  }

  @override
  Animation<double> get blurAnimation {
    if (_entranceController == null) {
      throw StateError('Animations must be initialized first');
    }
    return _blurAnimation;
  }

  @override
  Animation<double> get glowAnimation {
    if (_glowController == null) {
      throw StateError('Animations must be initialized first');
    }
    return _glowAnimation;
  }

  @override
  bool get showParticles => _showParticles;

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _entranceController?.dispose();
      _glowController?.dispose();
      _entranceController = null;
      _glowController = null;
    }
  }
}

/// Factory for creating animation services with proper lifecycle management
class PremiumLogoutAnimationsFactory {
  /// Create a new animation service instance
  static PremiumLogoutAnimations create() {
    return PremiumLogoutAnimations();
  }

  /// Create and initialize animation service in one step
  static PremiumLogoutAnimations createAndInitialize({
    required TickerProvider vsync,
    required Duration animationDuration,
  }) {
    final animations = PremiumLogoutAnimations();
    animations.initializeAnimations(
      vsync: vsync,
      animationDuration: animationDuration,
    );
    return animations;
  }
}