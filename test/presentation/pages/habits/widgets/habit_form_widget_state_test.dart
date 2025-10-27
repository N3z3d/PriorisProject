import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

import '../../../../test_utils/habit_test_doubles.dart';

void main() {
  group('HabitFormWidget state management', () {
    testWidgets('conserve la saisie du nom après rebuild', (tester) async {
      StateSetter? triggerRebuild;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                triggerRebuild = setState;
                return HabitFormWidget(
                  onSubmit: (_) {},
                  availableCategories: const ['Personnel'],
                );
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('habit-name-field')),
        'Nouvelle habitude',
      );

      triggerRebuild!.call(() {});
      await tester.pump();

      final field = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(field.controller.text, 'Nouvelle habitude');
    });

    testWidgets('ajoute une catégorie personnalisée et la conserve',
        (tester) async {
      final fakeService = HabitCategoryServiceSpy(createdValue: 'Business');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitFormWidget(
              onSubmit: (_) {},
              availableCategories: const ['Personnel'],
              categoryService: fakeService,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ Créer une nouvelle catégorie…'));
      await tester.pumpAndSettle();

      expect(fakeService.promptInvocationCount, 1);
      expect(find.text('Business'), findsWidgets);
    });

    testWidgets('annulation de création n\'altère pas la sélection',
        (tester) async {
      final fakeService = HabitCategoryServiceSpy(createdValue: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitFormWidget(
              onSubmit: (_) {},
              availableCategories: const ['Personnel'],
              categoryService: fakeService,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ Créer une nouvelle catégorie…'));
      await tester.pumpAndSettle();

      expect(fakeService.promptInvocationCount, 1);

      // Rouvre le menu pour vérifier qu'aucune nouvelle entrée n'est ajoutée.
      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();

      expect(find.text('Business'), findsNothing);
    });
  });
}
