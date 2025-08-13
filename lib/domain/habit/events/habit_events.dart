import 'package:uuid/uuid.dart';
import '../../core/events/domain_event.dart';

/// Événement déclenché lors de la création d'une habitude
class HabitCreatedEvent extends DomainEvent {
  final String habitId;
  final String name;
  final String type; // binary ou quantitative
  final String? category;
  final double? targetValue;

  HabitCreatedEvent({
    required this.habitId,
    required this.name,
    required this.type,
    this.category,
    this.targetValue,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitCreated';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'name': name,
    'type': type,
    'category': category,
    'targetValue': targetValue,
  };
}

/// Événement déclenché lors de l'enregistrement d'une habitude
class HabitCompletedEvent extends DomainEvent {
  final String habitId;
  final String name;
  final DateTime completedDate;
  final dynamic value; // bool pour binaire, double pour quantitatif
  final String type;
  final int currentStreak;
  final bool targetReached;

  HabitCompletedEvent({
    required this.habitId,
    required this.name,
    required this.completedDate,
    required this.value,
    required this.type,
    required this.currentStreak,
    required this.targetReached,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitCompleted';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'name': name,
    'completedDate': completedDate.toIso8601String(),
    'value': value,
    'type': type,
    'currentStreak': currentStreak,
    'targetReached': targetReached,
  };
}

/// Événement déclenché lors d'un milestone de streak
class HabitStreakMilestoneEvent extends DomainEvent {
  final String habitId;
  final String name;
  final int streakLength;
  final String milestoneType;
  final DateTime achievedAt;

  HabitStreakMilestoneEvent({
    required this.habitId,
    required this.name,
    required this.streakLength,
    required this.milestoneType,
    required this.achievedAt,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitStreakMilestone';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'name': name,
    'streakLength': streakLength,
    'milestoneType': milestoneType,
    'achievedAt': achievedAt.toIso8601String(),
  };

  /// Factory pour créer des milestones automatiquement
  factory HabitStreakMilestoneEvent.create({
    required String habitId,
    required String name,
    required int streakLength,
    required DateTime achievedAt,
  }) {
    String milestoneType;
    
    if (streakLength >= 365) {
      milestoneType = 'yearly';
    } else if (streakLength >= 100) {
      milestoneType = 'century';
    } else if (streakLength >= 30) {
      milestoneType = 'monthly';
    } else if (streakLength >= 7) {
      milestoneType = 'weekly';
    } else if (streakLength == 3) {
      milestoneType = 'first_three';
    } else {
      milestoneType = 'custom';
    }

    return HabitStreakMilestoneEvent(
      habitId: habitId,
      name: name,
      streakLength: streakLength,
      milestoneType: milestoneType,
      achievedAt: achievedAt,
    );
  }
}

/// Événement déclenché lors de la rupture d'une série
class HabitStreakBrokenEvent extends DomainEvent {
  final String habitId;
  final String name;
  final int previousStreak;
  final DateTime lastCompletedDate;
  final DateTime missedDate;
  final String reason;

  HabitStreakBrokenEvent({
    required this.habitId,
    required this.name,
    required this.previousStreak,
    required this.lastCompletedDate,
    required this.missedDate,
    this.reason = 'missed_day',
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitStreakBroken';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'name': name,
    'previousStreak': previousStreak,
    'lastCompletedDate': lastCompletedDate.toIso8601String(),
    'missedDate': missedDate.toIso8601String(),
    'reason': reason,
    'impact': _calculateImpact(),
  };

  String _calculateImpact() {
    if (previousStreak >= 100) return 'major';
    if (previousStreak >= 30) return 'significant';
    if (previousStreak >= 7) return 'moderate';
    return 'minor';
  }
}

/// Événement déclenché lors de la modification d'une habitude
class HabitModifiedEvent extends DomainEvent {
  final String habitId;
  final Map<String, dynamic> changes;
  final String? reason;

  HabitModifiedEvent({
    required this.habitId,
    required this.changes,
    this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitModified';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'changes': changes,
    'reason': reason,
    'changedFields': changes.keys.toList(),
  };
}

/// Événement déclenché lors de la suppression d'une habitude
class HabitDeletedEvent extends DomainEvent {
  final String habitId;
  final String name;
  final int finalStreak;
  final int totalCompletions;
  final double successRate;
  final String? reason;

  HabitDeletedEvent({
    required this.habitId,
    required this.name,
    required this.finalStreak,
    required this.totalCompletions,
    required this.successRate,
    this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitDeleted';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'name': name,
    'finalStreak': finalStreak,
    'totalCompletions': totalCompletions,
    'successRate': successRate,
    'reason': reason,
    'performance': _categorizePerformance(),
  };

  String _categorizePerformance() {
    if (successRate >= 0.8) return 'excellent';
    if (successRate >= 0.6) return 'good';
    if (successRate >= 0.4) return 'average';
    return 'poor';
  }
}

/// Événement déclenché lors de l'atteinte d'un objectif quantitatif
class HabitTargetReachedEvent extends DomainEvent {
  final String habitId;
  final String name;
  final double targetValue;
  final double achievedValue;
  final DateTime achievedDate;
  final double overPerformanceRatio;

  HabitTargetReachedEvent({
    required this.habitId,
    required this.name,
    required this.targetValue,
    required this.achievedValue,
    required this.achievedDate,
  }) : overPerformanceRatio = achievedValue / targetValue,
       super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitTargetReached';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'name': name,
    'targetValue': targetValue,
    'achievedValue': achievedValue,
    'achievedDate': achievedDate.toIso8601String(),
    'overPerformanceRatio': overPerformanceRatio,
    'overPerformancePercentage': ((overPerformanceRatio - 1) * 100).round(),
  };
}

/// Événement déclenché pour les rappels d'habitude
class HabitReminderEvent extends DomainEvent {
  final String habitId;
  final String name;
  final String reminderType;
  final DateTime scheduledFor;
  final int daysSinceLastCompletion;

  HabitReminderEvent({
    required this.habitId,
    required this.name,
    required this.reminderType,
    required this.scheduledFor,
    required this.daysSinceLastCompletion,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'HabitReminder';

  @override
  Map<String, dynamic> get payload => {
    'habitId': habitId,
    'name': name,
    'reminderType': reminderType,
    'scheduledFor': scheduledFor.toIso8601String(),
    'daysSinceLastCompletion': daysSinceLastCompletion,
    'urgency': _calculateUrgency(),
  };

  String _calculateUrgency() {
    if (daysSinceLastCompletion >= 3) return 'high';
    if (daysSinceLastCompletion >= 2) return 'medium';
    return 'low';
  }
}