import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/list/repositories/custom_list_repository.dart';
import 'package:prioris/domain/list/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeCustomListRepository extends CustomListRepository {
  final _lists = <String, CustomList>{};
  int saveCount = 0;
  int updateCount = 0;
  int deleteCount = 0;

  @override
  Future<List<CustomList>> getAllLists() async => _lists.values.toList();

  @override
  Future<CustomList?> getListById(String id) async => _lists[id];

  @override
  Future<void> saveList(CustomList list) async {
    saveCount++;
    _lists[list.id] = list;
  }

  @override
  Future<void> updateList(CustomList list) async {
    updateCount++;
    if (_lists.containsKey(list.id)) _lists[list.id] = list;
  }

  @override
  Future<void> deleteList(String id) async {
    deleteCount++;
    _lists.remove(id);
  }

  @override
  Future<void> clearAllLists() async => _lists.clear();

  @override
  Future<List<CustomList>> getListsByType(ListType type) async =>
      _lists.values.where((l) => l.type == type).toList();

  @override
  Future<List<CustomList>> searchListsByName(String q) async =>
      _lists.values
          .where((l) => l.name.toLowerCase().contains(q.toLowerCase()))
          .toList();

  @override
  Future<List<CustomList>> searchListsByDescription(String q) async =>
      _lists.values
          .where((l) =>
              l.description?.toLowerCase().contains(q.toLowerCase()) ?? false)
          .toList();
}

class _DuplicateOnSaveListRepository extends _FakeCustomListRepository {
  @override
  Future<void> saveList(CustomList list) async {
    if (_lists.containsKey(list.id)) throw Exception('duplicate entry');
    saveCount++;
    _lists[list.id] = list;
  }
}

class _FakeListItemRepository implements ListItemRepository {
  final _items = <String, ListItem>{};
  int addCount = 0;
  int updateCount = 0;
  int deleteCount = 0;

  @override
  Future<List<ListItem>> getAll() async => _items.values.toList();

  @override
  Future<ListItem?> getById(String id) async => _items[id];

  @override
  Future<ListItem> add(ListItem item) async {
    if (_items.containsKey(item.id)) throw Exception('duplicate');
    addCount++;
    _items[item.id] = item;
    return item;
  }

  @override
  Future<ListItem> update(ListItem item) async {
    updateCount++;
    _items[item.id] = item;
    return item;
  }

  @override
  Future<void> delete(String id) async {
    deleteCount++;
    _items.remove(id);
  }

  @override
  Future<List<ListItem>> getByListId(String listId) async =>
      _items.values.where((i) => i.listId == listId).toList();
}

class _PermissionItemRepository extends _FakeListItemRepository {
  @override
  Future<ListItem> add(ListItem item) => throw Exception('403 forbidden');

  @override
  Future<void> delete(String id) => throw Exception('permission denied');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CustomList _makeList({
  required String id,
  required String name,
  DateTime? updatedAt,
}) {
  final now = DateTime(2024, 1, 1);
  return CustomList(
    id: id,
    name: name,
    type: ListType.TODO,
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}

ListItem _makeItem({
  required String id,
  required String listId,
  DateTime? lastChosenAt,
}) {
  return ListItem(
    id: id,
    title: 'Item $id',
    listId: listId,
    createdAt: DateTime(2024, 1, 1),
    lastChosenAt: lastChosenAt,
  );
}

AdaptivePersistenceService _makeService({
  _FakeCustomListRepository? localList,
  _FakeCustomListRepository? cloudList,
  _FakeListItemRepository? localItem,
  _FakeListItemRepository? cloudItem,
}) {
  return AdaptivePersistenceService(
    localRepository: localList ?? _FakeCustomListRepository(),
    cloudRepository: cloudList ?? _FakeCustomListRepository(),
    localItemRepository: localItem ?? _FakeListItemRepository(),
    cloudItemRepository: cloudItem ?? _FakeListItemRepository(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('initialize / updateAuthenticationState', () {
    test('mode par défaut est localFirst avant initialize', () {
      final svc = _makeService();
      expect(svc.currentMode, equals(PersistenceMode.localFirst));
    });

    test('initialize(isAuthenticated: true) bascule en cloudFirst', () async {
      final svc = _makeService();
      await svc.initialize(isAuthenticated: true);
      expect(svc.currentMode, equals(PersistenceMode.cloudFirst));
    });

    test('updateAuthenticationState(false) repasse en localFirst', () async {
      final svc = _makeService();
      await svc.initialize(isAuthenticated: true);
      await svc.updateAuthenticationState(isAuthenticated: false);
      expect(svc.currentMode, equals(PersistenceMode.localFirst));
    });
  });

  group('mode localFirst (non authentifié)', () {
    late _FakeCustomListRepository localList;
    late _FakeCustomListRepository cloudList;
    late AdaptivePersistenceService svc;

    setUp(() {
      localList = _FakeCustomListRepository();
      cloudList = _FakeCustomListRepository();
      svc = _makeService(localList: localList, cloudList: cloudList);
      // localFirst par défaut — pas besoin d'appeler initialize
    });

    test('getAllLists ne lit que le local', () async {
      await localList.saveList(_makeList(id: 'l1', name: 'Local'));
      await cloudList.saveList(_makeList(id: 'l2', name: 'Cloud'));
      final result = await svc.getAllLists();
      expect(result.map((l) => l.id), contains('l1'));
      expect(result.map((l) => l.id), isNot(contains('l2')));
    });

    test('saveList écrit uniquement en local', () async {
      await svc.saveList(_makeList(id: 'l1', name: 'Test'));
      expect(localList.saveCount, equals(1));
      expect(cloudList.saveCount, equals(0));
    });

    test('deleteList opère uniquement en local', () async {
      await localList.saveList(_makeList(id: 'l1', name: 'Test'));
      await svc.deleteList('l1');
      expect(localList.deleteCount, equals(1));
      expect(cloudList.deleteCount, equals(0));
    });
  });

  group('mode cloudFirst (authentifié)', () {
    late _FakeCustomListRepository localList;
    late _FakeCustomListRepository cloudList;
    late AdaptivePersistenceService svc;

    setUp(() async {
      localList = _FakeCustomListRepository();
      cloudList = _FakeCustomListRepository();
      svc = _makeService(localList: localList, cloudList: cloudList);
      await svc.initialize(isAuthenticated: true);
    });

    test('getAllLists fusionne local + cloud', () async {
      await localList.saveList(_makeList(id: 'l1', name: 'Local'));
      await cloudList.saveList(_makeList(id: 'l2', name: 'Cloud'));
      final result = await svc.getAllLists();
      final ids = result.map((l) => l.id).toSet();
      expect(ids, containsAll(['l1', 'l2']));
    });

    test('saveList écrit local puis cloud', () async {
      await svc.saveList(_makeList(id: 'l1', name: 'Test'));
      expect(localList.saveCount, equals(1));
      expect(cloudList.saveCount, equals(1));
    });

    test('deleteList tente cloud puis local', () async {
      await localList.saveList(_makeList(id: 'l1', name: 'Test'));
      await cloudList.saveList(_makeList(id: 'l1', name: 'Test'));
      await svc.deleteList('l1');
      expect(cloudList.deleteCount, equals(1));
      expect(localList.deleteCount, equals(1));
    });

    test('getAllLists retient la version cloud quand même ID plus récent', () async {
      final local = _makeList(id: 'l1', name: 'Locale', updatedAt: DateTime(2024, 1, 1));
      final cloud = _makeList(id: 'l1', name: 'Cloud', updatedAt: DateTime(2024, 1, 2));
      await localList.saveList(local);
      await cloudList.saveList(cloud);
      final result = await svc.getAllLists();
      expect(result, hasLength(1));
      expect(result.first.name, equals('Cloud'));
    });
  });

  group('gestion des erreurs duplicate', () {
    test('saveList avec doublon en local → updateList sur local', () async {
      final localList = _DuplicateOnSaveListRepository();
      localList._lists['l1'] = _makeList(id: 'l1', name: 'Original');
      final svc = _makeService(localList: localList);
      await svc.saveList(_makeList(id: 'l1', name: 'Updated'));
      expect(localList.updateCount, equals(1));
      expect(localList._lists['l1']!.name, equals('Updated'));
    });

    test('saveList avec doublon en cloud → updateList sur cloud', () async {
      final cloudList = _DuplicateOnSaveListRepository();
      cloudList._lists['l1'] = _makeList(id: 'l1', name: 'Original');
      final localList = _FakeCustomListRepository();
      final svc = _makeService(localList: localList, cloudList: cloudList);
      await svc.initialize(isAuthenticated: true);
      await svc.saveList(_makeList(id: 'l1', name: 'Updated'));
      expect(localList.saveCount, equals(1));
      expect(cloudList.updateCount, equals(1));
      expect(cloudList._lists['l1']!.name, equals('Updated'));
    });
  });

  group('gestion des erreurs permission', () {
    test('saveItem avec erreur 403 sur cloud → silencieux', () async {
      final localItem = _FakeListItemRepository();
      final cloudItem = _PermissionItemRepository();
      final svc = _makeService(localItem: localItem, cloudItem: cloudItem);
      await svc.initialize(isAuthenticated: true);
      final item = _makeItem(id: 'i1', listId: 'l1');
      await expectLater(svc.saveItem(item), completes);
      expect(localItem.addCount, equals(1));
    });

    test('deleteItem avec erreur permission cloud → silencieux, local supprimé', () async {
      final localItem = _FakeListItemRepository();
      final cloudItem = _PermissionItemRepository();
      final svc = _makeService(localItem: localItem, cloudItem: cloudItem);
      await svc.initialize(isAuthenticated: true);
      final item = _makeItem(id: 'i1', listId: 'l1');
      await localItem.add(item);
      await expectLater(svc.deleteItem('i1'), completes);
      expect(localItem.deleteCount, equals(1));
    });
  });

  group('gestion des items', () {
    late _FakeListItemRepository localItem;
    late _FakeListItemRepository cloudItem;
    late AdaptivePersistenceService svc;

    setUp(() async {
      localItem = _FakeListItemRepository();
      cloudItem = _FakeListItemRepository();
      svc = _makeService(localItem: localItem, cloudItem: cloudItem);
      await svc.initialize(isAuthenticated: true);
    });

    test('getItemsByListId retourne items fusionnés en cloudFirst', () async {
      final item1 = _makeItem(id: 'i1', listId: 'l1');
      final item2 = _makeItem(id: 'i2', listId: 'l1');
      await localItem.add(item1);
      await cloudItem.add(item2);
      final result = await svc.getItemsByListId('l1');
      final ids = result.map((i) => i.id).toSet();
      expect(ids, containsAll(['i1', 'i2']));
    });

    test('getItemsByListId retient la version cloud quand même ID plus récent', () async {
      final localVersion = _makeItem(id: 'i1', listId: 'l1', lastChosenAt: DateTime(2024, 1, 1));
      final cloudVersion = _makeItem(id: 'i1', listId: 'l1', lastChosenAt: DateTime(2024, 1, 2));
      await localItem.add(localVersion);
      await cloudItem.add(cloudVersion);
      final result = await svc.getItemsByListId('l1');
      expect(result, hasLength(1));
      expect(result.first.lastChosenAt, equals(DateTime(2024, 1, 2)));
    });

    test('saveItem nominal ajoute en local et cloud', () async {
      final item = _makeItem(id: 'i1', listId: 'l1');
      await svc.saveItem(item);
      expect(localItem.addCount, equals(1));
      expect(cloudItem.addCount, equals(1));
    });

    test('updateItem nominal met à jour local et cloud', () async {
      final item = _makeItem(id: 'i1', listId: 'l1');
      await localItem.add(item);
      await cloudItem.add(item);
      await svc.updateItem(item);
      expect(localItem.updateCount, equals(1));
      expect(cloudItem.updateCount, equals(1));
    });

    test('deleteItem nominal supprime local et cloud', () async {
      final item = _makeItem(id: 'i1', listId: 'l1');
      await localItem.add(item);
      await cloudItem.add(item);
      await svc.deleteItem('i1');
      expect(cloudItem.deleteCount, equals(1));
      expect(localItem.deleteCount, equals(1));
    });
  });
}
