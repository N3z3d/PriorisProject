import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';
import 'package:prioris/l10n/app_localizations.dart';

import '../../../../test_utils/habit_test_doubles.dart';

void main() {
  group('HabitFormWidget — Nouvelle habitude', () {
    testWidgets('affiche le bloc Nom/Categorie et la phrase de suivi par defaut', (tester) async {
      await tester.pumpWidget(_buildForm());

      expect(find.text('Nouvelle habitude'), findsOneWidget);
      expect(find.byKey(const ValueKey('habit-name-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('habit-category-dropdown')), findsOneWidget);

      expect(find.text('Je veux faire cette habitude'), findsOneWidget);
      expect(find.byKey(const ValueKey('habit-tracking-times-field')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('habit-period-dropdown')));
      await tester.pumpAndSettle();

      expect(find.text('par jour'), findsWidgets);
      expect(find.text('par semaine'), findsOneWidget);
      expect(find.text('par mois'), findsOneWidget);
      expect(find.text('par an'), findsOneWidget);
      expect(find.text('tous les...'), findsOneWidget);
    });

    testWidgets('bascule en mode intervalle et met a jour le resume', (tester) async {
      await tester.pumpWidget(_buildForm());

      await tester.enterText(find.byKey(const ValueKey('habit-name-field')), 'Boire de l eau');

      await tester.tap(find.byKey(const ValueKey('habit-period-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('tous les...').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('habit-interval-count-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('habit-interval-every-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('habit-interval-unit-dropdown')), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('habit-interval-every-field')),
        '20',
      );
      await tester.tap(find.byKey(const ValueKey('habit-interval-unit-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('heures').last);
      await tester.pumpAndSettle();

      final summary = tester.widget<Text>(
        find.byKey(const ValueKey('habit-summary-text')),
      );
      expect(summary.data, contains('Boire de l eau 1 fois toutes les 20 heures'));
    });

    testWidgets('met a jour le resume en temps reel sur la periode choisie', (tester) async {
      await tester.pumpWidget(_buildForm());

      await tester.enterText(find.byKey(const ValueKey('habit-name-field')), 'Lire');
      await tester.enterText(
        find.byKey(const ValueKey('habit-tracking-times-field')),
        '3',
      );
      await tester.tap(find.byKey(const ValueKey('habit-period-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('par semaine').last);
      await tester.pumpAndSettle();

      final summary = tester.widget<Text>(
        find.byKey(const ValueKey('habit-summary-text')),
      );
      expect(summary.data, contains('Lire 3 fois par semaine'));
    });

    testWidgets('active le bouton Creer seulement quand le formulaire est valide', (tester) async {
      await tester.pumpWidget(_buildForm());

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      final buttonFinder =
          find.byWidgetPredicate((widget) => widget is ElevatedButton);

      final nameField = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const ValueKey('habit-name-field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(nameField.controller.text, isEmpty);
      expect(buttonFinder, findsOneWidget);

      ElevatedButton button() => tester.widget<ElevatedButton>(buttonFinder);

      expect(button().onPressed, isNull);

      await tester.enterText(find.byKey(const ValueKey('habit-name-field')), 'Etudier');
      await tester.enterText(find.byKey(const ValueKey('habit-tracking-times-field')), '0');
      await tester.pump();
      expect(button().onPressed, isNotNull);

      await tester.enterText(find.byKey(const ValueKey('habit-tracking-times-field')), '2');
      await tester.pump();
      expect(button().onPressed, isNotNull);
    });

    testWidgets('soumet un Habit configure sur 3 fois par semaine', (tester) async {
      Habit? submitted;

      await tester.pumpWidget(
        _buildForm(
          onSubmit: (habit) => submitted = habit,
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('habit-name-field')), 'Sport');
      await tester.enterText(find.byKey(const ValueKey('habit-tracking-times-field')), '3');
      await tester.tap(find.byKey(const ValueKey('habit-period-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('par semaine').last);
      await tester.pumpAndSettle();

      final submitButton =
          find.byWidgetPredicate((widget) => widget is ElevatedButton);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.timesTarget, 3);
      expect(submitted!.recurrenceType, RecurrenceType.timesPerWeek);
    });
  });
}

Widget _buildForm({
  Habit? initialHabit,
  List<String> categories = const ['Travail', 'Sante'],
  void Function(Habit)? onSubmit,
  HabitCategoryService? categoryService,
}) {
  return MaterialApp(
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
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
