import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/insights/insights_generation_service.dart';

void main() {
  group('InsightsGenerationService', () {
    group('generateSmartInsights', () {
      test('should generate insights for high productivity', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler une haute productivité (100% de réussite)
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateSmartInsights([habit], []);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('excellente')), isTrue);
      });

      test('should generate warning for many pending tasks', () {
        final tasks = List.generate(15, (i) => Task(title: 'Task $i', isCompleted: false));
        
        final insights = InsightsGenerationService.generateSmartInsights([], tasks);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'error'), isTrue);
        expect(
          insights.any(
            (insight) => insight['message'] == '15 t\u00E2ches en attente',
          ),
          isTrue,
        );
      });

      test('should generate insights for category performance', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Work Habit', type: HabitType.binary, category: 'Work');
        
        // Simuler une bonne performance
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateSmartInsights([habit], []);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['message'].contains('Work')), isTrue);
      });

      test('should generate streak insights for long streaks', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler une longue série (10 jours)
        for (int i = 0; i < 10; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateSmartInsights([habit], []);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['message'].contains('10 jours')), isTrue);
      });
    });

    group('generateProductivityInsights', () {
      test('should generate insights for empty habits list', () {
        final insights = InsightsGenerationService.generateProductivityInsights([]);
        
        expect(insights, isNotEmpty);
        expect(insights.first['type'], equals('info'));
        expect(
          insights.first['message'],
          contains('Aucune liste \u00E0 analyser'),
        );
      });

      test('should generate success insights for high productivity', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler une haute productivité (100% de réussite)
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateProductivityInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
        expect(
          insights.any(
            (insight) => insight['message'].contains('Bon rythme de livraison'),
          ),
          isTrue,
        );
      });

      test('should generate warning insights for low productivity', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler une faible productivité (0% de réussite)
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = false;
        }

        final insights = InsightsGenerationService.generateProductivityInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'warning'), isTrue);
        expect(
          insights.any(
            (insight) => insight['message'].contains('Productivit\u00E9 basse'),
          ),
          isTrue,
        );
      });

      test('should generate insights for habit count', () {
        final habits = List.generate(2, (i) => Habit(name: 'Habit $i', type: HabitType.binary));
        
        final insights = InsightsGenerationService.generateProductivityInsights(habits);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['message'].contains('2 habitudes')), isTrue);
      });

      test('should generate warning for too many habits', () {
        final habits = List.generate(12, (i) => Habit(name: 'Habit $i', type: HabitType.binary));
        
        final insights = InsightsGenerationService.generateProductivityInsights(habits);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'warning'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('12 habitudes')), isTrue);
      });
    });

    group('generateTaskInsights', () {
      test('should generate insights for empty tasks list', () {
        final insights = InsightsGenerationService.generateTaskInsights([]);
        
        expect(insights, isNotEmpty);
        expect(insights.first['type'], equals('info'));
        expect(
          insights.first['message'],
          contains('Commencez par cr\u00E9er des t\u00E2ches'),
        );
      });

      test('should generate success insights for high completion rate', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: true);
        final task3 = Task(title: 'Task 3', isCompleted: false);

        final insights = InsightsGenerationService.generateTaskInsights([task1, task2, task3]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('67%')), isTrue);
      });

      test('should generate warning insights for many pending tasks', () {
        final tasks = List.generate(15, (i) => Task(title: 'Task $i', isCompleted: false));
        
        final insights = InsightsGenerationService.generateTaskInsights(tasks);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'warning'), isTrue);
        expect(
          insights.any(
            (insight) => insight['message'].contains('R\u00E9duisez le backlog'),
          ),
          isTrue,
        );
      });

      test('should generate insights for completion time', () {
        final now = DateTime.now();
        final task = Task(
          title: 'Task 1',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 5)),
          completedAt: now.subtract(const Duration(days: 2)),
        );

        final insights = InsightsGenerationService.generateTaskInsights([task]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['message'].contains('3.0 jours')), isTrue);
      });

      test('should generate insights for category performance', () {
        final task1 = Task(title: 'Work Task', category: 'Work', isCompleted: true);
        final task2 = Task(title: 'Personal Task', category: 'Personal', isCompleted: true);

        final insights = InsightsGenerationService.generateTaskInsights([task1, task2]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
      });
    });

    group('generateStreakInsights', () {
      test('should generate insights for empty habits list', () {
        final insights = InsightsGenerationService.generateStreakInsights([]);
        
        expect(insights, isNotEmpty);
        expect(insights.first['type'], equals('info'));
        expect(insights.first['message'], contains('Aucune liste'));
      });

      test('should generate success insights for long streaks', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler une longue série (15 jours)
        for (int i = 0; i < 15; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateStreakInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('15 jours')), isTrue);
      });

      test('should generate warning insights for medium streaks', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler une série moyenne (5 jours)
        for (int i = 0; i < 5; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateStreakInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'warning'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('5 jours')), isTrue);
      });

      test('should generate info insights for short streaks', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler une courte série (2 jours)
        for (int i = 0; i < 2; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateStreakInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'info'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('2 jours')), isTrue);
      });

      test('should generate insights for no streak', () {
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        // Pas de complétions = pas de série

        final insights = InsightsGenerationService.generateStreakInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'info'), isTrue);
        expect(
          insights.any(
            (insight) =>
                insight['message'].contains('Premi\u00E8res habitudes en cours'),
          ),
          isTrue,
        );
      });

      test('should generate insights for multiple habits with different streaks', () {
        final now = DateTime.now();
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        
        // Habit 1: série de 10 jours
        for (int i = 0; i < 10; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit1.completions[dateKey] = true;
        }
        
        // Habit 2: série de 5 jours
        for (int i = 0; i < 5; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit2.completions[dateKey] = true;
        }

        final insights = InsightsGenerationService.generateStreakInsights([habit1, habit2]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['message'].contains('Habit 1')), isTrue);
        expect(insights.any((insight) => insight['message'].contains('10 jours')), isTrue);
      });
    });
  });
} 
