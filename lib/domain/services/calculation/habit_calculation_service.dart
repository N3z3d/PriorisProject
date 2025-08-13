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
    final habitSuccessRate = calculateSuccessRate(habits);
    if (habitSuccessRate > 80) {
      insights.add({
        'type': 'success',
        'message': 'Vos habitudes sont excellentes ! Taux de réussite de $habitSuccessRate%.',
        'icon': '🎯',
      });
    } else if (habitSuccessRate > 60) {
      insights.add({
        'type': 'warning',
        'message': 'Vos habitudes sont bonnes ($habitSuccessRate%), mais peuvent encore s\'améliorer.',
        'icon': '📈',
      });
    } else {
      insights.add({
        'type': 'info',
        'message': 'Concentrez-vous sur la régularité pour améliorer votre taux de $habitSuccessRate%.',
        'icon': '💡',
      });
    }
    
    // Insight 2 : Série de réussite
    final currentStreak = calculateCurrentStreak(habits);
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
    final categoryPerformance = calculateCategoryPerformance(habits);
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
