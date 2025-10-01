import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/lists/controllers/interfaces/lists_event_handler_interface.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_event_handler.dart';

void main() {
  group('ListsEventHandler Tests - SOLID SRP Compliance', () {
    late ListsEventHandler eventHandler;

    setUp(() {
      eventHandler = ListsEventHandler(
        eventLoggingEnabled: true,
        userId: 'test-user',
        sessionId: 'test-session',
      );
    });

    tearDown(() {
      eventHandler.dispose();
    });

    group('SRP - Single Responsibility Principle Tests', () {
      test('should only handle events without business logic', () {
        // GIVEN - Un événement quelconque
        final testEvent = ListsEvent(
          type: ListsEventType.listCreated,
          timestamp: DateTime.now(),
          data: {'test': 'data'},
        );

        // WHEN - Émission d'événement sans logique métier
        expect(() => eventHandler.emitEvent(testEvent), returnsNormally);

        // THEN - Aucune transformation ou validation métier
        // (le handler ne doit que relayer les événements)
      });

      test('should not contain state management logic', () {
        // GIVEN
        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        // WHEN - Émissions multiples
        eventHandler.emitListCreated(list);
        eventHandler.emitListUpdated(list);
        eventHandler.emitListDeleted('1');

        // THEN - Pas d'état métier conservé (seulement historique événements)
        final history = eventHandler.getRecentEvents();
        expect(history, hasLength(3));
      });

      test('should not contain persistence operations', () {
        // GIVEN
        final item = ListItem(
          id: 'item1',
          title: 'Test Item',
          listId: '1',
          createdAt: DateTime.now(),
        );

        // WHEN - Émission d'événement ne doit pas persister de données
        expect(() => eventHandler.emitItemAdded(item), returnsNormally);

        // THEN - Aucun effet de bord sur la persistance
      });
    });

    group('Event Emission', () {
      test('should emit list created event with correct data', () async {
        // GIVEN
        final list = CustomList(
          id: 'list1',
          name: 'Test List',
          createdAt: DateTime.now(),
        );

        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitListCreated(list);

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.type, equals(ListsEventType.listCreated));
        expect(event.data['listId'], equals('list1'));
        expect(event.data['listName'], equals('Test List'));
        expect(event.userId, equals('test-user'));
        expect(event.sessionId, equals('test-session'));
      });

      test('should emit list updated event', () async {
        // GIVEN
        final list = CustomList(
          id: 'list1',
          name: 'Updated List',
          createdAt: DateTime.now(),
        );

        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitListUpdated(list);

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));
        expect(events.first.type, equals(ListsEventType.listUpdated));
        expect(events.first.data['listName'], equals('Updated List'));
      });

      test('should emit list deleted event', () async {
        // GIVEN
        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitListDeleted('list1');

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));
        expect(events.first.type, equals(ListsEventType.listDeleted));
        expect(events.first.data['listId'], equals('list1'));
      });

      test('should emit item added event', () async {
        // GIVEN
        final item = ListItem(
          id: 'item1',
          title: 'Test Item',
          listId: 'list1',
          createdAt: DateTime.now(),
        );

        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitItemAdded(item);

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.type, equals(ListsEventType.itemAdded));
        expect(event.data['itemId'], equals('item1'));
        expect(event.data['itemTitle'], equals('Test Item'));
        expect(event.data['listId'], equals('list1'));
      });

      test('should emit bulk items added event', () async {
        // GIVEN
        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitBulkItemsAdded('list1', 5);

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.type, equals(ListsEventType.bulkItemsAdded));
        expect(event.data['listId'], equals('list1'));
        expect(event.data['itemCount'], equals(5));
      });

      test('should emit error event', () async {
        // GIVEN
        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitError('Test error message');

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.type, equals(ListsEventType.errorOccurred));
        expect(event.data['error'], equals('Test error message'));
      });

      test('should emit data cleared event', () async {
        // GIVEN
        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitDataCleared();

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));
        expect(events.first.type, equals(ListsEventType.dataCleared));
      });

      test('should emit data reloaded event', () async {
        // GIVEN
        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN
        eventHandler.emitDataReloaded(10);

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.type, equals(ListsEventType.dataReloaded));
        expect(event.data['listsCount'], equals(10));
      });
    });

    group('Event Listening', () {
      test('should listen to specific event types', () async {
        // GIVEN
        final receivedEvents = <ListsEvent>[];

        // WHEN - S'abonner seulement aux créations de listes
        final subscription = eventHandler.listenToEventType(
          ListsEventType.listCreated,
          (event) => receivedEvents.add(event),
        );

        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        // Émettre différents types d'événements
        eventHandler.emitListCreated(list);
        eventHandler.emitListUpdated(list);
        eventHandler.emitListDeleted('1');

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(receivedEvents, hasLength(1)); // Seulement la création
        expect(receivedEvents.first.type, equals(ListsEventType.listCreated));

        await subscription.cancel();
      });

      test('should listen to all events', () async {
        // GIVEN
        final receivedEvents = <ListsEvent>[];

        // WHEN - S'abonner à tous les événements
        final subscription = eventHandler.listenToAllEvents(
          (event) => receivedEvents.add(event),
        );

        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        eventHandler.emitListCreated(list);
        eventHandler.emitListUpdated(list);
        eventHandler.emitError('Test error');

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(receivedEvents, hasLength(3)); // Tous les événements

        await subscription.cancel();
      });

      test('should handle listener errors gracefully', () async {
        // GIVEN
        var errorHandled = false;

        // WHEN - Listener qui lance une exception
        final subscription = eventHandler.listenToAllEvents(
          (event) => throw Exception('Listener error'),
        );

        // L'erreur doit être gérée sans crasher le handler
        eventHandler.emitError('Test');

        // THEN - Attendre que l'erreur soit traitée
        await Future.delayed(Duration(milliseconds: 50));
        expect(() => eventHandler.emitError('Another test'), returnsNormally);

        await subscription.cancel();
      });
    });

    group('Event History Management', () {
      test('should maintain event history', () {
        // GIVEN
        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        // WHEN
        eventHandler.emitListCreated(list);
        eventHandler.emitListUpdated(list);
        eventHandler.emitListDeleted('1');

        // THEN
        final history = eventHandler.getRecentEvents();
        expect(history, hasLength(3));

        // Les événements doivent être dans l'ordre inverse (plus récents en premier)
        expect(history[0].type, equals(ListsEventType.listDeleted));
        expect(history[1].type, equals(ListsEventType.listUpdated));
        expect(history[2].type, equals(ListsEventType.listCreated));
      });

      test('should limit history size', () {
        // GIVEN - Générer plus d'événements que la limite
        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        // WHEN - Générer 150 événements (limite = 100)
        for (int i = 0; i < 150; i++) {
          eventHandler.emitListCreated(list.copyWith(id: '$i'));
        }

        // THEN
        final history = eventHandler.getRecentEvents();
        expect(history.length, lessThanOrEqualTo(100));
      });

      test('should limit returned history by parameter', () {
        // GIVEN
        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        for (int i = 0; i < 20; i++) {
          eventHandler.emitListCreated(list);
        }

        // WHEN
        final limitedHistory = eventHandler.getRecentEvents(5);

        // THEN
        expect(limitedHistory, hasLength(5));
      });

      test('should clear event history', () {
        // GIVEN
        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        eventHandler.emitListCreated(list);
        eventHandler.emitListUpdated(list);

        expect(eventHandler.getRecentEvents(), hasLength(2));

        // WHEN
        eventHandler.clearEventHistory();

        // THEN
        expect(eventHandler.getRecentEvents(), isEmpty);
      });
    });

    group('User Context Management', () {
      test('should update user context for future events', () async {
        // GIVEN
        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN - Changer le contexte utilisateur
        eventHandler.setUserContext('new-user', 'new-session');

        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());
        eventHandler.emitListCreated(list);

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.userId, equals('new-user'));
        expect(event.sessionId, equals('new-session'));
      });

      test('should handle null user context', () async {
        // GIVEN
        final events = <ListsEvent>[];
        eventHandler.eventStream.listen(events.add);

        // WHEN - Contexte utilisateur null
        eventHandler.setUserContext(null, null);

        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());
        eventHandler.emitListCreated(list);

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(events, hasLength(1));

        final event = events.first;
        expect(event.userId, isNull);
        expect(event.sessionId, isNull);
      });
    });

    group('Event Logging Control', () {
      test('should control event logging', () {
        // GIVEN
        expect(() => eventHandler.setEventLoggingEnabled(false), returnsNormally);
        expect(() => eventHandler.setEventLoggingEnabled(true), returnsNormally);
      });
    });

    group('Disposal and Cleanup', () {
      test('should handle disposal correctly', () {
        // GIVEN - Handler en fonctionnement normal
        final list = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        expect(() => eventHandler.emitListCreated(list), returnsNormally);

        // WHEN - Dispose
        eventHandler.dispose();

        // THEN - Opérations après dispose doivent être ignorées
        expect(() => eventHandler.emitListCreated(list), returnsNormally);
        expect(eventHandler.getRecentEvents(), isEmpty);
      });

      test('should prevent double disposal', () {
        // WHEN - Double dispose
        eventHandler.dispose();

        // THEN - Deuxième dispose ne doit pas causer d'erreur
        expect(() => eventHandler.dispose(), returnsNormally);
      });

      test('should close stream on disposal', () async {
        // GIVEN
        var streamClosed = false;

        eventHandler.eventStream.listen(
          (_) {},
          onDone: () => streamClosed = true,
        );

        // WHEN
        eventHandler.dispose();

        // THEN
        await Future.delayed(Duration(milliseconds: 10));
        expect(streamClosed, true);
      });
    });

    group('Factory Methods', () {
      test('should create typed events correctly', () {
        // GIVEN
        final list = CustomList(id: '1', name: 'Test List', createdAt: DateTime.now());

        // WHEN
        final event = ListsEvent.listCreated(list, userId: 'user1', sessionId: 'session1');

        // THEN
        expect(event.type, equals(ListsEventType.listCreated));
        expect(event.data['listId'], equals('1'));
        expect(event.data['listName'], equals('Test List'));
        expect(event.userId, equals('user1'));
        expect(event.sessionId, equals('session1'));
        expect(event.timestamp, isNotNull);
      });

      test('should create item events correctly', () {
        // GIVEN
        final item = ListItem(
          id: 'item1',
          title: 'Test Item',
          listId: 'list1',
          createdAt: DateTime.now(),
        );

        // WHEN
        final addedEvent = ListsEvent.itemAdded(item);
        final updatedEvent = ListsEvent.itemUpdated(item);
        final deletedEvent = ListsEvent.itemDeleted('item1', 'list1');

        // THEN
        expect(addedEvent.type, equals(ListsEventType.itemAdded));
        expect(updatedEvent.type, equals(ListsEventType.itemUpdated));
        expect(deletedEvent.type, equals(ListsEventType.itemDeleted));

        expect(addedEvent.data['itemId'], equals('item1'));
        expect(deletedEvent.data['itemId'], equals('item1'));
      });
    });
  });
}