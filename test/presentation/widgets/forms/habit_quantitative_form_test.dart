import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/forms/habit_quantitative_form.dart';

void main() {
  group('HabitQuantitativeForm', () {
    late TextEditingController targetValueController;
    late TextEditingController unitController;

    setUp(() {
      targetValueController = TextEditingController();
      unitController = TextEditingController();
    });

    testWidgets('should not display if type is binary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitQuantitativeForm(
              targetValueController: targetValueController,
              unitController: unitController,
              selectedType: HabitType.binary,
            ),
          ),
        ),
      );
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('should display fields if type is quantitative', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitQuantitativeForm(
              targetValueController: targetValueController,
              unitController: unitController,
              selectedType: HabitType.quantitative,
            ),
          ),
        ),
      );
      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Objectif *'), findsOneWidget);
      expect(find.text('Unité'), findsOneWidget);
    });
  });
} 
