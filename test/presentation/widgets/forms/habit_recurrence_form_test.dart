import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/forms/habit_recurrence_form.dart';

Widget _buildLocalizedApp(Widget child) {
  return MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('HabitRecurrenceForm', () {
    testWidgets(
      'should display frequency dropdown and default options',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildLocalizedApp(
            HabitRecurrenceForm(
              selectedRecurrenceType: null,
              onRecurrenceTypeChanged: (_) {},
              intervalDays: 1,
              onIntervalDaysChanged: (_) {},
              selectedWeekdays: const [],
              onWeekdaysChanged: (_) {},
              timesTarget: 1,
              onTimesTargetChanged: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Fréquence'), findsOneWidget);
        expect(find.text('Quotidien (par défaut)'), findsOneWidget);
      },
    );

    testWidgets('should display daily interval option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildLocalizedApp(
          HabitRecurrenceForm(
            selectedRecurrenceType: RecurrenceType.dailyInterval,
            onRecurrenceTypeChanged: (_) {},
            intervalDays: 2,
            onIntervalDaysChanged: (_) {},
            selectedWeekdays: const [],
            onWeekdaysChanged: (_) {},
            timesTarget: 1,
            onTimesTargetChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tous les '), findsOneWidget);
      expect(find.text(' jour(s)'), findsOneWidget);
    });

    testWidgets('should display weekly days option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildLocalizedApp(
          HabitRecurrenceForm(
            selectedRecurrenceType: RecurrenceType.weeklyDays,
            onRecurrenceTypeChanged: (_) {},
            intervalDays: 1,
            onIntervalDaysChanged: (_) {},
            selectedWeekdays: const [0, 2],
            onWeekdaysChanged: (_) {},
            timesTarget: 1,
            onTimesTargetChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jours de la semaine :'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(7));
    });

    testWidgets('should display times per week option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildLocalizedApp(
          HabitRecurrenceForm(
            selectedRecurrenceType: RecurrenceType.timesPerWeek,
            onRecurrenceTypeChanged: (_) {},
            intervalDays: 1,
            onIntervalDaysChanged: (_) {},
            selectedWeekdays: const [],
            onWeekdaysChanged: (_) {},
            timesTarget: 3,
            onTimesTargetChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('fois par semaine'), findsWidgets);
    });
  });
}
