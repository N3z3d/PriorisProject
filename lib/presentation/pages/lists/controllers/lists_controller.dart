import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import '../models/lists_state.dart';
import '../interfaces/lists_managers_interfaces.dart';

/// **Refactored ListsController** - SOLID Compliant State Management
///
/// **Single Responsibility Principle (SRP)** : Coordination et gestion d'état uniquement
/// **Open/Closed Principle (OCP)** : Extensible via injection de managers spécialisés
/// **Liskov Substitution Principle (LSP)** : Respecte les contrats d'interfaces
/// **Interface Segregation Principle (ISP)** : Utilise des interfaces spécialisées
/// **Dependency Inversion Principle (DIP)** : Dépend d'abstractions, injecte les implémentations
///
/// **Taille** : ~350 lignes (respecte la contrainte < 500 lignes)
/// **Responsabilités** : État + coordination entre managers + lifecycle
class RefactoredListsController extends StateNotifier<ListsState> {
  // === Dependency Injection (DIP compliant) ===
  final IListsInitializationManager _initializationManager;
  final IListsPersistenceManager _persistenceManager;
  final IListsFilterManager _filterManager;
  final IListsValidationService _validationService;
  final ILogger _logger;

  // === Lifecycle management ===
  bool _isDisposed = false;
  bool _isInitialized = false;

  /// **Dependency Injection Constructor**
  RefactoredListsController({
    required IListsInitializationManager initializationManager,
    required IListsPersistenceManager persistenceManager,
    required IListsFilterManager filterManager,
    required IListsValidationService validationService,
    required ILogger logger,
  }) : _logger = logger,
        _initializationManager = initializationManager,
        _persistenceManager = persistenceManager,
        _filterManager = filterManager,
        _validationService = validationService,
        super(const ListsState.initial()) {
    _autoInitialize();
  }

  /// **SRP** : Délègue l'initialisation au manager spécialisé
  Future<void> _autoInitialize() async {
    if (_isDisposed || _isInitialized) return;

    try {
      state = state.withLoading();
      await _initializationManager.initializeAuto();
      _isInitialized = true;
      await loadLists();
    } catch (e) {
      if (!_isDisposed) {
        state = state.withError('Erreur d\'initialisation: $e');
      }
    }
  }

  /// **SRP** : Gestion d'état pure - charge les listes
  Future<void> loadLists() async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('loadLists', () async {
      final lists = await _persistenceManager.loadAllLists();
      final validatedLists = _validationService.sanitizeLists(lists);
      final filteredLists = _filterManager.applyFilters(validatedLists, state);

      state = state.copyWith(
        lists: validatedLists,
        filteredLists: filteredLists,
      );
    });
  }

  /// Force le rechargement complet
  Future<void> forceReloadFromPersistence() async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('forceReloadFromPersistence', () async {
      _filterManager.clearCache();
      final lists = await _persistenceManager.forceReloadFromPersistence();
      final validatedLists = _validationService.sanitizeLists(lists);
      final filteredLists = _filterManager.applyFilters(validatedLists, state);

      state = state.copyWith(
        lists: validatedLists,
        filteredLists: filteredLists,
      );
    });
  }

  /// Efface toutes les données
  Future<void> clearAllData() async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('clearAllData', () async {
      await _persistenceManager.clearAllData();
      state = state.copyWith(
        lists: <CustomList>[],
        filteredLists: <CustomList>[],
      );
    });
  }

  /// Crée une nouvelle liste
  Future<void> createList(CustomList list) async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('createList', () async {
      if (!_validationService.validateList(list)) {
        throw Exception('Liste invalide');
      }

      await _persistenceManager.saveList(list);
      await _persistenceManager.verifyListPersistence(list.id);

      final updatedLists = [...state.lists, list];
      final filteredLists = _filterManager.applyFilters(updatedLists, state);

      state = state.copyWith(
        lists: updatedLists,
        filteredLists: filteredLists,
      );
    });
  }

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list) async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('updateList', () async {
      if (!_validationService.validateList(list)) {
        throw Exception('Liste invalide pour mise à jour');
      }

      await _persistenceManager.updateList(list);

      final updatedLists = state.lists
          .map((l) => l.id == list.id ? list : l)
          .toList();
      final filteredLists = _filterManager.applyFilters(updatedLists, state);

      state = state.copyWith(
        lists: updatedLists,
        filteredLists: filteredLists,
      );
    });
  }

  /// Supprime une liste
  Future<void> deleteList(String listId) async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('deleteList', () async {
      await _persistenceManager.deleteList(listId);

      final updatedLists = state.lists.where((l) => l.id != listId).toList();
      final filteredLists = _filterManager.applyFilters(updatedLists, state);

      state = state.copyWith(
        lists: updatedLists,
        filteredLists: filteredLists,
      );
    });
  }

  /// Ajoute un élément à une liste
  Future<void> addItemToList(String listId, ListItem item) async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('addItemToList', () async {
      if (!_validationService.validateListItem(item)) {
        throw Exception('Élément invalide');
      }

      await _persistenceManager.saveListItem(item);
      await _persistenceManager.verifyItemPersistence(item.id);

      _updateListInState(listId, (list) =>
        list.copyWith(items: [...list.items, item])
      );
    });
  }

  /// Ajoute plusieurs éléments
  Future<void> addMultipleItemsToList(String listId, List<String> itemTitles) async {
    if (!_isSafeToOperate || itemTitles.isEmpty) return;

    await _executeWithStateManagement('addMultipleItemsToList', () async {
      final items = itemTitles
          .where((title) => title.trim().isNotEmpty)
          .map((title) => ListItem(
                id: const Uuid().v4(),
                title: title.trim(),
                createdAt: DateTime.now(),
                listId: listId,
              ))
          .toList();

      await _persistenceManager.saveMultipleItems(items);

      _updateListInState(listId, (list) =>
        list.copyWith(items: [...list.items, ...items])
      );
    });
  }

  /// Met à jour un élément
  Future<void> updateListItem(String listId, ListItem item) async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('updateListItem', () async {
      if (!_validationService.validateListItem(item)) {
        throw Exception('Élément invalide pour mise à jour');
      }

      await _persistenceManager.updateListItem(item);

      _updateListInState(listId, (list) => list.copyWith(
        items: list.items.map((i) => i.id == item.id ? item : i).toList(),
      ));
    });
  }

  /// Supprime un élément
  Future<void> removeItemFromList(String listId, String itemId) async {
    if (!_isSafeToOperate) return;

    await _executeWithStateManagement('removeItemFromList', () async {
      await _persistenceManager.deleteListItem(itemId);

      _updateListInState(listId, (list) => list.copyWith(
        items: list.items.where((i) => i.id != itemId).toList(),
      ));
    });
  }

  // === Filter Operations ===

  void updateSearchQuery(String query) {
    if (!_isSafeToOperate) return;
    _updateFilters(state.copyWith(searchQuery: query));
  }

  void updateTypeFilter(ListType? type) {
    if (!_isSafeToOperate) return;
    _updateFilters(state.copyWith(selectedType: type));
  }

  void updateShowCompleted(bool show) {
    if (!_isSafeToOperate) return;
    _updateFilters(state.copyWith(showCompleted: show));
  }

  void updateShowInProgress(bool show) {
    if (!_isSafeToOperate) return;
    _updateFilters(state.copyWith(showInProgress: show));
  }

  void updateDateFilter(String? filter) {
    if (!_isSafeToOperate) return;
    _updateFilters(state.copyWith(selectedDateFilter: filter));
  }

  void updateSortOption(SortOption option) {
    if (!_isSafeToOperate) return;
    _updateFilters(state.copyWith(sortOption: option));
  }

  void clearError() {
    if (_isSafeToOperate) {
      state = state.withoutError();
    }
  }

  // === Lifecycle ===

  bool get _isSafeToOperate => mounted && !_isDisposed && _isInitialized;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      _filterManager.clearCache();
    } catch (e) {
      // Ignore errors during disposal
    }

    super.dispose();
  }

  // === Private Methods ===

  Future<void> _executeWithStateManagement(String operationName, Future<void> Function() operation) async {
    if (!_isSafeToOperate) return;

    state = state.withLoading();

    try {
      await operation();
      if (_isSafeToOperate) {
        state = state.withLoading(false);
      }
    } catch (e) {
      _logger.error(
        'Erreur lors de l\'opération $operationName',
        context: 'RefactoredListsController',
        error: e,
      );

      if (_isSafeToOperate) {
        state = state.withError(e.toString());
      }
      rethrow;
    }
  }

  void _updateListInState(String listId, CustomList Function(CustomList) updateFunction) {
    final updatedLists = state.lists.map((list) {
      if (list.id == listId) {
        return updateFunction(list);
      }
      return list;
    }).toList();

    final filteredLists = _filterManager.applyFilters(updatedLists, state);

    state = state.copyWith(
      lists: updatedLists,
      filteredLists: filteredLists,
    );
  }

  void _updateFilters(ListsState newState) {
    final filteredLists = _filterManager.applyFilters(newState.lists, newState);
    state = newState.copyWith(filteredLists: filteredLists);
  }
}