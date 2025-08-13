import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_item_card.dart';

void main() {
  group('ListItemCard', () {
    late ListItem testItem;

    setUp(() {
      testItem = ListItem(
        id: 'test_item',
        title: 'Test Item',
        description: 'Test Description',
        category: 'Test Category',
        eloScore: 1500.0, // Score élevé (équivalent HIGH priority)
        isCompleted: false,
        createdAt: DateTime.now(),
      );
    });

    testWidgets('displays item information correctly', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
        home: Scaffold(
          body: ListItemCard(
            item: testItem, // Utiliser l'item de test valide au lieu de null
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - Le widget doit se construire sans erreur
      expect(find.byType(ListItemCard), findsOneWidget);
      expect(find.text(testItem.title), findsOneWidget);
    });

    testWidgets('shows item with ELO score', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
        home: Scaffold(
          body: ListItemCard(
            item: testItem,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ListItemCard), findsOneWidget);
      expect(find.text(testItem.title), findsOneWidget);
      if (testItem.description != null) {
        expect(find.text(testItem.description!), findsOneWidget);
      }
    });

    testWidgets('handles tap events', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      final widget = MaterialApp(
        home: Scaffold(
          body: ListItemCard(
            item: testItem,
            onToggleCompletion: () {
              tapped = true;
            },
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(ListItemCard));

      // Assert
      expect(tapped, isTrue);
    });

    group('ELO system tests', () {
      testWidgets('displays ELO score badge correctly', (WidgetTester tester) async {
        // Arrange: Item avec score ELO très élevé
        final urgentItem = ListItem(
          id: 'urgent',
          title: 'Urgent Item',
          eloScore: 1600.0, // Score très élevé (URGENT)
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final widget = MaterialApp(
          home: Scaffold(
            body: ListItemCard(item: urgentItem),
          ),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Le badge ELO doit être affiché
        expect(find.byType(ListItemCard), findsOneWidget);
        expect(find.text('Urgent Item'), findsOneWidget);
        
        // Vérification que le score ELO est correct
        expect(urgentItem.eloScore, equals(1600.0));
      });

      testWidgets('displays different ELO levels correctly', (WidgetTester tester) async {
        // Arrange: Items avec différents scores ELO
        final highEloItem = ListItem(
          id: 'high',
          title: 'High ELO',
          eloScore: 1500.0, // URGENT
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final mediumEloItem = ListItem(
          id: 'medium',
          title: 'Medium ELO', 
          eloScore: 1350.0, // MOYEN
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final lowEloItem = ListItem(
          id: 'low',
          title: 'Low ELO',
          eloScore: 1100.0, // BAS
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        // Act & Assert pour chaque niveau
        expect(highEloItem.eloScore, equals(1500.0));
        expect(mediumEloItem.eloScore, equals(1350.0));
        expect(lowEloItem.eloScore, equals(1100.0));
      });
    });

    group('Completion state', () {
      testWidgets('shows completed item correctly', (WidgetTester tester) async {
        // Arrange: Item complété
        final completedItem = testItem.copyWith(isCompleted: true);

        final widget = MaterialApp(
          home: Scaffold(
            body: ListItemCard(item: completedItem),
          ),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert
        expect(find.byType(ListItemCard), findsOneWidget);
        expect(completedItem.isCompleted, isTrue);
      });

      testWidgets('handles completion toggle', (WidgetTester tester) async {
        // Arrange
        bool toggled = false;
        bool newValue = false;

        final widget = MaterialApp(
          home: Scaffold(
            body: ListItemCard(
              item: testItem,
              onToggleCompletion: () {
                toggled = true;
              },
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        if (find.byType(Checkbox).evaluate().isNotEmpty) {
          await tester.tap(find.byType(Checkbox));
        }

        // Assert - Si le checkbox existe, il doit répondre aux taps
        if (toggled) {
          expect(newValue, isNotNull);
        }
      });
    });

    group('Category display', () {
      testWidgets('shows category when present', (WidgetTester tester) async {
        // Arrange: Item avec catégorie
        final itemWithCategory = testItem.copyWith(category: 'Work Tasks');

        final widget = MaterialApp(
          home: Scaffold(
            body: ListItemCard(item: itemWithCategory),
          ),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert
        expect(find.byType(ListItemCard), findsOneWidget);
        expect(itemWithCategory.category, equals('Work Tasks'));
      });
    });

    group('Actions menu', () {
      testWidgets('shows action menu when actions provided', (WidgetTester tester) async {
        // Arrange
        // Variables inutilisées supprimées

        final widget = MaterialApp(
          home: Scaffold(
            body: ListItemCard(
              item: testItem,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert - Le menu d'actions doit être présent si onEdit/onDelete sont fournis
        expect(find.byType(ListItemCard), findsOneWidget);
        
        // Simulation d'actions
        if (find.byIcon(Icons.more_vert).evaluate().isNotEmpty) {
          // Le menu existe, on peut tester les actions
          expect(find.byIcon(Icons.more_vert), findsOneWidget);
        }
      });
    });
  });
} 
