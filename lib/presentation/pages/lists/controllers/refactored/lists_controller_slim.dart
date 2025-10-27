import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import '../../models/lists_state.dart';
import '../../interfaces/lists_managers_interfaces.dart';
import '../helpers/lists_controller_executor.dart';
import '../operations/lists_crud_operations.dart';
import '../state/lists_state_manager.dart';
import '../../services/list_item_sync_service.dart';

class ListsControllerSlim extends StateNotifier<ListsState>
    with ListsControllerExecutor {
  final IListsInitializationManager initializationManager;
  final IListsPerformanceMonitor performanceMonitor;
  final ListsCrudOperations crudOperations;
  final ListsStateManager stateManager;
  final ListItemSyncService syncService;
  final ILogger logger;

  bool _isInitialized = false;
  bool _isDisposed = false;

  ListsControllerSlim({
    required this.initializationManager,
    required this.performanceMonitor,
    required this.crudOperations,
    required this.stateManager,
    required this.syncService,
    required this.logger,
  }) : super(const ListsState.initial()) {
    _bootstrap();
  }

  bool get isInitialized => _isInitialized;

  @override
  bool get controllerInitialized => _isInitialized;

  @override
  bool get controllerDisposed => _isDisposed;

  @override
  String get logContext => 'ListsControllerSlim';

  Future<void> _bootstrap() async {
    if (_isInitialized || _isDisposed) return;
    state = stateManager.setLoading(state);
    try {
      await initializationManager.initializeAsync();
      _isInitialized = true;
      await loadLists();
    } catch (error, stack) {
      logger.error(
        'Initialization failed',
        context: 'ListsControllerSlim',
        error: error,
        stackTrace: stack,
      );
      if (!_isDisposed) {
        state = stateManager.setError(state, error.toString());
      }
    }
  }

  Future<void> loadLists() => runAsync(
        'loadLists',
        () => crudOperations.loadLists(state),
        showLoading: true,
      );

  Future<void> forceReload() => runAsync(
        'forceReload',
        () => crudOperations.forceReload(state),
        showLoading: true,
      );

  Future<void> forceReloadFromPersistence() => forceReload();

  Future<void> clearAllData() => runAsync(
        'clearAllData',
        () => crudOperations.clearAllData(state),
        showLoading: true,
      );

  Future<void> createList(CustomList list) =>
      runAsync('createList', () => crudOperations.createList(state, list));

  Future<void> updateList(CustomList list) =>
      runAsync('updateList', () => crudOperations.updateList(state, list));

  Future<void> deleteList(String listId) =>
      runAsync('deleteList', () => crudOperations.deleteList(state, listId));

  Future<void> addListItem(String listId, ListItem item) => runItemOperation(
        operation: 'addListItem',
        itemId: item.id,
        action: (current) => crudOperations.addListItem(current, listId, item),
      );

  Future<void> addMultipleItems(String listId, List<ListItem> items) async {
    if (items.isEmpty) return;
    final pendingIds = items.map((item) => item.id).toSet();
    await runItemsOperation(
      operation: 'addMultipleItems',
      itemIds: pendingIds,
      action: (currentState) =>
          crudOperations.addMultipleItems(currentState, listId, items),
    );
  }

  Future<void> addMultipleItemsToList(String listId, List<ListItem> items) =>
      addMultipleItems(listId, items);

  Future<void> updateListItem(String listId, ListItem item) =>
      runItemOperation(
        operation: 'updateListItem',
        itemId: item.id,
        action: (current) =>
            crudOperations.updateListItem(current, listId, item),
      );

  Future<void> removeListItem(String listId, String itemId) =>
      runItemOperation(
        operation: 'removeListItem',
        itemId: itemId,
        action: (current) =>
            crudOperations.removeListItem(current, listId, itemId),
      );

  Future<void> removeItemFromList(String listId, String itemId) =>
      removeListItem(listId, itemId);

  Future<void> changeSortOption(SortOption option) => runAsync(
        'changeSortOption',
        () => crudOperations.changeSortOption(state, option),
        showLoading: false,
      );

  void updateSearchQuery(String query) => runSync(
        'updateSearchQuery',
        () => state = crudOperations.updateFilters(state, searchQuery: query),
      );

  void updateTypeFilter(ListType? type) => runSync(
        'updateTypeFilter',
        () => state = crudOperations.updateFilters(state, selectedType: type),
      );

  void updateShowCompleted(bool show) => runSync(
        'updateShowCompleted',
        () => state = crudOperations.updateFilters(state, showCompleted: show),
      );

  void updateShowInProgress(bool show) => runSync(
        'updateShowInProgress',
        () => state = crudOperations.updateFilters(state, showInProgress: show),
      );

  void updateDateFilter(String? filter) => runSync(
        'updateDateFilter',
        () => state =
            crudOperations.updateFilters(state, selectedDateFilter: filter),
      );

  void clearError() {
    if (_isDisposed) return;
    state = stateManager.clearError(state);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    performanceMonitor.resetStats();
    super.dispose();
  }
}

typedef RefactoredListsController = ListsControllerSlim;
