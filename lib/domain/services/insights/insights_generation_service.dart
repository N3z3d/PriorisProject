import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/habit_calculation_service.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';

/// Service sp├®cialis├® dans la g├®n├®ration d'insights intelligents
/// 
/// Ce service extrait toute la logique de g├®n├®ration d'insights
/// des autres services pour respecter le principe de
/// responsabilit├® unique et faciliter les tests.
class InsightsGenerationService {
  /// G├®n├¿re des insights intelligents bas├®s sur les donn├®es globales
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des t├óches
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateSmartInsights(
    List<Habit> habits, 
    List<Task> tasks
  ) {
    final insights = <Map<String, dynamic>>[];
    
    // Insight 1 : Productivit├® par p├®riode
    final habitSuccessRate = HabitCalculationService.calculateSuccessRate(habits);
    if (habitSuccessRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Votre productivit├® est excellente ! Continuez comme ├ºa.',
        'icon': '­ƒÄ»',
      });
    } else if (habitSuccessRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Votre productivit├® est bonne, mais peut encore s\'am├®liorer.',
        'icon': '­ƒôê',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la r├®gularit├® pour am├®liorer votre productivit├®.',
        'icon': '­ƒÆí',
      });
    }
    
    // Insight 2 : Performance par cat├®gorie
    final categoryPerformance = HabitCalculationService.calculateCategoryPerformance(habits);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'type': 'success',
        'message': 'Votre meilleure cat├®gorie est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '­ƒÅå',
      });
    }
    
    // Insight 3 : S├®rie de r├®ussite
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Impressionnant ! Vous avez une s├®rie de $currentStreak jours.',
        'icon': '­ƒöÑ',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne s├®rie de $currentStreak jours, continuez !',
        'icon': '­ƒôè',
      });
    }
    
    // Insight 4 : T├óches en retard
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    if (pendingTasks > 10) {
      insights.add({
        'type': 'error',
        'message': 'Vous avez $pendingTasks t├óches en attente. Priorisez !',
        'icon': 'ÔÜá´©Å',
      });
    }
    
    return insights;
  }

  /// G├®n├¿re des insights sp├®cifiques ├á la productivit├® des habitudes
  /// 
  /// [habits] : Liste des habitudes ├á analyser
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateProductivityInsights(List<Habit> habits) {
    final insights = <Map<String, dynamic>>[];
    
    if (habits.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Commencez par cr├®er vos premi├¿res habitudes pour g├®n├®rer des insights.',
        'icon': '­ƒÄ»',
      });
      return insights;
    }

    // Insight 1 : Productivit├® des habitudes
    final habitSuccessRate = HabitCalculationService.calculateSuccessRate(habits);
    if (habitSuccessRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Vos habitudes sont excellentes ! Taux de r├®ussite de ${(habitSuccessRate * 100).round()}%.',
        'icon': '­ƒÄ»',
      });
    } else if (habitSuccessRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Vos habitudes sont bonnes (${(habitSuccessRate * 100).round()}%), mais peuvent encore s\'am├®liorer.',
        'icon': '­ƒôê',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la r├®gularit├® pour am├®liorer votre taux de ${(habitSuccessRate * 100).round()}%.',
        'icon': '­ƒÆí',
      });
    }
    
    // Insight 2 : S├®rie de r├®ussite
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Impressionnant ! Vous avez une s├®rie de $currentStreak jours.',
        'icon': '­ƒöÑ',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne s├®rie de $currentStreak jours, continuez !',
        'icon': '­ƒôè',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Commencez une nouvelle s├®rie pour am├®liorer votre productivit├®.',
        'icon': '­ƒÜÇ',
      });
    }
    
    // Insight 3 : Performance par cat├®gorie
    final categoryPerformance = HabitCalculationService.calculateCategoryPerformance(habits);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'type': 'success',
        'message': 'Votre meilleure cat├®gorie d\'habitudes est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '­ƒÅå',
      });
    }
    
    // Insight 4 : Nombre d'habitudes
    final activeHabits = habits.length;
    if (activeHabits < 3) {
      insights.add({
        'type': 'info',
        'message': 'Vous avez $activeHabits habitudes actives. Ajoutez-en pour diversifier vos objectifs.',
        'icon': 'Ô×ò',
      });
    } else if (activeHabits > 10) {
      insights.add({
        'type': 'warning',
        'message': 'Vous avez $activeHabits habitudes actives. Consid├®rez en simplifier certaines.',
        'icon': 'ÔÜû´©Å',
      });
    } else {
      insights.add({
        'type': 'success',
        'message': 'Excellent ├®quilibre avec $activeHabits habitudes actives.',
        'icon': 'Ô£à',
      });
    }
    
    return insights;
  }

  /// G├®n├¿re des insights sp├®cifiques aux t├óches
  /// 
  /// [tasks] : Liste des t├óches ├á analyser
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateTaskInsights(List<Task> tasks) {
    final insights = <Map<String, dynamic>>[];
    
    if (tasks.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Commencez par cr├®er vos premi├¿res t├óches pour g├®n├®rer des insights.',
        'icon': '­ƒôØ',
      });
      return insights;
    }

    // Insight 1 : Taux de compl├®tion
    final completionRate = TaskCalculationService.calculateCompletionRate(tasks);
    if (completionRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Excellent ! Vous terminez $completionRate% de vos t├óches.',
        'icon': 'Ô£à',
      });
    } else if (completionRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Bon travail ! Vous terminez $completionRate% de vos t├óches.',
        'icon': '­ƒôê',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la finalisation de vos t├óches ($completionRate% termin├®es).',
        'icon': '­ƒÆí',
      });
    }
    
    // Insight 2 : T├óches en attente
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    if (pendingTasks > 10) {
      insights.add({
        'type': 'error',
        'message': 'Vous avez $pendingTasks t├óches en attente. Priorisez !',
        'icon': 'ÔÜá´©Å',
      });
    } else if (pendingTasks > 5) {
      insights.add({
        'type': 'warning',
        'message': 'Vous avez $pendingTasks t├óches en attente.',
        'icon': '­ƒôï',
      });
    } else {
      insights.add({
        'type': 'success',
        'message': 'Excellent ! Seulement $pendingTasks t├óches en attente.',
        'icon': '­ƒÄ»',
      });
    }
    
    // Insight 3 : Performance par cat├®gorie
    final categoryPerformance = TaskCalculationService.calculateCategoryPerformance(tasks);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'type': 'success',
        'message': 'Votre meilleure cat├®gorie de t├óches est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '­ƒÅå',
      });
    }
    
    // Insight 4 : Temps de compl├®tion
    final averageTime = TaskCalculationService.calculateAverageCompletionTime(tasks);
    if (averageTime > 0) {
      if (averageTime < 3) {
        insights.add({
          'type': 'success',
          'message': 'Impressionnant ! Vous terminez vos t├óches en ${averageTime.toStringAsFixed(1)} jours en moyenne.',
          'icon': 'ÔÜí',
        });
      } else if (averageTime < 7) {
        insights.add({
          'type': 'warning',
          'message': 'Vous terminez vos t├óches en ${averageTime.toStringAsFixed(1)} jours en moyenne.',
          'icon': 'ÔÅ▒´©Å',
        });
      } else {
        insights.add({
          'type': 'info',
          'message': 'Consid├®rez optimiser votre temps de compl├®tion (${averageTime.toStringAsFixed(1)} jours en moyenne).',
          'icon': '­ƒôè',
        });
      }
    }
    
    return insights;
  }

  /// G├®n├¿re des insights sp├®cifiques aux s├®ries de r├®ussite
  /// 
  /// [habits] : Liste des habitudes ├á analyser
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateStreakInsights(List<Habit> habits) {
    final insights = <Map<String, dynamic>>[];
    
    if (habits.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Cr├®ez vos premi├¿res habitudes pour commencer ├á construire des s├®ries.',
        'icon': '­ƒÜÇ',
      });
      return insights;
    }

    // Insight 1 : S├®rie actuelle
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 30) {
      insights.add({
        'type': 'success',
        'message': 'Incroyable ! Vous avez une s├®rie de $currentStreak jours. Vous ├¬tes un mod├¿le !',
        'icon': '­ƒææ',
      });
    } else if (currentStreak > 14) {
      insights.add({
        'type': 'success',
        'message': 'Fantastique ! Votre s├®rie de $currentStreak jours est impressionnante.',
        'icon': '­ƒöÑ',
      });
    } else if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Excellent ! Vous avez une s├®rie de $currentStreak jours.',
        'icon': 'Ô¡É',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne s├®rie de $currentStreak jours, continuez sur cette lanc├®e !',
        'icon': '­ƒôê',
      });
    } else if (currentStreak > 0) {
      insights.add({
        'type': 'info',
        'message': 'Vous avez commenc├® une s├®rie de $currentStreak jours. Gardez le rythme !',
        'icon': '­ƒÄ»',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Commencez une nouvelle s├®rie aujourd\'hui pour am├®liorer votre productivit├®.',
        'icon': '­ƒÆ¬',
      });
    }
    
    // Insight 2 : Meilleure s├®rie historique (simulation)
    final bestStreak = _calculateBestStreak(habits);
    if (bestStreak > currentStreak && bestStreak > 7) {
      insights.add({
        'type': 'info',
        'message': 'Votre meilleure s├®rie historique est de $bestStreak jours. Vous pouvez y retourner !',
        'icon': '­ƒÅå',
      });
    }
    
    // Insight 3 : Habitudes avec les meilleures s├®ries
    final topStreakHabits = _getTopStreakHabits(habits);
    if (topStreakHabits.isNotEmpty) {
      final bestHabit = topStreakHabits.first;
      insights.add({
        'type': 'success',
        'message': 'Votre habitude "${bestHabit.name}" a la meilleure s├®rie (${bestHabit.getCurrentStreak()} jours).',
        'icon': '­ƒÄû´©Å',
      });
    }
    
    return insights;
  }

  /// Calcule la meilleure s├®rie historique (simulation)
  /// 
  /// [habits] : Liste des habitudes
  /// Retourne : Meilleure s├®rie historique
  static int _calculateBestStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    
    // Simulation bas├®e sur le taux de r├®ussite actuel
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    final successRate = HabitCalculationService.calculateSuccessRate(habits);
    
    // Estimation de la meilleure s├®rie bas├®e sur le taux de r├®ussite
    if (successRate > 0.9) {
      return (currentStreak * 1.5).round();
    } else if (successRate > 0.7) {
      return (currentStreak * 1.2).round();
    } else {
      return currentStreak;
    }
  }

  /// Obtient les habitudes avec les meilleures s├®ries
  /// 
  /// [habits] : Liste des habitudes
  /// Retourne : Liste des habitudes tri├®es par s├®rie d├®croissante
  static List<Habit> _getTopStreakHabits(List<Habit> habits) {
    if (habits.isEmpty) return [];
    
    final sortedHabits = List<Habit>.from(habits);
    sortedHabits.sort((a, b) => b.getCurrentStreak().compareTo(a.getCurrentStreak()));
    
    return sortedHabits.take(3).toList(); // Top 3
  }
} 
