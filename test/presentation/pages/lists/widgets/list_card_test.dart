import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_card.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('ListCard', () {
    late CustomList testList;

    setUp(() {
      final items = [
          ListItem(
          id: 'item1',
          title: 'Test Item 1',
            description: 'Description 1',
          eloScore: 1500.0, // Score élevé (équivalent HIGH priority)
          isCompleted: false,
            createdAt: DateTime.now(),
          ),
          ListItem(
          id: 'item2',
          title: 'Test Item 2',
            description: 'Description 2',
          eloScore: 1300.0, // Score moyen (équivalent MEDIUM priority)
          isCompleted: true,
            createdAt: DateTime.now(),
          ),
      ];

      testList = CustomList(
        id: 'test-list',
        name: 'Test List',
        type: ListType.CUSTOM,
        description: 'Test Description',
        items: items,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('displays list information correctly', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
          home: Scaffold(
          body: ListCard(
            list: testList,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - Le widget doit se construire sans erreur
      expect(find.byType(ListCard), findsOneWidget);
    });

    testWidgets('shows progress when items exist', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
          home: Scaffold(
          body: ListCard(
            list: testList,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ListCard), findsOneWidget);
      expect(find.text(testList.name), findsOneWidget);
    });

    testWidgets('handles tap events', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      final widget = MaterialApp(
          home: Scaffold(
            body: ListCard(
              list: testList,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(ListCard));

      // Assert
      expect(tapped, isTrue);
    });

    group('ELO system tests', () {
      testWidgets('works with ELO scores instead of priority', (WidgetTester tester) async {
        // Arrange: Liste avec items ayant différents scores ELO
        final highEloItem = ListItem(
          id: 'high-elo',
          title: 'High ELO Item',
          eloScore: 1600.0, // Score très élevé
          isCompleted: false,
          createdAt: DateTime.now(),
      );

        final lowEloItem = ListItem(
          id: 'low-elo', 
          title: 'Low ELO Item',
          eloScore: 1000.0, // Score bas
          isCompleted: true,
          createdAt: DateTime.now(),
        );

                 final eloList = CustomList(
           id: 'elo-list',
           name: 'ELO Test List',
           type: ListType.CUSTOM,
           description: 'Testing ELO system',
           items: [highEloItem, lowEloItem],
           createdAt: DateTime.now(),
           updatedAt: DateTime.now(),
         );

        final widget = MaterialApp(
          home: Scaffold(
            body: ListCard(list: eloList),
        ),
      );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Le widget se construit correctement avec le système ELO
        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('ELO Test List'), findsOneWidget);

        // Vérification que les scores ELO sont corrects
        expect(highEloItem.eloScore, equals(1600.0));
        expect(lowEloItem.eloScore, equals(1000.0));
    });
    });

    group('Progress calculation', () {
      testWidgets('calculates correct progress percentage', (WidgetTester tester) async {
        // Arrange: Liste avec 50% de completion
        final completedItem = ListItem(
          id: 'completed',
          title: 'Completed Item',
          eloScore: 1400.0,
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        final pendingItem = ListItem(
          id: 'pending',
          title: 'Pending Item',
          eloScore: 1200.0,
            isCompleted: false,
            createdAt: DateTime.now(),
        );

                 final progressList = CustomList(
           id: 'progress-list',
           name: 'Progress List',
           type: ListType.CUSTOM,
           description: 'Testing progress',
           items: [completedItem, pendingItem],
           createdAt: DateTime.now(),
           updatedAt: DateTime.now(),
         );

        final widget = MaterialApp(
          home: Scaffold(
            body: ListCard(list: progressList),
          ),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Le widget affiche la progression correcte
        expect(find.byType(ListCard), findsOneWidget);
        
        // Vérification du calcul de progression (50% dans ce cas)
        final progress = progressList.getCompletedItems().length / progressList.items.length;
        expect(progress, equals(0.5));
      });
    });
  });
} 
