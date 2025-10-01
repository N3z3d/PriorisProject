import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_filter_manager.dart';

void main() {
  group('ListsFilterManager', () {
    late ListsFilterManager filterManager;
    late List<CustomList> testLists;
    late CustomList todoList;
    late CustomList shoppingList;
    late CustomList completedList;

    setUp(() {
      filterManager = ListsFilterManager();

      // Create test data
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final weekAgo = now.subtract(const Duration(days: 7));

      todoList = CustomList(
        id: 'todo-1',
        name: 'Work Tasks',
        type: ListType.TODO,
        createdAt: yesterday,
        updatedAt: now,
        items: [
          ListItem(
            id: 'item-1',
            title: 'Complete project',
            createdAt: yesterday,
            listId: 'todo-1',
            isCompleted: false,
          ),
          ListItem(
            id: 'item-2',
            title: 'Review code',
            createdAt: yesterday,
            listId: 'todo-1',
            isCompleted: true,
          ),
        ],
      );

      shoppingList = CustomList(
        id: 'shopping-1',
        name: 'Grocery Shopping',
        type: ListType.SHOPPING,
        createdAt: weekAgo,
        updatedAt: yesterday,
        items: [
          ListItem(
            id: 'item-3',
            title: 'Buy milk',
            createdAt: weekAgo,
            listId: 'shopping-1',
            isCompleted: false,
          ),
        ],
      );

      completedList = CustomList(
        id: 'completed-1',
        name: 'Finished Tasks',
        type: ListType.TODO,
        createdAt: weekAgo,
        updatedAt: yesterday,
        items: [
          ListItem(
            id: 'item-4',
            title: 'Old task',
            createdAt: weekAgo,
            listId: 'completed-1',
            isCompleted: true,
          ),
        ],
      );

      testLists = [todoList, shoppingList, completedList];
    });

    tearDown(() {
      filterManager.clearCache();
    });

    group('Search Filtering', () {
      test('filterBySearchQuery filters by list name', () {
        final result = filterManager.filterBySearchQuery(testLists, 'work');

        expect(result, hasLength(1));
        expect(result.first.name, contains('Work'));
      });

      test('filterBySearchQuery filters by item title', () {
        final result = filterManager.filterBySearchQuery(testLists, 'milk');

        expect(result, hasLength(1));
        expect(result.first.name, 'Grocery Shopping');
      });

      test('filterBySearchQuery is case insensitive', () {
        final result = filterManager.filterBySearchQuery(testLists, 'WORK');

        expect(result, hasLength(1));
        expect(result.first.name, contains('Work'));
      });

      test('filterBySearchQuery returns all lists for empty query', () {
        final result = filterManager.filterBySearchQuery(testLists, '');

        expect(result, hasLength(testLists.length));
      });

      test('filterBySearchQuery returns empty for non-matching query', () {
        final result = filterManager.filterBySearchQuery(testLists, 'nonexistent');

        expect(result, isEmpty);
      });
    });

    group('Type Filtering', () {
      test('filterByType filters by specific type', () {
        final result = filterManager.filterByType(testLists, ListType.TODO.toString());

        expect(result, hasLength(2));
        expect(result.every((list) => list.type == ListType.TODO), isTrue);
      });

      test('filterByType returns all lists for null type', () {
        final result = filterManager.filterByType(testLists, null);

        expect(result, hasLength(testLists.length));
      });

      test('filterByType returns all lists for invalid type', () {
        final result = filterManager.filterByType(testLists, 'INVALID_TYPE');

        expect(result, hasLength(testLists.length));
      });
    });

    group('Status Filtering', () {
      test('filterByStatus shows only completed lists', () {
        final result = filterManager.filterByStatus(
          testLists,
          showCompleted: true,
          showInProgress: false,
        );

        expect(result, hasLength(1));
        expect(result.first.name, 'Finished Tasks');
      });

      test('filterByStatus shows only in-progress lists', () {
        final result = filterManager.filterByStatus(
          testLists,
          showCompleted: false,
          showInProgress: true,
        );

        expect(result, hasLength(2));
        expect(result.any((list) => list.name == 'Finished Tasks'), isFalse);
      });

      test('filterByStatus shows all when both flags are true', () {
        final result = filterManager.filterByStatus(
          testLists,
          showCompleted: true,
          showInProgress: true,
        );

        expect(result, hasLength(testLists.length));
      });

      test('filterByStatus shows all when both flags are false', () {
        final result = filterManager.filterByStatus(
          testLists,
          showCompleted: false,
          showInProgress: false,
        );

        expect(result, hasLength(testLists.length));
      });
    });

    group('Date Filtering', () {
      test('filterByDate filters by today', () {
        final todayList = todoList.copyWith(createdAt: DateTime.now());
        final listsWithToday = [todayList, shoppingList];

        final result = filterManager.filterByDate(listsWithToday, 'today');

        expect(result, hasLength(1));
        expect(result.first.id, todayList.id);
      });

      test('filterByDate filters by week', () {
        final result = filterManager.filterByDate(testLists, 'week');

        // Lists created within the last week
        expect(result.length, greaterThan(0));
      });

      test('filterByDate returns all for null filter', () {
        final result = filterManager.filterByDate(testLists, null);

        expect(result, hasLength(testLists.length));
      });

      test('filterByDate returns all for unknown filter', () {
        final result = filterManager.filterByDate(testLists, 'unknown');

        expect(result, hasLength(testLists.length));
      });
    });

    group('Sorting', () {
      test('sortLists sorts by name ascending', () {
        final result = filterManager.sortLists(testLists, SortOption.NAME_ASC);

        expect(result.first.name, 'Finished Tasks'); // Alphabetically first
        expect(result.last.name, 'Work Tasks'); // Alphabetically last
      });

      test('sortLists sorts by name descending', () {
        final result = filterManager.sortLists(testLists, SortOption.NAME_DESC);

        expect(result.first.name, 'Work Tasks'); // Alphabetically last
        expect(result.last.name, 'Finished Tasks'); // Alphabetically first
      });

      test('sortLists sorts by creation date ascending', () {
        final result = filterManager.sortLists(testLists, SortOption.DATE_CREATED_ASC);

        // Oldest first
        expect(result.first.createdAt.isBefore(result.last.createdAt), isTrue);
      });

      test('sortLists sorts by creation date descending', () {
        final result = filterManager.sortLists(testLists, SortOption.DATE_CREATED_DESC);

        // Newest first
        expect(result.first.createdAt.isAfter(result.last.createdAt), isTrue);
      });

      test('sortLists does not modify original list', () {
        final originalOrder = List.from(testLists);

        filterManager.sortLists(testLists, SortOption.NAME_ASC);

        expect(testLists, equals(originalOrder));
      });
    });

    group('Complete Filtering', () {
      test('applyFilters applies all filters correctly', () {
        final state = ListsState(
          lists: testLists,
          searchQuery: 'tasks',
          showCompleted: false,
          showInProgress: true,
          sortOption: SortOption.NAME_ASC,
        );

        final result = filterManager.applyFilters(testLists, state);

        // Should find lists with "tasks" in name that are in progress
        expect(result.isNotEmpty, isTrue);
        expect(result.every((list) =>
          list.name.toLowerCase().contains('tasks') ||
          list.items.any((item) => item.title.toLowerCase().contains('tasks'))
        ), isTrue);
      });

      test('applyFilters uses cache for repeated calls', () {
        final state = ListsState(
          lists: testLists,
          searchQuery: 'work',
          sortOption: SortOption.NAME_ASC,
        );

        // First call
        final result1 = filterManager.applyFilters(testLists, state);

        // Second call with same parameters should use cache
        final result2 = filterManager.applyFilters(testLists, state);

        expect(result1, equals(result2));

        final stats = filterManager.getCacheStats();
        expect(stats['cacheHits'], greaterThan(0));
      });
    });

    group('Cache Management', () {
      test('clearCache removes all cached results', () {
        final state = ListsState(
          lists: testLists,
          searchQuery: 'test',
        );

        // Populate cache
        filterManager.applyFilters(testLists, state);

        // Clear cache
        filterManager.clearCache();

        final stats = filterManager.getCacheStats();
        expect(stats['cacheSize'], 0);
      });

      test('getCacheStats returns correct statistics', () {
        final state = ListsState(lists: testLists);

        // Generate some cache hits and misses
        filterManager.applyFilters(testLists, state);
        filterManager.applyFilters(testLists, state); // Cache hit
        filterManager.applyFilters(testLists, state.copyWith(searchQuery: 'different')); // Cache miss

        final stats = filterManager.getCacheStats();

        expect(stats['totalFilterOperations'], 3);
        expect(stats['cacheHits'], 1);
        expect(stats['cacheMisses'], 2);
        expect(stats['hitRate'], closeTo(0.33, 0.1));
      });

      test('resetStats clears performance statistics', () {
        final state = ListsState(lists: testLists);

        // Generate some activity
        filterManager.applyFilters(testLists, state);

        // Reset stats
        filterManager.resetStats();

        final stats = filterManager.getCacheStats();
        expect(stats['totalFilterOperations'], 0);
        expect(stats['cacheHits'], 0);
        expect(stats['cacheMisses'], 0);
      });
    });

    group('Performance Optimization', () {
      test('applyOptimizedFilters handles large collections', () {
        // Create a large collection
        final largeLists = List.generate(1500, (index) => CustomList(
          id: 'list-$index',
          name: 'List $index',
          type: ListType.TODO,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: [],
        ));

        final state = ListsState(
          lists: largeLists,
          searchQuery: '100', // Should match some lists
        );

        final result = filterManager.applyOptimizedFilters(largeLists, state);

        expect(result.isNotEmpty, isTrue);
        expect(result.every((list) => list.name.contains('100')), isTrue);
      });

      test('applyOptimizedFilters falls back to normal filtering for small collections', () {
        final state = ListsState(lists: testLists);

        final optimizedResult = filterManager.applyOptimizedFilters(testLists, state);
        final normalResult = filterManager.applyFilters(testLists, state);

        expect(optimizedResult, equals(normalResult));
      });
    });

    group('Error Handling', () {
      test('filtering handles empty lists gracefully', () {
        final emptyLists = <CustomList>[];
        final state = ListsState(lists: emptyLists);

        final result = filterManager.applyFilters(emptyLists, state);

        expect(result, isEmpty);
      });

      test('filtering handles null values gracefully', () {
        final state = ListsState(
          lists: testLists,
          selectedType: null,
          selectedDateFilter: null,
        );

        expect(() => filterManager.applyFilters(testLists, state), returnsNormally);
      });
    });
  });
}