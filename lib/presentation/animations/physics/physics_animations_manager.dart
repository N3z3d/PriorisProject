import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'interfaces/physics_system_interface.dart';
import 'configs/physics_configs.dart';
import 'systems/spring_physics_system.dart';
import 'systems/gravity_physics_system.dart';
import 'systems/elastic_physics_system.dart';
import 'systems/wave_physics_system.dart';
import 'systems/inertial_physics_system.dart';
import 'systems/pendulum_physics_system.dart';
import 'systems/particle_physics_system.dart';

/// Main coordinator for all physics animation systems following SOLID principles
///
/// This manager serves as a facade that:
/// - Coordinates different physics systems (Facade Pattern)
/// - Provides lazy loading of systems (Performance)
/// - Maintains backward compatibility with existing API
/// - Follows Single Responsibility: only manages physics systems
class PhysicsAnimationsManager {
  static PhysicsAnimationsManager? _instance;
  static PhysicsAnimationsManager get instance => _instance ??= PhysicsAnimationsManager._();

  PhysicsAnimationsManager._();

  /// Public constructor for testing and direct instantiation
  factory PhysicsAnimationsManager() {
    return instance;
  }

  final Map<PhysicsSystemType, IPhysicsSystem> _systems = {};
  bool _isInitialized = false;

  /// Whether the manager has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all physics systems with lazy loading
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize systems lazily - they'll be created when first needed
      _isInitialized = true;
    } catch (e) {
      throw PhysicsSystemException(
        'Failed to initialize physics manager: $e',
        'physics_manager',
        e,
      );
    }
  }

  /// Get a specific physics system, creating it if needed (Lazy Loading)
  IPhysicsSystem getSystem(PhysicsSystemType type) {
    if (!_isInitialized) {
      throw PhysicsSystemException(
        'PhysicsManager not initialized. Call initialize() first.',
        'physics_manager',
      );
    }

    if (_systems.containsKey(type)) {
      return _systems[type]!;
    }

    // Lazy creation of physics systems
    final system = _createSystem(type);
    _systems[type] = system;

    // Initialize the system asynchronously
    system.initialize().catchError((error) {
      throw PhysicsSystemException(
        'Failed to initialize ${type.name} system: $error',
        type.name,
        error,
      );
    });

    return system;
  }

  /// Check if a physics system is available
  bool isSystemAvailable(PhysicsSystemType type) {
    return _isInitialized;
  }

  /// Factory method for creating physics systems (Factory Pattern)
  IPhysicsSystem _createSystem(PhysicsSystemType type) {
    switch (type) {
      case PhysicsSystemType.spring:
        return SpringPhysicsSystem();
      case PhysicsSystemType.gravity:
        return GravityPhysicsSystem();
      case PhysicsSystemType.elastic:
        return ElasticPhysicsSystem();
      case PhysicsSystemType.wave:
        return WavePhysicsSystem();
      case PhysicsSystemType.inertial:
        return InertialPhysicsSystem();
      case PhysicsSystemType.pendulum:
        return PendulumPhysicsSystem();
      case PhysicsSystemType.particle:
        return ParticlePhysicsSystem();
    }
  }

  /// Dispose all systems and clean up resources
  Future<void> dispose() async {
    for (final system in _systems.values) {
      await system.dispose();
    }
    _systems.clear();
    _isInitialized = false;
  }

  // ============================================================================
  // PUBLIC API METHODS - Maintaining backward compatibility
  // ============================================================================

  /// Create a spring animation widget
  Widget createSpringAnimation({
    required Widget child,
    required SpringPhysicsConfig config,
  }) {
    final system = getSystem(PhysicsSystemType.spring) as IAnimatedPhysicsSystem;
    return system.createAnimation(child: child, config: config);
  }

  /// Create a gravity bounce animation widget
  Widget createGravityAnimation({
    required Widget child,
    required GravityPhysicsConfig config,
  }) {
    final system = getSystem(PhysicsSystemType.gravity) as IAnimatedPhysicsSystem;
    return system.createAnimation(child: child, config: config);
  }

  /// Create an elastic bounce animation widget
  Widget createElasticAnimation({
    required Widget child,
    required ElasticPhysicsConfig config,
  }) {
    final system = getSystem(PhysicsSystemType.elastic) as IAnimatedPhysicsSystem;
    return system.createAnimation(child: child, config: config);
  }

  /// Create a wave animation widget
  Widget createWaveAnimation({
    required Widget child,
    required WavePhysicsConfig config,
  }) {
    final system = getSystem(PhysicsSystemType.wave) as IAnimatedPhysicsSystem;
    return system.createAnimation(child: child, config: config);
  }

  /// Create an inertial rotation animation widget
  Widget createInertialAnimation({
    required Widget child,
    required InertialPhysicsConfig config,
  }) {
    final system = getSystem(PhysicsSystemType.inertial) as IAnimatedPhysicsSystem;
    return system.createAnimation(child: child, config: config);
  }

  /// Create a pendulum animation widget
  Widget createPendulumAnimation({
    required Widget child,
    required PendulumPhysicsConfig config,
  }) {
    final system = getSystem(PhysicsSystemType.pendulum) as IAnimatedPhysicsSystem;
    return system.createAnimation(child: child, config: config);
  }

  /// Create a particle animation widget
  Widget createParticleAnimation({
    required Widget child,
    required ParticlePhysicsConfig config,
  }) {
    final system = getSystem(PhysicsSystemType.particle) as IAnimatedPhysicsSystem;
    return system.createAnimation(child: child, config: config);
  }

  // ============================================================================
  // STATIC BACKWARD COMPATIBILITY METHODS
  // ============================================================================

  /// Static method for spring animation (backward compatibility)
  static Widget springAnimation({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 800),
    double dampingRatio = 0.8,
    double stiffness = 100.0,
    VoidCallback? onComplete,
  }) {
    final config = SpringPhysicsConfig(
      duration: duration,
      dampingRatio: dampingRatio,
      stiffness: stiffness,
      trigger: trigger,
      onComplete: onComplete,
    );

    return instance.createSpringAnimation(child: child, config: config);
  }

  /// Static method for elastic bounce (backward compatibility)
  static Widget elasticBounce({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 1200),
    double bounceHeight = 1.3,
    int bounceCount = 3,
    VoidCallback? onComplete,
  }) {
    final config = ElasticPhysicsConfig(
      duration: duration,
      bounceHeight: bounceHeight,
      bounceCount: bounceCount,
      trigger: trigger,
      onComplete: onComplete,
    );

    return instance.createElasticAnimation(child: child, config: config);
  }

  /// Static method for spring scale (backward compatibility)
  static Widget springScale({
    required Widget child,
    required VoidCallback onTap,
    double scaleFactor = 0.9,
    Duration duration = const Duration(milliseconds: 600),
    Curve springCurve = Curves.elasticOut,
  }) {
    final config = SpringPhysicsConfig(
      duration: duration,
      scaleFactor: scaleFactor,
      stiffness: 100.0,
      dampingRatio: 0.8,
    );

    return _SpringScaleWrapper(
      onTap: onTap,
      springCurve: springCurve,
      child: instance.createSpringAnimation(child: child, config: config),
    );
  }

  /// Static method for inertial rotation (backward compatibility)
  static Widget inertialRotation({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 1500),
    double initialVelocity = 10.0,
    double friction = 0.05,
    VoidCallback? onComplete,
  }) {
    final config = InertialPhysicsConfig(
      duration: duration,
      initialVelocity: initialVelocity,
      friction: friction,
      trigger: trigger,
      onComplete: onComplete,
    );

    return instance.createInertialAnimation(child: child, config: config);
  }

  /// Static method for pendulum (backward compatibility)
  static Widget pendulum({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    double angle = 0.3,
    int cycles = 5,
    bool autoStart = true,
  }) {
    final config = PendulumPhysicsConfig(
      duration: duration,
      angle: angle,
      cycles: cycles,
      autoStart: autoStart,
    );

    return instance.createPendulumAnimation(child: child, config: config);
  }

  /// Static method for gravity bounce (backward compatibility)
  static Widget gravityBounce({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 2000),
    double height = 100.0,
    double bounceDamping = 0.7,
    int bounceCount = 3,
    VoidCallback? onComplete,
  }) {
    final config = GravityPhysicsConfig(
      duration: duration,
      height: height,
      bounceDamping: bounceDamping,
      bounceCount: bounceCount,
      trigger: trigger,
      onComplete: onComplete,
    );

    return instance.createGravityAnimation(child: child, config: config);
  }

  /// Static method for physics wave (backward compatibility)
  static Widget physicsWave({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double amplitude = 15.0,
    double frequency = 2.0,
    double damping = 0.02,
    bool autoStart = true,
  }) {
    final config = WavePhysicsConfig(
      duration: duration,
      amplitude: amplitude,
      frequency: frequency,
      damping: damping,
      autoStart: autoStart,
    );

    return instance.createWaveAnimation(child: child, config: config);
  }

  /// Static method for floating particle (backward compatibility)
  static Widget floatingParticle({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    double maxOffset = 20.0,
    double randomnessFactor = 0.3,
    bool autoStart = true,
  }) {
    final config = ParticlePhysicsConfig(
      duration: duration,
      maxOffset: maxOffset,
      randomnessFactor: randomnessFactor,
      autoStart: autoStart,
    );

    return instance.createParticleAnimation(child: child, config: config);
  }
}

/// Wrapper for spring scale animation to maintain backward compatibility
class _SpringScaleWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Curve springCurve;

  const _SpringScaleWrapper({
    required this.child,
    required this.onTap,
    required this.springCurve,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: child,
    );
  }
}