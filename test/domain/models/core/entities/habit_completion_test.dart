import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

void main() {
  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  group('Habit.markCompleted', () {
    test('ajoute la date du jour dans completions avec valeur true', () {
      final habit = Habit(name: 'H', type: HabitType.binary);
      expect(habit.completions, isEmpty);

      habit.markCompleted(true);

      final todayKey = dateKey(DateTime.now());
      expect(habit.completions[todayKey], isTrue);
    });

    test('ecrase une completion existante du jour', () {
      final habit = Habit(name: 'H', type: HabitType.binary);
      habit.markCompleted(true);
      habit.markCompleted(false);

      final todayKey = dateKey(DateTime.now());
      expect(habit.completions[todayKey], isFalse);
    });
  });

  group('Habit.isCompletedToday', () {
    test('retourne true apres markCompleted(true)', () {
      final habit = Habit(name: 'H', type: HabitType.binary);
      habit.markCompleted(true);
      expect(habit.isCompletedToday(), isTrue);
    });

    test('retourne false sur nouvelle habitude', () {
      final habit = Habit(name: 'H', type: HabitType.binary);
      expect(habit.isCompletedToday(), isFalse);
    });
  });

  group('Habit.getSuccessRate', () {
    test('retourne 0.0 sans completions', () {
      final habit = Habit(name: 'H', type: HabitType.binary);
      expect(habit.getSuccessRate(days: 7), 0.0);
    });

    test('retourne 1.0 si complete chaque jour de la periode', () {
      final now = DateTime.now();
      final completions = <String, dynamic>{
        for (int i = 0; i < 7; i++) dateKey(now.subtract(Duration(days: i))): true,
      };
      final habit = Habit(name: 'H', type: HabitType.binary, completions: completions);
      expect(habit.getSuccessRate(days: 7), 1.0);
    });

    test('retourne le bon ratio pour 3/7 jours', () {
      final now = DateTime.now();
      final completions = <String, dynamic>{
        dateKey(now): true,
        dateKey(now.subtract(const Duration(days: 2))): true,
        dateKey(now.subtract(const Duration(days: 5))): true,
      };
      final habit = Habit(name: 'H', type: HabitType.binary, completions: completions);
      expect(habit.getSuccessRate(days: 7), closeTo(3 / 7, 0.001));
    });
  });

  group('Habit.getCurrentStreak', () {
    test('retourne 0 sans completions', () {
      final habit = Habit(name: 'H', type: HabitType.binary);
      expect(habit.getCurrentStreak(), 0);
    });

    test('retourne 1 apres markCompleted(true)', () {
      final habit = Habit(name: 'H', type: HabitType.binary);
      habit.markCompleted(true);
      expect(habit.getCurrentStreak(), 1);
    });

    test('retourne le nombre de jours consecutifs', () {
      final now = DateTime.now();
      final completions = <String, dynamic>{
        for (int i = 0; i < 4; i++) dateKey(now.subtract(Duration(days: i))): true,
      };
      final habit = Habit(name: 'H', type: HabitType.binary, completions: completions);
      expect(habit.getCurrentStreak(), 4);
    });

    test('coupe le streak sur un jour manquant', () {
      final now = DateTime.now();
      // today and 2 days ago complete, yesterday missing
      final completions = <String, dynamic>{
        dateKey(now): true,
        dateKey(now.subtract(const Duration(days: 2))): true,
      };
      final habit = Habit(name: 'H', type: HabitType.binary, completions: completions);
      expect(habit.getCurrentStreak(), 1);
    });
  });

  group('Habit quantitative — cast int→double Supabase', () {
    test('getSuccessRate ne crashe pas si la completion est un int', () {
      final habit = Habit(
        name: 'Quantitative',
        type: HabitType.quantitative,
        targetValue: 3.0,
        completions: {
          dateKey(DateTime.now()): 5, // int, pas double
        },
      );
      expect(() => habit.getSuccessRate(), returnsNormally);
      expect(habit.getSuccessRate(), closeTo(1.0 / 7, 1e-9)); // 1 jour réussi sur 7
    });

    test('getCurrentStreak ne crashe pas si la completion est un int', () {
      final habit = Habit(
        name: 'Quantitative',
        type: HabitType.quantitative,
        targetValue: 3.0,
        completions: {
          dateKey(DateTime.now()): 5, // int
        },
      );
      expect(() => habit.getCurrentStreak(), returnsNormally);
      expect(habit.getCurrentStreak(), 1);
    });

    test('isCompletedToday ne crashe pas si la completion est un int', () {
      final habit = Habit(
        name: 'Quantitative',
        type: HabitType.quantitative,
        targetValue: 3.0,
        completions: {
          dateKey(DateTime.now()): 5, // int
        },
      );
      expect(() => habit.isCompletedToday(), returnsNormally);
      expect(habit.isCompletedToday(), isTrue);
    });

    test('fromJson ne crashe pas si target_value est un int JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'Test',
        'type': 'quantitative',
        'target_value': 5, // int JSON, pas 5.0
        'created_at': DateTime.now().toIso8601String(),
        'completions': <String, dynamic>{},
      };
      final habit = Habit.fromJson(json);
      expect(habit.targetValue, equals(5.0));
      expect(habit.targetValue, isA<double>());
    });
  });
}
