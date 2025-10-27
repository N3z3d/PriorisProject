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

void main() {
  group('ListsControllerSlim.createList', () {
    late ListsControllerSlim controller;
    late _InMemoryPersistence persistence;

    setUp(() async {
      final stateManager = ListsStateManager();
      persistence = _InMemoryPersistence();
      final crud = ListsCrudOperations(
        persistence: persistence,
        validator: ListsValidationService(),
        filterManager: ListsFilterManager(),
        stateManager: stateManager,
        logger: _NoopLogger(),
      );

      final syncService = ListItemSyncService(stateManager);

      controller = ListsControllerSlim(
        initializationManager: _ImmediateInitManager(),
        performanceMonitor: _NoopPerformanceMonitor(),
        crudOperations: crud,
        stateManager: stateManager,
        syncService: syncService,
        logger: _NoopLogger(),
      );
      await controller.loadLists();
    });

    test('ajoute la liste et laisse isLoading à false', () async {
      final now = DateTime(2024, 1, 1);
      final list = CustomList(
        id: 'liste-1',
        name: 'Liste de tests',
        type: ListType.CUSTOM,
        items: const [],
        createdAt: now,
        updatedAt: now,
      );

      await controller.createList(list);

      final state = controller.state;
      expect(state.isLoading, isFalse);
      expect(state.lists.map((l) => l.id), contains('liste-1'));
    });
  });
}

class _InMemoryPersistence implements IListsPersistenceManager {
  final List<CustomList> _lists = [];

  @override
  Future<List<CustomList>> loadAllLists() async => List.of(_lists);

  @override
  Future<void> saveList(CustomList list) async {
    _lists.add(list);
  }

  @override
  Future<void> updateList(CustomList list) async {
    final index = _lists.indexWhere((element) => element.id == list.id);
    if (index != -1) {
      _lists[index] = list;
    }
  }

  @override
  Future<void> deleteList(String listId) async {
    _lists.removeWhere((element) => element.id == listId);
  }

  @override
  Future<List<ListItem>> loadListItems(String listId) async => [];

  @override
  Future<void> saveListItem(ListItem item) async {}

  @override
  Future<void> updateListItem(ListItem item) async {}

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {}

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async =>
      List.of(_lists);

  @override
  Future<void> clearAllData() async {
    _lists.clear();
  }

  @override
  Future<void> verifyListPersistence(String listId) async {}

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> rollbackItems(List<ListItem> items) async {}
}

class _ImmediateInitManager implements IListsInitializationManager {
  bool _initialized = false;

  @override
  Future<void> initializeAdaptive() async {}

  @override
  Future<void> initializeLegacy() async {}

  @override
  Future<void> initializeAsync() async {
    _initialized = true;
  }

  @override
  bool get isInitialized => _initialized;

  @override
  String get initializationMode => 'test';
}

class _NoopPerformanceMonitor implements IListsPerformanceMonitor {
  @override
  void startOperation(String operationName) {}

  @override
  void endOperation(String operationName) {}

  @override
  Map<String, dynamic> getPerformanceStats() => const {};

  @override
  void logError(String operation, Object error, [StackTrace? stackTrace]) {}

  @override
  void logInfo(String message, {String? context}) {}

  @override
  void logWarning(String message, {String? context}) {}

  @override
  void resetStats() {}

  @override
  void monitorCacheOperation(String operation, bool hit) {}

  @override
  void monitorCollectionSize(String collection, int size) {}

  @override
  Map<String, dynamic> getDetailedMetrics() => const {};
}

class _NoopLogger implements ILogger {
  @override
  void debug(String message,
      {String? context, String? correlationId, dynamic data}) {}

  @override
  void info(String message,
      {String? context, String? correlationId, dynamic data}) {}

  @override
  void warning(String message,
      {String? context, String? correlationId, dynamic data}) {}

  @override
  void error(String message,
      {String? context,
      String? correlationId,
      dynamic error,
      StackTrace? stackTrace}) {}

  @override
  void fatal(String message,
      {String? context,
      String? correlationId,
      dynamic error,
      StackTrace? stackTrace}) {}

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
}
