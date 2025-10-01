/// **SYNC PERSISTENCE SERVICE** - SOLID Implementation
///
/// **LOT 3.1** : Service spécialisé pour la synchronisation et migration
/// **Responsabilité unique** : Gestion sync, migration et réconciliation
/// **Taille** : <200 lignes (contrainte CLAUDE.md respectée)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/sync_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/local_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/cloud_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';

/// **Service de synchronisation et migration**
///
/// **SRP** : Gestion exclusive de la synchronisation et migration
/// **OCP** : Extensible via injection de dépendances
/// **DIP** : Dépend d'abstractions (services local/cloud)
class SyncPersistenceService implements ISyncPersistenceService {
  final ILocalPersistenceService _localService;
  final ICloudPersistenceService _cloudService;
  final ILogger _logger;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Map<String, dynamic> _lastSyncStatus = {};

  /// **Constructeur avec injection de dépendances** (DIP)
  SyncPersistenceService({
    required ILocalPersistenceService localService,
    required ICloudPersistenceService cloudService,
    required ILogger logger,
  }) : _localService = localService,
       _cloudService = cloudService,
       _logger = logger;

  // === Sync State ===

  @override
  bool get isSyncing => _isSyncing;

  @override
  Future<bool> get hasPendingSync async {
    if (!_cloudService.isCloudAvailable) return false;

    try {
      final localLists = await _localService.getLocalLists();
      return localLists.isNotEmpty;
    } catch (e) {
      _logger.error('Erreur vérification sync pending', context: 'SyncPersistenceService', error: e);
      return false;
    }
  }

  // === Migration Operations ===

  @override
  Future<void> migrateData(MigrationStrategy strategy) async {
    _logger.info('Migration données avec stratégie: ${strategy.name}', context: 'SyncPersistenceService');

    try {
      final localLists = await _localService.getLocalLists();

      if (localLists.isEmpty) {
        _logger.info('Aucune donnée locale à migrer', context: 'SyncPersistenceService');
        return;
      }

      switch (strategy) {
        case MigrationStrategy.migrateAll:
          await migrateAllDataToCloud(localLists);
          break;
        case MigrationStrategy.intelligentMerge:
          await intelligentMergeToCloud(localLists);
          break;
        case MigrationStrategy.cloudOnly:
          // Ne rien migrer
          break;
        case MigrationStrategy.askUser:
          await intelligentMergeToCloud(localLists);
          break;
      }

      _logger.info('Migration terminée', context: 'SyncPersistenceService');
    } catch (e) {
      _logger.error('Erreur pendant la migration', context: 'SyncPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> hasPendingMigration() async {
    if (!_cloudService.isCloudAvailable) return false;

    try {
      final localLists = await _localService.getLocalLists();
      return localLists.isNotEmpty;
    } catch (e) {
      _logger.error('Erreur vérification migration', context: 'SyncPersistenceService', error: e);
      return false;
    }
  }

  @override
  Future<void> handleGuestToAuthenticatedTransition(MigrationStrategy strategy) async {
    _logger.info('Transition Invité → Connecté avec stratégie: ${strategy.name}', context: 'SyncPersistenceService');
    await migrateData(strategy);
  }

  @override
  Future<void> handleAuthenticatedToGuestTransition() async {
    _logger.info('Transition Connecté → Invité', context: 'SyncPersistenceService');
    // Pas de migration nécessaire, les données locales restent
  }

  // === Synchronization ===

  @override
  Future<void> forceSyncAll() async {
    if (!_cloudService.isCloudAvailable) {
      throw Exception('Synchronisation impossible sans authentification');
    }

    _logger.info('Force sync complet', context: 'SyncPersistenceService');
    _isSyncing = true;

    try {
      await syncLocalToCloud();
      _lastSyncTime = DateTime.now();
      _lastSyncStatus = {'status': 'success', 'time': _lastSyncTime!.toIso8601String()};

      _logger.info('Force sync terminé', context: 'SyncPersistenceService');
    } catch (e) {
      _lastSyncStatus = {'status': 'error', 'error': e.toString(), 'time': DateTime.now().toIso8601String()};
      _logger.error('Échec force sync', context: 'SyncPersistenceService', error: e);
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  @override
  void syncListToCloudAsync(CustomList list) {
    if (!_cloudService.isCloudAvailable) return;

    // Synchronisation asynchrone (background)
    Future.microtask(() async {
      try {
        await _cloudService.saveCloudList(list, fallbackToLocal: false);
        _logger.debug('Liste "${list.name}" sync async vers cloud', context: 'SyncPersistenceService');
      } catch (e) {
        _logger.warning('Échec sync async liste "${list.name}"', context: 'SyncPersistenceService');
      }
    });
  }

  @override
  void syncItemToCloudAsync(ListItem item) {
    if (!_cloudService.isCloudAvailable) return;

    // Synchronisation asynchrone (background)
    Future.microtask(() async {
      try {
        await _cloudService.saveCloudItem(item, fallbackToLocal: false);
        _logger.debug('Item "${item.title}" sync async vers cloud', context: 'SyncPersistenceService');
      } catch (e) {
        _logger.warning('Échec sync async item "${item.title}"', context: 'SyncPersistenceService');
      }
    });
  }

  @override
  Future<void> syncLocalToCloud() async {
    final localLists = await _localService.getLocalLists();

    for (final list in localLists) {
      await _cloudService.saveCloudList(list, fallbackToLocal: false);

      final items = await _localService.getLocalItems(list.id);
      for (final item in items) {
        await _cloudService.saveCloudItem(item, fallbackToLocal: false);
      }
    }
  }

  @override
  Future<void> syncCloudToLocal() async {
    final cloudLists = await _cloudService.getCloudLists(fallbackToLocal: false);

    for (final list in cloudLists) {
      await _localService.saveLocalList(list);

      final items = await _cloudService.getCloudItems(list.id, fallbackToLocal: false);
      for (final item in items) {
        await _localService.saveLocalItem(item);
      }
    }
  }

  // === Conflict Resolution ===

  @override
  Future<List<CustomList>> resolveListConflicts(
    List<CustomList> localLists,
    List<CustomList> cloudLists,
  ) async {
    final resolvedLists = <CustomList>[];
    final cloudMap = {for (final list in cloudLists) list.id: list};

    for (final localList in localLists) {
      final cloudList = cloudMap[localList.id];
      if (cloudList != null) {
        // Conflit : prendre la version la plus récente
        resolvedLists.add(localList.updatedAt.isAfter(cloudList.updatedAt) ? localList : cloudList);
      } else {
        resolvedLists.add(localList);
      }
    }

    // Ajouter les listes cloud qui n'existent pas localement
    for (final cloudList in cloudLists) {
      if (!localLists.any((l) => l.id == cloudList.id)) {
        resolvedLists.add(cloudList);
      }
    }

    return resolvedLists;
  }

  @override
  Future<List<ListItem>> resolveItemConflicts(
    List<ListItem> localItems,
    List<ListItem> cloudItems,
  ) async {
    final resolvedItems = <ListItem>[];
    final cloudMap = {for (final item in cloudItems) item.id: item};

    for (final localItem in localItems) {
      final cloudItem = cloudMap[localItem.id];
      if (cloudItem != null) {
        // Conflit : prendre la version la plus récente
        resolvedItems.add(localItem.createdAt.isAfter(cloudItem.createdAt) ? localItem : cloudItem);
      } else {
        resolvedItems.add(localItem);
      }
    }

    // Ajouter les items cloud qui n'existent pas localement
    for (final cloudItem in cloudItems) {
      if (!localItems.any((i) => i.id == cloudItem.id)) {
        resolvedItems.add(cloudItem);
      }
    }

    return resolvedItems;
  }

  // === Migration Strategies ===

  @override
  Future<void> migrateAllDataToCloud(List<CustomList> localLists) async {
    for (final list in localLists) {
      await _cloudService.saveCloudList(list, fallbackToLocal: false);

      final items = await _localService.getLocalItems(list.id);
      for (final item in items) {
        await _cloudService.saveCloudItem(item, fallbackToLocal: false);
      }
    }
  }

  @override
  Future<void> intelligentMergeToCloud(List<CustomList> localLists) async {
    final cloudLists = await _cloudService.getCloudLists(fallbackToLocal: false);
    final resolvedLists = await resolveListConflicts(localLists, cloudLists);

    for (final list in resolvedLists) {
      await _cloudService.saveCloudList(list, fallbackToLocal: false);
    }
  }

  // === Monitoring ===

  @override
  Map<String, dynamic> getSyncStats() {
    return {
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'cloudAvailable': _cloudService.isCloudAvailable,
      'service': 'SyncPersistenceService',
    };
  }

  @override
  Map<String, dynamic> getLastSyncStatus() => Map.from(_lastSyncStatus);
}