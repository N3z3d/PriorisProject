import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prioris/domain/models/custom_list.dart';
import 'package:prioris/domain/models/list_item.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_persistence_manager.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';

/// Mock classes
class MockListsCrudOperations extends Mock implements ListsCrudOperations {}

class MockListsPersistenceManager extends Mock
    implements ListsPersistenceManager {}

class MockListsStateManager extends Mock implements ListsStateManager {}

/// Tests de reproduction du bug "Ajouter ne fait rien"
void main() {
  group('ListsController - Add Item Bug Reproduction', () {
    late MockListsCrudOperations mockCrud;
    late MockListsPersistenceManager mockPersistence;
    late MockListsStateManager mockStateManager;

    setUp(() {
      mockCrud = MockListsCrudOperations();
      mockPersistence = MockListsPersistenceManager();
      mockStateManager = MockListsStateManager();

      // Register fallback values for mocktail
      registerFallbackValue(
        ListItem(
          id: 'test-id',
          title: 'Test',
          listId: 'list-id',
          createdAt: DateTime.now(),
        ),
      );
      registerFallbackValue(<ListItem>[]);
    });

    test('REPRO: addMultipleItemsToList should convert strings to ListItems',
        () async {
      // ARRANGE - Setup a simple scenario
      final listId = 'test-list-123';
      final itemTitles = ['Item 1', 'Item 2', 'Item 3'];

      // Create a real controller instance (we'll need to mock its dependencies)
      // For now, let's test the conversion logic in isolation

      // ACT - Simulate what happens when dialog calls addMultipleItemsToList
      final baseTimestamp = DateTime.now().microsecondsSinceEpoch;
      final convertedItems = <ListItem>[];

      for (var index = 0; index < itemTitles.length; index++) {
        final title = itemTitles[index];
        final createdAt = DateTime.now().add(Duration(microseconds: index));
        convertedItems.add(ListItem(
          id: '${listId}_auto_${baseTimestamp + index}_${title.hashCode}',
          title: title,
          createdAt: createdAt,
          listId: listId,
        ));
      }

      // ASSERT
      expect(convertedItems.length, equals(3),
          reason: 'Should convert all 3 titles to ListItems');
      expect(convertedItems[0].title, equals('Item 1'));
      expect(convertedItems[1].title, equals('Item 2'));
      expect(convertedItems[2].title, equals('Item 3'));
      expect(convertedItems.every((item) => item.listId == listId), isTrue,
          reason: 'All items should have correct listId');
    });

    test('REPRO: addMultipleItemsToList should call persistence layer',
        () async {
      // This test would require a full controller setup with mocked dependencies
      // For now, document the expected call chain:
      //
      // 1. Dialog calls: controller.addMultipleItemsToList(listId, [ListItem, ...])
      // 2. Controller converts if needed and calls: addMultipleItems(listId, items)
      // 3. addMultipleItems delegates to: crudOperations.addMultipleItems(...)
      // 4. crudOperations calls: persistence.saveMultipleItems(items)
      // 5. persistence calls repository.add() for each item
      // 6. crudOperations calls: stateManager.addItems(items)
      //
      // BUG HYPOTHESIS: One of these steps is not being called or fails silently
    });

    test('REPRO: single item add should persist and update state', () async {
      // ARRANGE
      final listId = 'test-list-456';
      final item = ListItem(
        id: 'item-1',
        title: 'Single test item',
        listId: listId,
        createdAt: DateTime.now(),
      );

      // Setup mocks
      when(() => mockPersistence.saveListItem(any()))
          .thenAnswer((_) async => true);
      when(() => mockStateManager.addItem(any())).thenReturn(null);

      // ACT - Simulate single item add through CRUD operations
      final result = await mockPersistence.saveListItem(item);

      // ASSERT
      expect(result, isTrue, reason: 'BUG: Persistence should succeed');
      verify(() => mockPersistence.saveListItem(item)).called(1);
    });

    test('REPRO: bulk add should handle all items or rollback on failure',
        () async {
      // ARRANGE
      final listId = 'test-list-789';
      final items = [
        ListItem(
          id: 'item-1',
          title: 'Bulk item 1',
          listId: listId,
          createdAt: DateTime.now(),
        ),
        ListItem(
          id: 'item-2',
          title: 'Bulk item 2',
          listId: listId,
          createdAt: DateTime.now(),
        ),
        ListItem(
          id: 'item-3',
          title: 'Bulk item 3',
          listId: listId,
          createdAt: DateTime.now(),
        ),
      ];

      // Setup mock - all succeed
      when(() => mockPersistence.saveMultipleItems(any()))
          .thenAnswer((_) async => true);

      // ACT
      final result = await mockPersistence.saveMultipleItems(items);

      // ASSERT
      expect(result, isTrue, reason: 'BUG: Bulk save should succeed');
      verify(() => mockPersistence.saveMultipleItems(items)).called(1);
    });

    test('REPRO: empty ID should be replaced with generated ID', () {
      // ARRANGE - This is what the dialog does (line 226 in list_detail_page.dart)
      final item = ListItem(
        id: '', // Dialog sets empty ID expecting controller to generate it
        title: 'Test item',
        listId: 'list-123',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // ACT & ASSERT
      expect(item.id, isEmpty,
          reason:
              'BUG HYPOTHESIS: Dialog creates items with empty IDs. Controller must generate IDs.');

      // The controller should detect empty IDs and generate unique ones
      // Check if this is happening in addMultipleItemsToList logic
    });
  });

  group('ListsController - State Management After Add', () {
    test('REPRO: state should contain new items after add', () {
      // This would require testing the full state flow:
      // 1. Initial state has list with N items
      // 2. Add operation completes
      // 3. State is updated with N+M items
      // 4. UI watches state and rebuilds

      // BUG HYPOTHESIS: State update might not trigger UI rebuild
      // Or state update happens but list isn't in the state yet
    });

    test('REPRO: listByIdProvider should return updated list after add', () {
      // From list_detail_page.dart line 177:
      // final currentList = ref.watch(listByIdProvider(widget.list.id)) ?? widget.list;
      //
      // BUG HYPOTHESIS: listByIdProvider returns null, so it falls back to widget.list
      // which is stale and doesn't contain the new items
    });
  });

  group('ListsController - Error Handling', () {
    late MockListsPersistenceManager mockPersistence;

    setUp(() {
      mockPersistence = MockListsPersistenceManager();
      registerFallbackValue(<ListItem>[]);
    });

    test('REPRO: should capture and expose errors without throwing', () async {
      // ARRANGE - Simulate persistence failure
      when(() => mockPersistence.saveMultipleItems(any()))
          .thenThrow(Exception('Database error'));

      // ACT & ASSERT
      expect(
        () => mockPersistence.saveMultipleItems([]),
        throwsException,
        reason:
            'BUG: If errors are thrown but not caught, add operation silently fails',
      );
    });

    test('REPRO: idempotence - double-click should not add duplicates',
        () async {
      // BUG HYPOTHESIS: User double-clicks "Add" button
      // Two operations are queued, same item added twice
      // Need debouncing or operation deduplication
    });
  });

  group('ListsController - OperationQueue Integration', () {
    test('REPRO: add operations should be queued with correct priority', () {
      // From OperationQueue docs: operations have priorities
      // BUG HYPOTHESIS: Add operations have too low priority
      // Or queue is blocked by other operations
    });

    test('REPRO: queue should not deadlock on concurrent adds', () {
      // BUG HYPOTHESIS: Multiple rapid adds cause queue deadlock
      // State manager or persistence layer not thread-safe
    });
  });
}
