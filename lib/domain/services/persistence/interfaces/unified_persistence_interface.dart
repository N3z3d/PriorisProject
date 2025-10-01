/// **UNIFIED PERSISTENCE INTERFACE** - Single Source of Truth
///
/// Cette interface unifie tous les services de persistance selon les principes SOLID :
/// - **SRP** : Une seule responsabilité - définir le contrat de persistance
/// - **OCP** : Ouverte à l'extension (nouvelles implémentations), fermée à la modification
/// - **LSP** : Toute implémentation peut remplacer cette interface
/// - **ISP** : Interface segregée en contrats spécialisés
/// - **DIP** : Fournit l'abstraction pour l'inversion de dépendance
///
/// **Consolidation 36→1** : Cette interface remplace tous les services de persistance dupliqués

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';

/// Mode de persistance adaptatif selon l'état d'authentification
enum PersistenceMode {
  /// Données stockées localement uniquement (utilisateur invité)
  localFirst,

  /// Données stockées en cloud avec backup local (utilisateur connecté)
  cloudFirst,

  /// Synchronisation intelligente entre local et cloud
  hybrid,
}

/// Stratégie de migration des données locales vers le cloud
enum MigrationStrategy {
  /// Migrer toutes les données locales vers le cloud
  migrateAll,

  /// Demander à l'utilisateur ce qu'il veut faire
  askUser,

  /// Garder uniquement les données cloud
  cloudOnly,

  /// Fusionner intelligemment les données
  intelligentMerge,
}

/// **INTERFACE PRINCIPALE UNIFIÉE** - Contract pour tous les services de persistance
///
/// Cette interface remplace :
/// - AdaptivePersistenceService (725 lignes)
/// - IPersistenceService
/// - IAdaptivePersistenceService
/// - IPersistenceCoordinator
/// - Tous les autres services de persistance dupliqués (36 fichiers)
abstract class IUnifiedPersistenceService {
  // === Configuration et État ===

  /// Mode de persistance actuel
  PersistenceMode get currentMode;

  /// État d'authentification
  bool get isAuthenticated;

  // === Lifecycle Management ===

  /// Initialise le service avec l'état d'authentification
  Future<void> initialize({required bool isAuthenticated});

  /// Met à jour l'état d'authentification et adapte la persistance
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  });

  /// Nettoie les ressources
  void dispose();

  // === Core List Operations ===

  /// Récupère toutes les listes selon le mode actuel
  /// **DEDUPLICATION** : Automatiquement dédupliquée si activée
  Future<List<CustomList>> getAllLists();

  /// Sauvegarde une liste selon le mode actuel
  /// **DEDUPLICATION** : Gère les conflits d'ID avec stratégie upsert
  Future<void> saveList(CustomList list);

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list);

  /// Supprime une liste selon le mode actuel
  /// **RLS PERMISSION** : Gère les erreurs de permission gracieusement
  Future<void> deleteList(String listId);

  // === Core Item Operations ===

  /// Récupère tous les items d'une liste selon le mode actuel
  Future<List<ListItem>> getItemsByListId(String listId);

  /// Sauvegarde un item selon le mode actuel
  /// **DEDUPLICATION** : Gère les conflits d'ID avec stratégie upsert
  Future<void> saveItem(ListItem item);

  /// Met à jour un item selon le mode actuel
  Future<void> updateItem(ListItem item);

  /// Supprime un item selon le mode actuel
  /// **RLS PERMISSION** : Gère les erreurs de permission gracieusement
  Future<void> deleteItem(String itemId);

  // === Bulk Operations ===

  /// Sauvegarde plusieurs items en une seule opération transactionnelle
  /// **TRANSACTIONAL** : Rollback automatique en cas d'échec partiel
  Future<void> saveMultipleItems(List<ListItem> items);

  /// Efface toutes les données (listes et éléments)
  Future<void> clearAllData();

  // === Advanced Operations ===

  /// Force le rechargement complet depuis la persistance
  Future<List<CustomList>> forceReloadFromPersistence();

  /// Vérifie qu'une liste a bien été persistée
  Future<void> verifyListPersistence(String listId);

  /// Vérifie qu'un item a bien été persisté
  Future<void> verifyItemPersistence(String itemId);

  // === Migration Support ===

  /// Migre les données selon la stratégie spécifiée
  Future<void> migrateData(MigrationStrategy strategy);

  /// Vérifie s'il y a des données à migrer
  Future<bool> hasPendingMigration();

  // === Synchronization Support ===

  /// Force une synchronisation complète
  Future<void> forceSyncAll();

  /// État de synchronisation actuel
  bool get isSyncing;

  // === Statistics and Monitoring ===

  /// Obtient les statistiques de persistance
  Map<String, dynamic> getPersistenceStats();
}

/// **INTERFACE DE CONFIGURATION UNIFIÉE**
/// Centralise toute la configuration des services de persistance
abstract class IPersistenceConfiguration {
  /// Mode par défaut
  PersistenceMode get defaultMode;

  /// Stratégie de migration par défaut
  MigrationStrategy get defaultMigrationStrategy;

  /// Activer la synchronisation en arrière-plan
  bool get enableBackgroundSync;

  /// Activer la déduplication automatique
  bool get enableDeduplication;

  /// Timeout pour les opérations de synchronisation
  Duration get syncTimeout;

  /// Nombre maximum de tentatives
  int get maxRetries;

  /// Convertit en Map pour debugging/monitoring
  Map<String, dynamic> toMap();
}

/// **FACTORY INTERFACE** pour créer les instances de persistance
/// **Factory Pattern** + **DIP** : Permet d'injecter différentes implémentations
abstract class IPersistenceServiceFactory {
  /// Crée une instance du service de persistance unifié
  IUnifiedPersistenceService createPersistenceService({
    required ILogger logger,
    IPersistenceConfiguration? configuration,
  });
}

/// **EXCEPTION UNIFIÉE** pour toutes les erreurs de persistance
class UnifiedPersistenceException implements Exception {
  final String message;
  final String operation;
  final String? id;
  final Object? cause;
  final PersistenceMode? mode;

  const UnifiedPersistenceException(
    this.message, {
    required this.operation,
    this.id,
    this.cause,
    this.mode,
  });

  @override
  String toString() {
    final idInfo = id != null ? ' (id: $id)' : '';
    final modeInfo = mode != null ? ' in ${mode!.name} mode' : '';
    final causeInfo = cause != null ? ', caused by: $cause' : '';
    return 'UnifiedPersistenceException in $operation$idInfo$modeInfo: $message$causeInfo';
  }
}

/// **VALIDATION INTERFACE** pour la validation des données de persistance
abstract class IPersistenceValidator {
  /// Valide une liste avant persistance
  bool validateList(CustomList list);

  /// Valide un item avant persistance
  bool validateListItem(ListItem item);

  /// Assainit une liste de CustomList (supprime les doublons, corrige les données)
  List<CustomList> sanitizeLists(List<CustomList> lists);

  /// Assainit une liste d'items
  List<ListItem> sanitizeItems(List<ListItem> items);
}