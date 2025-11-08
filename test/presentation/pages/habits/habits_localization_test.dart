import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/components/habit_progress_display.dart';
import 'package:prioris/presentation/pages/habits/components/habits_empty_state.dart';

void main() {
  Widget _wrap(Widget child, Locale locale) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    );
  }

  testWidgets('HabitsEmptyState renders FR translations', (tester) async {
    final locale = const Locale('fr');
    final l10n = lookupAppLocalizations(locale);

    await tester.pumpWidget(
      _wrap(
        HabitsEmptyState(onCreateHabit: () {}),
        locale,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.habitsEmptyTitle), findsOneWidget);
    expect(find.text(l10n.habitsEmptySubtitle), findsOneWidget);
    expect(find.text(l10n.habitsButtonCreate), findsWidgets);
  });

  testWidgets('HabitProgressDisplay renders EN metrics with localization',
      (tester) async {
    final locale = const Locale('en');
    final l10n = lookupAppLocalizations(locale);
    final completions = _buildRecentCompletions(successDays: 5, streakDays: 3);
    final habit = Habit(
      name: 'Reading',
      type: HabitType.binary,
      completions: completions,
      targetValue: null,
    );

    await tester.pumpWidget(
      _wrap(HabitProgressDisplay(habit: habit), locale),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.habitProgressThisWeek), findsOneWidget);
    expect(find.textContaining('5/7'), findsOneWidget);
    expect(find.text(l10n.habitProgressStreakDays(3)), findsOneWidget);
    expect(find.text(l10n.habitProgressCompletedToday), findsOneWidget);
  });
}

Map<String, dynamic> _buildRecentCompletions({
  required int successDays,
  required int streakDays,
}) {
  final now = DateTime.now();
  final completions = <String, dynamic>{};

  // Ensure streak days are consecutive including today.
  for (var i = 0; i < streakDays; i++) {
    final date = now.subtract(Duration(days: i));
    completions[_dateKey(date)] = true;
  }

  var extraSuccesses = successDays - streakDays;
  var offset = streakDays + 1;
  while (extraSuccesses > 0) {
    final date = now.subtract(Duration(days: offset));
    completions[_dateKey(date)] = true;
    extraSuccesses--;
    offset += 2;
  }

  return completions;
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
