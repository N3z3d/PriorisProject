/// **UNIFIED PERSISTENCE SERVICE HELPERS** - Private Implementation Methods
///
/// Ce fichier contient toutes les méthodes privées du UnifiedPersistenceService
/// pour respecter la contrainte <500 lignes par classe de CLAUDE.md
///
/// **Extension Pattern** : Étend UnifiedPersistenceService avec des méthodes privées

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/core/utils/operation_queue.dart';
import 'interfaces/unified_persistence_interface.dart';
import 'unified_persistence_service.dart';

/// **MIXIN HELPERS** pour UnifiedPersistenceService
/// Sépare les responsabilités en groupes logiques
mixin UnifiedPersistenceHelpers on UnifiedPersistenceService {

  // === Deduplication Helpers ===

  /// Déduplique une liste de CustomList par ID
  List<CustomList> _deduplicateLists(List<CustomList> lists) {
    final Map<String, CustomList> uniqueLists = {};

    for (final list in lists) {
      final existingList = uniqueLists[list.id];

      if (existingList == null) {
        // Première occurrence de cet ID
        uniqueLists[list.id] = list;
      } else {
        // Conflit détecté, garder la version la plus récente
        final resolved = _resolveListConflict(existingList, list);
        uniqueLists[list.id] = resolved;
        logger.debug(
          'Déduplication: conflit résolu pour liste "${resolved.name}" (${list.id})',
          context: 'UnifiedPersistenceService',
        );
      }
    }

    final deduplicatedLists = uniqueLists.values.toList();

    if (deduplicatedLists.length < lists.length) {
      logger.info(
        'Déduplication: ${lists.length} → ${deduplicatedLists.length} listes',
        context: 'UnifiedPersistenceService',
      );
    }

    return deduplicatedLists;
  }

  /// Résout les conflits entre listes (dernière modification gagne)
  CustomList _resolveListConflict(CustomList existing, CustomList incoming) {
    if (existing.updatedAt != null && incoming.updatedAt != null) {
      return existing.updatedAt!.isAfter(incoming.updatedAt!) ? existing : incoming;
    } else if (existing.updatedAt != null) {
      return existing;
    } else if (incoming.updatedAt != null) {
      return incoming;
    } else {
      // Aucune date, préférer la version entrante
      return incoming;
    }
  }

  /// Résout les conflits entre items
  ListItem _resolveItemConflict(ListItem existing, ListItem incoming) {
    if (existing.createdAt.isAfter(incoming.createdAt)) {
      return existing;
    } else if (incoming.createdAt.isAfter(existing.createdAt)) {
      return incoming;
    } else {
      // En cas d'égalité, préférer la version entrante
      return incoming;
    }
  }

  // === Cloud-First Operations ===

  /// Récupère les listes en mode cloud-first avec fallback
  Future<List<CustomList>> _getListsCloudFirst() async {
    try {
      final lists = await cloudRepository.getAllLists();

      // Sync en arrière-plan vers local si activé
      if (configuration.enableBackgroundSync) {
        _syncCloudToLocalAsync(lists);
      }

      return lists;
    } catch (e) {
      logger.error(
        'Cloud indisponible, fallback vers local',
        context: 'UnifiedPersistenceService',
        error: e,
      );
      return await localRepository.getAllLists();
    }
  }

  /// Récupère les listes en mode hybride
  Future<List<CustomList>> _getListsHybrid() async {
    // TODO: Implémenter stratégie hybride intelligente
    return await _getListsCloudFirst();
  }

  /// Sauvegarde une liste en mode cloud-first
  Future<void> _saveListCloudFirst(CustomList list) async {
    // Sauvegarder en local d'abord pour réponse immédiate
    await _saveListWithDeduplication(list, localRepository);

    // Sync vers cloud en arrière-plan ou immédiat
    if (configuration.enableBackgroundSync) {
      _syncListToCloudAsync(list);
    } else {
      try {
        await cloudRepository.saveList(list);
      } catch (e) {
        logger.error(
          'Échec sync immédiat vers cloud',
          context: 'UnifiedPersistenceService',
          error: e,
        );
        // Ne pas propager l'erreur - la sauvegarde locale a réussi
      }
    }
  }

  /// Sauvegarde une liste en mode hybride
  Future<void> _saveListHybrid(CustomList list) async {
    // TODO: Implémenter stratégie hybride intelligente
    await _saveListCloudFirst(list);
  }

  /// Met à jour une liste en mode hybride
  Future<void> _updateListHybrid(CustomList list) async {
    await localRepository.updateList(list);
    if (configuration.enableBackgroundSync) {
      _syncListToCloudAsync(list);
    }
  }

  /// Supprime une liste en mode cloud-first
  Future<void> _deleteListCloudFirst(String listId) async {
    // Supprimer en local d'abord
    await localRepository.deleteList(listId);

    // Sync suppression vers cloud en arrière-plan
    if (configuration.enableBackgroundSync) {
      _deleteFromCloudWithErrorHandling(listId, 'list');
    }
  }

  /// Supprime une liste en mode hybride
  Future<void> _deleteListHybrid(String listId) async {
    await _deleteListCloudFirst(listId);
  }

  // === Item Cloud Operations ===

  /// Récupère les items en mode cloud-first
  Future<List<ListItem>> _getItemsCloudFirst(String listId) async {
    try {
      final items = await cloudItemRepository.getByListId(listId);
      if (configuration.enableBackgroundSync) {
        _syncItemsToLocalAsync(listId, items);
      }
      return items;
    } catch (e) {
      logger.error(
        'Cloud indisponible pour items, fallback vers local',
        context: 'UnifiedPersistenceService',
        error: e,
      );
      return await localItemRepository.getByListId(listId);
    }
  }

  /// Récupère les items en mode hybride
  Future<List<ListItem>> _getItemsHybrid(String listId) async {
    return await _getItemsCloudFirst(listId);
  }

  /// Sauvegarde un item en mode cloud-first
  Future<void> _saveItemCloudFirst(ListItem item) async {
    await _saveItemWithDeduplication(item, localItemRepository);

    if (configuration.enableBackgroundSync) {
      _syncItemToCloudAsync(item);
    }
  }

  /// Sauvegarde un item en mode hybride
  Future<void> _saveItemHybrid(ListItem item) async {
    await _saveItemCloudFirst(item);
  }

  /// Met à jour un item en mode hybride
  Future<void> _updateItemHybrid(ListItem item) async {
    await localItemRepository.update(item);
    if (configuration.enableBackgroundSync) {
      _syncItemToCloudAsync(item);
    }
  }

  /// Supprime un item en mode cloud-first
  Future<void> _deleteItemCloudFirst(String itemId) async {
    await localItemRepository.delete(itemId);

    if (configuration.enableBackgroundSync) {
      _deleteFromCloudWithErrorHandling(itemId, 'item');
    }
  }

  /// Supprime un item en mode hybride
  Future<void> _deleteItemHybrid(String itemId) async {
    await _deleteItemCloudFirst(itemId);
  }

  // === Deduplication Save Operations ===

  /// Sauvegarde avec gestion des doublons pour listes
  Future<void> _saveListWithDeduplication(
    CustomList list,
    CustomListRepository repository,
  ) async {
    try {
      await repository.saveList(list);
    } catch (e) {
      if (e.toString().contains('Une liste avec cet ID existe déjà')) {
        logger.debug(
          'Conflit détecté pour liste ${list.id}, fusion...',
          context: 'UnifiedPersistenceService',
        );

        final existingList = await repository.getListById(list.id);
        if (existingList != null) {
          final mergedList = _resolveListConflict(existingList, list);
          await repository.updateList(mergedList);
          logger.debug(
            'Conflit résolu pour "${mergedList.name}"',
            context: 'UnifiedPersistenceService',
          );
        } else {
          await repository.saveList(list);
        }
      } else {
        rethrow;
      }
    }
  }

  /// Sauvegarde avec gestion des doublons pour items
  Future<void> _saveItemWithDeduplication(
    ListItem item,
    ListItemRepository repository,
  ) async {
    try {
      await repository.add(item);
    } catch (e) {
      if (e.toString().contains('Un item avec cet id existe déjà')) {
        logger.debug(
          'Conflit item détecté pour ${item.id}, fusion...',
          context: 'UnifiedPersistenceService',
        );

        final existingItem = await repository.getById(item.id);
        if (existingItem != null) {
          final mergedItem = _resolveItemConflict(existingItem, item);
          await repository.update(mergedItem);
          logger.debug(
            'Conflit item résolu pour "${mergedItem.title}"',
            context: 'UnifiedPersistenceService',
          );
        } else {
          await repository.add(item);
        }
      } else {
        rethrow;
      }
    }
  }

  // === Background Sync Operations ===

  /// Synchronise les listes cloud vers local en arrière-plan
  void _syncCloudToLocalAsync(List<CustomList> lists) {
    if (!configuration.enableBackgroundSync) return;

    Future.microtask(() async {
      try {
        for (final list in lists) {
          await _saveListWithDeduplication(list, localRepository);
        }
        logger.debug(
          'Sync background vers local terminé (${lists.length} listes)',
          context: 'UnifiedPersistenceService',
        );
      } catch (e) {
        logger.error(
          'Échec sync background vers local',
          context: 'UnifiedPersistenceService',
          error: e,
        );
      }
    });
  }

  /// Synchronise une liste vers le cloud en arrière-plan
  void _syncListToCloudAsync(CustomList list) {
    if (!configuration.enableBackgroundSync || !isAuthenticated) return;

    OperationQueue.instance.enqueue(
      name: 'syncListToCloud',
      operation: () async {
        await cloudRepository.saveList(list);
        logger.debug(
          'Sync cloud réussie pour "${list.name}"',
          context: 'UnifiedPersistenceService',
        );
      },
      priority: OperationPriority.low,
      maxRetries: configuration.maxRetries,
    ).catchError((e) {
      _handleCloudError('syncList', list.id, e);
    });
  }

  /// Synchronise un item vers le cloud en arrière-plan
  void _syncItemToCloudAsync(ListItem item) {
    if (!configuration.enableBackgroundSync || !isAuthenticated) return;

    OperationQueue.instance.enqueue(
      name: 'syncItemToCloud',
      operation: () async {
        await cloudItemRepository.add(item);
        logger.debug(
          'Sync cloud item réussie pour "${item.title}"',
          context: 'UnifiedPersistenceService',
        );
      },
      priority: OperationPriority.low,
      maxRetries: configuration.maxRetries,
    ).catchError((e) {
      _handleCloudError('syncItem', item.id, e);
    });
  }

  /// Synchronise les items vers le local en arrière-plan
  void _syncItemsToLocalAsync(String listId, List<ListItem> items) {
    if (!configuration.enableBackgroundSync) return;

    Future.microtask(() async {
      try {
        for (final item in items) {
          await _saveItemWithDeduplication(item, localItemRepository);
        }
        logger.debug(
          'Sync items vers local terminé pour liste $listId',
          context: 'UnifiedPersistenceService',
        );
      } catch (e) {
        logger.error(
          'Échec sync items vers local',
          context: 'UnifiedPersistenceService',
          error: e,
        );
      }
    });
  }

  // === Cloud Error Handling ===

  /// Suppression cloud avec gestion d'erreur
  void _deleteFromCloudWithErrorHandling(String id, String type) {
    if (!isAuthenticated) return;

    OperationQueue.instance.enqueue(
      name: 'deleteFromCloud',
      operation: () async {
        if (type == 'list') {
          await cloudRepository.deleteList(id);
        } else if (type == 'item') {
          await cloudItemRepository.delete(id);
        }
        logger.debug(
          'Suppression cloud réussie pour $type $id',
          context: 'UnifiedPersistenceService',
        );
      },
      priority: OperationPriority.medium,
      maxRetries: configuration.maxRetries,
    ).catchError((e) {
      _handleCloudError('delete$type', id, e);
    });
  }

  /// Gestion centralisée des erreurs cloud
  void _handleCloudError(String operation, String id, dynamic error) {
    final errorMsg = error.toString();

    // Vérifier si c'est une erreur de permission
    if (_isPermissionError(errorMsg)) {
      logger.warning(
        'Erreur de permission cloud pour $operation($id)',
        context: 'UnifiedPersistenceService',
      );
      return; // Ne pas propager - l'opération locale a réussi
    }

    // Pour les autres erreurs cloud, log sans bloquer
    logger.warning(
      'Erreur cloud pour $operation($id): ${_sanitizeErrorMessage(errorMsg)}',
      context: 'UnifiedPersistenceService',
    );
  }

  /// Vérifie si l'erreur est liée aux permissions
  bool _isPermissionError(String error) {
    return error.contains('403 Forbidden') ||
           error.contains('permission denied') ||
           error.contains('Row Level Security') ||
           error.contains('JWT expired') ||
           error.contains('Unauthorized');
  }

  /// Assainit les messages d'erreur pour l'utilisateur
  String _sanitizeErrorMessage(String error) {
    if (error.contains('PostgrestException')) return 'Problème de synchronisation cloud';
    if (error.contains('JWT expired')) return 'Session expirée';
    if (error.contains('403 Forbidden')) return 'Permissions insuffisantes';
    if (error.contains('Row Level Security')) return 'Restrictions d\'accès appliquées';

    return 'Problème de synchronisation temporaire';
  }

  // === Migration Helpers ===

  /// Gère la transition Invité → Connecté
  Future<void> _handleGuestToAuthenticatedTransition(MigrationStrategy strategy) async {
    logger.info(
      'Transition Invité → Connecté avec stratégie: ${strategy.name}',
      context: 'UnifiedPersistenceService',
    );

    try {
      final localLists = await localRepository.getAllLists();

      if (localLists.isEmpty) {
        logger.info('Aucune donnée locale à migrer', context: 'UnifiedPersistenceService');
        return;
      }

      await migrateData(strategy);
    } catch (e) {
      logger.error(
        'Erreur migration vers cloud',
        context: 'UnifiedPersistenceService',
        error: e,
      );
      // Ne pas propager - permettre à l'app de continuer avec les données locales
    }
  }

  /// Gère la transition Connecté → Invité
  Future<void> _handleAuthenticatedToGuestTransition() async {
    logger.info(
      'Transition Connecté → Invité',
      context: 'UnifiedPersistenceService',
    );

    try {
      // Synchroniser les dernières données cloud vers local
      final cloudLists = await cloudRepository.getAllLists();
      for (final list in cloudLists) {
        await _saveListWithDeduplication(list, localRepository);
      }

      logger.info('Sync cloud → local terminée', context: 'UnifiedPersistenceService');
    } catch (e) {
      logger.warning(
        'Impossible de synchroniser avant déconnexion',
        context: 'UnifiedPersistenceService',
      );
      // Continuer avec les données locales existantes
    }
  }

  /// Migration intelligente avec fusion des données
  Future<void> _intelligentMergeToCloud(List<CustomList> localLists) async {
    try {
      final cloudLists = await cloudRepository.getAllLists();
      final cloudListsMap = {for (var list in cloudLists) list.id: list};

      for (final localList in localLists) {
        final cloudList = cloudListsMap[localList.id];

        if (cloudList == null) {
          // Nouvelle liste locale → migrer vers cloud
          await cloudRepository.saveList(localList);
          logger.info('Liste "${localList.name}" migrée vers cloud', context: 'UnifiedPersistenceService');
        } else {
          // Conflit → résoudre avec la plus récente
          final mergedList = _resolveListConflict(localList, cloudList);
          await cloudRepository.saveList(mergedList);
          logger.info('Liste "${mergedList.name}" fusionnée', context: 'UnifiedPersistenceService');
        }
      }
    } catch (e) {
      logger.error('Erreur fusion intelligente', context: 'UnifiedPersistenceService', error: e);
      rethrow;
    }
  }

  /// Migration complète vers le cloud
  Future<void> _migrateAllDataToCloud(List<CustomList> localLists) async {
    for (final list in localLists) {
      try {
        await cloudRepository.saveList(list);
        logger.info('Liste "${list.name}" migrée', context: 'UnifiedPersistenceService');
      } catch (e) {
        logger.error('Erreur migration liste "${list.name}"', context: 'UnifiedPersistenceService', error: e);
      }
    }
  }

  /// Rollback des items en cas d'échec transactionnel
  Future<void> _rollbackFailedItems(List<ListItem> itemsToRollback) async {
    for (final item in itemsToRollback) {
      try {
        await deleteItem(item.id);
      } catch (e) {
        logger.warning(
          'Erreur rollback item ${item.id}',
          context: 'UnifiedPersistenceService',
        );
      }
    }
  }
}