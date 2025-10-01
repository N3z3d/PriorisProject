/// HEXAGONAL ARCHITECTURE + DOMAIN-DRIVEN DESIGN
/// Complete Architecture Export
///
/// This file provides a centralized export of the entire hexagonal architecture
/// implementation with DDD patterns. Use this for clean imports and architectural
/// overview.

// ========== BOUNDED CONTEXTS ==========
export '../domain/contexts/task_management/task_management_context.dart';
export '../domain/contexts/habit_tracking/habit_tracking_context.dart';
export '../domain/contexts/list_organization/list_organization_context.dart';
export '../domain/contexts/shared/shared_kernel.dart';

// ========== PRIMARY PORTS (Use Cases) ==========
export '../application/ports/primary/task_management_ports.dart';
export '../application/ports/primary/list_organization_ports.dart';

// ========== SECONDARY PORTS (Infrastructure) ==========
export '../application/ports/secondary/persistence_ports.dart';

// ========== APPLICATION SERVICES ==========
export '../application/services/task_management_service.dart';

/// Hexagonal DDD Architecture Overview
///
/// ARCHITECTURE SUMMARY:
///
/// 1. HEXAGONAL STRUCTURE:
///    - Domain (Core): Pure business logic
///    - Ports (Interfaces): Contracts for external communication
///    - Adapters (Implementations): Bridge to external systems
///    - Application Services: Orchestrate use cases
///
/// 2. DDD STRUCTURE:
///    - Bounded Contexts: Task Management, Habit Tracking, List Organization
///    - Shared Kernel: Common domain concepts
///    - Aggregates: Domain object lifecycles
///    - Domain Services: Complex business logic
///    - Domain Events: Context integration
///
/// 3. BENEFITS:
///    ✅ Clean separation of concerns
///    ✅ Testable architecture (easy mocking)
///    ✅ Technology independence
///    ✅ Business logic isolation
///    ✅ Clear context boundaries
///    ✅ Event-driven integration
///
/// 4. IMPLEMENTATION GUIDELINES:
///    - Domain logic must be pure (no external dependencies)
///    - All external access goes through ports
///    - Application services coordinate use cases
///    - Adapters implement port contracts
///    - Context integration via domain events
///
class HexagonalDDDArchitecture {
  static const String version = '1.0.0';
  static const String description = 'Hexagonal Architecture with Domain-Driven Design';

  /// Architecture layers (from inside out)
  static const Map<String, String> layers = {
    'Domain': 'Core business logic and rules',
    'Application': 'Use case orchestration and coordination',
    'Infrastructure': 'External concerns (DB, API, UI)',
  };

  /// Bounded contexts in the system
  static const List<String> boundedContexts = [
    'TaskManagement',
    'HabitTracking',
    'ListOrganization',
    'SharedKernel',
  ];

  /// Port types
  static const Map<String, String> portTypes = {
    'Primary': 'Driving ports (use cases, API)',
    'Secondary': 'Driven ports (persistence, notifications)',
  };

  /// Integration patterns
  static const Map<String, String> integrationPatterns = {
    'DomainEvents': 'Async context communication',
    'SharedKernel': 'Common domain concepts',
    'AnticorruptionLayer': 'External system isolation',
    'ContextMapping': 'Context relationship definitions',
  };

  /// Quality attributes achieved
  static const List<String> qualityAttributes = [
    'Maintainability',
    'Testability',
    'Scalability',
    'Technology Independence',
    'Business Logic Clarity',
    'Separation of Concerns',
  ];
}