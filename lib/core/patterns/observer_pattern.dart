/// Observer Pattern Implementation following SOLID principles
///
/// Single Responsibility: Event publisher, handlers, and events have distinct roles
/// Open/Closed: Easy to add new event types and handlers
/// Interface Segregation: Focused interfaces for different responsibilities
/// Dependency Inversion: Depend on abstractions, not concrete implementations

import 'dart:async';
import '../interfaces/application_interfaces.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DOMAIN EVENT IMPLEMENTATIONS (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base domain event implementation
abstract class BaseDomainEvent implements DomainEvent {
  final String _eventId;
  final DateTime _occurredAt;
  final Map<String, dynamic> _payload;

  BaseDomainEvent({
    Map<String, dynamic>? payload,
  }) : _eventId = _generateEventId(),
        _occurredAt = DateTime.now(),
        _payload = payload ?? {};

  @override
  String get eventId => _eventId;

  @override
  DateTime get occurredAt => _occurredAt;

  @override
  Map<String, dynamic> get payload => Map.unmodifiable(_payload);

  /// Add data to the event payload
  void addPayloadData(String key, dynamic value) {
    _payload[key] = value;
  }

  /// Remove data from the event payload
  void removePayloadData(String key) {
    _payload.remove(key);
  }

  static String _generateEventId() =>
    'evt_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
}

// ═══════════════════════════════════════════════════════════════════════════
// DOMAIN EVENT TYPES (OCP)
// ═══════════════════════════════════════════════════════════════════════════

/// Entity created event
class EntityCreatedEvent<T> extends BaseDomainEvent {
  final T entity;
  final String entityType;

  EntityCreatedEvent({
    required this.entity,
    required this.entityType,
    Map<String, dynamic>? additionalData,
  }) : super(payload: {
    'entity': entity,
    'entityType': entityType,
    ...?additionalData,
  });

  @override
  String get eventType => 'EntityCreated';
}

/// Entity updated event
class EntityUpdatedEvent<T> extends BaseDomainEvent {
  final T entity;
  final T? previousEntity;
  final String entityType;
  final Map<String, dynamic> changes;

  EntityUpdatedEvent({
    required this.entity,
    this.previousEntity,
    required this.entityType,
    required this.changes,
    Map<String, dynamic>? additionalData,
  }) : super(payload: {
    'entity': entity,
    'previousEntity': previousEntity,
    'entityType': entityType,
    'changes': changes,
    ...?additionalData,
  });

  @override
  String get eventType => 'EntityUpdated';
}

/// Entity deleted event
class EntityDeletedEvent<T> extends BaseDomainEvent {
  final T entity;
  final String entityType;

  EntityDeletedEvent({
    required this.entity,
    required this.entityType,
    Map<String, dynamic>? additionalData,
  }) : super(payload: {
    'entity': entity,
    'entityType': entityType,
    ...?additionalData,
  });

  @override
  String get eventType => 'EntityDeleted';
}

/// Business operation completed event
class BusinessOperationCompletedEvent extends BaseDomainEvent {
  final String operationName;
  final bool successful;
  final String? errorMessage;
  final Duration duration;

  BusinessOperationCompletedEvent({
    required this.operationName,
    required this.successful,
    this.errorMessage,
    required this.duration,
    Map<String, dynamic>? additionalData,
  }) : super(payload: {
    'operationName': operationName,
    'successful': successful,
    'errorMessage': errorMessage,
    'duration': duration.inMilliseconds,
    ...?additionalData,
  });

  @override
  String get eventType => 'BusinessOperationCompleted';
}

// ═══════════════════════════════════════════════════════════════════════════
// EVENT HANDLER IMPLEMENTATIONS (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base event handler with common functionality
abstract class BaseEventHandler<T extends DomainEvent> implements EventHandler<T> {
  final String _handlerId;
  final Type _eventType;

  BaseEventHandler() :
    _handlerId = _generateHandlerId(),
    _eventType = T;

  String get handlerId => _handlerId;
  Type get eventType => _eventType;

  @override
  bool canHandle(DomainEvent event) {
    return event.runtimeType == T || event is T;
  }

  @override
  Future<void> handle(T event) async {
    try {
      await handleInternal(event);
    } catch (e) {
      await handleError(event, e);
    }
  }

  /// Internal handling logic to be implemented by concrete handlers
  Future<void> handleInternal(T event);

  /// Error handling for event processing
  Future<void> handleError(T event, dynamic error) async {
    // Default error handling - can be overridden
    print('Error handling event ${event.eventType}: $error');
  }

  static String _generateHandlerId() =>
    'handler_${DateTime.now().millisecondsSinceEpoch}';
}

/// Asynchronous event handler for long-running operations
abstract class AsyncEventHandler<T extends DomainEvent> extends BaseEventHandler<T> {
  @override
  Future<void> handle(T event) async {
    // Fire and forget - don't wait for completion
    handleInternal(event).catchError((error) => handleError(event, error));
  }
}

/// Retry-capable event handler for unreliable operations
abstract class RetryableEventHandler<T extends DomainEvent> extends BaseEventHandler<T> {
  final int maxRetries;
  final Duration retryDelay;

  RetryableEventHandler({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> handle(T event) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        await handleInternal(event);
        return; // Success
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < maxRetries) {
          await Future.delayed(retryDelay * attempts); // Exponential backoff
        }
      }
    }

    // All retries failed
    await handleError(event, lastException);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EVENT PUBLISHER IMPLEMENTATION (OCP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Thread-safe event publisher with subscription management
class DomainEventPublisher implements EventPublisher {
  final Map<Type, List<EventHandler>> _handlers = {};
  final StreamController<DomainEvent> _eventStream = StreamController.broadcast();
  final List<DomainEvent> _eventHistory = [];
  final int _maxHistorySize;

  DomainEventPublisher({int maxHistorySize = 1000}) : _maxHistorySize = maxHistorySize;

  /// Stream of all published events
  Stream<DomainEvent> get eventStream => _eventStream.stream;

  /// History of published events (limited by maxHistorySize)
  List<DomainEvent> get eventHistory => List.unmodifiable(_eventHistory);

  @override
  Future<void> publish(DomainEvent event) async {
    // Add to history
    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0); // Remove oldest event
    }

    // Add to stream
    _eventStream.add(event);

    // Notify specific handlers
    final eventType = event.runtimeType;
    final handlers = _handlers[eventType] ?? [];

    // Process handlers concurrently
    final futures = handlers
        .where((handler) => handler.canHandle(event))
        .map((handler) => _safeHandleEvent(handler, event));

    await Future.wait(futures);
  }

  @override
  void subscribe<T extends DomainEvent>(EventHandler<T> handler) {
    final eventType = T;
    _handlers[eventType] = _handlers[eventType] ?? [];
    _handlers[eventType]!.add(handler);
  }

  @override
  void unsubscribe<T extends DomainEvent>(EventHandler<T> handler) {
    final eventType = T;
    _handlers[eventType]?.remove(handler);
    if (_handlers[eventType]?.isEmpty ?? false) {
      _handlers.remove(eventType);
    }
  }

  /// Get all handlers for a specific event type
  List<EventHandler<T>> getHandlers<T extends DomainEvent>() {
    return _handlers[T]?.cast<EventHandler<T>>() ?? [];
  }

  /// Get count of handlers for a specific event type
  int getHandlerCount<T extends DomainEvent>() {
    return _handlers[T]?.length ?? 0;
  }

  /// Clear all handlers
  void clearHandlers() {
    _handlers.clear();
  }

  /// Clear event history
  void clearHistory() {
    _eventHistory.clear();
  }

  /// Safe event handling with error isolation
  Future<void> _safeHandleEvent(EventHandler handler, DomainEvent event) async {
    try {
      await handler.handle(event);
    } catch (e) {
      // Isolate handler errors to prevent cascade failures
      print('Handler error for ${event.eventType}: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _eventStream.close();
    _handlers.clear();
    _eventHistory.clear();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EVENT SOURCING SUPPORT (OCP)
// ═══════════════════════════════════════════════════════════════════════════

/// Event store interface for event sourcing
abstract class EventStore {
  Future<void> saveEvent(DomainEvent event);
  Future<List<DomainEvent>> getEvents(String aggregateId);
  Future<List<DomainEvent>> getEventsByType(String eventType);
  Future<void> clearEvents(String aggregateId);
}

/// In-memory event store implementation
class InMemoryEventStore implements EventStore {
  final Map<String, List<DomainEvent>> _eventsByAggregate = {};
  final Map<String, List<DomainEvent>> _eventsByType = {};

  @override
  Future<void> saveEvent(DomainEvent event) async {
    // Save by aggregate (if applicable)
    final aggregateId = event.payload['aggregateId'] as String?;
    if (aggregateId != null) {
      _eventsByAggregate[aggregateId] = _eventsByAggregate[aggregateId] ?? [];
      _eventsByAggregate[aggregateId]!.add(event);
    }

    // Save by type
    _eventsByType[event.eventType] = _eventsByType[event.eventType] ?? [];
    _eventsByType[event.eventType]!.add(event);
  }

  @override
  Future<List<DomainEvent>> getEvents(String aggregateId) async {
    return List.unmodifiable(_eventsByAggregate[aggregateId] ?? []);
  }

  @override
  Future<List<DomainEvent>> getEventsByType(String eventType) async {
    return List.unmodifiable(_eventsByType[eventType] ?? []);
  }

  @override
  Future<void> clearEvents(String aggregateId) async {
    _eventsByAggregate.remove(aggregateId);
  }
}