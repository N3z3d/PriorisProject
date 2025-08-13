import 'package:prioris/domain/models/core/entities/task.dart';

/// Service spécialisé dans les calculs liés aux tâches
/// 
/// Ce service extrait toute la logique de calcul spécifique aux tâches
/// du StatisticsCalculationService pour respecter le principe de
/// responsabilité unique et faciliter les tests.
class TaskCalculationService {
  /// Calcule le taux de complétion des tâches
  /// 
  /// [tasks] : Liste des tâches à analyser
  /// Retourne : Pourcentage de tâches complétées (0-100)
  static int calculateCompletionRate(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return ((completedTasks / tasks.length) * 100).round();
  }

  /// Calcule les statistiques ELO des tâches
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec les statistiques ELO
  static Map<String, dynamic> calculateEloStatistics(List<Task> tasks) {
    if (tasks.isEmpty) {
      return {
        'averageElo': 0.0,
        'maxElo': 0.0,
        'minElo': 0.0,
        'distribution': {'easy': 0, 'medium': 0, 'hard': 0},
      };
    }
    
    final eloScores = tasks.map((task) => task.eloScore).toList();
    final averageElo = eloScores.reduce((a, b) => a + b) / eloScores.length;
    final maxElo = eloScores.reduce((a, b) => a > b ? a : b);
    final minElo = eloScores.reduce((a, b) => a < b ? a : b);
    
    // Distribution par difficulté
    int easy = 0, medium = 0, hard = 0;
    for (final elo in eloScores) {
      if (elo < 1200) {
        easy++;
      } else if (elo < 1400) {
        medium++;
      } else {
        hard++;
      }
    }
    
    return {
      'averageElo': averageElo,
      'maxElo': maxElo,
      'minElo': minElo,
      'distribution': {
        'easy': easy,
        'medium': medium,
        'hard': hard,
      },
    };
  }

  /// Calcule les statistiques de temps de complétion par catégorie
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec les statistiques de temps
  static Map<String, dynamic> calculateCompletionTimeStats(List<Task> tasks) {
    final completedTasks = tasks.where((task) => 
      task.isCompleted && task.completedAt != null
    ).toList();
    
    if (completedTasks.isEmpty) {
      return {
        'averageTime': 0.0,
        'fastestCategory': null,
        'slowestCategory': null,
        'categoryTimes': {},
      };
    }
    
    // Calculer le temps de complétion par tâche
    final Map<String, List<double>> categoryTimes = {};
    
    for (final task in completedTasks) {
      final duration = task.completedAt!.difference(task.createdAt).inDays.toDouble();
      final category = task.category ?? 'Sans catégorie';
      
      categoryTimes.putIfAbsent(category, () => []);
      categoryTimes[category]!.add(duration);
    }
    
    // Calculer les moyennes par catégorie
    final Map<String, double> categoryAverages = {};
    categoryTimes.forEach((category, times) {
      categoryAverages[category] = times.reduce((a, b) => a + b) / times.length;
    });
    
    // Trouver les catégories les plus rapides et lentes
    String? fastestCategory;
    String? slowestCategory;
    double fastestTime = double.infinity;
    double slowestTime = 0.0;
    
    categoryAverages.forEach((category, time) {
      if (time < fastestTime) {
        fastestTime = time;
        fastestCategory = category;
      }
      if (time > slowestTime) {
        slowestTime = time;
        slowestCategory = category;
      }
    });
    
    // Temps moyen global
    final allTimes = completedTasks.map((task) => 
      task.completedAt!.difference(task.createdAt).inDays.toDouble()
    ).toList();
    final averageTime = allTimes.reduce((a, b) => a + b) / allTimes.length;
    
    return {
      'averageTime': averageTime,
      'fastestCategory': fastestCategory,
      'slowestCategory': slowestCategory,
      'categoryTimes': categoryAverages,
    };
  }

  /// Calcule l'ELO moyen des tâches
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : ELO moyen
  static double calculateAverageElo(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    final eloScores = tasks.map((task) => task.eloScore).toList();
    return eloScores.reduce((a, b) => a + b) / eloScores.length;
  }

  /// Calcule le temps moyen de complétion des tâches terminées
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Temps moyen en jours
  static double calculateAverageCompletionTime(List<Task> tasks) {
    final completedTasks = tasks.where((task) => 
      task.isCompleted && task.completedAt != null
    ).toList();
    
    if (completedTasks.isEmpty) return 0.0;
    
    final totalDays = completedTasks
        .map((task) => task.completedAt!.difference(task.createdAt).inDays)
        .reduce((a, b) => a + b);
    
    return totalDays / completedTasks.length;
  }

  /// Calcule le nombre de tâches complétées
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Nombre de tâches complétées
  static int calculateCompletedTasks(List<Task> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  /// Calcule le nombre de tâches en attente
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Nombre de tâches en attente
  static int calculatePendingTasks(List<Task> tasks) {
    return tasks.where((task) => !task.isCompleted).length;
  }

  /// Calcule la performance par catégorie pour les tâches uniquement
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec catégorie -> pourcentage de complétion
  static Map<String, double> calculateCategoryPerformance(List<Task> tasks) {
    final Map<String, List<double>> categoryScores = {};
    
    // Analyser les tâches par catégorie
    for (final task in tasks) {
      if (task.category != null) {
        categoryScores.putIfAbsent(task.category!, () => []);
        final taskScore = task.isCompleted ? 100.0 : 0.0;
        categoryScores[task.category!]!.add(taskScore);
      }
    }
    
    // Calculer la moyenne par catégorie
    final Map<String, double> result = {};
    categoryScores.forEach((category, scores) {
      if (scores.isNotEmpty) {
        final average = scores.reduce((a, b) => a + b) / scores.length;
        result[category] = average;
      }
    });
    
    return result;
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
    final completionRate = calculateCompletionRate(tasks);
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
    final pendingTasks = calculatePendingTasks(tasks);
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
    final categoryPerformance = calculateCategoryPerformance(tasks);
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
    final averageTime = calculateAverageCompletionTime(tasks);
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
} 
