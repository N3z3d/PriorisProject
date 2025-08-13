import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/habit_calculation_service.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';

/// Service spécialisé dans la génération d'insights intelligents
/// 
/// Ce service extrait toute la logique de génération d'insights
/// des autres services pour respecter le principe de
/// responsabilité unique et faciliter les tests.
class InsightsGenerationService {
  /// Génère des insights intelligents basés sur les données globales
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateSmartInsights(
    List<Habit> habits, 
    List<Task> tasks
  ) {
    final insights = <Map<String, dynamic>>[];
    
    // Insight 1 : Productivité par période
    final habitSuccessRate = HabitCalculationService.calculateSuccessRate(habits);
    if (habitSuccessRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Votre productivité est excellente ! Continuez comme ça.',
        'icon': '🎯',
      });
    } else if (habitSuccessRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Votre productivité est bonne, mais peut encore s\'améliorer.',
        'icon': '📈',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la régularité pour améliorer votre productivité.',
        'icon': '💡',
      });
    }
    
    // Insight 2 : Performance par catégorie
    final categoryPerformance = HabitCalculationService.calculateCategoryPerformance(habits);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'type': 'success',
        'message': 'Votre meilleure catégorie est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '🏆',
      });
    }
    
    // Insight 3 : Série de réussite
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Impressionnant ! Vous avez une série de $currentStreak jours.',
        'icon': '🔥',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne série de $currentStreak jours, continuez !',
        'icon': '📊',
      });
    }
    
    // Insight 4 : Tâches en retard
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    if (pendingTasks > 10) {
      insights.add({
        'type': 'error',
        'message': 'Vous avez $pendingTasks tâches en attente. Priorisez !',
        'icon': '⚠️',
      });
    }
    
    return insights;
  }

  /// Génère des insights spécifiques à la productivité des habitudes
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateProductivityInsights(List<Habit> habits) {
    final insights = <Map<String, dynamic>>[];
    
    if (habits.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Commencez par créer vos premières habitudes pour générer des insights.',
        'icon': '🎯',
      });
      return insights;
    }

    // Insight 1 : Productivité des habitudes
    final habitSuccessRate = HabitCalculationService.calculateSuccessRate(habits);
    if (habitSuccessRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Vos habitudes sont excellentes ! Taux de réussite de ${(habitSuccessRate * 100).round()}%.',
        'icon': '🎯',
      });
    } else if (habitSuccessRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Vos habitudes sont bonnes (${(habitSuccessRate * 100).round()}%), mais peuvent encore s\'améliorer.',
        'icon': '📈',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la régularité pour améliorer votre taux de ${(habitSuccessRate * 100).round()}%.',
        'icon': '💡',
      });
    }
    
    // Insight 2 : Série de réussite
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Impressionnant ! Vous avez une série de $currentStreak jours.',
        'icon': '🔥',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne série de $currentStreak jours, continuez !',
        'icon': '📊',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Commencez une nouvelle série pour améliorer votre productivité.',
        'icon': '🚀',
      });
    }
    
    // Insight 3 : Performance par catégorie
    final categoryPerformance = HabitCalculationService.calculateCategoryPerformance(habits);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'type': 'success',
        'message': 'Votre meilleure catégorie d\'habitudes est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '🏆',
      });
    }
    
    // Insight 4 : Nombre d'habitudes
    final activeHabits = habits.length;
    if (activeHabits < 3) {
      insights.add({
        'type': 'info',
        'message': 'Vous avez $activeHabits habitudes actives. Ajoutez-en pour diversifier vos objectifs.',
        'icon': '➕',
      });
    } else if (activeHabits > 10) {
      insights.add({
        'type': 'warning',
        'message': 'Vous avez $activeHabits habitudes actives. Considérez en simplifier certaines.',
        'icon': '⚖️',
      });
    } else {
      insights.add({
        'type': 'success',
        'message': 'Excellent équilibre avec $activeHabits habitudes actives.',
        'icon': '✅',
      });
    }
    
    return insights;
  }

  /// Génère des insights spécifiques aux tâches
  /// 
  /// [tasks] : Liste des tâches à analyser
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateTaskInsights(List<Task> tasks) {
    final insights = <Map<String, dynamic>>[];
    
    if (tasks.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Commencez par créer vos premières tâches pour générer des insights.',
        'icon': '📝',
      });
      return insights;
    }

    // Insight 1 : Taux de complétion
    final completionRate = TaskCalculationService.calculateCompletionRate(tasks);
    if (completionRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Excellent ! Vous terminez $completionRate% de vos tâches.',
        'icon': '✅',
      });
    } else if (completionRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Bon travail ! Vous terminez $completionRate% de vos tâches.',
        'icon': '📈',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la finalisation de vos tâches ($completionRate% terminées).',
        'icon': '💡',
      });
    }
    
    // Insight 2 : Tâches en attente
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    if (pendingTasks > 10) {
      insights.add({
        'type': 'error',
        'message': 'Vous avez $pendingTasks tâches en attente. Priorisez !',
        'icon': '⚠️',
      });
    } else if (pendingTasks > 5) {
      insights.add({
        'type': 'warning',
        'message': 'Vous avez $pendingTasks tâches en attente.',
        'icon': '📋',
      });
    } else {
      insights.add({
        'type': 'success',
        'message': 'Excellent ! Seulement $pendingTasks tâches en attente.',
        'icon': '🎯',
      });
    }
    
    // Insight 3 : Performance par catégorie
    final categoryPerformance = TaskCalculationService.calculateCategoryPerformance(tasks);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'type': 'success',
        'message': 'Votre meilleure catégorie de tâches est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '🏆',
      });
    }
    
    // Insight 4 : Temps de complétion
    final averageTime = TaskCalculationService.calculateAverageCompletionTime(tasks);
    if (averageTime > 0) {
      if (averageTime < 3) {
        insights.add({
          'type': 'success',
          'message': 'Impressionnant ! Vous terminez vos tâches en ${averageTime.toStringAsFixed(1)} jours en moyenne.',
          'icon': '⚡',
        });
      } else if (averageTime < 7) {
        insights.add({
          'type': 'warning',
          'message': 'Vous terminez vos tâches en ${averageTime.toStringAsFixed(1)} jours en moyenne.',
          'icon': '⏱️',
        });
      } else {
        insights.add({
          'type': 'info',
          'message': 'Considérez optimiser votre temps de complétion (${averageTime.toStringAsFixed(1)} jours en moyenne).',
          'icon': '📊',
        });
      }
    }
    
    return insights;
  }

  /// Génère des insights spécifiques aux séries de réussite
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateStreakInsights(List<Habit> habits) {
    final insights = <Map<String, dynamic>>[];
    
    if (habits.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Créez vos premières habitudes pour commencer à construire des séries.',
        'icon': '🚀',
      });
      return insights;
    }

    // Insight 1 : Série actuelle
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 30) {
      insights.add({
        'type': 'success',
        'message': 'Incroyable ! Vous avez une série de $currentStreak jours. Vous êtes un modèle !',
        'icon': '👑',
      });
    } else if (currentStreak > 14) {
      insights.add({
        'type': 'success',
        'message': 'Fantastique ! Votre série de $currentStreak jours est impressionnante.',
        'icon': '🔥',
      });
    } else if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Excellent ! Vous avez une série de $currentStreak jours.',
        'icon': '⭐',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne série de $currentStreak jours, continuez sur cette lancée !',
        'icon': '📈',
      });
    } else if (currentStreak > 0) {
      insights.add({
        'type': 'info',
        'message': 'Vous avez commencé une série de $currentStreak jours. Gardez le rythme !',
        'icon': '🎯',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Commencez une nouvelle série aujourd\'hui pour améliorer votre productivité.',
        'icon': '💪',
      });
    }
    
    // Insight 2 : Meilleure série historique (simulation)
    final bestStreak = _calculateBestStreak(habits);
    if (bestStreak > currentStreak && bestStreak > 7) {
      insights.add({
        'type': 'info',
        'message': 'Votre meilleure série historique est de $bestStreak jours. Vous pouvez y retourner !',
        'icon': '🏆',
      });
    }
    
    // Insight 3 : Habitudes avec les meilleures séries
    final topStreakHabits = _getTopStreakHabits(habits);
    if (topStreakHabits.isNotEmpty) {
      final bestHabit = topStreakHabits.first;
      insights.add({
        'type': 'success',
        'message': 'Votre habitude "${bestHabit.name}" a la meilleure série (${bestHabit.getCurrentStreak()} jours).',
        'icon': '🎖️',
      });
    }
    
    return insights;
  }

  /// Calcule la meilleure série historique (simulation)
  /// 
  /// [habits] : Liste des habitudes
  /// Retourne : Meilleure série historique
  static int _calculateBestStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    
    // Simulation basée sur le taux de réussite actuel
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    final successRate = HabitCalculationService.calculateSuccessRate(habits);
    
    // Estimation de la meilleure série basée sur le taux de réussite
    if (successRate > 0.9) {
      return (currentStreak * 1.5).round();
    } else if (successRate > 0.7) {
      return (currentStreak * 1.2).round();
    } else {
      return currentStreak;
    }
  }

  /// Obtient les habitudes avec les meilleures séries
  /// 
  /// [habits] : Liste des habitudes
  /// Retourne : Liste des habitudes triées par série décroissante
  static List<Habit> _getTopStreakHabits(List<Habit> habits) {
    if (habits.isEmpty) return [];
    
    final sortedHabits = List<Habit>.from(habits);
    sortedHabits.sort((a, b) => b.getCurrentStreak().compareTo(a.getCurrentStreak()));
    
    return sortedHabits.take(3).toList(); // Top 3
  }
} 
