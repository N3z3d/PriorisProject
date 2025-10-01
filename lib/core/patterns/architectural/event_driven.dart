/// Event-Driven Architecture Pattern Implementation
///
/// Purpose: Promote loose coupling between components through events,
/// enabling scalable, maintainable, and reactive systems.

/// Base event interface
abstract class DomainEvent {
  String get eventId;
  String get eventType;
  DateTime get timestamp;
  Map<String, dynamic> get payload;
  String? get aggregateId;
}

/// Concrete domain events
class TaskCreatedEvent implements DomainEvent {
  @override
  final String eventId;
  @override
  final DateTime timestamp;
  @override
  final String? aggregateId;

  final String taskId;
  final String title;
  final String? description;

  TaskCreatedEvent({
    required this.taskId,
    required this.title,
    this.description,
    String? eventId,
    DateTime? timestamp,
  }) : eventId = eventId ?? _generateEventId(),
       timestamp = timestamp ?? DateTime.now(),
       aggregateId = taskId;

  @override
  String get eventType => 'task.created';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'title': title,
    'description': description,
  };

  static String _generateEventId() =>
      'evt_${DateTime.now().microsecondsSinceEpoch}';
}

class TaskCompletedEvent implements DomainEvent {
  @override
  final String eventId;
  @override
  final DateTime timestamp;
  @override
  final String? aggregateId;

  final String taskId;
  final DateTime completedAt;
  final double? score;

  TaskCompletedEvent({
    required this.taskId,
    required this.completedAt,
    this.score,
    String? eventId,
    DateTime? timestamp,
  }) : eventId = eventId ?? _generateEventId(),
       timestamp = timestamp ?? DateTime.now(),
       aggregateId = taskId;

  @override
  String get eventType => 'task.completed';

  @override
  Map<String, dynamic> get payload => {
    'taskId': taskId,
    'completedAt': completedAt.toIso8601String(),
    'score': score,
  };

  static String _generateEventId() =>
      'evt_${DateTime.now().microsecondsSinceEpoch}';
}

/// Event handler interface
abstract class EventHandler<T extends DomainEvent> {
  Future<void> handle(T event);
  bool canHandle(DomainEvent event);
}

/// Event bus interface
abstract class EventBus {
  void publish(DomainEvent event);
  void subscribe<T extends DomainEvent>(EventHandler<T> handler);
  void unsubscribe<T extends DomainEvent>(EventHandler<T> handler);
  Future<void> publishAndWait(DomainEvent event);
}

/// In-memory event bus implementation
class InMemoryEventBus implements EventBus {
  final Map<Type, List<EventHandler>> _handlers = {};
  final List<DomainEvent> _eventHistory = [];

  @override
  void publish(DomainEvent event) {
    _eventHistory.add(event);
    _notifyHandlers(event);
  }

  @override
  Future<void> publishAndWait(DomainEvent event) async {
    _eventHistory.add(event);
    await _notifyHandlersAsync(event);
  }

  @override
  void subscribe<T extends DomainEvent>(EventHandler<T> handler) {
    final type = T;
    if (!_handlers.containsKey(type)) {
      _handlers[type] = [];
    }
    _handlers[type]!.add(handler);
  }

  @override
  void unsubscribe<T extends DomainEvent>(EventHandler<T> handler) {
    final type = T;
    _handlers[type]?.remove(handler);
  }

  void _notifyHandlers(DomainEvent event) {
    for (final handlerList in _handlers.values) {
      for (final handler in handlerList) {
        if (handler.canHandle(event)) {
          try {
            handler.handle(event);
          } catch (e) {
            print('Error in event handler: $e');
          }
        }
      }
    }
  }

  Future<void> _notifyHandlersAsync(DomainEvent event) async {
    final futures = <Future>[];

    for (final handlerList in _handlers.values) {
      for (final handler in handlerList) {
        if (handler.canHandle(event)) {
          futures.add(handler.handle(event));
        }
      }
    }

    await Future.wait(futures);
  }

  /// Get event history
  List<DomainEvent> getEventHistory() => List.unmodifiable(_eventHistory);

  /// Clear event history
  void clearHistory() => _eventHistory.clear();

  /// Get handler count
  int getHandlerCount() {
    return _handlers.values.fold(0, (sum, list) => sum + list.length);
  }
}

/// Concrete event handlers
class TaskNotificationHandler implements EventHandler<TaskCreatedEvent> {
  final List<String> notifications = [];

  @override
  Future<void> handle(TaskCreatedEvent event) async {
    final message = 'New task created: ${event.title}';
    notifications.add(message);
    // In real implementation: send push notification, email, etc.
  }

  @override
  bool canHandle(DomainEvent event) => event is TaskCreatedEvent;
}

class TaskAnalyticsHandler implements EventHandler<DomainEvent> {
  final Map<String, int> _eventCounts = {};
  final List<DomainEvent> _processedEvents = [];

  @override
  Future<void> handle(DomainEvent event) async {
    _eventCounts[event.eventType] = (_eventCounts[event.eventType] ?? 0) + 1;
    _processedEvents.add(event);
    // In real implementation: send to analytics service
  }

  @override
  bool canHandle(DomainEvent event) => true; // Handle all events

  Map<String, int> getEventCounts() => Map.from(_eventCounts);
  List<DomainEvent> getProcessedEvents() => List.unmodifiable(_processedEvents);
}

/// Event-driven task service
class EventDrivenTaskService {
  final EventBus _eventBus;
  final Map<String, Map<String, dynamic>> _tasks = {};

  EventDrivenTaskService(this._eventBus);

  /// Create a task and publish event
  Future<void> createTask({
    required String id,
    required String title,
    String? description,
  }) async {
    _tasks[id] = {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': false,
      'createdAt': DateTime.now(),
    };

    final event = TaskCreatedEvent(
      taskId: id,
      title: title,
      description: description,
    );

    await _eventBus.publishAndWait(event);
  }

  /// Complete a task and publish event
  Future<void> completeTask(String id, {double? score}) async {
    if (!_tasks.containsKey(id)) return;

    final completedAt = DateTime.now();
    _tasks[id]!['isCompleted'] = true;
    _tasks[id]!['completedAt'] = completedAt;

    final event = TaskCompletedEvent(
      taskId: id,
      completedAt: completedAt,
      score: score,
    );

    await _eventBus.publishAndWait(event);
  }

  /// Get task
  Map<String, dynamic>? getTask(String id) => _tasks[id];

  /// Get all tasks
  Map<String, Map<String, dynamic>> getAllTasks() => Map.from(_tasks);
}

/// Event sourcing store (simplified)
class EventStore {
  final List<DomainEvent> _events = [];
  final Map<String, List<DomainEvent>> _aggregateEvents = {};

  /// Store an event
  void store(DomainEvent event) {
    _events.add(event);

    if (event.aggregateId != null) {
      final aggregateId = event.aggregateId!;
      if (!_aggregateEvents.containsKey(aggregateId)) {
        _aggregateEvents[aggregateId] = [];
      }
      _aggregateEvents[aggregateId]!.add(event);
    }
  }

  /// Get all events
  List<DomainEvent> getAllEvents() => List.unmodifiable(_events);

  /// Get events for specific aggregate
  List<DomainEvent> getEventsForAggregate(String aggregateId) {
    return List.unmodifiable(_aggregateEvents[aggregateId] ?? []);
  }

  /// Get events by type
  List<T> getEventsByType<T extends DomainEvent>() {
    return _events.whereType<T>().toList();
  }
}