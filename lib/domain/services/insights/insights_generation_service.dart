import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/services/calculation/habit_calculation_service.dart';
import 'package:prioris/domain/services/calculation/task_calculation_service.dart';

/// Service sp\u251C\u00AEcialis\u251C\u00AE dans la g\u251C\u00AEn\u251C\u00AEration d'insights intelligents
/// 
/// Ce service extrait toute la logique de g\u251C\u00AEn\u251C\u00AEration d'insights
/// des autres services pour respecter le principe de
/// responsabilit\u251C\u00AE unique et faciliter les tests.
class InsightsGenerationService {
  /// G\u251C\u00AEn\u251C\u00BFre des insights intelligents bas\u251C\u00AEs sur les donn\u251C\u00AEes globales
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des t\u251C\u00F3ches
  /// Retourne : Liste d'insights sous forme de Map
    static List<Map<String, dynamic>> generateSmartInsights(
    List<Habit> habits,
    List<Task> tasks,
  ) {
    final insights = <Map<String, dynamic>>[];

    final habitSuccessRate =
        HabitCalculationService.calculateSuccessRate(habits);
    if (habitSuccessRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Votre productivit\u00E9 est excellente ! Continuez comme \u00E7a.',
        'icon': '\uD83C\uDFAF',
      });
    } else if (habitSuccessRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Votre productivit\u00E9 est bonne, mais peut encore s\'am\u00E9liorer.',
        'icon': '\uD83D\uDCC8',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la r\u00E9gularit\u00E9 pour am\u00E9liorer votre productivit\u00E9.',
        'icon': '\uD83D\uDCA1',
      });
    }

    final categoryPerformance =
        HabitCalculationService.calculateCategoryPerformance(habits);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      insights.add({
        'type': 'success',
        'message': 'Votre meilleure cat\u00E9gorie est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '\uD83C\uDFC6',
      });
    }

    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Impressionnant ! Vous avez une s\u00E9rie de $currentStreak jours.',
        'icon': '\uD83D\uDD25',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne s\u00E9rie de $currentStreak jours, continuez !',
        'icon': '\uD83D\uDCCA',
      });
    }

    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    if (pendingTasks > 10) {
      insights.add({
        'type': 'error',
        'message': '${_tasksCount(pendingTasks)} en attente',
        'icon': '\u26A0\uFE0F',
      });
    }

    return insights;
  }  static List<Map<String, dynamic>> generateProductivityInsights(
    List<Habit> habits,
  ) {
    final insights = <Map<String, dynamic>>[];

    if (habits.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Aucune liste \u00E0 analyser',
        'icon': '\uD83D\uDDC2\uFE0F',
      });
      return insights;
    }

    final habitSuccessRate =
        HabitCalculationService.calculateSuccessRate(habits);
    if (habitSuccessRate >= 80) {
      insights.add({
        'type': 'success',
        'message': 'Bon rythme de livraison',
        'icon': '\uD83D\uDE80',
      });
    } else if (habitSuccessRate <= 30) {
      insights.add({
        'type': 'warning',
        'message': 'Productivit\u00E9 basse',
        'icon': '\u26A0\uFE0F',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Rythme stable \u00E0 maintenir',
        'icon': '\uD83D\uDCCA',
      });
    }

    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Impressionnant ! Vous avez une s\u00E9rie de $currentStreak jours.',
        'icon': '\uD83D\uDD25',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne s\u00E9rie de $currentStreak jours, continuez !',
        'icon': '\uD83D\uDCC8',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Commencez une nouvelle s\u00E9rie pour am\u00E9liorer votre productivit\u00E9.',
        'icon': '\uD83C\uDFAF',
      });
    }

    final categoryPerformance =
        HabitCalculationService.calculateCategoryPerformance(habits);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add({
        'type': 'success',
        'message': 'Votre meilleure cat\u00E9gorie d\'habitudes est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '\uD83C\uDFC6',
      });
    }

    final activeHabits = habits.length;
    if (activeHabits < 3) {
      insights.add({
        'type': 'info',
        'message': 'Vous avez $activeHabits habitudes actives. Ajoutez-en pour diversifier vos objectifs.',
        'icon': '\uD83D\uDCDD',
      });
    } else if (activeHabits > 10) {
      insights.add({
        'type': 'warning',
        'message': 'Vous avez $activeHabits habitudes actives. Consid\u00E9rez en simplifier certaines.',
        'icon': '\uD83D\uDCDA',
      });
    } else {
      insights.add({
        'type': 'success',
        'message': 'Excellent \u00E9quilibre avec $activeHabits habitudes actives.',
        'icon': '\u2705',
      });
    }

    return insights;
  }  static List<Map<String, dynamic>> generateTaskInsights(List<Task> tasks) {
    final insights = <Map<String, dynamic>>[];

    if (tasks.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Commencez par cr\u00E9er des t\u00E2ches',
        'icon': '\uD83D\uDDD2\uFE0F',
      });
      return insights;
    }

    final completionRate = TaskCalculationService.calculateCompletionRate(tasks);
    if (completionRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Excellent ! Vous terminez $completionRate% de vos t\u00E2ches.',
        'icon': '\u2705',
      });
    } else if (completionRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Bon travail ! Vous terminez $completionRate% de vos t\u00E2ches.',
        'icon': '\uD83D\uDCC8',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la finalisation de vos t\u00E2ches ($completionRate% termin\u00E9es).',
        'icon': '\uD83D\uDCA1',
      });
    }

    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    if (pendingTasks > 10) {
      insights.add({
        'type': 'warning',
        'message': 'R\u00E9duisez le backlog',
        'icon': '\u26A0\uFE0F',
      });
    } else {
      insights.add({
        'type': 'success',
        'message': 'Bon \u00E9quilibre de priorit\u00E9s',
        'icon': '\uD83C\uDFAF',
      });
    }

    final categoryPerformance =
        TaskCalculationService.calculateCategoryPerformance(tasks);
    if (categoryPerformance.isNotEmpty) {
      final bestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      insights.add({
        'type': 'success',
        'message': 'Votre meilleure cat\u00E9gorie de t\u00E2ches est "${bestCategory.key}" (${bestCategory.value.round()}%)',
        'icon': '\uD83C\uDFC6',
      });
    }

    final averageTime = TaskCalculationService.calculateAverageCompletionTime(tasks);
    if (averageTime > 0) {
      if (averageTime < 3) {
        insights.add({
          'type': 'success',
          'message': 'Impressionnant ! Vous terminez vos t\u00E2ches en ${averageTime.toStringAsFixed(1)} jours en moyenne.',
          'icon': '\u26A1',
        });
      } else if (averageTime < 7) {
        insights.add({
          'type': 'warning',
          'message': 'Vous terminez vos t\u00E2ches en ${averageTime.toStringAsFixed(1)} jours en moyenne.',
          'icon': '\u23F1\uFE0F',
        });
      } else {
        insights.add({
          'type': 'info',
          'message': 'Consid\u00E9rez optimiser votre temps de compl\u00E9tion (${averageTime.toStringAsFixed(1)} jours en moyenne).',
          'icon': '\uD83D\uDCCA',
        });
      }
    }

    return insights;
  }  static List<Map<String, dynamic>> generateStreakInsights(List<Habit> habits) {
    final insights = <Map<String, dynamic>>[];

    if (habits.isEmpty) {
      insights.add({
        'type': 'info',
        'message': 'Aucune liste',
        'icon': '\uD83D\uDCC2',
      });
      return insights;
    }

    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    if (currentStreak >= 10) {
      insights.add({
        'type': 'success',
        'message': 'S\u00E9rie de ${_daysCount(currentStreak)}',
        'icon': '\uD83D\uDD25',
      });
    } else if (currentStreak >= 5) {
      insights.add({
        'type': 'warning',
        'message': 'Poursuivez votre s\u00E9rie de ${_daysCount(currentStreak)}',
        'icon': '\uD83D\uDCC8',
      });
    } else if (currentStreak > 0) {
      insights.add({
        'type': 'info',
        'message': 'Rythme actuel : ${_daysCount(currentStreak)}',
        'icon': '\uD83C\uDFAF',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Premi\u00E8res habitudes en cours',
        'icon': '\uD83D\uDCAA',
      });
    }

    final bestStreak = _calculateBestStreak(habits);
    if (bestStreak > currentStreak && bestStreak > 7) {
      insights.add({
        'type': 'info',
        'message': 'Votre meilleure s\u00E9rie historique est de ${_daysCount(bestStreak)}. Vous pouvez y retourner !',
        'icon': '\uD83C\uDFC6',
      });
    }

    final topStreakHabits = _getTopStreakHabits(habits);
    if (topStreakHabits.isNotEmpty) {
      final bestHabit = topStreakHabits.first;
      insights.add({
        'type': 'success',
        'message': 'Votre habitude "${bestHabit.name}" a la meilleure s\u00E9rie (${bestHabit.getCurrentStreak()} jours).',
        'icon': '\uD83C\uDF96\uFE0F',
      });
    }

    return insights;
  }

  static String _plural(
    int value, {
    required String one,
    required String many,
  }) =>
      value.abs() == 1 ? one : many;

  static String _tasksCount(int value) =>
      '$value ${_plural(value, one: 't\u00E2che', many: 't\u00E2ches')}';

  static String _daysCount(int value) =>
      '$value ${_plural(value, one: 'jour', many: 'jours')}';

  static int _calculateBestStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    
    // Simulation bas\u251C\u00AEe sur le taux de r\u251C\u00AEussite actuel
    final currentStreak = HabitCalculationService.calculateCurrentStreak(habits);
    final successRate = HabitCalculationService.calculateSuccessRate(habits);
    
    // Estimation de la meilleure s\u251C\u00AErie bas\u251C\u00AEe sur le taux de r\u251C\u00AEussite
    if (successRate > 0.9) {
      return (currentStreak * 1.5).round();
    } else if (successRate > 0.7) {
      return (currentStreak * 1.2).round();
    } else {
      return currentStreak;
    }
  }

  /// Obtient les habitudes avec les meilleures s\u251C\u00AEries
  /// 
  /// [habits] : Liste des habitudes
  /// Retourne : Liste des habitudes tri\u251C\u00AEes par s\u251C\u00AErie d\u251C\u00AEcroissante
  static List<Habit> _getTopStreakHabits(List<Habit> habits) {
    if (habits.isEmpty) return [];
    
    final sortedHabits = List<Habit>.from(habits);
    sortedHabits.sort((a, b) => b.getCurrentStreak().compareTo(a.getCurrentStreak()));
    
    return sortedHabits.take(3).toList(); // Top 3
  }
} 
