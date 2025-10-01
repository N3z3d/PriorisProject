/// **DATA MANAGEMENT SERVICE** - SRP Specialized Component
///
/// **LOT 9** : Service spécialisé pour gestion avancée des données
/// **SRP** : Responsabilité unique = Clear/Reload/Sync des données
/// **Taille** : <100 lignes (extraction depuis God Class 923 lignes)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'lists_persistence_service.dart';
import 'items_persistence_service.dart';
import '../interfaces/unified_persistence_interface.dart';

/// Service spécialisé pour les opérations de gestion des données
///
/// **SRP** : Clear/Reload/Sync uniquement
/// **DIP** : Injecte ses dépendances (services, logger)
/// **OCP** : Extensible via nouvelles stratégies de synchronisation
class DataManagementService {
  final ListsPersistenceService _listsService;
  final ItemsPersistenceService _itemsService;
  final ILogger _logger;

  const DataManagementService({
    required ListsPersistenceService listsService,
    required ItemsPersistenceService itemsService,
    required ILogger logger,
  }) : _listsService = listsService,
       _itemsService = itemsService,
       _logger = logger;

  /// Efface toutes les données (listes et items)
  Future<void> clearAllData() async {
    _logger.info('Début effacement de toutes les données', context: 'DataManagementService');

    try {
      final allLists = await _listsService.getAllLists();
      final allItems = <ListItem>[];

      // Collecter tous les items
      for (final list in allLists) {
        final items = await _itemsService.getItemsByListId(list.id);
        allItems.addAll(items);
      }

      // Supprimer tous les items d'abord
      for (final item in allItems) {
        await _itemsService.deleteItem(item.id);
      }

      // Supprimer toutes les listes ensuite
      for (final list in allLists) {
        await _listsService.deleteList(list.id);
      }

      _logger.info('Toutes les données effacées avec succès', context: 'DataManagementService');
    } catch (e) {
      _logger.error('Échec effacement des données: $e', context: 'DataManagementService');
      rethrow;
    }
  }

  /// Force le rechargement depuis la persistance
  Future<List<CustomList>> forceReloadFromPersistence() async {
    _logger.info('Force reload depuis persistance', context: 'DataManagementService');

    try {
      // Clear any internal caches si nécessaire
      final lists = await _listsService.getAllLists();

      _logger.debug('${lists.length} listes rechargées', context: 'DataManagementService');
      return lists;
    } catch (e) {
      _logger.error('Erreur force reload: $e', context: 'DataManagementService');
      rethrow;
    }
  }

  /// Force la synchronisation de toutes les données
  Future<void> forceSyncAll() async {
    _logger.info('Début synchronisation forcée', context: 'DataManagementService');

    try {
      // Synchroniser les listes
      final lists = await _listsService.getAllLists(mode: PersistenceMode.localFirst);

      for (final list in lists) {
        await _listsService.saveList(list, mode: PersistenceMode.cloudFirst);
      }

      // Synchroniser les items
      for (final list in lists) {
        final items = await _itemsService.getItemsByListId(list.id, mode: PersistenceMode.localFirst);

        for (final item in items) {
          await _itemsService.saveItem(item, mode: PersistenceMode.cloudFirst);
        }
      }

      _logger.info('Synchronisation forcée terminée', context: 'DataManagementService');
    } catch (e) {
      _logger.error('Erreur synchronisation forcée: $e', context: 'DataManagementService');
      rethrow;
    }
  }

  /// Obtient les statistiques des données
  Future<Map<String, dynamic>> getDataStatistics() async {
    try {
      final lists = await _listsService.getAllLists();
      int totalItems = 0;

      for (final list in lists) {
        final items = await _itemsService.getItemsByListId(list.id);
        totalItems += items.length;
      }

      return {
        'totalLists': lists.length,
        'totalItems': totalItems,
        'averageItemsPerList': lists.isEmpty ? 0 : totalItems / lists.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.error('Erreur calcul statistiques: $e', context: 'DataManagementService');
      rethrow;
    }
  }
}