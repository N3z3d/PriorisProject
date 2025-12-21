import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/value_objects/habit_frequency.dart';
import 'package:prioris/domain/services/habit_frequency_summary_service.dart';
import 'package:prioris/l10n/app_localizations.dart';

void main() {
  Future<String> _renderSummary(
    WidgetTester tester,
    HabitFrequency frequency,
  ) async {
    late String summary;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            summary = HabitFrequencySummaryService.generateSummary(
                context, frequency);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return summary;
  }

  testWidgets('summarizes quarterly and semester frequencies', (tester) async {
    final quarterSummary = await _renderSummary(
      tester,
      const HabitFrequency(
        model: FrequencyModel.timesPerPeriod,
        timesCount: 1,
        period: FrequencyPeriod.quarter,
      ),
    );

    final semesterSummary = await _renderSummary(
      tester,
      const HabitFrequency(
        model: FrequencyModel.timesPerPeriod,
        timesCount: 2,
        period: FrequencyPeriod.semester,
      ),
    );

    expect(quarterSummary, contains('per quarter'));
    expect(semesterSummary, contains('times per semester'));
  });

  testWidgets('summarizes M days out of N cycle', (tester) async {
    final summary = await _renderSummary(
      tester,
      const HabitFrequency(
        model: FrequencyModel.daysPerCycle,
        daysActive: 2,
        daysCycle: 3,
      ),
    );

    expect(summary, contains('2 days out of 3'));
  });

  testWidgets('summarizes specific date once and yearly', (tester) async {
    final onceSummary = await _renderSummary(
      tester,
      HabitFrequency(
        model: FrequencyModel.specificDate,
        specificDate: DateTime(2025, 11, 24),
      ),
    );
    final yearlySummary = await _renderSummary(
      tester,
      HabitFrequency(
        model: FrequencyModel.specificDate,
        specificDate: DateTime(2025, 11, 24),
        repeatEveryYear: true,
      ),
    );

    expect(onceSummary, contains('Nov'));
    expect(onceSummary, contains('24'));
    expect(yearlySummary, contains('Every year'));
  });
}
