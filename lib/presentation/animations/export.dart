/// Export file for the refactored particle effects system
///
/// This file provides access to all particle system components
/// following SOLID principles architecture

// Main API (backward compatible)
export 'particle_effects.dart';

// New SOLID architecture components
export 'particle_effects_coordinator.dart';

// Core interfaces and models
export 'core/particle_system_interface.dart';
export 'core/particle_models.dart';

// Specialized particle systems
export 'systems/confetti_particle_system.dart';
export 'systems/sparkle_particle_system.dart';
export 'systems/fireworks_particle_system.dart';
export 'systems/celebration_particle_system.dart';