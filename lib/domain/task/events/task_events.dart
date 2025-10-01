import 'package:uuid/uuid.dart';
import '../../core/events/domain_event.dart';

/// Événement déclenché lors de la création d'une tâche
class TaskCreatedEvent extends DomainEvent {
  final String taskId;
  final String title;
  final String? category;
  final double initialEloScore;

  TaskCreatedEvent({
    required this.taskId,
    required this.title,
    this.category,
    required this.initialEloScore,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TaskCreated';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'title': title,
    'category': category,
    'initialEloScore': initialEloScore,
  };
}

/// Événement déclenché lors de la complétion d'une tâche
class TaskCompletedEvent extends DomainEvent {
  final String taskId;
  final String title;
  final double eloScore;
  final DateTime completedAt;
  final String? category;
  final Duration? completionTime;

  TaskCompletedEvent({
    required this.taskId,
    required this.title,
    required this.eloScore,
    required this.completedAt,
    this.category,
    this.completionTime,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TaskCompleted';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'title': title,
    'eloScore': eloScore,
    'completedAt': completedAt.toIso8601String(),
    'category': category,
    'completionTimeMinutes': completionTime?.inMinutes,
  };
}

/// Événement déclenché lors de la modification du score ELO d'une tâche
class TaskEloUpdatedEvent extends DomainEvent {
  final String taskId;
  final double previousElo;
  final double newElo;
  final String reason;

  TaskEloUpdatedEvent({
    required this.taskId,
    required this.previousElo,
    required this.newElo,
    required this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TaskEloUpdated';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'previousElo': previousElo,
    'newElo': newElo,
    'reason': reason,
    'eloChange': newElo - previousElo,
  };
}

/// Événement déclenché lors d'un duel entre tâches
class TaskDuelCompletedEvent extends DomainEvent {
  final String winnerTaskId;
  final String loserTaskId;
  final double winnerPreviousElo;
  final double winnerNewElo;
  final double loserPreviousElo;
  final double loserNewElo;
  final String duelContext;

  TaskDuelCompletedEvent({
    required this.winnerTaskId,
    required this.loserTaskId,
    required this.winnerPreviousElo,
    required this.winnerNewElo,
    required this.loserPreviousElo,
    required this.loserNewElo,
    this.duelContext = 'manual',
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TaskDuelCompleted';

  @override
  Map<String, dynamic> get payload => {
    'winnerTaskId': winnerTaskId,
    'loserTaskId': loserTaskId,
    'winnerEloChange': winnerNewElo - winnerPreviousElo,
    'loserEloChange': loserNewElo - loserPreviousElo,
    'duelContext': duelContext,
    'eloScores': {
      'winner': {'previous': winnerPreviousElo, 'new': winnerNewElo},
      'loser': {'previous': loserPreviousElo, 'new': loserNewElo},
    },
  };
}

/// Événement déclenché lors de la modification d'une tâche
class TaskModifiedEvent extends DomainEvent {
  final String taskId;
  final Map<String, dynamic> changes;
  final String? reason;

  TaskModifiedEvent({
    required this.taskId,
    required this.changes,
    this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TaskModified';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'changes': changes,
    'reason': reason,
    'changedFields': changes.keys.toList(),
  };
}

/// Événement déclenché lors de la suppression d'une tâche
class TaskDeletedEvent extends DomainEvent {
  final String taskId;
  final String title;
  final bool wasCompleted;
  final double finalEloScore;
  final String? reason;

  TaskDeletedEvent({
    required this.taskId,
    required this.title,
    required this.wasCompleted,
    required this.finalEloScore,
    this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TaskDeleted';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'title': title,
    'wasCompleted': wasCompleted,
    'finalEloScore': finalEloScore,
    'reason': reason,
  };
}

/// Événement déclenché lors du dépassement d'une échéance
class TaskOverdueEvent extends DomainEvent {
  final String taskId;
  final String title;
  final DateTime dueDate;
  final int daysPastDue;
  final double eloScore;

  TaskOverdueEvent({
    required this.taskId,
    required this.title,
    required this.dueDate,
    required this.daysPastDue,
    required this.eloScore,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TaskOverdue';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'daysPastDue': daysPastDue,
    'eloScore': eloScore,
    'severity': _calculateSeverity(),
  };

  String _calculateSeverity() {
    if (daysPastDue >= 7) return 'high';
    if (daysPastDue >= 3) return 'medium';
    return 'low';
  }
}

/// Événement déclenché lors de la suppression en masse de tâches
class TasksBulkDeletedEvent extends DomainEvent {
  final int deletedCount;
  final String deleteType;

  TasksBulkDeletedEvent({
    required this.deletedCount,
    required this.deleteType,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TasksBulkDeleted';

  @override
  Map<String, dynamic> get payload => {
    'deletedCount': deletedCount,
    'deleteType': deleteType,
  };
}

/// Événement déclenché lors de la réinitialisation des scores ELO
class TasksEloResetEvent extends DomainEvent {
  final int taskCount;

  TasksEloResetEvent({
    required this.taskCount,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'TasksEloReset';

  @override
  Map<String, dynamic> get payload => {
    'taskCount': taskCount,
  };
}