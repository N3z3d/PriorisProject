import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/refactored/lists_controller_slim.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/lists/services/list_item_sync_service.dart';

/// Lightweight persistence stub that performs no IO.
class NoopListsPersistenceManager implements IListsPersistenceManager {
  const NoopListsPersistenceManager();

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> deleteList(String listId) async {}

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async => const [];

  @override
  Future<List<ListItem>> loadListItems(String listId) async => const [];

  @override
  Future<List<CustomList>> loadAllLists() async => const [];

  @override
  Future<void> rollbackItems(List<ListItem> items) async {}

  @override
  Future<void> saveList(CustomList list) async {}

  @override
  Future<void> saveListItem(ListItem item) async {}

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {}

  @override
  Future<void> updateList(CustomList list) async {}

  @override
  Future<void> updateListItem(ListItem item) async {}

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> verifyListPersistence(String listId) async {}
}

/// Validation stub that always accepts incoming data.
class PassthroughListsValidationService implements IListsValidationService {
  const PassthroughListsValidationService();

  @override
  bool checkReferentialIntegrity(List<CustomList> lists) => true;

  @override
  List<String> getItemValidationErrors(ListItem item) => const [];

  @override
  List<String> getListValidationErrors(CustomList list) => const [];

  @override
  List<String> getStateValidationErrors(ListsState state) => const [];

  @override
  List<CustomList> sanitizeLists(List<CustomList> lists) =>
      List<CustomList>.from(lists);

  @override
  bool validateList(CustomList list) => true;

  @override
  bool validateListItem(ListItem item) => true;

  @override
  bool validateListsCollection(List<CustomList> lists) => true;

  @override
  bool validateState(ListsState state) => true;
}

/// Filter manager stub that returns lists unchanged.
class EchoListsFilterManager implements IListsFilterManager {
  const EchoListsFilterManager();

  @override
  List<CustomList> applyFilters(List<CustomList> lists, ListsState state) =>
      List<CustomList>.from(lists);

  @override
  List<CustomList> applyOptimizedFilters(
          List<CustomList> lists, ListsState state) =>
      List<CustomList>.from(lists);

  @override
  void clearCache() {}

  @override
  List<CustomList> filterByDate(List<CustomList> lists, String? dateFilter) =>
      List<CustomList>.from(lists);

  @override
  List<CustomList> filterBySearchQuery(
          List<CustomList> lists, String searchQuery) =>
      List<CustomList>.from(lists);

  @override
  List<CustomList> filterByStatus(
    List<CustomList> lists, {
    required bool showCompleted,
    required bool showInProgress,
  }) =>
      List<CustomList>.from(lists);

  @override
  List<CustomList> filterByType(List<CustomList> lists, String? selectedType) =>
      List<CustomList>.from(lists);

  @override
  List<CustomList> sortLists(List<CustomList> lists, SortOption sortOption) =>
      List<CustomList>.from(lists);
}

/// No-op logger used for unit tests.
class SilentLogger implements ILogger {
  const SilentLogger();

  @override
  void debug(String message,
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
  void info(String message,
      {String? context, String? correlationId, dynamic data}) {}

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

/// Performance monitor stub that ignores every call.
class SilentPerformanceMonitor implements IListsPerformanceMonitor {
  const SilentPerformanceMonitor();

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

/// Initialization manager stub that completes immediately.
class ImmediateInitializationManager implements IListsInitializationManager {
  const ImmediateInitializationManager();

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

/// Minimal controller that seeds its state without hitting persistence.
class StubListsController extends ListsControllerSlim {
  static const ListsStateManager _sharedManager = ListsStateManager();
  static const SilentLogger _sharedLogger = SilentLogger();
  static const EchoListsFilterManager _sharedFilterManager =
      EchoListsFilterManager();
  static const PassthroughListsValidationService _sharedValidator =
      PassthroughListsValidationService();
  static const NoopListsPersistenceManager _sharedPersistence =
      NoopListsPersistenceManager();

  StubListsController({
    required ListsState seededState,
  })  : _seededState = seededState,
        super(
          initializationManager: const ImmediateInitializationManager(),
          performanceMonitor: const SilentPerformanceMonitor(),
          crudOperations: ListsCrudOperations(
            persistence: _sharedPersistence,
            validator: _sharedValidator,
            filterManager: _sharedFilterManager,
            stateManager: _sharedManager,
            logger: _sharedLogger,
          ),
          stateManager: _sharedManager,
          syncService: const ListItemSyncService(_sharedManager),
          logger: _sharedLogger,
        );

  final ListsState _seededState;

  @override
  Future<void> loadLists() async {
    state = _seededState;
  }
}
