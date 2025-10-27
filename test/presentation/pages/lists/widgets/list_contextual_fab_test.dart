import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_contextual_fab.dart';

CustomList _buildList({required List<ListItem> items}) {
  final timestamp = DateTime(2024, 10, 20);
  return CustomList(
    id: 'list-id',
    name: 'Liste test',
    type: ListType.CUSTOM,
    items: items,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

Widget _pumpFab({
  required CustomList list,
  String searchQuery = '',
  List<ListItem>? filteredItems,
}) {
  return MaterialApp(
    home: Scaffold(
      floatingActionButton: ListContextualFab(
        list: list,
        baseLabel: 'Ajouter des elements',
        searchQuery: searchQuery,
        filteredItems: filteredItems ?? list.items,
        onPressed: () {},
        enableAnimations: false,
      ),
    ),
  );
}

void main() {
  group('ListContextualFab', () {
    testWidgets('shows onboarding text when list empty', (tester) async {
      final list = _buildList(items: []);

      await tester.pumpWidget(_pumpFab(list: list));
      await tester.pump();

      expect(find.text('Creer vos premiers elements'), findsOneWidget);
    });

    testWidgets('suggests adding to search when query matches', (tester) async {
      final item = ListItem(
        id: 'item-1',
        title: 'Alpha',
        isCompleted: false,
        createdAt: DateTime(2024, 10, 20),
      );
      final list = _buildList(items: [item]);

      await tester.pumpWidget(
        _pumpFab(
          list: list,
          searchQuery: 'al',
          filteredItems: [item],
        ),
      );
      await tester.pump();

      expect(find.text('Ajouter a cette recherche'), findsOneWidget);
    });

    testWidgets('encourages new element when search empty', (tester) async {
      final item = ListItem(
        id: 'item-1',
        title: 'Alpha',
        isCompleted: false,
        createdAt: DateTime(2024, 10, 20),
      );
      final list = _buildList(items: [item]);

      await tester.pumpWidget(
        _pumpFab(
          list: list,
          searchQuery: 'beta',
          filteredItems: const [],
        ),
      );
      await tester.pump();

      expect(find.text('Creer nouvel element'), findsOneWidget);
    });

    testWidgets('suggests adding more items for short list', (tester) async {
      final items = List.generate(
        2,
        (index) => ListItem(
          id: 'item-$index',
          title: 'Tache $index',
          isCompleted: false,
          createdAt: DateTime(2024, 10, 20),
        ),
      );
      final list = _buildList(items: items);

      await tester.pumpWidget(_pumpFab(list: list));
      await tester.pump();

      expect(find.text('Ajouter plus d''elements'), findsOneWidget);
    });

    testWidgets('uses default text for larger list', (tester) async {
      final items = List.generate(
        5,
        (index) => ListItem(
          id: 'item-large-$index',
          title: 'Item $index',
          isCompleted: false,
          createdAt: DateTime(2024, 10, 20),
        ),
      );
      final list = _buildList(items: items);

      await tester.pumpWidget(_pumpFab(list: list));
      await tester.pump();

      expect(find.text('Ajouter de nouveaux elements'), findsOneWidget);
    });
  });
}
