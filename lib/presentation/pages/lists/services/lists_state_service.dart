import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart' as filterService;
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../interfaces/lists_controller_interfaces.dart';
import '../controllers/lists_controller_refactored.dart'; // Import for ListsState

/// Service responsable de la gestion d'état des listes
///
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur les transformations d'état et le filtrage.
///
/// Applique le principe Dependency Inversion en utilisant des abstractions.
class ListsStateService implements IListsStateService {
  final filterService.ListsFilterService _filterService;

  ListsStateService(this._filterService);

  /// Mappe le SortOption de l'interface vers celui du service de filtrage
  filterService.SortOption _mapToFilterServiceSortOption(SortOption option) {
    switch (option) {
      case SortOption.NAME_ASC:
        return filterService.SortOption.NAME_ASC;
      case SortOption.NAME_DESC:
        return filterService.SortOption.NAME_DESC;
      case SortOption.DATE_CREATED_ASC:
        return filterService.SortOption.DATE_CREATED_ASC;
      case SortOption.DATE_CREATED_DESC:
        return filterService.SortOption.DATE_CREATED_DESC;
      case SortOption.PROGRESS_ASC:
        return filterService.SortOption.PROGRESS_ASC;
      case SortOption.PROGRESS_DESC:
        return filterService.SortOption.PROGRESS_DESC;
    }
  }

  @override
  List<CustomList> applyFilters(
    List<CustomList> lists, {
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
  }) {
    try {
      LoggerService.instance.debug(
        'Application des filtres: ${lists.length} listes, searchQuery="$searchQuery", selectedType=$selectedType',
        context: 'ListsStateService'
      );

      final result = _filterService.applyFilters(
        lists,
        searchQuery: searchQuery ?? '',
        selectedType: selectedType,
        showCompleted: showCompleted ?? true,
        showInProgress: showInProgress ?? true,
        selectedDateFilter: selectedDateFilter,
        sortOption: _mapToFilterServiceSortOption(sortOption ?? SortOption.NAME_ASC),
      );

      LoggerService.instance.debug(
        'Filtrage terminé: ${result.length} listes filtrées',
        context: 'ListsStateService'
      );

      return result;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de l\'application des filtres',
        context: 'ListsStateService',
        error: e
      );
      // En cas d'erreur de filtrage, retourner la liste complète
      return lists;
    }
  }

  @override
  List<CustomList> updateListInCollection(
    List<CustomList> lists,
    CustomList updatedList,
  ) {
    try {
      LoggerService.instance.debug(
        'Mise à jour de la liste "${updatedList.name}" dans la collection',
        context: 'ListsStateService'
      );

      return lists.map((list) =>
        list.id == updatedList.id ? updatedList : list
      ).toList();
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la mise à jour de la liste dans la collection',
        context: 'ListsStateService',
        error: e
      );
      return lists;
    }
  }

  @override
  List<CustomList> addListToCollection(
    List<CustomList> lists,
    CustomList newList,
  ) {
    try {
      LoggerService.instance.debug(
        'Ajout de la liste "${newList.name}" à la collection',
        context: 'ListsStateService'
      );

      return [...lists, newList];
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de l\'ajout de la liste à la collection',
        context: 'ListsStateService',
        error: e
      );
      return lists;
    }
  }

  @override
  List<CustomList> removeListFromCollection(
    List<CustomList> lists,
    String listId,
  ) {
    try {
      LoggerService.instance.debug(
        'Suppression de la liste $listId de la collection',
        context: 'ListsStateService'
      );

      return lists.where((list) => list.id != listId).toList();
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la suppression de la liste de la collection',
        context: 'ListsStateService',
        error: e
      );
      return lists;
    }
  }

  /// Crée un nouvel état avec les listes mises à jour
  ListsState createUpdatedState(
    ListsState currentState,
    List<CustomList> updatedLists,
  ) {
    final filteredLists = applyFilters(
      updatedLists,
      searchQuery: currentState.searchQuery,
      selectedType: currentState.selectedType,
      showCompleted: currentState.showCompleted,
      showInProgress: currentState.showInProgress,
      selectedDateFilter: currentState.selectedDateFilter,
      sortOption: currentState.sortOption,
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
      searchQuery: newSearchQuery,
      selectedType: newSelectedType,
      showCompleted: newShowCompleted,
      showInProgress: newShowInProgress,
      selectedDateFilter: newSelectedDateFilter,
      sortOption: newSortOption,
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

  @override
  List<CustomList> updateListItems(
    List<CustomList> lists,
    String listId,
    List<ListItem> Function(List<ListItem>) updateFunction,
  ) {
    try {
      LoggerService.instance.debug(
        'Mise à jour des éléments de la liste $listId',
        context: 'ListsStateService'
      );

      return lists.map((list) {
        if (list.id == listId) {
          return createUpdatedList(list, updateFunction);
        }
        return list;
      }).toList();
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la mise à jour des éléments de la liste $listId',
        context: 'ListsStateService',
        error: e
      );
      return lists;
    }
  }

  @override
  CustomList createUpdatedList(
    CustomList list,
    List<ListItem> Function(List<ListItem>) updateFunction,
  ) {
    try {
      LoggerService.instance.debug(
        'Création d\'une liste mise à jour pour "${list.name}"',
        context: 'ListsStateService'
      );

      final updatedItems = updateFunction(list.items);
      return list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la création de la liste mise à jour',
        context: 'ListsStateService',
        error: e
      );
      // En cas d'erreur, retourner la liste inchangée
      return list;
    }
  }

  /// Méthodes utilitaires pour les transformations d'état complètes

  /// Applique les filtres avec les paramètres complets d'un état
  List<CustomList> applyFiltersWithState(
    List<CustomList> lists,
    String searchQuery,
    ListType? selectedType,
    bool showCompleted,
    bool showInProgress,
    String? selectedDateFilter,
    SortOption sortOption,
  ) {
    return applyFilters(
      lists,
      searchQuery: searchQuery,
      selectedType: selectedType,
      showCompleted: showCompleted,
      showInProgress: showInProgress,
      selectedDateFilter: selectedDateFilter,
      sortOption: sortOption,
    );
  }

  /// Ajoute un élément à une liste dans une collection
  List<CustomList> addItemToListInCollection(
    List<CustomList> lists,
    String listId,
    ListItem item,
  ) {
    return updateListItems(lists, listId, (items) => [...items, item]);
  }

  /// Supprime un élément d'une liste dans une collection
  List<CustomList> removeItemFromListInCollection(
    List<CustomList> lists,
    String listId,
    String itemId,
  ) {
    return updateListItems(lists, listId, (items) =>
        items.where((item) => item.id != itemId).toList());
  }

  /// Met à jour un élément dans une liste de la collection
  List<CustomList> updateItemInListInCollection(
    List<CustomList> lists,
    String listId,
    ListItem updatedItem,
  ) {
    return updateListItems(lists, listId, (items) =>
        items.map((item) => item.id == updatedItem.id ? updatedItem : item)
            .toList());
  }
}