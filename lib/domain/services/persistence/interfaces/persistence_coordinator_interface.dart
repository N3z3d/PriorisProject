/// **PERSISTENCE COORDINATOR INTERFACE** - ISP Compliant
///
/// Interface segregée pour l'orchestration des services de persistance.
/// Respecte le principe ISP (Interface Segregation Principle).

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';

/// **Interface pour le coordinateur de persistance**
///
/// **Responsabilité unique** : Orchestration et configuration des services
/// **ISP** : Interface minimale de coordination
abstract class IPersistenceCoordinator {
  // === Configuration and State ===

  /// Mode de persistance actuel
  PersistenceMode get currentMode;

  /// État d'authentification
  bool get isAuthenticated;

  /// État de synchronisation
  bool get isSyncing;

  // === Lifecycle Management ===

  /// Initialise le coordinateur avec l'état d'authentification
  Future<void> initialize({required bool isAuthenticated});

  /// Met à jour l'état d'authentification et change de mode
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  });

  /// Libère les ressources
  void dispose();

  // === Core Operations (Unified Interface) ===

  /// Récupère toutes les listes selon le mode actuel
  Future<List<CustomList>> getAllLists();

  /// Sauvegarde une liste selon le mode actuel
  Future<void> saveList(CustomList list);

  /// Met à jour une liste selon le mode actuel
  Future<void> updateList(CustomList list);

  /// Supprime une liste selon le mode actuel
  Future<void> deleteList(String listId);

  /// Récupère les items d'une liste selon le mode actuel
  Future<List<ListItem>> getItemsByListId(String listId);

  /// Sauvegarde un item selon le mode actuel
  Future<void> saveItem(ListItem item);

  /// Met à jour un item selon le mode actuel
  Future<void> updateItem(ListItem item);

  /// Supprime un item selon le mode actuel
  Future<void> deleteItem(String itemId);

  // === Bulk Operations ===

  /// Sauvegarde multiple d'items avec transaction
  Future<void> saveMultipleItems(List<ListItem> items);

  /// Efface toutes les données selon le mode actuel
  Future<void> clearAllData();

  // === Advanced Operations ===

  /// Force le rechargement depuis la persistance
  Future<List<CustomList>> forceReloadFromPersistence();

  /// Vérifie qu'une liste a bien été persistée
  Future<void> verifyListPersistence(String listId);

  /// Vérifie qu'un item a bien été persisté
  Future<void> verifyItemPersistence(String itemId);

  // === Migration Support ===

  /// Migre les données selon la stratégie
  Future<void> migrateData(MigrationStrategy strategy);

  /// Vérifie s'il y a une migration en attente
  Future<bool> hasPendingMigration();

  // === Synchronization Support ===

  /// Force la synchronisation complète
  Future<void> forceSyncAll();

  // === Statistics and Monitoring ===

  /// Obtient les statistiques de persistance
  Map<String, dynamic> getPersistenceStats();
}