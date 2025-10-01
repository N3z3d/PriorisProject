/// HEXAGONAL ARCHITECTURE + DDD
/// List Organization Bounded Context
///
/// This bounded context handles everything related to list management:
/// - Custom list creation and organization
/// - List item lifecycle management
/// - List categorization and filtering
/// - List-task integration and synchronization
///
/// BOUNDED CONTEXT BOUNDARIES:
/// - Owns: CustomList aggregate, ListItem entities, Organization logic
/// - Collaborates with: Task Management (list-task sync), Habit Tracking (habit lists)
/// - External: Cloud synchronization, File import/export

// === DOMAIN ENTITIES ===
export '../../models/core/entities/custom_list.dart';
export '../../models/core/entities/list_item.dart';

// === AGGREGATES ===
export '../../list/aggregates/custom_list_aggregate.dart';

// === DOMAIN SERVICES ===
export '../../list/services/list_optimization_service.dart';
export '../../../domain/services/core/lists_filter_service.dart';

// === DOMAIN EVENTS ===
export '../../list/events/list_events.dart';

// === SPECIFICATIONS ===
export '../../list/specifications/list_specifications.dart';

// === REPOSITORIES (PORTS) ===
export '../../list/repositories/custom_list_repository.dart';
export '../../../data/repositories/list_item_repository.dart';

// === VALUE OBJECTS ===
export '../../list/value_objects/list_item.dart' hide ListItem;
export '../../list_management/value_objects/list_value_objects.dart' hide ListStatistics;

/// List Organization Domain Context
///
/// Encapsulates all list-related domain logic following DDD principles.
/// This context is responsible for:
/// 1. List structure and organization
/// 2. List item lifecycle and state transitions
/// 3. Cross-list operations and synchronization
/// 4. List analytics and optimization suggestions
class ListOrganizationContext {
  static const String contextName = 'ListOrganization';

  /// Domain events published by this context
  static const List<String> publishedEvents = [
    'ListCreated',
    'ListUpdated',
    'ListDeleted',
    'ListItemAdded',
    'ListItemCompleted',
    'ListItemMoved',
    'ListSynchronized',
    'ListOptimized',
  ];

  /// Domain events consumed by this context
  static const List<String> consumedEvents = [
    'TaskCreated',        // From Task Management
    'TaskCompleted',      // From Task Management
    'HabitCreated',       // From Habit Tracking
    'UserAuthenticated',  // From Authentication
    'CloudSyncTriggered', // From External Cloud
  ];

  /// Invariants maintained by this context
  static const List<String> invariants = [
    'List must have a non-empty name',
    'List items must belong to exactly one list',
    'Completed lists cannot have new items added',
    'List hierarchy cannot be circular',
    'List names must be unique per user',
  ];

  /// Optimization capabilities
  static const List<String> optimizations = [
    'Auto-categorization of list items',
    'Duplicate detection and merging',
    'Priority reordering suggestions',
    'List consolidation recommendations',
    'Progress tracking and analytics',
  ];

  /// Integration patterns
  static const Map<String, String> integrations = {
    'task_sync': 'Bidirectional sync with Task Management context',
    'habit_lists': 'Special list types for habit tracking',
    'cloud_backup': 'Automatic cloud synchronization',
    'import_export': 'External format support (CSV, JSON, etc.)',
  };
}