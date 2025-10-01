import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Service responsable uniquement des opérations de persistance des listes
///
/// Respecte le Single Responsibility Principle en ne gérant que
/// la persistance sans logique d'état ou de filtrage
class ListsPersistenceManager {
  final AdaptivePersistenceService? _adaptivePersistenceService;
  final CustomListRepository? _listRepository;
  final ListItemRepository? _itemRepository;

  ListsPersistenceManager.adaptive(this._adaptivePersistenceService)
      : _listRepository = null,
        _itemRepository = null;

  ListsPersistenceManager.legacy(this._listRepository, this._itemRepository)
      : _adaptivePersistenceService = null;

  /// Charge toutes les listes depuis la persistance
  Future<List<CustomList>> loadAllLists() async {
    try {
      if (_adaptivePersistenceService != null) {
        return await _adaptivePersistenceService!.getAllLists();
      } else if (_listRepository != null) {
        return await _listRepository!.getAll();
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
    } catch (e) {
      LoggerService.instance.error('Erreur lors du chargement des listes',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Sauvegarde une liste
  Future<void> saveList(CustomList list) async {
    try {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveList(list);
      } else if (_listRepository != null) {
        await _listRepository!.saveList(list);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      // Vérifier la persistance
      await _verifyListPersistence(list.id);
    } catch (e) {
      LoggerService.instance.error('Erreur lors de la sauvegarde de la liste',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list) async {
    try {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveList(list);
      } else if (_listRepository != null) {
        await _listRepository!.saveList(list);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
    } catch (e) {
      LoggerService.instance.error('Erreur lors de la mise à jour de la liste',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Supprime une liste
  Future<void> deleteList(String listId) async {
    try {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteList(listId);
      } else if (_listRepository != null) {
        await _listRepository!.deleteList(listId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
    } catch (e) {
      LoggerService.instance.error('Erreur lors de la suppression de la liste',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Ajoute un élément à une liste
  Future<void> addItemToList(String listId, ListItem item) async {
    try {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveItem(item);
      } else if (_itemRepository != null) {
        await _itemRepository!.add(item);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      // Vérifier la persistance
      await _verifyItemPersistence(item.id);
    } catch (e) {
      LoggerService.instance.error('Erreur lors de l\'ajout de l\'élément',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Ajoute plusieurs éléments à une liste
  Future<List<ListItem>> addMultipleItemsToList(String listId, List<String> itemTitles) async {
    final newItems = <ListItem>[];
    final failedItems = <ListItem>[];

    for (final title in itemTitles) {
      try {
        final item = ListItem.create(
          title: title,
          listId: listId,
        );

        await addItemToList(listId, item);
        newItems.add(item);
      } catch (e) {
        LoggerService.instance.error('Échec ajout élément "$title"',
            context: 'ListsPersistenceManager', error: e);
        failedItems.add(ListItem.create(title: title, listId: listId));
      }
    }

    if (failedItems.isNotEmpty) {
      // Rollback des éléments qui ont réussi
      await _rollbackFailedItems(newItems);
      throw Exception('Échec de l\'ajout de ${failedItems.length} éléments');
    }

    return newItems;
  }

  /// Met à jour un élément de liste
  Future<void> updateListItem(String listId, ListItem item) async {
    try {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveItem(item);
      } else if (_itemRepository != null) {
        await _itemRepository!.update(item);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
    } catch (e) {
      LoggerService.instance.error('Erreur lors de la mise à jour de l\'élément',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Supprime un élément d'une liste
  Future<void> removeItemFromList(String listId, String itemId) async {
    try {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteItem(itemId);
      } else if (_itemRepository != null) {
        await _itemRepository!.delete(itemId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }
    } catch (e) {
      LoggerService.instance.error('Erreur lors de la suppression de l\'élément',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Efface toutes les données de persistance
  Future<void> clearAllData() async {
    try {
      final (allLists, allItems) = await _loadAllDataForClearing();
      await _deleteAllDataFromPersistence(allLists, allItems);

      LoggerService.instance.info('Toutes les données ont été effacées avec succès',
          context: 'ListsPersistenceManager');
    } catch (e) {
      LoggerService.instance.error('Erreur lors de l\'effacement des données',
          context: 'ListsPersistenceManager', error: e);
      rethrow;
    }
  }

  /// Force le rechargement depuis la persistance
  Future<List<CustomList>> forceReloadFromPersistence() async {
    return await loadAllLists();
  }

  /// Vérifie qu'une liste a bien été persistée
  Future<void> _verifyListPersistence(String listId) async {
    try {
      CustomList? persistedList;

      if (_listRepository != null) {
        persistedList = await _listRepository!.getListById(listId);
      } else {
        throw StateError('Repository local non configuré');
      }

      if (persistedList == null) {
        throw Exception('Liste non trouvée après sauvegarde - échec de persistance locale');
      }

      LoggerService.instance.info('Vérification persistance locale réussie pour "${persistedList.name}"',
          context: 'ListsPersistenceManager');
    } catch (e) {
      throw Exception('Erreur lors de la vérification de persistance: $e');
    }
  }

  /// Vérifie qu'un élément a bien été persisté
  Future<void> _verifyItemPersistence(String itemId) async {
    try {
      ListItem? persistedItem;

      if (_itemRepository != null) {
        persistedItem = await _itemRepository!.getById(itemId);
      } else {
        throw StateError('Repository local non configuré');
      }

      if (persistedItem == null) {
        throw Exception('Élément non trouvé après sauvegarde - échec de persistance locale');
      }

      LoggerService.instance.info('Vérification persistance locale réussie pour "${persistedItem.title}"',
          context: 'ListsPersistenceManager');
    } catch (e) {
      throw Exception('Erreur lors de la vérification de persistance: $e');
    }
  }

  /// Rollback des éléments qui ont échoué
  Future<void> _rollbackFailedItems(List<ListItem> itemsToRollback) async {
    for (final item in itemsToRollback) {
      try {
        await removeItemFromList(item.listId, item.id);
      } catch (e) {
        LoggerService.instance.error('Échec rollback pour "${item.title}"',
            context: 'ListsPersistenceManager', error: e);
      }
    }
  }

  /// Charge toutes les données pour l'effacement
  Future<(List<CustomList>, List<ListItem>)> _loadAllDataForClearing() async {
    if (_adaptivePersistenceService != null) {
      return await _loadDataViaAdaptiveService();
    } else if (_listRepository != null && _itemRepository != null) {
      return await _loadDataViaLegacyRepositories();
    } else {
      throw StateError('Aucun service de persistance configuré');
    }
  }

  /// Charge les données via le service adaptatif
  Future<(List<CustomList>, List<ListItem>)> _loadDataViaAdaptiveService() async {
    final allLists = await _adaptivePersistenceService!.getAllLists();
    final allItems = <ListItem>[];

    for (final list in allLists) {
      final items = await _adaptivePersistenceService!.getItemsByListId(list.id);
      allItems.addAll(items);
    }

    return (allLists, allItems);
  }

  /// Charge les données via les repositories legacy
  Future<(List<CustomList>, List<ListItem>)> _loadDataViaLegacyRepositories() async {
    final allLists = await _listRepository!.getAll();
    final allItems = await _itemRepository!.getAll();
    return (allLists, allItems);
  }

  /// Supprime toutes les données de la persistance
  Future<void> _deleteAllDataFromPersistence(List<CustomList> allLists, List<ListItem> allItems) async {
    // Supprimer tous les éléments
    for (final item in allItems) {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteItem(item.id);
      } else if (_itemRepository != null) {
        await _itemRepository!.delete(item.id);
      }
    }

    // Supprimer toutes les listes
    for (final list in allLists) {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteList(list.id);
      } else if (_listRepository != null) {
        await _listRepository!.deleteList(list.id);
      }
    }
  }
}