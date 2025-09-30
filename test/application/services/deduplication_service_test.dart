/// TDD Tests for DeduplicationService
/// Follows Red → Green → Refactor methodology
/// Tests written to validate P0 critical service (Deduplication Strategy)

import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/application/services/deduplication_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('DeduplicationService Tests - P0 Critical Service', () {
    late DeduplicationService deduplicationService;

    final now = DateTime.now();
    final later = now.add(const Duration(hours: 1));

    setUp(() {
      deduplicationService = DeduplicationService();
    });

    group('List Deduplication Tests', () {
      test('should return empty list when input is empty', () {
        // GIVEN
        final emptyLists = <CustomList>[];

        // WHEN
        final result = deduplicationService.deduplicateLists(emptyLists);

        // THEN
        expect(result, isEmpty);
      });

      test('should return same lists when no duplicates', () {
        // GIVEN
        final list1 = CustomList(
          id: 'list-1',
          name: 'List 1',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final list2 = CustomList(
          id: 'list-2',
          name: 'List 2',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        // WHEN
        final result = deduplicationService.deduplicateLists([list1, list2]);

        // THEN
        expect(result, hasLength(2));
        expect(result.map((l) => l.id), containsAll(['list-1', 'list-2']));
      });

      test('should remove duplicate lists and keep most recent', () {
        // GIVEN
        final oldList = CustomList(
          id: 'list-123',
          name: 'Old Version',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final newList = CustomList(
          id: 'list-123',
          name: 'New Version',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later,
        );

        // WHEN
        final result = deduplicationService.deduplicateLists([oldList, newList]);

        // THEN
        expect(result, hasLength(1));
        expect(result.first.name, equals('New Version'));
        expect(result.first.updatedAt, equals(later));
      });

      test('should handle multiple duplicates of same ID', () {
        // GIVEN
        final list1 = CustomList(
          id: 'list-123',
          name: 'Version 1',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final list2 = CustomList(
          id: 'list-123',
          name: 'Version 2',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later,
        );
        final list3 = CustomList(
          id: 'list-123',
          name: 'Version 3',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later.add(const Duration(hours: 1)),
        );

        // WHEN
        final result = deduplicationService.deduplicateLists([list1, list2, list3]);

        // THEN
        expect(result, hasLength(1));
        expect(result.first.name, equals('Version 3'));
      });

      test('should prefer incoming when timestamps are equal', () {
        // GIVEN
        final existingList = CustomList(
          id: 'list-123',
          name: 'Existing',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final incomingList = CustomList(
          id: 'list-123',
          name: 'Incoming',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        // WHEN
        final result = deduplicationService.deduplicateLists([existingList, incomingList]);

        // THEN
        expect(result, hasLength(1));
        expect(result.first.name, equals('Incoming'));
      });
    });

    group('SaveListWithDeduplication Tests', () {
      test('should call saveOperation when no conflict', () async {
        // GIVEN
        final list = CustomList(
          id: 'list-123',
          name: 'Test List',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        var saveCalled = false;
        Future<void> saveOperation(CustomList l) async {
          saveCalled = true;
        }
        Future<CustomList?> getExisting(String id) async => null;
        Future<void> updateOperation(CustomList l) async {}

        // WHEN
        await deduplicationService.saveListWithDeduplication(
          list,
          saveOperation,
          getExisting,
          updateOperation,
        );

        // THEN
        expect(saveCalled, isTrue);
      });

      test('should call updateOperation on ID conflict', () async {
        // GIVEN
        final existingList = CustomList(
          id: 'list-123',
          name: 'Existing',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final newList = CustomList(
          id: 'list-123',
          name: 'New',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later,
        );

        var updateCalled = false;
        CustomList? updatedList;

        Future<void> saveOperation(CustomList l) async {
          throw Exception('Une liste avec cet ID existe déjà');
        }
        Future<CustomList?> getExisting(String id) async => existingList;
        Future<void> updateOperation(CustomList l) async {
          updateCalled = true;
          updatedList = l;
        }

        // WHEN
        await deduplicationService.saveListWithDeduplication(
          newList,
          saveOperation,
          getExisting,
          updateOperation,
        );

        // THEN
        expect(updateCalled, isTrue);
        expect(updatedList, isNotNull);
        expect(updatedList!.name, equals('New')); // More recent version
      });

      test('should rethrow non-conflict errors', () async {
        // GIVEN
        final list = CustomList(
          id: 'list-123',
          name: 'Test List',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        Future<void> saveOperation(CustomList l) async {
          throw Exception('Network error');
        }
        Future<CustomList?> getExisting(String id) async => null;
        Future<void> updateOperation(CustomList l) async {}

        // WHEN & THEN
        await expectLater(
          deduplicationService.saveListWithDeduplication(
            list,
            saveOperation,
            getExisting,
            updateOperation,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should retry saveOperation when existingList is null after conflict', () async {
        // GIVEN
        final list = CustomList(
          id: 'list-123',
          name: 'Test List',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        var saveCallCount = 0;
        Future<void> saveOperation(CustomList l) async {
          saveCallCount++;
          if (saveCallCount == 1) {
            throw Exception('duplicate key');
          }
        }
        Future<CustomList?> getExisting(String id) async => null;
        Future<void> updateOperation(CustomList l) async {}

        // WHEN
        await deduplicationService.saveListWithDeduplication(
          list,
          saveOperation,
          getExisting,
          updateOperation,
        );

        // THEN
        expect(saveCallCount, equals(2)); // First attempt + retry
      });
    });

    group('SaveItemWithDeduplication Tests', () {
      test('should call addOperation when no conflict', () async {
        // GIVEN
        final item = ListItem(
          id: 'item-123',
          listId: 'list-1',
          title: 'Test Item',
          createdAt: now,
        );

        var addCalled = false;
        Future<void> addOperation(ListItem i) async {
          addCalled = true;
        }
        Future<ListItem?> getById(String id) async => null;
        Future<void> updateOperation(ListItem i) async {}

        // WHEN
        await deduplicationService.saveItemWithDeduplication(
          item,
          addOperation,
          getById,
          updateOperation,
        );

        // THEN
        expect(addCalled, isTrue);
      });

      test('should call updateOperation on item ID conflict', () async {
        // GIVEN
        final existingItem = ListItem(
          id: 'item-123',
          listId: 'list-1',
          title: 'Existing Item',
          createdAt: now,
        );
        final newItem = ListItem(
          id: 'item-123',
          listId: 'list-1',
          title: 'New Item',
          createdAt: later,
        );

        var updateCalled = false;
        ListItem? updatedItem;

        Future<void> addOperation(ListItem i) async {
          throw Exception('Un item avec cet id existe déjà');
        }
        Future<ListItem?> getById(String id) async => existingItem;
        Future<void> updateOperation(ListItem i) async {
          updateCalled = true;
          updatedItem = i;
        }

        // WHEN
        await deduplicationService.saveItemWithDeduplication(
          newItem,
          addOperation,
          getById,
          updateOperation,
        );

        // THEN
        expect(updateCalled, isTrue);
        expect(updatedItem, isNotNull);
        expect(updatedItem!.title, equals('New Item')); // More recent version
      });
    });

    group('Statistics and Validation Tests', () {
      test('should calculate deduplication stats for lists', () {
        // GIVEN
        final list1 = CustomList(
          id: 'list-1',
          name: 'List 1',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final list2 = CustomList(
          id: 'list-1',
          name: 'List 1 Duplicate',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final list3 = CustomList(
          id: 'list-2',
          name: 'List 2',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        // WHEN
        final stats = deduplicationService.getDeduplicationStats([list1, list2, list3]);

        // THEN
        expect(stats['totalItems'], equals(3));
        expect(stats['uniqueItems'], equals(2));
        expect(stats['duplicateCount'], equals(1));
        expect(stats['duplicateRate'], equals('33.3'));
        expect(stats['duplicateIds'], hasLength(1));
      });

      test('should return zero stats for empty list', () {
        // WHEN
        final stats = deduplicationService.getDeduplicationStats([]);

        // THEN
        expect(stats['totalItems'], equals(0));
        expect(stats['uniqueItems'], equals(0));
        expect(stats['duplicateCount'], equals(0));
        expect(stats['duplicateRate'], equals('0.0'));
      });

      test('should validate deduplication success', () {
        // GIVEN
        final list1 = CustomList(
          id: 'list-1',
          name: 'List 1',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final list2 = CustomList(
          id: 'list-1',
          name: 'List 1 Duplicate',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        final original = [list1, list2];
        final deduplicated = [list1];

        // WHEN
        final isValid = deduplicationService.validateDeduplication(original, deduplicated);

        // THEN
        expect(isValid, isTrue);
      });

      test('should detect validation failure when duplicates remain', () {
        // GIVEN
        final list1 = CustomList(
          id: 'list-1',
          name: 'List 1',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final list2 = CustomList(
          id: 'list-1',
          name: 'List 1 Duplicate',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        final original = [list1, list2];
        final deduplicated = [list1, list2]; // Still has duplicates!

        // WHEN
        final isValid = deduplicationService.validateDeduplication(original, deduplicated);

        // THEN
        expect(isValid, isFalse);
      });
    });

    group('Merge and Deduplicate Tests', () {
      test('should merge two lists without duplicates', () {
        // GIVEN
        final list1 = [
          CustomList(
            id: 'list-1',
            name: 'List 1',
            type: ListType.CUSTOM,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        final list2 = [
          CustomList(
            id: 'list-2',
            name: 'List 2',
            type: ListType.CUSTOM,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // WHEN
        final result = deduplicationService.mergeAndDeduplicate<CustomList>(
          list1,
          list2,
          (list) => list.id,
          (existing, incoming) => incoming,
        );

        // THEN
        expect(result, hasLength(2));
      });

      test('should resolve conflicts when merging lists with duplicates', () {
        // GIVEN
        final oldList = CustomList(
          id: 'list-123',
          name: 'Old Version',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final newList = CustomList(
          id: 'list-123',
          name: 'New Version',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later,
        );

        final list1 = [oldList];
        final list2 = [newList];

        // WHEN
        final result = deduplicationService.mergeAndDeduplicate<CustomList>(
          list1,
          list2,
          (list) => list.id,
          (existing, incoming) {
            // Conflict resolver: prefer most recent
            return incoming.updatedAt.isAfter(existing.updatedAt) ? incoming : existing;
          },
        );

        // THEN
        expect(result, hasLength(1));
        expect(result.first.name, equals('New Version'));
      });

      test('should merge items with custom conflict resolver', () {
        // GIVEN
        final item1 = ListItem(
          id: 'item-123',
          listId: 'list-1',
          title: 'Item Old',
          createdAt: now,
        );
        final item2 = ListItem(
          id: 'item-123',
          listId: 'list-1',
          title: 'Item New',
          createdAt: later,
        );

        final list1 = [item1];
        final list2 = [item2];

        // WHEN
        final result = deduplicationService.mergeAndDeduplicate<ListItem>(
          list1,
          list2,
          (item) => item.id,
          (existing, incoming) {
            // Prefer most recent by createdAt
            return incoming.createdAt.isAfter(existing.createdAt) ? incoming : existing;
          },
        );

        // THEN
        expect(result, hasLength(1));
        expect(result.first.title, equals('Item New'));
      });
    });
  });
}
