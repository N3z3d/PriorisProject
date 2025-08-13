import 'dart:async';
import 'package:flutter/foundation.dart';
import 'domain_event.dart';

/// Interface pour les gestionnaires d'événements
abstract class EventHandler<T extends DomainEvent> {
  Future<void> handle(T event);
}

/// Bus d'événements pour la communication entre bounded contexts
class EventBus {
  static EventBus? _instance;
  static EventBus get instance => _instance ??= EventBus._();

  EventBus._();

  final Map<Type, List<EventHandler>> _handlers = {};
  final StreamController<DomainEvent> _eventStream = StreamController<DomainEvent>.broadcast();

  /// Stream de tous les événements
  Stream<DomainEvent> get eventStream => _eventStream.stream;

  /// Enregistre un gestionnaire pour un type d'événement
  void subscribe<T extends DomainEvent>(EventHandler<T> handler) {
    _handlers.putIfAbsent(T, () => []).add(handler);
  }

  /// Supprime un gestionnaire
  void unsubscribe<T extends DomainEvent>(EventHandler<T> handler) {
    _handlers[T]?.remove(handler);
    if (_handlers[T]?.isEmpty == true) {
      _handlers.remove(T);
    }
  }

  /// Publie un événement de manière asynchrone
  Future<void> publish(DomainEvent event) async {
    // Ajouter à l'événement stream
    _eventStream.add(event);

    // Trouver les handlers appropriés
    final handlers = _handlers[event.runtimeType] ?? [];
    
    // Exécuter tous les handlers en parallèle
    final futures = handlers.map((handler) async {
      try {
        await handler.handle(event);
      } catch (e, stackTrace) {
        // Log l'erreur mais continue avec les autres handlers (debug uniquement)
        if (kDebugMode) {
          debugPrint('Erreur lors du traitement de l\'événement ${event.eventName}: $e');
          debugPrint('StackTrace: $stackTrace');
        }
      }
    });

    await Future.wait(futures);
  }

  /// Publie plusieurs événements
  Future<void> publishAll(List<DomainEvent> events) async {
    for (final event in events) {
      await publish(event);
    }
  }

  /// Filtre les événements par type
  Stream<T> eventStreamOfType<T extends DomainEvent>() {
    return _eventStream.stream.where((event) => event is T).cast<T>();
  }

  /// Filtre les événements par nom
  Stream<DomainEvent> eventStreamByName(String eventName) {
    return _eventStream.stream.where((event) => event.eventName == eventName);
  }

  /// Compte le nombre de handlers pour un type d'événement
  int getHandlerCount<T extends DomainEvent>() {
    return _handlers[T]?.length ?? 0;
  }

  /// Liste tous les types d'événements avec handlers
  List<Type> getRegisteredEventTypes() {
    return _handlers.keys.toList();
  }

  /// Nettoie tous les handlers et ferme les streams
  void dispose() {
    _handlers.clear();
    _eventStream.close();
  }

  /// Remet à zéro l'instance (utile pour les tests)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}

/// Mixin pour simplifier l'utilisation de l'EventBus dans les services
mixin EventBusPublisher {
  EventBus get eventBus => EventBus.instance;

  /// Publie un événement
  Future<void> publishEvent(DomainEvent event) async {
    await eventBus.publish(event);
  }

  /// Publie plusieurs événements
  Future<void> publishEvents(List<DomainEvent> events) async {
    await eventBus.publishAll(events);
  }
}