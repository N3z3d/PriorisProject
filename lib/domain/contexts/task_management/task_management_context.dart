/// HEXAGONAL ARCHITECTURE + DDD
/// Task Management Bounded Context
///
/// This bounded context handles everything related to task lifecycle:
/// - Task creation, updates, completion
/// - Task prioritization and ELO scoring
/// - Task categorization and organization
///
/// BOUNDED CONTEXT BOUNDARIES:
/// - Owns: Task aggregate, Task domain logic
/// - Collaborates with: List Organization (via domain events)
/// - External: Authentication, Persistence

// === DOMAIN ENTITIES ===
export '../../models/core/entities/task.dart';

// === AGGREGATES ===
export '../../task/aggregates/task_aggregate.dart';

// === DOMAIN SERVICES ===
export '../../task/services/task_elo_service.dart';
export '../../task/services/unified_prioritization_service.dart' hide DuelResult;
export '../../task/services/list_item_task_converter.dart';

// === DOMAIN EVENTS ===
export '../../task/events/task_events.dart';

// === SPECIFICATIONS ===
export '../../task/specifications/task_specifications.dart';

// === REPOSITORIES (PORTS) ===
export '../../task/repositories/task_repository.dart';

/// Task Management Domain Context
///
/// Encapsulates all task-related domain logic following DDD principles.
/// This context is responsible for:
/// 1. Task lifecycle management
/// 2. Task prioritization algorithms
/// 3. Task-list relationships
/// 4. Task domain events and rules
class TaskManagementContext {
  static const String contextName = 'TaskManagement';

  /// Domain events published by this context
  static const List<String> publishedEvents = [
    'TaskCreated',
    'TaskCompleted',
    'TaskUpdated',
    'TaskDeleted',
    'TaskPrioritized',
    'EloScoreUpdated',
  ];

  /// Domain events consumed by this context
  static const List<String> consumedEvents = [
    'ListItemCreated',    // From List Organization
    'ListItemCompleted',  // From List Organization
    'UserAuthenticated',  // From Authentication
  ];

  /// Invariants maintained by this context
  static const List<String> invariants = [
    'Task must have a non-empty title',
    'Task ELO score must be between 800-2000',
    'Completed tasks cannot be modified',
    'Task due date cannot be in the past',
  ];
}