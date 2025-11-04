import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';

void main() {
  group('ListsCrudOperations', () {
    late _TestPersistenceManager persistence;
    late _TestValidationService validator;
    late _TestFilterManager filterManager;
    late ListsCrudOperations operations;
    final stateManager = ListsStateManager();
    final logger = _SilentLogger();

    setUp(() {
      persistence = _TestPersistenceManager();
      validator = _TestValidationService();
      filterManager = _TestFilterManager();
      operations = ListsCrudOperations(
        persistence: persistence,
        validator: validator,
        filterManager: filterManager,
        stateManager: stateManager,
        logger: logger,
      );
    });

    test('createList valide, persiste et ré-applique les filtres', () async {
      final now = DateTime.now();
      final list = CustomList(
        id: 'list-1',
        name: 'Liste A',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
      );

      filterManager.stubbedFilteredLists = [list];

      final result = await operations.createList(const ListsState.initial(), list);

      expect(validator.validatedLists, contains(list));
      expect(persistence.savedLists, contains(list));
      expect(persistence.verifyListCalls, contains('list-1'));
      expect(filterManager.applyFiltersCount, 1);
      expect(result.lists, contains(list));
      expect(result.filteredLists, equals([list]));
    });

    test('addMultipleItems valide chaque item puis persiste', () async {
      final now = DateTime.now();
      final listId = 'list-2';
      final items = List.generate(
        3,
        (index) => ListItem(
          id: 'item-$index',
          title: 'Titre $index',
          listId: listId,
          createdAt: now.add(Duration(minutes: index)),
        ),
      );
      final initialState = const ListsState.initial();

      final result = await operations.addMultipleItems(initialState, listId, items);

      expect(validator.validatedItems, equals(items));
      expect(persistence.savedItemBatches.single, equals(items));
      expect(result.lists, hasLength(initialState.lists.length));
      expect(filterManager.applyFiltersCount, 1);
    });

    test('changeSortOption applique le filtre et renvoie Future résolu', () async {
      final initialState = const ListsState.initial();
      final future = operations.changeSortOption(initialState, SortOption.DATE_CREATED_DESC);
      final result = await future;

      expect(filterManager.applyFiltersCount, 1);
      expect(result.sortOption, SortOption.DATE_CREATED_DESC);
    });

    test('createList lève ArgumentError lorsque la validation échoue', () async {
      validator.shouldValidateLists = false;
      final now = DateTime.now();
      final invalidList = CustomList(
        id: 'invalid',
        name: 'Invalid',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => operations.createList(const ListsState.initial(), invalidList),
        throwsArgumentError,
      );
      expect(persistence.savedLists, isEmpty);
      expect(filterManager.applyFiltersCount, 0);
    });
  });
}

class _TestPersistenceManager implements IListsPersistenceManager {
  final List<CustomList> savedLists = [];
  final List<List<ListItem>> savedItemBatches = [];
  final List<String> verifyListCalls = [];

  @override
  Future<void> saveList(CustomList list) async {
    savedLists.add(list);
  }

  @override
  Future<void> verifyListPersistence(String listId) async {
    verifyListCalls.add(listId);
  }

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {
    savedItemBatches.add(List.from(items));
  }

  @override
  Future<void> saveListItem(ListItem item) async {
    savedItemBatches.add([item]);
  }

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> updateList(CustomList list) async {
    savedLists.add(list);
  }

  @override
  Future<void> updateListItem(ListItem item) async {}

  @override
  Future<void> deleteList(String listId) async {}

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<List<CustomList>> loadAllLists() async => [];

  @override
  Future<List<ListItem>> loadListItems(String listId) async => [];

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async => [];

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> rollbackItems(List<ListItem> items) async {}
}

class _TestValidationService implements IListsValidationService {
  bool shouldValidateLists = true;
  bool shouldValidateItems = true;
  final List<CustomList> validatedLists = [];
  final List<ListItem> validatedItems = [];

  @override
  bool validateList(CustomList list) {
    validatedLists.add(list);
    return shouldValidateLists;
  }

  @override
  bool validateListItem(ListItem item) {
    validatedItems.add(item);
    return shouldValidateItems;
  }

  @override
  List<CustomList> sanitizeLists(List<CustomList> lists) => lists;

  @override
  bool validateState(ListsState state) => true;

  @override
  bool validateListsCollection(List<CustomList> lists) => true;

  @override
  List<String> getListValidationErrors(CustomList list) => const [];

  @override
  List<String> getItemValidationErrors(ListItem item) => const [];

  @override
  List<String> getStateValidationErrors(ListsState state) => const [];

  @override
  bool checkReferentialIntegrity(List<CustomList> lists) => true;
}

class _TestFilterManager implements IListsFilterManager {
  int applyFiltersCount = 0;
  List<CustomList>? stubbedFilteredLists;

  @override
  List<CustomList> applyFilters(List<CustomList> lists, ListsState state) {
    applyFiltersCount++;
    return stubbedFilteredLists ?? lists;
  }

  @override
  List<CustomList> filterBySearchQuery(List<CustomList> lists, String searchQuery) => lists;

  @override
  List<CustomList> filterByType(List<CustomList> lists, String? selectedType) => lists;

  @override
  List<CustomList> filterByStatus(
    List<CustomList> lists, {
    required bool showCompleted,
    required bool showInProgress,
  }) =>
      lists;

  @override
  List<CustomList> filterByDate(List<CustomList> lists, String? dateFilter) => lists;

  @override
  List<CustomList> sortLists(List<CustomList> lists, SortOption sortOption) => lists;

  @override
  void clearCache() {}

  @override
  List<CustomList> applyOptimizedFilters(List<CustomList> lists, ListsState state) => lists;
}

class _SilentLogger implements ILogger {
  @override
  void debug(String message, {String? context, String? correlationId, data}) {}

  @override
  void info(String message, {String? context, String? correlationId, data}) {}

  @override
  void warning(String message, {String? context, String? correlationId, data}) {}

  @override
  void error(String message, {String? context, String? correlationId, error, StackTrace? stackTrace}) {}

  @override
  void fatal(String message, {String? context, String? correlationId, error, StackTrace? stackTrace}) {}

  @override
  void performance(String operation, Duration duration, {String? context, String? correlationId, Map<String, dynamic>? metrics}) {}

  @override
  void userAction(String action, {String? context, String? correlationId, Map<String, dynamic>? properties}) {}
}
