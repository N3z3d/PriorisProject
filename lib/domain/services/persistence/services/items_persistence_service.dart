/// **ITEMS PERSISTENCE SERVICE** - SRP Specialized Component
///
/// **LOT 9** : Service spécialisé pour opérations CRUD items uniquement
/// **SRP** : Responsabilité unique = Persistance des ListItem
/// **Taille** : <150 lignes (extraction depuis God Class 923 lignes)

import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import '../interfaces/unified_persistence_interface.dart';

/// Service spécialisé pour la persistance des items de liste
///
/// **SRP** : Gestion CRUD des ListItem uniquement
/// **DIP** : Injecte ses dépendances (repository, logger, validator)
/// **OCP** : Extensible via PersistenceMode et stratégies
class ItemsPersistenceService {
  final ListItemRepository _localItemRepository;
  final ListItemRepository? _cloudItemRepository;
  final ILogger _logger;
  final IPersistenceValidator _validator;
  final IPersistenceConfiguration _config;

  const ItemsPersistenceService({
    required ListItemRepository localItemRepository,
    ListItemRepository? cloudItemRepository,
    required ILogger logger,
    required IPersistenceValidator validator,
    required IPersistenceConfiguration config,
  }) : _localItemRepository = localItemRepository,
       _cloudItemRepository = cloudItemRepository,
       _logger = logger,
       _validator = validator,
       _config = config;

  /// Récupère les items d'une liste selon le mode de persistance
  Future<List<ListItem>> getItemsByListId(String listId, {
    PersistenceMode? mode,
  }) async {
    if (listId.trim().isEmpty) {
      throw ArgumentError('ID liste requis');
    }

    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          return await _localItemRepository.getByListId(listId);
        case PersistenceMode.cloudFirst:
          return await _getItemsCloudFirst(listId);
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          return await _getItemsHybrid(listId);
      }
    } catch (e) {
      _logger.error('Erreur récupération items liste $listId: $e', context: 'ItemsPersistenceService');
      // Fallback vers local en cas d'erreur
      return await _localItemRepository.getByListId(listId);
    }
  }

  /// Sauvegarde un item selon le mode de persistance
  Future<void> saveItem(ListItem item, {PersistenceMode? mode}) async {
    if (!_validator.validateListItem(item)) {
      throw ArgumentError('Item invalide pour sauvegarde');
    }

    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          await _localItemRepository.add(item);
          break;
        case PersistenceMode.cloudFirst:
          await _saveItemCloudFirst(item);
          break;
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          await _saveItemHybrid(item);
          break;
      }

      _logger.debug('Item sauvegardé: ${item.id}', context: 'ItemsPersistenceService');
    } catch (e) {
      _logger.error('Erreur sauvegarde item ${item.id}: $e', context: 'ItemsPersistenceService');
      rethrow;
    }
  }

  /// Met à jour un item selon le mode de persistance
  Future<void> updateItem(ListItem item, {PersistenceMode? mode}) async {
    if (!_validator.validateListItem(item)) {
      throw ArgumentError('Item invalide pour mise à jour');
    }

    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          await _localItemRepository.update(item);
          break;
        case PersistenceMode.cloudFirst:
          await _cloudItemRepository?.update(item);
          await _localItemRepository.update(item);
          break;
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          await _updateItemHybrid(item);
          break;
      }

      _logger.debug('Item mis à jour: ${item.id}', context: 'ItemsPersistenceService');
    } catch (e) {
      _logger.error('Erreur mise à jour item ${item.id}: $e', context: 'ItemsPersistenceService');
      rethrow;
    }
  }

  /// Supprime un item selon le mode de persistance
  Future<void> deleteItem(String itemId, {PersistenceMode? mode}) async {
    if (itemId.trim().isEmpty) {
      throw ArgumentError('ID item requis pour suppression');
    }

    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          await _localItemRepository.delete(itemId);
          break;
        case PersistenceMode.cloudFirst:
          await _deleteItemCloudFirst(itemId);
          break;
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          await _deleteItemHybrid(itemId);
          break;
      }

      _logger.debug('Item supprimé: $itemId', context: 'ItemsPersistenceService');
    } catch (e) {
      _logger.error('Erreur suppression item $itemId: $e', context: 'ItemsPersistenceService');
      rethrow;
    }
  }

  /// Sauvegarde multiple d'items avec gestion d'erreurs
  Future<void> saveMultipleItems(List<ListItem> items, {PersistenceMode? mode}) async {
    if (items.isEmpty) return;

    final validItems = <ListItem>[];
    final invalidItems = <ListItem>[];

    // Validation préalable
    for (final item in items) {
      if (_validator.validateListItem(item)) {
        validItems.add(item);
      } else {
        invalidItems.add(item);
        _logger.warning('Item invalide ignoré: ${item.id}', context: 'ItemsPersistenceService');
      }
    }

    if (validItems.isEmpty) {
      throw ArgumentError('Aucun item valide à sauvegarder');
    }

    try {
      for (final item in validItems) {
        await saveItem(item, mode: mode);
      }

      _logger.info('${validItems.length} items sauvegardés avec succès', context: 'ItemsPersistenceService');
    } catch (e) {
      _logger.error('Erreur sauvegarde multiple items: $e', context: 'ItemsPersistenceService');
      await _rollbackFailedItems(validItems);
      rethrow;
    }
  }

  /// Vérifie la persistance d'un item
  Future<void> verifyItemPersistence(String itemId) async {
    try {
      final localExists = await _localItemRepository.exists(itemId);
      final cloudExists = _cloudItemRepository != null ? await _cloudItemRepository!.exists(itemId) : false;

      if (!localExists && !cloudExists) {
        throw StateError('Item $itemId non trouvé dans aucun repository');
      }

      if (!localExists) {
        _logger.warning('Item $itemId manquant en local', context: 'ItemsPersistenceService');
      }

      if (_cloudItemRepository != null && !cloudExists) {
        _logger.warning('Item $itemId manquant en cloud', context: 'ItemsPersistenceService');
      }
    } catch (e) {
      _logger.error('Erreur vérification item $itemId: $e', context: 'ItemsPersistenceService');
      rethrow;
    }
  }

  // ==================== MÉTHODES PRIVÉES SPÉCIALISÉES ====================

  Future<List<ListItem>> _getItemsCloudFirst(String listId) async {
    if (_cloudItemRepository == null) {
      return await _localItemRepository.getByListId(listId);
    }

    try {
      return await _cloudItemRepository!.getByListId(listId);
    } catch (e) {
      _logger.warning('Cloud indisponible, fallback local: $e', context: 'ItemsPersistenceService');
      return await _localItemRepository.getByListId(listId);
    }
  }

  Future<List<ListItem>> _getItemsHybrid(String listId) async => await _getItemsCloudFirst(listId);

  Future<void> _saveItemCloudFirst(ListItem item) async => await _localItemRepository.add(item);

  Future<void> _saveItemHybrid(ListItem item) async => await _saveItemCloudFirst(item);

  Future<void> _updateItemHybrid(ListItem item) async => await _localItemRepository.update(item);

  Future<void> _deleteItemCloudFirst(String itemId) async => await _localItemRepository.delete(itemId);

  Future<void> _deleteItemHybrid(String itemId) async => await _deleteItemCloudFirst(itemId);

  Future<void> _rollbackFailedItems(List<ListItem> items) async {
    for (final item in items) {
      try {
        await _localItemRepository.delete(item.id);
      } catch (e) {
        _logger.error('Échec rollback item ${item.id}: $e', context: 'ItemsPersistenceService');
      }
    }
  }
}