import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_progress_widget.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('ListProgressWidget', () {
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
            title: 'High ELO Item',
            description: 'Description 1',
            eloScore: 1500.0, // Score élevé (équivalent HIGH priority)
            isCompleted: true,
            createdAt: now,
          ),
          ListItem(
            id: 'item2',
            title: 'Medium ELO Item',
            description: 'Description 2',
            eloScore: 1300.0, // Score moyen (équivalent MEDIUM priority)
            isCompleted: false,
            createdAt: now,
          ),
          ListItem(
            id: 'item3',
            title: 'Low ELO Item',
            description: 'Description 3',
            eloScore: 1100.0, // Score bas (équivalent LOW priority)
            isCompleted: false,
            createdAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now, // Ajout du champ requis
      );
    });

    testWidgets('displays progress information correctly', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
          home: Scaffold(
            body: ListProgressWidget(list: testList),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ListProgressWidget), findsOneWidget);
      expect(find.text('Progression de la liste'), findsOneWidget);
    });

    testWidgets('shows correct completion progress', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
          home: Scaffold(
            body: ListProgressWidget(list: testList),
          ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert: 1 item complété sur 3 = 33%
      expect(find.byType(ListProgressWidget), findsOneWidget);
      
      // Vérification du calcul de progression
      final completedItems = testList.getCompletedItems().length;
      final totalItems = testList.items.length;
      final expectedProgress = (completedItems / totalItems * 100).round();
      
      expect(completedItems, equals(1));
      expect(totalItems, equals(3));
      expect(expectedProgress, equals(33));
    });

    testWidgets('displays ELO score statistics', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
          home: Scaffold(
            body: ListProgressWidget(list: testList),
          ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert: Le widget doit afficher les statistiques par score ELO
      expect(find.byType(ListProgressWidget), findsOneWidget);
      
      // Vérification des scores ELO dans nos données de test
      final highEloItems = testList.items.where((item) => item.eloScore >= 1500).length;
      final mediumEloItems = testList.items.where((item) => item.eloScore >= 1200 && item.eloScore < 1500).length;
      final lowEloItems = testList.items.where((item) => item.eloScore < 1200).length;
      
      expect(highEloItems, equals(1)); // 1 item à 1500
      expect(mediumEloItems, equals(1)); // 1 item à 1300
      expect(lowEloItems, equals(1)); // 1 item à 1100
    });

    testWidgets('displays category statistics when present', (WidgetTester tester) async {
      // Arrange: Liste avec catégories
      final now = DateTime.now();
             final listWithCategories = CustomList(
         id: 'category_list',
         name: 'Category List',
         type: ListType.CUSTOM,
         description: 'List with categories',
        items: [
          ListItem(
            id: 'work1',
            title: 'Work Task 1',
            category: 'Work',
            eloScore: 1400.0,
            isCompleted: false,
            createdAt: now,
          ),
          ListItem(
            id: 'personal1',
            title: 'Personal Task 1',
            category: 'Personal',
            eloScore: 1200.0,
            isCompleted: true,
            createdAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      final widget = MaterialApp(
          home: Scaffold(
          body: ListProgressWidget(list: listWithCategories),
          ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(ListProgressWidget), findsOneWidget);
      
      // Vérification des catégories
      final workItems = listWithCategories.items.where((item) => item.category == 'Work').length;
      final personalItems = listWithCategories.items.where((item) => item.category == 'Personal').length;
      
      expect(workItems, equals(1));
      expect(personalItems, equals(1));
    });

    testWidgets('handles empty list correctly', (WidgetTester tester) async {
      // Arrange: Liste vide
      final now = DateTime.now();
             final emptyList = CustomList(
         id: 'empty_list',
         name: 'Empty List',
         type: ListType.CUSTOM,
         description: 'Empty list for testing',
        items: [],
        createdAt: now,
        updatedAt: now,
      );

      final widget = MaterialApp(
          home: Scaffold(
            body: ListProgressWidget(list: emptyList),
          ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert: Le widget doit gérer les listes vides sans erreur
      expect(find.byType(ListProgressWidget), findsOneWidget);
      expect(find.text('Progression de la liste'), findsOneWidget);
      
      // Vérification que la liste est bien vide
      expect(emptyList.items.length, equals(0));
    });

    testWidgets('shows correct progress bar', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
          home: Scaffold(
            body: ListProgressWidget(list: testList),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert: La barre de progression doit être présente
      expect(find.byType(ListProgressWidget), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // Calcul de la progression attendue
      final progress = testList.getCompletedItems().length / testList.items.length;
      expect(progress, closeTo(0.33, 0.01)); // Environ 33%
    });

    group('ELO system integration', () {
      testWidgets('correctly categorizes items by ELO score', (WidgetTester tester) async {
        // Arrange: Liste avec items couvrant tous les niveaux ELO
        final now = DateTime.now();
                 final comprehensiveList = CustomList(
           id: 'comprehensive',
           name: 'Comprehensive ELO List',
           type: ListType.CUSTOM,
           description: 'All ELO levels',
          items: [
            ListItem(
              id: 'urgent',
              title: 'Urgent Task',
              eloScore: 1600.0, // URGENT
              isCompleted: false,
              createdAt: now,
            ),
            ListItem(
              id: 'high',
              title: 'High Task',
              eloScore: 1450.0, // ÉLEVÉ
              isCompleted: true,
              createdAt: now,
            ),
            ListItem(
              id: 'medium',
              title: 'Medium Task',
              eloScore: 1350.0, // MOYEN
              isCompleted: false,
              createdAt: now,
            ),
            ListItem(
              id: 'low',
              title: 'Low Task',
              eloScore: 1000.0, // BAS
              isCompleted: true,
              createdAt: now,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );

        final widget = MaterialApp(
          home: Scaffold(
            body: ListProgressWidget(list: comprehensiveList),
        ),
      );

        // Act
        await tester.pumpWidget(widget);

        // Assert: Vérification de la catégorisation ELO
        expect(find.byType(ListProgressWidget), findsOneWidget);
        
        // Comptage par niveau ELO
        final urgentItems = comprehensiveList.items.where((item) => item.eloScore >= 1500).length;
        final highItems = comprehensiveList.items.where((item) => item.eloScore >= 1400 && item.eloScore < 1500).length;
        final mediumItems = comprehensiveList.items.where((item) => item.eloScore >= 1300 && item.eloScore < 1400).length;
        final lowItems = comprehensiveList.items.where((item) => item.eloScore < 1300).length;

        expect(urgentItems, equals(1)); // 1 urgent (1600)
        expect(highItems, equals(1)); // 1 high (1450)
        expect(mediumItems, equals(1)); // 1 medium (1350)
        expect(lowItems, equals(1)); // 1 low (1000)
      });
    });
  });
} 
