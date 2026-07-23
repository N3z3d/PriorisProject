import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/lists/models/task_sort_field.dart';
import 'package:prioris/presentation/pages/lists/services/list_items_sorter.dart';

void main() {
  ListItem buildItem(String id, String title, double elo) => ListItem(
        id: id,
        title: title,
        listId: 'list-1',
        createdAt: DateTime(2026, 7, 1),
        eloScore: elo,
      );

  group('ListItemsSorter', () {
    const sorter = ListItemsSorter();

    final items = [
      buildItem('1', 'Écrire le rapport', 1400),
      buildItem('2', 'acheter du pain', 1200),
      buildItem('3', 'Zoo avec les enfants', 1600),
    ];

    group('sort', () {
      test('sorts by elo descending by default direction', () {
        final result =
            sorter.sort(items, TaskSortField.elo, isAscending: false, randomSeed: 1);

        expect(result.map((i) => i.id).toList(), ['3', '1', '2']);
      });

      test('sorts by elo ascending', () {
        final result =
            sorter.sort(items, TaskSortField.elo, isAscending: true, randomSeed: 1);

        expect(result.map((i) => i.id).toList(), ['2', '1', '3']);
      });

      test('sorts by name ignoring accents', () {
        final result =
            sorter.sort(items, TaskSortField.name, isAscending: true, randomSeed: 1);

        // "acheter" < "Écrire" (accents ignorés) < "Zoo"
        expect(result.map((i) => i.id).toList(), ['2', '1', '3']);
      });

      test('sorts by name descending', () {
        final result =
            sorter.sort(items, TaskSortField.name, isAscending: false, randomSeed: 1);

        expect(result.map((i) => i.id).toList(), ['3', '1', '2']);
      });

      test('random sort is deterministic for the same seed', () {
        final first =
            sorter.sort(items, TaskSortField.random, isAscending: false, randomSeed: 42);
        final second =
            sorter.sort(items, TaskSortField.random, isAscending: false, randomSeed: 42);

        expect(first.map((i) => i.id).toList(), second.map((i) => i.id).toList());
      });

      test('random sort keeps all items (permutation)', () {
        final result =
            sorter.sort(items, TaskSortField.random, isAscending: false, randomSeed: 42);

        expect(result.map((i) => i.id).toSet(), {'1', '2', '3'});
      });

      test('does not modify the original list', () {
        final original = List<ListItem>.from(items);

        sorter.sort(items, TaskSortField.elo, isAscending: true, randomSeed: 1);

        expect(items, equals(original));
      });

      test('handles empty list', () {
        final result =
            sorter.sort([], TaskSortField.elo, isAscending: true, randomSeed: 1);

        expect(result, isEmpty);
      });
    });

    group('normalizeSeed', () {
      test('maps negative seeds to positive values', () {
        expect(ListItemsSorter.normalizeSeed(-123), greaterThan(0));
      });

      test('maps zero to 1', () {
        expect(ListItemsSorter.normalizeSeed(0), equals(1));
      });

      test('keeps positive seeds unchanged', () {
        expect(ListItemsSorter.normalizeSeed(42), equals(42));
      });
    });

    group('reshuffleSeed', () {
      test('is deterministic with an injected clock', () {
        final fixedNow = DateTime(2026, 7, 22, 14, 0);

        final first = ListItemsSorter.reshuffleSeed(42, now: () => fixedNow);
        final second = ListItemsSorter.reshuffleSeed(42, now: () => fixedNow);

        expect(first, equals(second));
        expect(first, greaterThan(0));
      });

      test('produces a different seed when the clock changes', () {
        final seedA = ListItemsSorter.reshuffleSeed(
          42,
          now: () => DateTime(2026, 7, 22, 14, 0),
        );
        final seedB = ListItemsSorter.reshuffleSeed(
          42,
          now: () => DateTime(2026, 7, 22, 14, 0, 1),
        );

        expect(seedA, isNot(equals(seedB)));
      });
    });
  });
}
