import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/list/repositories/custom_list_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/custom_list_service.dart';

class _FakeCustomListRepository extends CustomListRepository {
  final _lists = <String, CustomList>{};

  @override
  Future<List<CustomList>> getAllLists() async => _lists.values.toList();

  @override
  Future<CustomList?> getListById(String id) async => _lists[id];

  @override
  Future<void> saveList(CustomList list) async => _lists[list.id] = list;

  @override
  Future<void> updateList(CustomList list) async {
    if (_lists.containsKey(list.id)) _lists[list.id] = list;
  }

  @override
  Future<void> deleteList(String id) async => _lists.remove(id);

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

CustomList _makeList({
  required String id,
  required String name,
  ListType type = ListType.TODO,
  String? description,
  List<ListItem>? items,
}) {
  final now = DateTime(2024, 1, 1);
  return CustomList(
    id: id,
    name: name,
    type: type,
    description: description,
    items: items ?? const [],
    createdAt: now,
    updatedAt: now,
  );
}

ListItem _makeItem({
  required String id,
  required String listId,
  bool isCompleted = false,
}) {
  final now = DateTime(2024, 1, 1);
  return ListItem(
    id: id,
    title: 'Item $id',
    listId: listId,
    createdAt: now,
    isCompleted: isCompleted,
    completedAt: isCompleted ? now : null,
  );
}

void main() {
  group('CustomListCrudService', () {
    late _FakeCustomListRepository repo;
    late CustomListCrudService service;

    setUp(() {
      repo = _FakeCustomListRepository();
      service = CustomListCrudService(repo);
    });

    test('getAllLists retourne liste vide initialement', () async {
      expect(await service.getAllLists(), isEmpty);
    });

    test('addList ajoute une liste puis getAllLists la retourne', () async {
      final list = _makeList(id: 'l1', name: 'Ma liste');
      await service.addList(list);
      final all = await service.getAllLists();
      expect(all, hasLength(1));
      expect(all.first.id, equals('l1'));
    });

    test('updateList met à jour une liste existante', () async {
      final list = _makeList(id: 'l1', name: 'Avant');
      await service.addList(list);
      final updated = _makeList(id: 'l1', name: 'Après');
      await service.updateList(updated);
      final all = await service.getAllLists();
      expect(all.first.name, equals('Après'));
    });

    test('deleteList supprime une liste existante', () async {
      await service.addList(_makeList(id: 'l1', name: 'A'));
      await service.addList(_makeList(id: 'l2', name: 'B'));
      await service.deleteList('l1');
      final all = await service.getAllLists();
      expect(all, hasLength(1));
      expect(all.first.id, equals('l2'));
    });

    test('clearAllLists vide toutes les listes', () async {
      await service.addList(_makeList(id: 'l1', name: 'A'));
      await service.addList(_makeList(id: 'l2', name: 'B'));
      await service.clearAllLists();
      expect(await service.getAllLists(), isEmpty);
    });

    test('getAllLists retourne vide après clearAllLists (edge case liste vide)', () async {
      await service.clearAllLists();
      expect(await service.getAllLists(), isEmpty);
    });
  });

  group('CustomListSearchService', () {
    late _FakeCustomListRepository repo;
    late CustomListSearchService service;

    setUp(() {
      repo = _FakeCustomListRepository();
      service = CustomListSearchService(repo);
    });

    test('getListsByType filtre par type', () async {
      await repo.saveList(_makeList(id: 'l1', name: 'Voyage', type: ListType.TRAVEL));
      await repo.saveList(_makeList(id: 'l2', name: 'Courses', type: ListType.SHOPPING));
      await repo.saveList(_makeList(id: 'l3', name: 'Voyage 2', type: ListType.TRAVEL));
      final result = await service.getListsByType(ListType.TRAVEL);
      expect(result, hasLength(2));
      expect(result.every((l) => l.type == ListType.TRAVEL), isTrue);
    });

    test('searchLists correspondance partielle insensible à la casse', () async {
      await repo.saveList(_makeList(id: 'l1', name: 'Mes Films Préférés'));
      await repo.saveList(_makeList(id: 'l2', name: 'Liste courses'));
      final result = await service.searchLists('films');
      expect(result, hasLength(1));
      expect(result.first.id, equals('l1'));
    });

    test('searchLists retourne liste vide si aucun résultat', () async {
      await repo.saveList(_makeList(id: 'l1', name: 'Courses'));
      final result = await service.searchLists('inexistant');
      expect(result, isEmpty);
    });

    test('searchLists cherche aussi dans la description', () async {
      await repo.saveList(
        _makeList(id: 'l1', name: 'Divers', description: 'voyages en Europe'),
      );
      await repo.saveList(_makeList(id: 'l2', name: 'Courses'));
      final result = await service.searchLists('europe');
      expect(result, hasLength(1));
      expect(result.first.id, equals('l1'));
    });
  });

  group('CustomListStatsService', () {
    late _FakeCustomListRepository repo;
    late CustomListStatsService service;

    setUp(() {
      repo = _FakeCustomListRepository();
      service = CustomListStatsService(repo);
    });

    test('getGlobalProgress retourne 0.0 si aucune liste', () async {
      expect(await service.getGlobalProgress(), equals(0.0));
    });

    test('getGlobalProgress retourne 0.0 si liste avec 0 éléments', () async {
      await repo.saveList(_makeList(id: 'l1', name: 'Vide'));
      expect(await service.getGlobalProgress(), equals(0.0));
    });

    test('getGlobalProgress calcule correctement la progression globale', () async {
      final item1 = _makeItem(id: 'i1', listId: 'l1', isCompleted: true);
      final item2 = _makeItem(id: 'i2', listId: 'l1', isCompleted: false);
      final item3 = _makeItem(id: 'i3', listId: 'l1', isCompleted: false);
      final item4 = _makeItem(id: 'i4', listId: 'l2', isCompleted: true);
      final item5 = _makeItem(id: 'i5', listId: 'l2', isCompleted: true);
      final item6 = _makeItem(id: 'i6', listId: 'l2', isCompleted: true);
      final item7 = _makeItem(id: 'i7', listId: 'l2', isCompleted: false);
      // list1: 3 items, 1 completed; list2: 4 items, 3 completed → 4/7
      await repo.saveList(_makeList(id: 'l1', name: 'A', items: [item1, item2, item3]));
      await repo.saveList(_makeList(id: 'l2', name: 'B', items: [item4, item5, item6, item7]));
      final progress = await service.getGlobalProgress();
      expect(progress, closeTo(4 / 7, 0.001));
    });

    test('getStats retourne les clés totalLists, totalItems, completedItems, averageProgress', () async {
      final result = await service.getStats();
      expect(result.containsKey('totalLists'), isTrue);
      expect(result.containsKey('totalItems'), isTrue);
      expect(result.containsKey('completedItems'), isTrue);
      expect(result.containsKey('averageProgress'), isTrue);
    });

    test('getStats calcule correctement avec des listes peuplées', () async {
      final item1 = _makeItem(id: 'i1', listId: 'l1', isCompleted: true);
      final item2 = _makeItem(id: 'i2', listId: 'l1', isCompleted: false);
      await repo.saveList(_makeList(id: 'l1', name: 'A', items: [item1, item2]));
      await repo.saveList(_makeList(id: 'l2', name: 'B'));
      final stats = await service.getStats();
      expect(stats['totalLists'], equals(2));
      expect(stats['totalItems'], equals(2));
      expect(stats['completedItems'], equals(1));
      // averageProgress = mean of per-list getProgress()
      // l1: 1/2 completed → 0.5 ; l2: 0 items → 0.0  → mean = 0.25
      expect(stats['averageProgress'], closeTo(0.25, 0.001));
    });
  });

  group('CustomListService (composite)', () {
    late _FakeCustomListRepository repo;
    late CustomListService service;

    setUp(() {
      repo = _FakeCustomListRepository();
      final crud = CustomListCrudService(repo);
      final search = CustomListSearchService(repo);
      final stats = CustomListStatsService(repo);
      service = CustomListService(crud, search, stats);
    });

    test('délègue getAllLists au CrudService', () async {
      await repo.saveList(_makeList(id: 'l1', name: 'Test'));
      final result = await service.getAllLists();
      expect(result, hasLength(1));
    });

    test('délègue searchLists au SearchService', () async {
      await repo.saveList(_makeList(id: 'l1', name: 'Cinéma'));
      await repo.saveList(_makeList(id: 'l2', name: 'Courses'));
      final result = await service.searchLists('cinéma');
      expect(result, hasLength(1));
      expect(result.first.id, equals('l1'));
    });

    test('délègue getGlobalProgress au StatsService', () async {
      expect(await service.getGlobalProgress(), equals(0.0));
    });
  });
}
