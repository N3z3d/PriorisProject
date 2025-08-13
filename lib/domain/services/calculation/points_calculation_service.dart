import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

/// Service spécialisé dans les calculs de points
/// 
/// Ce service extrait toute la logique de calcul des points
/// du StatisticsCalculationService pour respecter le principe de
/// responsabilité unique et faciliter les tests.
class PointsCalculationService {
  /// Points attribués pour chaque habitude active
  static const int habitPoints = 50;
  
  /// Points attribués pour chaque tâche complétée
  static const int completedTaskPoints = 25;
  
  /// Points attribués pour chaque tâche en attente
  static const int pendingTaskPoints = 0;

  /// Calcule le total des points basé sur les habitudes et tâches
  /// 
  /// [habits] : Liste des habitudes (50 points chacune)
  /// [tasks] : Liste des tâches (25 points chacune si complétée)
  /// Retourne : Total des points
  static int calculateTotalPoints(List<Habit> habits, List<Task> tasks) {
    final habitPoints = calculateHabitPoints(habits);
    final taskPoints = calculateTaskPoints(tasks);
    
    return habitPoints + taskPoints;
  }

  /// Calcule les points des habitudes
  /// 
  /// [habits] : Liste des habitudes
  /// Retourne : Total des points des habitudes
  static int calculateHabitPoints(List<Habit> habits) {
    return habits.length * habitPoints;
  }

  /// Calcule les points des tâches
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Total des points des tâches
  static int calculateTaskPoints(List<Task> tasks) {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks * completedTaskPoints;
  }

  /// Calcule les points par catégorie
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec catégorie -> points
  static Map<String, int> calculatePointsByCategory(List<Habit> habits, List<Task> tasks) {
    final Map<String, int> categoryPoints = {};
    
    // Calculer les points des habitudes par catégorie
    for (final habit in habits) {
      final category = habit.category ?? 'Sans catégorie';
      categoryPoints[category] = (categoryPoints[category] ?? 0) + habitPoints;
    }
    
    // Calculer les points des tâches par catégorie
    for (final task in tasks) {
      if (task.isCompleted) {
        final category = task.category ?? 'Sans catégorie';
        categoryPoints[category] = (categoryPoints[category] ?? 0) + completedTaskPoints;
      }
    }
    
    return categoryPoints;
  }

  /// Calcule les points des habitudes par catégorie
  /// 
  /// [habits] : Liste des habitudes
  /// Retourne : Map avec catégorie -> points
  static Map<String, int> calculateHabitPointsByCategory(List<Habit> habits) {
    final Map<String, int> categoryPoints = {};
    
    for (final habit in habits) {
      final category = habit.category ?? 'Sans catégorie';
      categoryPoints[category] = (categoryPoints[category] ?? 0) + habitPoints;
    }
    
    return categoryPoints;
  }

  /// Calcule les points des tâches par catégorie
  /// 
  /// [tasks] : Liste des tâches
  /// Retourne : Map avec catégorie -> points
  static Map<String, int> calculateTaskPointsByCategory(List<Task> tasks) {
    final Map<String, int> categoryPoints = {};
    
    for (final task in tasks) {
      if (task.isCompleted) {
        final category = task.category ?? 'Sans catégorie';
        categoryPoints[category] = (categoryPoints[category] ?? 0) + completedTaskPoints;
      }
    }
    
    return categoryPoints;
  }

  /// Calcule le pourcentage de points obtenus par rapport au maximum possible
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Pourcentage de points obtenus (0-100)
  static int calculatePointsPercentage(List<Habit> habits, List<Task> tasks) {
    final totalPoints = calculateTotalPoints(habits, tasks);
    final maxPossiblePoints = calculateMaxPossiblePoints(habits, tasks);
    
    if (maxPossiblePoints == 0) return 0;
    
    return ((totalPoints / maxPossiblePoints) * 100).round();
  }

  /// Calcule le maximum de points possible
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Maximum de points possible
  static int calculateMaxPossiblePoints(List<Habit> habits, List<Task> tasks) {
    final habitPoints = calculateHabitPoints(habits);
    final maxTaskPoints = tasks.length * completedTaskPoints;
    
    return habitPoints + maxTaskPoints;
  }

  /// Calcule les points potentiels restants
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Points potentiels restants
  static int calculateRemainingPoints(List<Habit> habits, List<Task> tasks) {
    final maxPossiblePoints = calculateMaxPossiblePoints(habits, tasks);
    final currentPoints = calculateTotalPoints(habits, tasks);
    
    return maxPossiblePoints - currentPoints;
  }

  /// Calcule les points par jour (moyenne sur 7 jours)
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Points moyens par jour
  static double calculateAveragePointsPerDay(List<Habit> habits, List<Task> tasks) {
    if (habits.isEmpty && tasks.isEmpty) return 0.0;
    
    // Calculer les points basés sur les taux de réussite des habitudes
    double habitPointsPerDay = 0.0;
    if (habits.isNotEmpty) {
      habitPointsPerDay = habits
          .map((habit) => habit.getSuccessRate() * habitPoints)
          .fold(0.0, (a, b) => a + b);
    }
    
    // Calculer les points des tâches complétées récemment (7 derniers jours)
    final now = DateTime.now();
    final recentTaskPoints = tasks
        .where((task) => task.isCompleted && 
                        task.completedAt != null &&
                        task.completedAt!.isAfter(now.subtract(const Duration(days: 7))))
        .length * completedTaskPoints;
    
    return (habitPointsPerDay + recentTaskPoints) / 7;
  }

  /// Calcule les points de la semaine en cours
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Points de la semaine en cours
  static int calculateWeeklyPoints(List<Habit> habits, List<Task> tasks) {
    if (habits.isEmpty && tasks.isEmpty) return 0;
    
    // Points des habitudes basés sur le taux de réussite de la semaine
    int habitPointsValue = 0;
    if (habits.isNotEmpty) {
      habitPointsValue = habits
          .map((habit) => (habit.getSuccessRate() * habitPoints).round())
          .reduce((a, b) => a + b);
    }
    
    // Points des tâches complétées cette semaine
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyTaskPoints = tasks
        .where((task) => task.isCompleted && 
                        task.completedAt != null &&
                        task.completedAt!.isAfter(weekStart))
        .length * completedTaskPoints;
    
    return habitPointsValue + weeklyTaskPoints;
  }

  /// Calcule les points du mois en cours
  /// 
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des tâches
  /// Retourne : Points du mois en cours
  static int calculateMonthlyPoints(List<Habit> habits, List<Task> tasks) {
    if (habits.isEmpty && tasks.isEmpty) return 0;
    
    // Points des habitudes basés sur le taux de réussite du mois
    int habitPointsValue = 0;
    if (habits.isNotEmpty) {
      habitPointsValue = habits
          .map((habit) => (habit.getSuccessRate() * habitPoints).round())
          .reduce((a, b) => a + b);
    }
    
    // Points des tâches complétées ce mois
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthlyTaskPoints = tasks
        .where((task) => task.isCompleted && 
                        task.completedAt != null &&
                        task.completedAt!.isAfter(monthStart))
        .length * completedTaskPoints;
    
    return habitPointsValue + monthlyTaskPoints;
  }
} 
