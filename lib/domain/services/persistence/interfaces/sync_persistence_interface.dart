/// **SYNC PERSISTENCE INTERFACE** - ISP Compliant
///
/// Interface segregée pour les opérations de synchronisation et migration uniquement.
/// Respecte le principe ISP (Interface Segregation Principle).

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';

/// **Interface pour la synchronisation et migration**
///
/// **Responsabilité unique** : Sync, migration, et réconciliation des données
/// **ISP** : Interface minimale et cohérente
abstract class ISyncPersistenceService {
  // === Sync State ===

  /// Indique si une synchronisation est en cours
  bool get isSyncing;

  /// Indique si il y a des données en attente de synchronisation
  Future<bool> get hasPendingSync;

  // === Migration Operations ===

  /// Migre les données selon la stratégie spécifiée
  Future<void> migrateData(MigrationStrategy strategy);

  /// Vérifie s'il y a une migration en attente
  Future<bool> hasPendingMigration();

  /// Gère la transition invité → authentifié
  Future<void> handleGuestToAuthenticatedTransition(MigrationStrategy strategy);

  /// Gère la transition authentifié → invité
  Future<void> handleAuthenticatedToGuestTransition();

  // === Synchronization ===

  /// Force la synchronisation complète de toutes les données
  Future<void> forceSyncAll();

  /// Synchronise une liste spécifique vers le cloud (async)
  void syncListToCloudAsync(CustomList list);

  /// Synchronise un item spécifique vers le cloud (async)
  void syncItemToCloudAsync(ListItem item);

  /// Synchronise toutes les données locales vers le cloud
  Future<void> syncLocalToCloud();

  /// Synchronise toutes les données cloud vers le local
  Future<void> syncCloudToLocal();

  // === Conflict Resolution ===

  /// Résout les conflits de données entre local et cloud
  Future<List<CustomList>> resolveListConflicts(
    List<CustomList> localLists,
    List<CustomList> cloudLists,
  );

  /// Résout les conflits d'items entre local et cloud
  Future<List<ListItem>> resolveItemConflicts(
    List<ListItem> localItems,
    List<ListItem> cloudItems,
  );

  // === Migration Strategies ===

  /// Migration complète : tout vers le cloud
  Future<void> migrateAllDataToCloud(List<CustomList> localLists);

  /// Migration intelligente : merge smart des données
  Future<void> intelligentMergeToCloud(List<CustomList> localLists);

  // === Monitoring ===

  /// Obtient les statistiques de synchronisation
  Map<String, dynamic> getSyncStats();

  /// Obtient le statut de la dernière synchronisation
  Map<String, dynamic> getLastSyncStatus();
}