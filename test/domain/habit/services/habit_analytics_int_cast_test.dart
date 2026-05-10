import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/habit/aggregates/habit_aggregate.dart';
import 'package:prioris/domain/habit/services/analytics/habit_pattern_analyzer.dart';
import 'package:prioris/domain/habit/services/analytics/habit_consistency_calculator.dart';

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

HabitAggregate _quantitativeHabit({
  required double target,
  required Map<String, dynamic> completions,
}) =>
    HabitAggregate.reconstitute(
      id: 'test-id',
      name: 'Test',
      type: HabitType.quantitative,
      targetValue: target,
      createdAt: DateTime(2024, 1, 1),
      completions: completions,
    );

void main() {
  final now = DateTime.now();

  group('HabitPatternAnalyzer - int cast (story 8.9)', () {
    final analyzer = HabitPatternAnalyzer();

    test('should analyze pattern with int completion values without CastError', () {
      final completions = {
        for (int i = 0; i < 7; i++) _dateKey(now.subtract(Duration(days: i))): 10, // int
      };
      final habit = _quantitativeHabit(target: 8.0, completions: completions);

      expect(() => analyzer.analyze(habit, days: 7), returnsNormally);

      final result = analyzer.analyze(habit, days: 7);
      expect(result.completionsByDayOfWeek, isA<Map<int, int>>());
    });

    test('should count int completions as successful when >= target', () {
      final completions = {
        _dateKey(now): 10,                            // int above target
        _dateKey(now.subtract(const Duration(days: 1))): 5,  // int below target
        _dateKey(now.subtract(const Duration(days: 2))): 8,  // int equal target
      };
      final habit = _quantitativeHabit(target: 8.0, completions: completions);

      final result = analyzer.analyze(habit, days: 7);
      expect(result.completionsByDayOfWeek, isA<Map<int, int>>());
    });

    test('should not count int completions below target as successful', () {
      final completions = {
        _dateKey(now): 3, // int, clearly below target
      };
      final habit = _quantitativeHabit(target: 8.0, completions: completions);

      expect(() => analyzer.analyze(habit, days: 7), returnsNormally);
    });
  });

  group('HabitConsistencyCalculator - int cast (story 8.9)', () {
    final calculator = HabitConsistencyCalculator();

    test('should calculate consistency with int completion values without CastError', () {
      final completions = {
        for (int i = 0; i < 5; i++) _dateKey(now.subtract(Duration(days: i))): 45, // int
      };
      final habit = _quantitativeHabit(target: 30.0, completions: completions);

      expect(() => calculator.calculate(habit, days: 7), returnsNormally);

      final result = calculator.calculate(habit, days: 7);
      expect(result.totalCompletions, greaterThan(0));
    });

    test('should not count int value below target in consistency', () {
      final completions = {
        _dateKey(now): 5, // int below target
      };
      final habit = _quantitativeHabit(target: 30.0, completions: completions);

      final result = calculator.calculate(habit, days: 7);
      expect(result.totalCompletions, 0);
    });

    test('should count int value exactly at target as completed', () {
      final completions = {
        _dateKey(now): 30, // int equal to target
      };
      final habit = _quantitativeHabit(target: 30.0, completions: completions);

      final result = calculator.calculate(habit, days: 7);
      expect(result.totalCompletions, 1);
    });
  });
}
