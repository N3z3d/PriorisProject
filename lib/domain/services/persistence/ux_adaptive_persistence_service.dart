import 'package:flutter/foundation.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/presentation/widgets/indicators/sync_status_indicator.dart';

/// Service de persistance adaptatif orienté UX
/// 
/// Améliore l'AdaptivePersistenceService original avec:
/// - Feedback utilisateur en temps réel
/// - Transitions transparentes et rassurantes
/// - Gestion des conflits avec notification
/// - États de synchronisation compréhensibles
class UXAdaptivePersistenceService {
  final CustomListRepository _localRepository;
  final CustomListRepository _cloudRepository;
  final ListItemRepository _localItemRepository;
  final ListItemRepository _cloudItemRepository;
  
  // Callback pour notifications UX
  final Function(SyncDisplayStatus status, String? message)? _onStatusChanged;
  
  PersistenceMode _currentMode = PersistenceMode.localFirst;
  bool _isAuthenticated = false;
  
  // État de synchronisation pour l'UX
  SyncDisplayStatus _currentStatus = SyncDisplayStatus.normal;
  
  UXAdaptivePersistenceService({
    required CustomListRepository localRepository,
    required CustomListRepository cloudRepository,
    required ListItemRepository localItemRepository,
    required ListItemRepository cloudItemRepository,
    Function(SyncDisplayStatus, String?)? onStatusChanged,
  }) : _localRepository = localRepository,
       _cloudRepository = cloudRepository,
       _localItemRepository = localItemRepository,
       _cloudItemRepository = cloudItemRepository,
       _onStatusChanged = onStatusChanged;

  /// Mode de persistance actuel
  PersistenceMode get currentMode => _currentMode;
  
  /// État d'authentification
  bool get isAuthenticated => _isAuthenticated;
  
  /// Statut de synchronisation actuel pour l'UX
  SyncDisplayStatus get currentStatus => _currentStatus;

  /// Initialise le service avec feedback UX
  Future<void> initialize({required bool isAuthenticated}) async {
    _isAuthenticated = isAuthenticated;
    _currentMode = isAuthenticated ? PersistenceMode.cloudFirst : PersistenceMode.localFirst;
    
    // UX: Indiquer le mode à l'utilisateur subtilement
    if (isAuthenticated) {
      _updateStatus(SyncDisplayStatus.normal);
    } else {
      _updateStatus(SyncDisplayStatus.offline, "Mode local");
    }
  }

  /// Met à jour l'état d'authentification avec UX fluide
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  }) async {
    final wasAuthenticated = _isAuthenticated;
    _isAuthenticated = isAuthenticated;
    
    if (!wasAuthenticated && isAuthenticated) {
      // Transition: Invité → Connecté avec feedback UX
      await _handleGuestToAuthenticatedTransitionUX(
        migrationStrategy ?? MigrationStrategy.intelligentMerge,
      );
      _currentMode = PersistenceMode.cloudFirst;
    } else if (wasAuthenticated && !isAuthenticated) {
      // Transition: Connecté → Invité avec feedback UX
      await _handleAuthenticatedToGuestTransitionUX();
      _currentMode = PersistenceMode.localFirst;
    }
  }

  /// Récupère toutes les listes avec feedback de connection
  Future<List<CustomList>> getAllLists() async {
    try {
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          return await _localRepository.getAllLists();
          
        case PersistenceMode.cloudFirst:
          // UX: Indiquer qu'on essaie le cloud
          _updateStatus(SyncDisplayStatus.syncing, "Synchronisation...");
          
          try {
            final cloudLists = await _cloudRepository.getAllLists();
            
            // UX: Succès cloud - retour à normal
            _updateStatus(SyncDisplayStatus.normal);
            
            // Sync en arrière-plan vers local pour backup
            _syncCloudToLocalAsync(cloudLists);
            return cloudLists;
          } catch (e) {
            // UX: Fallback automatique avec indication subtile
            _updateStatus(SyncDisplayStatus.offline, "Mode hors ligne");
            return await _localRepository.getAllLists();
          }
          
        case PersistenceMode.hybrid:
          return await _getHybridLists();
      }
    } catch (e) {
      _updateStatus(SyncDisplayStatus.attention, "Erreur de chargement");
      rethrow;
    }
  }

  /// Sauvegarde une liste avec feedback immédiat
  Future<void> saveList(CustomList list) async {
    try {
      // UX: Feedback immédiat de sauvegarde
      _updateStatus(SyncDisplayStatus.syncing, SyncMessages.saving(list.name));
      
      switch (_currentMode) {
        case PersistenceMode.localFirst:
          await _localRepository.saveList(list);
          _updateStatus(SyncDisplayStatus.normal);
          break;
          
        case PersistenceMode.cloudFirst:
          // Sauvegarder en local d'abord (réponse immédiate)
          await _localRepository.saveList(list);
          
          // UX: Indiquer que c'est sauvé localement
          _updateStatus(SyncDisplayStatus.normal);
          
          // Sync vers cloud en arrière-plan avec feedback
          _syncListToCloudAsyncUX(list);
          break;
          
        case PersistenceMode.hybrid:
          await _saveHybridList(list);
          _updateStatus(SyncDisplayStatus.normal);
          break;
      }
    } catch (e) {
      _updateStatus(SyncDisplayStatus.attention, "Erreur de sauvegarde");
      rethrow;
    }
  }

  /// Supprime une liste avec confirmation visuelle
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
          _deleteListFromCloudAsyncUX(listId);
          break;
          
        case PersistenceMode.hybrid:
          await _deleteHybridList(listId);
          break;
      }
    } catch (e) {
      _updateStatus(SyncDisplayStatus.attention, "Erreur de suppression");
      rethrow;
    }
  }

  /// Gestion UX de la transition Invité → Connecté
  Future<void> _handleGuestToAuthenticatedTransitionUX(
    MigrationStrategy strategy,
  ) async {
    try {
      final localLists = await _localRepository.getAllLists();
      
      if (localLists.isEmpty) {
        // UX: Pas de données à migrer - transition simple
        _updateStatus(SyncDisplayStatus.normal);
        return;
      }
      
      // UX: Indiquer la migration en cours
      _updateStatus(SyncDisplayStatus.syncing, "Synchronisation de vos données...");
      
      switch (strategy) {
        case MigrationStrategy.migrateAll:
          await _migrateAllDataToCloud(localLists);
          break;
          
        case MigrationStrategy.intelligentMerge:
          await _intelligentMergeToCloudUX(localLists);
          break;
          
        case MigrationStrategy.cloudOnly:
          // Ne rien migrer
          break;
          
        case MigrationStrategy.askUser:
          // Utiliser merge intelligent par défaut
          await _intelligentMergeToCloudUX(localLists);
          break;
      }
      
      // UX: Migration terminée avec succès
      _updateStatus(SyncDisplayStatus.merged, "Toutes vos données sont synchronisées");
      
      // Retour à normal après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        _updateStatus(SyncDisplayStatus.normal);
      });
      
    } catch (e) {
      _updateStatus(SyncDisplayStatus.attention, "Erreur de synchronisation");
      throw e;
    }
  }

  /// Gestion UX de la transition Connecté → Invité
  Future<void> _handleAuthenticatedToGuestTransitionUX() async {
    try {
      // UX: Indiquer qu'on sauvegarde avant déconnexion
      _updateStatus(SyncDisplayStatus.syncing, "Sauvegarde avant déconnexion...");
      
      final cloudLists = await _cloudRepository.getAllLists();
      for (final list in cloudLists) {
        await _localRepository.saveList(list);
      }
      
      // UX: Transition vers mode offline
      _updateStatus(SyncDisplayStatus.offline, "Mode hors ligne");
      
    } catch (e) {
      // En cas d'échec, continuer en mode offline
      _updateStatus(SyncDisplayStatus.offline, "Mode hors ligne");
    }
  }

  /// Fusion intelligente avec notification des conflits
  Future<void> _intelligentMergeToCloudUX(List<CustomList> localLists) async {
    try {
      final cloudLists = await _cloudRepository.getAllLists();
      final cloudListsMap = {for (var list in cloudLists) list.id: list};
      
      bool hasConflicts = false;
      
      for (final localList in localLists) {
        final cloudList = cloudListsMap[localList.id];
        
        if (cloudList == null) {
          // Nouvelle liste locale → migrer vers cloud
          await _cloudRepository.saveList(localList);
        } else {
          // Conflit détecté
          hasConflicts = true;
          final mergedList = _resolveMergeConflict(localList, cloudList);
          await _cloudRepository.saveList(mergedList);
        }
      }
      
      // UX: Notifier des conflits s'il y en a eu
      if (hasConflicts) {
        _updateStatus(SyncDisplayStatus.merged, "Données fusionnées automatiquement");
      }
      
    } catch (e) {
      _updateStatus(SyncDisplayStatus.attention, "Erreur lors de la fusion");
      rethrow;
    }
  }

  /// Synchronisation asynchrone vers le cloud avec feedback UX
  void _syncListToCloudAsyncUX(CustomList list) {
    if (!_isAuthenticated) return;
    
    Future.microtask(() async {
      try {
        await _cloudRepository.saveList(list);
        // UX: Notification subtile de succès (optionnel)
        // _updateStatus(SyncDisplayStatus.normal);
      } catch (e) {
        // UX: Indication discrète d'échec
        _updateStatus(SyncDisplayStatus.offline, "Sync différée");
      }
    });
  }

  /// Suppression asynchrone du cloud avec feedback UX
  void _deleteListFromCloudAsyncUX(String listId) {
    if (!_isAuthenticated) return;
    
    Future.microtask(() async {
      try {
        await _cloudRepository.deleteList(listId);
      } catch (e) {
        // UX: Indication discrète d'échec de sync
        _updateStatus(SyncDisplayStatus.offline, "Sync différée");
      }
    });
  }

  /// Met à jour le statut UX et notifie les listeners
  void _updateStatus(SyncDisplayStatus status, [String? message]) {
    _currentStatus = status;
    _onStatusChanged?.call(status, message);
  }

  /// Résout les conflits de fusion (comme original)
  CustomList _resolveMergeConflict(CustomList local, CustomList cloud) {
    if (local.updatedAt != null && cloud.updatedAt != null) {
      return local.updatedAt!.isAfter(cloud.updatedAt!) ? local : cloud;
    } else if (local.updatedAt != null) {
      return local;
    } else if (cloud.updatedAt != null) {
      return cloud;
    } else {
      return local;
    }
  }

  /// Migration complète vers le cloud (comme original)
  Future<void> _migrateAllDataToCloud(List<CustomList> localLists) async {
    for (final list in localLists) {
      try {
        await _cloudRepository.saveList(list);
      } catch (e) {
        // Continue malgré les erreurs
      }
    }
  }

  /// Synchronisation asynchrone du cloud vers local (comme original)
  void _syncCloudToLocalAsync(List<CustomList> cloudLists) {
    Future.microtask(() async {
      try {
        for (final list in cloudLists) {
          await _localRepository.saveList(list);
        }
      } catch (e) {
        // Échec silencieux du backup
      }
    });
  }

  // Méthodes hybrides (placeholders comme original)
  Future<List<CustomList>> _getHybridLists() async {
    return await getAllLists();
  }

  Future<void> _saveHybridList(CustomList list) async {
    await saveList(list);
  }

  Future<void> _deleteHybridList(String listId) async {
    await deleteList(listId);
  }

  /// Nettoie les ressources
  void dispose() {
    _updateStatus(SyncDisplayStatus.normal);
  }
}

/// Mode de persistance (réutilisé depuis le service original)
enum PersistenceMode {
  localFirst,
  cloudFirst,
  hybrid,
}

/// Stratégie de migration (réutilisée depuis le service original)
enum MigrationStrategy {
  migrateAll,
  askUser,
  cloudOnly,
  intelligentMerge,
}