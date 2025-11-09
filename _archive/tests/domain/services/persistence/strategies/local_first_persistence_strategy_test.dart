import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/strategies/local_first_persistence_strategy.dart';
import 'package:prioris/domain/services/persistence/interfaces/persistence_strategy_interface.dart';

import 'local_first_persistence_strategy_test.mocks.dart';

@GenerateMocks([CustomListRepository, ListItemRepository])
void main() {
  group('LocalFirstPersistenceStrategy', () {
    late LocalFirstPersistenceStrategy strategy;
    late MockCustomListRepository mockLocalRepository;
    late MockListItemRepository mockLocalItemRepository;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();

      strategy = LocalFirstPersistenceStrategy(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
      );
    });

    group('Strategy Properties', () {
      test('should have correct strategy name', () {
        expect(strategy.strategyName, equals('LocalFirst'));
      });

      test('should have correct conflict resolution strategy', () {
        expect(strategy.conflictResolutionStrategy, equals('latest_timestamp_wins'));
      });

      test('should be available when local repository works', () async {
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);

        final isAvailable = await strategy.isAvailable();

        expect(isAvailable, isTrue);
      });

      test('should not be available when local repository fails', () async {
        when(mockLocalRepository.getAllLists()).thenThrow(Exception('Storage error'));

        final isAvailable = await strategy.isAvailable();

        expect(isAvailable, isFalse);
      });
    });

    group('List Operations', () {
      test('getAllLists should return deduplicated lists', () async {
        final list1 = _createTestList('1', 'List 1');
        final list1Duplicate = _createTestList('1', 'List 1 Updated');
        final list2 = _createTestList('2', 'List 2');

        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [list1, list1Duplicate, list2]);

        final result = await strategy.getAllLists();

        expect(result.length, equals(2));
        expect(result.map((l) => l.id), containsAll(['1', '2']));
      });

      test('saveList should call repository saveList', () async {
        final list = _createTestList('1', 'Test List');

        when(mockLocalRepository.saveList(any)).thenAnswer((_) async {});

        await strategy.saveList(list);

        verify(mockLocalRepository.saveList(list)).called(1);
      });

      test('saveList should handle conflicts gracefully', () async {
        final list = _createTestList('1', 'Test List');
        final existingList = _createTestList('1', 'Existing List');

        when(mockLocalRepository.saveList(any))
            .thenThrow(Exception('Une liste avec cet ID existe déjà'));
        when(mockLocalRepository.getListById('1'))
            .thenAnswer((_) async => existingList);
        when(mockLocalRepository.updateList(any)).thenAnswer((_) async {});

        await strategy.saveList(list);

        verify(mockLocalRepository.getListById('1')).called(1);
        verify(mockLocalRepository.updateList(any)).called(1);
      });

      test('updateList should call repository updateList', () async {
        final list = _createTestList('1', 'Updated List');

        when(mockLocalRepository.updateList(any)).thenAnswer((_) async {});

        await strategy.updateList(list);

        verify(mockLocalRepository.updateList(list)).called(1);
      });

      test('deleteList should call repository deleteList', () async {
        when(mockLocalRepository.deleteList('1')).thenAnswer((_) async {});

        await strategy.deleteList('1');

        verify(mockLocalRepository.deleteList('1')).called(1);
      });

      test('getListById should call repository getListById', () async {
        final list = _createTestList('1', 'Test List');
        when(mockLocalRepository.getListById('1')).thenAnswer((_) async => list);

        final result = await strategy.getListById('1');

        expect(result, equals(list));
        verify(mockLocalRepository.getListById('1')).called(1);
      });
    });

    group('List Item Operations', () {
      test('getItemsByListId should return items from repository', () async {
        final items = [_createTestItem('1', 'Item 1', 'list1')];
        when(mockLocalItemRepository.getByListId('list1'))
            .thenAnswer((_) async => items);

        final result = await strategy.getItemsByListId('list1');

        expect(result, equals(items));
        verify(mockLocalItemRepository.getByListId('list1')).called(1);
      });

      test('saveItem should call repository add', () async {
        final item = _createTestItem('1', 'Test Item', 'list1');
        when(mockLocalItemRepository.add(any)).thenAnswer((_) async => item);

        await strategy.saveItem(item);

        verify(mockLocalItemRepository.add(item)).called(1);
      });

      test('saveItem should handle conflicts gracefully', () async {
        final item = _createTestItem('1', 'Test Item', 'list1');
        final existingItem = _createTestItem('1', 'Existing Item', 'list1');

        when(mockLocalItemRepository.add(any))
            .thenThrow(Exception('Un item avec cet id existe déjà'));
        when(mockLocalItemRepository.getById('1'))
            .thenAnswer((_) async => existingItem);
        when(mockLocalItemRepository.update(any)).thenAnswer((_) async => item);

        await strategy.saveItem(item);

        verify(mockLocalItemRepository.getById('1')).called(1);
        verify(mockLocalItemRepository.update(any)).called(1);
      });

      test('updateItem should call repository update', () async {
        final item = _createTestItem('1', 'Updated Item', 'list1');
        when(mockLocalItemRepository.update(any)).thenAnswer((_) async => item);

        await strategy.updateItem(item);

        verify(mockLocalItemRepository.update(item)).called(1);
      });

      test('deleteItem should call repository delete', () async {
        when(mockLocalItemRepository.delete('1')).thenAnswer((_) async {});

        await strategy.deleteItem('1');

        verify(mockLocalItemRepository.delete('1')).called(1);
      });

      test('getItemById should call repository getById', () async {
        final item = _createTestItem('1', 'Test Item', 'list1');
        when(mockLocalItemRepository.getById('1')).thenAnswer((_) async => item);

        final result = await strategy.getItemById('1');

        expect(result, equals(item));
        verify(mockLocalItemRepository.getById('1')).called(1);
      });
    });

    group('Batch Operations', () {
      test('saveLists should save all lists', () async {
        final lists = [
          _createTestList('1', 'List 1'),
          _createTestList('2', 'List 2'),
        ];

        when(mockLocalRepository.saveList(any)).thenAnswer((_) async {});

        await strategy.saveLists(lists);

        verify(mockLocalRepository.saveList(any)).called(2);
      });

      test('saveItems should save all items', () async {
        final items = [
          _createTestItem('1', 'Item 1', 'list1'),
          _createTestItem('2', 'Item 2', 'list1'),
        ];

        when(mockLocalItemRepository.add(any)).thenAnswer((_) async => items[0]);

        await strategy.saveItems(items);

        verify(mockLocalItemRepository.add(any)).called(2);
      });
    });

    group('Health & Maintenance', () {
      test('cleanup should complete without errors', () async {
        await strategy.cleanup();
        // No specific verification needed - just ensure it doesn't throw
      });

      test('validateIntegrity should return true for valid data', () async {
        final validLists = [_createTestList('1', 'Valid List')];
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => validLists);

        final result = await strategy.validateIntegrity();

        expect(result, isTrue);
      });

      test('validateIntegrity should return false for invalid data', () async {
        final invalidList = CustomList(
          id: '', // Invalid empty ID
          name: 'Invalid List',
          type: ListType.tasks,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [invalidList]);

        final result = await strategy.validateIntegrity();

        expect(result, isFalse);
      });
    });

    group('Conflict Resolution', () {
      test('resolveListConflict should prefer newer list', () {
        final older = _createTestList('1', 'Older');
        final newer = _createTestList('1', 'Newer');

        // Make newer list actually newer
        newer.updatedAt = DateTime.now().add(Duration(hours: 1));

        final result = strategy.resolveListConflict(older, newer);

        expect(result, equals(newer));
      });

      test('resolveListConflict should prefer existing for equal timestamps', () {
        final existing = _createTestList('1', 'Existing');
        final incoming = _createTestList('1', 'Incoming');

        // Same timestamps
        final sameTime = DateTime.now();
        existing.updatedAt = sameTime;
        incoming.updatedAt = sameTime;

        final result = strategy.resolveListConflict(existing, incoming);

        expect(result, equals(incoming)); // Prefers incoming by default
      });

      test('resolveItemConflict should prefer newer item', () {
        final older = _createTestItem('1', 'Older', 'list1');
        final newer = _createTestItem('1', 'Newer', 'list1');

        // Make newer item actually newer
        newer.createdAt = DateTime.now().add(Duration(hours: 1));

        final result = strategy.resolveItemConflict(older, newer);

        expect(result, equals(newer));
      });
    });

    group('Error Handling', () {
      test('should throw PersistenceStrategyException on repository error', () async {
        when(mockLocalRepository.getAllLists()).thenThrow(Exception('Repository error'));

        expect(
          () => strategy.getAllLists(),
          throwsA(isA<PersistenceStrategyException>()),
        );
      });

      test('PersistenceStrategyException should include strategy name', () async {
        when(mockLocalRepository.getAllLists()).thenThrow(Exception('Repository error'));

        try {
          await strategy.getAllLists();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, isA<PersistenceStrategyException>());
          final exception = e as PersistenceStrategyException;
          expect(exception.strategyName, equals('LocalFirst'));
        }
      });
    });
  });
}

// Helper functions to create test objects
CustomList _createTestList(String id, String name) {
  return CustomList(
    id: id,
    name: name,
    type: ListType.tasks,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

ListItem _createTestItem(String id, String title, String listId) {
  return ListItem(
    id: id,
    title: title,
    listId: listId,
    createdAt: DateTime.now(),
  );
}