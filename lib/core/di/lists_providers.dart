/// Riverpod providers for Lists domain following SOLID principles
/// Integrates with DI container for proper dependency management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/core/di/lists_dependency_container.dart';
import 'package:prioris/application/services/lists_persistence_service.dart';
import 'package:prioris/application/services/lists_state_manager.dart';
import 'package:prioris/application/services/lists_transaction_manager.dart';
import 'package:prioris/application/services/lists_error_handler.dart';
import 'package:prioris/application/services/lists_loading_manager.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

/// Provider for DI Container initialization
final diContainerInitProvider = FutureProvider<void>((ref) async {
  await ListsDependencyContainer.initialize(
    mode: DependencyMode.adaptive,
  );
});

/// Provider for Lists Error Handler
final listsErrorHandlerProvider = Provider<IListsErrorHandler>((ref) {
  return ListsDependencyContainer.get<IListsErrorHandler>();
});

/// Provider for Lists Loading Manager
final listsLoadingManagerProvider = Provider<IListsLoadingManager>((ref) {
  return ListsDependencyContainer.get<IListsLoadingManager>();
});

/// Provider for Lists Filter Service
final listsFilterServiceProvider = Provider<IListsFilterService>((ref) {
  return ListsDependencyContainer.get<IListsFilterService>();
});

/// Provider for Lists State Manager
final listsStateManagerProvider = StateNotifierProvider<ListsStateManager, ListsStateSnapshot>((ref) {
  // Instead of using DI container for state manager (which has lifecycle issues with Riverpod),
  // create directly with proper Riverpod lifecycle
  return ListsStateManager();
});

/// Provider for Lists Persistence Service with Adaptive Strategy
final listsPersistenceServiceProvider = Provider<IListsPersistenceService>((ref) {
  // Watch for adaptive persistence service
  final adaptiveServiceAsync = ref.watch(adaptivePersistenceInitProvider);

  return adaptiveServiceAsync.when(
    data: (adaptiveService) {
      // Create persistence service with adaptive strategy
      return ListsPersistenceService.adaptive(adaptiveService);
    },
    loading: () {
      // Fallback to local repositories while loading
      final localListRepo = InMemoryCustomListRepository();
      final localItemRepo = InMemoryListItemRepository();
      return ListsPersistenceService.local(localListRepo, localItemRepo);
    },
    error: (error, stack) {
      // Fallback to local repositories on error
      final localListRepo = InMemoryCustomListRepository();
      final localItemRepo = InMemoryListItemRepository();
      return ListsPersistenceService.local(localListRepo, localItemRepo);
    },
  );
});

/// Provider for Lists Transaction Manager
final listsTransactionManagerProvider = Provider<IListsTransactionManager>((ref) {
  final persistenceService = ref.watch(listsPersistenceServiceProvider);
  return ListsTransactionManager(persistenceService: persistenceService);
});

/// Provider for Lists Orchestrator (combines all services)
final listsOrchestratorProvider = Provider<ListsOrchestrator>((ref) {
  final stateManager = ref.watch(listsStateManagerProvider.notifier);
  final persistenceService = ref.watch(listsPersistenceServiceProvider);
  final transactionManager = ref.watch(listsTransactionManagerProvider);
  final errorHandler = ref.watch(listsErrorHandlerProvider);
  final loadingManager = ref.watch(listsLoadingManagerProvider);
  final filterService = ref.watch(listsFilterServiceProvider);

  return ListsOrchestrator(
    stateManager: stateManager,
    persistenceService: persistenceService,
    transactionManager: transactionManager,
    errorHandler: errorHandler,
    loadingManager: loadingManager,
    filterService: filterService,
  );
});

/// Provider for Lists State (read-only access)
final listsStateProvider = Provider<ListsStateSnapshot>((ref) {
  return ref.watch(listsStateManagerProvider);
});

/// Provider for filtered lists
final filteredListsProvider = Provider<List<CustomList>>((ref) {
  return ref.watch(listsStateProvider).filteredLists;
});

/// Provider for loading state
final listsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(listsStateProvider).isLoading;
});

/// Provider for error state
final listsErrorProvider = Provider<String?>((ref) {
  return ref.watch(listsStateProvider).error;
});

/// Provider for specific list by ID
final listByIdProvider = Provider.family<CustomList?, String>((ref, listId) {
  final state = ref.watch(listsStateProvider);
  return state.lists.cast<CustomList?>().firstWhere(
    (list) => list?.id == listId,
    orElse: () => null,
  );
});

/// Orchestrator class that coordinates all services
/// This replaces the massive controller with proper separation of concerns
class ListsOrchestrator {
  final IListsStateManager _stateManager;
  final IListsPersistenceService _persistenceService;
  final IListsTransactionManager _transactionManager;
  final IListsErrorHandler _errorHandler;
  final IListsLoadingManager _loadingManager;
  final IListsFilterService _filterService;

  ListsOrchestrator({
    required IListsStateManager stateManager,
    required IListsPersistenceService persistenceService,
    required IListsTransactionManager transactionManager,
    required IListsErrorHandler errorHandler,
    required IListsLoadingManager loadingManager,
    required IListsFilterService filterService,
  }) : _stateManager = stateManager,
       _persistenceService = persistenceService,
       _transactionManager = transactionManager,
       _errorHandler = errorHandler,
       _loadingManager = loadingManager,
       _filterService = filterService;

  /// Gets current state
  ListsStateSnapshot get state => _stateManager.getCurrentState<ListsStateSnapshot>();

  /// Loads all lists
  Future<void> loadLists() async {
    await _loadingManager.executeWithLoading(() async {
      try {
        final lists = await _persistenceService.getAllLists();
        await _handleListsLoaded(lists);
      } catch (error) {
        _errorHandler.handleError(error, 'loadLists');
        rethrow;
      }
    });
  }

  /// Creates a new list
  Future<void> createList(CustomList list) async {
    await _transactionManager.executeWithRollback(
      () async {
        await _persistenceService.saveList(list);
        final isVerified = await _transactionManager.verifyOperation('createList', list.id);
        if (!isVerified) {
          throw Exception('List creation verification failed');
        }
        _addListToState(list);
      },
      () async {
        await _persistenceService.deleteList(list.id);
      },
    );
  }

  /// Updates an existing list
  Future<void> updateList(CustomList list) async {
    // Get original list for rollback
    final originalList = state.lists.firstWhere(
      (l) => l.id == list.id,
      orElse: () => list, // Fallback to current if not found
    );

    await _transactionManager.executeWithRollback(
      () async {
        await _persistenceService.saveList(list);
        _updateListInState(list);
      },
      () async {
        await _persistenceService.saveList(originalList);
        _updateListInState(originalList);
      },
    );
  }

  /// Deletes a list
  Future<void> deleteList(String listId) async {
    // Get list and its items for potential rollback
    final listToDelete = state.lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => throw Exception('List not found'),
    );

    await _transactionManager.executeWithRollback(
      () async {
        await _persistenceService.deleteList(listId);
        _removeListFromState(listId);
      },
      () async {
        await _persistenceService.saveList(listToDelete);
        // Restore items if any
        for (final item in listToDelete.items) {
          await _persistenceService.saveItem(item);
        }
        _addListToState(listToDelete);
      },
    );
  }

  /// Adds an item to a list
  Future<void> addItemToList(String listId, ListItem item) async {
    await _transactionManager.executeWithRollback(
      () async {
        await _persistenceService.saveItem(item);
        final isVerified = await _transactionManager.verifyOperation('addItem', item.id);
        if (!isVerified) {
          throw Exception('Item creation verification failed');
        }
        _addItemToListState(listId, item);
      },
      () async {
        await _persistenceService.deleteItem(item.id);
      },
    );
  }

  /// Updates an item in a list
  Future<void> updateListItem(String listId, ListItem item) async {
    // Find original item for rollback
    final list = state.lists.firstWhere((l) => l.id == listId);
    final originalItem = list.items.firstWhere(
      (i) => i.id == item.id,
      orElse: () => item, // Fallback if not found
    );

    await _transactionManager.executeWithRollback(
      () async {
        await _persistenceService.updateItem(item);
        _updateItemInListState(listId, item);
      },
      () async {
        await _persistenceService.updateItem(originalItem);
        _updateItemInListState(listId, originalItem);
      },
    );
  }

  /// Removes an item from a list
  Future<void> removeItemFromList(String listId, String itemId) async {
    // Find item for potential rollback
    final list = state.lists.firstWhere((l) => l.id == listId);
    final itemToDelete = list.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    await _transactionManager.executeWithRollback(
      () async {
        await _persistenceService.deleteItem(itemId);
        _removeItemFromListState(listId, itemId);
      },
      () async {
        await _persistenceService.saveItem(itemToDelete);
        _addItemToListState(listId, itemToDelete);
      },
    );
  }

  /// Clears all data
  Future<void> clearAllData() async {
    final currentLists = List<CustomList>.from(state.lists);

    await _transactionManager.executeWithRollback(
      () async {
        await _persistenceService.clearAllData();
        _stateManager.updateLists([]);
        _stateManager.updateFilteredLists([]);
      },
      () async {
        // Restore all data
        for (final list in currentLists) {
          await _persistenceService.saveList(list);
          for (final item in list.items) {
            await _persistenceService.saveItem(item);
          }
        }
        await _handleListsLoaded(currentLists);
      },
    );
  }

  /// Updates search query and applies filters
  void updateSearchQuery(String query) {
    _stateManager.updateSearchQuery(query);
    _applyFilters();
  }

  /// Updates type filter and applies filters
  void updateTypeFilter(ListType? type) {
    _stateManager.updateTypeFilter(type);
    _applyFilters();
  }

  /// Updates completion filter and applies filters
  void updateShowCompleted(bool show) {
    _stateManager.updateShowCompleted(show);
    _applyFilters();
  }

  /// Updates in-progress filter and applies filters
  void updateShowInProgress(bool show) {
    _stateManager.updateShowInProgress(show);
    _applyFilters();
  }

  /// Updates date filter and applies filters
  void updateDateFilter(String? filter) {
    _stateManager.updateDateFilter(filter);
    _applyFilters();
  }

  /// Updates sort option and applies filters
  void updateSortOption(SortOption option) {
    _stateManager.updateSortOption(option);
    _applyFilters();
  }

  /// Clears error state
  void clearError() {
    _stateManager.setError(null);
  }

  /// Private helper methods

  Future<void> _handleListsLoaded(List<CustomList> lists) async {
    // Load items for each list if needed
    final listsWithItems = <CustomList>[];
    for (final list in lists) {
      final items = await _persistenceService.getItemsByListId(list.id);
      listsWithItems.add(list.copyWith(items: items));
    }

    _updateListsAndApplyFilters(listsWithItems);
  }

  void _updateListsAndApplyFilters(List<CustomList> lists) {
    final filteredLists = _filterService.applyFilters(
      lists,
      searchQuery: state.searchQuery,
      selectedType: state.selectedType,
      showCompleted: state.showCompleted,
      showInProgress: state.showInProgress,
      selectedDateFilter: state.selectedDateFilter,
      sortOption: state.sortOption,
    );

    _stateManager.updateLists(lists);
    _stateManager.updateFilteredLists(filteredLists);
  }

  void _applyFilters() {
    final filteredLists = _filterService.applyFilters(
      state.lists,
      searchQuery: state.searchQuery,
      selectedType: state.selectedType,
      showCompleted: state.showCompleted,
      showInProgress: state.showInProgress,
      selectedDateFilter: state.selectedDateFilter,
      sortOption: state.sortOption,
    );

    _stateManager.updateFilteredLists(filteredLists);
  }

  void _addListToState(CustomList list) {
    final updatedLists = [...state.lists, list];
    _updateListsAndApplyFilters(updatedLists);
  }

  void _updateListInState(CustomList list) {
    final updatedLists = state.lists.map((l) => l.id == list.id ? list : l).toList();
    _updateListsAndApplyFilters(updatedLists);
  }

  void _removeListFromState(String listId) {
    final updatedLists = state.lists.where((l) => l.id != listId).toList();
    _updateListsAndApplyFilters(updatedLists);
  }

  void _addItemToListState(String listId, ListItem item) {
    final updatedLists = state.lists.map((list) {
      if (list.id == listId) {
        return list.copyWith(items: [...list.items, item]);
      }
      return list;
    }).toList();
    _updateListsAndApplyFilters(updatedLists);
  }

  void _updateItemInListState(String listId, ListItem item) {
    final updatedLists = state.lists.map((list) {
      if (list.id == listId) {
        final updatedItems = list.items.map((i) => i.id == item.id ? item : i).toList();
        return list.copyWith(items: updatedItems);
      }
      return list;
    }).toList();
    _updateListsAndApplyFilters(updatedLists);
  }

  void _removeItemFromListState(String listId, String itemId) {
    final updatedLists = state.lists.map((list) {
      if (list.id == listId) {
        final updatedItems = list.items.where((i) => i.id != itemId).toList();
        return list.copyWith(items: updatedItems);
      }
      return list;
    }).toList();
    _updateListsAndApplyFilters(updatedLists);
  }
}