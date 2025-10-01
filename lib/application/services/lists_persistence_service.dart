/// SOLID-compliant persistence service implementation
/// Responsibility: Pure persistence operations without business logic

import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Strategy pattern for different persistence modes
enum PersistenceStrategy {
  adaptive,
  local,
  cloud,
}

/// Concrete implementation of IListsPersistenceService following SRP
/// Uses strategy pattern to delegate to appropriate persistence implementation
class ListsPersistenceService implements IListsPersistenceService {
  final AdaptivePersistenceService? _adaptiveService;
  final CustomListRepository? _localListRepository;
  final ListItemRepository? _localItemRepository;
  final PersistenceStrategy _strategy;

  const ListsPersistenceService.adaptive(
    AdaptivePersistenceService adaptiveService,
  ) : _adaptiveService = adaptiveService,
      _localListRepository = null,
      _localItemRepository = null,
      _strategy = PersistenceStrategy.adaptive;

  const ListsPersistenceService.local(
    CustomListRepository localListRepository,
    ListItemRepository localItemRepository,
  ) : _adaptiveService = null,
      _localListRepository = localListRepository,
      _localItemRepository = localItemRepository,
      _strategy = PersistenceStrategy.local;

  @override
  Future<List<CustomList>> getAllLists() async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          return await _adaptiveService!.getAllLists();
        case PersistenceStrategy.local:
          return await _localListRepository!.getAllLists();
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }
    } catch (e) {
      LoggerService.instance.error(
        'Failed to get all lists',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<CustomList?> getListById(String listId) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          // Adaptive service doesn't have getListById, fall back to local
          return await _getListByIdFallback(listId);
        case PersistenceStrategy.local:
          return await _localListRepository!.getListById(listId);
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }
    } catch (e) {
      LoggerService.instance.error(
        'Failed to get list by ID: $listId',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          await _adaptiveService!.saveList(list);
          break;
        case PersistenceStrategy.local:
          await _localListRepository!.saveList(list);
          break;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }

      LoggerService.instance.debug(
        'List saved: ${list.name}',
        context: 'ListsPersistenceService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to save list: ${list.name}',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteList(String listId) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          await _adaptiveService!.deleteList(listId);
          break;
        case PersistenceStrategy.local:
          await _localListRepository!.deleteList(listId);
          break;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }

      LoggerService.instance.debug(
        'List deleted: $listId',
        context: 'ListsPersistenceService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to delete list: $listId',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          return await _adaptiveService!.getItemsByListId(listId);
        case PersistenceStrategy.local:
          return await _localItemRepository!.getByListId(listId);
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }
    } catch (e) {
      LoggerService.instance.error(
        'Failed to get items for list: $listId',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> saveItem(ListItem item) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          await _adaptiveService!.saveItem(item);
          break;
        case PersistenceStrategy.local:
          await _localItemRepository!.add(item);
          break;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }

      LoggerService.instance.debug(
        'Item saved: ${item.title}',
        context: 'ListsPersistenceService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to save item: ${item.title}',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateItem(ListItem item) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          await _adaptiveService!.updateItem(item);
          break;
        case PersistenceStrategy.local:
          await _localItemRepository!.update(item);
          break;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }

      LoggerService.instance.debug(
        'Item updated: ${item.title}',
        context: 'ListsPersistenceService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update item: ${item.title}',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          await _adaptiveService!.deleteItem(itemId);
          break;
        case PersistenceStrategy.local:
          await _localItemRepository!.delete(itemId);
          break;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }

      LoggerService.instance.debug(
        'Item deleted: $itemId',
        context: 'ListsPersistenceService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to delete item: $itemId',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> verifyPersistence(String id) async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          // For adaptive, check if list exists in local repository
          if (_localListRepository != null) {
            final list = await _localListRepository!.getListById(id);
            return list != null;
          }
          return false;
        case PersistenceStrategy.local:
          final list = await _localListRepository!.getListById(id);
          return list != null;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }
    } catch (e) {
      LoggerService.instance.error(
        'Failed to verify persistence for: $id',
        context: 'ListsPersistenceService',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          // Adaptive service doesn't have clearAllData method
          // Fallback to clearing both repositories if available
          await _clearAllDataFallback();
          break;
        case PersistenceStrategy.local:
          await _clearLocalData();
          break;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }

      LoggerService.instance.info(
        'All data cleared',
        context: 'ListsPersistenceService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to clear all data',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> forceReload() async {
    try {
      switch (_strategy) {
        case PersistenceStrategy.adaptive:
          // Adaptive service doesn't have force reload, but we can
          // trigger a reload by getting all lists
          await getAllLists();
          break;
        case PersistenceStrategy.local:
          // For local strategy, reload means get fresh data
          await getAllLists();
          break;
        case PersistenceStrategy.cloud:
          throw UnimplementedError('Cloud strategy not implemented');
      }

      LoggerService.instance.debug(
        'Force reload completed',
        context: 'ListsPersistenceService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to force reload',
        context: 'ListsPersistenceService',
        error: e,
      );
      rethrow;
    }
  }

  /// Fallback method to get list by ID when adaptive service doesn't support it
  Future<CustomList?> _getListByIdFallback(String listId) async {
    final allLists = await getAllLists();
    try {
      return allLists.firstWhere((list) => list.id == listId);
    } catch (e) {
      return null; // Not found
    }
  }

  /// Fallback method to clear all data
  Future<void> _clearAllDataFallback() async {
    if (_localListRepository != null && _localItemRepository != null) {
      await _clearLocalData();
    }
  }

  /// Clear local repository data
  Future<void> _clearLocalData() async {
    final allLists = await _localListRepository!.getAllLists();
    final allItems = await _localItemRepository!.getAll();

    // Delete all items first
    for (final item in allItems) {
      await _localItemRepository!.delete(item.id);
    }

    // Then delete all lists
    for (final list in allLists) {
      await _localListRepository!.deleteList(list.id);
    }
  }
}