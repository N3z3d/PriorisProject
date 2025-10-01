import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../interfaces/lists_managers_interfaces.dart';

/// **Command Pattern** pour les opérations de persistance
///
/// **Single Responsibility Principle (SRP)** : Gère uniquement la persistance des données
/// **Open/Closed Principle (OCP)** : Extensible pour de nouveaux backends sans modification
/// **Dependency Inversion Principle (DIP)** : Dépend d'abstractions, pas d'implémentations
class ListsPersistenceManager implements IListsPersistenceManager {
  // === Dependencies (Strategy Pattern) ===
  final AdaptivePersistenceService? _adaptivePersistenceService;
  final CustomListRepository? _customListRepository;
  final ListItemRepository? _itemRepository;

  // === Performance monitoring ===
  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, int> _operationCounts = {};

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
    return await _executeOperation('loadAllLists', () async {
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
    await _executeOperation('saveList', () async {
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
    await _executeOperation('updateList', () async {
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
    await _executeOperation('deleteList', () async {
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
    return await _executeOperation('loadListItems', () async {
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
    await _executeOperation('saveListItem', () async {
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
    await _executeOperation('updateListItem', () async {
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
    await _executeOperation('deleteListItem', () async {
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
    await _executeOperation('saveMultipleItems', () async {
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
    return await _executeOperation('forceReloadFromPersistence', () async {
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
    await _executeOperation('clearAllData', () async {
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
    await _executeOperation('verifyListPersistence', () async {
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
    await _executeOperation('verifyItemPersistence', () async {
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
    await _executeOperation('rollbackItems', () async {
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

  /// Obtient les statistiques de performance
  Map<String, dynamic> getPerformanceStats() {
    return {
      'operationCounts': Map.from(_operationCounts),
      'currentOperations': _operationStartTimes.keys.toList(),
      'totalOperations': _operationCounts.values.fold(0, (sum, count) => sum + count),
      'averageOperationsPerMinute': _calculateAverageOperationsPerMinute(),
    };
  }

  /// Réinitialise les statistiques
  void resetStats() {
    _operationCounts.clear();
    _operationStartTimes.clear();

    LoggerService.instance.debug(
      'Statistiques de performance réinitialisées',
      context: 'ListsPersistenceManager',
    );
  }

  // === Private Methods ===

  /// **Template Method Pattern** - Exécute une opération avec monitoring
  Future<T> _executeOperation<T>(String operationName, Future<T> Function() operation) async {
    _startOperationMonitoring(operationName);

    try {
      final result = await operation();
      _endOperationMonitoring(operationName, success: true);
      return result;
    } catch (e) {
      _endOperationMonitoring(operationName, success: false);
      LoggerService.instance.error(
        'Erreur lors de l\'opération $operationName',
        context: 'ListsPersistenceManager',
        error: e,
      );
      rethrow;
    }
  }

  /// Démarre le monitoring d'une opération
  void _startOperationMonitoring(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
  }

  /// Termine le monitoring d'une opération
  void _endOperationMonitoring(String operationName, {required bool success}) {
    final startTime = _operationStartTimes.remove(operationName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      LoggerService.instance.debug(
        'Opération $operationName ${success ? "réussie" : "échouée"} en ${duration.inMilliseconds}ms',
        context: 'ListsPersistenceManager',
      );
    }
  }

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

  /// Calcule la moyenne d'opérations par minute
  double _calculateAverageOperationsPerMinute() {
    if (_operationCounts.isEmpty) return 0.0;

    final totalOps = _operationCounts.values.fold(0, (sum, count) => sum + count);
    // Estimation basée sur les opérations dans la dernière minute
    return totalOps / 1.0; // Simplification pour l'exemple
  }
}