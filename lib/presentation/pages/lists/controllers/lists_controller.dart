import 'package:prioris/data/repositories/custom_list_repository.dart'
    show CustomListRepository, InMemoryCustomListRepository;
import 'package:prioris/data/repositories/list_item_repository.dart'
    show ListItemRepository, InMemoryListItemRepository;
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart' as domain;
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/infrastructure/services/logger_adapter.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_validation_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/refactored/lists_controller_slim.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_initialization_manager.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_persistence_manager.dart';
import 'package:prioris/presentation/pages/lists/services/list_item_sync_service.dart';
import 'package:prioris/presentation/pages/lists/services/lists_performance_monitor.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart'
    show ListsState, SortOption;

export 'refactored/lists_controller_slim.dart';
export '../models/lists_state.dart' show ListsState, SortOption;

/// Legacy façade that preserves the historical `ListsController` API while
/// delegating the behaviour to `ListsControllerSlim`.
class ListsController extends ListsControllerSlim {
  ListsController._({
    required IListsInitializationManager initializationManager,
    required IListsPerformanceMonitor performanceMonitor,
    required ListsCrudOperations crudOperations,
    required ListsStateManager stateManager,
    required ListItemSyncService syncService,
    required ILogger logger,
  }) : super(
          initializationManager: initializationManager,
          performanceMonitor: performanceMonitor,
          crudOperations: crudOperations,
          stateManager: stateManager,
          syncService: syncService,
          logger: logger,
        );

  /// Factory used by the legacy tests. It accepts the historical signatures:
  ///
  /// * `ListsController.adaptive(service, filterService);`
  /// * `ListsController.adaptive(service, customRepo, itemRepo, filterService);`
  factory ListsController.adaptive(
    AdaptivePersistenceService adaptiveService,
    Object dependency, [
    ListItemRepository? itemRepository,
    domain.ListsFilterService? filterService,
  ]) {
    final setup = _resolveDependencies(
      adaptiveService,
      dependency,
      itemRepository,
      filterService,
    );

    final logger = LoggerAdapter.defaultInstance();
    final stateManager = ListsStateManager();
    final syncService = ListItemSyncService(stateManager);
    final performanceMonitor = ListsPerformanceMonitor();
    final validationService = ListsValidationService();
    final filterManager = setup.filterManager;
    final persistenceManager = setup.persistenceManager;

    final crud = ListsCrudOperations(
      persistence: persistenceManager,
      validator: validationService,
      filterManager: filterManager,
      stateManager: stateManager,
      logger: logger,
    );

    return ListsController._(
      initializationManager: setup.initializationManager,
      performanceMonitor: performanceMonitor,
      crudOperations: crud,
      stateManager: stateManager,
      syncService: syncService,
      logger: logger,
    );
  }

  /// Legacy helper kept for backwards compatibility with architecture tests.
  /// Clears any local state and disposes the controller safely.
  Future<void> cleanup() async {
    if (!controllerDisposed) {
      state = stateManager.clearAll();
      dispose();
    }
  }

  /// Legacy alias preserved for compatibility with historical tests.
  Future<void> addItemToList(String listId, ListItem item) {
    return addListItem(listId, item);
  }

  /// Legacy helper that accepts either `List<ListItem>` or `List<String>`.
  Future<void> addMultipleItemsToList(String listId, List<dynamic> entries) {
    final baseTimestamp = DateTime.now().microsecondsSinceEpoch;
    final normalizedItems = <ListItem>[];

    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      if (entry is ListItem) {
        normalizedItems.add(entry);
        continue;
      }
      if (entry is String) {
        final createdAt = DateTime.now().add(Duration(microseconds: index));
        normalizedItems.add(ListItem(
          id: '${listId}_auto_${baseTimestamp + index}_${entry.hashCode}',
          title: entry,
          createdAt: createdAt,
          listId: listId,
        ));
        continue;
      }
      throw ArgumentError(
        'Unsupported entry type for addMultipleItemsToList: ${entry.runtimeType}',
      );
    }

    return addMultipleItems(listId, normalizedItems);
  }
}

class _ControllerDependencies {
  _ControllerDependencies({
    required this.initializationManager,
    required this.persistenceManager,
    required this.filterManager,
  });

  final IListsInitializationManager initializationManager;
  final IListsPersistenceManager persistenceManager;
  final IListsFilterManager filterManager;
}

_ControllerDependencies _resolveDependencies(
  AdaptivePersistenceService adaptiveService,
  Object dependency,
  ListItemRepository? optionalItemRepo,
  domain.ListsFilterService? optionalFilterService,
) {
  late CustomListRepository listRepository;
  late ListItemRepository itemRepository;
  late domain.ListsFilterService filterService;

  if (dependency is domain.ListsFilterService) {
    listRepository = InMemoryCustomListRepository();
    itemRepository = InMemoryListItemRepository();
    filterService = dependency;
  } else if (dependency is CustomListRepository &&
      optionalItemRepo != null &&
      optionalFilterService != null) {
    listRepository = dependency;
    itemRepository = optionalItemRepo;
    filterService = optionalFilterService;
  } else {
    throw ArgumentError(
      'Invalid parameters supplied to ListsController.adaptive. '
      'Expected either (service, filterService) or '
      '(service, customRepository, itemRepository, filterService).',
    );
  }

  final initializationManager = ListsInitializationManager.adaptive(
    adaptiveService,
    listRepository,
    itemRepository,
  );

  final persistenceManager = ListsPersistenceManager.adaptive(
    adaptiveService,
    listRepository,
    itemRepository,
  );

  final filterManager = _FilterManagerAdapter(filterService);

  return _ControllerDependencies(
    initializationManager: initializationManager,
    persistenceManager: persistenceManager,
    filterManager: filterManager,
  );
}

class _FilterManagerAdapter implements IListsFilterManager {
  _FilterManagerAdapter(this._service);

  final domain.ListsFilterService _service;

  @override
  List<CustomList> applyFilters(List<CustomList> lists, ListsState state) {
    return _service.applyFilters(
      lists,
      searchQuery: state.searchQuery,
      selectedType: state.selectedType,
      showCompleted: state.showCompleted,
      showInProgress: state.showInProgress,
      selectedDateFilter: state.selectedDateFilter,
      sortOption: _toDomainSortOption(state.sortOption),
    );
  }

  @override
  List<CustomList> applyOptimizedFilters(List<CustomList> lists, ListsState state) {
    // The legacy service did not expose a dedicated optimized path. We reuse
    // the standard filtering behaviour.
    return applyFilters(lists, state);
  }

  @override
  void clearCache() => _service.clearCache();

  @override
  List<CustomList> filterByDate(List<CustomList> lists, String? dateFilter) {
    return _service.applyFilters(
      lists,
      selectedDateFilter: dateFilter,
    );
  }

  @override
  List<CustomList> filterBySearchQuery(List<CustomList> lists, String searchQuery) {
    return _service.applyFilters(
      lists,
      searchQuery: searchQuery,
    );
  }

  @override
  List<CustomList> filterByStatus(
    List<CustomList> lists, {
    required bool showCompleted,
    required bool showInProgress,
  }) {
    return _service.applyFilters(
      lists,
      showCompleted: showCompleted,
      showInProgress: showInProgress,
    );
  }

  @override
  List<CustomList> filterByType(List<CustomList> lists, String? selectedType) {
    final listType = _parseListType(selectedType);
    return _service.applyFilters(
      lists,
      selectedType: listType,
    );
  }

  @override
  List<CustomList> sortLists(List<CustomList> lists, SortOption sortOption) {
    return _service.applyFilters(
      lists,
      sortOption: _toDomainSortOption(sortOption),
    );
  }

  domain.SortOption _toDomainSortOption(SortOption option) {
    switch (option) {
      case SortOption.NAME_ASC:
        return domain.SortOption.NAME_ASC;
      case SortOption.NAME_DESC:
        return domain.SortOption.NAME_DESC;
      case SortOption.DATE_CREATED_ASC:
        return domain.SortOption.DATE_CREATED_ASC;
      case SortOption.DATE_CREATED_DESC:
        return domain.SortOption.DATE_CREATED_DESC;
      case SortOption.PROGRESS_ASC:
        return domain.SortOption.PROGRESS_ASC;
      case SortOption.PROGRESS_DESC:
        return domain.SortOption.PROGRESS_DESC;
    }
  }

  ListType? _parseListType(String? selectedType) {
    if (selectedType == null || selectedType.isEmpty) {
      return null;
    }
    return ListType.values.firstWhere(
      (type) => type.toString() == selectedType || type.name == selectedType,
      orElse: () => ListType.CUSTOM,
    );
  }
}
