import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_item_card.dart';

void main() {
  group('ListItemCard status indicator', () {
    testWidgets('does not show a spinner for ongoing items', (tester) async {
      final item = ListItem(
        id: 'item-1',
        title: 'Nouvelle tache',
        createdAt: DateTime(2024, 1, 1),
        eloScore: 1200,
        isCompleted: false,
        listId: 'list-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItemCard(
              item: item,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows a subtle sync spinner when item is syncing',
        (tester) async {
      final item = ListItem(
        id: 'item-sync',
        title: 'Synchronisation en cours',
        createdAt: DateTime(2024, 1, 1),
        eloScore: 1180,
        isCompleted: false,
        listId: 'list-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItemCard(
              item: item,
              isSyncing: true,
            ),
          ),
        ),
      );

      final indicatorFinder = find.byType(CircularProgressIndicator);
      expect(indicatorFinder, findsNWidgets(2));

      final indicator =
          tester.widgetList<CircularProgressIndicator>(indicatorFinder).first;
      expect(indicator.strokeWidth, closeTo(1.6, 0.3));
    });
  });
}
