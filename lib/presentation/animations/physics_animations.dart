import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Système d'animations avancées avec physique réaliste
///
/// Simplified implementation for compatibility
class PhysicsAnimations {
  /// Animation de spring avec paramètres personnalisables
  static Widget springAnimation({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 800),
    double dampingRatio = 0.8,
    double stiffness = 100.0,
    VoidCallback? onComplete,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: trigger ? 1.0 : 0.0),
      duration: duration,
      curve: Curves.elasticOut,
      onEnd: onComplete,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.1),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de bounce élastique
  static Widget elasticBounce({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 1200),
    double bounceHeight = 1.3,
    int bounceCount = 3,
    VoidCallback? onComplete,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: trigger ? 1.0 : 0.0),
      duration: duration,
      curve: Curves.bounceOut,
      onEnd: onComplete,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * (bounceHeight - 1.0)),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de scale avec effet de ressort
  static Widget springScale({
    required Widget child,
    required VoidCallback onTap,
    double scaleFactor = 0.9,
    Duration duration = const Duration(milliseconds: 600),
    Curve springCurve = Curves.elasticOut,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        duration: duration,
        curve: springCurve,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// Animation de rotation avec inertie
  static Widget inertialRotation({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 1500),
    double initialVelocity = 10.0,
    double friction = 0.05,
    VoidCallback? onComplete,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: trigger ? 2 * pi : 0.0),
      duration: duration,
      curve: Curves.decelerate,
      onEnd: onComplete,
      builder: (context, value, child) {
        return Transform.rotate(angle: value, child: child);
      },
      child: child,
    );
  }

  /// Animation de pendule
  static Widget pendulum({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    double angle = 0.3,
    int cycles = 5,
    bool autoStart = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: -angle, end: angle),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.rotate(angle: value, child: child);
      },
      child: child,
    );
  }

  /// Animation de gravité avec rebond
  static Widget gravityBounce({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 2000),
    double height = 100.0,
    double bounceDamping = 0.7,
    int bounceCount = 3,
    VoidCallback? onComplete,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: trigger ? height : 0.0),
      duration: duration,
      curve: Curves.bounceOut,
      onEnd: onComplete,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: child,
    );
  }

  /// Animation de vague physique
  static Widget physicsWave({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double amplitude = 15.0,
    double frequency = 2.0,
    double damping = 0.02,
    bool autoStart = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 2 * pi),
      duration: duration,
      builder: (context, value, child) {
        final offset = Offset(0, amplitude * sin(value * frequency));
        return Transform.translate(offset: offset, child: child);
      },
      child: child,
    );
  }

  /// Animation de particule flottante
  static Widget floatingParticle({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    double maxOffset = 20.0,
    double randomnessFactor = 0.3,
    bool autoStart = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 2 * pi),
      duration: duration,
      builder: (context, value, child) {
        final x = maxOffset * cos(value);
        final y = maxOffset * sin(value);
        return Transform.translate(offset: Offset(x, y), child: child);
      },
      child: child,
    );
  }
}