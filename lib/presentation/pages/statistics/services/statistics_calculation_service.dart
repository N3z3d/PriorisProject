import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/habit_calculation_service.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';
import 'package:prioris/domain/services/calculation/points_calculation_service.dart';
import 'package:prioris/domain/services/insights/insights_generation_service.dart';
import 'package:prioris/domain/services/calculation/progress_calculation_service.dart';

/// Service orchestrateur des statistiques pour l'application Prioris
/// 
/// Ce service utilise les services spécialisés pour calculer les statistiques
/// tout en maintenant une interface compatible avec le code existant.
/// Il respecte le principe de responsabilité unique en déléguant les calculs
/// aux services appropriés.
class StatisticsCalculationService {
  /// Calcule le taux de réussite moyen des habitudes
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Pourcentage de réussite moyen (0-100)
  static int calculateHabitSuccessRate(List<Habit> habits) {
    return HabitCalculationService.calculateSuccessRate(habits);
  }

  /// Calcule le taux de complétion des tâches
  /// 
  /// [tasks] : Liste des tâches à analyser
  /// Retourne : Pourcentage de tâches complétées (0-100)
  static int calculateTaskCompletionRate(List<Task> tasks) {
    return TaskCalculationService.calculateCompletionRate(tasks);
  }

  /// Calcule la série de réussite la plus longue parmi toutes les habitudes
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Nombre de jours de la série la plus longue
  static int calculateCurrentStreak(List<Habit> habits) {
    return HabitCalculationService.calculateCurrentStreak(habits);
  }

  /// Calcule le total des points basé sur les habitudes et tâches
  /// 
  /// [habits] : Liste des habitudes (50 points chacune)
  /// [tasks] : Liste des tâches (25 points chacune si complétée)
  /// Retourne : Total des points
  static int calculateTotalPoints(List<Habit> habits, List<Task> tasks) {
    return PointsCalculationService.calculateTotalPoints(habits, tasks);
  }

  /// Calcule la performance par catégorie
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec catégorie -> pourcentage de réussite
  static Map<String, double> calculateCategoryPerformance(
    List<Habit> habits, 
    List<Task> tasks
  ) {
    // Combiner les performances des habitudes et des tâches
    final habitPerformance = HabitCalculationService.calculateCategoryPerformance(habits);
    final taskPerformance = TaskCalculationService.calculateCategoryPerformance(tasks);
    
    final Map<String, List<double>> combinedScores = {};
    
    // Ajouter les scores des habitudes
    habitPerformance.forEach((category, score) {
      combinedScores.putIfAbsent(category, () => []);
      combinedScores[category]!.add(score);
    });
    
    // Ajouter les scores des tâches
    taskPerformance.forEach((category, score) {
      combinedScores.putIfAbsent(category, () => []);
      combinedScores[category]!.add(score);
    });
    
    // Calculer la moyenne par catégorie
    final Map<String, double> result = {};
    combinedScores.forEach((category, scores) {
      if (scores.isNotEmpty) {
        final average = scores.reduce((a, b) => a + b) / scores.length;
        result[category] = average;
      }
    });
    
    return result;
  }

  /// Génère des insights intelligents basés sur les données
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateSmartInsights(
    List<Habit> habits, 
    List<Task> tasks
  ) {
    return InsightsGenerationService.generateSmartInsights(habits, tasks);
  }

  /// Calcule les statistiques ELO des tâches
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec les statistiques ELO
  static Map<String, dynamic> calculateEloStatistics(List<Task> tasks) {
    return TaskCalculationService.calculateEloStatistics(tasks);
  }

  /// Calcule les statistiques de temps de complétion
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec les statistiques de temps
  static Map<String, dynamic> calculateCompletionTimeStats(List<Task> tasks) {
    return TaskCalculationService.calculateCompletionTimeStats(tasks);
  }

  /// Détermine la couleur de progression basée sur une valeur
  /// 
  /// [value] : Valeur entre 0 et 100
  /// Retourne : Couleur appropriée
  static Color getProgressColor(double value) {
    return ProgressCalculationService.getProgressColor(value);
  }

  /// Calcule les métriques principales pour l'interface
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec toutes les métriques principales
  static Map<String, dynamic> calculateMainMetrics(List<Habit> habits, List<Task> tasks) {
    return {
      'habitSuccessRate': calculateHabitSuccessRate(habits),
      'taskCompletionRate': calculateTaskCompletionRate(tasks),
      'currentStreak': calculateCurrentStreak(habits),
      'totalPoints': calculateTotalPoints(habits, tasks),
      'categoryPerformance': calculateCategoryPerformance(habits, tasks),
      'smartInsights': generateSmartInsights(habits, tasks),
    };
  }

  /// Calcule les métriques pour l'onglet Vue d'ensemble
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec les métriques de l'overview
  static Map<String, dynamic> calculateOverviewMetrics(List<Habit> habits, List<Task> tasks) {
    return {
      'mainMetrics': calculateMainMetrics(habits, tasks),
      'eloStatistics': calculateEloStatistics(tasks),
      'completionTimeStats': calculateCompletionTimeStats(tasks),
    };
  }
} 
