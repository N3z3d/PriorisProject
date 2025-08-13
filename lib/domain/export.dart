library;

/// Exports principaux de la couche Domain selon l'architecture DDD
/// 
/// Ce fichier centralise tous les exports de la couche domaine
/// pour faciliter leur utilisation dans l'application.

// === CORE ===
// Value Objects
export 'core/value_objects/export.dart';

// Aggregates
export 'core/aggregates/aggregate_root.dart';

// Events
export 'core/events/export.dart';

// Specifications
export 'core/specifications/export.dart';

// Services
export 'core/services/domain_service.dart';

// Interfaces
export 'core/interfaces/repository.dart';

// Exceptions
export 'core/exceptions/domain_exceptions.dart';

// Bounded Contexts
export 'core/bounded_context.dart';

// === TASK BOUNDED CONTEXT ===
// Aggregates
export 'task/aggregates/task_aggregate.dart';

// Services
export 'task/services/task_elo_service.dart';

// Repositories
export 'task/repositories/task_repository.dart';

// Events
export 'task/events/task_events.dart';

// Specifications
export 'task/specifications/task_specifications.dart';

// === HABIT BOUNDED CONTEXT ===
// Aggregates
export 'habit/aggregates/habit_aggregate.dart';

// Services
export 'habit/services/habit_analytics_service.dart' hide TrendDirection;

// Repositories
export 'habit/repositories/habit_repository.dart';

// Events
export 'habit/events/habit_events.dart';

// Specifications
export 'habit/specifications/habit_specifications.dart';

// === LIST BOUNDED CONTEXT ===
// Aggregates
export 'list/aggregates/custom_list_aggregate.dart';

// Value Objects
export 'list/value_objects/list_item.dart';

// Services
export 'list/services/list_optimization_service.dart';

// Repositories
export 'list/repositories/custom_list_repository.dart';

// Events
export 'list/events/list_events.dart';

// Specifications
export 'list/specifications/list_specifications.dart';