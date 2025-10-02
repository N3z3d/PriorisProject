/// Data Migration Service
/// Single Responsibility: Handle data migration between local and cloud storage

import '../ports/persistence_interfaces.dart';
import '../../domain/models/core/entities/custom_list.dart';
import '../../domain/models/core/entities/list_item.dart';
import '../../data/repositories/custom_list_repository.dart';
import '../../infrastructure/services/logger_service.dart';

/// SOLID implementation of data migration
/// Follows Single Responsibility Principle - only handles migrations
class DataMigrationService implements IDataMigrationService {
  final CustomListRepository _localRepository;
  final CustomListRepository _cloudRepository;

  DataMigrationService({
    required CustomListRepository localRepository,
    required CustomListRepository cloudRepository,
  }) : _localRepository = localRepository,
       _cloudRepository = cloudRepository;

  @override
  Future<void> migrateToCloud({
    required MigrationStrategy strategy,
    required List<CustomList> localLists,
  }) async {
    LoggerService.instance.info(
      'Starting migration to cloud with strategy: $strategy',
      context: 'DataMigrationService',
    );

    if (localLists.isEmpty) {
      LoggerService.instance.info('No local data to migrate', context: 'DataMigrationService');
      return;
    }

    LoggerService.instance.info(
      'Migrating ${localLists.length} lists to cloud',
      context: 'DataMigrationService',
    );

    try {
      switch (strategy) {
        case MigrationStrategy.migrateAll:
          await _migrateAllDataToCloud(localLists);
          break;

        case MigrationStrategy.intelligentMerge:
          await _intelligentMergeToCloud(localLists);
          break;

        case MigrationStrategy.cloudOnly:
          // Don't migrate anything, use only cloud data
          LoggerService.instance.info(
            'Cloud-only strategy selected, skipping migration',
            context: 'DataMigrationService',
          );
          break;

        case MigrationStrategy.askUser:
          // TODO: Implement user dialog
          // For now, default to intelligent merge
          await _intelligentMergeToCloud(localLists);
          break;
      }

      LoggerService.instance.info('Migration completed successfully', context: 'DataMigrationService');
    } catch (e) {
      LoggerService.instance.error(
        'Migration failed',
        context: 'DataMigrationService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> migrateToLocal({
    required List<CustomList> cloudLists,
  }) async {
    LoggerService.instance.info(
      'Starting migration to local with ${cloudLists.length} lists',
      context: 'DataMigrationService',
    );

    try {
      for (final list in cloudLists) {
        await _localRepository.saveList(list);
      }

      LoggerService.instance.info(
        'Successfully migrated ${cloudLists.length} lists to local storage',
        context: 'DataMigrationService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to migrate to local storage',
        context: 'DataMigrationService',
        error: e,
      );
      // Continue with existing local data if migration fails
    }
  }

  @override
  CustomList resolveListConflict(CustomList local, CustomList cloud) {
    LoggerService.instance.debug(
      'Resolving conflict for list "${local.name}" (${local.id})',
      context: 'DataMigrationService',
    );

    // Use the list with the most recent modification date
    if (local.updatedAt.isAfter(cloud.updatedAt)) {
      LoggerService.instance.debug('Local version is more recent', context: 'DataMigrationService');
      return local;
    } else {
      LoggerService.instance.debug('Cloud version is more recent or equal', context: 'DataMigrationService');
      return cloud;
    }
  }

  @override
  ListItem resolveItemConflict(ListItem existing, ListItem incoming) {
    LoggerService.instance.debug(
      'Resolving item conflict for "${existing.title}" (${existing.id})',
      context: 'DataMigrationService',
    );

    // Use the item with the most recent creation date (items don't always have updatedAt)
    if (existing.createdAt.isAfter(incoming.createdAt)) {
      LoggerService.instance.debug('Existing item is more recent', context: 'DataMigrationService');
      return existing;
    } else if (incoming.createdAt.isAfter(existing.createdAt)) {
      LoggerService.instance.debug('Incoming item is more recent', context: 'DataMigrationService');
      return incoming;
    } else {
      // Equal timestamps, prefer incoming (default behavior)
      LoggerService.instance.debug('Equal timestamps, preferring incoming', context: 'DataMigrationService');
      return incoming;
    }
  }

  /// Migration complète vers le cloud
  Future<void> _migrateAllDataToCloud(List<CustomList> localLists) async {
    LoggerService.instance.info('Starting full migration to cloud', context: 'DataMigrationService');

    int successCount = 0;
    int errorCount = 0;

    for (final list in localLists) {
      try {
        await _cloudRepository.saveList(list);
        successCount++;
        LoggerService.instance.debug('Migrated list "${list.name}"', context: 'DataMigrationService');
      } catch (e) {
        errorCount++;
        LoggerService.instance.error(
          'Failed to migrate list "${list.name}"',
          context: 'DataMigrationService',
          error: e,
        );
      }
    }

    LoggerService.instance.info(
      'Migration summary: $successCount succeeded, $errorCount failed',
      context: 'DataMigrationService',
    );

    if (errorCount > 0 && successCount == 0) {
      throw PersistenceException(
        'All migration attempts failed',
        operation: 'migrateAllDataToCloud',
      );
    }
  }

  /// Migration intelligente avec fusion des données
  Future<void> _intelligentMergeToCloud(List<CustomList> localLists) async {
    LoggerService.instance.info('Starting intelligent merge to cloud', context: 'DataMigrationService');

    try {
      final cloudLists = await _cloudRepository.getAllLists();
      final cloudListsMap = {for (var list in cloudLists) list.id: list};

      int newListsCount = 0;
      int mergedListsCount = 0;

      for (final localList in localLists) {
        final cloudList = cloudListsMap[localList.id];

        if (cloudList == null) {
          // New local list → migrate to cloud
          await _cloudRepository.saveList(localList);
          newListsCount++;
          LoggerService.instance.debug('New list "${localList.name}" migrated to cloud', context: 'DataMigrationService');
        } else {
          // Conflict → resolve with the most recent
          final mergedList = resolveListConflict(localList, cloudList);
          await _cloudRepository.saveList(mergedList);
          mergedListsCount++;
          LoggerService.instance.debug('List "${mergedList.name}" merged', context: 'DataMigrationService');
        }
      }

      LoggerService.instance.info(
        'Intelligent merge completed: $newListsCount new lists, $mergedListsCount merged',
        context: 'DataMigrationService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Intelligent merge failed',
        context: 'DataMigrationService',
        error: e,
      );
      rethrow;
    }
  }

  /// Create migration summary report
  Map<String, dynamic> createMigrationReport({
    required MigrationStrategy strategy,
    required int totalItems,
    required int successCount,
    required int errorCount,
    required Duration duration,
  }) {
    return {
      'strategy': strategy.name,
      'totalItems': totalItems,
      'successCount': successCount,
      'errorCount': errorCount,
      'successRate': totalItems > 0 ? (successCount / totalItems * 100).toStringAsFixed(1) : '0.0',
      'durationMs': duration.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      final localLists = await _localRepository.getAllLists();
      return localLists.isNotEmpty;
    } catch (e) {
      LoggerService.instance.error(
        'Failed to check migration need',
        context: 'DataMigrationService',
        error: e,
      );
      return false;
    }
  }

  /// Get migration statistics
  Future<Map<String, dynamic>> getMigrationStats() async {
    try {
      final localLists = await _localRepository.getAllLists();
      final cloudLists = await _cloudRepository.getAllLists();

      return {
        'localListsCount': localLists.length,
        'cloudListsCount': cloudLists.length,
        'hasLocalData': localLists.isNotEmpty,
        'hasCloudData': cloudLists.isNotEmpty,
        'potentialConflicts': _calculatePotentialConflicts(localLists, cloudLists),
      };
    } catch (e) {
      LoggerService.instance.error(
        'Failed to get migration stats',
        context: 'DataMigrationService',
        error: e,
      );
      return {
        'error': e.toString(),
        'localListsCount': 0,
        'cloudListsCount': 0,
        'hasLocalData': false,
        'hasCloudData': false,
        'potentialConflicts': 0,
      };
    }
  }

  int _calculatePotentialConflicts(List<CustomList> localLists, List<CustomList> cloudLists) {
    final cloudIds = cloudLists.map((list) => list.id).toSet();
    return localLists.where((list) => cloudIds.contains(list.id)).length;
  }
}