import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/habit_footer.dart';

void main() {
  group('HabitFooter', () {
    testWidgets('should display category and recurrence', (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Test Habit',
        description: 'Test',
        type: HabitType.binary,
        category: 'Santé',
        recurrenceType: RecurrenceType.dailyInterval,
        intervalDays: 2,
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitFooter(habit: habit),
          ),
        ),
      );

      expect(find.text('Santé'), findsOneWidget);
      expect(find.text('Tous les 2 jours'), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('should display default recurrence if null', (WidgetTester tester) async {
      final habit = Habit(
        id: '2',
        name: 'Test Habit',
        description: 'Test',
        type: HabitType.binary,
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitFooter(habit: habit),
          ),
        ),
      );

      expect(find.text('Quotidien'), findsOneWidget);
    });

    testWidgets('should display correct recurrence for weeklyDays', (WidgetTester tester) async {
      final habit = Habit(
        id: '3',
        name: 'Test Habit',
        description: 'Test',
        type: HabitType.binary,
        recurrenceType: RecurrenceType.weeklyDays,
        weekdays: [0, 2, 4],
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitFooter(habit: habit),
          ),
        ),
      );

      expect(find.textContaining('Lun'), findsOneWidget);
      expect(find.textContaining('Mer'), findsOneWidget);
      expect(find.textContaining('Ven'), findsOneWidget);
    });
  });
} 
