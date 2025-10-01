/// **CLOUD PERSISTENCE SERVICE** - SOLID Implementation
///
/// **LOT 3.1** : Service spécialisé pour les opérations cloud avec fallback
/// **Responsabilité unique** : Gestion des données cloud avec fallback intelligent
/// **Taille** : <250 lignes (contrainte CLAUDE.md respectée)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/cloud_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/local_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';

/// **Service de persistance cloud**
///
/// **SRP** : Gestion exclusive des opérations cloud avec fallback
/// **OCP** : Extensible via injection de dépendances
/// **DIP** : Dépend d'abstractions (repositories et services)
class CloudPersistenceService implements ICloudPersistenceService {
  final CustomListRepository _cloudRepository;
  final ListItemRepository _cloudItemRepository;
  final ILocalPersistenceService _localService;
  final IPersistenceValidator _validator;
  final ILogger _logger;
  final bool _isAuthenticated;

  /// **Constructeur avec injection de dépendances** (DIP)
  const CloudPersistenceService({
    required CustomListRepository cloudRepository,
    required ListItemRepository cloudItemRepository,
    required ILocalPersistenceService localService,
    required IPersistenceValidator validator,
    required ILogger logger,
    required bool isAuthenticated,
  }) : _cloudRepository = cloudRepository,
       _cloudItemRepository = cloudItemRepository,
       _localService = localService,
       _validator = validator,
       _logger = logger,
       _isAuthenticated = isAuthenticated;

  // === Authentication State ===

  @override
  bool get isCloudAvailable => _isAuthenticated;

  // === List Operations ===

  @override
  Future<List<CustomList>> getCloudLists({bool fallbackToLocal = true}) async {
    _logger.debug('Récupération listes cloud (fallback: $fallbackToLocal)', context: 'CloudPersistenceService');

    try {
      if (!isCloudAvailable) {
        return fallbackToLocal ? await _localService.getLocalLists() : <CustomList>[];
      }

      final lists = await _cloudRepository.getAllLists();
      final sanitizedLists = _validator.sanitizeLists(lists);

      _logger.info('${sanitizedLists.length} listes cloud récupérées', context: 'CloudPersistenceService');
      return sanitizedLists;
    } catch (e) {
      _logger.error('Erreur cloud, fallback: $fallbackToLocal', context: 'CloudPersistenceService', error: e);
      return fallbackToLocal ? await _localService.getLocalLists() : <CustomList>[];
    }
  }

  @override
  Future<void> saveCloudList(CustomList list, {bool fallbackToLocal = true}) async {
    if (!_validator.validateList(list)) {
      throw UnifiedPersistenceException(
        'Liste invalide pour sauvegarde cloud',
        operation: 'saveCloudList',
        id: list.id,
        mode: PersistenceMode.cloudFirst,
      );
    }

    try {
      if (isCloudAvailable) {
        await _cloudRepository.saveList(list);
        _logger.info('Liste "${list.name}" sauvegardée dans le cloud', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.saveLocalList(list);
        _logger.info('Liste "${list.name}" sauvegardée localement (cloud indisponible)', context: 'CloudPersistenceService');
      } else {
        throw UnifiedPersistenceException(
          'Cloud indisponible et fallback désactivé',
          operation: 'saveCloudList',
          id: list.id,
          mode: PersistenceMode.cloudFirst,
        );
      }
    } catch (e) {
      _logger.error('Échec sauvegarde cloud liste "${list.name}"', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateCloudList(CustomList list, {bool fallbackToLocal = true}) async {
    if (!_validator.validateList(list)) {
      throw UnifiedPersistenceException(
        'Liste invalide pour mise à jour cloud',
        operation: 'updateCloudList',
        id: list.id,
        mode: PersistenceMode.cloudFirst,
      );
    }

    try {
      if (isCloudAvailable) {
        await _cloudRepository.updateList(list);
        _logger.info('Liste "${list.name}" mise à jour dans le cloud', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.updateLocalList(list);
        _logger.info('Liste "${list.name}" mise à jour localement (cloud indisponible)', context: 'CloudPersistenceService');
      }
    } catch (e) {
      _logger.error('Échec mise à jour cloud liste "${list.name}"', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCloudList(String listId, {bool fallbackToLocal = true}) async {
    try {
      if (isCloudAvailable) {
        await _cloudRepository.deleteList(listId);
        _logger.info('Liste $listId supprimée du cloud', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.deleteLocalList(listId);
        _logger.info('Liste $listId supprimée localement (cloud indisponible)', context: 'CloudPersistenceService');
      }
    } catch (e) {
      _logger.error('Échec suppression cloud liste $listId', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  // === Item Operations ===

  @override
  Future<List<ListItem>> getCloudItems(String listId, {bool fallbackToLocal = true}) async {
    try {
      if (!isCloudAvailable) {
        return fallbackToLocal ? await _localService.getLocalItems(listId) : <ListItem>[];
      }

      final items = await _cloudItemRepository.getByListId(listId);
      final sanitizedItems = _validator.sanitizeItems(items);

      _logger.debug('${sanitizedItems.length} items cloud récupérés pour liste $listId', context: 'CloudPersistenceService');
      return sanitizedItems;
    } catch (e) {
      _logger.error('Erreur cloud items, fallback: $fallbackToLocal', context: 'CloudPersistenceService', error: e);
      return fallbackToLocal ? await _localService.getLocalItems(listId) : <ListItem>[];
    }
  }

  @override
  Future<void> saveCloudItem(ListItem item, {bool fallbackToLocal = true}) async {
    if (!_validator.validateListItem(item)) {
      throw UnifiedPersistenceException(
        'Item invalide pour sauvegarde cloud',
        operation: 'saveCloudItem',
        id: item.id,
        mode: PersistenceMode.cloudFirst,
      );
    }

    try {
      if (isCloudAvailable) {
        await _cloudItemRepository.add(item);
        _logger.info('Item "${item.title}" sauvegardé dans le cloud', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.saveLocalItem(item);
        _logger.info('Item "${item.title}" sauvegardé localement (cloud indisponible)', context: 'CloudPersistenceService');
      }
    } catch (e) {
      _logger.error('Échec sauvegarde cloud item "${item.title}"', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateCloudItem(ListItem item, {bool fallbackToLocal = true}) async {
    if (!_validator.validateListItem(item)) {
      throw UnifiedPersistenceException(
        'Item invalide pour mise à jour cloud',
        operation: 'updateCloudItem',
        id: item.id,
        mode: PersistenceMode.cloudFirst,
      );
    }

    try {
      if (isCloudAvailable) {
        await _cloudItemRepository.update(item);
        _logger.info('Item "${item.title}" mis à jour dans le cloud', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.updateLocalItem(item);
        _logger.info('Item "${item.title}" mis à jour localement (cloud indisponible)', context: 'CloudPersistenceService');
      }
    } catch (e) {
      _logger.error('Échec mise à jour cloud item "${item.title}"', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCloudItem(String itemId, {bool fallbackToLocal = true}) async {
    try {
      if (isCloudAvailable) {
        await _cloudItemRepository.delete(itemId);
        _logger.info('Item $itemId supprimé du cloud', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.deleteLocalItem(itemId);
        _logger.info('Item $itemId supprimé localement (cloud indisponible)', context: 'CloudPersistenceService');
      }
    } catch (e) {
      _logger.error('Échec suppression cloud item $itemId', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  // === Batch Operations ===

  @override
  Future<void> saveMultipleCloudItems(List<ListItem> items, {bool fallbackToLocal = true}) async {
    if (items.isEmpty) return;

    try {
      if (isCloudAvailable) {
        for (final item in items) {
          await saveCloudItem(item, fallbackToLocal: false);
        }
        _logger.info('${items.length} items sauvegardés dans le cloud avec succès', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.saveMultipleLocalItems(items);
        _logger.info('${items.length} items sauvegardés localement (cloud indisponible)', context: 'CloudPersistenceService');
      }
    } catch (e) {
      _logger.error('Échec sauvegarde cloud bulk', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> clearCloudData({bool fallbackToLocal = true}) async {
    _logger.info('Début effacement données cloud', context: 'CloudPersistenceService');

    try {
      if (isCloudAvailable) {
        final allLists = await getCloudLists(fallbackToLocal: false);
        final allItems = <ListItem>[];

        for (final list in allLists) {
          final items = await getCloudItems(list.id, fallbackToLocal: false);
          allItems.addAll(items);
        }

        for (final item in allItems) {
          await deleteCloudItem(item.id, fallbackToLocal: false);
        }

        for (final list in allLists) {
          await deleteCloudList(list.id, fallbackToLocal: false);
        }

        _logger.info('Données cloud effacées avec succès', context: 'CloudPersistenceService');
      } else if (fallbackToLocal) {
        await _localService.clearLocalData();
        _logger.info('Données locales effacées (cloud indisponible)', context: 'CloudPersistenceService');
      }
    } catch (e) {
      _logger.error('Échec effacement données cloud', context: 'CloudPersistenceService', error: e);
      rethrow;
    }
  }

  // === Connectivity & Health ===

  @override
  Future<bool> checkCloudConnectivity() async {
    try {
      if (!isCloudAvailable) return false;

      // Test simple avec timeout
      await _cloudRepository.getAllLists();
      return true;
    } catch (e) {
      _logger.debug('Test connectivité cloud échoué', context: 'CloudPersistenceService');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getCloudHealthStatus() async {
    final isConnected = await checkCloudConnectivity();

    return {
      'isAuthenticated': _isAuthenticated,
      'isConnected': isConnected,
      'isAvailable': isCloudAvailable,
      'lastCheck': DateTime.now().toIso8601String(),
      'service': 'CloudPersistenceService',
    };
  }
}