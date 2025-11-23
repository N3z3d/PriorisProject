import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

import '../../../../test_utils/habit_test_doubles.dart';

void main() {
  group('HabitFormWidget state management', () {
    testWidgets('conserve la saisie du nom après rebuild', (tester) async {
      StateSetter? triggerRebuild;

      await tester.pumpWidget(
        _wrapWithMaterial(
          StatefulBuilder(
            builder: (context, setState) {
              triggerRebuild = setState;
              return HabitFormWidget(
                onSubmit: (_) {},
                availableCategories: const ['Personnel'],
              );
            },
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

    testWidgets('ajoute une catégorie personnalisée et la conserve', (tester) async {
      final fakeService = HabitCategoryServiceSpy(createdValue: 'Business');

      await tester.pumpWidget(
        _wrapWithMaterial(
          HabitFormWidget(
            onSubmit: (_) {},
            availableCategories: const ['Personnel'],
            categoryService: fakeService,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('habit-category-create-item')));
      await tester.pumpAndSettle();

      expect(fakeService.promptInvocationCount, 1);
      expect(find.text('Business'), findsWidgets);
    });

    testWidgets('annulation de création ne modifie pas la sélection', (tester) async {
      final fakeService = HabitCategoryServiceSpy(createdValue: null);

      await tester.pumpWidget(
        _wrapWithMaterial(
          HabitFormWidget(
            onSubmit: (_) {},
            availableCategories: const ['Personnel'],
            categoryService: fakeService,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('habit-category-create-item')));
      await tester.pumpAndSettle();

      expect(fakeService.promptInvocationCount, 1);

      await tester.tap(find.byKey(const ValueKey('habit-category-dropdown')));
      await tester.pumpAndSettle();

      expect(find.text('Business'), findsNothing);
    });

    testWidgets('ramène les compteurs invalides à 1 pour préserver la validation', (tester) async {
      await tester.pumpWidget(
        _wrapWithMaterial(
          HabitFormWidget(
            onSubmit: (_) {},
            availableCategories: const ['Personnel'],
          ),
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('habit-name-field')), 'Lecture');
      await tester.enterText(find.byKey(const ValueKey('habit-tracking-times-field')), '0');
      await tester.pump();

      final summary = tester.widget<Text>(
        find.byKey(const ValueKey('habit-summary-text')),
      );

      expect(summary.data, contains('1 fois par jour'));
    });
  });
}

Widget _wrapWithMaterial(Widget child) {
  return MaterialApp(
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}
