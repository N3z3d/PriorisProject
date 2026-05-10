import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/dialogs/habit_record_dialog.dart';

void main() {
  group('HabitRecordDialog', () {
    testWidgets('should display dialog and save value', (WidgetTester tester) async {
      double? savedValue;
      final habit = Habit(
        id: '1',
        name: 'Test Habit',
        type: HabitType.quantitative,
        targetValue: 10.0,
        unit: 'verres',
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => HabitRecordDialog(
                    habit: habit,
                    currentValue: 5.0,
                    onSave: (value) => savedValue = value,
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Enregistrer'), findsWidgets);
      expect(find.text('Valeur actuelle pour aujourd\'hui'), findsOneWidget);
      expect(find.text('Objectif : 10.0 verres'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '7.5');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(savedValue, 7.5);
    });

    // --- 8.9 int cast tests ---

    testWidgets('should pre-fill field with int currentValue without CastError (story 8.9)', (WidgetTester tester) async {
      final habit = Habit(
        id: '2',
        name: 'Drink water',
        type: HabitType.quantitative,
        targetValue: 10.0,
        unit: 'verres',
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => HabitRecordDialog(
                    habit: habit,
                    currentValue: 5, // int, not 5.0
                    onSave: (_) {},
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // With (currentValue as double?)?.toString(), int 5 silently gives empty string ''
      // After fix with (currentValue as num?)?.toDouble()?.toString(), gives '5.0'
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller?.text, isNotEmpty);
      expect(field.controller?.text, '5.0');
    });
  });
} 
