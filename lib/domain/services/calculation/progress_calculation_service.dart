import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';  // Temporarily disabled
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'habit_calculation_service.dart';
import 'task_calculation_service.dart';

// Temporary placeholder classes for fl_chart types
class FlSpot {
  final double x;
  final double y;
  const FlSpot(this.x, this.y);
}

class PieChartSectionData {
  final double value;
  final Color color;
  final String title;
  const PieChartSectionData({required this.value, required this.color, this.title = ''});
}

class BarChartGroupData {
  final int x;
  final List<dynamic> barRods;
  const BarChartGroupData({required this.x, this.barRods = const []});
}

/// Service spécialisé dans les calculs de progression et génération de données pour graphiques
/// 
/// Ce service extrait toute la logique de calcul de progression
/// des widgets et du StatisticsCalculationService pour respecter le principe de
/// responsabilité unique et faciliter les tests.
class ProgressCalculationService {
  /// Détermine la couleur de progression basée sur une valeur
  /// 
  /// [value] : Valeur entre 0 et 100
  /// Retourne : Couleur appropriée
  static Color getProgressColor(double value) {
    if (value >= 80) return AppTheme.successColor;
    if (value >= 60) return AppTheme.primaryColor;
    if (value >= 40) return AppTheme.accentColor;
    return AppTheme.errorColor;
  }

  /// Génère les données de progression pour un graphique
  /// 
  /// [period] : Période sélectionnée ('7_days', '30_days', '90_days', '365_days')
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Liste de points FlSpot pour le graphique
  static List<FlSpot> generateProgressData(String period, List<Habit> habits, List<Task> tasks) {
    switch (period) {
      case '7_days':
        return _generateWeeklyProgressData(habits, tasks);
      case '30_days':
        return _generateMonthlyProgressData(habits, tasks);
      case '90_days':
        return _generateQuarterlyProgressData(habits, tasks);
      case '365_days':
        return _generateYearlyProgressData(habits, tasks);
      default:
        return _generateWeeklyProgressData(habits, tasks);
    }
  }

  /// Génère les labels de période pour l'axe X
  /// 
  /// [period] : Période sélectionnée
  /// Retourne : Liste de labels pour l'axe X
  static List<String> generatePeriodLabels(String period) {
    switch (period) {
      case '7_days':
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      case '30_days':
        return List.generate(30, (index) => '${index + 1}');
      case '90_days':
        return List.generate(90, (index) => '${index + 1}');
      case '365_days':
        return List.generate(365, (index) => '${index + 1}');
      default:
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    }
  }

  /// Calcule la progression globale basée sur les habitudes et tâches
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Pourcentage de progression globale (0-100)
  static double calculateOverallProgress(List<Habit> habits, List<Task> tasks) {
    if (habits.isEmpty && tasks.isEmpty) return 0.0;
    
    double habitProgress = 0.0;
    double taskProgress = 0.0;
    
    // Calculer la progression des habitudes
    if (habits.isNotEmpty) {
      final habitSuccessRate = HabitCalculationService.calculateSuccessRate(habits);
      habitProgress = habitSuccessRate.toDouble();
    }
    
    // Calculer la progression des tâches
    if (tasks.isNotEmpty) {
      final taskCompletionRate = TaskCalculationService.calculateCompletionRate(tasks);
      taskProgress = taskCompletionRate.toDouble();
    }
    
    // Moyenne pondérée (habitudes plus importantes)
    if (habits.isNotEmpty && tasks.isNotEmpty) {
      return (habitProgress * 0.7 + taskProgress * 0.3);
    } else if (habits.isNotEmpty) {
      return habitProgress;
    } else {
      return taskProgress;
    }
  }

  /// Calcule la progression par jour pour les 7 derniers jours
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Liste de points FlSpot pour la semaine
  static List<FlSpot> _generateWeeklyProgressData(List<Habit> habits, List<Task> tasks) {
    final List<FlSpot> data = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayProgress = _calculateDayProgress(date, habits, tasks);
      data.add(FlSpot((6 - i).toDouble(), dayProgress));
    }
    
    return data;
  }

  /// Calcule la progression par jour pour les 30 derniers jours
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Liste de points FlSpot pour le mois
  static List<FlSpot> _generateMonthlyProgressData(List<Habit> habits, List<Task> tasks) {
    final List<FlSpot> data = [];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayProgress = _calculateDayProgress(date, habits, tasks);
      data.add(FlSpot((29 - i).toDouble(), dayProgress));
    }
    
    return data;
  }

  /// Calcule la progression par jour pour les 90 derniers jours
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Liste de points FlSpot pour le trimestre
  static List<FlSpot> _generateQuarterlyProgressData(List<Habit> habits, List<Task> tasks) {
    final List<FlSpot> data = [];
    final now = DateTime.now();
    
    for (int i = 89; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayProgress = _calculateDayProgress(date, habits, tasks);
      data.add(FlSpot((89 - i).toDouble(), dayProgress));
    }
    
    return data;
  }

  /// Calcule la progression par jour pour les 365 derniers jours
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Liste de points FlSpot pour l'année
  static List<FlSpot> _generateYearlyProgressData(List<Habit> habits, List<Task> tasks) {
    final List<FlSpot> data = [];
    final now = DateTime.now();
    
    for (int i = 364; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayProgress = _calculateDayProgress(date, habits, tasks);
      data.add(FlSpot((364 - i).toDouble(), dayProgress));
    }
    
    return data;
  }

  /// Calcule la progression pour une journée spécifique
  /// 
  /// [date] : Date pour laquelle calculer la progression
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Pourcentage de progression pour cette journée (0-100)
  static double _calculateDayProgress(DateTime date, List<Habit> habits, List<Task> tasks) {
    double habitProgress = 0.0;
    double taskProgress = 0.0;
    
    // Calculer la progression des habitudes pour cette journée
    if (habits.isNotEmpty) {
      final dateKey = _getDateKey(date);
      int completedHabits = 0;
      
      for (final habit in habits) {
        final value = habit.completions[dateKey];
        bool isCompleted = false;
        
        if (habit.type == HabitType.binary && value == true) {
          isCompleted = true;
        } else if (habit.type == HabitType.quantitative && 
                   value != null && 
                   habit.targetValue != null && 
                   (value as double) >= habit.targetValue!) {
          isCompleted = true;
        }
        
        if (isCompleted) completedHabits++;
      }
      
      habitProgress = (completedHabits / habits.length) * 100;
    }
    
    // Calculer la progression des tâches pour cette journée
    if (tasks.isNotEmpty) {
      final tasksCompletedToday = tasks.where((task) {
        if (!task.isCompleted || task.completedAt == null) return false;
        final taskDate = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);
        return taskDate.isAtSameMomentAs(targetDate);
      }).length;
      
      taskProgress = (tasksCompletedToday / tasks.length) * 100;
    }
    
    // Moyenne pondérée
    if (habits.isNotEmpty && tasks.isNotEmpty) {
      return (habitProgress * 0.7 + taskProgress * 0.3);
    } else if (habits.isNotEmpty) {
      return habitProgress;
    } else {
      return taskProgress;
    }
  }

  /// Génère une clé de date au format YYYY-MM-DD
  /// 
  /// [date] : Date à formater
  /// Retourne : Clé de date formatée
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calcule la progression moyenne sur une période donnée
  /// 
  /// [period] : Période ('7_days', '30_days', '90_days', '365_days')
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Progression moyenne sur la période (0-100)
  static double calculateAverageProgress(String period, List<Habit> habits, List<Task> tasks) {
    final progressData = generateProgressData(period, habits, tasks);
    
    if (progressData.isEmpty) return 0.0;
    
    final totalProgress = progressData.map((spot) => spot.y).reduce((a, b) => a + b);
    return totalProgress / progressData.length;
  }

  /// Calcule la tendance de progression (croissante, décroissante, stable)
  /// 
  /// [period] : Période sélectionnée
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : 'increasing', 'decreasing', ou 'stable'
  static String calculateProgressTrend(String period, List<Habit> habits, List<Task> tasks) {
    final progressData = generateProgressData(period, habits, tasks);
    
    if (progressData.length < 2) return 'stable';
    
    // Prendre les 3 premiers et 3 derniers points pour calculer la tendance
    final firstPoints = progressData.take(3).map((spot) => spot.y).toList();
    final lastPoints = progressData.reversed.take(3).map((spot) => spot.y).toList();
    
    final firstAverage = firstPoints.reduce((a, b) => a + b) / firstPoints.length;
    final lastAverage = lastPoints.reduce((a, b) => a + b) / lastPoints.length;
    
    final difference = lastAverage - firstAverage;
    
    if (difference > 5) return 'increasing';
    if (difference < -5) return 'decreasing';
    return 'stable';
  }

  /// Calcule le meilleur jour de la période
  /// 
  /// [period] : Période sélectionnée
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Index du meilleur jour et sa valeur
  static Map<String, dynamic> calculateBestDay(String period, List<Habit> habits, List<Task> tasks) {
    final progressData = generateProgressData(period, habits, tasks);
    
    if (progressData.isEmpty) {
      return {'index': 0, 'value': 0.0};
    }
    
    double maxValue = progressData.first.y;
    int maxIndex = 0;
    
    for (int i = 1; i < progressData.length; i++) {
      if (progressData[i].y > maxValue) {
        maxValue = progressData[i].y;
        maxIndex = i;
      }
    }
    
    return {'index': maxIndex, 'value': maxValue};
  }

  /// Calcule le pire jour de la période
  /// 
  /// [period] : Période sélectionnée
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Index du pire jour et sa valeur
  static Map<String, dynamic> calculateWorstDay(String period, List<Habit> habits, List<Task> tasks) {
    final progressData = generateProgressData(period, habits, tasks);
    
    if (progressData.isEmpty) {
      return {'index': 0, 'value': 0.0};
    }
    
    double minValue = progressData.first.y;
    int minIndex = 0;
    
    for (int i = 1; i < progressData.length; i++) {
      if (progressData[i].y < minValue) {
        minValue = progressData[i].y;
        minIndex = i;
      }
    }
    
    return {'index': minIndex, 'value': minValue};
  }
} 
