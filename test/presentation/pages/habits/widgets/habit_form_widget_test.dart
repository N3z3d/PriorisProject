import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

import '../../../../test_utils/habit_test_doubles.dart';

void main() {
  group('HabitFormWidget', () {
    testWidgets('affiche le libellé de catégorie une seule fois', (tester) async {
      await tester.pumpWidget(_buildForm());

      expect(find.text('Catégorie (facultatif)'), findsOneWidget);
    });

    testWidgets('affiche une phrase guide pour le type d\'habitude', (tester) async {
      await tester.pumpWidget(_buildForm());

      expect(find.text('Je veux'), findsOneWidget);
      expect(find.text('Cocher quand c\'est fait'), findsOneWidget);
      expect(find.text('Mesurer une quantité'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(2));

      final description = tester.widget<Text>(
        find.byKey(const ValueKey('habit-type-description')),
      );
      expect(description.data, contains('coch'));
    });

    testWidgets('met à jour la description quand le type quantitatif est sélectionné', (tester) async {
      await tester.pumpWidget(_buildForm());

      await tester.tap(find.text('Mesurer une quantité'));
      await tester.pumpAndSettle();

      final description = tester.widget<Text>(
        find.byKey(const ValueKey('habit-type-description')),
      );
      expect(description.data, contains('quantité'));
    });

    testWidgets('crée une nouvelle catégorie via le service et la sélectionne', (tester) async {
      final fakeService = HabitCategoryServiceSpy(createdValue: 'Business');

      await tester.pumpWidget(
        _buildForm(categoryService: fakeService),
      );

      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('habit-category-create-item')));
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

      await tester.tap(find.text('Mesurer une quantité'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const ValueKey('habit-target-field')), '3,5');
      await tester.enterText(find.byKey(const ValueKey('habit-unit-field')), 'km');
      await tester.enterText(find.byKey(const ValueKey('habit-name-field')), 'Course');

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Créer l\'habitude'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.type, HabitType.quantitative);
      expect(submitted!.targetValue, 3.5);
      expect(submitted!.unit, 'km');
    });

    testWidgets('affiche un SnackBar si le nom est vide', (tester) async {
      await tester.pumpWidget(_buildForm());

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Créer l\'habitude'));
      await tester.pump();

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
