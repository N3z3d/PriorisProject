import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_controller_interfaces.dart';
import 'package:prioris/presentation/pages/lists/controllers/interfaces/lists_filter_service_interface.dart';

/// Test TDD pour IListsFilterService
///
/// Ces tests définissent le comportement attendu AVANT l'implémentation
/// selon la méthodologie TDD (Red-Green-Refactor).
void main() {
  group('IListsFilterService TDD Tests', () {
    // Test data setup
    late List<CustomList> testLists;
    late IListsFilterService filterService;

    setUp(() {
      // Setup test data - définit les données de test communes
      testLists = _createTestLists();
      // L'implémentation concrète sera injectée plus tard
      filterService = _MockListsFilterService();
    });

    group('TDD - applyFilters()', () {
      test('SHOULD return all lists WHEN no filters are applied', () {
        // ARRANGE
        const searchQuery = '';
        const selectedType = null;
        const showCompleted = true;
        const showInProgress = true;
        const selectedDateFilter = null;
        const sortOption = SortOption.NAME_ASC;

        // ACT
        final result = filterService.applyFilters(
          testLists,
          searchQuery: searchQuery,
          selectedType: selectedType,
          showCompleted: showCompleted,
          showInProgress: showInProgress,
          selectedDateFilter: selectedDateFilter,
          sortOption: sortOption,
        );

        // ASSERT
        expect(result.length, equals(testLists.length));
        expect(result, containsAll(testLists));
      });

      test('SHOULD filter by search query WHEN search query is provided', () {
        // ARRANGE
        const searchQuery = 'Shopping';
        final expectedLists = testLists.where((list) =>
          list.name.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();

        // ACT
        final result = filterService.applyFilters(
          testLists,
          searchQuery: searchQuery,
          selectedType: null,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        );

        // ASSERT
        expect(result.length, equals(expectedLists.length));
        expect(result.every((list) =>
          list.name.toLowerCase().contains(searchQuery.toLowerCase())), isTrue);
      });

      test('SHOULD filter by type WHEN selectedType is provided', () {
        // ARRANGE
        const selectedType = ListType.CUSTOM;
        final expectedLists = testLists.where((list) =>
          list.type == selectedType
        ).toList();

        // ACT
        final result = filterService.applyFilters(
          testLists,
          searchQuery: '',
          selectedType: selectedType,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        );

        // ASSERT
        expect(result.length, equals(expectedLists.length));
        expect(result.every((list) => list.type == selectedType), isTrue);
      });

      test('SHOULD hide completed lists WHEN showCompleted is false', () {
        // ARRANGE
        const showCompleted = false;
        const showInProgress = true;

        // ACT
        final result = filterService.applyFilters(
          testLists,
          searchQuery: '',
          selectedType: null,
          showCompleted: showCompleted,
          showInProgress: showInProgress,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        );

        // ASSERT
        expect(result.every((list) => !filterService.isListCompleted(list)), isTrue);
      });

      test('SHOULD apply multiple filters simultaneously', () {
        // ARRANGE
        const searchQuery = 'list';
        const selectedType = ListType.CUSTOM;
        const showCompleted = true;
        const showInProgress = false;

        // ACT
        final result = filterService.applyFilters(
          testLists,
          searchQuery: searchQuery,
          selectedType: selectedType,
          showCompleted: showCompleted,
          showInProgress: showInProgress,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        );

        // ASSERT
        expect(result.every((list) =>
          list.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
          list.type == selectedType
        ), isTrue);
      });
    });

    group('TDD - filterBySearchQuery()', () {
      test('SHOULD return empty list WHEN no lists match search query', () {
        // ARRANGE
        const searchQuery = 'NonExistentSearchTerm';

        // ACT
        final result = filterService.filterBySearchQuery(testLists, searchQuery);

        // ASSERT
        expect(result, isEmpty);
      });

      test('SHOULD search in list names case-insensitively', () {
        // ARRANGE
        const searchQuery = 'SHOPPING'; // Uppercase

        // ACT
        final result = filterService.filterBySearchQuery(testLists, searchQuery);

        // ASSERT
        expect(result.isNotEmpty, isTrue);
        expect(result.every((list) =>
          list.name.toLowerCase().contains(searchQuery.toLowerCase())), isTrue);
      });

      test('SHOULD search in list item titles', () {
        // ARRANGE
        const searchQuery = 'item'; // Should match items within lists

        // ACT
        final result = filterService.filterBySearchQuery(testLists, searchQuery);

        // ASSERT
        expect(result.isNotEmpty, isTrue);
      });

      test('SHOULD handle empty search query', () {
        // ARRANGE
        const searchQuery = '';

        // ACT
        final result = filterService.filterBySearchQuery(testLists, searchQuery);

        // ASSERT
        expect(result.length, equals(testLists.length));
      });
    });

    group('TDD - sortLists()', () {
      test('SHOULD sort by name ascending WHEN sortOption is NAME_ASC', () {
        // ARRANGE
        const sortOption = SortOption.NAME_ASC;

        // ACT
        final result = filterService.sortLists(testLists, sortOption);

        // ASSERT
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].name.toLowerCase().compareTo(result[i + 1].name.toLowerCase()),
            lessThanOrEqualTo(0));
        }
      });

      test('SHOULD sort by creation date WHEN sortOption is DATE_CREATED_DESC', () {
        // ARRANGE
        const sortOption = SortOption.DATE_CREATED_DESC;

        // ACT
        final result = filterService.sortLists(testLists, sortOption);

        // ASSERT
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].createdAt.isAfter(result[i + 1].createdAt) ||
            result[i].createdAt.isAtSameMomentAs(result[i + 1].createdAt), isTrue);
        }
      });
    });

    group('TDD - Cache Management', () {
      test('SHOULD cache filter results WHEN cacheFilterResults is called', () {
        // ARRANGE
        const cacheKey = 'test_filter_key';
        final testResults = [testLists.first];

        // ACT
        filterService.cacheFilterResults(cacheKey, testResults);
        final cachedResults = filterService.getCachedFilterResults(cacheKey);

        // ASSERT
        expect(cachedResults, isNotNull);
        expect(cachedResults!.length, equals(testResults.length));
      });

      test('SHOULD return null WHEN cache key does not exist', () {
        // ARRANGE
        const nonExistentKey = 'non_existent_key';

        // ACT
        final result = filterService.getCachedFilterResults(nonExistentKey);

        // ASSERT
        expect(result, isNull);
      });

      test('SHOULD clear cache WHEN clearCache is called', () {
        // ARRANGE
        const cacheKey = 'test_filter_key';
        final testResults = [testLists.first];
        filterService.cacheFilterResults(cacheKey, testResults);

        // ACT
        filterService.clearCache();
        final cachedResults = filterService.getCachedFilterResults(cacheKey);

        // ASSERT
        expect(cachedResults, isNull);
      });
    });

    group('TDD - Performance Stats', () {
      test('SHOULD return performance stats WHEN getPerformanceStats is called', () {
        // ACT
        final stats = filterService.getPerformanceStats();

        // ASSERT
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('filteringTime'), isTrue);
        expect(stats.containsKey('cacheHitRate'), isTrue);
      });

      test('SHOULD enable/disable cache WHEN setCacheEnabled is called', () {
        // ACT & ASSERT
        expect(() => filterService.setCacheEnabled(true), returnsNormally);
        expect(() => filterService.setCacheEnabled(false), returnsNormally);
      });
    });

    group('TDD - Helper Methods', () {
      test('SHOULD normalize search query WHEN normalizeSearchQuery is called', () {
        // ARRANGE
        const rawQuery = '  MIXED Case Query  ';

        // ACT
        final normalized = filterService.normalizeSearchQuery(rawQuery);

        // ASSERT
        expect(normalized, equals('mixed case query'));
      });

      test('SHOULD determine completion status WHEN isListCompleted is called', () {
        // ARRANGE
        final completedList = _createCompletedList();
        final incompleteList = _createIncompleteList();

        // ACT & ASSERT
        expect(filterService.isListCompleted(completedList), isTrue);
        expect(filterService.isListCompleted(incompleteList), isFalse);
      });
    });
  });
}

/// Mock implementation for TDD testing
/// Cette classe sera remplacée par l'implémentation réelle
class _MockListsFilterService implements IListsFilterService {
  final Map<String, List<CustomList>> _cache = {};
  bool _cacheEnabled = true;

  @override
  List<CustomList> applyFilters(
    List<CustomList> lists, {
    required String searchQuery,
    required ListType? selectedType,
    required bool showCompleted,
    required bool showInProgress,
    required String? selectedDateFilter,
    required SortOption sortOption,
  }) {
    var result = List<CustomList>.from(lists);

    if (searchQuery.isNotEmpty) {
      result = filterBySearchQuery(result, searchQuery);
    }

    if (selectedType != null) {
      result = filterByType(result, selectedType);
    }

    result = filterByCompletionStatus(result,
      showCompleted: showCompleted,
      showInProgress: showInProgress);

    if (selectedDateFilter != null) {
      result = filterByDate(result, selectedDateFilter);
    }

    result = sortLists(result, sortOption);

    return result;
  }

  @override
  List<CustomList> filterBySearchQuery(List<CustomList> lists, String searchQuery) {
    if (searchQuery.isEmpty) return lists;

    final normalizedQuery = normalizeSearchQuery(searchQuery);
    return lists.where((list) => matchesSearchQuery(list, normalizedQuery)).toList();
  }

  @override
  List<CustomList> filterByType(List<CustomList> lists, ListType? selectedType) {
    if (selectedType == null) return lists;
    return lists.where((list) => list.type == selectedType).toList();
  }

  @override
  List<CustomList> filterByCompletionStatus(
    List<CustomList> lists, {
    required bool showCompleted,
    required bool showInProgress,
  }) {
    return lists.where((list) {
      final isCompleted = isListCompleted(list);
      return (showCompleted && isCompleted) || (showInProgress && !isCompleted);
    }).toList();
  }

  @override
  List<CustomList> filterByDate(List<CustomList> lists, String? selectedDateFilter) {
    if (selectedDateFilter == null) return lists;
    return lists.where((list) => matchesDateFilter(list, selectedDateFilter)).toList();
  }

  @override
  List<CustomList> sortLists(List<CustomList> lists, SortOption sortOption) {
    final sortedLists = List<CustomList>.from(lists);

    switch (sortOption) {
      case SortOption.NAME_ASC:
        sortedLists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.NAME_DESC:
        sortedLists.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.DATE_CREATED_ASC:
        sortedLists.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.DATE_CREATED_DESC:
        sortedLists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.PROGRESS_ASC:
        // Tri par pourcentage de progression (croissant)
        sortedLists.sort((a, b) => _calculateProgress(a).compareTo(_calculateProgress(b)));
        break;
      case SortOption.PROGRESS_DESC:
        // Tri par pourcentage de progression (décroissant)
        sortedLists.sort((a, b) => _calculateProgress(b).compareTo(_calculateProgress(a)));
        break;
      default:
        break;
    }

    return sortedLists;
  }

  @override
  bool matchesSearchQuery(CustomList list, String searchQuery) {
    final listNameMatches = list.name.toLowerCase().contains(searchQuery.toLowerCase());
    final itemMatches = list.items.any((item) =>
      item.title.toLowerCase().contains(searchQuery.toLowerCase()));
    return listNameMatches || itemMatches;
  }

  @override
  bool isListCompleted(CustomList list) {
    if (list.items.isEmpty) return false;
    return list.items.every((item) => item.isCompleted);
  }

  @override
  bool matchesDateFilter(CustomList list, String? dateFilter) {
    // Implémentation simple pour les tests
    return true;
  }

  @override
  String normalizeSearchQuery(String query) {
    return query.trim().toLowerCase();
  }

  @override
  void cacheFilterResults(String cacheKey, List<CustomList> results) {
    if (_cacheEnabled) {
      _cache[cacheKey] = List<CustomList>.from(results);
    }
  }

  @override
  List<CustomList>? getCachedFilterResults(String cacheKey) {
    return _cache[cacheKey];
  }

  @override
  void clearCache() {
    _cache.clear();
  }

  @override
  String generateCacheKey({
    required String searchQuery,
    required ListType? selectedType,
    required bool showCompleted,
    required bool showInProgress,
    required String? selectedDateFilter,
    required SortOption sortOption,
  }) {
    return '${searchQuery}_${selectedType}_${showCompleted}_${showInProgress}_${selectedDateFilter}_$sortOption';
  }

  @override
  Map<String, dynamic> getPerformanceStats() {
    return {
      'filteringTime': 50, // ms
      'cacheHitRate': 0.75,
      'totalFilterOperations': 100,
    };
  }

  @override
  void setCacheEnabled(bool enabled) {
    _cacheEnabled = enabled;
  }

  @override
  void dispose() {
    _cache.clear();
  }

  /// Calcule le pourcentage de progression d'une liste
  double _calculateProgress(CustomList list) {
    if (list.items.isEmpty) return 0.0;
    final completedItems = list.items.where((item) => item.isCompleted).length;
    return completedItems / list.items.length;
  }
}

/// Helper functions pour créer les données de test
List<CustomList> _createTestLists() {
  return [
    CustomList(
      id: '1',
      name: 'Shopping List',
      type: ListType.SHOPPING,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      items: [
        ListItem(
          id: '1-1',
          title: 'Buy groceries',
          createdAt: DateTime(2024, 1, 1),
          listId: '1',
          isCompleted: false,
        ),
        ListItem(
          id: '1-2',
          title: 'Buy clothes',
          createdAt: DateTime(2024, 1, 2),
          listId: '1',
          isCompleted: true,
        ),
      ],
    ),
    CustomList(
      id: '2',
      name: 'Work Tasks',
      type: ListType.PROJECTS,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      items: [
        ListItem(
          id: '2-1',
          title: 'Complete project',
          createdAt: DateTime(2024, 1, 2),
          listId: '2',
          isCompleted: true,
        ),
        ListItem(
          id: '2-2',
          title: 'Review code',
          createdAt: DateTime(2024, 1, 3),
          listId: '2',
          isCompleted: true,
        ),
      ],
    ),
    CustomList(
      id: '3',
      name: 'Personal Goals',
      type: ListType.CUSTOM,
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      items: [],
    ),
  ];
}

CustomList _createCompletedList() {
  return CustomList(
    id: 'completed',
    name: 'Completed List',
    type: ListType.SHOPPING,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    items: [
      ListItem(
        id: 'item1',
        title: 'Task 1',
        createdAt: DateTime.now(),
        listId: 'completed',
        isCompleted: true,
      ),
      ListItem(
        id: 'item2',
        title: 'Task 2',
        createdAt: DateTime.now(),
        listId: 'completed',
        isCompleted: true,
      ),
    ],
  );
}

CustomList _createIncompleteList() {
  return CustomList(
    id: 'incomplete',
    name: 'Incomplete List',
    type: ListType.PROJECTS,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    items: [
      ListItem(
        id: 'item1',
        title: 'Task 1',
        createdAt: DateTime.now(),
        listId: 'incomplete',
        isCompleted: true,
      ),
      ListItem(
        id: 'item2',
        title: 'Task 2',
        createdAt: DateTime.now(),
        listId: 'incomplete',
        isCompleted: false, // Au moins un incomplete
      ),
    ],
  );
}