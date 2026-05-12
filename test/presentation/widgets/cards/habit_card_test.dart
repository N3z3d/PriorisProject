import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/cards/habit_card.dart';

void main() {
  group('HabitCard - int cast (story 8.9)', () {
    testWidgets('should display correct progress text for int todayValue without CastError', (WidgetTester tester) async {
      final habit = Habit(
        id: '1',
        name: 'Drink water',
        type: HabitType.quantitative,
        targetValue: 10.0,
        unit: 'cups',
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HabitCard(
                habit: habit,
                todayValue: 5, // int, not 5.0
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Before fix: (_getProgressValue uses `widget.todayValue as double?`)
      // → null for int → returns 0.0 → HabitProgressBar shows '0.0 / 10.0 cups'
      // After fix: `(widget.todayValue as num?)?.toDouble()` → 5.0 → shows '5.0 / 10.0 cups'
      expect(find.text('5.0 / 10.0 cups'), findsOneWidget);
    });

    testWidgets('should return false for int todayValue below target (progress < 1.0)', (WidgetTester tester) async {
      final habit = Habit(
        id: '2',
        name: 'Push-ups',
        type: HabitType.quantitative,
        targetValue: 20.0,
        unit: 'reps',
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HabitCard(
                habit: habit,
                todayValue: 5, // int, 5/20 = 0.25, below target
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('5.0 / 20.0 reps'), findsOneWidget);
    });

    testWidgets('should clamp progress to 1.0 for int todayValue at or above target', (WidgetTester tester) async {
      final habit = Habit(
        id: '3',
        name: 'Steps',
        type: HabitType.quantitative,
        targetValue: 10.0,
        unit: 'steps',
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HabitCard(
                habit: habit,
                todayValue: 10, // int exactly at target
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('10.0 / 10.0 steps'), findsOneWidget);
    });
  });
}
