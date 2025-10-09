import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import '../../models/lists_state.dart';

/// Lightweight helper dedicated to state transformations for lists.
/// SRP: encapsulates state mutations to keep controllers slim.
class ListsStateManager {
  const ListsStateManager();

  ListsState setLoading(ListsState state, {bool isLoading = true}) {
    return state.withLoading(loading: isLoading);
  }

  ListsState clearError(ListsState state) {
    return state.withoutError();
  }

  ListsState setError(ListsState state, String message) {
    return state.withError(message);
  }

  ListsState replaceLists(ListsState state, List<CustomList> lists) {
    return state.copyWith(
      lists: lists,
      filteredLists: lists,
      isLoading: false,
      error: null,
    );
  }

  ListsState updateFilteredLists(ListsState state, List<CustomList> filtered) {
    return state.copyWith(filteredLists: filtered);
  }

  ListsState addList(ListsState state, CustomList list) {
    final updated = [...state.lists, list];
    return state.copyWith(lists: updated);
  }

  ListsState updateList(ListsState state, CustomList list) {
    final updated = state.lists
        .map((existing) => existing.id == list.id ? list : existing)
        .toList();
    return state.copyWith(lists: updated);
  }

  ListsState removeList(ListsState state, String listId) {
    final updated = state.lists.where((list) => list.id != listId).toList();
    return state.copyWith(lists: updated);
  }

  ListsState addItem(ListsState state, String listId, ListItem item) {
    return _transformItems(state, listId, (items) => [...items, item]);
  }

  ListsState addItems(ListsState state, String listId, List<ListItem> items) {
    return _transformItems(state, listId, (existing) => [...existing, ...items]);
  }

  ListsState updateItem(ListsState state, String listId, ListItem item) {
    return _transformItems(state, listId, (items) {
      return items.map((current) => current.id == item.id ? item : current).toList();
    });
  }

  ListsState removeItem(ListsState state, String listId, String itemId) {
    return _transformItems(state, listId, (items) => items.where((item) => item.id != itemId).toList());
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
    return state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      selectedType: selectedType ?? state.selectedType,
      showCompleted: showCompleted ?? state.showCompleted,
      showInProgress: showInProgress ?? state.showInProgress,
      selectedDateFilter: selectedDateFilter ?? state.selectedDateFilter,
      sortOption: sortOption ?? state.sortOption,
    );
  }

  ListsState clearAll() => const ListsState.initial();

  ListsState _transformItems(
    ListsState state,
    String listId,
    List<ListItem> Function(List<ListItem>) transform,
  ) {
    final updated = state.lists.map((list) {
      if (list.id != listId) return list;
      final newItems = transform(list.items);
      return list.copyWith(items: newItems);
    }).toList();

    return state.copyWith(lists: updated);
  }
}
