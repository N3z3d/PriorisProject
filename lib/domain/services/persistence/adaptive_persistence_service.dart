import 'package:flutter/foundation.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/core/utils/operation_queue.dart';

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

/// Service de persistance adaptatif qui gère intelligemment 
/// le stockage selon l'état d'authentification de l'utilisateur
class AdaptivePersistenceService {
  final CustomListRepository _localRepository;
  final CustomListRepository _cloudRepository;
  final ListItemRepository _localItemRepository;
  final ListItemRepository _cloudItemRepository;
  
  PersistenceMode _currentMode = PersistenceMode.localFirst;
  bool _isAuthenticated = false;
  
  AdaptivePersistenceService({
    required CustomListRepository localRepository,
    required CustomListRepository cloudRepository,
    required ListItemRepository localItemRepository,
    required ListItemRepository cloudItemRepository,
  }) : _localRepository = localRepository,
       _cloudRepository = cloudRepository,
       _localItemRepository = localItemRepository,
       _cloudItemRepository = cloudItemRepository;

  /// Mode de persistance actuel
  PersistenceMode get currentMode => _currentMode;
  
  /// État d'authentification
  bool get isAuthenticated => _isAuthenticated;

  /// Initialise le service avec l'état d'authentification
  Future<void> initialize({required bool isAuthenticated}) async {
    LoggerService.instance.info('Initialisation avec auth=$isAuthenticated', context: 'AdaptivePersistenceService');
    
    _isAuthenticated = isAuthenticated;
    _currentMode = isAuthenticated ? PersistenceMode.cloudFirst : PersistenceMode.localFirst;
    
    LoggerService.instance.info('Mode de persistance: $_currentMode', context: 'AdaptivePersistenceService');
  }

  /// Met à jour l'état d'authentification et adapte la persistance
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  }) async {
    LoggerService.instance.info('Changement d\'authentification: $_isAuthenticated → $isAuthenticated', context: 'AdaptivePersistenceService');
    
    final wasAuthenticated = _isAuthenticated;
    _isAuthenticated = isAuthenticated;
    
    if (!wasAuthenticated && isAuthenticated) {
      // Transition: Invité → Connecté
      await _handleGuestToAuthenticatedTransition(
        migrationStrategy ?? MigrationStrategy.intelligentMerge,
      );
      _currentMode = PersistenceMode.cloudFirst;
    } else if (wasAuthenticated && !isAuthenticated) {
      // Transition: Connecté → Invité
      await _handleAuthenticatedToGuestTransition();
      _currentMode = PersistenceMode.localFirst;
    }
    
    LoggerService.instance.info('Nouveau mode de persistance: $_currentMode', context: 'AdaptivePersistenceService');
  }

  /// Récupère toutes les listes selon le mode actuel
  /// DEDUPLICATION FIX: Déduplique automatiquement les résultats
  Future<List<CustomList>> getAllLists() async {
    try {
      List<CustomList> lists;
      
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          lists = await _localRepository.getAllLists();
          break;
          
        case PersistenceMode.cloudFirst:
          // Essayer cloud d'abord, fallback vers local
          try {
            lists = await _cloudRepository.getAllLists();
            // Sync en arrière-plan vers local pour backup avec gestion d'erreur
            _syncCloudToLocalWithErrorHandling(lists);
          } catch (e) {
            LoggerService.instance.error('Cloud indisponible, fallback vers local', context: 'AdaptivePersistenceService', error: e);
            lists = await _localRepository.getAllLists();
          }
          break;
          
        case PersistenceMode.hybrid:
          lists = await _getHybridLists();
          break;
      }
      
      // DEDUPLICATION FIX: Déduplication automatique des résultats
      return _deduplicateLists(lists);
    } catch (e) {
      LoggerService.instance.error('Erreur lors de la récupération des listes', context: 'AdaptivePersistenceService', error: e);
      rethrow;
    }
  }
  
  /// DEDUPLICATION FIX: Déduplique une liste de CustomList par ID
  List<CustomList> _deduplicateLists(List<CustomList> lists) {
    final Map<String, CustomList> uniqueLists = {};
    
    for (final list in lists) {
      final existingList = uniqueLists[list.id];
      
      if (existingList == null) {
        // Première occurrence de cet ID
        uniqueLists[list.id] = list;
      } else {
        // Conflit détecté, garder la version la plus récente
        final resolved = _resolveListConflict(existingList, list);
        uniqueLists[list.id] = resolved;
        LoggerService.instance.debug('Déduplication: conflit résolu pour liste "${resolved.name}" (${list.id})', context: 'AdaptivePersistenceService');
      }
    }
    
    final deduplicatedLists = uniqueLists.values.toList();
    
    if (deduplicatedLists.length < lists.length) {
      LoggerService.instance.info('Déduplication: ${lists.length} → ${deduplicatedLists.length} listes (${lists.length - deduplicatedLists.length} doublons supprimés)', context: 'AdaptivePersistenceService');
    }
    
    return deduplicatedLists;
  }
  
  /// ERROR BOUNDARY FIX: Sync cloud vers local avec gestion d'erreur robuste
  void _syncCloudToLocalWithErrorHandling(List<CustomList> cloudLists) {
    Future.microtask(() async {
      try {
        for (final list in cloudLists) {
          try {
            await _saveListWithDeduplication(list, _localRepository);
          } catch (e) {
            LoggerService.instance.error('Échec backup local pour liste "${list.name}" (${list.id})', context: 'AdaptivePersistenceService', error: e);
            // Continuer avec les autres listes même si une échoue
          }
        }
        LoggerService.instance.info('Backup local mis à jour (${cloudLists.length} listes traitées)', context: 'AdaptivePersistenceService');
      } catch (e) {
        print('⚠️ Échec général du backup local: ${_sanitizeErrorMessage(e.toString())}');
      }
    });
  }

  /// Sauvegarde une liste selon le mode actuel
  /// DEDUPLICATION FIX: Gère les conflits d'ID avec stratégie upsert
  Future<void> saveList(CustomList list) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _saveListWithDeduplication(list, _localRepository);
          break;
          
        case PersistenceMode.cloudFirst:
          // Sauvegarder en local d'abord avec déduplication
          await _saveListWithDeduplication(list, _localRepository);
          // Sync vers cloud en arrière-plan
          _syncListToCloudAsync(list);
          break;
          
        case PersistenceMode.hybrid:
          await _saveHybridList(list);
          break;
      }
      
      print('✅ Liste "${list.name}" sauvegardée en mode $_currentMode');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde: $e');
      rethrow;
    }
  }
  
  /// DEDUPLICATION FIX: Sauvegarde avec gestion des doublons
  Future<void> _saveListWithDeduplication(CustomList list, CustomListRepository repository) async {
    try {
      // Tenter la sauvegarde normale
      await repository.saveList(list);
    } catch (e) {
      if (e.toString().contains('Une liste avec cet ID existe déjà')) {
        print('🔄 Conflit détecté pour liste ${list.id}, utilisation stratégie de fusion...');
        
        // Récupérer la liste existante
        final existingList = await repository.getListById(list.id);
        
        if (existingList != null) {
          // Utiliser la version la plus récente
          final mergedList = _resolveListConflict(existingList, list);
          
          // Mettre à jour la liste existante
          await repository.updateList(mergedList);
          print('🔀 Conflit résolu: fusion réussie pour "${mergedList.name}"');
        } else {
          // Si la liste n'existe pas finalement, réessayer l'ajout
          await repository.saveList(list);
        }
      } else {
        // Re-lancer l'erreur si ce n'est pas un conflit d'ID
        rethrow;
      }
    }
  }
  
  /// DEDUPLICATION FIX: Résout les conflits entre listes
  CustomList _resolveListConflict(CustomList existing, CustomList incoming) {
    // Utiliser la liste avec la date de modification la plus récente
    if (existing.updatedAt.isAfter(incoming.updatedAt)) {
      print('📅 Conflit résolu: version existante plus récente conservée');
      return existing;
    } else if (incoming.updatedAt.isAfter(existing.updatedAt)) {
      print('📅 Conflit résolu: version entrante plus récente adoptée');
      return incoming;
    } else {
      // En cas d'égalité, préférer la version entrante (comportement par défaut)
      print('📅 Conflit résolu: versions équivalentes, adoption version entrante');
      return incoming;
    }
  }

  /// Supprime une liste selon le mode actuel
  /// RLS PERMISSION FIX: Gère les erreurs de permission gracieusement
  Future<void> deleteList(String listId) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localRepository.deleteList(listId);
          break;
          
        case PersistenceMode.cloudFirst:
          // Supprimer en local d'abord (toujours possible)
          await _localRepository.deleteList(listId);
          // Sync suppression vers cloud en arrière-plan avec gestion d'erreur
          _deleteListFromCloudWithErrorHandling(listId);
          break;
          
        case PersistenceMode.hybrid:
          await _deleteHybridList(listId);
          break;
      }
      
      print('🗑️ Liste $listId supprimée en mode $_currentMode');
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
      rethrow;
    }
  }
  
  /// RLS PERMISSION FIX: Suppression cloud avec gestion d'erreur de permission
  /// Now uses reliable operation queue instead of unhandled microtask
  void _deleteListFromCloudWithErrorHandling(String listId) {
    if (!_isAuthenticated) return;
    
    OperationQueue.instance.enqueue(
      name: 'deleteListFromCloud',
      operation: () async {
        await _cloudRepository.deleteList(listId);
        LoggerService.instance.info('Suppression cloud réussie pour $listId', context: 'AdaptivePersistenceService');
      },
      priority: OperationPriority.medium,
      maxRetries: 2,
    ).catchError((e) {
      _handleCloudPermissionError('deleteList', listId, e);
    });
  }

  /// Récupère tous les items d'une liste selon le mode actuel
  Future<List<ListItem>> getItemsByListId(String listId) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          return await _localItemRepository.getByListId(listId);
          
        case PersistenceMode.cloudFirst:
          // Essayer cloud d'abord, fallback vers local
          try {
            final cloudItems = await _cloudItemRepository.getByListId(listId);
            // Sync en arrière-plan vers local pour backup
            _syncItemsToLocalAsync(listId, cloudItems);
            return cloudItems;
          } catch (e) {
            print('⚠️ Cloud indisponible pour items, fallback vers local: $e');
            return await _localItemRepository.getByListId(listId);
          }
          
        case PersistenceMode.hybrid:
          return await _getHybridItems(listId);
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des items: $e');
      rethrow;
    }
  }

  /// Sauvegarde un item selon le mode actuel
  /// DEDUPLICATION FIX: Gère les conflits d'ID avec stratégie upsert
  Future<void> saveItem(ListItem item) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _saveItemWithDeduplication(item, _localItemRepository);
          break;
          
        case PersistenceMode.cloudFirst:
          // Sauvegarder en local d'abord avec déduplication
          await _saveItemWithDeduplication(item, _localItemRepository);
          // Sync vers cloud en arrière-plan
          _syncItemToCloudAsync(item);
          break;
          
        case PersistenceMode.hybrid:
          await _saveHybridItem(item);
          break;
      }
      
      print('✅ Item "${item.title}" sauvegardé en mode $_currentMode');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde d\'item: $e');
      rethrow;
    }
  }
  
  /// DEDUPLICATION FIX: Sauvegarde d'item avec gestion des doublons  
  Future<void> _saveItemWithDeduplication(ListItem item, ListItemRepository repository) async {
    try {
      // Tenter l'ajout normal
      await repository.add(item);
    } catch (e) {
      if (e.toString().contains('Un item avec cet id existe déjà')) {
        print('🔄 Conflit d\'item détecté pour ${item.id}, utilisation stratégie upsert...');
        
        // Récupérer l'item existant
        final existingItem = await repository.getById(item.id);
        
        if (existingItem != null) {
          // Utiliser la version la plus récente
          final mergedItem = _resolveItemConflict(existingItem, item);
          
          // Mettre à jour l'item existant
          await repository.update(mergedItem);
          print('🔀 Conflit d\'item résolu: fusion réussie pour "${mergedItem.title}"');
        } else {
          // Si l'item n'existe pas finalement, réessayer l'ajout
          await repository.add(item);
        }
      } else {
        // Re-lancer l'erreur si ce n'est pas un conflit d'ID
        rethrow;
      }
    }
  }
  
  /// DEDUPLICATION FIX: Résout les conflits entre items
  ListItem _resolveItemConflict(ListItem existing, ListItem incoming) {
    // Utiliser l'item avec la date de création la plus récente (les items n'ont pas toujours updatedAt)
    if (existing.createdAt.isAfter(incoming.createdAt)) {
      print('📅 Conflit d\'item résolu: version existante plus récente conservée');
      return existing;
    } else if (incoming.createdAt.isAfter(existing.createdAt)) {
      print('📅 Conflit d\'item résolu: version entrante plus récente adoptée');
      return incoming;
    } else {
      // En cas d'égalité, préférer la version entrante
      print('📅 Conflit d\'item résolu: versions équivalentes, adoption version entrante');
      return incoming;
    }
  }

  /// Met à jour un item selon le mode actuel
  Future<void> updateItem(ListItem item) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localItemRepository.update(item);
          break;
          
        case PersistenceMode.cloudFirst:
          // Mettre à jour en local d'abord
          await _localItemRepository.update(item);
          // Sync vers cloud en arrière-plan
          _syncItemToCloudAsync(item);
          break;
          
        case PersistenceMode.hybrid:
          await _updateHybridItem(item);
          break;
      }
      
      print('✅ Item "${item.title}" mis à jour en mode $_currentMode');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour d\'item: $e');
      rethrow;
    }
  }

  /// Supprime un item selon le mode actuel
  /// RLS PERMISSION FIX: Gère les erreurs de permission gracieusement
  Future<void> deleteItem(String itemId) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localItemRepository.delete(itemId);
          break;
          
        case PersistenceMode.cloudFirst:
          // Supprimer en local d'abord (toujours possible)
          await _localItemRepository.delete(itemId);
          // Sync suppression vers cloud en arrière-plan avec gestion d'erreur
          _deleteItemFromCloudWithErrorHandling(itemId);
          break;
          
        case PersistenceMode.hybrid:
          await _deleteHybridItem(itemId);
          break;
      }
      
      print('🗑️ Item $itemId supprimé en mode $_currentMode');
    } catch (e) {
      print('❌ Erreur lors de la suppression d\'item: $e');
      rethrow;
    }
  }
  
  /// RLS PERMISSION FIX: Suppression d'item cloud avec gestion d'erreur
  void _deleteItemFromCloudWithErrorHandling(String itemId) {
    if (!_isAuthenticated) return;
    
    Future.microtask(() async {
      try {
        await _cloudItemRepository.delete(itemId);
        print('🔄 Suppression cloud item réussie pour $itemId');
      } catch (e) {
        _handleCloudPermissionError('deleteItem', itemId, e);
      }
    });
  }
  
  /// RLS PERMISSION FIX: Gestion centralisée des erreurs de permission cloud
  void _handleCloudPermissionError(String operation, String id, dynamic error) {
    final errorMsg = error.toString();
    
    // Vérifier si c'est une erreur de permission
    if (errorMsg.contains('403 Forbidden') || 
        errorMsg.contains('permission denied') || 
        errorMsg.contains('Row Level Security') ||
        errorMsg.contains('JWT expired') ||
        errorMsg.contains('Unauthorized')) {
      
      print('🔒 Erreur de permission cloud pour $operation($id): ${_sanitizeErrorMessage(errorMsg)}');
      
      // Log pour monitoring (sans exposer les détails techniques)
      _logPermissionError(operation, id, errorMsg);
      
      // Note: Ne pas propager l'erreur - l'opération locale a déjà réussi
      return;
    }
    
    // Pour les autres erreurs cloud, log sans bloquer
    print('⚠️ Erreur cloud pour $operation($id): ${_sanitizeErrorMessage(errorMsg)}');
  }
  
  /// RLS PERMISSION FIX: Assainit les messages d'erreur pour l'utilisateur
  String _sanitizeErrorMessage(String error) {
    // Remplacer les messages techniques par des messages compréhensibles
    if (error.contains('PostgrestException')) return 'Problème de synchronisation cloud';
    if (error.contains('JWT expired')) return 'Session expirée';
    if (error.contains('403 Forbidden')) return 'Permissions insuffisantes';
    if (error.contains('Row Level Security')) return 'Restrictions d\'accès appliquées';
    
    // Pour les autres erreurs, garder un message générique
    return 'Problème de synchronisation temporaire';
  }
  
  /// RLS PERMISSION FIX: Log les erreurs de permission pour monitoring
  void _logPermissionError(String operation, String id, String error) {
    // Dans un vrai projet, ceci enverrait vers un service de monitoring
    // comme Firebase Crashlytics, Sentry, etc.
    print('📊 MONITORING: Permission error - Operation: $operation, ID: $id, Error: ${error.substring(0, error.length.clamp(0, 100))}...');
  }

  /// Gère la transition Invité → Connecté
  Future<void> _handleGuestToAuthenticatedTransition(
    MigrationStrategy strategy,
  ) async {
    print('🔄 Transition Invité → Connecté avec stratégie: $strategy');
    
    try {
      final localLists = await _localRepository.getAllLists();
      
      if (localLists.isEmpty) {
        print('📭 Aucune donnée locale à migrer');
        return;
      }
      
      print('📦 Migration de ${localLists.length} listes vers le cloud');
      
      switch (strategy) {
        case MigrationStrategy.migrateAll:
          await _migrateAllDataToCloud(localLists);
          break;
          
        case MigrationStrategy.intelligentMerge:
          await _intelligentMergeToCloud(localLists);
          break;
          
        case MigrationStrategy.cloudOnly:
          // Ne rien migrer, utiliser uniquement les données cloud
          break;
          
        case MigrationStrategy.askUser:
          // TODO: Implémenter dialogue utilisateur
          await _intelligentMergeToCloud(localLists);
          break;
      }
      
      print('✅ Migration terminée');
    } catch (e) {
      print('❌ Erreur pendant la migration: $e');
      // En cas d'erreur, conserver les données locales
    }
  }

  /// Gère la transition Connecté → Invité
  Future<void> _handleAuthenticatedToGuestTransition() async {
    print('🔄 Transition Connecté → Invité');
    
    try {
      // Synchroniser les dernières données cloud vers local
      final cloudLists = await _cloudRepository.getAllLists();
      for (final list in cloudLists) {
        await _localRepository.saveList(list);
      }
      
      print('✅ Synchronisation cloud → local terminée');
    } catch (e) {
      print('⚠️ Impossible de synchroniser avant déconnexion: $e');
      // Continuer avec les données locales existantes
    }
  }

  /// Migration intelligente avec fusion des données
  Future<void> _intelligentMergeToCloud(List<CustomList> localLists) async {
    try {
      final cloudLists = await _cloudRepository.getAllLists();
      final cloudListsMap = {for (var list in cloudLists) list.id: list};
      
      for (final localList in localLists) {
        final cloudList = cloudListsMap[localList.id];
        
        if (cloudList == null) {
          // Nouvelle liste locale → migrer vers cloud
          await _cloudRepository.saveList(localList);
          print('📤 Liste "${localList.name}" migrée vers cloud');
        } else {
          // Conflit → résoudre avec la plus récente
          final mergedList = _resolveMergeConflict(localList, cloudList);
          await _cloudRepository.saveList(mergedList);
          print('🔀 Liste "${mergedList.name}" fusionnée');
        }
      }
    } catch (e) {
      print('❌ Erreur lors de la fusion intelligente: $e');
      rethrow;
    }
  }

  /// Résout les conflits de fusion (dernière modification gagne)
  CustomList _resolveMergeConflict(CustomList local, CustomList cloud) {
    // Utiliser la liste la plus récemment modifiée
    if (local.updatedAt != null && cloud.updatedAt != null) {
      return local.updatedAt!.isAfter(cloud.updatedAt!) ? local : cloud;
    } else if (local.updatedAt != null) {
      return local;
    } else if (cloud.updatedAt != null) {
      return cloud;
    } else {
      // Aucune date, garder la locale par sécurité
      return local;
    }
  }

  /// Migration complète vers le cloud
  Future<void> _migrateAllDataToCloud(List<CustomList> localLists) async {
    for (final list in localLists) {
      try {
        await _cloudRepository.saveList(list);
        print('📤 Liste "${list.name}" migrée');
      } catch (e) {
        print('❌ Erreur migration liste "${list.name}": $e');
      }
    }
  }

  /// Synchronisation asynchrone vers le cloud
  void _syncListToCloudAsync(CustomList list) {
    if (!_isAuthenticated) return;
    
    Future.microtask(() async {
      try {
        print('🔄 Tentative sync cloud pour "${list.name}"...');
        print('📋 JSON envoyé: ${list.toJson()}');
        await _cloudRepository.saveList(list);
        print('✅ Sync cloud réussie pour "${list.name}"');
      } catch (e) {
        print('❌ Échec sync cloud pour "${list.name}": $e');
        // TODO: Ajouter à une queue de retry
      }
    });
  }

  /// Synchronisation asynchrone du cloud vers local
  @Deprecated('Use _syncCloudToLocalWithErrorHandling instead')
  void _syncCloudToLocalAsync(List<CustomList> cloudLists) {
    _syncCloudToLocalWithErrorHandling(cloudLists);
  }

  /// Suppression asynchrone du cloud
  @Deprecated('Use _deleteListFromCloudWithErrorHandling instead')
  void _deleteListFromCloudAsync(String listId) {
    _deleteListFromCloudWithErrorHandling(listId);
  }

  /// Synchronisation asynchrone d'un item vers le cloud
  void _syncItemToCloudAsync(ListItem item) {
    if (!_isAuthenticated) return;
    
    Future.microtask(() async {
      try {
        await _cloudItemRepository.add(item);
        print('🔄 Sync cloud item réussie pour "${item.title}"');
      } catch (e) {
        print('⚠️ Échec sync cloud item pour "${item.title}": $e');
        // TODO: Ajouter à une queue de retry
      }
    });
  }

  /// Synchronisation asynchrone d'items vers le local
  void _syncItemsToLocalAsync(String listId, List<ListItem> items) {
    Future.microtask(() async {
      try {
        for (final item in items) {
          await _localItemRepository.add(item);
        }
        print('🔄 Backup local items mis à jour pour liste $listId');
      } catch (e) {
        print('⚠️ Échec backup local items: $e');
      }
    });
  }

  /// Suppression asynchrone d'item du cloud
  @Deprecated('Use _deleteItemFromCloudWithErrorHandling instead')
  void _deleteItemFromCloudAsync(String itemId) {
    _deleteItemFromCloudWithErrorHandling(itemId);
  }

  // Méthodes hybrides (pour usage futur)
  Future<List<CustomList>> _getHybridLists() async {
    // TODO: Implémenter logique hybride avancée
    return await getAllLists();
  }

  Future<void> _saveHybridList(CustomList list) async {
    // TODO: Implémenter sauvegarde hybride
    await saveList(list);
  }

  Future<void> _deleteHybridList(String listId) async {
    // TODO: Implémenter suppression hybride
    await deleteList(listId);
  }

  /// Méthodes hybrides pour items (pour usage futur)
  Future<List<ListItem>> _getHybridItems(String listId) async {
    // TODO: Implémenter logique hybride avancée pour items
    return await getItemsByListId(listId);
  }

  Future<void> _saveHybridItem(ListItem item) async {
    // TODO: Implémenter sauvegarde hybride item
    await saveItem(item);
  }

  Future<void> _updateHybridItem(ListItem item) async {
    // TODO: Implémenter update hybride item
    await updateItem(item);
  }

  Future<void> _deleteHybridItem(String itemId) async {
    // TODO: Implémenter suppression hybride item
    await deleteItem(itemId);
  }

  /// Nettoie les ressources
  void dispose() {
    print('🧹 AdaptivePersistenceService: Nettoyage des ressources');
  }
}