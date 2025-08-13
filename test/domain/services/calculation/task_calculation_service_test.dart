import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';

void main() {
  group('TaskCalculationService', () {
    group('calculateCompletionRate', () {
      test('should return 0 for empty tasks list', () {
        final result = TaskCalculationService.calculateCompletionRate([]);
        expect(result, equals(0));
      });

      test('should calculate completion rate correctly', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);
        final task3 = Task(title: 'Task 3', isCompleted: true);

        final result = TaskCalculationService.calculateCompletionRate([task1, task2, task3]);
        expect(result, equals(67)); // 2/3 * 100 = 67
      });

      test('should return 100 for all completed tasks', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: true);

        final result = TaskCalculationService.calculateCompletionRate([task1, task2]);
        expect(result, equals(100));
      });

      test('should return 0 for no completed tasks', () {
        final task1 = Task(title: 'Task 1', isCompleted: false);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final result = TaskCalculationService.calculateCompletionRate([task1, task2]);
        expect(result, equals(0));
      });
    });

    group('calculateEloStatistics', () {
      test('should return default values for empty tasks list', () {
        final result = TaskCalculationService.calculateEloStatistics([]);
        
        expect(result['averageElo'], equals(0.0));
        expect(result['maxElo'], equals(0.0));
        expect(result['minElo'], equals(0.0));
        expect(result['distribution']['easy'], equals(0));
        expect(result['distribution']['medium'], equals(0));
        expect(result['distribution']['hard'], equals(0));
      });

      test('should calculate ELO statistics correctly', () {
        final task1 = Task(title: 'Task 1', eloScore: 1000); // Easy
        final task2 = Task(title: 'Task 2', eloScore: 1300); // Medium
        final task3 = Task(title: 'Task 3', eloScore: 1500); // Hard

        final result = TaskCalculationService.calculateEloStatistics([task1, task2, task3]);
        
        expect(result['averageElo'], equals(1266.6666666666667));
        expect(result['maxElo'], equals(1500));
        expect(result['minElo'], equals(1000));
        expect(result['distribution']['easy'], equals(1));
        expect(result['distribution']['medium'], equals(1));
        expect(result['distribution']['hard'], equals(1));
      });

      test('should categorize ELO scores correctly', () {
        final easyTask = Task(title: 'Easy', eloScore: 1100);
        final mediumTask = Task(title: 'Medium', eloScore: 1300);
        final hardTask = Task(title: 'Hard', eloScore: 1500);

        final result = TaskCalculationService.calculateEloStatistics([easyTask, mediumTask, hardTask]);
        
        expect(result['distribution']['easy'], equals(1));
        expect(result['distribution']['medium'], equals(1));
        expect(result['distribution']['hard'], equals(1));
      });
    });

    group('calculateCompletionTimeStats', () {
      test('should return default values for empty tasks list', () {
        final result = TaskCalculationService.calculateCompletionTimeStats([]);
        
        expect(result['averageTime'], equals(0.0));
        expect(result['fastestCategory'], isNull);
        expect(result['slowestCategory'], isNull);
        expect(result['categoryTimes'], isEmpty);
      });

      test('should return default values for tasks without completion data', () {
        final task1 = Task(title: 'Task 1', isCompleted: false);
        final task2 = Task(title: 'Task 2', isCompleted: true); // No completedAt

        final result = TaskCalculationService.calculateCompletionTimeStats([task1, task2]);
        
        expect(result['averageTime'], equals(0.0));
        expect(result['fastestCategory'], isNull);
        expect(result['slowestCategory'], isNull);
        expect(result['categoryTimes'], isEmpty);
      });

      test('should calculate completion time stats correctly', () {
        final now = DateTime.now();
        final task1 = Task(
          title: 'Task 1',
          category: 'Work',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 5)),
          completedAt: now.subtract(const Duration(days: 2)),
        );
        final task2 = Task(
          title: 'Task 2',
          category: 'Personal',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 10)),
          completedAt: now.subtract(const Duration(days: 8)),
        );

        final result = TaskCalculationService.calculateCompletionTimeStats([task1, task2]);
        
        expect(result['averageTime'], equals(2.5)); // (3 + 2) / 2 = 2.5
        expect(result['fastestCategory'], equals('Personal')); // 2 jours
        expect(result['slowestCategory'], equals('Work')); // 3 jours
        expect(result['categoryTimes']['Work'], equals(3.0));
        expect(result['categoryTimes']['Personal'], equals(2.0));
      });
    });

    group('calculateAverageElo', () {
      test('should return 0.0 for empty tasks list', () {
        final result = TaskCalculationService.calculateAverageElo([]);
        expect(result, equals(0.0));
      });

      test('should calculate average ELO correctly', () {
        final task1 = Task(title: 'Task 1', eloScore: 1000);
        final task2 = Task(title: 'Task 2', eloScore: 1200);
        final task3 = Task(title: 'Task 3', eloScore: 1400);

        final result = TaskCalculationService.calculateAverageElo([task1, task2, task3]);
        expect(result, equals(1200.0)); // (1000 + 1200 + 1400) / 3 = 1200
      });
    });

    group('calculateAverageCompletionTime', () {
      test('should return 0.0 for empty tasks list', () {
        final result = TaskCalculationService.calculateAverageCompletionTime([]);
        expect(result, equals(0.0));
      });

      test('should return 0.0 for tasks without completion data', () {
        final task1 = Task(title: 'Task 1', isCompleted: false);
        final task2 = Task(title: 'Task 2', isCompleted: true); // No completedAt

        final result = TaskCalculationService.calculateAverageCompletionTime([task1, task2]);
        expect(result, equals(0.0));
      });

      test('should calculate average completion time correctly', () {
        final now = DateTime.now();
        final task1 = Task(
          title: 'Task 1',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 5)),
          completedAt: now.subtract(const Duration(days: 2)),
        );
        final task2 = Task(
          title: 'Task 2',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 10)),
          completedAt: now.subtract(const Duration(days: 8)),
        );

        final result = TaskCalculationService.calculateAverageCompletionTime([task1, task2]);
        expect(result, equals(2.5)); // (3 + 2) / 2 = 2.5
      });
    });

    group('calculateCompletedTasks', () {
      test('should return 0 for empty tasks list', () {
        final result = TaskCalculationService.calculateCompletedTasks([]);
        expect(result, equals(0));
      });

      test('should count completed tasks correctly', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);
        final task3 = Task(title: 'Task 3', isCompleted: true);

        final result = TaskCalculationService.calculateCompletedTasks([task1, task2, task3]);
        expect(result, equals(2));
      });
    });

    group('calculatePendingTasks', () {
      test('should return 0 for empty tasks list', () {
        final result = TaskCalculationService.calculatePendingTasks([]);
        expect(result, equals(0));
      });

      test('should count pending tasks correctly', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);
        final task3 = Task(title: 'Task 3', isCompleted: false);

        final result = TaskCalculationService.calculatePendingTasks([task1, task2, task3]);
        expect(result, equals(2));
      });
    });

    group('calculateCategoryPerformance', () {
      test('should return empty map for empty tasks list', () {
        final result = TaskCalculationService.calculateCategoryPerformance([]);
        expect(result, isEmpty);
      });

      test('should calculate performance by category', () {
        final task1 = Task(title: 'Task 1', category: 'Work', isCompleted: true);
        final task2 = Task(title: 'Task 2', category: 'Work', isCompleted: false);
        final task3 = Task(title: 'Task 3', category: 'Personal', isCompleted: true);

        final result = TaskCalculationService.calculateCategoryPerformance([task1, task2, task3]);
        
        expect(result['Work'], equals(50.0)); // 1/2 * 100 = 50%
        expect(result['Personal'], equals(100.0)); // 1/1 * 100 = 100%
      });
    });

    group('generateTaskInsights', () {
      test('should generate insights for empty tasks list', () {
        final insights = TaskCalculationService.generateTaskInsights([]);
        
        expect(insights, isNotEmpty);
        expect(insights.first['type'], equals('info'));
        expect(insights.first['message'], contains('premières tâches'));
      });

      test('should generate success insights for high completion rate', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: true);
        final task3 = Task(title: 'Task 3', isCompleted: false);

        final insights = TaskCalculationService.generateTaskInsights([task1, task2, task3]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('67%')), isTrue);
      });

      test('should generate warning insights for many pending tasks', () {
        final tasks = List.generate(15, (i) => Task(title: 'Task $i', isCompleted: false));
        
        final insights = TaskCalculationService.generateTaskInsights(tasks);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'error'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('15 tâches')), isTrue);
      });

      test('should generate insights for completion time', () {
        final now = DateTime.now();
        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 5)),
          completedAt: now.subtract(const Duration(days: 2)),
        );

        final insights = TaskCalculationService.generateTaskInsights([task]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['message'].contains('3.0 jours')), isTrue);
      });
    });
  });
} 

