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

      expect(
          find.byKey(const ValueKey('list-item-sync-spinner')), findsOneWidget);
      final indicatorFinder = find.byType(CircularProgressIndicator);
      expect(indicatorFinder, findsOneWidget);

      final indicator =
          tester.widget<CircularProgressIndicator>(indicatorFinder);
      expect(indicator.strokeWidth, closeTo(1.8, 0.3));
    });
  });
}
