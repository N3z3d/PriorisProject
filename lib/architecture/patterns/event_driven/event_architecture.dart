/// Event-Driven Architecture Implementation
///
/// Architectural pattern based on the production and consumption of events
/// to enable loose coupling between system components.

import 'dart:async';

/// Base Event class
abstract class DomainEvent {
  final String id;
  final DateTime occurredAt;
  final String eventType;
  final Map<String, dynamic> metadata;

  DomainEvent({
    required this.id,
    required this.eventType,
    DateTime? occurredAt,
    Map<String, dynamic>? metadata,
  })  : occurredAt = occurredAt ?? DateTime.now(),
        metadata = metadata ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventType': eventType,
        'occurredAt': occurredAt.toIso8601String(),
        'metadata': metadata,
      };
}

/// Event Handler interface
abstract class EventHandler<T extends DomainEvent> {
  Future<void> handle(T event);
  String get handlerName;
  bool canHandle(DomainEvent event) => event is T;
}

/// Event Bus - Central event distribution system
class EventBus {
  static EventBus? _instance;
  static EventBus get instance {
    _instance ??= EventBus._();
    return _instance!;
  }

  EventBus._();

  final Map<Type, List<EventHandler>> _handlers = {};
  final List<DomainEvent> _eventHistory = [];
  final StreamController<DomainEvent> _eventStream = StreamController.broadcast();

  /// Register an event handler
  void register<T extends DomainEvent>(EventHandler<T> handler) {
    _handlers.putIfAbsent(T, () => []).add(handler);
  }

  /// Unregister an event handler
  void unregister<T extends DomainEvent>(EventHandler<T> handler) {
    _handlers[T]?.remove(handler);
    if (_handlers[T]?.isEmpty == true) {
      _handlers.remove(T);
    }
  }

  /// Publish an event
  Future<void> publish(DomainEvent event) async {
    // Add to history
    _eventHistory.add(event);

    // Add to stream
    _eventStream.add(event);

    // Find and execute handlers
    final handlers = _handlers[event.runtimeType] ?? [];
    final futures = handlers
        .where((handler) => handler.canHandle(event))
        .map((handler) => _handleEvent(handler, event));

    await Future.wait(futures);
  }

  Future<void> _handleEvent(EventHandler handler, DomainEvent event) async {
    try {
      await handler.handle(event);
    } catch (e) {
      // Log error but don't stop other handlers
      print('Error in event handler ${handler.handlerName}: $e');
    }
  }

  /// Get event stream for real-time listening
  Stream<DomainEvent> get eventStream => _eventStream.stream;

  /// Get event history
  List<DomainEvent> getEventHistory({
    String? eventType,
    DateTime? since,
    int? limit,
  }) {
    var events = _eventHistory.where((event) {
      if (eventType != null && event.eventType != eventType) return false;
      if (since != null && event.occurredAt.isBefore(since)) return false;
      return true;
    });

    if (limit != null) {
      events = events.take(limit);
    }

    return events.toList();
  }

  /// Clear event history
  void clearHistory() {
    _eventHistory.clear();
  }

  /// Get registered handlers count
  Map<Type, int> get handlerCounts =>
      _handlers.map((type, handlers) => MapEntry(type, handlers.length));

  /// Dispose resources
  void dispose() {
    _handlers.clear();
    _eventHistory.clear();
    _eventStream.close();
  }
}

/// Event Sourcing Store
class EventStore {
  final List<DomainEvent> _events = [];
  final Map<String, List<DomainEvent>> _aggregateEvents = {};

  /// Save event to store
  void save(DomainEvent event, {String? aggregateId}) {
    _events.add(event);

    if (aggregateId != null) {
      _aggregateEvents.putIfAbsent(aggregateId, () => []).add(event);
    }
  }

  /// Get events for aggregate
  List<DomainEvent> getEventsForAggregate(String aggregateId) {
    return _aggregateEvents[aggregateId] ?? [];
  }

  /// Get all events
  List<DomainEvent> getAllEvents({
    String? eventType,
    DateTime? since,
    DateTime? until,
  }) {
    return _events.where((event) {
      if (eventType != null && event.eventType != eventType) return false;
      if (since != null && event.occurredAt.isBefore(since)) return false;
      if (until != null && event.occurredAt.isAfter(until)) return false;
      return true;
    }).toList();
  }

  /// Create snapshot of aggregate state
  void createSnapshot(String aggregateId, Map<String, dynamic> state) {
    // Implementation would save aggregate snapshot
    // Useful for performance optimization in event sourcing
  }
}

/// Event Processor - Handles event processing patterns
class EventProcessor {
  final List<EventHandler> _processors = [];

  void addProcessor(EventHandler processor) {
    _processors.add(processor);
  }

  Future<void> processEvent(DomainEvent event) async {
    final applicableProcessors = _processors
        .where((processor) => processor.canHandle(event))
        .toList();

    // Process sequentially to maintain order
    for (final processor in applicableProcessors) {
      await processor.handle(event);
    }
  }

  /// Process events in batch
  Future<void> processBatch(List<DomainEvent> events) async {
    for (final event in events) {
      await processEvent(event);
    }
  }
}

/// Saga Pattern - Long-running business processes
abstract class Saga {
  final String sagaId;
  final Map<String, dynamic> _state = {};
  bool _isComplete = false;

  Saga(this.sagaId);

  /// Handle an event in the saga
  Future<void> handle(DomainEvent event);

  /// Get saga state
  Map<String, dynamic> get state => Map.from(_state);

  /// Set saga state
  void setState(String key, dynamic value) {
    _state[key] = value;
  }

  /// Mark saga as complete
  void complete() {
    _isComplete = true;
  }

  /// Check if saga is complete
  bool get isComplete => _isComplete;

  /// Get saga status
  Map<String, dynamic> getStatus() => {
        'sagaId': sagaId,
        'isComplete': _isComplete,
        'state': state,
      };
}

/// Saga Manager - Manages multiple sagas
class SagaManager {
  final Map<String, Saga> _sagas = {};
  final EventBus _eventBus;

  SagaManager(this._eventBus) {
    // Subscribe to all events
    _eventBus.eventStream.listen(_handleEvent);
  }

  /// Start a new saga
  void startSaga(Saga saga) {
    _sagas[saga.sagaId] = saga;
  }

  /// Get saga by ID
  Saga? getSaga(String sagaId) {
    return _sagas[sagaId];
  }

  /// Handle incoming event
  Future<void> _handleEvent(DomainEvent event) async {
    final activeSagas = _sagas.values.where((saga) => !saga.isComplete);

    for (final saga in activeSagas) {
      try {
        await saga.handle(event);

        // Remove completed sagas
        if (saga.isComplete) {
          _sagas.remove(saga.sagaId);
        }
      } catch (e) {
        print('Error in saga ${saga.sagaId}: $e');
      }
    }
  }

  /// Get active sagas count
  int get activeSagasCount => _sagas.values.where((saga) => !saga.isComplete).length;

  /// Get all saga statuses
  List<Map<String, dynamic>> getAllSagaStatuses() {
    return _sagas.values.map((saga) => saga.getStatus()).toList();
  }
}