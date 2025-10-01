import 'package:flutter/material.dart';
import '../interfaces/physics_system_interface.dart';

/// Configuration for spring physics animations
class SpringPhysicsConfig extends PhysicsAnimationConfig {
  final double stiffness;
  final double dampingRatio;
  final double mass;
  final double scaleFactor;
  final double rotationFactor;
  final bool trigger;

  const SpringPhysicsConfig({
    required super.duration,
    required this.stiffness,
    required this.dampingRatio,
    this.mass = 1.0,
    this.scaleFactor = 1.2,
    this.rotationFactor = 0.1,
    this.trigger = false,
    super.autoStart,
    super.onComplete,
  });

  SpringPhysicsConfig copyWith({
    Duration? duration,
    double? stiffness,
    double? dampingRatio,
    double? mass,
    double? scaleFactor,
    double? rotationFactor,
    bool? trigger,
    bool? autoStart,
    VoidCallback? onComplete,
  }) {
    return SpringPhysicsConfig(
      duration: duration ?? this.duration,
      stiffness: stiffness ?? this.stiffness,
      dampingRatio: dampingRatio ?? this.dampingRatio,
      mass: mass ?? this.mass,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      rotationFactor: rotationFactor ?? this.rotationFactor,
      trigger: trigger ?? this.trigger,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}

/// Configuration for gravity physics animations
class GravityPhysicsConfig extends PhysicsAnimationConfig {
  final double height;
  final double gravity;
  final double bounceDamping;
  final int bounceCount;
  final double restitution;
  final bool trigger;

  const GravityPhysicsConfig({
    required super.duration,
    required this.height,
    this.gravity = 9.81,
    this.bounceDamping = 0.7,
    this.bounceCount = 3,
    this.restitution = 0.8,
    this.trigger = false,
    super.autoStart,
    super.onComplete,
  });

  GravityPhysicsConfig copyWith({
    Duration? duration,
    double? height,
    double? gravity,
    double? bounceDamping,
    int? bounceCount,
    double? restitution,
    bool? trigger,
    bool? autoStart,
    VoidCallback? onComplete,
  }) {
    return GravityPhysicsConfig(
      duration: duration ?? this.duration,
      height: height ?? this.height,
      gravity: gravity ?? this.gravity,
      bounceDamping: bounceDamping ?? this.bounceDamping,
      bounceCount: bounceCount ?? this.bounceCount,
      restitution: restitution ?? this.restitution,
      trigger: trigger ?? this.trigger,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}

/// Configuration for elastic physics animations
class ElasticPhysicsConfig extends PhysicsAnimationConfig {
  final double bounceHeight;
  final int bounceCount;
  final double elasticity;
  final double tension;
  final bool trigger;

  const ElasticPhysicsConfig({
    required super.duration,
    required this.bounceHeight,
    required this.bounceCount,
    this.elasticity = 0.8,
    this.tension = 100.0,
    this.trigger = false,
    super.autoStart,
    super.onComplete,
  });

  ElasticPhysicsConfig copyWith({
    Duration? duration,
    double? bounceHeight,
    int? bounceCount,
    double? elasticity,
    double? tension,
    bool? trigger,
    bool? autoStart,
    VoidCallback? onComplete,
  }) {
    return ElasticPhysicsConfig(
      duration: duration ?? this.duration,
      bounceHeight: bounceHeight ?? this.bounceHeight,
      bounceCount: bounceCount ?? this.bounceCount,
      elasticity: elasticity ?? this.elasticity,
      tension: tension ?? this.tension,
      trigger: trigger ?? this.trigger,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}

/// Configuration for wave physics animations
class WavePhysicsConfig extends PhysicsAnimationConfig {
  final double amplitude;
  final double frequency;
  final double damping;
  final double phase;
  final WaveType waveType;

  const WavePhysicsConfig({
    required super.duration,
    required this.amplitude,
    required this.frequency,
    this.damping = 0.02,
    this.phase = 0.0,
    this.waveType = WaveType.sine,
    super.autoStart = true,
    super.onComplete,
  });

  WavePhysicsConfig copyWith({
    Duration? duration,
    double? amplitude,
    double? frequency,
    double? damping,
    double? phase,
    WaveType? waveType,
    bool? autoStart,
    VoidCallback? onComplete,
  }) {
    return WavePhysicsConfig(
      duration: duration ?? this.duration,
      amplitude: amplitude ?? this.amplitude,
      frequency: frequency ?? this.frequency,
      damping: damping ?? this.damping,
      phase: phase ?? this.phase,
      waveType: waveType ?? this.waveType,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}

/// Configuration for inertial physics animations
class InertialPhysicsConfig extends PhysicsAnimationConfig {
  final double initialVelocity;
  final double friction;
  final double mass;
  final bool trigger;

  const InertialPhysicsConfig({
    required super.duration,
    required this.initialVelocity,
    this.friction = 0.05,
    this.mass = 1.0,
    this.trigger = false,
    super.autoStart,
    super.onComplete,
  });

  InertialPhysicsConfig copyWith({
    Duration? duration,
    double? initialVelocity,
    double? friction,
    double? mass,
    bool? trigger,
    bool? autoStart,
    VoidCallback? onComplete,
  }) {
    return InertialPhysicsConfig(
      duration: duration ?? this.duration,
      initialVelocity: initialVelocity ?? this.initialVelocity,
      friction: friction ?? this.friction,
      mass: mass ?? this.mass,
      trigger: trigger ?? this.trigger,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}

/// Configuration for pendulum physics animations
class PendulumPhysicsConfig extends PhysicsAnimationConfig {
  final double angle;
  final int cycles;
  final double length;
  final double gravity;

  const PendulumPhysicsConfig({
    required super.duration,
    required this.angle,
    required this.cycles,
    this.length = 1.0,
    this.gravity = 9.81,
    super.autoStart = true,
    super.onComplete,
  });

  PendulumPhysicsConfig copyWith({
    Duration? duration,
    double? angle,
    int? cycles,
    double? length,
    double? gravity,
    bool? autoStart,
    VoidCallback? onComplete,
  }) {
    return PendulumPhysicsConfig(
      duration: duration ?? this.duration,
      angle: angle ?? this.angle,
      cycles: cycles ?? this.cycles,
      length: length ?? this.length,
      gravity: gravity ?? this.gravity,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}

/// Configuration for floating particle animations
class ParticlePhysicsConfig extends PhysicsAnimationConfig {
  final double maxOffset;
  final double randomnessFactor;
  final double airResistance;
  final double turbulence;

  const ParticlePhysicsConfig({
    required super.duration,
    required this.maxOffset,
    this.randomnessFactor = 0.3,
    this.airResistance = 0.01,
    this.turbulence = 0.1,
    super.autoStart = true,
    super.onComplete,
  });

  ParticlePhysicsConfig copyWith({
    Duration? duration,
    double? maxOffset,
    double? randomnessFactor,
    double? airResistance,
    double? turbulence,
    bool? autoStart,
    VoidCallback? onComplete,
  }) {
    return ParticlePhysicsConfig(
      duration: duration ?? this.duration,
      maxOffset: maxOffset ?? this.maxOffset,
      randomnessFactor: randomnessFactor ?? this.randomnessFactor,
      airResistance: airResistance ?? this.airResistance,
      turbulence: turbulence ?? this.turbulence,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}

/// Physics parameters for different systems
class SpringPhysicsParameters extends PhysicsParameters {
  final double stiffness;

  const SpringPhysicsParameters({
    required super.mass,
    required super.damping,
    required this.stiffness,
  });
}

class GravityPhysicsParameters extends PhysicsParameters {
  final double gravity;
  final double restitution;

  const GravityPhysicsParameters({
    required super.mass,
    required super.damping,
    required this.gravity,
    required this.restitution,
  });
}

class WavePhysicsParameters extends PhysicsParameters {
  final double amplitude;
  final double frequency;
  final double phase;

  const WavePhysicsParameters({
    required super.mass,
    required super.damping,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });
}

/// Enumeration for different wave types
enum WaveType {
  sine,
  cosine,
  square,
  triangle,
  sawtooth,
}

/// Enumeration for physics system types
enum PhysicsSystemType {
  spring,
  gravity,
  elastic,
  wave,
  inertial,
  pendulum,
  particle,
}