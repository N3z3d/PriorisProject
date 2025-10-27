import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habits_body.dart';

void main() {
  testWidgets('HabitsBody renders habits list when data is available',
      (tester) async {
    final incomplete = Habit(name: 'Read', type: HabitType.binary);
    final completed = Habit(name: 'Workout', type: HabitType.binary)
      ..markCompleted(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitsBody(
            habits: [incomplete, completed],
            isLoading: false,
            error: null,
            onDeleteHabit: (_, __) {},
            onRecordHabit: (_) {},
            onCreateHabit: () {},
            onEditHabit: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Workout'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('HabitsBody shows loading state when fetching data',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitsBody(
            habits: [],
            isLoading: true,
            error: null,
            onDeleteHabit: (_, __) {},
            onRecordHabit: (_) {},
            onCreateHabit: () {},
            onEditHabit: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
