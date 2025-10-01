/// Modern Physics Animation System - Refactored with SOLID Principles
///
/// This library provides a comprehensive physics animation system that has been
/// refactored from a 830-line monolithic class into focused, single-responsibility
/// physics systems following SOLID principles.
///
/// ## Available Physics Systems:
/// - **SpringPhysicsSystem**: Realistic spring dynamics with damped harmonic oscillators
/// - **GravityPhysicsSystem**: Gravity-based animations with realistic bouncing
/// - **ElasticPhysicsSystem**: Elastic deformation with material properties
/// - **WavePhysicsSystem**: Wave-based animations (sine, cosine, square, triangle, sawtooth)
/// - **InertialPhysicsSystem**: Rotational dynamics with friction
/// - **PendulumPhysicsSystem**: Pendulum motion with realistic physics
/// - **ParticlePhysicsSystem**: Floating particle motion with turbulence
///
/// ## Usage Examples:
///
/// ### Using the Manager (Recommended):
/// ```dart
/// // Get manager instance
/// final manager = PhysicsAnimationsManager();
/// await manager.initialize();
///
/// // Create spring animation
/// final springConfig = SpringPhysicsConfig(
///   duration: Duration(milliseconds: 800),
///   stiffness: 100.0,
///   dampingRatio: 0.8,
/// );
///
/// Widget springWidget = manager.createSpringAnimation(
///   child: YourWidget(),
///   config: springConfig,
/// );
/// ```
///
/// ### Using Individual Systems:
/// ```dart
/// final springSystem = SpringPhysicsSystem();
/// await springSystem.initialize();
///
/// final config = SpringPhysicsConfig(
///   duration: Duration(milliseconds: 800),
///   stiffness: 100.0,
///   dampingRatio: 0.8,
/// );
///
/// Widget springWidget = springSystem.createAnimation(
///   child: YourWidget(),
///   config: config,
/// );
/// ```
///
/// ### Static Methods (Backward Compatible):
/// ```dart
/// Widget springWidget = PhysicsAnimationsManager.springAnimation(
///   child: YourWidget(),
///   trigger: true,
///   duration: Duration(milliseconds: 800),
///   dampingRatio: 0.8,
///   stiffness: 100.0,
/// );
/// ```
///
/// ## Physics Accuracy:
/// - **Realistic Physics**: All systems implement accurate physics equations
/// - **Spring Dynamics**: Hooke's Law, damped harmonic oscillators
/// - **Gravity Simulation**: Kinematic equations, coefficient of restitution
/// - **Wave Functions**: Sinusoidal motion with damping and phase relationships
/// - **Material Properties**: Elastic modulus, stress-strain relationships
///
/// ## Performance Benefits:
/// - **Lazy Loading**: Physics systems created only when needed
/// - **Modular Architecture**: Load only required physics systems
/// - **Memory Efficient**: Proper resource management and disposal
/// - **Testable**: Each system can be tested independently
///
// Export the complete physics system
export 'physics/export.dart';

// For backward compatibility, also export the legacy wrapper
export 'physics_animations.dart' show PhysicsAnimations;