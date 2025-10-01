/// Concrete implementations of persistence strategies
/// Each strategy follows SRP and implements specific persistence behavior

import 'package:prioris/core/patterns/persistence_strategy.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Local-only persistence strategy
/// Uses local repositories for offline-first approach
class LocalPersistenceStrategy implements IPersistenceStrategy {
  final CustomListRepository _listRepository;
  final ListItemRepository _itemRepository;
  bool _isInitialized = false;

  LocalPersistenceStrategy({
    required CustomListRepository listRepository,
    required ListItemRepository itemRepository,
  }) : _listRepository = listRepository,
       _itemRepository = itemRepository;

  @override
  String get strategyName => 'local';

  @override
  Future<bool> isAvailable() async {
    try {
      // Test repository availability by attempting a simple operation
      await _listRepository.getAllLists();
      return true;
    } catch (e) {
      LoggerService.instance.warning(
        'Local repositories not available',
        context: 'LocalPersistenceStrategy',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    LoggerService.instance.info(
      'Initializing local persistence strategy',
      context: 'LocalPersistenceStrategy',
    );

    // Perform any initialization if needed
    _isInitialized = true;

    LoggerService.instance.info(
      'Local persistence strategy initialized',
      context: 'LocalPersistenceStrategy',
    );
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    return await _listRepository.getAllLists();
  }

  @override
  Future<CustomList?> getListById(String listId) async {
    return await _listRepository.getListById(listId);
  }

  @override
  Future<void> saveList(CustomList list) async {
    await _listRepository.saveList(list);
  }

  @override
  Future<void> deleteList(String listId) async {
    await _listRepository.deleteList(listId);
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    return await _itemRepository.getByListId(listId);
  }

  @override
  Future<void> saveItem(ListItem item) async {
    await _itemRepository.add(item);
  }

  @override
  Future<void> updateItem(ListItem item) async {
    await _itemRepository.update(item);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _itemRepository.delete(itemId);
  }

  @override
  Future<bool> verifyPersistence(String id) async {
    try {
      final list = await _listRepository.getListById(id);
      return list != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAllData() async {
    final allLists = await _listRepository.getAllLists();
    final allItems = await _itemRepository.getAll();

    // Delete items first to maintain referential integrity
    for (final item in allItems) {
      await _itemRepository.delete(item.id);
    }

    // Then delete lists
    for (final list in allLists) {
      await _listRepository.deleteList(list.id);
    }

    LoggerService.instance.info(
      'Local data cleared: ${allLists.length} lists, ${allItems.length} items',
      context: 'LocalPersistenceStrategy',
    );
  }

  @override
  Future<void> dispose() async {
    LoggerService.instance.debug(
      'Disposing local persistence strategy',
      context: 'LocalPersistenceStrategy',
    );
    _isInitialized = false;
  }
}

/// Adaptive persistence strategy
/// Uses AdaptivePersistenceService for intelligent cloud/local switching
class AdaptivePersistenceStrategy implements IPersistenceStrategy {
  final AdaptivePersistenceService _adaptiveService;
  bool _isInitialized = false;

  AdaptivePersistenceStrategy({
    required AdaptivePersistenceService adaptiveService,
  }) : _adaptiveService = adaptiveService;

  @override
  String get strategyName => 'adaptive';

  @override
  Future<bool> isAvailable() async {
    try {
      // Check if adaptive service is ready
      await _adaptiveService.getAllLists();
      return true;
    } catch (e) {
      LoggerService.instance.warning(
        'Adaptive service not available',
        context: 'AdaptivePersistenceStrategy',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    LoggerService.instance.info(
      'Initializing adaptive persistence strategy',
      context: 'AdaptivePersistenceStrategy',
    );

    // AdaptivePersistenceService should already be initialized
    _isInitialized = true;

    LoggerService.instance.info(
      'Adaptive persistence strategy initialized (mode: ${_adaptiveService.currentMode})',
      context: 'AdaptivePersistenceStrategy',
    );
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    return await _adaptiveService.getAllLists();
  }

  @override
  Future<CustomList?> getListById(String listId) async {
    // AdaptivePersistenceService doesn't have getListById, so we search in all lists
    final allLists = await _adaptiveService.getAllLists();
    try {
      return allLists.firstWhere((list) => list.id == listId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    await _adaptiveService.saveList(list);
  }

  @override
  Future<void> deleteList(String listId) async {
    await _adaptiveService.deleteList(listId);
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    return await _adaptiveService.getItemsByListId(listId);
  }

  @override
  Future<void> saveItem(ListItem item) async {
    await _adaptiveService.saveItem(item);
  }

  @override
  Future<void> updateItem(ListItem item) async {
    await _adaptiveService.updateItem(item);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _adaptiveService.deleteItem(itemId);
  }

  @override
  Future<bool> verifyPersistence(String id) async {
    try {
      final list = await getListById(id);
      return list != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAllData() async {
    // AdaptivePersistenceService doesn't have clearAllData, so we implement it
    final allLists = await _adaptiveService.getAllLists();

    for (final list in allLists) {
      // Delete all items in the list first
      final items = await _adaptiveService.getItemsByListId(list.id);
      for (final item in items) {
        await _adaptiveService.deleteItem(item.id);
      }

      // Then delete the list
      await _adaptiveService.deleteList(list.id);
    }

    LoggerService.instance.info(
      'Adaptive data cleared: ${allLists.length} lists',
      context: 'AdaptivePersistenceStrategy',
    );
  }

  @override
  Future<void> dispose() async {
    LoggerService.instance.debug(
      'Disposing adaptive persistence strategy',
      context: 'AdaptivePersistenceStrategy',
    );

    // AdaptivePersistenceService has its own disposal
    _adaptiveService.dispose();
    _isInitialized = false;
  }
}

/// In-memory persistence strategy
/// For testing and temporary data storage
class InMemoryPersistenceStrategy implements IPersistenceStrategy {
  final Map<String, CustomList> _lists = {};
  final Map<String, ListItem> _items = {};
  bool _isInitialized = false;

  @override
  String get strategyName => 'memory';

  @override
  Future<bool> isAvailable() async {
    return true; // Always available
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    LoggerService.instance.info(
      'Initializing in-memory persistence strategy',
      context: 'InMemoryPersistenceStrategy',
    );

    _isInitialized = true;

    LoggerService.instance.info(
      'In-memory persistence strategy initialized',
      context: 'InMemoryPersistenceStrategy',
    );
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    return _lists.values.toList();
  }

  @override
  Future<CustomList?> getListById(String listId) async {
    return _lists[listId];
  }

  @override
  Future<void> saveList(CustomList list) async {
    _lists[list.id] = list;
  }

  @override
  Future<void> deleteList(String listId) async {
    _lists.remove(listId);

    // Also remove all items in this list
    _items.removeWhere((key, item) => item.listId == listId);
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    return _items.values.where((item) => item.listId == listId).toList();
  }

  @override
  Future<void> saveItem(ListItem item) async {
    _items[item.id] = item;
  }

  @override
  Future<void> updateItem(ListItem item) async {
    _items[item.id] = item;
  }

  @override
  Future<void> deleteItem(String itemId) async {
    _items.remove(itemId);
  }

  @override
  Future<bool> verifyPersistence(String id) async {
    return _lists.containsKey(id) || _items.containsKey(id);
  }

  @override
  Future<void> clearAllData() async {
    final listCount = _lists.length;
    final itemCount = _items.length;

    _lists.clear();
    _items.clear();

    LoggerService.instance.info(
      'In-memory data cleared: $listCount lists, $itemCount items',
      context: 'InMemoryPersistenceStrategy',
    );
  }

  @override
  Future<void> dispose() async {
    LoggerService.instance.debug(
      'Disposing in-memory persistence strategy',
      context: 'InMemoryPersistenceStrategy',
    );

    await clearAllData();
    _isInitialized = false;
  }
}

/// Read-only persistence strategy
/// For scenarios where data should not be modified
class ReadOnlyPersistenceStrategy implements IPersistenceStrategy {
  final IPersistenceStrategy _underlyingStrategy;

  ReadOnlyPersistenceStrategy({
    required IPersistenceStrategy underlyingStrategy,
  }) : _underlyingStrategy = underlyingStrategy;

  @override
  String get strategyName => 'readonly-${_underlyingStrategy.strategyName}';

  @override
  Future<bool> isAvailable() async {
    return await _underlyingStrategy.isAvailable();
  }

  @override
  Future<void> initialize() async {
    await _underlyingStrategy.initialize();
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    return await _underlyingStrategy.getAllLists();
  }

  @override
  Future<CustomList?> getListById(String listId) async {
    return await _underlyingStrategy.getListById(listId);
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    return await _underlyingStrategy.getItemsByListId(listId);
  }

  @override
  Future<bool> verifyPersistence(String id) async {
    return await _underlyingStrategy.verifyPersistence(id);
  }

  // Write operations throw errors in read-only mode

  @override
  Future<void> saveList(CustomList list) async {
    throw UnsupportedError('Write operations not allowed in read-only mode');
  }

  @override
  Future<void> deleteList(String listId) async {
    throw UnsupportedError('Write operations not allowed in read-only mode');
  }

  @override
  Future<void> saveItem(ListItem item) async {
    throw UnsupportedError('Write operations not allowed in read-only mode');
  }

  @override
  Future<void> updateItem(ListItem item) async {
    throw UnsupportedError('Write operations not allowed in read-only mode');
  }

  @override
  Future<void> deleteItem(String itemId) async {
    throw UnsupportedError('Write operations not allowed in read-only mode');
  }

  @override
  Future<void> clearAllData() async {
    throw UnsupportedError('Write operations not allowed in read-only mode');
  }

  @override
  Future<void> dispose() async {
    await _underlyingStrategy.dispose();
  }
}