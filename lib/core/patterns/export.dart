/// Design Patterns Export File
///
/// This file exports all implemented design patterns in the Prioris application.
/// Each pattern is implemented with comprehensive tests, documentation, and examples.

// CREATIONAL PATTERNS
export 'creational/factory_method.dart';
export 'creational/abstract_factory.dart';
export 'creational/builder.dart';
export 'creational/prototype.dart';
// Note: Singleton pattern already exists in DI Container (dependency_injection_container.dart)

// STRUCTURAL PATTERNS
export 'structural/adapter.dart';
export 'structural/composite.dart';
// Note: Flyweight pattern already exists in caching system

// BEHAVIORAL PATTERNS
export 'behavioral/observer.dart';

// ARCHITECTURAL PATTERNS
export 'architectural/event_driven.dart';
// Note: Circuit Breaker pattern already exists in error handling system

// ADDITIONAL PATTERNS (Legacy - maintained for backward compatibility)
export 'factory_pattern.dart';
export 'observer_pattern.dart' hide EventStore;
export 'strategy_pattern.dart';
export 'cqrs_pattern.dart';
export 'liskov_substitution_pattern.dart';