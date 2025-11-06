import '../shared/lists_domain_dependencies.dart';
import '../../models/lists_state.dart';
import '../../models/lists_filter_patch.dart';
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

  Future<ListsState> clearAllData(ListsState current) {
    return _executeMutation(
      current,
      persist: () => persistence.clearAllData(),
      updateState: (_) => stateManager.clearAll(),
    );
  }

  Future<ListsState> createList(ListsState current, CustomList list) {
    return _executeMutation(
      current,
      validate: () => _ensureListValid(list),
      persist: () async {
        await persistence.saveList(list);
        await persistence.verifyListPersistence(list.id);
      },
      updateState: (state) => stateManager.addList(state, list),
    );
  }

  Future<ListsState> updateList(ListsState current, CustomList list) {
    return _executeMutation(
      current,
      validate: () => _ensureListValid(list),
      persist: () => persistence.updateList(list),
      updateState: (state) => stateManager.updateList(state, list),
    );
  }

  Future<ListsState> deleteList(ListsState current, String listId) {
    return _executeMutation(
      current,
      persist: () => persistence.deleteList(listId),
      updateState: (state) => stateManager.removeList(state, listId),
    );
  }

  Future<ListsState> addListItem(ListsState current, String listId, ListItem item) {
    return _executeMutation(
      current,
      validate: () => _ensureItemValid(item),
      persist: () async {
        await persistence.saveListItem(item);
        await persistence.verifyItemPersistence(item.id);
      },
      updateState: (state) => stateManager.addItem(state, listId, item),
    );
  }

  Future<ListsState> addMultipleItems(
    ListsState current,
    String listId,
    List<ListItem> items,
  ) {
    return _executeMutation(
      current,
      validate: () {
        for (final item in items) {
          _ensureItemValid(item);
        }
      },
      persist: () => persistence.saveMultipleItems(items),
      updateState: (state) => stateManager.addItems(state, listId, items),
    );
  }

  Future<ListsState> updateListItem(ListsState current, String listId, ListItem item) {
    return _executeMutation(
      current,
      validate: () => _ensureItemValid(item),
      persist: () => persistence.updateListItem(item),
      updateState: (state) => stateManager.updateItem(state, listId, item),
    );
  }

  Future<ListsState> removeListItem(ListsState current, String listId, String itemId) {
    return _executeMutation(
      current,
      persist: () => persistence.deleteListItem(itemId),
      updateState: (state) => stateManager.removeItem(state, listId, itemId),
    );
  }

  Future<ListsState> changeSortOption(ListsState current, SortOption option) {
    final patch = ListsFilterPatch.sort(option);
    final nextState = _applyFilterPatch(current, patch);
    return Future.value(nextState);
  }

  ListsState updateFilters(
    ListsState current,
    ListsFilterPatch patch,
  ) {
    return _applyFilterPatch(current, patch);
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

  ListsState _applyFilters(ListsState state) =>
      stateManager.updateFilteredLists(
        state,
        filterManager.applyFilters(state.lists, state),
      );

  Future<ListsState> _executeMutation(
    ListsState current, {
    void Function()? validate,
    required Future<void> Function() persist,
    required ListsState Function(ListsState) updateState,
  }) async {
    validate?.call();
    await persist();
    final updatedState = updateState(current);
    return _applyFilters(updatedState);
  }

  ListsState _applyFilterMutationSync(
    ListsState current,
    ListsState Function(ListsState) transform,
  ) {
    final updated = transform(current);
    return _applyFilters(updated);
  }

  ListsState _applyFilterPatch(ListsState current, ListsFilterPatch patch) {
    return _applyFilterMutationSync(
      current,
      (state) => stateManager.applyFilterPatch(state, patch),
    );
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
