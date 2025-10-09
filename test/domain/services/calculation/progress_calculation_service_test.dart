import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/progress_calculation_service.dart';

void main() {
  group('ProgressCalculationService', () {
    group('getProgressColor', () {
      test('should return success color for high values', () {
        final color = ProgressCalculationService.getProgressColor(85.0);
        expect(color, isNotNull);
        expect(color, isA<Color>());
      });

      test('should return primary color for medium-high values', () {
        final color = ProgressCalculationService.getProgressColor(70.0);
        expect(color, isNotNull);
        expect(color, isA<Color>());
      });

      test('should return accent color for medium values', () {
        final color = ProgressCalculationService.getProgressColor(50.0);
        expect(color, isNotNull);
        expect(color, isA<Color>());
      });

      test('should return error color for low values', () {
        final color = ProgressCalculationService.getProgressColor(30.0);
        expect(color, isNotNull);
        expect(color, isA<Color>());
      });
    });

    group('generatePeriodLabels', () {
      test('should generate weekly labels', () {
        final labels = ProgressCalculationService.generatePeriodLabels('7_days');
        expect(labels, equals(['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']));
      });

      test('should generate monthly labels', () {
        final labels = ProgressCalculationService.generatePeriodLabels('30_days');
        expect(labels.length, equals(30));
        expect(labels.first, equals('1'));
        expect(labels.last, equals('30'));
      });

      test('should generate quarterly labels', () {
        final labels = ProgressCalculationService.generatePeriodLabels('90_days');
        expect(labels.length, equals(90));
        expect(labels.first, equals('1'));
        expect(labels.last, equals('90'));
      });

      test('should generate yearly labels', () {
        final labels = ProgressCalculationService.generatePeriodLabels('365_days');
        expect(labels.length, equals(365));
        expect(labels.first, equals('1'));
        expect(labels.last, equals('365'));
      });

      test('should default to weekly labels for unknown period', () {
        final labels = ProgressCalculationService.generatePeriodLabels('unknown');
        expect(labels, equals(['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']));
      });
    });

    group('calculateOverallProgress', () {
      test('should return 0 for empty lists', () {
        final progress = ProgressCalculationService.calculateOverallProgress([], []);
        expect(progress, equals(0.0));
      });

      test('should calculate progress for habits only', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler 100% de réussite
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final progress = ProgressCalculationService.calculateOverallProgress([habit], []);
        expect(progress, equals(100.0));
      });

      test('should calculate progress for tasks only', () {
        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: true);
        final task3 = Task(title: 'Task 3', isCompleted: false);

        final progress = ProgressCalculationService.calculateOverallProgress([], [task1, task2, task3]);
        expect(progress, equals(67.0)); // 2/3 * 100 = 66.67 arrondi à 67
      });

      test('should calculate weighted progress for both habits and tasks', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Habitude avec 100% de réussite
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final task1 = Task(title: 'Task 1', isCompleted: true);
        final task2 = Task(title: 'Task 2', isCompleted: false);

        final progress = ProgressCalculationService.calculateOverallProgress([habit], [task1, task2]);
        // 100 * 0.7 + 50 * 0.3 = 70 + 15 = 85
        expect(progress, equals(85.0));
      });
    });

    group('generateProgressData', () {
      test('should generate weekly data', () {
        final data = ProgressCalculationService.generateProgressData('7_days', [], []);
        expect(data.length, equals(7));
        expect(data.first.index, equals(0));
        expect(data.last.index, equals(6));
      });

      test('should generate monthly data', () {
        final data = ProgressCalculationService.generateProgressData('30_days', [], []);
        expect(data.length, equals(30));
        expect(data.first.index, equals(0));
        expect(data.last.index, equals(29));
      });

      test('should generate quarterly data', () {
        final data = ProgressCalculationService.generateProgressData('90_days', [], []);
        expect(data.length, equals(90));
        expect(data.first.index, equals(0));
        expect(data.last.index, equals(89));
      });

      test('should generate yearly data', () {
        final data = ProgressCalculationService.generateProgressData('365_days', [], []);
        expect(data.length, equals(365));
        expect(data.first.index, equals(0));
        expect(data.last.index, equals(364));
      });

      test('should default to weekly data for unknown period', () {
        final data = ProgressCalculationService.generateProgressData('unknown', [], []);
        expect(data.length, equals(7));
      });

      test('should generate data with actual progress values', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler des données de progression
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final data = ProgressCalculationService.generateProgressData('7_days', [habit], []);
        expect(data.length, equals(7));
        expect(data.every((point) => point.value >= 0 && point.value <= 100), isTrue);
      });
    });

    group('calculateAverageProgress', () {
      test('should return 0 for empty data', () {
        final progress = ProgressCalculationService.calculateAverageProgress('7_days', [], []);
        expect(progress, equals(0.0));
      });

      test('should calculate average progress correctly', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler des données de progression variées
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = i % 2 == 0; // Alterner true/false
        }

        final progress = ProgressCalculationService.calculateAverageProgress('7_days', [habit], []);
        expect(progress, greaterThan(0.0));
        expect(progress, lessThanOrEqualTo(100.0));
      });
    });

    group('calculateProgressTrend', () {
      test('should return stable for insufficient data', () {
        final trend = ProgressCalculationService.calculateProgressTrend('7_days', [], []);
        expect(trend, equals('stable'));
      });

      test('should return stable for consistent data', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler des données constantes
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = true;
        }

        final trend = ProgressCalculationService.calculateProgressTrend('7_days', [habit], []);
        expect(trend, equals('stable'));
      });
    });

    group('calculateBestDay', () {
      test('should return default values for empty data', () {
        final result = ProgressCalculationService.calculateBestDay('7_days', [], []);
        expect(result['index'], equals(0));
        expect(result['value'], equals(0.0));
      });

      test('should find the best day correctly', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler des données avec un pic
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = i == 3; // Seulement le jour 3
        }

        final result = ProgressCalculationService.calculateBestDay('7_days', [habit], []);
        expect(result['index'], isA<int>());
        expect(result['value'], isA<double>());
        expect(result['value'], greaterThan(0.0));
      });
    });

    group('calculateWorstDay', () {
      test('should return default values for empty data', () {
        final result = ProgressCalculationService.calculateWorstDay('7_days', [], []);
        expect(result['index'], equals(0));
        expect(result['value'], equals(0.0));
      });

      test('should find the worst day correctly', () {
        final now = DateTime.now();
        final habit = Habit(name: 'Test Habit', type: HabitType.binary);
        
        // Simuler des données avec un creux
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          habit.completions[dateKey] = i != 2; // Tous sauf le jour 2
        }

        final result = ProgressCalculationService.calculateWorstDay('7_days', [habit], []);
        expect(result['index'], isA<int>());
        expect(result['value'], isA<double>());
      });
    });
  });
} 
