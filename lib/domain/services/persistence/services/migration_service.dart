/// **MIGRATION SERVICE** - SRP Specialized Component
///
/// **LOT 9** : Service spécialisé pour migration de données
/// **SRP** : Responsabilité unique = Migration entre persistances
/// **Taille** : <150 lignes (extraction depuis God Class 923 lignes)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'lists_persistence_service.dart';
import 'items_persistence_service.dart';
import '../interfaces/unified_persistence_interface.dart';

/// Service spécialisé pour la migration des données
///
/// **SRP** : Migration et stratégies de transition uniquement
/// **DIP** : Injecte ses dépendances (services, logger)
/// **OCP** : Extensible via nouvelles stratégies de migration
class MigrationService {
  final ListsPersistenceService _listsService;
  final ItemsPersistenceService _itemsService;
  final ILogger _logger;
  bool _isAuthenticated = false;

  MigrationService({
    required ListsPersistenceService listsService,
    required ItemsPersistenceService itemsService,
    required ILogger logger,
  }) : _listsService = listsService,
       _itemsService = itemsService,
       _logger = logger;

  /// Met à jour l'état d'authentification
  void updateAuthenticationState(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
  }

  /// Migre les données selon la stratégie spécifiée
  Future<void> migrateData(MigrationStrategy strategy) async {
    _logger.info('Migration données avec stratégie: ${strategy.name}', context: 'MigrationService');

    try {
      final localLists = await _listsService.getAllLists(mode: PersistenceMode.localOnly);

      if (localLists.isEmpty) {
        _logger.info('Aucune donnée locale à migrer', context: 'MigrationService');
        return;
      }

      switch (strategy) {
        case MigrationStrategy.migrateAll:
          await _migrateAllDataToCloud(localLists);
          break;

        case MigrationStrategy.intelligentMerge:
          await _intelligentMergeToCloud(localLists);
          break;

        case MigrationStrategy.cloudOnly:
          // Ne rien migrer, utiliser uniquement les données cloud
          _logger.info('Migration cloudOnly: aucune action requise', context: 'MigrationService');
          break;

        case MigrationStrategy.askUser:
          // TODO: Implémenter dialogue utilisateur
          await _intelligentMergeToCloud(localLists);
          break;
      }

      _logger.info('Migration terminée', context: 'MigrationService');
    } catch (e) {
      _logger.error('Erreur pendant la migration: $e', context: 'MigrationService');
      rethrow;
    }
  }

  /// Vérifie s'il y a une migration en attente
  Future<bool> hasPendingMigration() async {
    if (!_isAuthenticated) return false;

    try {
      final localLists = await _listsService.getAllLists(mode: PersistenceMode.localOnly);
      return localLists.isNotEmpty;
    } catch (e) {
      _logger.error('Erreur vérification migration: $e', context: 'MigrationService');
      return false;
    }
  }

  /// Gère la transition de guest vers utilisateur authentifié
  Future<void> handleGuestToAuthenticatedTransition(MigrationStrategy strategy) async {
    _logger.info('Transition guest → authentifié', context: 'MigrationService');

    try {
      await migrateData(strategy);
      _isAuthenticated = true;
    } catch (e) {
      _logger.error('Erreur transition guest → authentifié: $e', context: 'MigrationService');
      rethrow;
    }
  }

  /// Gère la transition d'utilisateur authentifié vers guest
  Future<void> handleAuthenticatedToGuestTransition() async {
    _logger.info('Transition authentifié → guest', context: 'MigrationService');

    try {
      // Sauvegarder les données cloud vers local avant déconnexion
      final cloudLists = await _listsService.getAllLists(mode: PersistenceMode.cloudFirst);

      for (final list in cloudLists) {
        await _listsService.saveList(list, mode: PersistenceMode.localOnly);

        final items = await _itemsService.getItemsByListId(list.id, mode: PersistenceMode.cloudFirst);
        for (final item in items) {
          await _itemsService.saveItem(item, mode: PersistenceMode.localOnly);
        }
      }

      _isAuthenticated = false;
      _logger.info('Transition authentifié → guest terminée', context: 'MigrationService');
    } catch (e) {
      _logger.error('Erreur transition authentifié → guest: $e', context: 'MigrationService');
      rethrow;
    }
  }

  // ==================== MÉTHODES PRIVÉES DE MIGRATION ====================

  /// Migre toutes les données locales vers le cloud
  Future<void> _migrateAllDataToCloud(List<CustomList> lists) async {
    _logger.info('Migration complète vers cloud: ${lists.length} listes', context: 'MigrationService');

    for (final list in lists) {
      // Migrer la liste
      await _listsService.saveList(list, mode: PersistenceMode.cloudFirst);

      // Migrer les items de la liste
      final items = await _itemsService.getItemsByListId(list.id, mode: PersistenceMode.localOnly);
      for (final item in items) {
        await _itemsService.saveItem(item, mode: PersistenceMode.cloudFirst);
      }
    }
  }

  /// Migre intelligemment en évitant les doublons
  Future<void> _intelligentMergeToCloud(List<CustomList> lists) async {
    _logger.info('Migration intelligente vers cloud: ${lists.length} listes', context: 'MigrationService');

    for (final list in lists) {
      try {
        // Vérifier si la liste existe déjà dans le cloud
        await _listsService.verifyListPersistence(list.id);
        _logger.debug('Liste ${list.id} déjà présente en cloud', context: 'MigrationService');
      } catch (e) {
        // Liste n'existe pas, la migrer
        await _listsService.saveList(list, mode: PersistenceMode.cloudFirst);

        // Migrer les items
        final items = await _itemsService.getItemsByListId(list.id, mode: PersistenceMode.localOnly);
        for (final item in items) {
          try {
            await _itemsService.verifyItemPersistence(item.id);
            _logger.debug('Item ${item.id} déjà présent en cloud', context: 'MigrationService');
          } catch (e) {
            await _itemsService.saveItem(item, mode: PersistenceMode.cloudFirst);
          }
        }
      }
    }
  }
}