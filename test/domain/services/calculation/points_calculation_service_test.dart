import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/points_calculation_service.dart';

void main() {
  group('PointsCalculationService', () {
    group('calculateTotalPoints', () {
      test('should return 0 for empty lists', () {
        final result = PointsCalculationService.calculateTotalPoints([], []);
        expect(result, equals(0));
      });

      test('should calculate total points correctly', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final result = PointsCalculationService.calculateTotalPoints([habit1, habit2], [task1, task2]);
        
        // 2 habitudes * 50 = 100 points
        // 1 tâche complétée * 25 = 25 points
        // Total = 125 points
        expect(result, equals(125));
      });

      test('should calculate points for habits only', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);

        final result = PointsCalculationService.calculateTotalPoints([habit1, habit2], []);
        expect(result, equals(100)); // 2 * 50 = 100
      });

      test('should calculate points for tasks only', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: true);
        final task3 = Task(title: 'Task 3', isCompleted: false);

        final result = PointsCalculationService.calculateTotalPoints([], [task1, task2, task3]);
        expect(result, equals(50)); // 2 * 25 = 50
      });
    });

    group('calculateHabitPoints', () {
      test('should return 0 for empty habits list', () {
        final result = PointsCalculationService.calculateHabitPoints([]);
        expect(result, equals(0));
      });

      test('should calculate habit points correctly', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        final habit3 = Habit(name: 'Habit 3', type: HabitType.binary);

        final result = PointsCalculationService.calculateHabitPoints([habit1, habit2, habit3]);
        expect(result, equals(150)); // 3 * 50 = 150
      });
    });

    group('calculateTaskPoints', () {
      test('should return 0 for empty tasks list', () {
        final result = PointsCalculationService.calculateTaskPoints([]);
        expect(result, equals(0));
      });

      test('should calculate task points correctly', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);
        final task3 = Task(title: 'Task 3', isCompleted: true);
        final task4 = Task(title: 'Task 4', isCompleted: false);

        final result = PointsCalculationService.calculateTaskPoints([task1, task2, task3, task4]);
        expect(result, equals(50)); // 2 * 25 = 50
      });

      test('should return 0 for no completed tasks', () {
        final task1 = Task(title: 'Task 1', isCompleted: false);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final result = PointsCalculationService.calculateTaskPoints([task1, task2]);
        expect(result, equals(0));
      });
    });

    group('calculatePointsByCategory', () {
      test('should return empty map for empty lists', () {
        final result = PointsCalculationService.calculatePointsByCategory([], []);
        expect(result, isEmpty);
      });

      test('should calculate points by category correctly', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary, category: 'Work');
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary, category: 'Personal');
        final task1 = Task(title: 'Task 1', category: 'Work', isCompleted: true);
        final task2 = Task(title: 'Task 2', category: 'Personal', isCompleted: false);

        final result = PointsCalculationService.calculatePointsByCategory([habit1, habit2], [task1, task2]);
        
        expect(result['Work'], equals(75)); // 50 (habitude) + 25 (tâche complétée)
        expect(result['Personal'], equals(50)); // 50 (habitude) + 0 (tâche non complétée)
      });

      test('should handle tasks without category', () {
        final habit = Habit(name: 'Habit 1', type: HabitType.binary, category: 'Work');
        final task = Task(title: 'Task 1', isCompleted: true); // Pas de catégorie

        final result = PointsCalculationService.calculatePointsByCategory([habit], [task]);
        
        expect(result['Work'], equals(50)); // 50 (habitude)
        expect(result['Sans catégorie'], equals(25)); // 25 (tâche complétée)
      });
    });

    group('calculateHabitPointsByCategory', () {
      test('should return empty map for empty habits list', () {
        final result = PointsCalculationService.calculateHabitPointsByCategory([]);
        expect(result, isEmpty);
      });

      test('should calculate habit points by category', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary, category: 'Work');
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary, category: 'Work');
        final habit3 = Habit(name: 'Habit 3', type: HabitType.binary, category: 'Personal');

        final result = PointsCalculationService.calculateHabitPointsByCategory([habit1, habit2, habit3]);
        
        expect(result['Work'], equals(100)); // 2 * 50 = 100
        expect(result['Personal'], equals(50)); // 1 * 50 = 50
      });
    });

    group('calculateTaskPointsByCategory', () {
      test('should return empty map for empty tasks list', () {
        final result = PointsCalculationService.calculateTaskPointsByCategory([]);
        expect(result, isEmpty);
      });

      test('should calculate task points by category', () {
        final task1 = Task(title: 'Task 1', category: 'Work', isCompleted: true);
        final task2 = Task(title: 'Task 2', category: 'Work', isCompleted: false);
        final task3 = Task(title: 'Task 3', category: 'Personal', isCompleted: true);

        final result = PointsCalculationService.calculateTaskPointsByCategory([task1, task2, task3]);
        
        expect(result['Work'], equals(25)); // 1 * 25 = 25
        expect(result['Personal'], equals(25)); // 1 * 25 = 25
      });
    });

    group('calculatePointsPercentage', () {
      test('should return 0 for empty lists', () {
        final result = PointsCalculationService.calculatePointsPercentage([], []);
        expect(result, equals(0));
      });

      test('should calculate percentage correctly', () {
        final habit = Habit(name: 'Habit 1', type: HabitType.binary);
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final result = PointsCalculationService.calculatePointsPercentage([habit], [task1, task2]);
        
        // Points obtenus : 50 (habitude) + 25 (tâche complétée) = 75
        // Points max : 50 (habitude) + 50 (2 tâches) = 100
        // Pourcentage : 75/100 * 100 = 75%
        expect(result, equals(75));
      });

      test('should return 100 for all tasks completed', () {
        final habit = Habit(name: 'Habit 1', type: HabitType.binary);
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: true);

        final result = PointsCalculationService.calculatePointsPercentage([habit], [task1, task2]);
        expect(result, equals(100));
      });
    });

    group('calculateMaxPossiblePoints', () {
      test('should return 0 for empty lists', () {
        final result = PointsCalculationService.calculateMaxPossiblePoints([], []);
        expect(result, equals(0));
      });

      test('should calculate max possible points correctly', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        final task1 = Task(title: 'Task 1', isCompleted: false);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final result = PointsCalculationService.calculateMaxPossiblePoints([habit1, habit2], [task1, task2]);
        
        // 2 habitudes * 50 = 100 points
        // 2 tâches * 25 = 50 points
        // Total max = 150 points
        expect(result, equals(150));
      });
    });

    group('calculateRemainingPoints', () {
      test('should return 0 for empty lists', () {
        final result = PointsCalculationService.calculateRemainingPoints([], []);
        expect(result, equals(0));
      });

      test('should calculate remaining points correctly', () {
        final habit = Habit(name: 'Habit 1', type: HabitType.binary);
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final result = PointsCalculationService.calculateRemainingPoints([habit], [task1, task2]);
        
        // Points obtenus : 50 (habitude) + 25 (tâche complétée) = 75
        // Points max : 50 (habitude) + 50 (2 tâches) = 100
        // Points restants : 100 - 75 = 25
        expect(result, equals(25));
      });

      test('should return 0 when all points are obtained', () {
        final habit = Habit(name: 'Habit 1', type: HabitType.binary);
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: true);

        final result = PointsCalculationService.calculateRemainingPoints([habit], [task1, task2]);
        expect(result, equals(0));
      });
    });

    group('calculateAveragePointsPerDay', () {
      test('should return 0.0 for empty lists', () {
        final result = PointsCalculationService.calculateAveragePointsPerDay([], []);
        expect(result, equals(0.0));
      });

      test('should calculate average points per day with fixed clock', () {
        // Horloge fixe : mercredi 22 juillet 2026, 14h00
        final now = DateTime(2026, 7, 22, 14, 0);
        final habit = Habit(name: 'Habit 1', type: HabitType.binary);

        // 100% de réussite sur les 7 jours précédant l'horloge fixe
        _seedCompletions(habit, from: now, days: 7);

        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          completedAt: now.subtract(const Duration(days: 3)),
        );

        final result = PointsCalculationService
            .calculateAveragePointsPerDay([habit], [task], now: now);

        // Habitude : 100% * 50 = 50 points / 7 jours = 7.14
        // Tâche : 25 points / 7 jours = 3.57
        // Total : ~10.71 points par jour
        expect(result, greaterThan(10.0));
        expect(result, lessThan(11.0));
      });

      test('should exclude tasks completed more than 7 days before the clock', () {
        final now = DateTime(2026, 7, 22, 14, 0);
        final oldTask = Task(
          title: 'Old task',
          isCompleted: true,
          completedAt: now.subtract(const Duration(days: 8)),
        );

        final result = PointsCalculationService
            .calculateAveragePointsPerDay([], [oldTask], now: now);

        expect(result, equals(0.0));
      });
    });

    group('calculateWeeklyPoints', () {
      test('should return 0 for empty lists', () {
        final result = PointsCalculationService.calculateWeeklyPoints([], []);
        expect(result, equals(0));
      });

      test('should include a task completed monday morning when run monday afternoon', () {
        // Bug du lundi : weekStart non tronqué à minuit excluait toute tâche
        // complétée le lundi avant l'heure du run.
        final mondayAfternoon = DateTime(2026, 7, 20, 14, 0);
        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          completedAt: DateTime(2026, 7, 20, 9, 0),
        );

        final result = PointsCalculationService
            .calculateWeeklyPoints([], [task], now: mondayAfternoon);

        expect(result, equals(25));
      });

      test('should include a task completed just after monday midnight', () {
        // Passage de minuit : run à 00h05 le lundi, tâche complétée à 00h01
        final justAfterMidnight = DateTime(2026, 7, 20, 0, 5);
        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          completedAt: DateTime(2026, 7, 20, 0, 1),
        );

        final result = PointsCalculationService
            .calculateWeeklyPoints([], [task], now: justAfterMidnight);

        expect(result, equals(25));
      });

      test('should exclude tasks completed before the current week', () {
        // Mercredi 22 juillet 2026 : la semaine commence le lundi 20 à minuit
        final wednesday = DateTime(2026, 7, 22, 14, 0);
        final sundayTask = Task(
          title: 'Sunday task',
          isCompleted: true,
          completedAt: DateTime(2026, 7, 19, 23, 0),
        );
        final mondayTask = Task(
          title: 'Monday task',
          isCompleted: true,
          completedAt: DateTime(2026, 7, 20, 0, 30),
        );

        final result = PointsCalculationService
            .calculateWeeklyPoints([], [sundayTask, mondayTask], now: wednesday);

        expect(result, equals(25));
      });

      test('should calculate weekly points with habits and tasks', () {
        final now = DateTime(2026, 7, 22, 14, 0);
        final habit = Habit(name: 'Habit 1', type: HabitType.binary);
        _seedCompletions(habit, from: now, days: 7);

        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          completedAt: DateTime(2026, 7, 21, 10, 0),
        );

        final result = PointsCalculationService
            .calculateWeeklyPoints([habit], [task], now: now);

        // Habitude : 100% * 50 = 50 points
        // Tâche : 25 points (complétée dans la semaine)
        // Total : 75 points
        expect(result, equals(75));
      });
    });

    group('calculateMonthlyPoints', () {
      test('should return 0 for empty lists', () {
        final result = PointsCalculationService.calculateMonthlyPoints([], []);
        expect(result, equals(0));
      });

      test('should calculate monthly points with fixed clock', () {
        final now = DateTime(2026, 7, 15, 14, 0);
        final habit = Habit(name: 'Habit 1', type: HabitType.binary);
        _seedCompletions(habit, from: now, days: 7);

        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          completedAt: DateTime(2026, 7, 10, 9, 0),
        );

        final result = PointsCalculationService
            .calculateMonthlyPoints([habit], [task], now: now);

        // Habitude : 100% * 50 = 50 points
        // Tâche : 25 points
        // Total : 75 points
        expect(result, equals(75));
      });

      test('should include a task completed on the 1st when run on the 1st', () {
        // 1er du mois : le mois commence le 1er à minuit
        final firstOfMonth = DateTime(2026, 7, 1, 9, 0);
        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          completedAt: DateTime(2026, 7, 1, 8, 0),
        );

        final result = PointsCalculationService
            .calculateMonthlyPoints([], [task], now: firstOfMonth);

        expect(result, equals(25));
      });

      test('should exclude tasks completed the previous month', () {
        final now = DateTime(2026, 7, 15, 14, 0);
        final juneTask = Task(
          title: 'June task',
          isCompleted: true,
          completedAt: DateTime(2026, 6, 30, 23, 0),
        );

        final result = PointsCalculationService
            .calculateMonthlyPoints([], [juneTask], now: now);

        expect(result, equals(0));
      });
    });
  });
}

/// Remplit [habit] avec 100% de réussite sur les [days] jours
/// précédant [from] (inclus), avec des clés de date déterministes.
void _seedCompletions(Habit habit, {required DateTime from, required int days}) {
  for (int i = 0; i < days; i++) {
    final date = from.subtract(Duration(days: i));
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    habit.completions[dateKey] = true;
  }
}

