/// **LISTS PERSISTENCE SERVICE** - SRP Specialized Component
///
/// **LOT 9** : Service spécialisé pour opérations CRUD listes uniquement
/// **SRP** : Responsabilité unique = Persistance des CustomList
/// **Taille** : <150 lignes (extraction depuis God Class 923 lignes)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import '../interfaces/unified_persistence_interface.dart';

/// Service spécialisé pour la persistance des listes
///
/// **SRP** : Gestion CRUD des CustomList uniquement
/// **DIP** : Injecte ses dépendances (repository, logger, validator)
/// **OCP** : Extensible via PersistenceMode et stratégies
class ListsPersistenceService {
  final CustomListRepository _localRepository;
  final CustomListRepository? _cloudRepository;
  final ILogger _logger;
  final IPersistenceValidator _validator;
  final IPersistenceConfiguration _config;

  const ListsPersistenceService({
    required CustomListRepository localRepository,
    CustomListRepository? cloudRepository,
    required ILogger logger,
    required IPersistenceValidator validator,
    required IPersistenceConfiguration config,
  }) : _localRepository = localRepository,
       _cloudRepository = cloudRepository,
       _logger = logger,
       _validator = validator,
       _config = config;

  /// Récupère toutes les listes selon le mode de persistance
  Future<List<CustomList>> getAllLists({
    PersistenceMode? mode,
  }) async {
    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          return await _localRepository.getAll();
        case PersistenceMode.cloudFirst:
          return await _getListsCloudFirst();
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          return await _getListsHybrid();
      }
    } catch (e) {
      _logger.error('Erreur récupération listes: $e', context: 'ListsPersistenceService');
      // Fallback vers local en cas d'erreur
      return await _localRepository.getAll();
    }
  }

  /// Sauvegarde une liste selon le mode de persistance
  Future<void> saveList(CustomList list, {PersistenceMode? mode}) async {
    if (!_validator.validateList(list)) {
      throw ArgumentError('Liste invalide pour sauvegarde');
    }

    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          await _localRepository.add(list);
          break;
        case PersistenceMode.cloudFirst:
          await _saveListCloudFirst(list);
          break;
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          await _saveListHybrid(list);
          break;
      }

      _logger.debug('Liste sauvegardée: ${list.id}', context: 'ListsPersistenceService');
    } catch (e) {
      _logger.error('Erreur sauvegarde liste ${list.id}: $e', context: 'ListsPersistenceService');
      rethrow;
    }
  }

  /// Met à jour une liste selon le mode de persistance
  Future<void> updateList(CustomList list, {PersistenceMode? mode}) async {
    if (!_validator.validateList(list)) {
      throw ArgumentError('Liste invalide pour mise à jour');
    }

    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          await _localRepository.updateList(list);
          break;
        case PersistenceMode.cloudFirst:
          await _cloudRepository?.updateList(list);
          await _localRepository.updateList(list);
          break;
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          await _updateListHybrid(list);
          break;
      }

      _logger.debug('Liste mise à jour: ${list.id}', context: 'ListsPersistenceService');
    } catch (e) {
      _logger.error('Erreur mise à jour liste ${list.id}: $e', context: 'ListsPersistenceService');
      rethrow;
    }
  }

  /// Supprime une liste selon le mode de persistance
  Future<void> deleteList(String listId, {PersistenceMode? mode}) async {
    if (listId.trim().isEmpty) {
      throw ArgumentError('ID liste requis pour suppression');
    }

    final effectiveMode = mode ?? _config.defaultMode;

    try {
      switch (effectiveMode) {
        case PersistenceMode.localOnly:
          await _localRepository.deleteList(listId);
          break;
        case PersistenceMode.cloudFirst:
          await _deleteListCloudFirst(listId);
          break;
        case PersistenceMode.localFirst:
        case PersistenceMode.hybrid:
          await _deleteListHybrid(listId);
          break;
      }

      _logger.debug('Liste supprimée: $listId', context: 'ListsPersistenceService');
    } catch (e) {
      _logger.error('Erreur suppression liste $listId: $e', context: 'ListsPersistenceService');
      rethrow;
    }
  }

  /// Vérifie la persistance d'une liste
  Future<void> verifyListPersistence(String listId) async {
    try {
      final localExists = await _localRepository.exists(listId);
      final cloudExists = _cloudRepository != null ? await _cloudRepository!.exists(listId) : false;

      if (!localExists && !cloudExists) {
        throw StateError('Liste $listId non trouvée dans aucun repository');
      }

      if (!localExists) {
        _logger.warning('Liste $listId manquante en local', context: 'ListsPersistenceService');
      }

      if (_cloudRepository != null && !cloudExists) {
        _logger.warning('Liste $listId manquante en cloud', context: 'ListsPersistenceService');
      }
    } catch (e) {
      _logger.error('Erreur vérification liste $listId: $e', context: 'ListsPersistenceService');
      rethrow;
    }
  }

  // ==================== MÉTHODES PRIVÉES SPÉCIALISÉES ====================

  Future<List<CustomList>> _getListsCloudFirst() async {
    if (_cloudRepository == null) {
      return await _localRepository.getAll();
    }

    try {
      return await _cloudRepository!.getAll();
    } catch (e) {
      _logger.warning('Cloud indisponible, fallback local: $e', context: 'ListsPersistenceService');
      return await _localRepository.getAll();
    }
  }

  Future<List<CustomList>> _getListsHybrid() async => await _getListsCloudFirst();

  Future<void> _saveListCloudFirst(CustomList list) async {
    await _localRepository.add(list);
    if (_cloudRepository != null) {
      try {
        await _cloudRepository!.add(list);
      } catch (e) {
        _logger.warning('Échec sync cloud pour liste ${list.id}: $e', context: 'ListsPersistenceService');
      }
    }
  }

  Future<void> _saveListHybrid(CustomList list) async => await _saveListCloudFirst(list);

  Future<void> _updateListHybrid(CustomList list) async => await _localRepository.updateList(list);

  Future<void> _deleteListCloudFirst(String listId) async => await _localRepository.deleteList(listId);

  Future<void> _deleteListHybrid(String listId) async => await _deleteListCloudFirst(listId);
}