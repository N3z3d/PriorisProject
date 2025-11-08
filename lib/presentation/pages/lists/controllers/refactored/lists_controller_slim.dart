import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/lists_domain_dependencies.dart';
import '../../models/lists_state.dart';
import '../../models/lists_filter_patch.dart';
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
  bool get controllerInitialized => isInitialized;

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

  Future<void> loadLists() => _runCrudOperation(
        'loadLists',
        crudOperations.loadLists,
        showLoading: true,
      );

  Future<void> forceReload() => _runCrudOperation(
        'forceReload',
        crudOperations.forceReload,
        showLoading: true,
      );

  Future<void> forceReloadFromPersistence() => forceReload();

  Future<void> clearAllData() => _runCrudOperation(
        'clearAllData',
        crudOperations.clearAllData,
        showLoading: true,
      );

  Future<void> createList(CustomList list) =>
      _runCrudOperation('createList', (current) => crudOperations.createList(current, list));

  Future<void> updateList(CustomList list) =>
      _runCrudOperation('updateList', (current) => crudOperations.updateList(current, list));

  Future<void> deleteList(String listId) =>
      _runCrudOperation('deleteList', (current) => crudOperations.deleteList(current, listId));

  Future<void> addListItem(String listId, ListItem item) => _runItemOperation(
        operation: 'addListItem',
        itemId: item.id,
        action: (current) => crudOperations.addListItem(current, listId, item),
      );

  Future<void> addMultipleItems(String listId, List<ListItem> items) async {
    if (items.isEmpty) return;
    final pendingIds = items.map((item) => item.id).toSet();
    await _runItemsOperation(
      operation: 'addMultipleItems',
      itemIds: pendingIds,
      action: (currentState) =>
          crudOperations.addMultipleItems(currentState, listId, items),
    );
  }

  Future<void> addMultipleItemsToList(String listId, List<ListItem> items) =>
      addMultipleItems(listId, items);

  Future<void> updateListItem(String listId, ListItem item) =>
      _runItemOperation(
        operation: 'updateListItem',
        itemId: item.id,
        action: (current) =>
            crudOperations.updateListItem(current, listId, item),
      );

  Future<void> removeListItem(String listId, String itemId) =>
      _runItemOperation(
        operation: 'removeListItem',
        itemId: itemId,
        action: (current) =>
            crudOperations.removeListItem(current, listId, itemId),
      );

  Future<void> removeItemFromList(String listId, String itemId) =>
      removeListItem(listId, itemId);

  Future<void> changeSortOption(SortOption option) => _runCrudOperation(
        'changeSortOption',
        (current) => crudOperations.changeSortOption(current, option),
        showLoading: false,
      );

  void updateSearchQuery(String query) =>
      _applyFilterPatch('updateSearchQuery', ListsFilterPatch.search(query));

  void updateTypeFilter(ListType? type) =>
      _applyFilterPatch('updateTypeFilter', ListsFilterPatch.type(type));

  void updateShowCompleted(bool show) =>
      _applyFilterPatch('updateShowCompleted', ListsFilterPatch.showCompleted(show));

  void updateShowInProgress(bool show) =>
      _applyFilterPatch('updateShowInProgress', ListsFilterPatch.showInProgress(show));

  void updateDateFilter(String? filter) =>
      _applyFilterPatch('updateDateFilter', ListsFilterPatch.dateFilter(filter));

  void _applyFilterPatch(String operation, ListsFilterPatch patch) {
    runSync(operation, () {
      state = crudOperations.updateFilters(state, patch);
    });
  }

  void clearError() {
    if (_isDisposed) {
      return;
    }
    final clearedState = stateManager.clearError(state);
    state = clearedState;
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    performanceMonitor.resetStats();
    super.dispose();
  }

  Future<void> _runCrudOperation(
    String operation,
    Future<ListsState> Function(ListsState current) action, {
    bool showLoading = false,
  }) =>
      runAsync(
        operation,
        () => action(state),
        showLoading: showLoading,
      );

  Future<void> _runItemOperation({
    required String operation,
    required String itemId,
    required Future<ListsState> Function(ListsState current) action,
  }) =>
      runItemOperation(
        operation: operation,
        itemId: itemId,
        action: action,
      );

  Future<void> _runItemsOperation({
    required String operation,
    required Set<String> itemIds,
    required Future<ListsState> Function(ListsState current) action,
  }) =>
      runItemsOperation(
        operation: operation,
        itemIds: itemIds,
        action: action,
      );
}

typedef RefactoredListsController = ListsControllerSlim;
