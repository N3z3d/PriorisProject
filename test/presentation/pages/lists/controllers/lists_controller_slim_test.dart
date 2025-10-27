import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/refactored/lists_controller_slim.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_validation_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_filter_manager.dart';
import 'package:prioris/presentation/pages/lists/services/list_item_sync_service.dart';

Future<void> _waitForInitialization(ListsControllerSlim controller) async {
  const pollInterval = Duration(milliseconds: 10);
  while (!controller.isInitialized) {
    await Future<void>.delayed(pollInterval);
  }
  // Laisse le temps au cycle de chargement initial de se terminer.
  await Future<void>.delayed(pollInterval);
}

void main() {
  group('ListsControllerSlim', () {
    late _InMemoryPersistence persistence;
    late ListsStateManager stateManager;
    late ListItemSyncService syncService;
    late ListsControllerSlim controller;
    late _RecordingLogger logger;
    late CustomList initialList;

    setUp(() async {
      logger = _RecordingLogger();
      stateManager = ListsStateManager();
      syncService = ListItemSyncService(stateManager);

      final now = DateTime(2024, 1, 1);
      initialList = CustomList(
        id: 'list-1',
        name: 'Liste de test',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
        items: [
          ListItem(
            id: 'item-1',
            title: 'Tâche existante',
            listId: 'list-1',
            createdAt: now,
            eloScore: 1300,
          ),
        ],
      );

      persistence = _InMemoryPersistence([initialList]);

      final crud = ListsCrudOperations(
        persistence: persistence,
        validator: ListsValidationService(),
        filterManager: ListsFilterManager(),
        stateManager: stateManager,
        logger: logger,
      );

      controller = ListsControllerSlim(
        initializationManager: const _ImmediateInitManager(),
        performanceMonitor: _SilentPerformanceMonitor(),
        crudOperations: crud,
        stateManager: stateManager,
        syncService: syncService,
        logger: logger,
      );

      await _waitForInitialization(controller);
    });

    tearDown(() {
      controller.dispose();
    });

    test('loadLists charge les données et désactive le chargement', () {
      final state = controller.state;

      expect(state.isLoading, isFalse);
      expect(state.lists, isNotEmpty);
      expect(state.filteredLists.length, equals(1));
      expect(state.lists.first.id, equals(initialList.id));
      expect(persistence.loadInvocations, equals(1));
    });

    test('createList ajoute une nouvelle liste dans l’état', () async {
      final now = DateTime(2024, 2, 2);
      final newList = CustomList(
        id: 'list-2',
        name: 'Nouvelle liste',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
      );

      await controller.createList(newList);

      expect(controller.state.lists.map((list) => list.id),
          containsAll(['list-1', 'list-2']));
      expect(persistence.savedListIds, contains('list-2'));
    });

    test('updateSearchQuery met à jour la requête et filtre les résultats', () {
      controller.updateSearchQuery('Tâche');
      expect(controller.state.searchQuery, equals('Tâche'));
      expect(controller.state.filteredLists.first.items.length, equals(1));
    });

    test('addListItem ajoute l’élément et remet les flags de synchronisation',
        () async {
      final newItem = ListItem(
        id: 'item-2',
        title: 'Nouvelle tâche',
        listId: initialList.id,
        createdAt: DateTime(2024, 3, 3),
        eloScore: 1280,
      );

      await controller.addListItem(initialList.id, newItem);

      final updated =
          controller.state.findListById(initialList.id)?.items ?? const [];
      expect(updated.map((item) => item.id), contains('item-2'));
      expect(controller.state.syncingItemIds, isEmpty);
    });

    test('addMultipleItems gère les ajouts groupés et vide les flags',
        () async {
      final items = List.generate(
        3,
        (index) => ListItem(
          id: 'batch-${index + 1}',
          title: 'Batch ${index + 1}',
          listId: initialList.id,
          createdAt: DateTime(2024, 4, index + 1),
          eloScore: 1250 + index * 10,
        ),
      );

      await controller.addMultipleItemsToList(initialList.id, items);

      final updated =
          controller.state.findListById(initialList.id)?.items ?? const [];
      expect(updated.map((item) => item.id),
          containsAll(['batch-1', 'batch-2', 'batch-3']));
      expect(controller.state.syncingItemIds, isEmpty);
    });

    test(
        'une erreur pendant la synchronisation nettoie les flags et relance l’exception',
        () async {
      persistence.throwOnSaveListItem = true;
      final failingItem = ListItem(
        id: 'item-error',
        title: 'Erreur',
        listId: initialList.id,
        createdAt: DateTime(2024, 5, 5),
      );

      await expectLater(
        () => controller.addListItem(initialList.id, failingItem),
        throwsA(isA<StateError>()),
      );

      expect(controller.state.syncingItemIds, isEmpty);
      expect(logger.errors.length, isPositive);
    });

    test('dispose empêche les opérations ultérieures', () async {
      controller.dispose();
      final loadsBefore = persistence.loadInvocations;

      await controller.loadLists();

      expect(persistence.loadInvocations, equals(loadsBefore));
    });
  });
}

class _InMemoryPersistence implements IListsPersistenceManager {
  List<CustomList> _lists;
  bool throwOnSaveListItem = false;
  int loadInvocations = 0;
  final Set<String> savedListIds = {};

  _InMemoryPersistence(List<CustomList> seed)
      : _lists = List<CustomList>.from(seed);

  @override
  Future<void> clearAllData() async {
    _lists = [];
  }

  @override
  Future<void> deleteList(String listId) async {
    _lists = _lists.where((list) => list.id != listId).toList();
  }

  @override
  Future<void> deleteListItem(String itemId) async {
    _lists = _lists
        .map((list) => list.removeItem(itemId))
        .toList(growable: false);
  }

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async {
    loadInvocations += 1;
    return List<CustomList>.unmodifiable(_lists);
  }

  @override
  Future<List<CustomList>> loadAllLists() async {
    loadInvocations += 1;
    return List<CustomList>.unmodifiable(_lists);
  }

  @override
  Future<List<ListItem>> loadListItems(String listId) async {
    return List<ListItem>.unmodifiable(
      _lists.firstWhere((list) => list.id == listId).items,
    );
  }

  @override
  Future<void> rollbackItems(List<ListItem> items) async {
    for (final item in items) {
      await deleteListItem(item.id);
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    savedListIds.add(list.id);
    _lists = [
      ..._lists.where((existing) => existing.id != list.id),
      list,
    ];
  }

  @override
  Future<void> saveListItem(ListItem item) async {
    if (throwOnSaveListItem) {
      throw StateError('Simulated persistence failure');
    }
    _lists = _lists
        .map((list) =>
            list.id == item.listId ? list.addItem(item) : list)
        .toList(growable: false);
  }

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {
    for (final item in items) {
      await saveListItem(item);
    }
  }

  @override
  Future<void> updateList(CustomList list) async {
    _lists = _lists
        .map((existing) => existing.id == list.id ? list : existing)
        .toList(growable: false);
  }

  @override
  Future<void> updateListItem(ListItem item) async {
    _lists = _lists
        .map((list) =>
            list.id == item.listId ? list.updateItem(item) : list)
        .toList(growable: false);
  }

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> verifyListPersistence(String listId) async {}
}

class _ImmediateInitManager implements IListsInitializationManager {
  const _ImmediateInitManager();

  @override
  Future<void> initializeAdaptive() async {}

  @override
  Future<void> initializeAsync() async {}

  @override
  Future<void> initializeLegacy() async {}

  @override
  bool get isInitialized => true;

  @override
  String get initializationMode => 'immediate';
}

class _SilentPerformanceMonitor implements IListsPerformanceMonitor {
  @override
  void endOperation(String operationName) {}

  @override
  Map<String, dynamic> getDetailedMetrics() => const {};

  @override
  Map<String, dynamic> getPerformanceStats() => const {};

  @override
  void logError(String operation, Object error, [StackTrace? stackTrace]) {}

  @override
  void logInfo(String message, {String? context}) {}

  @override
  void logWarning(String message, {String? context}) {}

  @override
  void monitorCacheOperation(String operation, bool hit) {}

  @override
  void monitorCollectionSize(String collection, int size) {}

  @override
  void resetStats() {}

  @override
  void startOperation(String operationName) {}
}

class _RecordingLogger implements ILogger {
  final List<String> infos = [];
  final List<String> errors = [];

  @override
  void debug(String message,
      {String? context, String? correlationId, dynamic data}) {}

  @override
  void error(String message,
      {String? context,
      String? correlationId,
      dynamic error,
      StackTrace? stackTrace}) {
    errors.add(message);
  }

  @override
  void fatal(String message,
      {String? context,
      String? correlationId,
      dynamic error,
      StackTrace? stackTrace}) {
    errors.add(message);
  }

  @override
  void info(String message,
      {String? context, String? correlationId, dynamic data}) {
    infos.add(message);
  }

  @override
  void performance(String operation, Duration duration,
      {String? context,
      String? correlationId,
      Map<String, dynamic>? metrics}) {}

  @override
  void userAction(String action,
      {String? context,
      String? correlationId,
      Map<String, dynamic>? properties}) {}

  @override
  void warning(String message,
      {String? context, String? correlationId, dynamic data}) {}
}
