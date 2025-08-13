import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/services/calculation/habit_calculation_service.dart';

void main() {
  group('HabitCalculationService', () {
    group('calculateSuccessRate', () {
      test('should return 0 for empty habits list', () {
        final result = HabitCalculationService.calculateSuccessRate([]);
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

        final result = HabitCalculationService.calculateSuccessRate([habit1, habit2]);
        expect(result, equals(50)); // (100 + 0) / 2 = 50
      });
    });

    group('calculateCurrentStreak', () {
      test('should return 0 for empty habits list', () {
        final result = HabitCalculationService.calculateCurrentStreak([]);
        expect(result, equals(0));
      });

      test('should return the highest streak among habits', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);

        // Simuler des streaks différents
        for (int i = 0; i < 3; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit1.completions[dateKey] = true;
        }

        for (int i = 0; i < 5; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit2.completions[dateKey] = true;
        }

        final result = HabitCalculationService.calculateCurrentStreak([habit1, habit2]);
        expect(result, equals(5)); // Le plus haut streak
      });
    });

    group('calculateAveragePerDay', () {
      test('should return 0.0 for empty habits list', () {
        final result = HabitCalculationService.calculateAveragePerDay([]);
        expect(result, equals(0.0));
      });

      test('should calculate average per day correctly', () {
        final now = DateTime.now();
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);

        // Simuler des données de complétion
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit1.completions[dateKey] = true; // 100%
          habit2.completions[dateKey] = false; // 0%
        }

        final result = HabitCalculationService.calculateAveragePerDay([habit1, habit2]);
        expect(result, equals(1.0)); // (1.0 + 0.0) / 2 * 2 = 1.0
      });
    });

    group('calculateCategoryPerformance', () {
      test('should return empty map for empty habits list', () {
        final result = HabitCalculationService.calculateCategoryPerformance([]);
        expect(result, isEmpty);
      });

      test('should calculate performance by category', () {
        final now = DateTime.now();
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary, category: 'Work');
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary, category: 'Work');
        final habit3 = Habit(name: 'Habit 3', type: HabitType.binary, category: 'Personal');

        // Simuler des données de réussite pour les 7 derniers jours
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit1.completions[dateKey] = true; // 100%
          habit2.completions[dateKey] = false; // 0%
          habit3.completions[dateKey] = true; // 100%
        }

        final result = HabitCalculationService.calculateCategoryPerformance([habit1, habit2, habit3]);
        
        expect(result['Work'], isNotNull);
        expect(result['Personal'], isNotNull);
        expect(result['Work'], equals(50.0)); // (100 + 0) / 2 = 50%
        expect(result['Personal'], equals(100.0)); // 100%
      });
    });

    group('generateHabitInsights', () {
      test('should generate insights for empty habits list', () {
        final insights = HabitCalculationService.generateHabitInsights([]);
        
        expect(insights, isNotEmpty);
        expect(insights.first['type'], equals('info'));
        expect(insights.first['message'], contains('premières habitudes'));
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

        final insights = HabitCalculationService.generateHabitInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'success'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('excellentes')), isTrue);
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

        final insights = HabitCalculationService.generateHabitInsights([habit]);
        
        expect(insights, isNotEmpty);
        expect(insights.any((insight) => insight['type'] == 'info'), isTrue);
        expect(insights.any((insight) => insight['message'].contains('régularité')), isTrue);
      });
    });

    group('calculateActiveHabits', () {
      test('should return 0 for empty list', () {
        final result = HabitCalculationService.calculateActiveHabits([]);
        expect(result, equals(0));
      });

      test('should return correct count for habits list', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        final habit3 = Habit(name: 'Habit 3', type: HabitType.binary);

        final result = HabitCalculationService.calculateActiveHabits([habit1, habit2, habit3]);
        expect(result, equals(3));
      });
    });

    group('calculateCompletedToday', () {
      test('should return 0 for empty list', () {
        final result = HabitCalculationService.calculateCompletedToday([]);
        expect(result, equals(0));
      });

      test('should return correct count for completed habits today', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        final habit3 = Habit(name: 'Habit 3', type: HabitType.binary);

        // Marquer seulement 2 habitudes comme complétées aujourd'hui
        habit1.markCompleted(true);
        habit2.markCompleted(true);
        habit3.markCompleted(false);

        final result = HabitCalculationService.calculateCompletedToday([habit1, habit2, habit3]);
        expect(result, equals(2));
      });
    });

    group('calculateTodayCompletionRate', () {
      test('should return 0 for empty list', () {
        final result = HabitCalculationService.calculateTodayCompletionRate([]);
        expect(result, equals(0));
      });

      test('should calculate completion rate correctly', () {
        final habit1 = Habit(name: 'Habit 1', type: HabitType.binary);
        final habit2 = Habit(name: 'Habit 2', type: HabitType.binary);
        final habit3 = Habit(name: 'Habit 3', type: HabitType.binary);
        final habit4 = Habit(name: 'Habit 4', type: HabitType.binary);

        // Marquer 2 habitudes sur 4 comme complétées
        habit1.markCompleted(true);
        habit2.markCompleted(true);
        habit3.markCompleted(false);
        habit4.markCompleted(false);

        final result = HabitCalculationService.calculateTodayCompletionRate([habit1, habit2, habit3, habit4]);
        expect(result, equals(50)); // 2/4 * 100 = 50%
      });
    });
  });
} 

