/// **DEDUPLICATION SERVICE** - SRP Specialized Component
///
/// **LOT 9** : Service spécialisé pour déduplication de données
/// **SRP** : Responsabilité unique = Détecter et éviter les doublons
/// **Taille** : <100 lignes (extraction depuis God Class 923 lignes)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import '../interfaces/unified_persistence_interface.dart';

/// Service spécialisé pour la déduplication des données
///
/// **SRP** : Déduplication et détection de doublons uniquement
/// **DIP** : Injecte ses dépendances (repositories, logger, config)
/// **OCP** : Extensible via nouvelles stratégies de déduplication
class DeduplicationService {
  final CustomListRepository _localRepository;
  final ListItemRepository _localItemRepository;
  final ILogger _logger;
  final IPersistenceConfiguration _config;

  const DeduplicationService({
    required CustomListRepository localRepository,
    required ListItemRepository localItemRepository,
    required ILogger logger,
    required IPersistenceConfiguration config,
  }) : _localRepository = localRepository,
       _localItemRepository = localItemRepository,
       _logger = logger,
       _config = config;

  /// Sauvegarde une liste avec déduplication automatique
  Future<void> saveListWithDeduplication(CustomList list, CustomListRepository repository) async {
    if (!_config.enableDeduplication) {
      await repository.add(list);
      return;
    }

    try {
      final existing = await repository.getListById(list.id);
      if (existing != null) {
        _logger.debug('Liste dupliquée détectée: ${list.id}', context: 'DeduplicationService');

        // Comparer et fusionner si nécessaire
        final merged = _mergeCustomLists(existing, list);
        await repository.updateList(merged);
      } else {
        await repository.add(list);
      }

      _logger.debug('Liste sauvegardée avec déduplication: ${list.id}', context: 'DeduplicationService');
    } catch (e) {
      _logger.error('Erreur déduplication liste ${list.id}: $e', context: 'DeduplicationService');
      rethrow;
    }
  }

  /// Sauvegarde un item avec déduplication automatique
  Future<void> saveItemWithDeduplication(ListItem item, ListItemRepository repository) async {
    if (!_config.enableDeduplication) {
      await repository.add(item);
      return;
    }

    try {
      final existing = await repository.getById(item.id);
      if (existing != null) {
        _logger.debug('Item dupliqué détecté: ${item.id}', context: 'DeduplicationService');

        // Comparer et fusionner si nécessaire
        final merged = _mergeListItems(existing, item);
        await repository.update(merged);
      } else {
        await repository.add(item);
      }

      _logger.debug('Item sauvegardé avec déduplication: ${item.id}', context: 'DeduplicationService');
    } catch (e) {
      _logger.error('Erreur déduplication item ${item.id}: $e', context: 'DeduplicationService');
      rethrow;
    }
  }

  /// Détecte les doublons dans une liste de CustomList
  Future<List<CustomList>> detectDuplicateLists(List<CustomList> lists) async {
    final duplicates = <CustomList>[];
    final seen = <String>{};

    for (final list in lists) {
      if (seen.contains(list.id)) {
        duplicates.add(list);
        _logger.warning('Doublon de liste détecté: ${list.id}', context: 'DeduplicationService');
      } else {
        seen.add(list.id);
      }
    }

    return duplicates;
  }

  /// Détecte les doublons dans une liste de ListItem
  Future<List<ListItem>> detectDuplicateItems(List<ListItem> items) async {
    final duplicates = <ListItem>[];
    final seen = <String>{};

    for (final item in items) {
      if (seen.contains(item.id)) {
        duplicates.add(item);
        _logger.warning('Doublon d\'item détecté: ${item.id}', context: 'DeduplicationService');
      } else {
        seen.add(item.id);
      }
    }

    return duplicates;
  }

  // ==================== MÉTHODES PRIVÉES DE FUSION ====================

  /// Fusionne deux CustomList en priorisant les données les plus récentes
  CustomList _mergeCustomLists(CustomList existing, CustomList incoming) {
    // Prioriser les données les plus récentes basées sur updatedAt
    final useIncoming = incoming.updatedAt.isAfter(existing.updatedAt);

    return CustomList(
      id: existing.id, // ID reste le même
      name: useIncoming ? incoming.name : existing.name,
      description: useIncoming ? incoming.description : existing.description,
      type: useIncoming ? incoming.type : existing.type,
      color: useIncoming ? incoming.color : existing.color,
      icon: useIncoming ? incoming.icon : existing.icon,
      createdAt: existing.createdAt, // Date création conservée
      updatedAt: useIncoming ? incoming.updatedAt : existing.updatedAt,
      settings: useIncoming ? incoming.settings : existing.settings,
    );
  }

  /// Fusionne deux ListItem en priorisant les données les plus récentes
  ListItem _mergeListItems(ListItem existing, ListItem incoming) {
    // Prioriser les données les plus récentes basées sur updatedAt
    final useIncoming = incoming.updatedAt.isAfter(existing.updatedAt);

    return ListItem(
      id: existing.id, // ID reste le même
      title: useIncoming ? incoming.title : existing.title,
      description: useIncoming ? incoming.description : existing.description,
      isCompleted: useIncoming ? incoming.isCompleted : existing.isCompleted,
      priority: useIncoming ? incoming.priority : existing.priority,
      listId: existing.listId, // listId conservé
      createdAt: existing.createdAt, // Date création conservée
      updatedAt: useIncoming ? incoming.updatedAt : existing.updatedAt,
      dueDate: useIncoming ? incoming.dueDate : existing.dueDate,
      tags: useIncoming ? incoming.tags : existing.tags,
    );
  }
}