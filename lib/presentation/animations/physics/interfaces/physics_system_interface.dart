import 'package:flutter/material.dart';

/// Core interface for all physics systems following the Interface Segregation Principle
abstract class IPhysicsSystem {
  /// Unique identifier for the physics system
  String get systemId;

  /// Human-readable name for the physics system
  String get systemName;

  /// Whether the system is currently active/available
  bool get isActive;

  /// Initialize the physics system with required dependencies
  Future<void> initialize();

  /// Clean up resources when system is disposed
  Future<void> dispose();
}

/// Interface for physics systems that can create animated widgets
abstract class IAnimatedPhysicsSystem extends IPhysicsSystem {
  /// Create an animated widget using this physics system
  Widget createAnimation({
    required Widget child,
    required PhysicsAnimationConfig config,
  });
}

/// Interface for physics systems that support real-time calculations
abstract class ICalculatablePhysicsSystem extends IPhysicsSystem {
  /// Calculate physics state at a given time
  PhysicsState calculateState({
    required double time,
    required PhysicsParameters parameters,
  });

  /// Update physics parameters in real-time
  void updateParameters(PhysicsParameters parameters);
}

/// Interface for physics systems that support triggerable animations
abstract class ITriggerablePhysicsSystem extends IPhysicsSystem {
  /// Trigger an animation with specific parameters
  Future<void> trigger({
    required PhysicsAnimationConfig config,
    VoidCallback? onComplete,
  });

  /// Stop current animation
  void stop();

  /// Whether the system is currently animating
  bool get isAnimating;
}

/// Base configuration for all physics animations
abstract class PhysicsAnimationConfig {
  final Duration duration;
  final bool autoStart;
  final VoidCallback? onComplete;

  const PhysicsAnimationConfig({
    required this.duration,
    this.autoStart = false,
    this.onComplete,
  });
}

/// Base physics parameters for calculations
abstract class PhysicsParameters {
  final double mass;
  final double damping;

  const PhysicsParameters({
    required this.mass,
    required this.damping,
  });
}

/// Physics state representing position, velocity, and acceleration
class PhysicsState {
  final Offset position;
  final Offset velocity;
  final Offset acceleration;
  final double rotation;
  final double scale;
  final double time;

  const PhysicsState({
    required this.position,
    required this.velocity,
    required this.acceleration,
    required this.rotation,
    required this.scale,
    required this.time,
  });

  PhysicsState copyWith({
    Offset? position,
    Offset? velocity,
    Offset? acceleration,
    double? rotation,
    double? scale,
    double? time,
  }) {
    return PhysicsState(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      acceleration: acceleration ?? this.acceleration,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      time: time ?? this.time,
    );
  }

  @override
  String toString() {
    return 'PhysicsState(pos: $position, vel: $velocity, acc: $acceleration, '
           'rot: $rotation, scale: $scale, time: $time)';
  }
}

/// Exception thrown by physics systems
class PhysicsSystemException implements Exception {
  final String message;
  final String systemId;
  final Object? cause;

  const PhysicsSystemException(
    this.message,
    this.systemId, [
    this.cause,
  ]);

  @override
  String toString() => 'PhysicsSystemException($systemId): $message';
}