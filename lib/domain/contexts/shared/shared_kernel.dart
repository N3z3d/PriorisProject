/// HEXAGONAL ARCHITECTURE + DDD
/// Shared Kernel
///
/// Contains domain concepts that are shared across multiple bounded contexts.
/// This represents the core domain model that all contexts agree upon.
///
/// SHARED CONCEPTS:
/// - Common value objects (Priority, Progress, EloScore)
/// - Shared domain events and event bus
/// - Common specifications and business rules
/// - Cross-cutting domain services
/// - Shared exceptions and error types

// === SHARED VALUE OBJECTS ===
export '../../core/value_objects/export.dart';

// === SHARED DOMAIN EVENTS ===
export '../../core/events/export.dart';

// === SHARED SPECIFICATIONS ===
export '../../core/specifications/export.dart';

// === SHARED AGGREGATE ROOTS ===
export '../../core/aggregates/aggregate_root.dart';
export '../../core/base/aggregate_root_enhanced.dart' hide ConcurrencyException, AndSpecification, OrSpecification, NotSpecification;

// === SHARED DOMAIN SERVICES ===
export '../../core/services/domain_service.dart';

// === SHARED INTERFACES ===
export '../../core/interfaces/repository.dart';

// === SHARED EXCEPTIONS ===
export '../../core/exceptions/domain_exceptions.dart';

/// Shared Kernel Definition
///
/// Defines the common domain model shared across all bounded contexts.
/// Changes to the shared kernel require agreement from all context teams.
class SharedKernel {
  static const String version = '1.0.0';

  /// Core domain concepts shared across all contexts
  static const List<String> sharedConcepts = [
    'Priority',          // Task/Item priority levels
    'Progress',          // Completion tracking
    'EloScore',          // Ranking and prioritization
    'DateRange',         // Time-based operations
    'DomainEvent',       // Event-driven communication
    'AggregateRoot',     // Domain object lifecycle
    'Repository',        // Data access abstraction
  ];

  /// Shared business rules that apply across contexts
  static const List<String> sharedRules = [
    'User authentication required for persistence',
    'Soft delete policy for user data',
    'Event sourcing for audit trail',
    'Optimistic concurrency control',
    'Data validation at domain boundaries',
  ];

  /// Integration contracts between contexts
  static const Map<String, List<String>> integrationContracts = {
    'TaskManagement_ListOrganization': [
      'Task completion updates list item status',
      'List item changes can trigger task updates',
      'Shared priority and progress tracking',
    ],
    'TaskManagement_HabitTracking': [
      'Habits can be converted to tasks for prioritization',
      'Task completion can update habit streaks',
      'Shared ELO scoring system',
    ],
    'ListOrganization_HabitTracking': [
      'Habit lists are special list types',
      'List organization applies to habit collections',
      'Shared filtering and search capabilities',
    ],
  };

  /// Anti-corruption patterns
  static const List<String> antiCorruption = [
    'External API models are translated at boundary',
    'Legacy data structures are adapted via ports',
    'Third-party dependencies are isolated in adapters',
    'Context boundaries are enforced via interfaces',
  ];

  /// Shared kernel stability guarantees
  static const List<String> stabilityGuarantees = [
    'Breaking changes require major version bump',
    'Backward compatibility within major versions',
    'Deprecation warnings before removal',
    'Migration guides for breaking changes',
  ];
}