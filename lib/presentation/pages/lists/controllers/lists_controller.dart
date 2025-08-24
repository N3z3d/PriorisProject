import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/presentation/services/performance/data_consistency_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/presentation/services/performance/performance_monitor.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';

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
/// ADAPTIVE MODE: Utilise l'AdaptivePersistenceService pour une gestion
/// intelligente de la persistance selon l'état d'authentification.
class ListsController extends StateNotifier<ListsState> {
  // ADAPTIVE FIX: Service de persistance adaptatif au lieu des repositories directs
  final AdaptivePersistenceService? _adaptivePersistenceService;
  final ListsFilterService _filterService;
  
  // Backwards compatibility: Repositories pour constructeurs legacy
  final CustomListRepository? _listRepository;
  final ListItemRepository? _itemRepository;

  // ADAPTIVE FIX: Constructeur principal avec AdaptivePersistenceService
  ListsController.adaptive(
    AdaptivePersistenceService adaptivePersistenceService,
    CustomListRepository localListRepository,
    ListItemRepository localItemRepository,
    this._filterService,
  ) : _adaptivePersistenceService = adaptivePersistenceService,
        _listRepository = localListRepository,
        _itemRepository = localItemRepository,
        super(const ListsState()) {
    // Initialisation immédiate avec service adaptatif
    _initializeAdaptive();
  }

  // LEGACY: Constructeur avec repositories directs (pour compatibilité)
  @Deprecated('Use ListsController.adaptive() instead')
  ListsController(
    CustomListRepository listRepository,
    ListItemRepository itemRepository,
    this._filterService,
  ) : _listRepository = listRepository,
        _itemRepository = itemRepository,
        _adaptivePersistenceService = null,
        super(const ListsState()) {
    // Initialisation legacy
    _initializeSync();
  }
  
  // DEPRECATED: Constructeur asynchrone - conservé pour compatibilité tests existants
  @Deprecated('Use primary constructor with pre-initialized repositories')
  ListsController.async(
    Future<CustomListRepository> listRepositoryFuture, 
    Future<ListItemRepository> itemRepositoryFuture, 
    this._filterService,
  ) : _listRepository = InMemoryCustomListRepository(), // Temporaire pour tests
        _itemRepository = InMemoryListItemRepository(), // Temporaire pour tests
        _adaptivePersistenceService = null, // Pas utilisé dans ce constructeur
        super(const ListsState()) {
    // ARCHITECTURE FIX: Initialiser les repositories de manière asynchrone
    _initializeRepositoriesAsync(listRepositoryFuture, itemRepositoryFuture);
  }
  
  /// ADAPTIVE FIX: Initialisation avec service adaptatif
  void _initializeAdaptive() {
    LoggerService.instance.info('Initialisation adaptive du ListsController', context: 'ListsController');
    
    // Charger les données via le service adaptatif
    loadLists();
  }

  /// LEGACY: Initialisation synchrone immédiate (pour compatibilité)
  @Deprecated('Use _initializeAdaptive() instead')
  void _initializeSync() {
    // Repositories déjà prêts via HiveRepositoryRegistry, charger immédiatement
    LoggerService.instance.info('Initialisation synchrone du ListsController - chargement immédiat', context: 'ListsController');
    
    // Charger les données immédiatement
    loadLists();
  }
  
  /// Initialisation asynchrone (pour compatibilité tests)
  Future<void> _initializeRepositoriesAsync(
    Future<CustomListRepository> listRepositoryFuture,
    Future<ListItemRepository> itemRepositoryFuture,
  ) async {
    try {
      // DEPRECATED: Cette méthode est obsolète avec l'approche synchrone
      // Les repositories temporaires sont utilisés seulement pour compatibilité tests
      await listRepositoryFuture; // Attendre l'initialisation
      await itemRepositoryFuture; // Attendre l'initialisation
      
      await loadLists();
    } catch (e) {
      if (mounted) {
        _setErrorState('Erreur d\'initialisation: $e');
      }
    }
  }

  /// ADAPTIVE FIX: Charge toutes les listes via le service adaptatif
  Future<void> loadLists() async {
    // DISPOSAL FIX: Ne rien faire si le controller est disposé
    if (!isSafelyMounted) {
      LoggerService.instance.warning('Tentative de chargement après disposal - opération ignorée', context: 'ListsController');
      return;
    }
    
    LoggerService.instance.debug('Début chargement des listes via service adaptatif', context: 'ListsController');
    
    await _executeWithLoading(() async {
      try {
        List<CustomList> lists;
        
        // ADAPTIVE: Utiliser le service adaptatif ou fallback vers repository legacy
        if (_adaptivePersistenceService != null) {
          lists = await _adaptivePersistenceService.getAllLists();
          if (isSafelyMounted) {
            LoggerService.instance.info('${lists.length} listes chargées via AdaptivePersistenceService (${_adaptivePersistenceService.currentMode})', context: 'ListsController');
          }
        } else if (_listRepository != null) {
          // Fallback legacy
          lists = await _listRepository!.getAllLists();
          if (isSafelyMounted) {
            LoggerService.instance.info('${lists.length} listes chargées depuis repository legacy', context: 'ListsController');
          }
        } else {
          throw StateError('Aucun service de persistance configuré');
        }
        
        // DISPOSAL FIX: Vérifier isSafelyMounted avant traitement
        if (isSafelyMounted) {
          await _handleListsLoaded(lists);
          // SAFE STATE ACCESS: Accès sécurisé à l'état après vérification
          try {
            print('✓ Chargement terminé - ${state.lists.length} listes dans l\'\u00e9tat');
          } catch (e) {
            print('⚠️ Impossible d\'accéder à l\'état après chargement (controller disposé)');
          }
        }
      } catch (e) {
        LoggerService.instance.error('Erreur lors du chargement des listes', context: 'ListsController', error: e);
        if (isSafelyMounted) {
          _setErrorState('Erreur lors du chargement des listes: $e');
        }
        rethrow;
      }
    });
  }
  
  /// Efface toutes les données (listes et éléments) via le service adaptatif
  /// Utilisé lors de la déconnexion avec effacement des données
  Future<void> clearAllData() async {
    print('🗑️ Début de l\'effacement de toutes les données...');
    
    try {
      List<CustomList> allLists;
      List<ListItem> allItems = [];
      
      // ADAPTIVE: Récupérer toutes les données via le service adaptatif
      if (_adaptivePersistenceService != null) {
        allLists = await _adaptivePersistenceService.getAllLists();
        
        // Récupérer tous les items de toutes les listes
        for (final list in allLists) {
          final items = await _adaptivePersistenceService.getItemsByListId(list.id);
          allItems.addAll(items);
        }
        
        // Effacer toutes les listes via le service adaptatif
        for (final list in allLists) {
          await _adaptivePersistenceService.deleteList(list.id);
          print('🗑️ Liste "${list.name}" effacée');
        }
        
        // Effacer tous les éléments via le service adaptatif  
        for (final item in allItems) {
          await _adaptivePersistenceService.deleteItem(item.id);
        }
      } else if (_listRepository != null && _itemRepository != null) {
        // Fallback legacy
        allLists = await _listRepository!.getAllLists();
        for (final list in allLists) {
          await _listRepository!.deleteList(list.id);
          print('🗑️ Liste "${list.name}" effacée');
        }
        
        allItems = await _itemRepository!.getAll();
        for (final item in allItems) {
          await _itemRepository!.delete(item.id);
        }
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
      
      print('🗑️ Tous les ${allItems.length} éléments effacés');
      
      // Mettre à jour l'état local
      if (mounted) {
        state = state.copyWith(
          lists: <CustomList>[],
          filteredLists: <CustomList>[],
        );
      }
      
      print('✅ Toutes les données ont été effacées avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'effacement des données: $e');
      rethrow;
    }
  }

  /// ADAPTIVE FIX: Force le rechargement avec invalidation de cache
  Future<void> forceReloadFromPersistence() async {
    // PERFORMANCE FIX: Invalider le cache avant rechargement
    DataConsistencyService.invalidateCache();
    
    await _executeWithLoading(() async {
      try {
        // Vider l'état local d'abord
        if (mounted) {
          state = state.copyWith(
            lists: <CustomList>[],
            filteredLists: <CustomList>[],
          );
        }
        
        // Recharger complètement depuis la persistance via le service adaptatif
        List<CustomList> lists;
        if (_adaptivePersistenceService != null) {
          lists = await _adaptivePersistenceService.getAllLists();
        } else if (_listRepository != null) {
          lists = await _listRepository!.getAllLists();
        } else {
          throw StateError('Aucun service de persistance configuré');
        }
        
        await _handleListsLoaded(lists);
        
        // PERFORMANCE FIX: Mettre en cache les nouveaux résultats
        DataConsistencyService.cacheLists(lists);
        
        print('🔄 Rechargement forcé terminé: ${lists.length} listes chargées');
      } catch (e) {
        _setErrorState('Erreur lors du rechargement forcé: $e');
        rethrow;
      }
    });
  }

  /// Gère les listes chargées et charge leurs items
  Future<void> _handleListsLoaded(List<CustomList> lists) async {
    // ADAPTIVE FIX: Charger les items via le service adaptatif
    final listsWithItems = <CustomList>[];
    for (final list in lists) {
      List<ListItem> items;
      
      // ADAPTIVE: Utiliser le service adaptatif ou fallback vers repository legacy
      if (_adaptivePersistenceService != null) {
        items = await _adaptivePersistenceService.getItemsByListId(list.id);
      } else if (_itemRepository != null) {
        // Fallback legacy
        items = await _itemRepository!.getByListId(list.id);
      } else {
        items = [];
      }
      
      listsWithItems.add(list.copyWith(items: items));
    }
    
    _updateListsAndApplyFilters(listsWithItems);
  }

  /// Met à jour la requête de recherche
  void updateSearchQuery(String query) {
    if (mounted) {
      state = state.copyWith(searchQuery: query);
      _applyFilters();
    }
  }

  /// Met à jour le filtre par type
  void updateTypeFilter(ListType? type) {
    if (mounted) {
      state = state.copyWith(selectedType: type);
      _applyFilters();
    }
  }

  /// Met à jour le filtre de statut (terminées)
  void updateShowCompleted(bool show) {
    if (mounted) {
      state = state.copyWith(showCompleted: show);
      _applyFilters();
    }
  }

  /// Met à jour le filtre de statut (en cours)
  void updateShowInProgress(bool show) {
    if (mounted) {
      state = state.copyWith(showInProgress: show);
      _applyFilters();
    }
  }

  /// Met à jour le filtre par date
  void updateDateFilter(String? filter) {
    if (mounted) {
      state = state.copyWith(selectedDateFilter: filter);
      _applyFilters();
    }
  }

  /// Met à jour l'option de tri
  void updateSortOption(SortOption option) {
    if (mounted) {
      state = state.copyWith(sortOption: option);
      _applyFilters();
    }
  }

  /// Crée une nouvelle liste via le service adaptatif
  Future<void> createList(CustomList list) async {
    await _executeWithLoading(() async {
      try {
        // ADAPTIVE: Sauvegarder via le service adaptatif
        if (_adaptivePersistenceService != null) {
          await _adaptivePersistenceService.saveList(list);
        } else if (_listRepository != null) {
          // Fallback legacy
          await _listRepository!.saveList(list);
        } else {
          throw StateError('Aucun service de persistance configuré');
        }
        
        // CORRECTION: Vérifier que la sauvegarde a réussi
        await _verifyListPersistence(list.id);
        
        // Seulement après vérification, ajouter à l'état
        _addListToState(list);
      } catch (e) {
        // CORRECTION: Gestion d'erreur robuste
        _setErrorState('Échec de création de la liste: $e');
        rethrow;
      }
    });
  }
  
  /// Vérifie qu'une liste a bien été persistée LOCALEMENT
  /// Note: En mode cloudFirst, on vérifie le local car le sync cloud est asynchrone
  Future<void> _verifyListPersistence(String listId) async {
    try {
      CustomList? persistedList;
      
      // CORRECTION: Toujours vérifier dans le repository LOCAL
      // car en mode cloudFirst le sync cloud se fait en async
      if (_listRepository != null) {
        persistedList = await _listRepository!.getListById(listId);
      } else {
        throw StateError('Repository local non configuré');
      }
      
      if (persistedList == null) {
        throw Exception('Liste non trouvée après sauvegarde - échec de persistance locale');
      }
      
      print('✅ Vérification persistance locale réussie pour "${persistedList.name}"');
    } catch (e) {
      throw Exception('Erreur lors de la vérification de persistance: $e');
    }
  }

  /// Ajoute une liste à l'état
  void _addListToState(CustomList list) {
    final updatedLists = [...state.lists, list];
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Met à jour une liste existante via le service adaptatif
  Future<void> updateList(CustomList list) async {
    await _executeWithLoading(() async {
      // ADAPTIVE: Mettre à jour via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService.saveList(list); // saveList fait update automatiquement
      } else if (_listRepository != null) {
        await _listRepository!.updateList(list);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
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

  /// Supprime une liste via le service adaptatif
  Future<void> deleteList(String listId) async {
    await _executeWithLoading(() async {
      // ADAPTIVE: Supprimer via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService.deleteList(listId);
      } else if (_listRepository != null) {
        await _listRepository!.deleteList(listId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
      _removeListFromState(listId);
    });
  }

  /// Supprime une liste de l'état
  void _removeListFromState(String listId) {
    final updatedLists = state.lists.where((l) => l.id != listId).toList();
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Ajoute un élément à une liste via le service adaptatif
  Future<void> addItemToList(String listId, ListItem item) async {
    await _executeWithLoading(() async {
      try {
        // ADAPTIVE: Sauvegarder via le service adaptatif
        if (_adaptivePersistenceService != null) {
          await _adaptivePersistenceService.saveItem(item);
        } else if (_itemRepository != null) {
          // Fallback legacy
          await _itemRepository!.add(item);
        } else {
          throw StateError('Aucun service de persistance configuré');
        }
        
        // CORRECTION: Vérifier que l'item a bien été persisté
        await _verifyItemPersistence(item.id);
        
        // Seulement après vérification, ajouter à l'état
        _addItemToListState(listId, item);
      } catch (e) {
        // CORRECTION: Gestion d'erreur robuste
        _setErrorState('Échec d\'ajout de l\'élément: $e');
        rethrow;
      }
    });
  }
  
  /// Vérifie qu'un item a bien été persisté LOCALEMENT
  /// Note: En mode cloudFirst, on vérifie le local car le sync cloud est asynchrone
  Future<void> _verifyItemPersistence(String itemId) async {
    try {
      ListItem? persistedItem;
      
      // CORRECTION: Toujours vérifier dans le repository LOCAL
      // car en mode cloudFirst le sync cloud se fait en async
      if (_itemRepository != null) {
        persistedItem = await _itemRepository!.getById(itemId);
      } else {
        throw StateError('Repository local d\'items non configuré');
      }
      
      if (persistedItem == null) {
        throw Exception('Item non trouvé après sauvegarde - échec de persistance locale');
      }
      
      print('✅ Vérification persistance locale réussie pour item "${persistedItem.title}"');
    } catch (e) {
      throw Exception('Erreur lors de la vérification de persistance d\'item: $e');
    }
  }

  /// Ajoute plusieurs éléments à une liste en une seule opération
  Future<void> addMultipleItemsToList(String listId, List<String> itemTitles) async {
    if (itemTitles.isEmpty) return;
    
    await _executeWithLoading(() async {
      final items = <ListItem>[];
      final savedItems = <ListItem>[];
      
      try {
        // Créer tous les éléments
        for (int i = 0; i < itemTitles.length; i++) {
          final title = itemTitles[i].trim();
          if (title.isNotEmpty) {
            final item = ListItem(
              id: const Uuid().v4(),
              title: title,
              createdAt: DateTime.now(),
              listId: listId,
            );
            items.add(item);
          }
        }
        
        // ADAPTIVE: Sauvegarder avec gestion d'erreur transactionnelle
        for (final item in items) {
          try {
            // ADAPTIVE: Sauvegarder via le service adaptatif
            if (_adaptivePersistenceService != null) {
              await _adaptivePersistenceService.saveItem(item);
            } else if (_itemRepository != null) {
              await _itemRepository!.add(item);
            } else {
              throw StateError('Aucun service de persistance configuré');
            }
            
            // Vérifier immédiatement la persistance
            await _verifyItemPersistence(item.id);
            savedItems.add(item);
          } catch (e) {
            // CORRECTION: Rollback en cas d'échec partiel
            await _rollbackFailedItems(savedItems);
            throw Exception('Échec d\'ajout bulk à l\'item "${item.title}": $e');
          }
        }
        
        // Seulement si TOUS les items sont sauvegardés, mettre à jour l'état
        _addMultipleItemsToListState(listId, savedItems);
      } catch (e) {
        _setErrorState('Échec d\'ajout multiple: $e');
        rethrow;
      }
    });
  }
  
  /// Rollback des items en cas d'échec transactionnel
  Future<void> _rollbackFailedItems(List<ListItem> itemsToRollback) async {
    for (final item in itemsToRollback) {
      try {
        // ADAPTIVE: Supprimer via le service adaptatif
        if (_adaptivePersistenceService != null) {
          await _adaptivePersistenceService.deleteItem(item.id);
        } else if (_itemRepository != null) {
          await _itemRepository!.delete(item.id);
        }
      } catch (e) {
        // Log l'erreur mais continue le rollback
        print('⚠️ Erreur lors du rollback de l\'item ${item.id}: $e');
      }
    }
  }

  /// Ajoute un élément à une liste dans l'état
  void _addItemToListState(String listId, ListItem item) {
    final updatedLists = _updateListItems(listId, (items) => [...items, item]);
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Ajoute plusieurs éléments à une liste dans l'état
  void _addMultipleItemsToListState(String listId, List<ListItem> newItems) {
    final updatedLists = _updateListItems(listId, (items) => [...items, ...newItems]);
    _updateListsAndApplyFilters(updatedLists);
  }

  /// Met à jour un élément de liste via le service adaptatif
  Future<void> updateListItem(String listId, ListItem item) async {
    await _executeWithLoading(() async {
      // ADAPTIVE: Mettre à jour via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService.updateItem(item);
      } else if (_itemRepository != null) {
        await _itemRepository!.update(item);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
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

  /// Supprime un élément de liste via le service adaptatif
  Future<void> removeItemFromList(String listId, String itemId) async {
    await _executeWithLoading(() async {
      // ADAPTIVE: Supprimer via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService.deleteItem(itemId);
      } else if (_itemRepository != null) {
        await _itemRepository!.delete(itemId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
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
    if (isSafelyMounted) {
      try {
        state = state.copyWith(error: null);
      } catch (e) {
        print('⚠️ Erreur lors de l\'effacement de l\'erreur: $e');
      }
    }
  }

  /// Nettoie les ressources
  void cleanup() {
    // Le nettoyage peut se faire même après dispose dans certains cas
    try {
      _filterService.clearCache();
    } catch (e) {
      print('⚠️ Erreur lors du nettoyage des ressources: $e');
    }
  }
  
  // LIFECYCLE FIX: Flag pour éviter les doubles dispositions
  bool _isDisposed = false;
  
  /// LIFECYCLE FIX: Override dispose pour gérer la disposition correctement
  @override  
  void dispose() {
    // DISPOSAL FIX: Éviter les doubles dispositions
    if (_isDisposed) {
      print('⚠️ Tentative de double disposition évitée');
      return;
    }
    
    _isDisposed = true;
    
    // Nettoyer les ressources avant la disposition
    try {
      cleanup();
    } catch (e) {
      // Ignorer les erreurs de nettoyage lors de la disposition
      print('⚠️ Erreur lors du nettoyage pendant dispose: $e');
    }
    
    // Appeler la disposition parente en toute sécurité
    try {
      super.dispose();
    } catch (e) {
      print('⚠️ Erreur lors de la disposition parente: $e');
    }
  }
  
  /// LIFECYCLE FIX: Vérification sécurisée du statut mounted
  bool get isSafelyMounted {
    try {
      return mounted && !_isDisposed;
    } catch (e) {
      // En cas d'erreur d'accès à mounted, considérer comme non-mounted
      return false;
    }
  }

  // --- Méthodes privées ---


  /// Exécute une fonction avec gestion du loading et des erreurs
  /// LIFECYCLE FIX: Vérifier isSafelyMounted avant toute mise à jour d'état
  Future<void> _executeWithLoading(Future<void> Function() action) async {
    if (!isSafelyMounted) return; // DISPOSAL FIX: Ne rien faire si disposé
    
    _setLoadingState(true);
    
    try {
      await action();
      if (isSafelyMounted) _setLoadingState(false); // DISPOSAL FIX: Vérifier mounted
    } catch (e) {
      if (isSafelyMounted) _setErrorState(e.toString()); // DISPOSAL FIX: Vérifier mounted
    }
  }

  /// Définit l'état de chargement
  void _setLoadingState(bool isLoading) {
    if (isSafelyMounted) {
      try {
        state = state.copyWith(isLoading: isLoading, error: null);
      } catch (e) {
        print('⚠️ Erreur lors de la mise à jour de l\'état de chargement: $e');
      }
    }
  }

  /// Définit l'état d'erreur
  void _setErrorState(String errorMessage) {
    if (isSafelyMounted) {
      try {
        state = state.copyWith(
          isLoading: false,
          error: 'Erreur: $errorMessage',
        );
      } catch (e) {
        print('⚠️ Erreur lors de la mise à jour de l\'état d\'erreur: $e');
      }
    }
  }

  /// Met à jour les listes et applique les filtres
  void _updateListsAndApplyFilters(List<CustomList> lists) {
    print('🔍 DEBUG _updateListsAndApplyFilters: Entrée avec ${lists.length} listes');
    
    if (mounted) {
      final filteredLists = _applyFiltersToLists(lists);
      
      print('🔍 DEBUG _updateListsAndApplyFilters: Mise à jour state avec ${lists.length} listes et ${filteredLists.length} filtrées');
      
      state = state.copyWith(
        lists: lists,
        filteredLists: filteredLists,
      );
      
      // CORRECTION: Si le filtrage retourne une liste vide alors que nous avons des listes, 
      // utiliser toutes les listes comme fallback
      if (lists.isNotEmpty && filteredLists.isEmpty) {
        print('🔧 CORRECTION: Le filtrage a retourné 0 listes alors que nous en avons ${lists.length}. Utilisation de toutes les listes.');
        state = state.copyWith(filteredLists: lists);
      }
      
      print('🔍 DEBUG _updateListsAndApplyFilters: État final - ${state.lists.length} listes, ${state.filteredLists.length} filtrées');
    }
  }

  /// Applique les filtres aux listes fournies
  List<CustomList> _applyFiltersToLists(List<CustomList> lists) {
    print('🔍 DEBUG _applyFiltersToLists: Entrée avec ${lists.length} listes');
    print('🔍 DEBUG _applyFiltersToLists: searchQuery="${state.searchQuery}", selectedType=${state.selectedType}, showCompleted=${state.showCompleted}');
    
    final result = _filterService.applyFilters(
      lists,
      searchQuery: state.searchQuery,
      selectedType: state.selectedType,
      showCompleted: state.showCompleted,
      showInProgress: state.showInProgress,
      selectedDateFilter: state.selectedDateFilter,
      sortOption: state.sortOption,
    );
    
    print('🔍 DEBUG _applyFiltersToLists: Sortie avec ${result.length} listes filtrées');
    for (var list in result) {
      print('  - Liste filtrée: "${list.name}"');
    }
    
    return result;
  }

  /// Applique les filtres aux listes actuelles
  void _applyFilters() {
    if (mounted) {
      final filteredLists = _applyFiltersToLists(state.lists);
      state = state.copyWith(filteredLists: filteredLists);
    }
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

/// ADAPTIVE FIX: Provider pour le controller des listes avec service adaptatif
/// 
/// Utilise l'AdaptivePersistenceService pour une gestion intelligente de la persistance
/// selon l'état d'authentification, avec migration automatique des données.
final listsControllerProvider = StateNotifierProvider<ListsController, ListsState>((ref) {
  // Utiliser le service adaptatif INITIALISÉ (FIX: remplace adaptivePersistenceServiceProvider)
  final adaptivePersistenceService = ref.watch(adaptivePersistenceInitProvider);
  final filterService = ref.read(listsFilterServiceProvider);
  
  // S'assurer que le listener est actif pour surveiller les changements d'auth
  ref.watch(adaptivePersistenceListenerProvider);
  
  return adaptivePersistenceService.when(
    data: (service) => ListsController.adaptive(
      service, 
      ref.read(hiveCustomListRepositoryProvider),
      ref.read(hiveListItemRepositoryProvider),
      filterService,
    ),
    loading: () => ListsController.adaptive(
      ref.read(adaptivePersistenceServiceProvider), // Fallback temporaire
      ref.read(hiveCustomListRepositoryProvider),
      ref.read(hiveListItemRepositoryProvider),
      filterService,
    ),
    error: (error, stack) {
      print('❌ Erreur initialisation AdaptivePersistenceService: $error');
      return ListsController.adaptive(
        ref.read(adaptivePersistenceServiceProvider), // Fallback temporaire
        ref.read(hiveCustomListRepositoryProvider),
        ref.read(hiveListItemRepositoryProvider),
        filterService,
      );
    },
  );
});

/// LEGACY: Provider avec repositories directs (pour compatibilité tests)
@Deprecated('Use listsControllerProvider instead')
final listsControllerLegacyProvider = StateNotifierProvider<ListsController, ListsState>((ref) {
  final listRepository = ref.watch(customListRepositoryProvider);
  final itemRepository = ref.watch(listItemRepositoryProvider);
  final filterService = ref.read(listsFilterServiceProvider);
  return ListsController(listRepository, itemRepository, filterService);
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

/// Provider pour une liste spécifique par ID
/// Ce provider écoute les changements d'état et retourne la liste mise à jour
final listByIdProvider = Provider.family<CustomList?, String>((ref, listId) {
  final listsState = ref.watch(listsControllerProvider);
  final foundList = listsState.lists.where((list) => list.id == listId).firstOrNull;
  
  // DEBUG: Afficher les détails de recherche
  print('🔍 DEBUG listByIdProvider: Recherche liste avec ID: $listId');
  print('🔍 DEBUG listByIdProvider: ${listsState.lists.length} listes disponibles:');
  for (var list in listsState.lists) {
    print('  - Liste "${list.name}" ID: ${list.id} (match: ${list.id == listId})');
  }
  print('🔍 DEBUG listByIdProvider: Résultat: ${foundList?.name ?? 'NON TROUVÉE'}');
  
  return foundList;
}); 
