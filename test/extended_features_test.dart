import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

void main() {
  group('Extended Features Tests', () {
    
    group('Extended Habit Frequencies', () {
      test('should support all extended recurrence types', () {
        // Vérifier que tous les nouveaux types existent
        expect(RecurrenceType.values, contains(RecurrenceType.weekends));
        expect(RecurrenceType.values, contains(RecurrenceType.weekdays));
        expect(RecurrenceType.values, contains(RecurrenceType.monthly));
        expect(RecurrenceType.values, contains(RecurrenceType.monthlyDay));
        expect(RecurrenceType.values, contains(RecurrenceType.quarterly));
        expect(RecurrenceType.values, contains(RecurrenceType.yearly));
        expect(RecurrenceType.values, contains(RecurrenceType.hourlyInterval));
        expect(RecurrenceType.values, contains(RecurrenceType.timesPerHour));
        
        // Vérifier qu'on a au moins 12 types de récurrence
        expect(RecurrenceType.values.length, greaterThanOrEqualTo(12));
      });

      test('should create habit with weekend recurrence', () {
        final habit = Habit(
          name: 'Weekend Exercise',
          type: HabitType.binary,
          category: 'Health',
          recurrenceType: RecurrenceType.weekends,
        );

        expect(habit.name, equals('Weekend Exercise'));
        expect(habit.type, equals(HabitType.binary));
        expect(habit.recurrenceType, equals(RecurrenceType.weekends));
        expect(habit.category, equals('Health'));
      });

      test('should create habit with monthly day configuration', () {
        final habit = Habit(
          name: 'Monthly Budget Review',
          type: HabitType.binary,
          category: 'Finance',
          recurrenceType: RecurrenceType.monthlyDay,
          monthlyDay: 15, // 15th of each month
        );

        expect(habit.recurrenceType, equals(RecurrenceType.monthlyDay));
        expect(habit.monthlyDay, equals(15));
        expect(habit.name, equals('Monthly Budget Review'));
      });

      test('should create habit with quarterly configuration', () {
        final habit = Habit(
          name: 'Quarterly Review',
          type: HabitType.binary,
          category: 'Work',
          recurrenceType: RecurrenceType.quarterly,
          quarterMonth: 2, // Second month of quarter
        );

        expect(habit.recurrenceType, equals(RecurrenceType.quarterly));
        expect(habit.quarterMonth, equals(2));
      });

      test('should create habit with yearly configuration', () {
        final habit = Habit(
          name: 'Annual Checkup',
          type: HabitType.binary,
          category: 'Health',
          recurrenceType: RecurrenceType.yearly,
          yearlyMonth: 12,
          yearlyDay: 31,
        );

        expect(habit.recurrenceType, equals(RecurrenceType.yearly));
        expect(habit.yearlyMonth, equals(12));
        expect(habit.yearlyDay, equals(31));
      });

      test('should create habit with hourly interval', () {
        final habit = Habit(
          name: 'Drink Water',
          type: HabitType.quantitative,
          category: 'Health',
          recurrenceType: RecurrenceType.hourlyInterval,
          hourlyInterval: 2, // Every 2 hours
          targetValue: 8.0,
          unit: 'glasses',
        );

        expect(habit.recurrenceType, equals(RecurrenceType.hourlyInterval));
        expect(habit.hourlyInterval, equals(2));
        expect(habit.type, equals(HabitType.quantitative));
        expect(habit.targetValue, equals(8.0));
      });

      test('should create weekdays only habit', () {
        final habit = Habit(
          name: 'Work Meditation',
          type: HabitType.binary,
          category: 'Mindfulness',
          recurrenceType: RecurrenceType.weekdays,
        );

        expect(habit.recurrenceType, equals(RecurrenceType.weekdays));
        expect(habit.name, equals('Work Meditation'));
      });
    });

    group('Habit Functionality', () {
      test('should mark binary habit as completed', () {
        final habit = Habit(
          name: 'Daily Exercise',
          type: HabitType.binary,
          category: 'Health',
          recurrenceType: RecurrenceType.dailyInterval,
        );

        expect(habit.isCompletedToday(), isFalse);
        
        habit.markCompleted(true);
        expect(habit.isCompletedToday(), isTrue);
        
        habit.markCompleted(false);
        expect(habit.isCompletedToday(), isFalse);
      });

      test('should record quantitative values', () {
        final habit = Habit(
          name: 'Read Pages',
          type: HabitType.quantitative,
          category: 'Education',
          targetValue: 20.0,
          unit: 'pages',
        );

        expect(habit.isCompletedToday(), isFalse);
        
        habit.recordValue(15.0);
        expect(habit.isCompletedToday(), isFalse); // Below target
        
        habit.recordValue(25.0);
        expect(habit.isCompletedToday(), isTrue); // Above target
        
        expect(habit.getTodayValue(), equals(25.0));
      });

      test('should calculate success rate', () {
        final habit = Habit(
          name: 'Test Habit',
          type: HabitType.binary,
        );

        // Mark as completed for 3 out of 7 days
        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = i < 3; // First 3 days completed
        }

        final successRate = habit.getSuccessRate(days: 7);
        expect(successRate, equals(3/7)); // 3 out of 7 days
      });

      test('should calculate current streak', () {
        final habit = Habit(
          name: 'Streak Test',
          type: HabitType.binary,
        );

        // Mark as completed for last 5 days
        final now = DateTime.now();
        for (int i = 0; i < 5; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final streak = habit.getCurrentStreak();
        expect(streak, equals(5));
      });
    });

    group('Task ELO System', () {
      test('should create task with default ELO', () {
        final task = Task(
          title: 'Test Task',
          category: 'Work',
        );

        expect(task.title, equals('Test Task'));
        expect(task.eloScore, equals(1200.0));
        expect(task.isCompleted, isFalse);
        expect(task.category, equals('Work'));
      });

      test('should calculate win probability correctly', () {
        final task1 = Task(title: 'Task 1', eloScore: 1400.0);
        final task2 = Task(title: 'Task 2', eloScore: 1600.0);

        final task1WinProb = task1.calculateWinProbability(task2);
        final task2WinProb = task2.calculateWinProbability(task1);

        expect(task1WinProb, lessThan(0.5)); // Lower ELO has lower win prob
        expect(task2WinProb, greaterThan(0.5)); // Higher ELO has higher win prob
        expect(task1WinProb + task2WinProb, closeTo(1.0, 0.001)); // Should sum to ~1
      });

      test('should update ELO scores after duel', () {
        final task1 = Task(title: 'Task 1', eloScore: 1400.0);
        final task2 = Task(title: 'Task 2', eloScore: 1600.0);

        final initialElo1 = task1.eloScore;
        final initialElo2 = task2.eloScore;

        // Task 1 (lower ELO) wins against Task 2 (higher ELO)
        task1.updateEloScore(task2, true);
        task2.updateEloScore(task1, false);

        expect(task1.eloScore, greaterThan(initialElo1)); // Winner gains points
        expect(task2.eloScore, lessThan(initialElo2)); // Loser loses points
      });

      test('should complete task with timestamp', () {
        final task = Task(
          title: 'Complete Me',
          category: 'Work',
        );

        expect(task.isCompleted, isFalse);
        expect(task.completedAt, isNull);

        final completionTime = DateTime.now();
        final completedTask = task.copyWith(
          isCompleted: true,
          completedAt: completionTime,
        );

        expect(completedTask.isCompleted, isTrue);
        expect(completedTask.completedAt, equals(completionTime));
      });
    });

    group('Statistics & Analytics', () {
      test('should calculate basic statistics for habits list', () {
        final habits = [
          Habit(name: 'Exercise', type: HabitType.binary, category: 'Health'),
          Habit(name: 'Reading', type: HabitType.quantitative, category: 'Education', targetValue: 30.0),
          Habit(name: 'Meditation', type: HabitType.binary, category: 'Health'),
        ];

        // Count by type
        final binaryHabits = habits.where((h) => h.type == HabitType.binary).length;
        final quantitativeHabits = habits.where((h) => h.type == HabitType.quantitative).length;

        expect(binaryHabits, equals(2));
        expect(quantitativeHabits, equals(1));

        // Count by category
        final healthHabits = habits.where((h) => h.category == 'Health').length;
        final educationHabits = habits.where((h) => h.category == 'Education').length;

        expect(healthHabits, equals(2));
        expect(educationHabits, equals(1));
      });

      test('should calculate task completion statistics', () {
        final tasks = [
          Task(title: 'Task 1', isCompleted: true, eloScore: 1500.0, category: 'Work'),
          Task(title: 'Task 2', isCompleted: false, eloScore: 1400.0, category: 'Work'),
          Task(title: 'Task 3', isCompleted: true, eloScore: 1600.0, category: 'Personal'),
          Task(title: 'Task 4', isCompleted: true, eloScore: 1300.0, category: 'Work'),
        ];

        final completedTasks = tasks.where((t) => t.isCompleted).length;
        final totalTasks = tasks.length;
        final completionRate = (completedTasks / totalTasks) * 100;

        expect(completionRate, equals(75.0)); // 3/4 = 75%

        // Calculate average ELO of completed tasks
        final completedTasksElo = tasks
            .where((t) => t.isCompleted)
            .map((t) => t.eloScore)
            .toList();
        final avgCompletedElo = completedTasksElo.reduce((a, b) => a + b) / completedTasksElo.length;

        expect(avgCompletedElo, equals((1500 + 1600 + 1300) / 3)); // Average of completed tasks

        // Group by category
        final workTasks = tasks.where((t) => t.category == 'Work').length;
        final personalTasks = tasks.where((t) => t.category == 'Personal').length;

        expect(workTasks, equals(3));
        expect(personalTasks, equals(1));
      });

      test('should categorize tasks by difficulty based on ELO', () {
        final tasks = [
          Task(title: 'Easy', eloScore: 1200.0),
          Task(title: 'Medium 1', eloScore: 1450.0),
          Task(title: 'Medium 2', eloScore: 1550.0),
          Task(title: 'Hard', eloScore: 1800.0),
        ];

        final easyTasks = tasks.where((t) => t.eloScore < 1400).length;
        final mediumTasks = tasks.where((t) => t.eloScore >= 1400 && t.eloScore < 1700).length;
        final hardTasks = tasks.where((t) => t.eloScore >= 1700).length;

        expect(easyTasks, equals(1));
        expect(mediumTasks, equals(2));
        expect(hardTasks, equals(1));
      });

      test('should generate insights based on performance', () {
        final habits = [
          Habit(name: 'Consistent Habit', type: HabitType.binary),
        ];

        final tasks = [
          Task(title: 'High ELO Task', eloScore: 1800.0, isCompleted: true),
          Task(title: 'Another High Task', eloScore: 1750.0, isCompleted: true),
        ];

        // Simulate insight generation
        final insights = <String>[];

        // High task completion rate
        final completionRate = tasks.where((t) => t.isCompleted).length / tasks.length;
        if (completionRate >= 0.8) {
          insights.add('Excellent taux de complétion des tâches!');
        }

        // High ELO performance
        final avgTaskElo = tasks.map((t) => t.eloScore).reduce((a, b) => a + b) / tasks.length;
        if (avgTaskElo > 1700) {
          insights.add('Vous excellez dans les tâches difficiles!');
        }

        // Habit consistency (simplified)
        if (habits.isNotEmpty) {
          insights.add('Continuez vos bonnes habitudes!');
        }

        expect(insights.length, greaterThanOrEqualTo(2));
        expect(insights, contains('Excellent taux de complétion des tâches!'));
        expect(insights, contains('Vous excellez dans les tâches difficiles!'));
      });
    });

    group('Data Filtering & Time Periods', () {
      test('should filter tasks by completion date', () {
        final now = DateTime.now();
        final tasks = [
          Task(
            title: 'Recent Task',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 3)),
          ),
          Task(
            title: 'Old Task',
            isCompleted: true,
            completedAt: now.subtract(const Duration(days: 35)),
          ),
          Task(
            title: 'Uncompleted',
            isCompleted: false,
          ),
        ];

        // Filter last 7 days
        final recentTasks = tasks.where((task) {
          if (!task.isCompleted || task.completedAt == null) return false;
          return task.completedAt!.isAfter(now.subtract(const Duration(days: 7)));
        }).toList();

        // Filter last 30 days
        final monthlyTasks = tasks.where((task) {
          if (!task.isCompleted || task.completedAt == null) return false;
          return task.completedAt!.isAfter(now.subtract(const Duration(days: 30)));
        }).toList();

        expect(recentTasks.length, equals(1)); // Only recent task
        expect(monthlyTasks.length, equals(1)); // Only recent task (old one is beyond 30 days)
        expect(recentTasks.first.title, equals('Recent Task'));
      });

      test('should support different period configurations', () {
        final periodConfigs = {
          '7 jours': Duration(days: 7),
          '30 jours': Duration(days: 30),
          '3 mois': Duration(days: 90),
          '1 an': Duration(days: 365),
        };

        for (final config in periodConfigs.entries) {
          expect(config.value.inDays, greaterThan(0));
          expect(config.key, isNotEmpty);
        }

        expect(periodConfigs['7 jours']?.inDays, equals(7));
        expect(periodConfigs['1 an']?.inDays, equals(365));
      });
    });

    group('Copy and Modification', () {
      test('should copy habit with modifications', () {
        final originalHabit = Habit(
          name: 'Original',
          type: HabitType.binary,
          category: 'Health',
          recurrenceType: RecurrenceType.dailyInterval,
        );

        final modifiedHabit = originalHabit.copyWith(
          name: 'Modified',
          category: 'Fitness',
          recurrenceType: RecurrenceType.weekends,
        );

        expect(modifiedHabit.name, equals('Modified'));
        expect(modifiedHabit.category, equals('Fitness'));
        expect(modifiedHabit.recurrenceType, equals(RecurrenceType.weekends));
        expect(modifiedHabit.type, equals(HabitType.binary)); // Unchanged
        expect(modifiedHabit.id, equals(originalHabit.id)); // Unchanged
      });

      test('should copy task with modifications', () {
        final originalTask = Task(
          title: 'Original Task',
          eloScore: 1400.0,
          category: 'Work',
        );

        final modifiedTask = originalTask.copyWith(
          title: 'Modified Task',
          eloScore: 1500.0,
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        expect(modifiedTask.title, equals('Modified Task'));
        expect(modifiedTask.eloScore, equals(1500.0));
        expect(modifiedTask.isCompleted, isTrue);
        expect(modifiedTask.completedAt, isNotNull);
        expect(modifiedTask.category, equals('Work')); // Unchanged
        expect(modifiedTask.id, equals(originalTask.id)); // Unchanged
      });
    });
  });
} 
