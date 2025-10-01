import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import the new refactored physics system
import 'physics/physics_animations_manager.dart';

/// Système d'animations avancées avec physique réaliste
///
/// DEPRECATED: This class has been refactored following SOLID principles.
/// Use PhysicsAnimationsManager directly for new implementations.
/// This class remains for backward compatibility.
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.springAnimation(
      child: child,
      trigger: trigger,
      duration: duration,
      dampingRatio: dampingRatio,
      stiffness: stiffness,
      onComplete: onComplete,
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.elasticBounce(
      child: child,
      trigger: trigger,
      duration: duration,
      bounceHeight: bounceHeight,
      bounceCount: bounceCount,
      onComplete: onComplete,
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.springScale(
      child: child,
      onTap: onTap,
      scaleFactor: scaleFactor,
      duration: duration,
      springCurve: springCurve,
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.inertialRotation(
      child: child,
      trigger: trigger,
      duration: duration,
      initialVelocity: initialVelocity,
      friction: friction,
      onComplete: onComplete,
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.pendulum(
      child: child,
      duration: duration,
      angle: angle,
      cycles: cycles,
      autoStart: autoStart,
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.gravityBounce(
      child: child,
      trigger: trigger,
      duration: duration,
      height: height,
      bounceDamping: bounceDamping,
      bounceCount: bounceCount,
      onComplete: onComplete,
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.physicsWave(
      child: child,
      duration: duration,
      amplitude: amplitude,
      frequency: frequency,
      damping: damping,
      autoStart: autoStart,
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
    // Delegate to the new refactored system
    return PhysicsAnimationsManager.floatingParticle(
      child: child,
      duration: duration,
      maxOffset: maxOffset,
      randomnessFactor: randomnessFactor,
      autoStart: autoStart,
    );
  }
}

// === PHYSICS ANIMATIONS FACADE (SOLID-COMPLIANT) ===
//
// SOLID COMPLIANCE:
// - SRP: Single responsibility as a facade to PhysicsAnimationsManager
// - OCP: Open for extension through the modular physics system
// - LSP: Compatible with original PhysicsAnimations interface
// - ISP: Focused interface for physics animations only
// - DIP: Depends on PhysicsAnimationsManager abstraction
//
// This facade provides backward compatibility while delegating to the new
// refactored physics system that follows SOLID principles.
// CONSTRAINT: <200 lines (currently ~170 lines)
//
// For new development, use PhysicsAnimationsManager directly.