import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/refactored_adaptive_persistence_service.dart';
import 'package:prioris/domain/services/persistence/interfaces/persistence_mode_interface.dart';

import 'refactored_adaptive_persistence_service_test.mocks.dart';

@GenerateMocks([CustomListRepository, ListItemRepository])

void main() {
  group('RefactoredAdaptivePersistenceService', () {
    late RefactoredAdaptivePersistenceService service;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();

      service = RefactoredAdaptivePersistenceService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('Initialization', () {
      test('should initialize with guest user (local-first mode)', () async {
        await service.initialize(isAuthenticated: false);

        expect(service.isAuthenticated, isFalse);
        expect(service.currentMode, equals(PersistenceMode.localFirst));
      });

      test('should initialize with authenticated user (cloud-first mode)', () async {
        await service.initialize(isAuthenticated: true);

        expect(service.isAuthenticated, isTrue);
        expect(service.currentMode, equals(PersistenceMode.cloudFirst));
      });
    });

    group('Authentication State Updates', () {
      test('should update from guest to authenticated', () async {
        // Start as guest
        await service.initialize(isAuthenticated: false);
        expect(service.currentMode, equals(PersistenceMode.localFirst));

        // Mock empty local data for migration
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);

        // Update to authenticated
        await service.updateAuthenticationState(isAuthenticated: true);

        expect(service.isAuthenticated, isTrue);
        expect(service.currentMode, equals(PersistenceMode.cloudFirst));
      });

      test('should update from authenticated to guest', () async {
        // Start as authenticated
        await service.initialize(isAuthenticated: true);
        expect(service.currentMode, equals(PersistenceMode.cloudFirst));

        // Mock cloud data for sync
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => []);

        // Update to guest
        await service.updateAuthenticationState(isAuthenticated: false);

        expect(service.isAuthenticated, isFalse);
        expect(service.currentMode, equals(PersistenceMode.localFirst));
      });
    });

    group('List Operations - Local First Mode', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('getAllLists should use local repository', () async {
        final testLists = [_createTestList('1', 'Test List')];
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);

        final result = await service.getAllLists();

        expect(result, equals(testLists));
        verify(mockLocalRepository.getAllLists()).called(1);
      });

      test('saveList should use local repository', () async {
        final testList = _createTestList('1', 'Test List');
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async {});

        await service.saveList(testList);

        verify(mockLocalRepository.saveList(testList)).called(1);
      });

      test('deleteList should use local repository', () async {
        when(mockLocalRepository.deleteList('1')).thenAnswer((_) async {});

        await service.deleteList('1');

        verify(mockLocalRepository.deleteList('1')).called(1);
      });
    });

    group('List Item Operations', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('getItemsByListId should use current strategy', () async {
        final testItems = [_createTestItem('1', 'Test Item', 'list1')];
        when(mockLocalItemRepository.getByListId('list1'))
            .thenAnswer((_) async => testItems);

        final result = await service.getItemsByListId('list1');

        expect(result, equals(testItems));
        verify(mockLocalItemRepository.getByListId('list1')).called(1);
      });

      test('saveItem should use current strategy', () async {
        final testItem = _createTestItem('1', 'Test Item', 'list1');
        when(mockLocalItemRepository.add(any)).thenAnswer((_) async => testItem);

        await service.saveItem(testItem);

        verify(mockLocalItemRepository.add(testItem)).called(1);
      });

      test('updateItem should use current strategy', () async {
        final testItem = _createTestItem('1', 'Updated Item', 'list1');
        when(mockLocalItemRepository.update(any)).thenAnswer((_) async => testItem);

        await service.updateItem(testItem);

        verify(mockLocalItemRepository.update(testItem)).called(1);
      });

      test('deleteItem should use current strategy', () async {
        when(mockLocalItemRepository.delete('1')).thenAnswer((_) async {});

        await service.deleteItem('1');

        verify(mockLocalItemRepository.delete('1')).called(1);
      });
    });

    group('Migration Support', () {
      test('should provide migration progress stream', () {
        expect(service.migrationProgress, isA<Stream>());
      });

      test('should report migration status', () {
        expect(service.isMigrating, isA<bool>());
      });
    });

    group('Resource Management', () {
      test('dispose should clean up resources', () {
        // Should not throw
        expect(() => service.dispose(), returnsNormally);
      });

      test('should handle multiple dispose calls gracefully', () {
        service.dispose();
        // Second dispose should not throw
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('API Compatibility', () {
      test('should maintain backward compatible API', () async {
        await service.initialize(isAuthenticated: false);

        // Test that all original methods are available
        expect(service.currentMode, isA<PersistenceMode>());
        expect(service.isAuthenticated, isA<bool>());

        // Mock repositories for API calls
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async {});
        when(mockLocalRepository.deleteList(any)).thenAnswer((_) async {});
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalItemRepository.add(any)).thenAnswer((_) async => _createTestItem('1', 'Item', 'list1'));
        when(mockLocalItemRepository.update(any)).thenAnswer((_) async => _createTestItem('1', 'Item', 'list1'));
        when(mockLocalItemRepository.delete(any)).thenAnswer((_) async {});

        // Test all methods are callable
        await service.getAllLists();
        await service.saveList(_createTestList('1', 'Test'));
        await service.deleteList('1');
        await service.getItemsByListId('list1');
        await service.saveItem(_createTestItem('1', 'Item', 'list1'));
        await service.updateItem(_createTestItem('1', 'Item', 'list1'));
        await service.deleteItem('1');

        // All should complete without errors
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
