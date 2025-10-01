import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';

/// Gestionnaire d'événements pour les listes
///
/// Responsabilité unique : Gérer les événements UI et les mises à jour d'état
/// en respectant les principes SOLID :
/// - SRP : Se concentre uniquement sur la gestion des événements et filtres
/// - OCP : Extensible via l'injection du service de filtrage
/// - DIP : Dépend de l'abstraction ILogger
class ListsEventHandler {
  final ListsFilterService _filterService;
  final ILogger _logger;

  const ListsEventHandler({
    required ListsFilterService filterService,
    required ILogger logger,
  })  : _filterService = filterService,
        _logger = logger;

  /// Met à jour l'état avec de nouvelles listes et applique les filtres
  ListsState updateListsAndApplyFilters(
    ListsState currentState,
    List<CustomList> lists,
  ) {
    _logger.debug(
      'Mise à jour état avec ${lists.length} listes',
      context: 'ListsEventHandler',
    );

    final filteredLists = _applyFiltersToLists(currentState, lists);

    final newState = currentState.copyWith(
      lists: lists,
      filteredLists: filteredLists,
    );

    // CORRECTION: Si le filtrage retourne une liste vide alors que nous avons des listes,
    // utiliser toutes les listes comme fallback
    if (lists.isNotEmpty && filteredLists.isEmpty) {
      _logger.warning(
        'Le filtrage a retourné 0 listes alors que nous en avons ${lists.length}. Utilisation de toutes les listes.',
        context: 'ListsEventHandler',
      );
      return newState.copyWith(filteredLists: lists);
    }

    _logger.debug(
      'État final - ${newState.totalListsCount} listes, ${newState.filteredListsCount} filtrées',
      context: 'ListsEventHandler',
    );

    return newState;
  }

  /// Met à jour la requête de recherche
  ListsState updateSearchQuery(ListsState currentState, String query) {
    final newState = currentState.copyWith(searchQuery: query);
    return _applyFilters(newState);
  }

  /// Met à jour le filtre par type
  ListsState updateTypeFilter(ListsState currentState, ListType? type) {
    final newState = currentState.copyWith(selectedType: type);
    return _applyFilters(newState);
  }

  /// Met à jour le filtre de statut (terminées)
  ListsState updateShowCompleted(ListsState currentState, bool show) {
    final newState = currentState.copyWith(showCompleted: show);
    return _applyFilters(newState);
  }

  /// Met à jour le filtre de statut (en cours)
  ListsState updateShowInProgress(ListsState currentState, bool show) {
    final newState = currentState.copyWith(showInProgress: show);
    return _applyFilters(newState);
  }

  /// Met à jour le filtre par date
  ListsState updateDateFilter(ListsState currentState, String? filter) {
    final newState = currentState.copyWith(selectedDateFilter: filter);
    return _applyFilters(newState);
  }

  /// Met à jour l'option de tri
  ListsState updateSortOption(ListsState currentState, SortOption option) {
    final newState = currentState.copyWith(sortOption: option);
    return _applyFilters(newState);
  }

  /// Ajoute une liste à l'état
  ListsState addListToState(ListsState currentState, CustomList list) {
    final updatedLists = [...currentState.lists, list];
    return updateListsAndApplyFilters(currentState, updatedLists);
  }

  /// Met à jour une liste dans l'état
  ListsState updateListInState(ListsState currentState, CustomList list) {
    final updatedLists = currentState.lists.map((l) =>
      l.id == list.id ? list : l
    ).toList();
    return updateListsAndApplyFilters(currentState, updatedLists);
  }

  /// Supprime une liste de l'état
  ListsState removeListFromState(ListsState currentState, String listId) {
    final updatedLists = currentState.lists.where((l) => l.id != listId).toList();
    return updateListsAndApplyFilters(currentState, updatedLists);
  }

  /// Ajoute un élément à une liste dans l'état
  ListsState addItemToListState(
    ListsState currentState,
    String listId,
    ListItem item,
  ) {
    final updatedLists = _updateListItems(currentState, listId, (items) => [...items, item]);
    return updateListsAndApplyFilters(currentState, updatedLists);
  }

  /// Ajoute plusieurs éléments à une liste dans l'état
  ListsState addMultipleItemsToListState(
    ListsState currentState,
    String listId,
    List<ListItem> newItems,
  ) {
    final updatedLists = _updateListItems(currentState, listId, (items) => [...items, ...newItems]);
    return updateListsAndApplyFilters(currentState, updatedLists);
  }

  /// Met à jour un élément dans l'état d'une liste
  ListsState updateItemInListState(
    ListsState currentState,
    String listId,
    ListItem item,
  ) {
    final updatedLists = _updateListItems(
      currentState,
      listId,
      (items) => items.map((i) => i.id == item.id ? item : i).toList(),
    );
    return updateListsAndApplyFilters(currentState, updatedLists);
  }

  /// Supprime un élément d'une liste dans l'état
  ListsState removeItemFromListState(
    ListsState currentState,
    String listId,
    String itemId,
  ) {
    final updatedLists = _updateListItems(
      currentState,
      listId,
      (items) => items.where((i) => i.id != itemId).toList(),
    );
    return updateListsAndApplyFilters(currentState, updatedLists);
  }

  /// Efface l'état après l'effacement des données
  ListsState updateStateAfterDataClearing(ListsState currentState) {
    return currentState.copyWith(
      lists: <CustomList>[],
      filteredLists: <CustomList>[],
    );
  }

  /// Met à jour l'état de chargement
  ListsState setLoadingState(ListsState currentState, bool isLoading) {
    return currentState.copyWith(isLoading: isLoading, error: null);
  }

  /// Met à jour l'état d'erreur
  ListsState setErrorState(ListsState currentState, String errorMessage) {
    return currentState.copyWith(
      isLoading: false,
      error: 'Erreur: $errorMessage',
    );
  }

  /// Efface les erreurs
  ListsState clearError(ListsState currentState) {
    return currentState.copyWith(error: null);
  }

  /// Applique les filtres aux listes fournies
  List<CustomList> _applyFiltersToLists(ListsState state, List<CustomList> lists) {
    _logger.debug(
      'Application des filtres: searchQuery="${state.searchQuery}", selectedType=${state.selectedType}, showCompleted=${state.showCompleted}',
      context: 'ListsEventHandler',
    );

    final result = _filterService.applyFilters(
      lists,
      searchQuery: state.searchQuery,
      selectedType: state.selectedType,
      showCompleted: state.showCompleted,
      showInProgress: state.showInProgress,
      selectedDateFilter: state.selectedDateFilter,
      sortOption: state.sortOption,
    );

    _logger.debug(
      'Filtrage terminé: ${result.length} listes filtrées sur ${lists.length}',
      context: 'ListsEventHandler',
    );

    return result;
  }

  /// Applique les filtres aux listes actuelles
  ListsState _applyFilters(ListsState state) {
    final filteredLists = _applyFiltersToLists(state, state.lists);
    return state.copyWith(filteredLists: filteredLists);
  }

  /// Met à jour les éléments d'une liste spécifique
  List<CustomList> _updateListItems(
    ListsState state,
    String listId,
    List<ListItem> Function(List<ListItem>) updateFunction,
  ) {
    return state.lists.map((list) {
      if (list.id == listId) {
        return _createUpdatedList(list, updateFunction);
      }
      return list;
    }).toList();
  }

  /// Crée une liste mise à jour avec de nouveaux éléments
  CustomList _createUpdatedList(
    CustomList list,
    List<ListItem> Function(List<ListItem>) updateFunction,
  ) {
    final updatedItems = updateFunction(list.items);
    return list.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }
}