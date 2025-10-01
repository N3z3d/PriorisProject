import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// État du controller des listes
///
/// Contient toutes les données nécessaires pour gérer l'affichage
/// et les interactions avec les listes personnalisées.
class ListsState {
  final List<CustomList> lists;
  final List<CustomList> filteredLists;
  final String searchQuery;
  final ListType? selectedType;
  final bool showCompleted;
  final bool showInProgress;
  final String? selectedDateFilter;
  final SortOption sortOption;
  final bool isLoading;
  final String? error;

  const ListsState({
    this.lists = const [],
    this.filteredLists = const [],
    this.searchQuery = '',
    this.selectedType,
    this.showCompleted = true,
    this.showInProgress = true,
    this.selectedDateFilter,
    this.sortOption = SortOption.NAME_ASC,
    this.isLoading = false,
    this.error,
  });

  /// Crée une copie de l'état avec de nouvelles valeurs
  ListsState copyWith({
    List<CustomList>? lists,
    List<CustomList>? filteredLists,
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
    bool? isLoading,
    String? error,
  }) {
    return ListsState(
      lists: lists ?? this.lists,
      filteredLists: filteredLists ?? this.filteredLists,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      showCompleted: showCompleted ?? this.showCompleted,
      showInProgress: showInProgress ?? this.showInProgress,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Service responsable de la gestion pure de l'état des listes
///
/// Respecte le Single Responsibility Principle en ne gérant que
/// les transformations d'état sans logique métier
class ListsStateManager {
  ListsState _state = const ListsState();

  ListsState get state => _state;

  /// Met à jour l'état de chargement
  void setLoading(bool isLoading) {
    _state = _state.copyWith(isLoading: isLoading);
  }

  /// Met à jour l'état d'erreur
  void setError(String? error) {
    _state = _state.copyWith(error: error, isLoading: false);
  }

  /// Efface l'erreur
  void clearError() {
    _state = _state.copyWith(error: null);
  }

  /// Met à jour les listes et applique les filtres
  void updateLists(List<CustomList> lists) {
    _state = _state.copyWith(
      lists: lists,
      isLoading: false,
      error: null,
    );
  }

  /// Met à jour les listes filtrées
  void updateFilteredLists(List<CustomList> filteredLists) {
    _state = _state.copyWith(filteredLists: filteredLists);
  }

  /// Met à jour la requête de recherche
  void updateSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
  }

  /// Met à jour le filtre de type
  void updateTypeFilter(ListType? type) {
    _state = _state.copyWith(selectedType: type);
  }

  /// Met à jour l'affichage des listes complétées
  void updateShowCompleted(bool show) {
    _state = _state.copyWith(showCompleted: show);
  }

  /// Met à jour l'affichage des listes en cours
  void updateShowInProgress(bool show) {
    _state = _state.copyWith(showInProgress: show);
  }

  /// Met à jour le filtre de date
  void updateDateFilter(String? filter) {
    _state = _state.copyWith(selectedDateFilter: filter);
  }

  /// Met à jour l'option de tri
  void updateSortOption(SortOption option) {
    _state = _state.copyWith(sortOption: option);
  }

  /// Ajoute une liste à l'état
  void addList(CustomList list) {
    final updatedLists = [..._state.lists, list];
    updateLists(updatedLists);
  }

  /// Met à jour une liste existante dans l'état
  void updateListInState(CustomList list) {
    final updatedLists = _state.lists.map((l) => l.id == list.id ? list : l).toList();
    updateLists(updatedLists);
  }

  /// Supprime une liste de l'état
  void removeList(String listId) {
    final updatedLists = _state.lists.where((l) => l.id != listId).toList();
    updateLists(updatedLists);
  }

  /// Ajoute un élément à une liste dans l'état
  void addItemToList(String listId, ListItem item) {
    final updatedLists = _state.lists.map((list) {
      if (list.id == listId) {
        final updatedItems = [...list.items, item];
        return list.copyWith(items: updatedItems);
      }
      return list;
    }).toList();
    updateLists(updatedLists);
  }

  /// Ajoute plusieurs éléments à une liste dans l'état
  void addMultipleItemsToList(String listId, List<ListItem> newItems) {
    final updatedLists = _state.lists.map((list) {
      if (list.id == listId) {
        final updatedItems = [...list.items, ...newItems];
        return list.copyWith(items: updatedItems);
      }
      return list;
    }).toList();
    updateLists(updatedLists);
  }

  /// Met à jour un élément dans une liste de l'état
  void updateItemInList(String listId, ListItem item) {
    final updatedLists = _state.lists.map((list) {
      if (list.id == listId) {
        final updatedItems = list.items.map((i) => i.id == item.id ? item : i).toList();
        return list.copyWith(items: updatedItems);
      }
      return list;
    }).toList();
    updateLists(updatedLists);
  }

  /// Supprime un élément d'une liste dans l'état
  void removeItemFromList(String listId, String itemId) {
    final updatedLists = _state.lists.map((list) {
      if (list.id == listId) {
        final updatedItems = list.items.where((i) => i.id != itemId).toList();
        return list.copyWith(items: updatedItems);
      }
      return list;
    }).toList();
    updateLists(updatedLists);
  }

  /// Efface toutes les données de l'état
  void clearAllData() {
    _state = const ListsState();
  }
}