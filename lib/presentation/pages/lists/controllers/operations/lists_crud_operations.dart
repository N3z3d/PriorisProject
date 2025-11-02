import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import '../../models/lists_state.dart';
import '../../interfaces/lists_managers_interfaces.dart';
import '../state/lists_state_manager.dart';

class ListsCrudOperations {
  final IListsPersistenceManager persistence;
  final IListsValidationService validator;
  final IListsFilterManager filterManager;
  final ListsStateManager stateManager;
  final ILogger logger;

  const ListsCrudOperations({
    required this.persistence,
    required this.validator,
    required this.filterManager,
    required this.stateManager,
    required this.logger,
  });

  Future<ListsState> loadLists(ListsState current) {
    return _loadAndFilter(current, () => persistence.loadAllLists());
  }

  Future<ListsState> forceReload(ListsState current) {
    return _loadAndFilter(
      current,
      () => persistence.forceReloadFromPersistence(),
    );
  }

  Future<ListsState> clearAllData(ListsState current) async {
    await persistence.clearAllData();
    return stateManager.clearAll();
  }

  Future<ListsState> createList(ListsState current, CustomList list) async {
    _ensureListValid(list);
    await persistence.saveList(list);
    await persistence.verifyListPersistence(list.id);
    final updatedState = stateManager.addList(current, list);
    return _applyFilters(updatedState);
  }

  Future<ListsState> updateList(ListsState current, CustomList list) async {
    _ensureListValid(list);
    await persistence.updateList(list);
    final updatedState = stateManager.updateList(current, list);
    return _applyFilters(updatedState);
  }

  Future<ListsState> deleteList(ListsState current, String listId) async {
    await persistence.deleteList(listId);
    final updatedState = stateManager.removeList(current, listId);
    return _applyFilters(updatedState);
  }

  Future<ListsState> addListItem(ListsState current, String listId, ListItem item) async {
    _ensureItemValid(item);
    await persistence.saveListItem(item);
    await persistence.verifyItemPersistence(item.id);
    final updatedState = stateManager.addItem(current, listId, item);
    return _applyFilters(updatedState);
  }

  Future<ListsState> addMultipleItems(
    ListsState current,
    String listId,
    List<ListItem> items,
  ) async {
    for (final item in items) {
      _ensureItemValid(item);
    }
    await persistence.saveMultipleItems(items);
    final updatedState = stateManager.addItems(current, listId, items);
    return _applyFilters(updatedState);
  }

  Future<ListsState> updateListItem(ListsState current, String listId, ListItem item) async {
    _ensureItemValid(item);
    await persistence.updateListItem(item);
    final updatedState = stateManager.updateItem(current, listId, item);
    return _applyFilters(updatedState);
  }

  Future<ListsState> removeListItem(ListsState current, String listId, String itemId) async {
    await persistence.deleteListItem(itemId);
    final updatedState = stateManager.removeItem(current, listId, itemId);
    return _applyFilters(updatedState);
  }

  Future<ListsState> changeSortOption(ListsState current, SortOption option) async {
    final updated = stateManager.updateFilters(current, sortOption: option);
    return _applyFilters(updated);
  }

  ListsState updateFilters(
    ListsState current, {
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
  }) {
    final updated = stateManager.updateFilters(
      current,
      searchQuery: searchQuery,
      selectedType: selectedType,
      showCompleted: showCompleted,
      showInProgress: showInProgress,
      selectedDateFilter: selectedDateFilter,
    );
    return _applyFilters(updated);
  }

  Future<ListsState> _loadAndFilter(
    ListsState current,
    Future<List<CustomList>> Function() loader,
  ) async {
    final lists = await loader();
    final sanitized = validator.sanitizeLists(lists);
    final baseState = stateManager.replaceLists(current, sanitized);
    return _applyFilters(baseState);
  }

  ListsState _applyFilters(ListsState state) {
    final filtered = filterManager.applyFilters(state.lists, state);
    return stateManager.updateFilteredLists(state, filtered);
  }

  void _ensureListValid(CustomList list) {
    if (!validator.validateList(list)) {
      logger.error('Liste invalide: ${list.id}', context: 'ListsCrudOperations');
      throw ArgumentError('Liste invalide');
    }
  }

  void _ensureItemValid(ListItem item) {
    if (!validator.validateListItem(item)) {
      logger.error('Élément invalide: ${item.id}', context: 'ListsCrudOperations');
      throw ArgumentError('Élément invalide');
    }
  }
}
