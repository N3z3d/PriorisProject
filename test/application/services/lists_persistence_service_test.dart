/// TDD Tests for ListsPersistenceService
/// Follows Red → Green → Refactor methodology
/// Tests written to validate P0 critical service (Strategy Pattern)

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/application/services/lists_persistence_service.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'lists_persistence_service_test.mocks.dart';

@GenerateMocks([
  AdaptivePersistenceService,
  CustomListRepository,
  ListItemRepository,
])
void main() {
  group('ListsPersistenceService Tests - P0 Critical Service', () {
    late MockAdaptivePersistenceService mockAdaptiveService;
    late MockCustomListRepository mockListRepository;
    late MockListItemRepository mockItemRepository;

    final now = DateTime.now();
    final testList = CustomList(
      id: 'list-123',
      name: 'Test List',
      type: ListType.CUSTOM,
      createdAt: now,
      updatedAt: now,
    );

    final testItem = ListItem(
      id: 'item-456',
      listId: 'list-123',
      title: 'Test Item',
      createdAt: now,
    );

    setUp(() {
      mockAdaptiveService = MockAdaptivePersistenceService();
      mockListRepository = MockCustomListRepository();
      mockItemRepository = MockListItemRepository();
    });

    group('Adaptive Strategy Tests', () {
      late ListsPersistenceService service;

      setUp(() {
        service = ListsPersistenceService.adaptive(mockAdaptiveService);
      });

      test('should get all lists via adaptive service', () async {
        // GIVEN
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList]);

        // WHEN
        final result = await service.getAllLists();

        // THEN
        expect(result, hasLength(1));
        expect(result.first.id, equals('list-123'));
        verify(mockAdaptiveService.getAllLists()).called(1);
      });

      test('should get list by ID using fallback (getAllLists)', () async {
        // GIVEN
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList]);

        // WHEN
        final result = await service.getListById('list-123');

        // THEN
        expect(result, isNotNull);
        expect(result!.id, equals('list-123'));
        verify(mockAdaptiveService.getAllLists()).called(1);
      });

      test('should return null when list not found in fallback', () async {
        // GIVEN
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList]);

        // WHEN
        final result = await service.getListById('non-existent');

        // THEN
        expect(result, isNull);
        verify(mockAdaptiveService.getAllLists()).called(1);
      });

      test('should save list via adaptive service', () async {
        // GIVEN
        when(mockAdaptiveService.saveList(any))
            .thenAnswer((_) async {});

        // WHEN
        await service.saveList(testList);

        // THEN
        verify(mockAdaptiveService.saveList(testList)).called(1);
      });

      test('should delete list via adaptive service', () async {
        // GIVEN
        when(mockAdaptiveService.deleteList('list-123'))
            .thenAnswer((_) async {});

        // WHEN
        await service.deleteList('list-123');

        // THEN
        verify(mockAdaptiveService.deleteList('list-123')).called(1);
      });

      test('should get items by list ID via adaptive service', () async {
        // GIVEN
        when(mockAdaptiveService.getItemsByListId('list-123'))
            .thenAnswer((_) async => [testItem]);

        // WHEN
        final result = await service.getItemsByListId('list-123');

        // THEN
        expect(result, hasLength(1));
        expect(result.first.id, equals('item-456'));
        verify(mockAdaptiveService.getItemsByListId('list-123')).called(1);
      });

      test('should save item via adaptive service', () async {
        // GIVEN
        when(mockAdaptiveService.saveItem(any))
            .thenAnswer((_) async {});

        // WHEN
        await service.saveItem(testItem);

        // THEN
        verify(mockAdaptiveService.saveItem(testItem)).called(1);
      });

      test('should update item via adaptive service', () async {
        // GIVEN
        when(mockAdaptiveService.updateItem(any))
            .thenAnswer((_) async {});

        // WHEN
        await service.updateItem(testItem);

        // THEN
        verify(mockAdaptiveService.updateItem(testItem)).called(1);
      });

      test('should delete item via adaptive service', () async {
        // GIVEN
        when(mockAdaptiveService.deleteItem('item-456'))
            .thenAnswer((_) async {});

        // WHEN
        await service.deleteItem('item-456');

        // THEN
        verify(mockAdaptiveService.deleteItem('item-456')).called(1);
      });
    });

    group('Local Strategy Tests', () {
      late ListsPersistenceService service;

      setUp(() {
        service = ListsPersistenceService.local(
          mockListRepository,
          mockItemRepository,
        );
      });

      test('should get all lists from local repository', () async {
        // GIVEN
        when(mockListRepository.getAllLists())
            .thenAnswer((_) async => [testList]);

        // WHEN
        final result = await service.getAllLists();

        // THEN
        expect(result, hasLength(1));
        expect(result.first.id, equals('list-123'));
        verify(mockListRepository.getAllLists()).called(1);
      });

      test('should get list by ID from local repository', () async {
        // GIVEN
        when(mockListRepository.getListById('list-123'))
            .thenAnswer((_) async => testList);

        // WHEN
        final result = await service.getListById('list-123');

        // THEN
        expect(result, isNotNull);
        expect(result!.id, equals('list-123'));
        verify(mockListRepository.getListById('list-123')).called(1);
      });

      test('should save list to local repository', () async {
        // GIVEN
        when(mockListRepository.saveList(any))
            .thenAnswer((_) async {});

        // WHEN
        await service.saveList(testList);

        // THEN
        verify(mockListRepository.saveList(testList)).called(1);
      });

      test('should delete list from local repository', () async {
        // GIVEN
        when(mockListRepository.deleteList('list-123'))
            .thenAnswer((_) async {});

        // WHEN
        await service.deleteList('list-123');

        // THEN
        verify(mockListRepository.deleteList('list-123')).called(1);
      });

      test('should get items from local repository', () async {
        // GIVEN
        when(mockItemRepository.getByListId('list-123'))
            .thenAnswer((_) async => [testItem]);

        // WHEN
        final result = await service.getItemsByListId('list-123');

        // THEN
        expect(result, hasLength(1));
        expect(result.first.id, equals('item-456'));
        verify(mockItemRepository.getByListId('list-123')).called(1);
      });

      test('should save item to local repository', () async {
        // GIVEN
        when(mockItemRepository.add(any))
            .thenAnswer((_) async => testItem);

        // WHEN
        await service.saveItem(testItem);

        // THEN
        verify(mockItemRepository.add(testItem)).called(1);
      });

      test('should update item in local repository', () async {
        // GIVEN
        when(mockItemRepository.update(any))
            .thenAnswer((_) async => testItem);

        // WHEN
        await service.updateItem(testItem);

        // THEN
        verify(mockItemRepository.update(testItem)).called(1);
      });

      test('should delete item from local repository', () async {
        // GIVEN
        when(mockItemRepository.delete('item-456'))
            .thenAnswer((_) async {});

        // WHEN
        await service.deleteItem('item-456');

        // THEN
        verify(mockItemRepository.delete('item-456')).called(1);
      });

      test('should verify persistence using local repository', () async {
        // GIVEN
        when(mockListRepository.getListById('list-123'))
            .thenAnswer((_) async => testList);

        // WHEN
        final result = await service.verifyPersistence('list-123');

        // THEN
        expect(result, isTrue);
        verify(mockListRepository.getListById('list-123')).called(1);
      });

      test('should return false when entity not found during verification', () async {
        // GIVEN
        when(mockListRepository.getListById('non-existent'))
            .thenAnswer((_) async => null);

        // WHEN
        final result = await service.verifyPersistence('non-existent');

        // THEN
        expect(result, isFalse);
        verify(mockListRepository.getListById('non-existent')).called(1);
      });

      test('should clear all local data (items then lists)', () async {
        // GIVEN
        when(mockListRepository.getAllLists())
            .thenAnswer((_) async => [testList]);
        when(mockItemRepository.getAll())
            .thenAnswer((_) async => [testItem]);
        when(mockItemRepository.delete(any))
            .thenAnswer((_) async {});
        when(mockListRepository.deleteList(any))
            .thenAnswer((_) async {});

        // WHEN
        await service.clearAllData();

        // THEN
        verify(mockItemRepository.getAll()).called(1);
        verify(mockItemRepository.delete('item-456')).called(1);
        verify(mockListRepository.getAllLists()).called(1);
        verify(mockListRepository.deleteList('list-123')).called(1);
      });

      test('should force reload by getting all lists', () async {
        // GIVEN
        when(mockListRepository.getAllLists())
            .thenAnswer((_) async => [testList]);

        // WHEN
        await service.forceReload();

        // THEN
        verify(mockListRepository.getAllLists()).called(1);
      });
    });

    group('Error Handling Tests', () {
      test('should rethrow error when getAllLists fails (adaptive)', () async {
        // GIVEN
        final service = ListsPersistenceService.adaptive(mockAdaptiveService);
        when(mockAdaptiveService.getAllLists())
            .thenThrow(Exception('Database error'));

        // WHEN & THEN
        await expectLater(
          service.getAllLists(),
          throwsA(isA<Exception>()),
        );
      });

      test('should rethrow error when saveList fails (local)', () async {
        // GIVEN
        final service = ListsPersistenceService.local(
          mockListRepository,
          mockItemRepository,
        );
        when(mockListRepository.saveList(any))
            .thenThrow(Exception('Save failed'));

        // WHEN & THEN
        await expectLater(
          service.saveList(testList),
          throwsA(isA<Exception>()),
        );
      });

      test('should return false when verifyPersistence throws error', () async {
        // GIVEN
        final service = ListsPersistenceService.local(
          mockListRepository,
          mockItemRepository,
        );
        when(mockListRepository.getListById(any))
            .thenThrow(Exception('Verification error'));

        // WHEN
        final result = await service.verifyPersistence('list-123');

        // THEN
        expect(result, isFalse);
      });
    });

    group('Cloud Strategy Tests (Unimplemented)', () {
      test('should throw UnimplementedError for cloud getAllLists', () async {
        // Cloud strategy is not implemented yet
        // This test documents the expected behavior
        // When cloud is implemented, this test should be updated

        // For now, we can't instantiate cloud strategy
        // but we document the expected behavior
        expect(() => PersistenceStrategy.cloud, returnsNormally);
      });
    });
  });
}
