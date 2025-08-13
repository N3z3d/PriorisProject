import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/builders/habit_builder.dart';

void main() {
  group('HabitBuilder', () {
    late HabitBuilder builder;

    setUp(() {
      builder = HabitBuilder();
    });

    group('Méthodes de base', () {
      test('should build habit with required parameters', () {
        final habit = builder
            .withName('Test Habit')
            .withType(HabitType.binary)
            .build();

        expect(habit.name, 'Test Habit');
        expect(habit.type, HabitType.binary);
        expect(habit.id, isNotNull);
        expect(habit.createdAt, isNotNull);
      });

      test('should build habit with all optional parameters', () {
        final now = DateTime.now();
        final completions = {'2024-01-01': true};
        
        final habit = builder
            .withId('test-id')
            .withName('Complete Habit')
            .withDescription('Test description')
            .withType(HabitType.quantitative)
            .withCategory('Health')
            .withTargetValue(5.0)
            .withUnit('glasses')
            .withCreatedAt(now)
            .withCompletions(completions)
            .withRecurrenceType(RecurrenceType.dailyInterval)
            .withIntervalDays(2)
            .withWeekdays([1, 3, 5])
            .withTimesTarget(3)
            .withMonthlyDay(15)
            .withQuarterMonth(2)
            .withYearlyMonth(6)
            .withYearlyDay(15)
            .withHourlyInterval(4)
            .build();

        expect(habit.id, 'test-id');
        expect(habit.name, 'Complete Habit');
        expect(habit.description, 'Test description');
        expect(habit.type, HabitType.quantitative);
        expect(habit.category, 'Health');
        expect(habit.targetValue, 5.0);
        expect(habit.unit, 'glasses');
        expect(habit.createdAt, now);
        expect(habit.completions, completions);
        expect(habit.recurrenceType, RecurrenceType.dailyInterval);
        expect(habit.intervalDays, 2);
        expect(habit.weekdays, [1, 3, 5]);
        expect(habit.timesTarget, 3);
        expect(habit.monthlyDay, 15);
        expect(habit.quarterMonth, 2);
        expect(habit.yearlyMonth, 6);
        expect(habit.yearlyDay, 15);
        expect(habit.hourlyInterval, 4);
      });

      test('should throw error when name is missing', () {
        expect(
          () => builder.withType(HabitType.binary).build(),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error when type is missing', () {
        expect(
          () => builder.withName('Test').build(),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Méthodes de configuration pour types courants', () {
      test('should create binary habit with asBinaryHabit', () {
        final habit = builder.asBinaryHabit('Drink Water').build();

        expect(habit.name, 'Drink Water');
        expect(habit.type, HabitType.binary);
      });

      test('should create quantitative habit with asQuantitativeHabit', () {
        final habit = builder
            .asQuantitativeHabit('Read Books', 30.0, 'pages')
            .build();

        expect(habit.name, 'Read Books');
        expect(habit.type, HabitType.quantitative);
        expect(habit.targetValue, 30.0);
        expect(habit.unit, 'pages');
      });

      test('should configure daily recurrence', () {
        final habit = builder
            .withName('Daily Task')
            .withType(HabitType.binary)
            .withDailyRecurrence()
            .build();

        expect(habit.recurrenceType, RecurrenceType.dailyInterval);
        expect(habit.intervalDays, 1);
      });

      test('should configure weekly recurrence', () {
        final habit = builder
            .withName('Weekly Task')
            .withType(HabitType.binary)
            .withWeeklyRecurrence([1, 3, 5])
            .build();

        expect(habit.recurrenceType, RecurrenceType.weeklyDays);
        expect(habit.weekdays, [1, 3, 5]);
      });

      test('should configure monthly recurrence', () {
        final habit = builder
            .withName('Monthly Task')
            .withType(HabitType.binary)
            .withMonthlyRecurrence(15)
            .build();

        expect(habit.recurrenceType, RecurrenceType.monthlyDay);
        expect(habit.monthlyDay, 15);
      });

      test('should configure yearly recurrence', () {
        final habit = builder
            .withName('Yearly Task')
            .withType(HabitType.binary)
            .withYearlyRecurrence(6, 15)
            .build();

        expect(habit.recurrenceType, RecurrenceType.yearly);
        expect(habit.yearlyMonth, 6);
        expect(habit.yearlyDay, 15);
      });

      test('should configure weekdays only', () {
        final habit = builder
            .withName('Weekday Task')
            .withType(HabitType.binary)
            .withWeekdaysOnly()
            .build();

        expect(habit.recurrenceType, RecurrenceType.weekdays);
      });

      test('should configure weekends only', () {
        final habit = builder
            .withName('Weekend Task')
            .withType(HabitType.binary)
            .withWeekendsOnly()
            .build();

        expect(habit.recurrenceType, RecurrenceType.weekends);
      });
    });

    group('Méthode reset', () {
      test('should reset all parameters', () {
        final habit1 = builder
            .withName('First Habit')
            .withType(HabitType.binary)
            .withCategory('Health')
            .build();

        builder.reset();

        final habit2 = builder
            .withName('Second Habit')
            .withType(HabitType.quantitative)
            .build();

        expect(habit1.name, 'First Habit');
        expect(habit1.category, 'Health');
        expect(habit2.name, 'Second Habit');
        expect(habit2.category, isNull);
      });
    });

    group('Scénarios d\'utilisation réels', () {
      test('should build drinking water habit', () {
        final habit = builder
            .asBinaryHabit('Drink Water')
            .withDescription('Drink 8 glasses of water daily')
            .withCategory('Health')
            .withDailyRecurrence()
            .build();

        expect(habit.name, 'Drink Water');
        expect(habit.description, 'Drink 8 glasses of water daily');
        expect(habit.category, 'Health');
        expect(habit.type, HabitType.binary);
        expect(habit.recurrenceType, RecurrenceType.dailyInterval);
        expect(habit.intervalDays, 1);
      });

      test('should build reading habit', () {
        final habit = builder
            .asQuantitativeHabit('Read Books', 30.0, 'pages')
            .withDescription('Read 30 pages daily')
            .withCategory('Learning')
            .withDailyRecurrence()
            .build();

        expect(habit.name, 'Read Books');
        expect(habit.description, 'Read 30 pages daily');
        expect(habit.category, 'Learning');
        expect(habit.type, HabitType.quantitative);
        expect(habit.targetValue, 30.0);
        expect(habit.unit, 'pages');
        expect(habit.recurrenceType, RecurrenceType.dailyInterval);
      });

      test('should build exercise habit for weekdays', () {
        final habit = builder
            .asBinaryHabit('Exercise')
            .withDescription('30 minutes of exercise')
            .withCategory('Fitness')
            .withWeekdaysOnly()
            .build();

        expect(habit.name, 'Exercise');
        expect(habit.description, '30 minutes of exercise');
        expect(habit.category, 'Fitness');
        expect(habit.type, HabitType.binary);
        expect(habit.recurrenceType, RecurrenceType.weekdays);
      });

      test('should build monthly review habit', () {
        final habit = builder
            .asBinaryHabit('Monthly Review')
            .withDescription('Review goals and progress')
            .withCategory('Productivity')
            .withMonthlyRecurrence(1)
            .build();

        expect(habit.name, 'Monthly Review');
        expect(habit.description, 'Review goals and progress');
        expect(habit.category, 'Productivity');
        expect(habit.type, HabitType.binary);
        expect(habit.recurrenceType, RecurrenceType.monthlyDay);
        expect(habit.monthlyDay, 1);
      });
    });

    group('Validation des paramètres', () {
      test('should handle null values correctly', () {
        final habit = builder
            .withName('Test')
            .withType(HabitType.binary)
            .build();

        expect(habit.description, isNull);
        expect(habit.category, isNull);
      });

      test('should generate unique IDs when not provided', () {
        final habit1 = builder
            .withName('Habit 1')
            .withType(HabitType.binary)
            .build();

        final habit2 = builder
            .withName('Habit 2')
            .withType(HabitType.binary)
            .build();

        expect(habit1.id, isNotNull);
        expect(habit2.id, isNotNull);
        expect(habit1.id, isNot(equals(habit2.id)));
      });

      test('should use provided ID when specified', () {
        final habit = builder
            .withId('custom-id')
            .withName('Test')
            .withType(HabitType.binary)
            .build();

        expect(habit.id, 'custom-id');
      });
    });
  });
} 
