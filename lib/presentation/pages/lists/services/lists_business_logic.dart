import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';

/// Service de logique métier pour les listes
///
/// Responsabilité unique : Gérer toutes les opérations CRUD sur les listes et items
/// en respectant les principes SOLID :
/// - SRP : Se concentre uniquement sur la logique métier des listes
/// - OCP : Extensible via l'injection de dépendances
/// - DIP : Dépend d'abstractions (repositories et services)
class ListsBusinessLogic {
  final IUnifiedPersistenceService? _unifiedPersistenceService;
  final CustomListRepository? _listRepository;
  final ListItemRepository? _itemRepository;
  final ILogger _logger;

  const ListsBusinessLogic({
    IUnifiedPersistenceService? unifiedPersistenceService,
    CustomListRepository? listRepository,
    ListItemRepository? itemRepository,
    required ILogger logger,
  })  : _unifiedPersistenceService = unifiedPersistenceService,
        _listRepository = listRepository,
        _itemRepository = itemRepository,
        _logger = logger;

  /// Charge toutes les listes avec leurs items
  Future<List<CustomList>> loadAllLists() async {
    _logger.debug('Début chargement des listes via service adaptatif', context: 'ListsBusinessLogic');

    List<CustomList> lists;

    // UNIFIED: Utiliser le service unifié ou fallback vers repository legacy
    if (_unifiedPersistenceService != null) {
      lists = await _unifiedPersistenceService!.getAllLists();
      _logger.info('${lists.length} listes chargées via UnifiedPersistenceService (${_unifiedPersistenceService!.currentMode})', context: 'ListsBusinessLogic');
    } else if (_listRepository != null) {
      // Fallback legacy
      lists = await _listRepository!.getAllLists();
      _logger.info('${lists.length} listes chargées depuis repository legacy', context: 'ListsBusinessLogic');
    } else {
      throw StateError('Aucun service de persistance configuré');
    }

    // Charger les items pour chaque liste
    final listsWithItems = <CustomList>[];
    for (final list in lists) {
      final items = await _loadItemsForList(list.id);
      listsWithItems.add(list.copyWith(items: items));
    }

    return listsWithItems;
  }

  /// Charge les items pour une liste spécifique
  Future<List<ListItem>> _loadItemsForList(String listId) async {
    if (_unifiedPersistenceService != null) {
      return await _unifiedPersistenceService!.getItemsByListId(listId);
    } else if (_itemRepository != null) {
      return await _itemRepository!.getByListId(listId);
    } else {
      return [];
    }
  }

  /// Crée une nouvelle liste
  Future<void> createList(CustomList list) async {
    // ADAPTIVE: Sauvegarder via le service adaptatif
    if (_unifiedPersistenceService != null) {
      await _unifiedPersistenceService!.saveList(list);
    } else if (_listRepository != null) {
      // Fallback legacy
      await _listRepository!.saveList(list);
    } else {
      throw StateError('Aucun service de persistance configuré');
    }

    // CORRECTION: Vérifier que la sauvegarde a réussi
    await _verifyListPersistence(list.id);
  }

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list) async {
    // ADAPTIVE: Mettre à jour via le service adaptatif
    if (_unifiedPersistenceService != null) {
      await _unifiedPersistenceService!.saveList(list); // saveList fait update automatiquement
    } else if (_listRepository != null) {
      await _listRepository!.updateList(list);
    } else {
      throw StateError('Aucun service de persistance configuré');
    }
  }

  /// Supprime une liste
  Future<void> deleteList(String listId) async {
    // ADAPTIVE: Supprimer via le service adaptatif
    if (_unifiedPersistenceService != null) {
      await _unifiedPersistenceService!.deleteList(listId);
    } else if (_listRepository != null) {
      await _listRepository!.deleteList(listId);
    } else {
      throw StateError('Aucun service de persistance configuré');
    }
  }

  /// Ajoute un élément à une liste
  Future<void> addItemToList(ListItem item) async {
    // ADAPTIVE: Sauvegarder via le service adaptatif
    if (_unifiedPersistenceService != null) {
      await _unifiedPersistenceService!.saveItem(item);
    } else if (_itemRepository != null) {
      // Fallback legacy
      await _itemRepository!.add(item);
    } else {
      throw StateError('Aucun service de persistance configuré');
    }

    // CORRECTION: Vérifier que l'item a bien été persisté
    await _verifyItemPersistence(item.id);
  }

  /// Ajoute plusieurs éléments à une liste en une seule opération
  Future<List<ListItem>> addMultipleItemsToList(String listId, List<String> itemTitles) async {
    if (itemTitles.isEmpty) return [];

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
          await addItemToList(item);
          savedItems.add(item);
        } catch (e) {
          // CORRECTION: Rollback en cas d'échec partiel
          await _rollbackFailedItems(savedItems);
          throw Exception('Échec d\'ajout bulk à l\'item "${item.title}": $e');
        }
      }

      return savedItems;
    } catch (e) {
      _logger.error('Échec d\'ajout multiple', context: 'ListsBusinessLogic', error: e);
      rethrow;
    }
  }

  /// Met à jour un élément de liste
  Future<void> updateListItem(ListItem item) async {
    // ADAPTIVE: Mettre à jour via le service adaptatif
    if (_unifiedPersistenceService != null) {
      await _unifiedPersistenceService!.updateItem(item);
    } else if (_itemRepository != null) {
      await _itemRepository!.update(item);
    } else {
      throw StateError('Aucun service de persistance configuré');
    }
  }

  /// Supprime un élément de liste
  Future<void> removeItemFromList(String itemId) async {
    // ADAPTIVE: Supprimer via le service adaptatif
    if (_unifiedPersistenceService != null) {
      await _unifiedPersistenceService!.deleteItem(itemId);
    } else if (_itemRepository != null) {
      await _itemRepository!.delete(itemId);
    } else {
      throw StateError('Aucun service de persistance configuré');
    }
  }

  /// Efface toutes les données (listes et éléments)
  Future<void> clearAllData() async {
    _logger.info('Début de l\'effacement de toutes les données', context: 'ListsBusinessLogic');

    final (allLists, allItems) = await _loadAllDataForClearing();
    await _deleteAllDataFromPersistence(allLists, allItems);

    _logger.info('Toutes les données ont été effacées avec succès', context: 'ListsBusinessLogic');
  }

  /// Charge toutes les données (listes et éléments) pour l'effacement
  Future<(List<CustomList>, List<ListItem>)> _loadAllDataForClearing() async {
    if (_unifiedPersistenceService != null) {
      return await _loadDataViaAdaptiveService();
    } else if (_listRepository != null && _itemRepository != null) {
      return await _loadDataViaLegacyRepositories();
    } else {
      throw StateError('Aucun service de persistance configuré');
    }
  }

  /// Charge les données via le service adaptatif
  Future<(List<CustomList>, List<ListItem>)> _loadDataViaAdaptiveService() async {
    final allLists = await _unifiedPersistenceService!.getAllLists();
    final allItems = <ListItem>[];

    for (final list in allLists) {
      final items = await _unifiedPersistenceService!.getItemsByListId(list.id);
      allItems.addAll(items);
    }

    return (allLists, allItems);
  }

  /// Charge les données via les repositories legacy
  Future<(List<CustomList>, List<ListItem>)> _loadDataViaLegacyRepositories() async {
    final allLists = await _listRepository!.getAllLists();
    final allItems = await _itemRepository!.getAll();
    return (allLists, allItems);
  }

  /// Efface toutes les données de la persistance
  Future<void> _deleteAllDataFromPersistence(
    List<CustomList> allLists,
    List<ListItem> allItems,
  ) async {
    if (_unifiedPersistenceService != null) {
      await _deleteDataViaAdaptiveService(allLists, allItems);
    } else if (_listRepository != null && _itemRepository != null) {
      await _deleteDataViaLegacyRepositories(allLists, allItems);
    }
  }

  /// Efface les données via le service adaptatif
  Future<void> _deleteDataViaAdaptiveService(
    List<CustomList> allLists,
    List<ListItem> allItems,
  ) async {
    for (final list in allLists) {
      await _unifiedPersistenceService!.deleteList(list.id);
      _logger.info('Liste "${list.name}" effacée', context: 'ListsBusinessLogic');
    }

    for (final item in allItems) {
      await _unifiedPersistenceService!.deleteItem(item.id);
    }
  }

  /// Efface les données via les repositories legacy
  Future<void> _deleteDataViaLegacyRepositories(
    List<CustomList> allLists,
    List<ListItem> allItems,
  ) async {
    for (final list in allLists) {
      await _listRepository!.deleteList(list.id);
      _logger.info('Liste "${list.name}" effacée', context: 'ListsBusinessLogic');
    }

    for (final item in allItems) {
      await _itemRepository!.delete(item.id);
    }
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

      _logger.info('Vérification persistance locale réussie pour "${persistedList.name}"', context: 'ListsBusinessLogic');
    } catch (e) {
      throw Exception('Erreur lors de la vérification de persistance: $e');
    }
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

      _logger.info('Vérification persistance locale réussie pour item "${persistedItem.title}"', context: 'ListsBusinessLogic');
    } catch (e) {
      throw Exception('Erreur lors de la vérification de persistance d\'item: $e');
    }
  }

  /// Rollback des items en cas d'échec transactionnel
  Future<void> _rollbackFailedItems(List<ListItem> itemsToRollback) async {
    for (final item in itemsToRollback) {
      try {
        // ADAPTIVE: Supprimer via le service adaptatif
        if (_unifiedPersistenceService != null) {
          await _unifiedPersistenceService!.deleteItem(item.id);
        } else if (_itemRepository != null) {
          await _itemRepository!.delete(item.id);
        }
      } catch (e) {
        // Log l'erreur mais continue le rollback
        _logger.warning('Erreur lors du rollback de l\'item ${item.id}: $e', context: 'ListsBusinessLogic');
      }
    }
  }
}