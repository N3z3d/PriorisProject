/// SOLID Persistence Interfaces
/// Following Interface Segregation Principle - separate interfaces for different concerns

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

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

/// Interface pour la gestion de l'état d'authentification
abstract class IAuthenticationStateManager {
  /// État d'authentification actuel
  bool get isAuthenticated;

  /// Mode de persistance actuel
  PersistenceMode get currentMode;

  /// Initialise le gestionnaire d'état avec l'état d'authentification actuel
  Future<void> initialize({required bool isAuthenticated});

  /// Met à jour l'état d'authentification
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  });

  /// Écoute les changements d'état d'authentification
  Stream<bool> get authenticationStateStream;
}

/// Interface pour la migration des données
abstract class IDataMigrationService {
  /// Gère la transition Invité → Connecté
  Future<void> migrateToCloud({
    required MigrationStrategy strategy,
    required List<CustomList> localLists,
  });

  /// Gère la transition Connecté → Invité
  Future<void> migrateToLocal({
    required List<CustomList> cloudLists,
  });

  /// Résout les conflits de fusion
  CustomList resolveListConflict(CustomList local, CustomList cloud);

  /// Résout les conflits d'items
  ListItem resolveItemConflict(ListItem existing, ListItem incoming);
}

/// Interface pour la synchronisation des données
abstract class ISyncService {
  /// Synchronise une liste vers le cloud en arrière-plan
  void syncListToCloudAsync(CustomList list);

  /// Synchronise les listes du cloud vers le local
  void syncCloudToLocalAsync(List<CustomList> cloudLists);

  /// Synchronise un item vers le cloud
  void syncItemToCloudAsync(ListItem item);

  /// Synchronise les items vers le local
  void syncItemsToLocalAsync(String listId, List<ListItem> items);
}

/// Interface pour la déduplication des données
abstract class IDeduplicationService {
  /// Déduplique une liste de CustomList par ID
  List<CustomList> deduplicateLists(List<CustomList> lists);

  /// Sauvegarde avec gestion des doublons
  Future<void> saveListWithDeduplication(
    CustomList list,
    Future<void> Function(CustomList) saveOperation,
    Future<CustomList?> Function(String) getExistingOperation,
    Future<void> Function(CustomList) updateOperation,
  );

  /// Sauvegarde d'item avec gestion des doublons
  Future<void> saveItemWithDeduplication(
    ListItem item,
    Future<void> Function(ListItem) addOperation,
    Future<ListItem?> Function(String) getByIdOperation,
    Future<void> Function(ListItem) updateOperation,
  );
}

/// Interface pour la gestion des erreurs de permission
abstract class IPermissionErrorHandler {
  /// Gère les erreurs de permission cloud
  void handleCloudPermissionError(String operation, String id, dynamic error);

  /// Assainit les messages d'erreur pour l'utilisateur
  String sanitizeErrorMessage(String error);

  /// Log les erreurs de permission pour monitoring
  void logPermissionError(String operation, String id, String error);

  /// Suppression cloud avec gestion d'erreur de permission
  void deleteFromCloudWithErrorHandling(
    String id,
    Future<void> Function(String) deleteOperation,
  );
}

/// Interface principale pour le coordinateur de persistance
abstract class IPersistenceCoordinator {
  /// Mode de persistance actuel
  PersistenceMode get currentMode;

  /// État d'authentification
  bool get isAuthenticated;

  /// Initialise le service avec l'état d'authentification
  Future<void> initialize({required bool isAuthenticated});

  /// Met à jour l'état d'authentification et adapte la persistance
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  });

  /// Récupère toutes les listes selon le mode actuel
  Future<List<CustomList>> getAllLists();

  /// Sauvegarde une liste selon le mode actuel
  Future<void> saveList(CustomList list);

  /// Supprime une liste selon le mode actuel
  Future<void> deleteList(String listId);

  /// Récupère tous les items d'une liste selon le mode actuel
  Future<List<ListItem>> getItemsByListId(String listId);

  /// Sauvegarde un item selon le mode actuel
  Future<void> saveItem(ListItem item);

  /// Met à jour un item selon le mode actuel
  Future<void> updateItem(ListItem item);

  /// Supprime un item selon le mode actuel
  Future<void> deleteItem(String itemId);

  /// Nettoie les ressources
  void dispose();
}

/// Configuration pour le système de persistance
class PersistenceConfiguration {
  final PersistenceMode defaultMode;
  final MigrationStrategy defaultMigrationStrategy;
  final bool enableBackgroundSync;
  final bool enableDeduplication;
  final Duration syncTimeout;
  final int maxRetries;

  const PersistenceConfiguration({
    this.defaultMode = PersistenceMode.localFirst,
    this.defaultMigrationStrategy = MigrationStrategy.intelligentMerge,
    this.enableBackgroundSync = true,
    this.enableDeduplication = true,
    this.syncTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
  });

  PersistenceConfiguration copyWith({
    PersistenceMode? defaultMode,
    MigrationStrategy? defaultMigrationStrategy,
    bool? enableBackgroundSync,
    bool? enableDeduplication,
    Duration? syncTimeout,
    int? maxRetries,
  }) {
    return PersistenceConfiguration(
      defaultMode: defaultMode ?? this.defaultMode,
      defaultMigrationStrategy: defaultMigrationStrategy ?? this.defaultMigrationStrategy,
      enableBackgroundSync: enableBackgroundSync ?? this.enableBackgroundSync,
      enableDeduplication: enableDeduplication ?? this.enableDeduplication,
      syncTimeout: syncTimeout ?? this.syncTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultMode': defaultMode.name,
      'defaultMigrationStrategy': defaultMigrationStrategy.name,
      'enableBackgroundSync': enableBackgroundSync,
      'enableDeduplication': enableDeduplication,
      'syncTimeoutSeconds': syncTimeout.inSeconds,
      'maxRetries': maxRetries,
    };
  }
}

/// Exception pour les erreurs de persistance
class PersistenceException implements Exception {
  final String message;
  final String operation;
  final String? id;
  final Object? cause;

  const PersistenceException(
    this.message, {
    required this.operation,
    this.id,
    this.cause,
  });

  @override
  String toString() {
    final idInfo = id != null ? ' (id: $id)' : '';
    final causeInfo = cause != null ? ', caused by: $cause' : '';
    return 'PersistenceException in $operation$idInfo: $message$causeInfo';
  }
}