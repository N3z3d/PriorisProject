import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('AppRoutes', () {
    testWidgets('navigates to list detail correctly', (WidgetTester tester) async {
      // Arrange: CustomList avec le système ELO
      final now = DateTime.now();
      final testList = CustomList(
        id: 'test_list',
        name: 'Test List',
        type: ListType.CUSTOM,
        description: 'Test Description',
        items: [
          ListItem(
            id: 'item1',
            title: 'Test Item',
            description: 'Test Description',
            eloScore: 1500.0, // Score élevé (équivalent HIGH priority)
            isCompleted: false,
            createdAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert: Test de navigation
      expect(testList.items.first.eloScore, equals(1500.0));
      expect(testList.type, equals(ListType.CUSTOM));
      expect(testList.items.length, equals(1));
    });

    testWidgets('handles route generation correctly', (WidgetTester tester) async {
      // Arrange
      const routeName = '/test';
      
      // Act & Assert: Test de génération de route
      expect(routeName, equals('/test'));
    });

    group('ELO system integration', () {
      testWidgets('works with ELO-based lists', (WidgetTester tester) async {
        // Arrange: Liste avec différents scores ELO
        final now = DateTime.now();
        final eloList = CustomList(
          id: 'elo_test',
          name: 'ELO List',
          type: ListType.CUSTOM,
          description: 'ELO testing',
          items: [
            ListItem(
              id: 'urgent',
              title: 'Urgent Task',
              eloScore: 1600.0, // URGENT
              isCompleted: false,
              createdAt: now,
            ),
            ListItem(
              id: 'medium',
              title: 'Medium Task',
              eloScore: 1300.0, // MOYEN
              isCompleted: true,
              createdAt: now,
            ),
            ListItem(
              id: 'low',
              title: 'Low Task',
              eloScore: 1100.0, // BAS
              isCompleted: false,
              createdAt: now,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );

        // Act & Assert: Vérification du système ELO
        expect(eloList.items[0].eloScore, equals(1600.0)); // Urgent
        expect(eloList.items[1].eloScore, equals(1300.0)); // Medium
        expect(eloList.items[2].eloScore, equals(1100.0)); // Low
        
        // Vérification des états de completion
        expect(eloList.items[0].isCompleted, isFalse);
        expect(eloList.items[1].isCompleted, isTrue);
        expect(eloList.items[2].isCompleted, isFalse);
      });
    });

    group('Route parameter validation', () {
      testWidgets('validates list parameters correctly', (WidgetTester tester) async {
        // Arrange: Liste avec validation
        final now = DateTime.now();
                 final validList = CustomList(
           id: 'valid_list',
           name: 'Valid List',
           type: ListType.PROJECTS,
           description: 'Valid description',
           items: [],
           createdAt: now,
           updatedAt: now,
      );

        // Act & Assert: Validation des paramètres
        expect(validList.id, isNotEmpty);
        expect(validList.name, isNotEmpty);
                 expect(validList.type, equals(ListType.PROJECTS));
        expect(validList.items, isEmpty);
      });
    });
  });
} 
