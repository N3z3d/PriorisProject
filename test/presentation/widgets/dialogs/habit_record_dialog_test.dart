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
  });
} 
