import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/services/statistics_calculation_service.dart';

void main() {
  group('StatisticsCalculationService', () {
    group('calculateHabitSuccessRate', () {
      test('should return 0 for empty habits list', () {
        final result = StatisticsCalculationService.calculateHabitSuccessRate([]);
        expect(result, equals(0));
      });

      test('should calculate average success rate for multiple habits', () {
        final now = DateTime.now();
        final habit1 = Habit(
          name: 'Test Habit 1',
          type: HabitType.binary,
        );
        final habit2 = Habit(
          name: 'Test Habit 2',
          type: HabitType.binary,
        );

        // Simuler des données de complétion pour les 7 derniers jours
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit1.completions[dateKey] = true; // 100% de réussite
          habit2.completions[dateKey] = false; // 0% de réussite
        }

        final result = StatisticsCalculationService.calculateHabitSuccessRate([habit1, habit2]);
        expect(result, equals(50)); // (100 + 0) / 2 = 50
      });
    });

    group('calculateTaskCompletionRate', () {
      test('should return 0 for empty tasks list', () {
        final result = StatisticsCalculationService.calculateTaskCompletionRate([]);
        expect(result, equals(0));
      });

      test('should calculate completion rate correctly', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);
        final task3 = Task(title: 'Task 3', isCompleted: true);

        final result = StatisticsCalculationService.calculateTaskCompletionRate([task1, task2, task3]);
        expect(result, equals(67)); // 2/3 * 100 = 67
      });
    });

    group('calculateCurrentStreak', () {
      test('should return 0 for empty habits list', () {
        final result = StatisticsCalculationService.calculateCurrentStreak([]);
        expect(result, equals(0));
      });

      test('should return the highest streak among habits', () {
        final now = DateTime.now();
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);

        // Simuler des streaks différents
        for (int i = 0; i < 3; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit1.completions[dateKey] = true;
        }

        for (int i = 0; i < 5; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit2.completions[dateKey] = true;
        }

        final result = StatisticsCalculationService.calculateCurrentStreak([habit1, habit2]);
        expect(result, equals(5)); // Le plus haut streak
      });
    });

    group('calculateTotalPoints', () {
      test('should calculate points correctly', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final result = StatisticsCalculationService.calculateTotalPoints([habit1, habit2], [task1, task2]);
        
        // 2 habitudes * 50 = 100 points
        // 1 tâche complétée * 25 = 25 points
        // Total = 125 points
        expect(result, equals(125));
      });

      test('should return 0 for empty lists', () {
        final result = StatisticsCalculationService.calculateTotalPoints([], []);
        expect(result, equals(0));
      });
    });

    group('calculateCategoryPerformance', () {
      test('should return empty map for empty lists', () {
        final result = StatisticsCalculationService.calculateCategoryPerformance([], []);
        expect(result, isEmpty);
      });

      test('should calculate performance by category', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary, category: 'Work');
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary, category: 'Work');
        final task1 = Task(title: 'Task 1', category: 'Work', isCompleted: true);
        final task2 = Task(title: 'Task 2', category: 'Personal', isCompleted: false);

        // Simuler des données de réussite
        final now = DateTime.now();
        final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        habit1.completions[dateKey] = true; // 100%
        habit2.completions[dateKey] = false; // 0%

        final result = StatisticsCalculationService.calculateCategoryPerformance([habit1, habit2], [task1, task2]);
        
        expect(result['Work'], isNotNull);
        expect(result['Personal'], isNotNull);
        // Work: (100 + 0 + 100) / 3 = 67%
        // Personal: 0 / 1 = 0%
      });
    });

    group('generateSmartInsights', () {
      test('should generate insights for high productivity', () {
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        final now = DateTime.now();
        
        // Simuler une haute productivité (100% de réussite)
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = StatisticsCalculationService.generateSmartInsights([habit], []);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
      });

      test('should generate warning for many pending tasks', () {
        final tasks = List.generate(15, (i) => Task(title: 'Task $i', isCompleted: false));
        
        final insights = StatisticsCalculationService.generateSmartInsights([], tasks);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'error'), isTrue);
      });
    });

    group('calculateEloStatistics', () {
      test('should return default values for empty tasks list', () {
        final result = StatisticsCalculationService.calculateEloStatistics([]);
        
        expect(result['averageElo'], equals(0.0));
        expect(result['maxElo'], equals(0.0));
        expect(result['minElo'], equals(0.0));
        expect(result['distribution']['easy'], equals(0));
        expect(result['distribution']['medium'], equals(0));
        expect(result['distribution']['hard'], equals(0));
      });

      test('should calculate ELO statistics correctly', () {
        final task1 = Task(title: 'Easy Task', eloScore: 1100.0);
        final task2 = Task(title: 'Medium Task', eloScore: 1300.0);
        final task3 = Task(title: 'Hard Task', eloScore: 1500.0);

        final result = StatisticsCalculationService.calculateEloStatistics([task1, task2, task3]);
        
        expect(result['averageElo'], equals(1300.0));
        expect(result['maxElo'], equals(1500.0));
        expect(result['minElo'], equals(1100.0));
        expect(result['distribution']['easy'], equals(1));
        expect(result['distribution']['medium'], equals(1));
        expect(result['distribution']['hard'], equals(1));
      });
    });

    group('calculateCompletionTimeStats', () {
      test('should return default values for empty tasks list', () {
        final result = StatisticsCalculationService.calculateCompletionTimeStats([]);
        
        expect(result['averageTime'], equals(0.0));
        expect(result['fastestCategory'], isNull);
        expect(result['slowestCategory'], isNull);
        expect(result['categoryTimes'], isEmpty);
      });

      test('should calculate completion time statistics', () {
        final now = DateTime.now();
        final task1 = Task(
          title: 'Fast Task',
          category: 'Work',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 1)),
          completedAt: now,
        );
        final task2 = Task(
          title: 'Slow Task',
          category: 'Personal',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 5)),
          completedAt: now,
        );

        final result = StatisticsCalculationService.calculateCompletionTimeStats([task1, task2]);
        
        expect(result['averageTime'], equals(3.0)); // (1 + 5) / 2
        expect(result['fastestCategory'], equals('Work'));
        expect(result['slowestCategory'], equals('Personal'));
        expect(result['categoryTimes']['Work'], equals(1.0));
        expect(result['categoryTimes']['Personal'], equals(5.0));
      });
    });

    group('getProgressColor', () {
      test('should return success color for high values', () {
        final color = StatisticsCalculationService.getProgressColor(85.0);
        expect(color, isNotNull);
      });

      test('should return error color for low values', () {
        final color = StatisticsCalculationService.getProgressColor(30.0);
        expect(color, isNotNull);
      });
    });
  });
} 
