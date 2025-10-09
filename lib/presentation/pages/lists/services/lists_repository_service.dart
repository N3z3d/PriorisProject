import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../interfaces/lists_controller_interfaces.dart';

/// Service responsable de toutes les opérations de persistance des listes
///
/// Respecte le principe Single Responsibility en centralisant
/// toutes les interactions avec les repositories.
///
/// Applique le principe Dependency Inversion en utilisant des abstractions
/// plutôt que des implémentations concrètes.
class ListsRepositoryService implements IListsRepositoryService {
  // ADAPTIVE: Service de persistance adaptatif principal
  final AdaptivePersistenceService? _adaptivePersistenceService;

  // LEGACY: Repositories pour compatibilité backwards
  final CustomListRepository? _listRepository;
  final ListItemRepository? _itemRepository;

  /// Constructeur principal avec service adaptatif (recommandé)
  ListsRepositoryService.adaptive({
    required AdaptivePersistenceService adaptivePersistenceService,
    CustomListRepository? localListRepository,
    ListItemRepository? localItemRepository,
  }) : _adaptivePersistenceService = adaptivePersistenceService,
        _listRepository = localListRepository,
        _itemRepository = localItemRepository;

  /// Constructeur legacy avec repositories directs (pour compatibilité)
  @Deprecated('Use ListsRepositoryService.adaptive() instead')
  ListsRepositoryService.legacy({
    required CustomListRepository listRepository,
    required ListItemRepository itemRepository,
  }) : _adaptivePersistenceService = null,
        _listRepository = listRepository,
        _itemRepository = itemRepository;

  @override
  Future<List<CustomList>> getAllLists() async {
    try {
      LoggerService.instance.debug(
        'Chargement de toutes les listes via RepositoryService',
        context: 'ListsRepositoryService'
      );

      List<CustomList> lists;

      // ADAPTIVE: Utiliser le service adaptatif ou fallback vers repositories
      final adaptiveService = _adaptivePersistenceService;
      final listRepo = _listRepository;

      if (adaptiveService != null) {
        lists = await adaptiveService.getAllLists();
        LoggerService.instance.info(
          '${lists.length} listes chargées via AdaptivePersistenceService (${adaptiveService.currentMode})',
          context: 'ListsRepositoryService'
        );
      } else if (listRepo != null) {
        lists = await listRepo.getAllLists();
        LoggerService.instance.info(
          '${lists.length} listes chargées via repository legacy',
          context: 'ListsRepositoryService'
        );
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      return lists;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors du chargement des listes',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    try {
      List<ListItem> items;

      // ADAPTIVE: Utiliser le service adaptatif ou fallback vers repositories
      final adaptiveService = _adaptivePersistenceService;
      final itemRepo = _itemRepository;

      if (adaptiveService != null) {
        items = await adaptiveService.getItemsByListId(listId);
      } else if (itemRepo != null) {
        items = await itemRepo.getByListId(listId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      return items;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors du chargement des éléments de la liste $listId',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    try {
      // ADAPTIVE: Sauvegarder via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveList(list);
      } else if (_listRepository != null) {
        await _listRepository!.saveList(list);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      // Vérifier la persistance
      await verifyListPersistence(list.id);

      LoggerService.instance.info(
        'Liste "${list.name}" sauvegardée avec succès',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la sauvegarde de la liste "${list.name}"',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> updateList(CustomList list) async {
    try {
      // ADAPTIVE: Mettre à jour via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveList(list); // saveList fait update automatiquement
      } else if (_listRepository != null) {
        await _listRepository!.updateList(list);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.info(
        'Liste "${list.name}" mise à jour avec succès',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la mise à jour de la liste "${list.name}"',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteList(String listId) async {
    try {
      // ADAPTIVE: Supprimer via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteList(listId);
      } else if (_listRepository != null) {
        await _listRepository!.deleteList(listId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.info(
        'Liste $listId supprimée avec succès',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la suppression de la liste $listId',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> saveItem(ListItem item) async {
    try {
      // ADAPTIVE: Sauvegarder via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveItem(item);
      } else if (_itemRepository != null) {
        await _itemRepository!.add(item);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      // Vérifier la persistance
      await verifyItemPersistence(item.id);

      LoggerService.instance.debug(
        'Élément "${item.title}" sauvegardé avec succès',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la sauvegarde de l\'élément "${item.title}"',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> updateItem(ListItem item) async {
    try {
      // ADAPTIVE: Mettre à jour via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.updateItem(item);
      } else if (_itemRepository != null) {
        await _itemRepository!.update(item);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.debug(
        'Élément "${item.title}" mis à jour avec succès',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la mise à jour de l\'élément "${item.title}"',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      // ADAPTIVE: Supprimer via le service adaptatif
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteItem(itemId);
      } else if (_itemRepository != null) {
        await _itemRepository!.delete(itemId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.debug(
        'Élément $itemId supprimé avec succès',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la suppression de l\'élément $itemId',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {
    if (items.isEmpty) return;

    final savedItems = <ListItem>[];

    try {
      // Sauvegarder avec gestion d'erreur transactionnelle
      for (final item in items) {
        try {
          await saveItem(item);
          savedItems.add(item);
        } catch (e) {
          // Rollback en cas d'échec partiel
          await _rollbackFailedItems(savedItems);
          throw Exception('Échec d\'ajout bulk à l\'item "${item.title}": $e');
        }
      }

      LoggerService.instance.info(
        '${items.length} éléments sauvegardés en bloc avec succès',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la sauvegarde multiple d\'éléments',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      _logClearStart();
      final summary = await (_adaptivePersistenceService != null
          ? _clearWithAdaptive()
          : _clearWithLegacy());
      _logClearSuccess(summary);
    } catch (e, stack) {
      LoggerService.instance.error(
        'Erreur lors de l'effacement des donnees',
        context: 'ListsRepositoryService',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  void _logClearStart() {
    LoggerService.instance.info(
      'Debut de l'effacement de toutes les donnees...',
      context: 'ListsRepositoryService',
    );
  }

  Future<_ClearSummary> _clearWithAdaptive() async {
    final lists = await _adaptivePersistenceService!.getAllLists();
    final items = <ListItem>[];

    for (final list in lists) {
      final listItems = await _adaptivePersistenceService!.getItemsByListId(list.id);
      items.addAll(listItems);
    }

    for (final list in lists) {
      await _adaptivePersistenceService!.deleteList(list.id);
    }
    for (final item in items) {
      await _adaptivePersistenceService!.deleteItem(item.id);
    }

    return (listCount: lists.length, itemCount: items.length);
  }

  Future<_ClearSummary> _clearWithLegacy() async {
    if (_listRepository == null || _itemRepository == null) {
      throw StateError('Aucun service de persistance configure');
    }

    final lists = await _listRepository!.getAllLists();
    for (final list in lists) {
      await _listRepository!.deleteList(list.id);
    }

    final items = await _itemRepository!.getAll();
    for (final item in items) {
      await _itemRepository!.delete(item.id);
    }

    return (listCount: lists.length, itemCount: items.length);
  }

void _logClearSuccess(_ClearSummary summary) {
    LoggerService.instance.info(
      'Toutes les donnees effacees avec succes: ${summary.listCount} listes et ${summary.itemCount} elements',
      context: 'ListsRepositoryService',
    );
}

typedef _ClearSummary = ({int listCount, int itemCount});

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async {
    try {
      LoggerService.instance.info(
        'Force rechargement depuis la persistance',
        context: 'ListsRepositoryService'
      );

      List<CustomList> lists;
      if (_adaptivePersistenceService != null) {
        lists = await _adaptivePersistenceService!.getAllLists();
      } else if (_listRepository != null) {
        lists = await _listRepository!.getAllLists();
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      // Charger les items pour chaque liste
      final listsWithItems = <CustomList>[];
      for (final list in lists) {
        final items = await getItemsByListId(list.id);
        listsWithItems.add(list.copyWith(items: items));
      }

      LoggerService.instance.info(
        'Rechargement forcé terminé: ${listsWithItems.length} listes chargées',
        context: 'ListsRepositoryService'
      );

      return listsWithItems;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors du rechargement forcé',
        context: 'ListsRepositoryService',
        error: e
      );
      rethrow;
    }
  }

  @override
  Future<void> verifyListPersistence(String listId) async {
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

      LoggerService.instance.debug(
        'Vérification persistance locale réussie pour "${persistedList.name}"',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la vérification de persistance de la liste $listId',
        context: 'ListsRepositoryService',
        error: e
      );
      throw Exception('Erreur lors de la vérification de persistance: $e');
    }
  }

  @override
  Future<void> verifyItemPersistence(String itemId) async {
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

      LoggerService.instance.debug(
        'Vérification persistance locale réussie pour item "${persistedItem.title}"',
        context: 'ListsRepositoryService'
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la vérification de persistance de l\'item $itemId',
        context: 'ListsRepositoryService',
        error: e
      );
      throw Exception('Erreur lors de la vérification de persistance d\'item: $e');
    }
  }

  /// Rollback des items en cas d'échec transactionnel
  Future<void> _rollbackFailedItems(List<ListItem> itemsToRollback) async {
    for (final item in itemsToRollback) {
      try {
        await deleteItem(item.id);
      } catch (e) {
        // Log l'erreur mais continue le rollback
        LoggerService.instance.warning(
          'Erreur lors du rollback de l\'item ${item.id}: $e',
          context: 'ListsRepositoryService'
        );
      }
    }
  }
}
