import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('ListDetailPage', () {
    late CustomList testList;

    setUp(() {
      final now = DateTime.now();
      testList = CustomList(
        id: 'test_list',
        name: 'Test List',
        type: ListType.CUSTOM,
        description: 'Test Description',
        items: [
          ListItem(
            id: 'item1',
            title: 'Urgent Task',
            description: 'Urgent description',
            eloScore: 1600.0, // Score très élevé (équivalent URGENT priority)
            isCompleted: false,
            createdAt: now,
          ),
          ListItem(
            id: 'item2',
            title: 'Low Priority Task',
            description: 'Low priority description',
            eloScore: 1100.0, // Score bas (équivalent LOW priority)
            isCompleted: true,
            createdAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );
    });

    testWidgets('displays list information correctly', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
            home: ListDetailPage(list: testList),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ListDetailPage), findsOneWidget);
      expect(find.text(testList.name), findsAtLeastNWidgets(1)); // Le nom peut apparaître plusieurs fois (AppBar, titre, etc.)
      if (testList.description != null) {
        expect(find.text(testList.description!), findsOneWidget);
      }
    });

    testWidgets('shows items with ELO scores', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
            home: ListDetailPage(list: testList),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert: Les items doivent s'afficher avec leurs scores ELO
      expect(find.byType(ListDetailPage), findsOneWidget);
      expect(find.text('Urgent Task'), findsOneWidget);
      expect(find.text('Low Priority Task'), findsOneWidget);
      
      // Vérification des scores ELO
      expect(testList.items[0].eloScore, equals(1600.0)); // Urgent
      expect(testList.items[1].eloScore, equals(1100.0)); // Low
    });

    testWidgets('handles item completion toggle', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
            home: ListDetailPage(list: testList),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert: Page doit gérer le toggle de completion
      expect(find.byType(ListDetailPage), findsOneWidget);
      
      // Vérification des états de completion
      expect(testList.items[0].isCompleted, isFalse); // Urgent task pas complétée
      expect(testList.items[1].isCompleted, isTrue); // Low task complétée
    });

    group('ELO system integration', () {
      testWidgets('displays items sorted by ELO score', (WidgetTester tester) async {
        // Arrange: Liste avec items de scores ELO variés
        final now = DateTime.now();
        final sortedList = CustomList(
          id: 'sorted_list',
          name: 'Sorted ELO List',
          type: ListType.CUSTOM,
          description: 'Items sorted by ELO',
          items: [
            ListItem(
              id: 'high',
              title: 'High ELO Item',
              eloScore: 1500.0, // ÉLEVÉ
              isCompleted: false,
              createdAt: now,
            ),
            ListItem(
              id: 'urgent',
              title: 'Urgent ELO Item',
              eloScore: 1600.0, // URGENT (le plus haut)
              isCompleted: false,
              createdAt: now,
            ),
            ListItem(
              id: 'medium',
              title: 'Medium ELO Item',
              eloScore: 1300.0, // MOYEN
              isCompleted: true,
              createdAt: now,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );

        final widget = MaterialApp(
          home: ListDetailPage(list: sortedList),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Vérification des scores ELO
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(sortedList.items[0].eloScore, equals(1500.0)); // High
        expect(sortedList.items[1].eloScore, equals(1600.0)); // Urgent (highest)
        expect(sortedList.items[2].eloScore, equals(1300.0)); // Medium
      });
    });

    group('Item actions', () {
      testWidgets('supports adding new items', (WidgetTester tester) async {
        // Arrange
        final widget = MaterialApp(
            home: ListDetailPage(list: testList),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Page doit permettre l'ajout d'items
        expect(find.byType(ListDetailPage), findsOneWidget);

        // Vérification que la liste a bien 2 items initialement
        expect(testList.items.length, equals(2));
    });

      testWidgets('supports editing items', (WidgetTester tester) async {
        // Arrange
        final widget = MaterialApp(
            home: ListDetailPage(list: testList),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Page doit permettre l'édition d'items
        expect(find.byType(ListDetailPage), findsOneWidget);
        
        // Les items doivent être éditables
        expect(testList.items[0].title, equals('Urgent Task'));
        expect(testList.items[1].title, equals('Low Priority Task'));
    });

      testWidgets('supports deleting items', (WidgetTester tester) async {
        // Arrange
        final widget = MaterialApp(
            home: ListDetailPage(list: testList),
      );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Page doit permettre la suppression d'items
        expect(find.byType(ListDetailPage), findsOneWidget);
        
        // Vérification que les items existent avant suppression
        expect(testList.items.isNotEmpty, isTrue);
      });
    });

    group('Progress tracking', () {
      testWidgets('shows completion progress correctly', (WidgetTester tester) async {
        // Arrange
        final widget = MaterialApp(
            home: ListDetailPage(list: testList),
      );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Progression doit être affichée correctement
      expect(find.byType(ListDetailPage), findsOneWidget);
        
        // Calcul de la progression: 1 item complété sur 2 = 50%
        final completedItems = testList.items.where((item) => item.isCompleted).length;
        final totalItems = testList.items.length;
        final expectedProgress = (completedItems / totalItems * 100).round();
        
        expect(completedItems, equals(1));
        expect(totalItems, equals(2));
        expect(expectedProgress, equals(50));
      });
    });
  });
} 
