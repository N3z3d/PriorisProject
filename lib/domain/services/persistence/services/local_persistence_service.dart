/// **LOCAL PERSISTENCE SERVICE** - SOLID Implementation
///
/// **LOT 3.1** : Service spécialisé pour les opérations locales uniquement
/// **Responsabilité unique** : Gestion des données locales avec déduplication
/// **Taille** : <250 lignes (contrainte CLAUDE.md respectée)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/local_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';

/// **Service de persistance locale**
///
/// **SRP** : Gestion exclusive des opérations locales
/// **OCP** : Extensible via injection de dépendances
/// **DIP** : Dépend d'abstractions (repositories et logger)
class LocalPersistenceService implements ILocalPersistenceService {
  final CustomListRepository _localRepository;
  final ListItemRepository _localItemRepository;
  final IPersistenceValidator _validator;
  final ILogger _logger;

  /// **Constructeur avec injection de dépendances** (DIP)
  const LocalPersistenceService({
    required CustomListRepository localRepository,
    required ListItemRepository localItemRepository,
    required IPersistenceValidator validator,
    required ILogger logger,
  }) : _localRepository = localRepository,
       _localItemRepository = localItemRepository,
       _validator = validator,
       _logger = logger;

  // === List Operations ===

  @override
  Future<List<CustomList>> getLocalLists() async {
    _logger.debug('Récupération listes locales', context: 'LocalPersistenceService');

    try {
      final lists = await _localRepository.getAllLists();
      final sanitizedLists = _validator.sanitizeLists(lists);

      _logger.info('${sanitizedLists.length} listes locales récupérées', context: 'LocalPersistenceService');
      return sanitizedLists;
    } catch (e) {
      _logger.error('Erreur récupération listes locales', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> saveLocalList(CustomList list) async {
    if (!_validator.validateList(list)) {
      throw UnifiedPersistenceException(
        'Liste invalide pour sauvegarde locale',
        operation: 'saveLocalList',
        id: list.id,
        mode: PersistenceMode.localFirst,
      );
    }

    try {
      await _saveListWithDeduplication(list);
      _logger.info('Liste "${list.name}" sauvegardée localement', context: 'LocalPersistenceService');
    } catch (e) {
      _logger.error('Échec sauvegarde locale liste "${list.name}"', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateLocalList(CustomList list) async {
    if (!_validator.validateList(list)) {
      throw UnifiedPersistenceException(
        'Liste invalide pour mise à jour locale',
        operation: 'updateLocalList',
        id: list.id,
        mode: PersistenceMode.localFirst,
      );
    }

    try {
      await _localRepository.updateList(list);
      _logger.info('Liste "${list.name}" mise à jour localement', context: 'LocalPersistenceService');
    } catch (e) {
      _logger.error('Échec mise à jour locale liste "${list.name}"', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteLocalList(String listId) async {
    try {
      await _localRepository.deleteList(listId);
      _logger.info('Liste $listId supprimée localement', context: 'LocalPersistenceService');
    } catch (e) {
      _logger.error('Échec suppression locale liste $listId', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  // === Item Operations ===

  @override
  Future<List<ListItem>> getLocalItems(String listId) async {
    try {
      final items = await _localItemRepository.getByListId(listId);
      final sanitizedItems = _validator.sanitizeItems(items);

      _logger.debug('${sanitizedItems.length} items locaux récupérés pour liste $listId', context: 'LocalPersistenceService');
      return sanitizedItems;
    } catch (e) {
      _logger.error('Erreur récupération items locaux pour liste $listId', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> saveLocalItem(ListItem item) async {
    if (!_validator.validateListItem(item)) {
      throw UnifiedPersistenceException(
        'Item invalide pour sauvegarde locale',
        operation: 'saveLocalItem',
        id: item.id,
        mode: PersistenceMode.localFirst,
      );
    }

    try {
      await _saveItemWithDeduplication(item);
      _logger.info('Item "${item.title}" sauvegardé localement', context: 'LocalPersistenceService');
    } catch (e) {
      _logger.error('Échec sauvegarde locale item "${item.title}"', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateLocalItem(ListItem item) async {
    if (!_validator.validateListItem(item)) {
      throw UnifiedPersistenceException(
        'Item invalide pour mise à jour locale',
        operation: 'updateLocalItem',
        id: item.id,
        mode: PersistenceMode.localFirst,
      );
    }

    try {
      await _localItemRepository.update(item);
      _logger.info('Item "${item.title}" mis à jour localement', context: 'LocalPersistenceService');
    } catch (e) {
      _logger.error('Échec mise à jour locale item "${item.title}"', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteLocalItem(String itemId) async {
    try {
      await _localItemRepository.delete(itemId);
      _logger.info('Item $itemId supprimé localement', context: 'LocalPersistenceService');
    } catch (e) {
      _logger.error('Échec suppression locale item $itemId', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  // === Batch Operations ===

  @override
  Future<void> saveMultipleLocalItems(List<ListItem> items) async {
    if (items.isEmpty) return;

    final savedItems = <ListItem>[];

    try {
      for (final item in items) {
        await saveLocalItem(item);
        savedItems.add(item);
      }

      _logger.info('${items.length} items sauvegardés localement avec succès', context: 'LocalPersistenceService');
    } catch (e) {
      // Rollback en cas d'échec partiel
      await _rollbackItems(savedItems);
      throw UnifiedPersistenceException(
        'Échec sauvegarde locale bulk (rollback effectué)',
        operation: 'saveMultipleLocalItems',
        mode: PersistenceMode.localFirst,
        cause: e,
      );
    }
  }

  @override
  Future<void> clearLocalData() async {
    _logger.info('Début effacement données locales', context: 'LocalPersistenceService');

    try {
      // Récupérer toutes les données
      final allLists = await getLocalLists();
      final allItems = <ListItem>[];

      for (final list in allLists) {
        final items = await getLocalItems(list.id);
        allItems.addAll(items);
      }

      // Supprimer tous les items
      for (final item in allItems) {
        await deleteLocalItem(item.id);
      }

      // Supprimer toutes les listes
      for (final list in allLists) {
        await deleteLocalList(list.id);
      }

      _logger.info('Données locales effacées avec succès', context: 'LocalPersistenceService');
    } catch (e) {
      _logger.error('Échec effacement données locales', context: 'LocalPersistenceService', error: e);
      rethrow;
    }
  }

  // === Verification ===

  @override
  Future<bool> verifyLocalList(String listId) async {
    try {
      final list = await _localRepository.getListById(listId);
      final exists = list != null;

      _logger.debug('Vérification liste locale $listId: ${exists ? "existe" : "inexistante"}', context: 'LocalPersistenceService');
      return exists;
    } catch (e) {
      _logger.error('Erreur vérification liste locale $listId', context: 'LocalPersistenceService', error: e);
      return false;
    }
  }

  @override
  Future<bool> verifyLocalItem(String itemId) async {
    try {
      final item = await _localItemRepository.getById(itemId);
      final exists = item != null;

      _logger.debug('Vérification item local $itemId: ${exists ? "existe" : "inexistant"}', context: 'LocalPersistenceService');
      return exists;
    } catch (e) {
      _logger.error('Erreur vérification item local $itemId', context: 'LocalPersistenceService', error: e);
      return false;
    }
  }

  // === Private Helper Methods ===

  Future<void> _saveListWithDeduplication(CustomList list) async {
    try {
      await _localRepository.saveList(list);
    } catch (e) {
      if (e.toString().contains('existe déjà')) {
        await _localRepository.updateList(list);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _saveItemWithDeduplication(ListItem item) async {
    try {
      await _localItemRepository.add(item);
    } catch (e) {
      if (e.toString().contains('existe déjà')) {
        await _localItemRepository.update(item);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _rollbackItems(List<ListItem> items) async {
    for (final item in items) {
      try {
        await deleteLocalItem(item.id);
      } catch (e) {
        _logger.warning('Erreur rollback item ${item.id}', context: 'LocalPersistenceService');
      }
    }
  }
}