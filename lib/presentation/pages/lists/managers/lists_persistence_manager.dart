import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../interfaces/lists_managers_interfaces.dart';
import 'performance_monitoring_mixin.dart';

/// **Command Pattern** pour les opérations de persistance
///
/// **Single Responsibility Principle (SRP)** : Gère uniquement la persistance des données
/// **Open/Closed Principle (OCP)** : Extensible pour de nouveaux backends sans modification
/// **Dependency Inversion Principle (DIP)** : Dépend d'abstractions, pas d'implémentations
class ListsPersistenceManager
    with PerformanceMonitoringMixin
    implements IListsPersistenceManager {
  // === Dependencies (Strategy Pattern) ===
  final AdaptivePersistenceService? _adaptivePersistenceService;
  final CustomListRepository? _customListRepository;
  final ListItemRepository? _itemRepository;

  @override
  String get monitoringContext => 'ListsPersistenceManager';

  /// **Dependency Injection** - Constructor principal
  ListsPersistenceManager({
    AdaptivePersistenceService? adaptivePersistenceService,
    CustomListRepository? customListRepository,
    ListItemRepository? itemRepository,
  })  : _adaptivePersistenceService = adaptivePersistenceService,
        _customListRepository = customListRepository,
        _itemRepository = itemRepository;

  /// **Factory constructor** - Pour mode adaptatif (recommandé)
  factory ListsPersistenceManager.adaptive(
    AdaptivePersistenceService adaptivePersistenceService,
    CustomListRepository customListRepository,
    ListItemRepository itemRepository,
  ) {
    return ListsPersistenceManager(
      adaptivePersistenceService: adaptivePersistenceService,
      customListRepository: customListRepository,
      itemRepository: itemRepository,
    );
  }

  /// **Factory constructor** - Pour mode legacy (compatibilité)
  factory ListsPersistenceManager.legacy(
    CustomListRepository customListRepository,
    ListItemRepository itemRepository,
  ) {
    return ListsPersistenceManager(
      customListRepository: customListRepository,
      itemRepository: itemRepository,
    );
  }

  // === Lists Operations ===

  @override
  Future<List<CustomList>> loadAllLists() async {
    return await executeMonitoredOperation('loadAllLists', () async {
      List<CustomList> lists;

      if (_adaptivePersistenceService != null) {
        lists = await _adaptivePersistenceService!.getAllLists();
        LoggerService.instance.info(
          '${lists.length} listes chargées via AdaptivePersistenceService (${_adaptivePersistenceService!.currentMode})',
          context: 'ListsPersistenceManager',
        );
      } else if (_customListRepository != null) {
        lists = await _customListRepository!.getAllLists();
        LoggerService.instance.info(
          '${lists.length} listes chargées depuis repository legacy',
          context: 'ListsPersistenceManager',
        );
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      // Charger les éléments de chaque liste
      final listsWithItems = <CustomList>[];
      for (final list in lists) {
        final items = await loadListItems(list.id);
        listsWithItems.add(list.copyWith(items: items));
      }

      return listsWithItems;
    });
  }

  @override
  Future<void> saveList(CustomList list) async {
    await executeMonitoredOperation('saveList', () async {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveList(list);
      } else if (_customListRepository != null) {
        await _customListRepository!.saveList(list);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.info(
        'Liste "${list.name}" sauvegardée avec succès',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> updateList(CustomList list) async {
    await executeMonitoredOperation('updateList', () async {
      if (_adaptivePersistenceService != null) {
        // saveList fait update automatiquement dans le service adaptatif
        await _adaptivePersistenceService!.saveList(list);
      } else if (_customListRepository != null) {
        await _customListRepository!.updateList(list);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.info(
        'Liste "${list.name}" mise à jour avec succès',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> deleteList(String listId) async {
    await executeMonitoredOperation('deleteList', () async {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteList(listId);
      } else if (_customListRepository != null) {
        await _customListRepository!.deleteList(listId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.info(
        'Liste $listId supprimée avec succès',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<List<ListItem>> loadListItems(String listId) async {
    return await executeMonitoredOperation('loadListItems', () async {
      List<ListItem> items;

      if (_adaptivePersistenceService != null) {
        items = await _adaptivePersistenceService!.getItemsByListId(listId);
      } else if (_itemRepository != null) {
        items = await _itemRepository!.getByListId(listId);
      } else {
        items = [];
      }

      LoggerService.instance.debug(
        '${items.length} éléments chargés pour la liste $listId',
        context: 'ListsPersistenceManager',
      );

      return items;
    });
  }

  // === List Items Operations ===

  @override
  Future<void> saveListItem(ListItem item) async {
    await executeMonitoredOperation('saveListItem', () async {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.saveItem(item);
      } else if (_itemRepository != null) {
        await _itemRepository!.add(item);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.debug(
        'Élément "${item.title}" sauvegardé avec succès',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> updateListItem(ListItem item) async {
    await executeMonitoredOperation('updateListItem', () async {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.updateItem(item);
      } else if (_itemRepository != null) {
        await _itemRepository!.update(item);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.debug(
        'Élément "${item.title}" mis à jour avec succès',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> deleteListItem(String itemId) async {
    await executeMonitoredOperation('deleteListItem', () async {
      if (_adaptivePersistenceService != null) {
        await _adaptivePersistenceService!.deleteItem(itemId);
      } else if (_itemRepository != null) {
        await _itemRepository!.delete(itemId);
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      LoggerService.instance.debug(
        'Élément $itemId supprimé avec succès',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {
    await executeMonitoredOperation('saveMultipleItems', () async {
      final savedItems = <ListItem>[];

      try {
        for (final item in items) {
          await saveListItem(item);
          await verifyItemPersistence(item.id);
          savedItems.add(item);
        }

        LoggerService.instance.info(
          '${savedItems.length} éléments sauvegardés en lot avec succès',
          context: 'ListsPersistenceManager',
        );
      } catch (e) {
        // Rollback en cas d'échec partiel
        LoggerService.instance.warning(
          'Échec partiel lors de la sauvegarde multiple - rollback de ${savedItems.length} éléments',
          context: 'ListsPersistenceManager',
        );
        await rollbackItems(savedItems);
        rethrow;
      }
    });
  }

  // === Maintenance Operations ===

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async {
    return await executeMonitoredOperation('forceReloadFromPersistence', () async {
      LoggerService.instance.info(
        'Début du rechargement forcé depuis la persistance',
        context: 'ListsPersistenceManager',
      );

      List<CustomList> lists;

      if (_adaptivePersistenceService != null) {
        lists = await _adaptivePersistenceService!.getAllLists();
      } else if (_customListRepository != null) {
        lists = await _customListRepository!.getAllLists();
      } else {
        throw StateError('Aucun service de persistance configuré');
      }

      // Recharger complètement avec tous les éléments
      final reloadedLists = <CustomList>[];
      for (final list in lists) {
        final items = await loadListItems(list.id);
        reloadedLists.add(list.copyWith(items: items));
      }

      LoggerService.instance.info(
        'Rechargement forcé terminé: ${reloadedLists.length} listes chargées',
        context: 'ListsPersistenceManager',
      );

      return reloadedLists;
    });
  }

  @override
  Future<void> clearAllData() async {
    await executeMonitoredOperation('clearAllData', () async {
      LoggerService.instance.warning(
        'Début de l\'effacement de toutes les données',
        context: 'ListsPersistenceManager',
      );

      final (allLists, allItems) = await _loadAllDataForClearing();
      await _deleteAllDataFromPersistence(allLists, allItems);

      LoggerService.instance.warning(
        'Toutes les données ont été effacées: ${allLists.length} listes, ${allItems.length} éléments',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> verifyListPersistence(String listId) async {
    await executeMonitoredOperation('verifyListPersistence', () async {
      CustomList? persistedList;

      // Toujours vérifier dans le repository LOCAL pour la persistance immédiate
      if (_customListRepository != null) {
        persistedList = await _customListRepository!.getListById(listId);
      } else {
        throw StateError('Repository local non configuré pour vérification');
      }

      if (persistedList == null) {
        throw Exception(
          'Liste non trouvée après sauvegarde - échec de persistance locale',
        );
      }

      LoggerService.instance.debug(
        'Vérification persistance locale réussie pour "${persistedList.name}"',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> verifyItemPersistence(String itemId) async {
    await executeMonitoredOperation('verifyItemPersistence', () async {
      ListItem? persistedItem;

      // Toujours vérifier dans le repository LOCAL pour la persistance immédiate
      if (_itemRepository != null) {
        persistedItem = await _itemRepository!.getById(itemId);
      } else {
        throw StateError('Repository local d\'items non configuré pour vérification');
      }

      if (persistedItem == null) {
        throw Exception(
          'Item non trouvé après sauvegarde - échec de persistance locale',
        );
      }

      LoggerService.instance.debug(
        'Vérification persistance locale réussie pour item "${persistedItem.title}"',
        context: 'ListsPersistenceManager',
      );
    });
  }

  @override
  Future<void> rollbackItems(List<ListItem> items) async {
    await executeMonitoredOperation('rollbackItems', () async {
      for (final item in items) {
        try {
          await deleteListItem(item.id);
        } catch (e) {
          LoggerService.instance.warning(
            'Erreur lors du rollback de l\'item ${item.id}: $e',
            context: 'ListsPersistenceManager',
          );
        }
      }

      LoggerService.instance.info(
        'Rollback terminé pour ${items.length} éléments',
        context: 'ListsPersistenceManager',
      );
    });
  }

  /// Obtient les statistiques de performance (délègue au mixin)
  Map<String, dynamic> getPerformanceStats() => super.getPerformanceStats();

  /// Réinitialise les statistiques (délègue au mixin)
  void resetStats() => resetPerformanceCounters();

  // === Private Methods ===

  /// Charge toutes les données pour l'effacement
  Future<(List<CustomList>, List<ListItem>)> _loadAllDataForClearing() async {
    if (_adaptivePersistenceService != null) {
      return await _loadDataViaAdaptiveService();
    } else if (_customListRepository != null && _itemRepository != null) {
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
    final allLists = await _customListRepository!.getAllLists();
    final allItems = await _itemRepository!.getAll();
    return (allLists, allItems);
  }

  /// Efface toutes les données de la persistance
  Future<void> _deleteAllDataFromPersistence(
    List<CustomList> allLists,
    List<ListItem> allItems,
  ) async {
    if (_adaptivePersistenceService != null) {
      await _deleteDataViaAdaptiveService(allLists, allItems);
    } else if (_customListRepository != null && _itemRepository != null) {
      await _deleteDataViaLegacyRepositories(allLists, allItems);
    }
  }

  /// Efface les données via le service adaptatif
  Future<void> _deleteDataViaAdaptiveService(
    List<CustomList> allLists,
    List<ListItem> allItems,
  ) async {
    for (final list in allLists) {
      await _adaptivePersistenceService!.deleteList(list.id);
    }

    for (final item in allItems) {
      await _adaptivePersistenceService!.deleteItem(item.id);
    }
  }

  /// Efface les données via les repositories legacy
  Future<void> _deleteDataViaLegacyRepositories(
    List<CustomList> allLists,
    List<ListItem> allItems,
  ) async {
    for (final list in allLists) {
      await _customListRepository!.deleteList(list.id);
    }

    for (final item in allItems) {
      await _itemRepository!.delete(item.id);
    }
  }
}