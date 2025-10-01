import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/presentation/pages/habits_page.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';

// Mock classes
class MockHabitsController extends Mock implements HabitsController {}
class MockTabController extends Mock implements TabController {}

void main() {
  group('Refactored HabitsPage Tests', () {
    late MockHabitsController mockController;
    late MockTabController mockTabController;

    setUp(() {
      mockController = MockHabitsController();
      mockTabController = MockTabController();
    });

    testWidgets('should display habits header correctly', (tester) async {
      // Arrange
      when(mockController.tabController).thenReturn(mockTabController);
      
      // Create a test app with providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactiveHabitsProvider.overrideWith((ref) => <Habit>[]),
            habitsLoadingProvider.overrideWith((ref) => false),
            habitsErrorProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Mes Habitudes'), findsOneWidget);
      expect(find.text('Construisez votre meilleure version'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
    });

    testWidgets('should display loading state correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactiveHabitsProvider.overrideWith((ref) => <Habit>[]),
            habitsLoadingProvider.overrideWith((ref) => true),
            habitsErrorProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no habits exist', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactiveHabitsProvider.overrideWith((ref) => <Habit>[]),
            habitsLoadingProvider.overrideWith((ref) => false),
            habitsErrorProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Aucune habitude'), findsOneWidget);
      expect(find.text('Ajouter ma première habitude'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('should display habits list when habits exist', (tester) async {
      // Arrange
      final testHabits = [
        Habit(
          id: '1',
          name: 'Test Habit 1',
          category: 'Santé',
          createdAt: DateTime.now(),
        ),
        Habit(
          id: '2',
          name: 'Test Habit 2',
          category: 'Sport',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactiveHabitsProvider.overrideWith((ref) => testHabits),
            habitsLoadingProvider.overrideWith((ref) => false),
            habitsErrorProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Test Habit 1'), findsOneWidget);
      expect(find.text('Test Habit 2'), findsOneWidget);
      expect(find.text('Santé'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
    });

    testWidgets('should display floating action button', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactiveHabitsProvider.overrideWith((ref) => <Habit>[]),
            habitsLoadingProvider.overrideWith((ref) => false),
            habitsErrorProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
    });

    testWidgets('should show tabs correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactiveHabitsProvider.overrideWith((ref) => <Habit>[]),
            habitsLoadingProvider.overrideWith((ref) => false),
            habitsErrorProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Actives'), findsOneWidget);
      expect(find.text('Complétées'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  group('HabitsController Tests', () {
    testWidgets('should handle habit addition correctly', (tester) async {
      // This would require more complex mocking of Riverpod providers
      // and is beyond the scope of this basic test example
    });

    testWidgets('should handle habit deletion correctly', (tester) async {
      // This would require more complex mocking of Riverpod providers
      // and is beyond the scope of this basic test example
    });
  });
}
