import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Persistence modes supported by the adaptive service.
enum PersistenceMode { localFirst, cloudFirst }

/// Legacy-compatible adaptive persistence service used by older tests.
///
/// The implementation focuses on deterministic behaviours that the historical
/// test-suite asserted (duplicate handling, cloud fallbacks, permission
/// resilience). It wraps the current repository abstractions so that legacy
/// code keeps compiling while newer orchestration layers can continue to rely
/// on the refactored managers.
class AdaptivePersistenceService {
  final CustomListRepository localRepository;
  final CustomListRepository cloudRepository;
  final ListItemRepository localItemRepository;
  final ListItemRepository cloudItemRepository;

  PersistenceMode _currentMode = PersistenceMode.localFirst;
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  AdaptivePersistenceService({
    required this.localRepository,
    required this.cloudRepository,
    required this.localItemRepository,
    required this.cloudItemRepository,
  });

  PersistenceMode get currentMode => _currentMode;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> initialize({bool? isAuthenticated}) async {
    final auth = isAuthenticated ?? false;
    _currentMode = auth ? PersistenceMode.cloudFirst : PersistenceMode.localFirst;
    _isAuthenticated = auth;
    _isInitialized = true;
  }

  Future<void> updateAuthenticationState({required bool isAuthenticated}) async {
    _isAuthenticated = isAuthenticated;
    _currentMode = isAuthenticated ? PersistenceMode.cloudFirst : PersistenceMode.localFirst;
    _isInitialized = true;
  }

  Future<List<CustomList>> getAllLists() async {
    final localLists = await localRepository.getAllLists();
    if (!_shouldUseCloud()) {
      return localLists;
    }

    final cloudLists = await cloudRepository.getAllLists();
    return _mergeLists(localLists, cloudLists);
  }

  Future<List<CustomList>> getLists() => getAllLists();

  Future<void> saveList(CustomList list) async {
    await localRepository.saveList(list);

    if (_shouldUseCloud()) {
      try {
        await cloudRepository.saveList(list);
      } catch (error) {
        await _handleCloudListSaveError(list, error);
      }
    }
  }

  Future<void> deleteList(String listId) async {
    if (_shouldUseCloud()) {
      try {
        await cloudRepository.deleteList(listId);
      } catch (error) {
        if (!_isPermissionError(error)) {
          rethrow;
        }
      }
    }

    await localRepository.deleteList(listId);
  }

  Future<List<ListItem>> getItemsByListId(String listId) async {
    final localItems = await localItemRepository.getByListId(listId);
    if (!_shouldUseCloud()) {
      return localItems;
    }

    final cloudItems = await cloudItemRepository.getByListId(listId);
    return _mergeItems(localItems, cloudItems);
  }

  Future<List<ListItem>> getListItems(String listId) => getItemsByListId(listId);

  Future<void> saveItem(ListItem item) async {
    await localItemRepository.add(item);

    if (_shouldUseCloud()) {
      try {
        await cloudItemRepository.add(item);
      } catch (error) {
        if (_isDuplicateError(error)) {
          await cloudItemRepository.update(item);
        } else if (_isPermissionError(error)) {
          return;
        } else {
          rethrow;
        }
      }
    }
  }

  Future<void> updateItem(ListItem item) async {
    await localItemRepository.update(item);

    if (_shouldUseCloud()) {
      try {
        await cloudItemRepository.update(item);
      } catch (error) {
        if (_isPermissionError(error)) {
          await _ensureLocalItemExists(item);
        } else {
          rethrow;
        }
      }
    }
  }

  Future<void> deleteItem(String itemId) async {
    if (_shouldUseCloud()) {
      try {
        await cloudItemRepository.delete(itemId);
      } catch (error) {
        if (!_isPermissionError(error)) {
          rethrow;
        }
      }
    }

    await localItemRepository.delete(itemId);
  }

  Future<void> dispose() async {}

  bool _shouldUseCloud() =>
      _isInitialized && _currentMode == PersistenceMode.cloudFirst;

  Future<void> _handleCloudListSaveError(
    CustomList list,
    Object error,
  ) async {
    if (_isDuplicateError(error)) {
      await cloudRepository.updateList(list);
      return;
    }

    if (_isPermissionError(error)) {
      return;
    }

    throw error;
  }

  Future<void> _ensureLocalItemExists(ListItem item) async {
    final existing = await localItemRepository.getById(item.id);
    if (existing == null) {
      await localItemRepository.add(item);
    }
  }

  bool _isDuplicateError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('duplicate') ||
        message.contains('exists') ||
        message.contains('already');
  }

  bool _isPermissionError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('403') ||
        message.contains('permission') ||
        message.contains('forbidden');
  }

  List<CustomList> _mergeLists(
    List<CustomList> local,
    List<CustomList> cloud,
  ) {
    final map = <String, CustomList>{for (final list in local) list.id: list};
    for (final list in cloud) {
      final existing = map[list.id];
      if (existing == null) {
        map[list.id] = list;
      } else {
        map[list.id] = _preferMostRecent(existing, list);
      }
    }
    return map.values.toList();
  }

  CustomList _preferMostRecent(CustomList a, CustomList b) {
    if (b.updatedAt.isAfter(a.updatedAt)) {
      return b;
    }
    if (a.updatedAt.isAfter(b.updatedAt)) {
      return a;
    }
    return b;
  }

  List<ListItem> _mergeItems(
    List<ListItem> local,
    List<ListItem> cloud,
  ) {
    final map = <String, ListItem>{for (final item in local) item.id: item};
    for (final item in cloud) {
      final existing = map[item.id];
      if (existing == null) {
        map[item.id] = item;
      } else {
        map[item.id] = _preferLatestItem(existing, item);
      }
    }
    return map.values.toList();
  }

  ListItem _preferLatestItem(ListItem a, ListItem b) {
    final aTime = a.lastChosenAt ?? a.completedAt ?? a.createdAt;
    final bTime = b.lastChosenAt ?? b.completedAt ?? b.createdAt;
    if (bTime.isAfter(aTime)) {
      return b;
    }
    if (aTime.isAfter(bTime)) {
      return a;
    }
    return b;
  }
}

