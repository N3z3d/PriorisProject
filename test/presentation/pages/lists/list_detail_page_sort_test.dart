import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_item_card.dart';

import '../../../test_utils/list_test_doubles.dart';

void main() {
  group('ListDetailPage random sorting', () {
    late CustomList seedList;
    late ListsState seededState;

    setUp(() {
      final now = DateTime(2024, 10, 20, 9, 30);
      final items = <ListItem>[
        ListItem(
          id: 'item-a',
          title: 'Préparer slides',
          createdAt: now,
          listId: 'list-1',
          eloScore: 1340,
        ),
        ListItem(
          id: 'item-b',
          title: 'Revoir backlog',
          createdAt: now.add(const Duration(minutes: 1)),
          listId: 'list-1',
          eloScore: 1200,
        ),
        ListItem(
          id: 'item-c',
          title: 'Appeler partenaire',
          createdAt: now.add(const Duration(minutes: 2)),
          listId: 'list-1',
          eloScore: 1420,
        ),
      ];

      seedList = CustomList(
        id: 'list-1',
        name: 'Roadmap Q4',
        type: ListType.CUSTOM,
        items: items,
        createdAt: now,
        updatedAt: now,
      );

      seededState = ListsState(
        lists: [seedList],
        filteredLists: [seedList],
        isLoading: false,
      );
    });

    testWidgets('applies deterministic shuffle when random sort selected',
        (tester) async {
      final controller = StubListsController(seededState: seededState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            listsControllerProvider.overrideWith((ref) => controller),
          ],
          child: MaterialApp(
            home: ListDetailPage(list: seedList),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(seconds: 4));

      // Switch to random sort.
      await tester.tap(find.text('Score Élo'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Aléatoire').last);
      await tester.pump(const Duration(milliseconds: 200));

      final displayedOrder = tester
          .widgetList<ListItemCard>(find.byType(ListItemCard))
          .map((card) => card.item.title)
          .toList();

      final expectedOrder = _shuffleWithSeed(
              seedList.items, _normalizedSeed(seedList.id.hashCode))
          .map((item) => item.title)
          .toList();

      expect(displayedOrder, expectedOrder);
    });
  });
}

List<ListItem> _shuffleWithSeed(List<ListItem> source, int seed) {
  final shuffled = List<ListItem>.from(source);
  final random = Random(seed);
  for (var i = shuffled.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final tmp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = tmp;
  }
  return shuffled;
}

int _normalizedSeed(int rawSeed) {
  final normalized = rawSeed & 0x7fffffff;
  return normalized == 0 ? 1 : normalized;
}
