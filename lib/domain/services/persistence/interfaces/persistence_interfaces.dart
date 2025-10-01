import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/persistence/common/persistence_types.dart';

/// Interface pour les services de persistance de base
abstract class IPersistenceService {
  /// Sauvegarde une liste
  Future<PersistenceResult<void>> saveList(CustomList list);

  /// Récupère une liste par ID
  Future<PersistenceResult<CustomList?>> getListById(String id);

  /// Récupère toutes les listes
  Future<PersistenceResult<List<CustomList>>> getAllLists();

  /// Supprime une liste
  Future<PersistenceResult<void>> deleteList(String id);

  /// Sauvegarde un élément
  Future<PersistenceResult<void>> saveItem(ListItem item);

  /// Récupère un élément par ID
  Future<PersistenceResult<ListItem?>> getItemById(String id);

  /// Récupère tous les éléments d'une liste
  Future<PersistenceResult<List<ListItem>>> getItemsByListId(String listId);

  /// Supprime un élément
  Future<PersistenceResult<void>> deleteItem(String id);
}

/// Interface pour la gestion des modes de persistance
abstract class IPersistenceModeManager {
  /// Mode de persistance actuel
  PersistenceMode get currentMode;

  /// État d'authentification
  bool get isAuthenticated;

  /// Met à jour l'état d'authentification
  void updateAuthenticationState(bool isAuthenticated);

  /// Détermine le mode de persistance optimal
  PersistenceMode determineOptimalMode(bool isAuthenticated);

  /// Change le mode de persistance
  void switchMode(PersistenceMode newMode);
}

/// Interface pour les services de synchronisation
abstract class ISyncService {
  /// État de synchronisation actuel
  SyncStatus get syncStatus;

  /// Synchronise du local vers le cloud
  Future<PersistenceResult<void>> syncLocalToCloud();

  /// Synchronise du cloud vers le local
  Future<PersistenceResult<void>> syncCloudToLocal();

  /// Synchronisation bidirectionnelle
  Future<PersistenceResult<void>> bidirectionalSync();

  /// Vérifie si une synchronisation est nécessaire
  Future<bool> isSyncRequired();
}

/// Interface pour les services de migration
abstract class IMigrationService {
  /// Migre les données selon la stratégie spécifiée
  Future<PersistenceResult<void>> migrateData(MigrationStrategy strategy);

  /// Vérifie s'il y a des données à migrer
  Future<bool> hasPendingMigration();

  /// Fusionne intelligemment les données local/cloud
  Future<PersistenceResult<void>> intelligentMerge();
}

/// Interface pour le service de persistance adaptatif
abstract class IAdaptivePersistenceService extends IPersistenceService {
  /// Configuration actuelle
  PersistenceConfig get config;

  /// Met à jour la configuration
  void updateConfig(PersistenceConfig config);

  /// Efface toutes les données
  Future<PersistenceResult<void>> clearAllData();

  /// Force une synchronisation complète
  Future<PersistenceResult<void>> forceSyncAll();
}