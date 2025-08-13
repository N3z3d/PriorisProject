import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import '../controllers/lists_controller.dart';

/// Service responsable de la gestion d'état des listes
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur les transformations d'état.
class ListsStateService {
  final ListsFilterService _filterService;

  ListsStateService(this._filterService);

  /// Applique les filtres aux listes
  List<CustomList> applyFilters(
    List<CustomList> lists,
    String searchQuery,
    ListType? selectedType,
    bool showCompleted,
    bool showInProgress,
    String? selectedDateFilter,
    SortOption sortOption,
  ) {
    return _filterService.applyFilters(
      lists,
      searchQuery: searchQuery,
      selectedType: selectedType,
      showCompleted: showCompleted,
      showInProgress: showInProgress,
      selectedDateFilter: selectedDateFilter,
      sortOption: sortOption,
    );
  }

  /// Met à jour une liste spécifique dans la liste
  List<CustomList> updateListInCollection(
    List<CustomList> lists, 
    CustomList updatedList,
  ) {
    return lists.map((list) => 
      list.id == updatedList.id ? updatedList : list
    ).toList();
  }

  /// Ajoute une liste à la collection
  List<CustomList> addListToCollection(
    List<CustomList> lists, 
    CustomList newList,
  ) {
    return [...lists, newList];
  }

  /// Supprime une liste de la collection
  List<CustomList> removeListFromCollection(
    List<CustomList> lists, 
    String listId,
  ) {
    return lists.where((list) => list.id != listId).toList();
  }

  /// Crée un nouvel état avec les listes mises à jour
  ListsState createUpdatedState(
    ListsState currentState,
    List<CustomList> updatedLists,
  ) {
    final filteredLists = applyFilters(
      updatedLists,
      currentState.searchQuery,
      currentState.selectedType,
      currentState.showCompleted,
      currentState.showInProgress,
      currentState.selectedDateFilter,
      currentState.sortOption,
    );

    return currentState.copyWith(
      lists: updatedLists,
      filteredLists: filteredLists,
    );
  }

  /// Crée un état avec des filtres mis à jour
  ListsState createFilteredState(
    ListsState currentState, {
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
  }) {
    final newSearchQuery = searchQuery ?? currentState.searchQuery;
    final newSelectedType = selectedType ?? currentState.selectedType;
    final newShowCompleted = showCompleted ?? currentState.showCompleted;
    final newShowInProgress = showInProgress ?? currentState.showInProgress;
    final newSelectedDateFilter = selectedDateFilter ?? currentState.selectedDateFilter;
    final newSortOption = sortOption ?? currentState.sortOption;

    final filteredLists = applyFilters(
      currentState.lists,
      newSearchQuery,
      newSelectedType,
      newShowCompleted,
      newShowInProgress,
      newSelectedDateFilter,
      newSortOption,
    );

    return currentState.copyWith(
      searchQuery: newSearchQuery,
      selectedType: newSelectedType,
      showCompleted: newShowCompleted,
      showInProgress: newShowInProgress,
      selectedDateFilter: newSelectedDateFilter,
      sortOption: newSortOption,
      filteredLists: filteredLists,
    );
  }

  /// Crée un état de chargement
  ListsState createLoadingState(ListsState currentState, bool isLoading) {
    return currentState.copyWith(
      isLoading: isLoading,
      error: isLoading ? null : currentState.error,
    );
  }

  /// Crée un état d'erreur
  ListsState createErrorState(ListsState currentState, String error) {
    return currentState.copyWith(
      isLoading: false,
      error: 'Erreur: $error',
    );
  }
}