import 'package:prioris/domain/models/core/entities/habit.dart';

/// Service spécialisé dans les calculs liés aux habitudes
/// 
/// Ce service extrait toute la logique de calcul spécifique aux habitudes
/// du StatisticsCalculationService pour respecter le principe de
/// responsabilité unique et faciliter les tests.
class HabitCalculationService {
  /// Calcule le taux de réussite moyen des habitudes
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Pourcentage de réussite moyen (0-100)
  static int calculateSuccessRate(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    
    final totalRate = habits
        .map((habit) => habit.getSuccessRate() * 100)
        .reduce((a, b) => a + b);
    
    return (totalRate / habits.length).round();
  }

  /// Calcule la série de réussite la plus longue parmi toutes les habitudes
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Nombre de jours de la série la plus longue
  static int calculateCurrentStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    
    return habits
        .map((habit) => habit.getCurrentStreak())
        .reduce((a, b) => a > b ? a : b);
  }

  /// Calcule la moyenne d'habitudes complétées par jour
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Nombre moyen d'habitudes complétées par jour
  static double calculateAveragePerDay(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;
    
    final totalCompletions = habits
        .map((habit) => habit.getSuccessRate())
        .reduce((a, b) => a + b);
    
    return (totalCompletions / habits.length) * habits.length;
  }

  /// Calcule la performance par catégorie pour les habitudes uniquement
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Map avec catégorie -> pourcentage de réussite
  static Map<String, double> calculateCategoryPerformance(List<Habit> habits) {
    final Map<String, List<double>> categoryScores = {};
    
    // Analyser les habitudes par catégorie
    for (final habit in habits) {
      if (habit.category != null) {
        categoryScores.putIfAbsent(habit.category!, () => []);
        categoryScores[habit.category!]!.add(habit.getSuccessRate() * 100);
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

  /// Génère des insights spécifiques aux habitudes
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Liste d'insights sous forme de Map
  static List<Map<String, dynamic>> generateHabitInsights(List<Habit> habits) {
    if (habits.isEmpty) {
      return [
        {
          'type': 'info',
          'message': 'Commencez par créer vos premières habitudes pour générer des insights.',
          'icon': '🎯',
        },
      ];
    }

    final insights = <Map<String, dynamic>>[];
    _appendHabitSuccessRateInsights(habits, insights);
    _appendHabitStreakInsights(habits, insights);
    _appendHabitCategoryPerformance(habits, insights);
    _appendHabitCountSummary(habits.length, insights);

    return insights;
  }
  static void _appendHabitSuccessRateInsights(
    List<Habit> habits,
    List<Map<String, dynamic>> insights,
  ) {
    final habitSuccessRate = calculateSuccessRate(habits);
    if (habitSuccessRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Vos habitudes sont excellentes ! Taux de reussite de $habitSuccessRate%.',
        'icon': '🎯',
      });
    } else if (habitSuccessRate > 60) {
      insights.add({
        'type': 'warning',
        'message': "Vos habitudes sont bonnes ($habitSuccessRate%), mais peuvent encore s'ameliorer.",
        'icon': '📈',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la regularite pour ameliorer votre taux de $habitSuccessRate%.',
        'icon': '💡',
      });
    }
  }

  static void _appendHabitStreakInsights(
    List<Habit> habits,
    List<Map<String, dynamic>> insights,
  ) {
    final currentStreak = calculateCurrentStreak(habits);
    if (currentStreak > 7) {
      insights.add({
        'type': 'success',
        'message': 'Impressionnant ! Vous avez une serie de $currentStreak jours.',
        'icon': '🔥',
      });
    } else if (currentStreak > 3) {
      insights.add({
        'type': 'warning',
        'message': 'Bonne serie de $currentStreak jours, continuez !',
        'icon': '📊',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Commencez une nouvelle serie pour ameliorer votre productivite.',
        'icon': '💡',
      });
    }
  }

  static void _appendHabitCategoryPerformance(
    List<Habit> habits,
    List<Map<String, dynamic>> insights,
  ) {
    final categoryPerformance = calculateCategoryPerformance(habits);
    if (categoryPerformance.isEmpty) {
      return;
    }

    final bestCategory = categoryPerformance.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    insights.add({
      'type': 'success',
      'message': "Votre meilleure categorie d'habitudes est ${bestCategory.key} (${bestCategory.value.round()}%)",
      'icon': '🏆',
    });
  }

  static void _appendHabitCountSummary(
    int activeHabits,
    List<Map<String, dynamic>> insights,
  ) {
    if (activeHabits < 3) {
      insights.add({
        'type': 'info',
        'message': 'Vous avez $activeHabits habitudes actives. Ajoutez-en pour diversifier vos objectifs.',
        'icon': '🧭',
      });
    } else if (activeHabits > 10) {
      insights.add({
        'type': 'warning',
        'message': 'Vous avez $activeHabits habitudes actives. Considerez en simplifier certaines.',
        'icon': '🧹',
      });
    } else {
      insights.add({
        'type': 'success',
        'message': 'Excellent equilibre avec $activeHabits habitudes actives.',
        'icon': '✅',
      });
    }
  }



  /// Calcule le nombre d'habitudes actives
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Nombre d'habitudes actives
  static int calculateActiveHabits(List<Habit> habits) {
    return habits.length;
  }

  /// Calcule le nombre d'habitudes complétées aujourd'hui
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Nombre d'habitudes complétées aujourd'hui
  static int calculateCompletedToday(List<Habit> habits) {
    return habits.where((habit) => habit.isCompletedToday()).length;
  }

  /// Calcule le pourcentage d'habitudes complétées aujourd'hui
  /// 
  /// [habits] : Liste des habitudes à analyser
  /// Retourne : Pourcentage d'habitudes complétées aujourd'hui (0-100)
  static int calculateTodayCompletionRate(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    
    final completedToday = calculateCompletedToday(habits);
    return ((completedToday / habits.length) * 100).round();
  }
} 
