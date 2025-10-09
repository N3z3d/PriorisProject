import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import '../../models/lists_state.dart';
import '../../interfaces/lists_managers_interfaces.dart';
import '../operations/lists_crud_operations.dart';
import '../state/lists_state_manager.dart';

class ListsControllerSlim extends StateNotifier<ListsState> {
  final IListsInitializationManager initializationManager;
  final IListsPerformanceMonitor performanceMonitor;
  final ListsCrudOperations crudOperations;
  final ListsStateManager stateManager;
  final ILogger logger;

  bool _isInitialized = false;
  bool _isDisposed = false;

  ListsControllerSlim({
    required this.initializationManager,
    required this.performanceMonitor,
    required this.crudOperations,
    required this.stateManager,
    required this.logger,
  }) : super(const ListsState.initial()) {
    _bootstrap();
  }

  bool get isInitialized => _isInitialized;

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

  Future<void> loadLists() => _runAsync('loadLists', () => crudOperations.loadLists(state));

  Future<void> forceReload() => _runAsync('forceReload', () => crudOperations.forceReload(state));

  Future<void> forceReloadFromPersistence() => forceReload();

  Future<void> clearAllData() => _runAsync('clearAllData', () => crudOperations.clearAllData(state));

  Future<void> createList(CustomList list) => _runAsync('createList', () => crudOperations.createList(state, list));

  Future<void> updateList(CustomList list) => _runAsync('updateList', () => crudOperations.updateList(state, list));

  Future<void> deleteList(String listId) => _runAsync('deleteList', () => crudOperations.deleteList(state, listId));

  Future<void> addListItem(String listId, ListItem item) => _runAsync(
        'addListItem',
        () => crudOperations.addListItem(state, listId, item),
      );

  Future<void> addMultipleItems(String listId, List<ListItem> items) => _runAsync(
        'addMultipleItems',
        () => crudOperations.addMultipleItems(state, listId, items),
      );

  Future<void> addMultipleItemsToList(String listId, List<ListItem> items) => addMultipleItems(listId, items);

  Future<void> updateListItem(String listId, ListItem item) => _runAsync(
        'updateListItem',
        () => crudOperations.updateListItem(state, listId, item),
      );

  Future<void> removeListItem(String listId, String itemId) => _runAsync(
        'removeListItem',
        () => crudOperations.removeListItem(state, listId, itemId),
      );

  Future<void> removeItemFromList(String listId, String itemId) => removeListItem(listId, itemId);

  Future<void> changeSortOption(SortOption option) => _runAsync(
        'changeSortOption',
        () => crudOperations.changeSortOption(state, option),
      );

  void updateSearchQuery(String query) => _runSync(
        'updateSearchQuery',
        () => state = crudOperations.updateFilters(state, searchQuery: query),
      );

  void updateTypeFilter(ListType? type) => _runSync(
        'updateTypeFilter',
        () => state = crudOperations.updateFilters(state, selectedType: type),
      );

  void updateShowCompleted(bool show) => _runSync(
        'updateShowCompleted',
        () => state = crudOperations.updateFilters(state, showCompleted: show),
      );

  void updateShowInProgress(bool show) => _runSync(
        'updateShowInProgress',
        () => state = crudOperations.updateFilters(state, showInProgress: show),
      );

  void updateDateFilter(String? filter) => _runSync(
        'updateDateFilter',
        () => state = crudOperations.updateFilters(state, selectedDateFilter: filter),
      );

  void clearError() {
    if (_isDisposed) return;
    state = stateManager.clearError(state);
  }

  Future<void> _runAsync(String operation, Future<ListsState> Function() action) async {
    if (!_isInitialized || _isDisposed) return;

    state = stateManager.setLoading(state);
    performanceMonitor.startOperation(operation);
    try {
      final nextState = await action();
      performanceMonitor.endOperation(operation);
      if (!_isDisposed) {
        state = stateManager.clearError(nextState);
      }
    } catch (error, stack) {
      performanceMonitor.endOperation(operation);
      logger.error(
        'Operation $operation failed',
        context: 'ListsControllerSlim',
        error: error,
        stackTrace: stack,
      );
      if (!_isDisposed) {
        state = stateManager.setError(state, error.toString());
      }
      rethrow;
    }
  }

  void _runSync(String operation, void Function() mutation) {
    if (!_isInitialized || _isDisposed) return;

    try {
      mutation();
      performanceMonitor.logInfo('Operation $operation applied', context: 'ListsControllerSlim');
    } catch (error, stack) {
      logger.error(
        'Operation $operation failed',
        context: 'ListsControllerSlim',
        error: error,
        stackTrace: stack,
      );
      state = stateManager.setError(state, error.toString());
    }
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
