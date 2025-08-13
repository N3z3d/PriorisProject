import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/forms/habit_recurrence_form.dart';

void main() {
  group('HabitRecurrenceForm', () {
    testWidgets('should display frequency dropdown and default options', (WidgetTester tester) async {
      int intervalDays = 1;
      List<int> selectedWeekdays = [];
      int timesTarget = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitRecurrenceForm(
              selectedRecurrenceType: null,
              onRecurrenceTypeChanged: (_) {},
              intervalDays: intervalDays,
              onIntervalDaysChanged: (_) {},
              selectedWeekdays: selectedWeekdays,
              onWeekdaysChanged: (_) {},
              timesTarget: timesTarget,
              onTimesTargetChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Fréquence'), findsOneWidget);
      expect(find.text('Quotidien (par défaut)'), findsOneWidget);
    });

    testWidgets('should display daily interval option', (WidgetTester tester) async {
      int intervalDays = 2;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitRecurrenceForm(
              selectedRecurrenceType: RecurrenceType.dailyInterval,
              onRecurrenceTypeChanged: (_) {},
              intervalDays: intervalDays,
              onIntervalDaysChanged: (_) {},
              selectedWeekdays: [],
              onWeekdaysChanged: (_) {},
              timesTarget: 1,
              onTimesTargetChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Tous les '), findsOneWidget);
      expect(find.text(' jour(s)'), findsOneWidget);
    });

    testWidgets('should display weekly days option', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitRecurrenceForm(
              selectedRecurrenceType: RecurrenceType.weeklyDays,
              onRecurrenceTypeChanged: (_) {},
              intervalDays: 1,
              onIntervalDaysChanged: (_) {},
              selectedWeekdays: [0, 2],
              onWeekdaysChanged: (_) {},
              timesTarget: 1,
              onTimesTargetChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Jours de la semaine :'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(7));
    });

    testWidgets('should display times per week option', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitRecurrenceForm(
              selectedRecurrenceType: RecurrenceType.timesPerWeek,
              onRecurrenceTypeChanged: (_) {},
              intervalDays: 1,
              onIntervalDaysChanged: (_) {},
              selectedWeekdays: [],
              onWeekdaysChanged: (_) {},
              timesTarget: 3,
              onTimesTargetChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.textContaining('fois par semaine'), findsWidgets);
    });
  });
} 
