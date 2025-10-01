import 'package:mockito/mockito.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Centralized mock factory for consistent test setup
///
/// Provides pre-configured mocks with sensible defaults to prevent
/// test performance issues and initialization failures.
class MockFactory {
  /// Creates a fast-responding mock AdaptivePersistenceService
  static MockAdaptivePersistenceService createMockAdaptivePersistenceService({
    List<CustomList>? mockLists,
    List<ListItem>? mockItems,
  }) {
    final mock = MockAdaptivePersistenceService();

    // Fast initialization - no delays
    when(mock.initialize(isAuthenticated: any))
        .thenAnswer((_) async {});

    // Return provided lists or empty list
    when(mock.getAllLists())
        .thenAnswer((_) async => mockLists ?? <CustomList>[]);

    // Return provided items or empty list
    when(mock.getItemsByListId(any))
        .thenAnswer((_) async => mockItems ?? <ListItem>[]);

    // Fast save operations
    when(mock.saveList(any))
        .thenAnswer((_) async {});

    when(mock.saveItem(any))
        .thenAnswer((_) async {});

    when(mock.deleteList(any))
        .thenAnswer((_) async {});

    return mock;
  }

  /// Creates a fast-responding mock CustomListRepository
  static MockCustomListRepository createMockCustomListRepository({
    List<CustomList>? mockLists,
  }) {
    final mock = MockCustomListRepository();

    when(mock.getAllLists())
        .thenAnswer((_) async => mockLists ?? <CustomList>[]);

    when(mock.getListById(any))
        .thenAnswer((invocation) async {
      final id = invocation.positionalArguments[0] as String;
      return mockLists?.firstWhere(
        (list) => list.id == id,
        orElse: () => throw StateError('List not found'),
      );
    });

    when(mock.saveList(any))
        .thenAnswer((_) async {});

    when(mock.updateList(any))
        .thenAnswer((_) async {});

    when(mock.deleteList(any))
        .thenAnswer((_) async {});

    return mock;
  }

  /// Creates a fast-responding mock ListItemRepository
  static MockListItemRepository createMockListItemRepository({
    List<ListItem>? mockItems,
  }) {
    final mock = MockListItemRepository();

    when(mock.getByListId(any))
        .thenAnswer((invocation) async {
      final listId = invocation.positionalArguments[0] as String;
      return mockItems?.where((item) => item.listId == listId).toList() ?? <ListItem>[];
    });

    when(mock.getById(any))
        .thenAnswer((invocation) async {
      final id = invocation.positionalArguments[0] as String;
      return mockItems?.firstWhere(
        (item) => item.id == id,
        orElse: () => throw StateError('Item not found'),
      );
    });

    when(mock.add(any))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as ListItem);

    when(mock.update(any))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as ListItem);

    when(mock.delete(any))
        .thenAnswer((_) async {});

    return mock;
  }

  /// Creates a fast-responding mock ListsFilterService
  static MockListsFilterService createMockListsFilterService() {
    final mock = MockListsFilterService();

    when(mock.applyFilters(
      any,
      searchQuery: anyNamed('searchQuery'),
      selectedType: anyNamed('selectedType'),
      showCompleted: anyNamed('showCompleted'),
      showInProgress: anyNamed('showInProgress'),
      selectedDateFilter: anyNamed('selectedDateFilter'),
      sortOption: anyNamed('sortOption'),
    )).thenAnswer((invocation) {
      // Pass through lists unchanged for simple tests
      return invocation.positionalArguments[0] as List<CustomList>;
    });

    return mock;
  }

  /// Creates a complete test environment with all necessary mocks
  static TestEnvironment createTestEnvironment({
    List<CustomList>? testLists,
    List<ListItem>? testItems,
  }) {
    return TestEnvironment(
      adaptiveService: createMockAdaptivePersistenceService(
        mockLists: testLists,
        mockItems: testItems,
      ),
      customListRepo: createMockCustomListRepository(mockLists: testLists),
      listItemRepo: createMockListItemRepository(mockItems: testItems),
      filterService: createMockListsFilterService(),
    );
  }
}

/// Container for a complete test environment
class TestEnvironment {
  final MockAdaptivePersistenceService adaptiveService;
  final MockCustomListRepository customListRepo;
  final MockListItemRepository listItemRepo;
  final MockListsFilterService filterService;

  TestEnvironment({
    required this.adaptiveService,
    required this.customListRepo,
    required this.listItemRepo,
    required this.filterService,
  });
}

// Generate the required mocks if they don't exist
class MockAdaptivePersistenceService extends Mock implements AdaptivePersistenceService {}
class MockCustomListRepository extends Mock implements CustomListRepository {}
class MockListItemRepository extends Mock implements ListItemRepository {}
class MockListsFilterService extends Mock implements ListsFilterService {}