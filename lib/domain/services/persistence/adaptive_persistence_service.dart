import 'package:flutter/foundation.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';

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
    print('🔧 AdaptivePersistenceService: Initialisation avec auth=$isAuthenticated');
    
    _isAuthenticated = isAuthenticated;
    _currentMode = isAuthenticated ? PersistenceMode.cloudFirst : PersistenceMode.localFirst;
    
    print('📊 Mode de persistance: $_currentMode');
  }

  /// Met à jour l'état d'authentification et adapte la persistance
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  }) async {
    print('🔄 Changement d\'authentification: $_isAuthenticated → $isAuthenticated');
    
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
    
    print('📊 Nouveau mode de persistance: $_currentMode');
  }

  /// Récupère toutes les listes selon le mode actuel
  Future<List<CustomList>> getAllLists() async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          return await _localRepository.getAllLists();
          
        case PersistenceMode.cloudFirst:
          // Essayer cloud d'abord, fallback vers local
          try {
            final cloudLists = await _cloudRepository.getAllLists();
            // Sync en arrière-plan vers local pour backup
            _syncCloudToLocalAsync(cloudLists);
            return cloudLists;
          } catch (e) {
            print('⚠️ Cloud indisponible, fallback vers local: $e');
            return await _localRepository.getAllLists();
          }
          
        case PersistenceMode.hybrid:
          return await _getHybridLists();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des listes: $e');
      rethrow;
    }
  }

  /// Sauvegarde une liste selon le mode actuel
  Future<void> saveList(CustomList list) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localRepository.saveList(list);
          break;
          
        case PersistenceMode.cloudFirst:
          // Sauvegarder en local d'abord (réponse immédiate)
          await _localRepository.saveList(list);
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

  /// Supprime une liste selon le mode actuel
  Future<void> deleteList(String listId) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localRepository.deleteList(listId);
          break;
          
        case PersistenceMode.cloudFirst:
          // Supprimer en local d'abord
          await _localRepository.deleteList(listId);
          // Sync suppression vers cloud en arrière-plan
          _deleteListFromCloudAsync(listId);
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
  Future<void> saveItem(ListItem item) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localItemRepository.add(item);
          break;
          
        case PersistenceMode.cloudFirst:
          // Sauvegarder en local d'abord (réponse immédiate)
          await _localItemRepository.add(item);
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
  Future<void> deleteItem(String itemId) async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localItemRepository.delete(itemId);
          break;
          
        case PersistenceMode.cloudFirst:
          // Supprimer en local d'abord
          await _localItemRepository.delete(itemId);
          // Sync suppression vers cloud en arrière-plan
          _deleteItemFromCloudAsync(itemId);
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
  void _syncCloudToLocalAsync(List<CustomList> cloudLists) {
    Future.microtask(() async {
      try {
        for (final list in cloudLists) {
          await _localRepository.saveList(list);
        }
        print('🔄 Backup local mis à jour');
      } catch (e) {
        print('⚠️ Échec backup local: $e');
      }
    });
  }

  /// Suppression asynchrone du cloud
  void _deleteListFromCloudAsync(String listId) {
    if (!_isAuthenticated) return;
    
    Future.microtask(() async {
      try {
        await _cloudRepository.deleteList(listId);
        print('🔄 Suppression cloud réussie pour $listId');
      } catch (e) {
        print('⚠️ Échec suppression cloud pour $listId: $e');
      }
    });
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
  void _deleteItemFromCloudAsync(String itemId) {
    if (!_isAuthenticated) return;
    
    Future.microtask(() async {
      try {
        await _cloudItemRepository.delete(itemId);
        print('🔄 Suppression cloud item réussie pour $itemId');
      } catch (e) {
        print('⚠️ Échec suppression cloud item pour $itemId: $e');
      }
    });
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