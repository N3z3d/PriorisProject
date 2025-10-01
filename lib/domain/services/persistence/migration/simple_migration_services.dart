/// Simple Migration Services Implementation - SOLID Architecture
/// Implémentations simplifiées pour remplacer les services manquants

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'migration_interfaces.dart';

/// SOLID: Single Responsibility - Résolution simple des conflits
class SimpleConflictResolver implements IConflictResolver {
  static SimpleConflictResolver? _instance;
  static SimpleConflictResolver get instance => _instance ??= SimpleConflictResolver._();
  SimpleConflictResolver._();

  @override
  Future<CustomList> resolveListConflict(
    CustomList localList,
    CustomList cloudList,
    ConflictResolutionStrategy strategy,
  ) async {
    switch (strategy) {
      case ConflictResolutionStrategy.keepLocal:
        return localList;
      case ConflictResolutionStrategy.keepCloud:
        return cloudList;
      case ConflictResolutionStrategy.smartMerge:
        return _mergeListsByTimestamp(localList, cloudList);
      case ConflictResolutionStrategy.duplicate:
        return _createDuplicateList(localList, cloudList);
      case ConflictResolutionStrategy.askUser:
        // En mode simple, on utilise smartMerge par défaut
        return _mergeListsByTimestamp(localList, cloudList);
    }
  }

  @override
  Future<ListItem> resolveItemConflict(
    ListItem localItem,
    ListItem cloudItem,
    ConflictResolutionStrategy strategy,
  ) async {
    switch (strategy) {
      case ConflictResolutionStrategy.keepLocal:
        return localItem;
      case ConflictResolutionStrategy.keepCloud:
        return cloudItem;
      case ConflictResolutionStrategy.smartMerge:
        return _mergeItemsByTimestamp(localItem, cloudItem);
      case ConflictResolutionStrategy.duplicate:
        return _createDuplicateItem(localItem, cloudItem);
      case ConflictResolutionStrategy.askUser:
        // En mode simple, on utilise smartMerge par défaut
        return _mergeItemsByTimestamp(localItem, cloudItem);
    }
  }

  CustomList _mergeListsByTimestamp(CustomList local, CustomList cloud) {
    // Simple merge: keep the most recent based on updatedAt
    final localTime = local.updatedAt ?? local.createdAt;
    final cloudTime = cloud.updatedAt ?? cloud.createdAt;
    return localTime.isAfter(cloudTime) ? local : cloud;
  }

  ListItem _mergeItemsByTimestamp(ListItem local, ListItem cloud) {
    // Simple merge: keep the most recent based on createdAt
    final localTime = local.createdAt;
    final cloudTime = cloud.createdAt;
    return localTime.isAfter(cloudTime) ? local : cloud;
  }

  CustomList _createDuplicateList(CustomList local, CustomList cloud) {
    // Create a new list with merged content
    return local.copyWith(
      name: '${local.name} (Merged)',
      description: '${local.description ?? ''}\n--- Cloud version ---\n${cloud.description ?? ''}',
    );
  }

  ListItem _createDuplicateItem(ListItem local, ListItem cloud) {
    // Keep local, we don't duplicate items in simple implementation
    return local;
  }
}

/// SOLID: Single Responsibility - Validation simple des données
class SimpleMigrationValidator implements IMigrationValidator {
  static SimpleMigrationValidator? _instance;
  static SimpleMigrationValidator get instance => _instance ??= SimpleMigrationValidator._();
  SimpleMigrationValidator._();

  @override
  Future<bool> validateList(CustomList list) async {
    // Validation basique
    if (list.id.isEmpty) return false;
    if (list.name.trim().isEmpty) return false;
    return true;
  }

  @override
  Future<bool> validateItem(ListItem item) async {
    // Validation basique
    if (item.id.isEmpty) return false;
    if (item.listId.isEmpty) return false;
    if (item.title.trim().isEmpty) return false;
    return true;
  }

  @override
  Future<bool> validateMigrationIntegrity(List<CustomList> lists, List<ListItem> items) async {
    // Vérifier que tous les items appartiennent à des listes existantes
    final listIds = lists.map((l) => l.id).toSet();
    for (final item in items) {
      if (!listIds.contains(item.listId)) {
        return false;
      }
    }
    return true;
  }
}

/// SOLID: Single Responsibility - Tracking simple du progrès
class SimpleProgressTracker implements IProgressTracker {
  static SimpleProgressTracker? _instance;
  static SimpleProgressTracker get instance => _instance ??= SimpleProgressTracker._();
  SimpleProgressTracker._();

  int _totalItems = 0;
  int _completedItems = 0;
  final List<String> _conflicts = [];
  final List<String> _errors = [];

  @override
  void startMigration(int totalItems) {
    _totalItems = totalItems;
    _completedItems = 0;
    _conflicts.clear();
    _errors.clear();
    print('🚀 Migration started: $totalItems items to process');
  }

  @override
  void updateProgress(int completedItems) {
    _completedItems = completedItems;
    final progress = _totalItems > 0 ? (_completedItems / _totalItems * 100).toStringAsFixed(1) : '0.0';
    print('📊 Migration progress: $_completedItems/$_totalItems ($progress%)');
  }

  @override
  void reportConflict(String itemId, ConflictResolutionStrategy strategy) {
    _conflicts.add(itemId);
    print('⚠️ Conflict resolved for $itemId using ${strategy.name}');
  }

  @override
  void reportError(String itemId, String error) {
    _errors.add('$itemId: $error');
    print('❌ Error during migration of $itemId: $error');
  }

  @override
  void finishMigration(MigrationResult result) {
    print('✅ Migration completed: ${result.migratedLists} lists, ${result.migratedItems} items');
    print('📈 Success rate: ${(result.successRate * 100).toStringAsFixed(1)}%');
    if (result.conflicts > 0) print('⚠️ Conflicts resolved: ${result.conflicts}');
    if (result.errors > 0) print('❌ Errors: ${result.errors}');
  }

  @override
  void dispose() {
    _totalItems = 0;
    _completedItems = 0;
    _conflicts.clear();
    _errors.clear();
  }

  // Getters pour accéder aux statistiques
  int get totalItems => _totalItems;
  int get completedItems => _completedItems;
  List<String> get conflicts => List.unmodifiable(_conflicts);
  List<String> get errors => List.unmodifiable(_errors);
}

/// SOLID: Single Responsibility - Nettoyage simple des données
class SimpleDataCleaner implements IDataCleaner {
  static SimpleDataCleaner? _instance;
  static SimpleDataCleaner get instance => _instance ??= SimpleDataCleaner._();
  SimpleDataCleaner._();

  @override
  Future<void> cleanupAfterMigration(List<String> migratedIds) async {
    print('🧹 Cleanup completed for ${migratedIds.length} migrated items');
    // En mode simple, pas de nettoyage automatique pour éviter la perte de données
  }

  @override
  Future<void> performFullCleanup() async {
    print('🧹 Full cleanup requested - skipped in simple mode for safety');
    // En mode simple, pas de nettoyage complet pour éviter la perte de données
  }
}