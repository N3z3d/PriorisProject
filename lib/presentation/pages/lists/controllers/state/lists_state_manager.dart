import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import '../../models/lists_state.dart';
import '../../models/lists_filter_patch.dart';
import 'item_transformations.dart';
import 'item_transformations.dart';

/// Lightweight helper dedicated to state transformations for lists.
/// SRP: encapsulates state mutations to keep controllers slim.
class ListsStateManager {
  const ListsStateManager();

  ListsState setLoading(ListsState state, {bool isLoading = true}) {
    return state.withLoading(loading: isLoading);
  }

  ListsState clearError(ListsState state) {
    return state.copyWith(
      error: null,
      isLoading: false,
    );
  }

  ListsState setError(ListsState state, String message) {
    return state.withError(message);
  }

  ListsState replaceLists(ListsState state, List<CustomList> lists) {
    return _withLists(state, lists).copyWith(filteredLists: lists);
  }

  ListsState updateFilteredLists(ListsState state, List<CustomList> filtered) {
    return state.copyWith(filteredLists: filtered);
  }

  ListsState addList(ListsState state, CustomList list) {
    return _modifyLists(state, (lists) => [...lists, list]);
  }

  ListsState updateList(ListsState state, CustomList list) {
    return _modifyLists(
      state,
      (lists) => lists
          .map((existing) => existing.id == list.id ? list : existing)
          .toList(),
    );
  }

  ListsState removeList(ListsState state, String listId) {
    return _modifyLists(
      state,
      (lists) => lists.where((list) => list.id != listId).toList(),
    );
  }

  ListsState addItem(ListsState state, String listId, ListItem item) {
    return _transformItems(
      state,
      listId,
      ItemTransformations.append(item),
    );
  }

  ListsState addItems(ListsState state, String listId, List<ListItem> items) {
    return _transformItems(
      state,
      listId,
      ItemTransformations.appendMany(items),
    );
  }

  ListsState updateItem(ListsState state, String listId, ListItem item) {
    return _transformItems(
      state,
      listId,
      ItemTransformations.replace(item),
    );
  }

  ListsState removeItem(ListsState state, String listId, String itemId) {
    return _transformItems(
      state,
      listId,
      ItemTransformations.remove(itemId),
    );
  }

  ListsState updateFilters(
    ListsState state, {
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
  }) {
    final patch = ListsFilterPatch(
      searchQuery: searchQuery,
      selectedType: selectedType,
      showCompleted: showCompleted,
      showInProgress: showInProgress,
      selectedDateFilter: selectedDateFilter,
      sortOption: sortOption,
    );
    return applyFilterPatch(state, patch);
  }

  ListsState applyFilterPatch(ListsState state, ListsFilterPatch patch) {
    return state.copyWith(
      searchQuery: patch.searchQuery ?? state.searchQuery,
      selectedType: patch.selectedType ?? state.selectedType,
      showCompleted: patch.showCompleted ?? state.showCompleted,
      showInProgress: patch.showInProgress ?? state.showInProgress,
      selectedDateFilter: patch.selectedDateFilter ?? state.selectedDateFilter,
      sortOption: patch.sortOption ?? state.sortOption,
    );
  }

  ListsState clearAll() => const ListsState.initial();

  ListsState setItemSyncing(
    ListsState state,
    String itemId, {
    required bool isSyncing,
  }) {
    final updated = Set<String>.from(state.syncingItemIds);
    if (isSyncing) {
      updated.add(itemId);
    } else {
      updated.remove(itemId);
    }
    return state.copyWith(syncingItemIds: updated);
  }

  ListsState setMultipleItemsSyncing(
    ListsState state,
    Set<String> itemIds, {
    required bool isSyncing,
  }) {
    final updated = Set<String>.from(state.syncingItemIds);
    if (isSyncing) {
      updated.addAll(itemIds);
    } else {
      updated.removeAll(itemIds);
    }
    return state.copyWith(syncingItemIds: updated);
  }

  ListsState _transformItems(
    ListsState state,
    String listId,
      ItemTransformation transform,
  ) {
    final updated = state.lists.map((list) {
      if (list.id != listId) return list;
      final newItems = transform(list.items);
      return list.copyWith(items: newItems);
    }).toList();

    return _withLists(state, updated);
  }

  ListsState _withLists(ListsState state, List<CustomList> lists) {
    return state.copyWith(
      lists: lists,
      isLoading: false,
      error: null,
    );
  }

  ListsState _modifyLists(
    ListsState state,
    List<CustomList> Function(List<CustomList>) transform,
  ) {
    final updated = transform(state.lists);
    return _withLists(state, updated);
  }
}
