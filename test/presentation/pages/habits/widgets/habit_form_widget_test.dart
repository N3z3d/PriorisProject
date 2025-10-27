import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

import '../../../../test_utils/habit_test_doubles.dart';

void main() {
  group('HabitFormWidget', () {
    testWidgets('affiche le libellé de catégorie une seule fois', (tester) async {
      await tester.pumpWidget(
        _buildForm(),
      );

      expect(find.text('Catégorie (facultatif)'), findsOneWidget);
    });

    testWidgets('crée une nouvelle catégorie via le service et la sélectionne', (tester) async {
      final fakeService = HabitCategoryServiceSpy(
        createdValue: 'Business',
      );

      await tester.pumpWidget(
        _buildForm(categoryService: fakeService),
      );

      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ Créer une nouvelle catégorie…'));
      await tester.pumpAndSettle();

      expect(fakeService.promptInvocationCount, 1);
      expect(find.text('Business'), findsWidgets);
    });

    testWidgets('soumet une habitude quantitative avec objectif et unité', (tester) async {
      Habit? submitted;

      await tester.pumpWidget(
        _buildForm(
          onSubmit: (habit) => submitted = habit,
        ),
      );

      await tester.tap(find.text('Quantité'));
      await tester.pump();

      await tester.enterText(find.byKey(const ValueKey('habit-target-field')), '3,5');
      await tester.enterText(find.byKey(const ValueKey('habit-unit-field')), 'km');
      await tester.enterText(find.byKey(const ValueKey('habit-name-field')), 'Course');

      await tester.ensureVisible(find.text('Créer l\'habitude'));
      await tester.tap(find.text('Créer l\'habitude'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.type, HabitType.quantitative);
      expect(submitted!.targetValue, 3.5);
      expect(submitted!.unit, 'km');
    });

    testWidgets('affiche un SnackBar si le nom est vide', (tester) async {
      await tester.pumpWidget(_buildForm());

      await tester.tap(find.text('Créer l\'habitude'));
      await tester.pump(); // pump pour afficher le SnackBar

      expect(find.text('Veuillez saisir un nom pour l\'habitude'), findsOneWidget);
    });
  });
}

Widget _buildForm({
  Habit? initialHabit,
  List<String> categories = const ['Travail', 'Santé'],
  void Function(Habit)? onSubmit,
  HabitCategoryService? categoryService,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HabitFormWidget(
          initialHabit: initialHabit,
          availableCategories: categories,
          onSubmit: onSubmit ?? (_) {},
          categoryService: categoryService ?? const HabitCategoryService(),
        ),
      ),
    ),
  );
}
