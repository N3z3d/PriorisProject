/// HEXAGONAL ARCHITECTURE + DDD
/// Habit Tracking Bounded Context
///
/// This bounded context handles everything related to habit lifecycle:
/// - Habit creation, tracking, completion
/// - Streak calculations and analytics
/// - Habit recurrence patterns
/// - Progress monitoring
///
/// BOUNDED CONTEXT BOUNDARIES:
/// - Owns: Habit aggregate, Habit analytics, Streak calculations
/// - Collaborates with: Task Management (habit-task conversion)
/// - External: Notifications, Calendar integration

// === DOMAIN ENTITIES ===
export '../../models/core/entities/habit.dart';

// === AGGREGATES ===
export '../../habit/aggregates/habit_aggregate.dart' hide HabitType, RecurrenceType;

// === DOMAIN SERVICES ===
export '../../habit/services/habit_analytics_service.dart';

// === DOMAIN EVENTS ===
export '../../habit/events/habit_events.dart';

// === SPECIFICATIONS ===
export '../../habit/specifications/habit_specifications.dart';

// === REPOSITORIES (PORTS) ===
export '../../habit/repositories/habit_repository.dart' hide TrendDirection;

/// Habit Tracking Domain Context
///
/// Encapsulates all habit-related domain logic following DDD principles.
/// This context is responsible for:
/// 1. Habit lifecycle and recurrence management
/// 2. Streak calculations and milestone tracking
/// 3. Habit analytics and progress monitoring
/// 4. Habit-task integration for prioritization
class HabitTrackingContext {
  static const String contextName = 'HabitTracking';

  /// Domain events published by this context
  static const List<String> publishedEvents = [
    'HabitCreated',
    'HabitCompleted',
    'HabitSkipped',
    'StreakAchieved',
    'MilestoneReached',
    'HabitArchived',
  ];

  /// Domain events consumed by this context
  static const List<String> consumedEvents = [
    'TaskCompleted',      // From Task Management
    'UserAuthenticated',  // From Authentication
    'CalendarEventCreated', // From External Calendar
  ];

  /// Invariants maintained by this context
  static const List<String> invariants = [
    'Habit must have a valid recurrence pattern',
    'Streak cannot be negative',
    'Completion date must be within habit schedule',
    'Archived habits cannot be modified',
    'Habit name must be unique per user',
  ];

  /// Analytics capabilities
  static const List<String> analytics = [
    'Completion rate calculation',
    'Streak trend analysis',
    'Best performance periods',
    'Habit correlation analysis',
    'Progress predictions',
  ];
}