import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

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

  MigrationResult({
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

/// Callbacks pour suivre le progrès de la migration
abstract class MigrationProgressCallback {
  void onMigrationStarted(int totalItems);
  void onItemMigrated(String itemType, String itemId);
  void onConflictResolved(String itemType, String itemId, ConflictResolutionStrategy strategy);
  void onError(String itemType, String itemId, String error);
  void onMigrationCompleted(MigrationResult result);
}

/// Service avancé pour la migration intelligente des données
/// 
/// Gère la migration robuste des données entre repositories local et cloud
/// avec résolution automatique des conflits et tracking du progrès.
class DataMigrationService {
  final CustomListRepository _localRepository;
  final CustomListRepository _cloudRepository;
  final ListItemRepository _localItemRepository;
  final ListItemRepository _cloudItemRepository;
  
  MigrationProgressCallback? _progressCallback;

  DataMigrationService({
    required CustomListRepository localRepository,
    required CustomListRepository cloudRepository,
    required ListItemRepository localItemRepository,
    required ListItemRepository cloudItemRepository,
  }) : _localRepository = localRepository,
       _cloudRepository = cloudRepository,
       _localItemRepository = localItemRepository,
       _cloudItemRepository = cloudItemRepository;

  /// Définit le callback de progression
  void setProgressCallback(MigrationProgressCallback? callback) {
    _progressCallback = callback;
  }

  /// Migration complète des données locales vers le cloud
  Future<MigrationResult> migrateLocalToCloud({
    MigrationConfig config = const MigrationConfig(),
  }) async {
    print('🚀 Début migration locale → cloud');
    final stopwatch = Stopwatch()..start();
    
    int migratedLists = 0;
    int migratedItems = 0;
    int conflicts = 0;
    int errors = 0;
    final errorMessages = <String>[];
    final statistics = <String, dynamic>{};

    try {
      // Phase 1: Récupérer toutes les données
      final localLists = await _localRepository.getAllLists();
      final cloudLists = await _cloudRepository.getAllLists();
      
      print('📊 Données trouvées - Local: ${localLists.length} listes, Cloud: ${cloudLists.length} listes');
      
      // Créer une map des listes cloud pour comparaison rapide
      final cloudListsMap = {for (var list in cloudLists) list.id: list};
      
      // Calculer le total d'items pour le tracking
      int totalItems = localLists.length;
      for (final list in localLists) {
        final items = await _localItemRepository.getByListId(list.id);
        totalItems += items.length;
      }
      
      _progressCallback?.onMigrationStarted(totalItems);

      // Phase 2: Migrer les listes avec résolution des conflits
      for (final localList in localLists) {
        try {
          final cloudList = cloudListsMap[localList.id];
          final result = await _migrateList(localList, cloudList, config);
          
          if (result.migrated) {
            migratedLists++;
            _progressCallback?.onItemMigrated('list', localList.id);
          }
          
          if (result.wasConflict) {
            conflicts++;
            _progressCallback?.onConflictResolved('list', localList.id, config.conflictStrategy);
          }
          
        } catch (e) {
          errors++;
          final errorMsg = 'Erreur migration liste ${localList.id}: $e';
          errorMessages.add(errorMsg);
          _progressCallback?.onError('list', localList.id, e.toString());
          print('❌ $errorMsg');
        }
      }

      // Phase 3: Migrer les items
      for (final localList in localLists) {
        try {
          final localItems = await _localItemRepository.getByListId(localList.id);
          final cloudItems = await _cloudItemRepository.getByListId(localList.id);
          
          final result = await _migrateItems(localItems, cloudItems, config);
          migratedItems += result.migrated;
          conflicts += result.conflicts;
          errors += result.errors;
          
        } catch (e) {
          errors++;
          errorMessages.add('Erreur migration items pour liste ${localList.id}: $e');
        }
      }

      // Phase 4: Nettoyage optionnel
      if (config.deleteLocalAfterMigration && errors == 0) {
        await _cleanupLocalData();
        statistics['localDataCleaned'] = true;
      }

      stopwatch.stop();
      
      final result = MigrationResult(
        migratedLists: migratedLists,
        migratedItems: migratedItems,
        conflicts: conflicts,
        errors: errors,
        duration: stopwatch.elapsed,
        errorMessages: errorMessages,
        statistics: {
          ...statistics,
          'totalLocalLists': localLists.length,
          'totalCloudLists': cloudLists.length,
          'conflictResolutionStrategy': config.conflictStrategy.name,
          'successRate': errors == 0 ? 1.0 : (migratedLists + migratedItems - errors) / (migratedLists + migratedItems),
        },
      );

      _progressCallback?.onMigrationCompleted(result);
      
      print('✅ Migration terminée - Listes: $migratedLists, Items: $migratedItems, Conflits: $conflicts, Erreurs: $errors');
      return result;
      
    } catch (e) {
      stopwatch.stop();
      print('💥 Erreur critique de migration: $e');
      
      final result = MigrationResult(
        migratedLists: migratedLists,
        migratedItems: migratedItems,
        conflicts: conflicts,
        errors: errors + 1,
        duration: stopwatch.elapsed,
        errorMessages: [...errorMessages, 'Erreur critique: $e'],
      );
      
      _progressCallback?.onMigrationCompleted(result);
      return result;
    }
  }

  /// Migration des données cloud vers local (pour mode offline)
  Future<MigrationResult> migrateCloudToLocal({
    MigrationConfig config = const MigrationConfig(),
  }) async {
    print('⬇️ Début migration cloud → local');
    final stopwatch = Stopwatch()..start();
    
    int migratedLists = 0;
    int migratedItems = 0;
    int conflicts = 0;
    int errors = 0;
    final errorMessages = <String>[];

    try {
      // Récupérer les données cloud
      final cloudLists = await _cloudRepository.getAllLists();
      final localLists = await _localRepository.getAllLists();
      
      final localListsMap = {for (var list in localLists) list.id: list};
      
      int totalItems = cloudLists.length;
      for (final list in cloudLists) {
        final items = await _cloudItemRepository.getByListId(list.id);
        totalItems += items.length;
      }
      
      _progressCallback?.onMigrationStarted(totalItems);

      // Migrer les listes
      for (final cloudList in cloudLists) {
        try {
          final localList = localListsMap[cloudList.id];
          final result = await _migrateList(cloudList, localList, config, toCloud: false);
          
          if (result.migrated) {
            migratedLists++;
            _progressCallback?.onItemMigrated('list', cloudList.id);
          }
          
          if (result.wasConflict) {
            conflicts++;
            _progressCallback?.onConflictResolved('list', cloudList.id, config.conflictStrategy);
          }
          
        } catch (e) {
          errors++;
          errorMessages.add('Erreur migration liste ${cloudList.id}: $e');
          _progressCallback?.onError('list', cloudList.id, e.toString());
        }
      }

      // Migrer les items
      for (final cloudList in cloudLists) {
        try {
          final cloudItems = await _cloudItemRepository.getByListId(cloudList.id);
          final localItems = await _localItemRepository.getByListId(cloudList.id);
          
          final result = await _migrateItems(cloudItems, localItems, config, toCloud: false);
          migratedItems += result.migrated;
          conflicts += result.conflicts;
          errors += result.errors;
          
        } catch (e) {
          errors++;
          errorMessages.add('Erreur migration items pour liste ${cloudList.id}: $e');
        }
      }

      stopwatch.stop();
      
      final result = MigrationResult(
        migratedLists: migratedLists,
        migratedItems: migratedItems,
        conflicts: conflicts,
        errors: errors,
        duration: stopwatch.elapsed,
        errorMessages: errorMessages,
        statistics: {
          'direction': 'cloud-to-local',
          'totalCloudLists': cloudLists.length,
          'totalLocalLists': localLists.length,
        },
      );
      
      _progressCallback?.onMigrationCompleted(result);
      return result;
      
    } catch (e) {
      stopwatch.stop();
      return MigrationResult(
        migratedLists: migratedLists,
        migratedItems: migratedItems,
        conflicts: conflicts,
        errors: errors + 1,
        duration: stopwatch.elapsed,
        errorMessages: [...errorMessages, 'Erreur critique: $e'],
      );
    }
  }

  /// Synchronisation bidirectionnelle intelligente
  Future<MigrationResult> bidirectionalSync({
    MigrationConfig config = const MigrationConfig(),
  }) async {
    print('🔄 Début synchronisation bidirectionnelle');
    final stopwatch = Stopwatch()..start();
    
    int migratedLists = 0;
    int migratedItems = 0;
    int conflicts = 0;
    int errors = 0;
    final errorMessages = <String>[];

    try {
      final localLists = await _localRepository.getAllLists();
      final cloudLists = await _cloudRepository.getAllLists();
      
      // Créer des maps pour comparaison
      final localListsMap = {for (var list in localLists) list.id: list};
      final cloudListsMap = {for (var list in cloudLists) list.id: list};
      
      // Trouver tous les IDs uniques
      final allListIds = {...localListsMap.keys, ...cloudListsMap.keys};
      
      _progressCallback?.onMigrationStarted(allListIds.length * 2); // Lists + items
      
      // Synchroniser chaque liste
      for (final listId in allListIds) {
        final localList = localListsMap[listId];
        final cloudList = cloudListsMap[listId];
        
        try {
          // Synchroniser la liste elle-même
          final listResult = await _syncList(localList, cloudList, config);
          if (listResult.migrated) migratedLists++;
          if (listResult.wasConflict) conflicts++;
          
          // Synchroniser les items
          final localItems = localList != null 
              ? await _localItemRepository.getByListId(listId) 
              : <ListItem>[];
          final cloudItems = cloudList != null 
              ? await _cloudItemRepository.getByListId(listId) 
              : <ListItem>[];
              
          final itemsResult = await _syncItems(localItems, cloudItems, config);
          migratedItems += itemsResult.migrated;
          conflicts += itemsResult.conflicts;
          errors += itemsResult.errors;
          
        } catch (e) {
          errors++;
          errorMessages.add('Erreur sync liste $listId: $e');
        }
      }
      
      stopwatch.stop();
      
      return MigrationResult(
        migratedLists: migratedLists,
        migratedItems: migratedItems,
        conflicts: conflicts,
        errors: errors,
        duration: stopwatch.elapsed,
        errorMessages: errorMessages,
        statistics: {
          'syncType': 'bidirectional',
          'totalListIds': allListIds.length,
        },
      );
      
    } catch (e) {
      stopwatch.stop();
      return MigrationResult(
        migratedLists: 0,
        migratedItems: 0,
        conflicts: 0,
        errors: 1,
        duration: stopwatch.elapsed,
        errorMessages: ['Erreur critique sync: $e'],
      );
    }
  }

  /// Vérifie l'intégrité des données après migration
  Future<Map<String, dynamic>> verifyDataIntegrity() async {
    print('🔍 Vérification de l\'intégrité des données');
    
    try {
      final localLists = await _localRepository.getAllLists();
      final cloudLists = await _cloudRepository.getAllLists();
      
      final results = <String, dynamic>{
        'localListsCount': localLists.length,
        'cloudListsCount': cloudLists.length,
        'inconsistencies': <String>[],
        'orphanedItems': <String>[],
        'duplicates': <String>[],
      };
      
      // Vérifier les orphelins et inconsistances
      for (final list in localLists) {
        final localItems = await _localItemRepository.getByListId(list.id);
        final cloudItems = await _cloudItemRepository.getByListId(list.id);
        
        if (localItems.length != cloudItems.length) {
          results['inconsistencies'].add(
            'Liste ${list.name}: ${localItems.length} items local vs ${cloudItems.length} items cloud'
          );
        }
        
        // Chercher les items orphelins
        for (final item in localItems) {
          if (!cloudItems.any((ci) => ci.id == item.id)) {
            results['orphanedItems'].add('Item ${item.title} (${item.id}) existe en local mais pas en cloud');
          }
        }
      }
      
      return results;
      
    } catch (e) {
      return {
        'error': 'Erreur lors de la vérification: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // ========== Méthodes privées ==========

  Future<_MigrationItemResult> _migrateList(
    CustomList sourceList, 
    CustomList? targetList, 
    MigrationConfig config, {
    bool toCloud = true,
  }) async {
    if (targetList == null) {
      // Pas de conflit, migration directe
      if (toCloud) {
        await _cloudRepository.saveList(sourceList);
      } else {
        await _localRepository.saveList(sourceList);
      }
      return _MigrationItemResult(migrated: true, wasConflict: false);
    }
    
    // Conflit détecté, appliquer la stratégie
    final resolvedList = await _resolveListConflict(sourceList, targetList, config);
    if (resolvedList != null) {
      if (toCloud) {
        await _cloudRepository.saveList(resolvedList);
      } else {
        await _localRepository.saveList(resolvedList);
      }
      return _MigrationItemResult(migrated: true, wasConflict: true);
    }
    
    return _MigrationItemResult(migrated: false, wasConflict: true);
  }

  Future<_MigrationBatchResult> _migrateItems(
    List<ListItem> sourceItems,
    List<ListItem> targetItems, 
    MigrationConfig config, {
    bool toCloud = true,
  }) async {
    final targetItemsMap = {for (var item in targetItems) item.id: item};
    int migrated = 0;
    int conflicts = 0;
    int errors = 0;

    for (final sourceItem in sourceItems) {
      try {
        final targetItem = targetItemsMap[sourceItem.id];
        
        if (targetItem == null) {
          // Pas de conflit
          if (toCloud) {
            await _cloudItemRepository.add(sourceItem);
          } else {
            await _localItemRepository.add(sourceItem);
          }
          migrated++;
          _progressCallback?.onItemMigrated('item', sourceItem.id);
        } else {
          // Conflit
          final resolvedItem = await _resolveItemConflict(sourceItem, targetItem, config);
          if (resolvedItem != null) {
            if (toCloud) {
              await _cloudItemRepository.update(resolvedItem);
            } else {
              await _localItemRepository.update(resolvedItem);
            }
            migrated++;
            conflicts++;
            _progressCallback?.onConflictResolved('item', sourceItem.id, config.conflictStrategy);
          }
        }
      } catch (e) {
        errors++;
        _progressCallback?.onError('item', sourceItem.id, e.toString());
      }
    }

    return _MigrationBatchResult(
      migrated: migrated,
      conflicts: conflicts,
      errors: errors,
    );
  }

  Future<_MigrationItemResult> _syncList(
    CustomList? localList,
    CustomList? cloudList,
    MigrationConfig config,
  ) async {
    if (localList == null && cloudList == null) {
      return _MigrationItemResult(migrated: false, wasConflict: false);
    }
    
    if (localList == null) {
      // Existe seulement en cloud, copier vers local
      await _localRepository.saveList(cloudList!);
      return _MigrationItemResult(migrated: true, wasConflict: false);
    }
    
    if (cloudList == null) {
      // Existe seulement en local, copier vers cloud
      await _cloudRepository.saveList(localList);
      return _MigrationItemResult(migrated: true, wasConflict: false);
    }
    
    // Existe des deux côtés, résoudre le conflit
    final resolved = await _resolveListConflict(localList, cloudList, config);
    if (resolved != null) {
      await _localRepository.saveList(resolved);
      await _cloudRepository.saveList(resolved);
      return _MigrationItemResult(migrated: true, wasConflict: true);
    }
    
    return _MigrationItemResult(migrated: false, wasConflict: true);
  }

  Future<_MigrationBatchResult> _syncItems(
    List<ListItem> localItems,
    List<ListItem> cloudItems,
    MigrationConfig config,
  ) async {
    final localItemsMap = {for (var item in localItems) item.id: item};
    final cloudItemsMap = {for (var item in cloudItems) item.id: item};
    final allItemIds = {...localItemsMap.keys, ...cloudItemsMap.keys};
    
    int migrated = 0;
    int conflicts = 0;
    int errors = 0;

    for (final itemId in allItemIds) {
      try {
        final localItem = localItemsMap[itemId];
        final cloudItem = cloudItemsMap[itemId];
        
        if (localItem == null) {
          // Existe seulement en cloud
          await _localItemRepository.add(cloudItem!);
          migrated++;
        } else if (cloudItem == null) {
          // Existe seulement en local
          await _cloudItemRepository.add(localItem);
          migrated++;
        } else {
          // Conflit
          final resolved = await _resolveItemConflict(localItem, cloudItem, config);
          if (resolved != null) {
            await _localItemRepository.update(resolved);
            await _cloudItemRepository.update(resolved);
            migrated++;
            conflicts++;
          }
        }
      } catch (e) {
        errors++;
      }
    }

    return _MigrationBatchResult(
      migrated: migrated,
      conflicts: conflicts,
      errors: errors,
    );
  }

  Future<CustomList?> _resolveListConflict(
    CustomList list1,
    CustomList list2,
    MigrationConfig config,
  ) async {
    switch (config.conflictStrategy) {
      case ConflictResolutionStrategy.keepLocal:
        return list1;
      case ConflictResolutionStrategy.keepCloud:
        return list2;
      case ConflictResolutionStrategy.smartMerge:
        return _smartMergeLists(list1, list2);
      case ConflictResolutionStrategy.duplicate:
        // Créer une copie avec un nouvel ID
        final duplicatedList = list1.copyWith(
          id: '${list1.id}_duplicate_${DateTime.now().millisecondsSinceEpoch}',
          name: '${list1.name} (Copie)',
        );
        return duplicatedList;
      case ConflictResolutionStrategy.askUser:
        // TODO: Implémenter l'interface utilisateur
        return _smartMergeLists(list1, list2);
    }
  }

  Future<ListItem?> _resolveItemConflict(
    ListItem item1,
    ListItem item2,
    MigrationConfig config,
  ) async {
    switch (config.conflictStrategy) {
      case ConflictResolutionStrategy.keepLocal:
        return item1;
      case ConflictResolutionStrategy.keepCloud:
        return item2;
      case ConflictResolutionStrategy.smartMerge:
        return _smartMergeItems(item1, item2);
      case ConflictResolutionStrategy.duplicate:
        return item1.copyWith(
          id: '${item1.id}_duplicate_${DateTime.now().millisecondsSinceEpoch}',
        );
      case ConflictResolutionStrategy.askUser:
        return _smartMergeItems(item1, item2);
    }
  }

  CustomList _smartMergeLists(CustomList list1, CustomList list2) {
    // Utiliser la liste avec la date de modification la plus récente
    if (list1.updatedAt.isAfter(list2.updatedAt)) {
      return list1;
    } else if (list2.updatedAt.isAfter(list1.updatedAt)) {
      return list2;
    } else {
      // Même date, fusionner intelligemment
      return list1.copyWith(
        name: list1.name.isNotEmpty ? list1.name : list2.name,
        description: list1.description?.isNotEmpty == true 
            ? list1.description 
            : list2.description,
        updatedAt: DateTime.now(),
      );
    }
  }

  ListItem _smartMergeItems(ListItem item1, ListItem item2) {
    // Utiliser l'item le plus récent basé sur les dates disponibles
    // Priorité: completedAt > lastChosenAt > createdAt
    final item1RecentDate = item1.completedAt ?? item1.lastChosenAt ?? item1.createdAt;
    final item2RecentDate = item2.completedAt ?? item2.lastChosenAt ?? item2.createdAt;
    
    if (item1RecentDate.isAfter(item2RecentDate)) {
      return item1;
    } else if (item2RecentDate.isAfter(item1RecentDate)) {
      return item2;
    } else {
      // Même date, fusionner intelligemment en favorisant la complétude
      return ListItem(
        id: item1.id,
        title: item1.title.isNotEmpty ? item1.title : item2.title,
        description: item1.description?.isNotEmpty == true ? item1.description : item2.description,
        category: item1.category?.isNotEmpty == true ? item1.category : item2.category,
        eloScore: max(item1.eloScore, item2.eloScore), // Garder le meilleur score
        isCompleted: item2.isCompleted || item1.isCompleted,
        createdAt: item1.createdAt.isBefore(item2.createdAt) ? item1.createdAt : item2.createdAt,
        completedAt: item2.completedAt ?? item1.completedAt,
        dueDate: item1.dueDate ?? item2.dueDate,
        notes: item1.notes?.isNotEmpty == true ? item1.notes : item2.notes,
        listId: item1.listId,
        lastChosenAt: item1.lastChosenAt != null && item2.lastChosenAt != null
            ? (item1.lastChosenAt!.isAfter(item2.lastChosenAt!) ? item1.lastChosenAt : item2.lastChosenAt)
            : (item1.lastChosenAt ?? item2.lastChosenAt),
      );
    }
  }

  Future<void> _cleanupLocalData() async {
    print('🧹 Nettoyage des données locales après migration réussie');
    try {
      await _localRepository.clearAll();
      print('✅ Données locales nettoyées');
    } catch (e) {
      print('⚠️ Erreur lors du nettoyage: $e');
    }
  }

  /// Nettoie les ressources
  void dispose() {
    print('🧹 DataMigrationService: Nettoyage des ressources');
    _progressCallback = null;
  }
}

// ========== Classes utilitaires privées ==========

class _MigrationItemResult {
  final bool migrated;
  final bool wasConflict;

  _MigrationItemResult({
    required this.migrated,
    required this.wasConflict,
  });
}

class _MigrationBatchResult {
  final int migrated;
  final int conflicts;
  final int errors;

  _MigrationBatchResult({
    required this.migrated,
    required this.conflicts,
    required this.errors,
  });
}