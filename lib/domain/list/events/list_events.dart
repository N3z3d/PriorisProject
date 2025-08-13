import 'package:uuid/uuid.dart';
import '../../core/events/domain_event.dart';

/// Événement déclenché lors de la création d'une liste
class ListCreatedEvent extends DomainEvent {
  final String listId;
  final String name;
  final String type;
  final String? description;

  ListCreatedEvent({
    required this.listId,
    required this.name,
    required this.type,
    this.description,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListCreated';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'name': name,
    'type': type,
    'description': description,
  };
}

/// Événement déclenché lors de l'ajout d'un élément à une liste
class ListItemAddedEvent extends DomainEvent {
  final String listId;
  final String itemId;
  final String itemName;
  final String? category;
  final double initialElo;

  ListItemAddedEvent({
    required this.listId,
    required this.itemId,
    required this.itemName,
    this.category,
    required this.initialElo,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListItemAdded';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'itemId': itemId,
    'itemName': itemName,
    'category': category,
    'initialElo': initialElo,
  };
}

/// Événement déclenché lors de la complétion d'un élément de liste
class ListItemCompletedEvent extends DomainEvent {
  final String listId;
  final String itemId;
  final String itemName;
  final double eloScore;
  final DateTime completedAt;

  ListItemCompletedEvent({
    required this.listId,
    required this.itemId,
    required this.itemName,
    required this.eloScore,
    required this.completedAt,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListItemCompleted';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'itemId': itemId,
    'itemName': itemName,
    'eloScore': eloScore,
    'completedAt': completedAt.toIso8601String(),
  };
}

/// Événement déclenché lors de la complétion complète d'une liste
class ListCompletedEvent extends DomainEvent {
  final String listId;
  final String listName;
  final int totalItems;
  final DateTime completedAt;
  final Duration timeTaken;
  final double averageElo;

  ListCompletedEvent({
    required this.listId,
    required this.listName,
    required this.totalItems,
    required this.completedAt,
    required this.timeTaken,
    required this.averageElo,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListCompleted';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'listName': listName,
    'totalItems': totalItems,
    'completedAt': completedAt.toIso8601String(),
    'timeTakenDays': timeTaken.inDays,
    'timeTakenHours': timeTaken.inHours,
    'averageElo': averageElo,
    'performance': _calculatePerformance(),
  };

  String _calculatePerformance() {
    if (averageElo >= 1400) return 'excellent';
    if (averageElo >= 1300) return 'good';
    if (averageElo >= 1200) return 'average';
    return 'below_average';
  }
}

/// Événement déclenché lors de la modification d'une liste
class ListModifiedEvent extends DomainEvent {
  final String listId;
  final Map<String, dynamic> changes;
  final String? reason;

  ListModifiedEvent({
    required this.listId,
    required this.changes,
    this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListModified';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'changes': changes,
    'reason': reason,
    'changedFields': changes.keys.toList(),
  };
}

/// Événement déclenché lors de la suppression d'un élément de liste
class ListItemRemovedEvent extends DomainEvent {
  final String listId;
  final String itemId;
  final String itemName;
  final bool wasCompleted;
  final double eloScore;
  final String? reason;

  ListItemRemovedEvent({
    required this.listId,
    required this.itemId,
    required this.itemName,
    required this.wasCompleted,
    required this.eloScore,
    this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListItemRemoved';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'itemId': itemId,
    'itemName': itemName,
    'wasCompleted': wasCompleted,
    'eloScore': eloScore,
    'reason': reason,
  };
}

/// Événement déclenché lors de la suppression d'une liste
class ListDeletedEvent extends DomainEvent {
  final String listId;
  final String name;
  final int totalItems;
  final int completedItems;
  final double completionRate;
  final String? reason;

  ListDeletedEvent({
    required this.listId,
    required this.name,
    required this.totalItems,
    required this.completedItems,
    required this.completionRate,
    this.reason,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListDeleted';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'name': name,
    'totalItems': totalItems,
    'completedItems': completedItems,
    'completionRate': completionRate,
    'reason': reason,
  };
}

/// Événement déclenché lors du milestone de progression d'une liste
class ListProgressMilestoneEvent extends DomainEvent {
  final String listId;
  final String listName;
  final int completedItems;
  final int totalItems;
  final double progressPercentage;
  final String milestoneType;

  ListProgressMilestoneEvent({
    required this.listId,
    required this.listName,
    required this.completedItems,
    required this.totalItems,
    required this.progressPercentage,
    required this.milestoneType,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListProgressMilestone';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'listName': listName,
    'completedItems': completedItems,
    'totalItems': totalItems,
    'progressPercentage': progressPercentage,
    'milestoneType': milestoneType,
  };

  /// Factory pour créer des milestones automatiquement
  factory ListProgressMilestoneEvent.create({
    required String listId,
    required String listName,
    required int completedItems,
    required int totalItems,
  }) {
    final progressPercentage = totalItems > 0 ? (completedItems / totalItems) * 100 : 0;
    
    String milestoneType;
    if (progressPercentage >= 100) {
      milestoneType = 'completed';
    } else if (progressPercentage >= 75) {
      milestoneType = 'three_quarters';
    } else if (progressPercentage >= 50) {
      milestoneType = 'halfway';
    } else if (progressPercentage >= 25) {
      milestoneType = 'quarter';
    } else if (completedItems == 1) {
      milestoneType = 'first_item';
    } else {
      milestoneType = 'progress';
    }

    return ListProgressMilestoneEvent(
      listId: listId,
      listName: listName,
      completedItems: completedItems,
      totalItems: totalItems,
      progressPercentage: progressPercentage.toDouble(),
      milestoneType: milestoneType,
    );
  }
}

/// Événement déclenché lors d'un duel entre éléments de liste
class ListItemDuelEvent extends DomainEvent {
  final String listId;
  final String winnerItemId;
  final String loserItemId;
  final double winnerNewElo;
  final double loserNewElo;
  final double eloChange;

  ListItemDuelEvent({
    required this.listId,
    required this.winnerItemId,
    required this.loserItemId,
    required this.winnerNewElo,
    required this.loserNewElo,
    required this.eloChange,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListItemDuel';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'winnerItemId': winnerItemId,
    'loserItemId': loserItemId,
    'winnerNewElo': winnerNewElo,
    'loserNewElo': loserNewElo,
    'eloChange': eloChange,
  };
}

/// Événement déclenché lors de la réorganisation d'une liste
class ListReorganizedEvent extends DomainEvent {
  final String listId;
  final String reorganizationType;
  final Map<String, dynamic> reorganizationData;

  ListReorganizedEvent({
    required this.listId,
    required this.reorganizationType,
    required this.reorganizationData,
  }) : super(
         eventId: const Uuid().v4(),
         occurredAt: DateTime.now(),
       );

  @override
  String get eventName => 'ListReorganized';

  @override
  Map<String, dynamic> get payload => {
    'listId': listId,
    'reorganizationType': reorganizationType,
    'reorganizationData': reorganizationData,
  };
}