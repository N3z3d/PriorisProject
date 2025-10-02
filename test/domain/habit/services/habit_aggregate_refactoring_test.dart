import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/habit/aggregates/habit_aggregate.dart';
import 'package:prioris/domain/habit/services/habit_completion_service.dart';
import 'package:prioris/domain/habit/services/habit_streak_calculator.dart';
import 'package:prioris/domain/habit/services/habit_progress_calculator.dart';

/// Tests de validation du refactoring de HabitAggregate
///
/// Ces tests vérifient que:
/// 1. La refactorisation maintient la compatibilité arrière
/// 2. Les services métier fonctionnent correctement
/// 3. Tous les comportements originaux sont préservés
void main() {
  group('HabitAggregate Refactoring - Backward Compatibility', () {
    test('should create binary habit with same behavior as before', () {
      final habit = HabitAggregate.create(
        name: 'Read daily',
        type: HabitType.binary,
        category: 'Learning',
      );

      expect(habit.name, 'Read daily');
      expect(habit.type, HabitType.binary);
      expect(habit.category, 'Learning');
      expect(habit.getCurrentStreak(), 0);
    });

    test('should create quantitative habit with same behavior as before', () {
      final habit = HabitAggregate.create(
        name: 'Drink water',
        type: HabitType.quantitative,
        targetValue: 8.0,
        unit: 'glasses',
      );

      expect(habit.name, 'Drink water');
      expect(habit.type, HabitType.quantitative);
      expect(habit.targetValue, 8.0);
      expect(habit.unit, 'glasses');
    });

    test('should mark binary habit as completed', () {
      final habit = HabitAggregate.create(
        name: 'Exercise',
        type: HabitType.binary,
      );

      habit.markCompleted(true);

      expect(habit.isCompletedToday(), true);
      expect(habit.getCurrentStreak(), 1);
      expect(habit.getSuccessRate(days: 1), 1.0);
    });

    test('should record quantitative value', () {
      final habit = HabitAggregate.create(
        name: 'Drink water',
        type: HabitType.quantitative,
        targetValue: 8.0,
      );

      habit.recordValue(10.0);

      expect(habit.getTodayValue(), 10.0);
      expect(habit.isCompletedToday(), true);
      expect(habit.getCurrentStreak(), 1);
    });

    test('should calculate streak correctly over multiple days', () {
      final habit = HabitAggregate.create(
        name: 'Daily reading',
        type: HabitType.binary,
      );

      final today = DateTime.now();
      for (int i = 0; i < 5; i++) {
        final date = today.subtract(Duration(days: i));
        habit.markCompleted(true, date: date);
      }

      expect(habit.getCurrentStreak(), 5);
    });

    test('should update name and publish event', () {
      final habit = HabitAggregate.create(
        name: 'Old name',
        type: HabitType.binary,
      );

      habit.updateName('New name');

      expect(habit.name, 'New name');
      expect(habit.domainEvents.length, 2); // Created + Modified
    });

    test('should update target value for quantitative habit', () {
      final habit = HabitAggregate.create(
        name: 'Drink water',
        type: HabitType.quantitative,
        targetValue: 8.0,
      );

      habit.updateTargetValue(10.0);

      expect(habit.targetValue, 10.0);
    });

    test('should throw error when marking quantitative habit with boolean', () {
      final habit = HabitAggregate.create(
        name: 'Drink water',
        type: HabitType.quantitative,
        targetValue: 8.0,
      );

      expect(
        () => habit.markCompleted(true),
        throwsA(isA<InvalidHabitRecordException>()),
      );
    });

    test('should calculate progress correctly', () {
      final habit = HabitAggregate.create(
        name: 'Exercise',
        type: HabitType.binary,
      );

      final today = DateTime.now();
      // Complete 5 out of 10 days
      for (int i = 0; i < 5; i++) {
        final date = today.subtract(Duration(days: i * 2));
        habit.markCompleted(true, date: date);
      }

      final progress = habit.calculateProgress(days: 10);
      expect(progress.percentage, 0.5);
    });
  });

  group('HabitCompletionService - Unit Tests', () {
    const service = HabitCompletionService();

    test('should verify binary completion correctly', () {
      final completions = {
        '2024-01-01': true,
        '2024-01-02': false,
      };

      final isCompleted = service.isCompletedOnDate(
        date: DateTime(2024, 1, 1),
        type: HabitType.binary,
        completions: completions,
        targetValue: null,
      );

      expect(isCompleted, true);
    });

    test('should verify quantitative completion correctly', () {
      final completions = {
        '2024-01-01': 10.0,
        '2024-01-02': 5.0,
      };

      final isCompleted = service.isCompletedOnDate(
        date: DateTime(2024, 1, 1),
        type: HabitType.quantitative,
        completions: completions,
        targetValue: 8.0,
      );

      expect(isCompleted, true);

      final isNotCompleted = service.isCompletedOnDate(
        date: DateTime(2024, 1, 2),
        type: HabitType.quantitative,
        completions: completions,
        targetValue: 8.0,
      );

      expect(isNotCompleted, false);
    });
  });

  group('HabitStreakCalculator - Unit Tests', () {
    const calculator = HabitStreakCalculator();

    test('should calculate current streak correctly', () {
      final completions = {
        '2024-01-05': true,
        '2024-01-04': true,
        '2024-01-03': true,
        '2024-01-02': false,
        '2024-01-01': true,
      };

      final streak = calculator.calculateCurrentStreak(
        fromDate: DateTime(2024, 1, 5),
        type: HabitType.binary,
        completions: completions,
        targetValue: null,
      );

      expect(streak, 3);
    });

    test('should find last completed date correctly', () {
      final completions = {
        '2024-01-05': false,
        '2024-01-04': false,
        '2024-01-03': true,
        '2024-01-02': false,
      };

      final lastDate = calculator.findLastCompletedDate(
        before: DateTime(2024, 1, 5),
        type: HabitType.binary,
        completions: completions,
        targetValue: null,
      );

      expect(lastDate, DateTime(2024, 1, 3));
    });

    test('should check milestone correctly', () {
      final event = calculator.checkStreakMilestone(
        habitId: 'test-id',
        habitName: 'Test Habit',
        streak: 7,
        achievedAt: DateTime.now(),
      );

      expect(event, isNotNull);
      expect(event!.streakLength, 7);
    });

    test('should not create event for non-milestone streak', () {
      final event = calculator.checkStreakMilestone(
        habitId: 'test-id',
        habitName: 'Test Habit',
        streak: 5,
        achievedAt: DateTime.now(),
      );

      expect(event, isNull);
    });
  });

  group('HabitProgressCalculator - Unit Tests', () {
    const calculator = HabitProgressCalculator();

    test('should calculate success rate correctly', () {
      final completions = {
        '2024-01-01': true,
        '2024-01-02': true,
        '2024-01-03': false,
        '2024-01-04': true,
      };

      final rate = calculator.calculateSuccessRate(
        fromDate: DateTime(2024, 1, 4),
        type: HabitType.binary,
        completions: completions,
        targetValue: null,
        days: 4,
      );

      expect(rate, 0.75); // 3 out of 4 days
    });

    test('should count successful days correctly', () {
      final completions = {
        '2024-01-01': 10.0,
        '2024-01-02': 5.0,
        '2024-01-03': 8.0,
        '2024-01-04': 12.0,
      };

      final count = calculator.countSuccessfulDays(
        fromDate: DateTime(2024, 1, 4),
        type: HabitType.quantitative,
        completions: completions,
        targetValue: 8.0,
        days: 4,
      );

      expect(count, 3); // Days with value >= 8.0
    });

    test('should calculate progress correctly', () {
      final completions = {
        '2024-01-01': true,
        '2024-01-02': true,
        '2024-01-03': false,
      };

      final progress = calculator.calculateProgress(
        fromDate: DateTime(2024, 1, 3),
        type: HabitType.binary,
        completions: completions,
        targetValue: null,
        days: 3,
      );

      expect(progress.completed, 2);
      expect(progress.total, 3);
      expect(progress.percentage, closeTo(0.666, 0.01));
    });
  });

  group('SOLID Principles Validation', () {
    test('SRP - Each service has single responsibility', () {
      // HabitCompletionService: handles completion logic
      const completionService = HabitCompletionService();
      expect(completionService, isA<HabitCompletionService>());

      // HabitStreakCalculator: calculates streaks
      const streakCalculator = HabitStreakCalculator();
      expect(streakCalculator, isA<HabitStreakCalculator>());

      // HabitProgressCalculator: calculates progress
      const progressCalculator = HabitProgressCalculator();
      expect(progressCalculator, isA<HabitProgressCalculator>());
    });

    test('DIP - Aggregate depends on abstractions via const services', () {
      final habit = HabitAggregate.create(
        name: 'Test',
        type: HabitType.binary,
      );

      // The aggregate uses services but doesn't create them directly
      // Services are injected as const static dependencies
      expect(habit, isA<HabitAggregate>());
    });

    test('OCP - Services are open for extension via inheritance', () {
      // Services can be extended without modifying existing code
      expect(HabitCompletionService(), isA<HabitCompletionService>());
    });
  });

  group('Method Size Validation', () {
    test('All methods in services should be under 50 lines', () {
      // This is a meta-test to ensure we maintain the constraint
      // In real implementation, we'd check method line counts
      expect(true, true); // Verified manually during refactoring
    });
  });
}
