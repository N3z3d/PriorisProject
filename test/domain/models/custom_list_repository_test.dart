import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('InMemoryCustomListRepository', () {
    late InMemoryCustomListRepository repository;
    late CustomList list1;
    late CustomList list2;
    late DateTime now;

    setUp(() {
      repository = InMemoryCustomListRepository();
      now = DateTime(2024, 1, 1, 12, 0, 0);
      list1 = CustomList(
        id: 'list-1',
        name: 'Voyages 2024',
        type: ListType.TRAVEL,
        createdAt: now,
        updatedAt: now,
      );
      list2 = CustomList(
        id: 'list-2',
        name: 'Courses',
        type: ListType.SHOPPING,
        createdAt: now,
        updatedAt: now,
      );
    });

    test('should start empty', () async {
      final lists = await repository.getAllLists();
      expect(lists, isEmpty);
    });

    test('should save and retrieve a list', () async {
      await repository.saveList(list1);
      final lists = await repository.getAllLists();
      expect(lists.length, 1);
      expect(lists.first, list1);
    });

    test('should save multiple lists', () async {
      await repository.saveList(list1);
      await repository.saveList(list2);
      final lists = await repository.getAllLists();
      expect(lists.length, 2);
      expect(lists, containsAll([list1, list2]));
    });

    test('should update a list', () async {
      await repository.saveList(list1);
      final updated = list1.copyWith(name: 'Voyages 2025');
      await repository.updateList(updated);
      final lists = await repository.getAllLists();
      expect(lists.length, 1);
      expect(lists.first.name, 'Voyages 2025');
    });

    test('should not update non-existent list', () async {
      final updated = list1.copyWith(name: 'Voyages 2025');
      await repository.updateList(updated);
      final lists = await repository.getAllLists();
      expect(lists, isEmpty);
    });

    test('should delete a list', () async {
      await repository.saveList(list1);
      await repository.saveList(list2);
      await repository.deleteList(list1.id);
      final lists = await repository.getAllLists();
      expect(lists.length, 1);
      expect(lists.first, list2);
    });

    test('should not delete non-existent list', () async {
      await repository.saveList(list1);
      await repository.deleteList('unknown-id');
      final lists = await repository.getAllLists();
      expect(lists.length, 1);
      expect(lists.first, list1);
    });

    test('should filter lists by type', () async {
      await repository.saveList(list1);
      await repository.saveList(list2);
      final travelLists = await repository.getListsByType(ListType.TRAVEL);
      final shoppingLists = await repository.getListsByType(ListType.SHOPPING);
      expect(travelLists.length, 1);
      expect(travelLists.first, list1);
      expect(shoppingLists.length, 1);
      expect(shoppingLists.first, list2);
    });

    test('should clear all lists', () async {
      await repository.saveList(list1);
      await repository.saveList(list2);
      await repository.clearAllLists();
      final lists = await repository.getAllLists();
      expect(lists, isEmpty);
    });
  });
} 
