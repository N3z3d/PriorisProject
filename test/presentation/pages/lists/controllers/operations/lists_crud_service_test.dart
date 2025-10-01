import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_service.dart';

import 'lists_crud_service_test.mocks.dart';

@GenerateMocks([
  AdaptivePersistenceService,
  CustomListRepository,
  ListItemRepository,
])
void main() {
  group('ListsCrudService Tests - SOLID SRP Compliance', () {
    late MockAdaptivePersistenceService mockAdaptiveService;
    late MockCustomListRepository mockListRepository;
    late MockListItemRepository mockItemRepository;
    late ListsCrudService crudService;

    setUp(() {
      mockAdaptiveService = MockAdaptivePersistenceService();
      mockListRepository = MockCustomListRepository();
      mockItemRepository = MockListItemRepository();

      crudService = ListsCrudService.adaptive(
        adaptivePersistenceService: mockAdaptiveService,
        listRepository: mockListRepository,
        itemRepository: mockItemRepository,
      );
    });

    group('SRP - Single Responsibility Principle Tests', () {
      test('should only handle persistence operations without state management', () {
        // GIVEN
        final testList = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveList(any)).thenAnswer((_) async {});
        when(mockListRepository.getListById('1')).thenAnswer((_) async => testList);

        // WHEN
        expect(() => crudService.createList(testList), returnsNormally);

        // THEN - Ne doit PAS gérer l'état, seulement la persistance
        // (pas d'état interne dans CrudService)
      });

      test('should not contain any business validation logic', () async {
        // GIVEN - Liste avec données potentiellement invalides
        final invalidList = CustomList(
          id: '',  // ID vide
          name: '', // Nom vide
          createdAt: DateTime.now().add(Duration(days: 1)), // Date future
        );

        when(mockAdaptiveService.saveList(any)).thenAnswer((_) async {});
        when(mockListRepository.getListById('')).thenAnswer((_) async => invalidList);

        // WHEN - Le CrudService ne doit PAS faire de validation métier
        final result = await crudService.createList(invalidList);

        // THEN - Doit persister sans validation (SRP - validation ailleurs)
        expect(result, equals(invalidList));
        verify(mockAdaptiveService.saveList(invalidList)).called(1);
      });

      test('should delegate to appropriate persistence service (DIP)', () async {
        // GIVEN
        final testList = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockAdaptiveService.getItemsByListId('1')).thenAnswer((_) async => []);

        // WHEN
        await crudService.loadAllLists();

        // THEN - Doit déléguer au service adaptatif (DIP)
        verify(mockAdaptiveService.getAllLists()).called(1);
        verify(mockAdaptiveService.getItemsByListId('1')).called(1);
      });
    });

    group('List CRUD Operations', () {
      test('should load all lists with items', () async {
        // GIVEN
        final list1 = CustomList(id: '1', name: 'List 1', createdAt: DateTime.now());
        final list2 = CustomList(id: '2', name: 'List 2', createdAt: DateTime.now());

        final item1 = ListItem(id: 'item1', title: 'Item 1', listId: '1', createdAt: DateTime.now());
        final item2 = ListItem(id: 'item2', title: 'Item 2', listId: '2', createdAt: DateTime.now());

        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => [list1, list2]);
        when(mockAdaptiveService.getItemsByListId('1')).thenAnswer((_) async => [item1]);
        when(mockAdaptiveService.getItemsByListId('2')).thenAnswer((_) async => [item2]);

        // WHEN
        final result = await crudService.loadAllLists();

        // THEN
        expect(result, hasLength(2));
        expect(result[0].items, contains(item1));
        expect(result[1].items, contains(item2));
      });

      test('should create list and verify persistence', () async {
        // GIVEN
        final testList = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveList(any)).thenAnswer((_) async {});
        when(mockListRepository.getListById('1')).thenAnswer((_) async => testList);

        // WHEN
        final result = await crudService.createList(testList);

        // THEN
        expect(result, equals(testList));
        verify(mockAdaptiveService.saveList(testList)).called(1);
        verify(mockListRepository.getListById('1')).called(1); // Vérification
      });

      test('should throw exception if persistence verification fails', () async {
        // GIVEN
        final testList = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveList(any)).thenAnswer((_) async {});
        when(mockListRepository.getListById('1')).thenAnswer((_) async => null); // Échec vérification

        // WHEN & THEN
        expect(
          () => crudService.createList(testList),
          throwsA(isA<Exception>()),
        );
      });

      test('should update list', () async {
        // GIVEN
        final testList = CustomList(
          id: '1',
          name: 'Updated List',
          createdAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveList(any)).thenAnswer((_) async {});

        // WHEN
        final result = await crudService.updateList(testList);

        // THEN
        expect(result, equals(testList));
        verify(mockAdaptiveService.saveList(testList)).called(1);
      });

      test('should delete list', () async {
        // GIVEN
        when(mockAdaptiveService.deleteList('1')).thenAnswer((_) async {});

        // WHEN
        final result = await crudService.deleteList('1');

        // THEN
        expect(result, true);
        verify(mockAdaptiveService.deleteList('1')).called(1);
      });

      test('should handle delete list failure', () async {
        // GIVEN
        when(mockAdaptiveService.deleteList('1')).thenThrow(Exception('Delete failed'));

        // WHEN
        final result = await crudService.deleteList('1');

        // THEN
        expect(result, false);
      });
    });

    group('Item CRUD Operations', () {
      test('should load list items', () async {
        // GIVEN
        final item1 = ListItem(id: 'item1', title: 'Item 1', listId: '1', createdAt: DateTime.now());
        final item2 = ListItem(id: 'item2', title: 'Item 2', listId: '1', createdAt: DateTime.now());

        when(mockAdaptiveService.getItemsByListId('1')).thenAnswer((_) async => [item1, item2]);

        // WHEN
        final result = await crudService.loadListItems('1');

        // THEN
        expect(result, hasLength(2));
        expect(result, containsAll([item1, item2]));
      });

      test('should add item to list with verification', () async {
        // GIVEN
        final testItem = ListItem(
          id: 'item1',
          title: 'Test Item',
          listId: '1',
          createdAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveItem(any)).thenAnswer((_) async {});
        when(mockItemRepository.getById('item1')).thenAnswer((_) async => testItem);

        // WHEN
        final result = await crudService.addItemToList(testItem);

        // THEN
        expect(result, equals(testItem));
        verify(mockAdaptiveService.saveItem(testItem)).called(1);
        verify(mockItemRepository.getById('item1')).called(1); // Vérification
      });

      test('should add multiple items transactionally', () async {
        // GIVEN
        final itemTitles = ['Item 1', 'Item 2', 'Item 3'];

        when(mockAdaptiveService.saveItem(any)).thenAnswer((_) async {});
        when(mockItemRepository.getById(any)).thenAnswer((_) async =>
          ListItem(id: 'test', title: 'test', listId: '1', createdAt: DateTime.now())
        );

        // WHEN
        final result = await crudService.addMultipleItemsToList('1', itemTitles);

        // THEN
        expect(result, hasLength(3));
        expect(result.map((item) => item.title), containsAll(itemTitles));
        verify(mockAdaptiveService.saveItem(any)).called(3);
        verify(mockItemRepository.getById(any)).called(3); // Vérifications
      });

      test('should rollback on partial failure during bulk add', () async {
        // GIVEN
        final itemTitles = ['Item 1', 'Item 2', 'Item 3'];

        // Premier item réussit
        when(mockAdaptiveService.saveItem(argThat(predicate<ListItem>((item) => item.title == 'Item 1'))))
            .thenAnswer((_) async {});
        when(mockItemRepository.getById(argThat(predicate<String>((id) => id.contains('Item 1')))))
            .thenAnswer((_) async => ListItem(id: 'item1', title: 'Item 1', listId: '1', createdAt: DateTime.now()));

        // Deuxième item échoue à la sauvegarde
        when(mockAdaptiveService.saveItem(argThat(predicate<ListItem>((item) => item.title == 'Item 2'))))
            .thenThrow(Exception('Save failed'));

        // WHEN & THEN
        expect(
          () => crudService.addMultipleItemsToList('1', itemTitles),
          throwsA(isA<Exception>()),
        );

        // Vérifier que le rollback est tenté
        verify(mockAdaptiveService.deleteItem(any)).called(1);
      });

      test('should update item', () async {
        // GIVEN
        final testItem = ListItem(
          id: 'item1',
          title: 'Updated Item',
          listId: '1',
          createdAt: DateTime.now(),
        );

        when(mockAdaptiveService.updateItem(any)).thenAnswer((_) async {});

        // WHEN
        final result = await crudService.updateListItem(testItem);

        // THEN
        expect(result, equals(testItem));
        verify(mockAdaptiveService.updateItem(testItem)).called(1);
      });

      test('should remove item from list', () async {
        // GIVEN
        when(mockAdaptiveService.deleteItem('item1')).thenAnswer((_) async {});

        // WHEN
        final result = await crudService.removeItemFromList('item1');

        // THEN
        expect(result, true);
        verify(mockAdaptiveService.deleteItem('item1')).called(1);
      });

      test('should handle remove item failure', () async {
        // GIVEN
        when(mockAdaptiveService.deleteItem('item1')).thenThrow(Exception('Delete failed'));

        // WHEN
        final result = await crudService.removeItemFromList('item1');

        // THEN
        expect(result, false);
      });
    });

    group('Bulk Operations', () {
      test('should clear all data', () async {
        // GIVEN
        final list1 = CustomList(id: '1', name: 'List 1', createdAt: DateTime.now());
        final list2 = CustomList(id: '2', name: 'List 2', createdAt: DateTime.now());

        final item1 = ListItem(id: 'item1', title: 'Item 1', listId: '1', createdAt: DateTime.now());
        final item2 = ListItem(id: 'item2', title: 'Item 2', listId: '2', createdAt: DateTime.now());

        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => [list1, list2]);
        when(mockAdaptiveService.getItemsByListId('1')).thenAnswer((_) async => [item1]);
        when(mockAdaptiveService.getItemsByListId('2')).thenAnswer((_) async => [item2]);
        when(mockAdaptiveService.deleteList(any)).thenAnswer((_) async {});
        when(mockAdaptiveService.deleteItem(any)).thenAnswer((_) async {});

        // WHEN
        await crudService.clearAllData();

        // THEN
        verify(mockAdaptiveService.deleteList('1')).called(1);
        verify(mockAdaptiveService.deleteList('2')).called(1);
        verify(mockAdaptiveService.deleteItem('item1')).called(1);
        verify(mockAdaptiveService.deleteItem('item2')).called(1);
      });

      test('should force reload from persistence', () async {
        // GIVEN
        final testList = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockAdaptiveService.getItemsByListId('1')).thenAnswer((_) async => []);

        // WHEN
        final result = await crudService.forceReloadFromPersistence();

        // THEN
        expect(result, hasLength(1));
        expect(result.first.name, equals('Test'));
      });
    });

    group('Legacy Support', () {
      test('should work with legacy constructor', () async {
        // GIVEN
        final legacyCrudService = ListsCrudService.legacy(
          listRepository: mockListRepository,
          itemRepository: mockItemRepository,
        );

        final testList = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        when(mockListRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockItemRepository.getByListId('1')).thenAnswer((_) async => []);

        // WHEN
        final result = await legacyCrudService.loadAllLists();

        // THEN
        expect(result, hasLength(1));
        verify(mockListRepository.getAllLists()).called(1);
      });
    });

    group('Verification System', () {
      test('should verify list persistence correctly', () async {
        // GIVEN
        final testList = CustomList(id: '1', name: 'Test', createdAt: DateTime.now());

        when(mockListRepository.getListById('1')).thenAnswer((_) async => testList);

        // WHEN
        final result = await crudService.verifyPersistence('1', true);

        // THEN
        expect(result, true);
        verify(mockListRepository.getListById('1')).called(1);
      });

      test('should verify item persistence correctly', () async {
        // GIVEN
        final testItem = ListItem(id: 'item1', title: 'Test', listId: '1', createdAt: DateTime.now());

        when(mockItemRepository.getById('item1')).thenAnswer((_) async => testItem);

        // WHEN
        final result = await crudService.verifyPersistence('item1', false);

        // THEN
        expect(result, true);
        verify(mockItemRepository.getById('item1')).called(1);
      });

      test('should return false for failed verification', () async {
        // GIVEN
        when(mockListRepository.getListById('1')).thenAnswer((_) async => null);

        // WHEN
        final result = await crudService.verifyPersistence('1', true);

        // THEN
        expect(result, false);
      });
    });
  });
}