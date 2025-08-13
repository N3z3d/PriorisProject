import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/statistics/widgets/tabs/habits_tab_widget.dart';

void main() {
  group('HabitsTabWidget', () {
    final testHabits = [
      Habit(
        id: '1',
        name: 'Méditation',
        type: HabitType.binary,
        category: 'Bien-être',
        createdAt: DateTime.now(),
      ),
      Habit(
        id: '2',
        name: 'Sport',
        type: HabitType.binary,
        category: 'Santé',
        createdAt: DateTime.now(),
      ),
      Habit(
        id: '3',
        name: 'Lecture',
        type: HabitType.binary,
        category: 'Développement personnel',
        createdAt: DateTime.now(),
      ),
    ];

    Widget createTestWidget({
      List<Habit>? habits,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: HabitsTabWidget(
            habits: habits ?? testHabits,
          ),
        ),
      );
    }

    testWidgets('should render correctly with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Vérifier que le widget se rend sans erreur
      expect(find.byType(HabitsTabWidget), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should handle empty habits list', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(habits: []));

      // Vérifier que le widget se rend sans erreur avec une liste vide
      expect(find.byType(HabitsTabWidget), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final singleChildScrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      
      expect(singleChildScrollView.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('should contain all required widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Vérifier que tous les widgets enfants sont présents
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should have correct structure with Column and children', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Trouver tous les Column descendants du SingleChildScrollView
      final columnFinders = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Column),
      );
      expect(columnFinders, findsWidgets);

      // Vérifier qu'au moins un Column a le bon crossAxisAlignment
      final columns = tester.widgetList<Column>(columnFinders);
      final hasCorrectAlignment = columns.any((column) => column.crossAxisAlignment == CrossAxisAlignment.start);
      expect(hasCorrectAlignment, isTrue);
    });

    testWidgets('should have correct spacing between widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Vérifier que les SizedBox avec height 24 sont présents
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final hasCorrectSpacing = sizedBoxes.any((sizedBox) => 
        sizedBox.height == 24
      );
      expect(hasCorrectSpacing, isTrue);
    });

    testWidgets('should handle large datasets', (WidgetTester tester) async {
      final List<Habit> largeHabits = List.generate(100, (index) => Habit(
        id: 'habit_$index',
        name: 'Habit $index',
        type: HabitType.binary,
        category: 'Category ${index % 5}',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(habits: largeHabits));

      // Vérifier que le widget se rend sans erreur avec de grandes quantités de données
      expect(find.byType(HabitsTabWidget), findsOneWidget);
    });

    testWidgets('should handle single habit', (WidgetTester tester) async {
      final singleHabit = [
        Habit(
          id: '1',
          name: 'Méditation',
          type: HabitType.binary,
          category: 'Bien-être',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(createTestWidget(habits: singleHabit));

      // Vérifier que le widget se rend correctement avec une seule habitude
      expect(find.byType(HabitsTabWidget), findsOneWidget);
    });

    testWidgets('should handle habits with different types', (WidgetTester tester) async {
      final mixedHabits = [
        Habit(
          id: '1',
          name: 'Méditation',
          type: HabitType.binary,
          category: 'Bien-être',
          createdAt: DateTime.now(),
        ),
        Habit(
          id: '2',
          name: 'Boire de l\'eau',
          type: HabitType.quantitative,
          category: 'Santé',
          targetValue: 2.0,
          unit: 'litres',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(createTestWidget(habits: mixedHabits));

      // Vérifier que le widget se rend correctement avec des habitudes de types différents
      expect(find.byType(HabitsTabWidget), findsOneWidget);
    });

    testWidgets('should handle habits without categories', (WidgetTester tester) async {
      final habitsWithoutCategory = [
        Habit(
          id: '1',
          name: 'Méditation',
          type: HabitType.binary,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(createTestWidget(habits: habitsWithoutCategory));

      // Vérifier que le widget se rend correctement avec des habitudes sans catégorie
      expect(find.byType(HabitsTabWidget), findsOneWidget);
    });
  });
} 

