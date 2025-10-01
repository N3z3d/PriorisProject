/// Migration Service Interfaces - SOLID Architecture
/// Définit les contrats pour les services de migration selon DIP

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Stratégies de résolution des conflits lors de la migration
enum ConflictResolutionStrategy {
  /// Garder la version locale en cas de conflit
  keepLocal,

  /// Garder la version cloud en cas de conflit
  keepCloud,

  /// Fusionner intelligemment basé sur les timestamps
  smartMerge,

  /// Créer des copies pour éviter la perte de données
  duplicate,

  /// Demander à l'utilisateur de choisir
  askUser,
}

/// Stratégies de migration
enum MigrationStrategy {
  localToCloud,
  cloudToLocal,
  bidirectionalSync,
}

/// Configuration pour la migration des données
class MigrationConfig {
  final ConflictResolutionStrategy conflictStrategy;
  final bool deleteLocalAfterMigration;
  final bool enableProgressTracking;
  final Duration timeout;
  final int batchSize;

  const MigrationConfig({
    this.conflictStrategy = ConflictResolutionStrategy.smartMerge,
    this.deleteLocalAfterMigration = false,
    this.enableProgressTracking = true,
    this.timeout = const Duration(minutes: 10),
    this.batchSize = 50,
  });
}

/// Résultat d'une migration
class MigrationResult {
  final int migratedLists;
  final int migratedItems;
  final int conflicts;
  final int errors;
  final Duration duration;
  final List<String> errorMessages;
  final Map<String, dynamic> statistics;

  const MigrationResult({
    required this.migratedLists,
    required this.migratedItems,
    required this.conflicts,
    required this.errors,
    required this.duration,
    this.errorMessages = const [],
    this.statistics = const {},
  });

  bool get isSuccess => errors == 0;
  double get successRate => (migratedLists + migratedItems) > 0
      ? (migratedLists + migratedItems - errors) / (migratedLists + migratedItems)
      : 1.0;
}

/// SOLID: Interface Segregation - Interface spécialisée pour la résolution de conflits
abstract class IConflictResolver {
  Future<CustomList> resolveListConflict(
    CustomList localList,
    CustomList cloudList,
    ConflictResolutionStrategy strategy,
  );

  Future<ListItem> resolveItemConflict(
    ListItem localItem,
    ListItem cloudItem,
    ConflictResolutionStrategy strategy,
  );
}

/// SOLID: Interface Segregation - Interface spécialisée pour la validation
abstract class IMigrationValidator {
  Future<bool> validateList(CustomList list);
  Future<bool> validateItem(ListItem item);
  Future<bool> validateMigrationIntegrity(List<CustomList> lists, List<ListItem> items);
}

/// SOLID: Interface Segregation - Interface spécialisée pour le tracking du progrès
abstract class IProgressTracker {
  void startMigration(int totalItems);
  void updateProgress(int completedItems);
  void reportConflict(String itemId, ConflictResolutionStrategy strategy);
  void reportError(String itemId, String error);
  void finishMigration(MigrationResult result);
  void dispose();

  // Getters pour accéder aux statistiques
  int get totalItems;
  int get completedItems;
  List<String> get conflicts;
  List<String> get errors;
}

/// SOLID: Interface Segregation - Interface spécialisée pour le nettoyage des données
abstract class IDataCleaner {
  Future<void> cleanupAfterMigration(List<String> migratedIds);
  Future<void> performFullCleanup();
}

/// Callbacks pour suivre le progrès de la migration
abstract class MigrationProgressCallback {
  void onMigrationStarted(int totalItems);
  void onItemMigrated(String itemType, String itemId);
  void onConflictResolved(String itemType, String itemId, ConflictResolutionStrategy strategy);
  void onError(String itemType, String itemId, String error);
  void onMigrationCompleted(MigrationResult result);
}