import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/data/repositories/sample_data_service.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:flutter/foundation.dart';

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

/// Controller pour la gestion des listes personnalisées
/// 
/// Gère l'état des listes et toutes les actions utilisateur liées aux listes.
/// Utilise des services dédiés pour le filtrage et les opérations.
class ListsController extends StateNotifier<ListsState> {
  final CustomListRepository _listRepository;
  final ListItemRepository _itemRepository;
  final SampleDataService _sampleDataService;
  final ListsFilterService _filterService;

  ListsController(
    this._listRepository, 
    this._itemRepository, 
    this._sampleDataService,
    this._filterService,
  ) : super(const ListsState());

  /// Charge toutes les listes
  Future<void> loadLists() async {
    await _executeWithLoading(() async {
      final lists = await _listRepository.getAllLists();
      await _handleListsLoaded(lists);
    });
  }

  /// Gère les listes chargées
  Future<void> _handleListsLoaded(List<CustomList> lists) async {
    if (lists.isEmpty) {
      await _loadSampleDataIfNeeded();
      final updatedLists = await _listRepository.getAllLists();
      _updateListsAndApplyFilters(updatedLists);
    } else {
      _updateListsAndApplyFilters(lists);
    }
  }

  /// Met à jour la requête de recherche
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Met à jour le filtre par type
  void updateTypeFilter(ListType? type) {
    state = state.copyWith(selectedType: type);
    _applyFilters();
  }

  /// Met à jour le filtre de statut (terminées)
  void updateShowCompleted(bool show) {
    state = state.copyWith(showCompleted: show);
    _applyFilters();
  }

  /// Met à jour le filtre de statut (en cours)
  void updateShowInProgress(bool show) {
    state = state.copyWith(showInProgress: show);
    _applyFilters();
  }

  /// Met à jour le filtre par date
  void updateDateFilter(String? filter) {
    state = state.copyWith(selectedDateFilter: filter);
    _applyFilters();
  }

  /// Met à jour l'option de tri
  void updateSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
    _applyFilters();
  }

  /// Crée une nouvelle liste
  Future<void> createList(CustomList list) async {
    await _executeWithLoading(() async {
      await _listRepository.saveList(list);
      _addListToState(list);
    });
  }

  /// Ajoute une liste à l'état
  void _addListToState(CustomList list) {
    final updatedLists = [...state.lists, list];
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list) async {
    await _executeWithLoading(() async {
      await _listRepository.updateList(list);
      _updateListInState(list);
    });
  }

  /// Met à jour une liste dans l'état
  void _updateListInState(CustomList list) {
    final updatedLists = state.lists.map((l) => 
      l.id == list.id ? list : l
    ).toList();
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Supprime une liste
  Future<void> deleteList(String listId) async {
    await _executeWithLoading(() async {
      await _listRepository.deleteList(listId);
      _removeListFromState(listId);
    });
  }

  /// Supprime une liste de l'état
  void _removeListFromState(String listId) {
    final updatedLists = state.lists.where((l) => l.id != listId).toList();
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Ajoute un élément à une liste
  Future<void> addItemToList(String listId, ListItem item) async {
    await _executeWithLoading(() async {
      await _itemRepository.add(item);
      _addItemToListState(listId, item);
    });
  }

  /// Ajoute un élément à une liste dans l'état
  void _addItemToListState(String listId, ListItem item) {
    final updatedLists = _updateListItems(listId, (items) => [...items, item]);
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Met à jour un élément de liste
  Future<void> updateListItem(String listId, ListItem item) async {
    await _executeWithLoading(() async {
      await _itemRepository.update(item);
      _updateItemInListState(listId, item);
    });
  }

  /// Met à jour un élément dans l'état d'une liste
  void _updateItemInListState(String listId, ListItem item) {
    final updatedLists = _updateListItems(listId, (items) => 
      items.map((i) => i.id == item.id ? item : i).toList()
    );
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Supprime un élément de liste
  Future<void> removeItemFromList(String listId, String itemId) async {
    await _executeWithLoading(() async {
      await _itemRepository.delete(itemId);
      _removeItemFromListState(listId, itemId);
    });
  }

  /// Supprime un élément d'une liste dans l'état
  void _removeItemFromListState(String listId, String itemId) {
    final updatedLists = _updateListItems(listId, (items) => 
      items.where((i) => i.id != itemId).toList()
    );
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Efface les erreurs
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Nettoie les ressources
  void cleanup() {
    _filterService.clearCache();
  }

  // --- Méthodes privées ---

  /// Charge les données d'exemple si nécessaire
  Future<void> _loadSampleDataIfNeeded() async {
    try {
      await _sampleDataService.importSampleData();
    } catch (e) {
      debugPrint('Erreur lors du chargement des données d\'exemple: $e');
    }
  }

  /// Exécute une fonction avec gestion du loading et des erreurs
  Future<void> _executeWithLoading(Future<void> Function() action) async {
    _setLoadingState(true);
    
    try {
      await action();
      _setLoadingState(false);
    } catch (e) {
      _setErrorState(e.toString());
    }
  }

  /// Définit l'état de chargement
  void _setLoadingState(bool isLoading) {
    state = state.copyWith(isLoading: isLoading, error: null);
  }

  /// Définit l'état d'erreur
  void _setErrorState(String errorMessage) {
    state = state.copyWith(
      isLoading: false,
      error: 'Erreur: $errorMessage',
    );
  }

  /// Met à jour les listes et applique les filtres
  void _updateListsAndApplyFilters(List<CustomList> lists) {
    final filteredLists = _applyFiltersToLists(lists);
    
    state = state.copyWith(
      lists: lists,
      filteredLists: filteredLists,
    );
  }

  /// Applique les filtres aux listes fournies
  List<CustomList> _applyFiltersToLists(List<CustomList> lists) {
    return _filterService.applyFilters(
      lists,
      searchQuery: state.searchQuery,
      selectedType: state.selectedType,
      showCompleted: state.showCompleted,
      showInProgress: state.showInProgress,
      selectedDateFilter: state.selectedDateFilter,
      sortOption: state.sortOption,
    );
  }

  /// Applique les filtres aux listes actuelles
  void _applyFilters() {
    final filteredLists = _applyFiltersToLists(state.lists);
    state = state.copyWith(filteredLists: filteredLists);
  }

  /// Met à jour les éléments d'une liste spécifique
  List<CustomList> _updateListItems(
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

/// Provider pour le service de filtrage
final listsFilterServiceProvider = Provider<ListsFilterService>((ref) {
  return ListsFilterService();
});

/// Provider pour le controller des listes
final listsControllerProvider = StateNotifierProvider<ListsController, ListsState>((ref) {
  final listRepository = ref.read(customListRepositoryProvider);
  final itemRepository = ref.read(listItemRepositoryProvider);
  final sampleDataService = ref.read(sampleDataServiceProvider);
  final filterService = ref.read(listsFilterServiceProvider);
  return ListsController(listRepository, itemRepository, sampleDataService, filterService);
});

/// Provider pour les listes filtrées
final filteredListsProvider = Provider<List<CustomList>>((ref) {
  return ref.watch(listsControllerProvider).filteredLists;
});

/// Provider pour l'état de chargement
final listsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(listsControllerProvider).isLoading;
});

/// Provider pour les erreurs
final listsErrorProvider = Provider<String?>((ref) {
  return ref.watch(listsControllerProvider).error;
}); 
