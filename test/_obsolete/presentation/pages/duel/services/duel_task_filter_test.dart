import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/duel/services/duel_task_filter.dart';

void main() {
  group('DuelTaskFilter', () {
    final filter = DuelTaskFilter();

    CustomList _buildList(String id, List<ListItem> items) => CustomList(
          id: id,
          name: 'List $id',
          type: ListType.custom,
          items: items,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

    ListItem _buildItem(String id, {bool isCompleted = false}) => ListItem(
          id: id,
          title: 'Item $id',
          createdAt: DateTime(2024, 1, 1),
          description: null,
          category: null,
          eloScore: 1200,
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime(2024, 1, 2) : null,
          dueDate: null,
          notes: null,
          listId: 'list-a',
        );

    test('retourne les éléments de toutes les listes quand toutes sont activées', () {
      final lists = [
        _buildList('list-a', [_buildItem('a1'), _buildItem('a2')]),
        _buildList('list-b', [_buildItem('b1')]),
      ];

      final result = filter.extractEligibleItems(
        lists: lists,
        settings: ListPrioritizationSettings.defaultSettings(),
      );

      expect(result.length, 3);
    });

    test('filtre les éléments en fonction des listes activées', () {
      final lists = [
        _buildList('list-a', [_buildItem('a1'), _buildItem('a2')]),
        _buildList('list-b', [_buildItem('b1')]),
      ];

      final settings = ListPrioritizationSettings(enabledListIds: {'list-b'});

      final result = filter.extractEligibleItems(
        lists: lists,
        settings: settings,
      );

      expect(result.map((item) => item.id), ['b1']);
    });

    test('ignore les éléments complétés', () {
      final lists = [
        _buildList('list-a', [
          _buildItem('a1'),
          _buildItem('a2', isCompleted: true),
        ]),
      ];

      final result = filter.extractEligibleItems(
        lists: lists,
        settings: ListPrioritizationSettings.defaultSettings(),
      );

      expect(result.length, 1);
      expect(result.first.id, 'a1');
    });
  });
}
