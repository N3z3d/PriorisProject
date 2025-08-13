import '../../core/interfaces/repository.dart';
import '../../core/specifications/specification.dart';
import '../../core/value_objects/export.dart';
import '../aggregates/habit_aggregate.dart';

/// Repository pour les habitudes dans le domaine
/// 
/// Cette interface définit les opérations de persistance spécifiques
/// aux habitudes. L'implémentation concrète sera dans la couche infrastructure.
abstract class HabitRepository extends PaginatedRepository<HabitAggregate> 
    implements SearchableRepository<HabitAggregate> {

  /// Trouve les habitudes par type
  Future<List<HabitAggregate>> findByType(HabitType type);

  /// Trouve les habitudes par catégorie
  Future<List<HabitAggregate>> findByCategory(String category);

  /// Trouve les habitudes par type de récurrence
  Future<List<HabitAggregate>> findByRecurrenceType(RecurrenceType recurrenceType);

  /// Trouve les habitudes complétées aujourd'hui
  Future<List<HabitAggregate>> findCompletedToday();

  /// Trouve les habitudes non complétées aujourd'hui
  Future<List<HabitAggregate>> findIncompleteToday();

  /// Trouve les habitudes avec un streak supérieur à un seuil
  Future<List<HabitAggregate>> findWithStreakAbove(int minStreak);

  /// Trouve les habitudes avec un taux de réussite dans une plage
  Future<List<HabitAggregate>> findBySuccessRate(
    double minRate,
    double maxRate, {
    int days = 30,
  });

  /// Trouve les habitudes créées dans une période
  Future<List<HabitAggregate>> findCreatedBetween(DateTime start, DateTime end);

  /// Trouve les habitudes qui nécessitent de l'attention
  Future<List<HabitAggregate>> findNeedingAttention();

  /// Trouve les habitudes excellentes (bon streak et taux de réussite)
  Future<List<HabitAggregate>> findExcellentHabits({
    int minStreak = 7,
    double minSuccessRate = 0.8,
  });

  /// Trouve les habitudes en difficulté
  Future<List<HabitAggregate>> findStrugglingHabits({
    double maxSuccessRate = 0.5,
    int days = 14,
  });

  /// Trouve les habitudes avec une valeur cible spécifique
  Future<List<HabitAggregate>> findByTargetValue(double targetValue);

  /// Trouve les habitudes avec une unité spécifique
  Future<List<HabitAggregate>> findByUnit(String unit);

  /// Obtient les statistiques globales des habitudes
  Future<HabitStatistics> getStatistics({DateRange? dateRange});

  /// Obtient la distribution des types d'habitudes
  Future<Map<HabitType, int>> getTypeDistribution();

  /// Obtient les catégories les plus utilisées
  Future<Map<String, int>> getCategoryUsage({int limit = 10});

  /// Obtient les habitudes avec les meilleurs streaks
  Future<List<HabitAggregate>> getTopStreaks({int limit = 10});

  /// Obtient les habitudes avec les meilleurs taux de réussite
  Future<List<HabitAggregate>> getTopSuccessRates({
    int limit = 10,
    int days = 30,
  });

  /// Sauvegarde plusieurs habitudes en lot
  Future<void> saveAll(List<HabitAggregate> habits);

  /// Archive les habitudes inactives
  Future<int> archiveInactive({
    int daysSinceCreation = 90,
    double maxSuccessRate = 0.2,
  });

  /// Met à jour les données de complétion d'une habitude
  Future<void> updateCompletion(
    String habitId,
    DateTime date,
    dynamic value,
  );

  /// Obtient l'historique de complétion d'une habitude
  Future<Map<DateTime, dynamic>> getCompletionHistory(
    String habitId, {
    DateRange? dateRange,
  });

  /// Calcule les trends de progression
  Future<Map<String, HabitTrend>> calculateTrends({
    DateRange? dateRange,
  });
}

/// Statistiques des habitudes
class HabitStatistics {
  final int totalHabits;
  final int activeHabits;
  final int completedTodayCount;
  final int incompleteToday;
  final double overallSuccessRate;
  final double averageStreak;
  final int totalCompletions;
  final Map<String, int> habitsByCategory;
  final Map<HabitType, int> habitsByType;
  final Map<RecurrenceType, int> habitsByRecurrence;
  final Map<String, double> categorySuccessRates;
  final List<HabitAggregate> topPerformers;
  final List<HabitAggregate> needingImprovement;

  const HabitStatistics({
    required this.totalHabits,
    required this.activeHabits,
    required this.completedTodayCount,
    required this.incompleteToday,
    required this.overallSuccessRate,
    required this.averageStreak,
    required this.totalCompletions,
    required this.habitsByCategory,
    required this.habitsByType,
    required this.habitsByRecurrence,
    required this.categorySuccessRates,
    required this.topPerformers,
    required this.needingImprovement,
  });

  factory HabitStatistics.empty() {
    return const HabitStatistics(
      totalHabits: 0,
      activeHabits: 0,
      completedTodayCount: 0,
      incompleteToday: 0,
      overallSuccessRate: 0.0,
      averageStreak: 0.0,
      totalCompletions: 0,
      habitsByCategory: {},
      habitsByType: {},
      habitsByRecurrence: {},
      categorySuccessRates: {},
      topPerformers: [],
      needingImprovement: [],
    );
  }
}

/// Tendance d'une habitude
class HabitTrend {
  final String habitId;
  final TrendDirection direction;
  final double changeRate;
  final int periodDays;
  final double confidence;

  const HabitTrend({
    required this.habitId,
    required this.direction,
    required this.changeRate,
    required this.periodDays,
    required this.confidence,
  });
}

enum TrendDirection {
  improving,
  declining,
  stable,
}

/// Extensions utiles pour le repository des habitudes
extension HabitRepositoryExtensions on HabitRepository {
  /// Trouve les habitudes à faire aujourd'hui
  Future<List<HabitAggregate>> findTodaysTasks() async {
    final incompleteToday = await findIncompleteToday();
    
    // Trier par priorité (streak existant + taux de réussite)
    incompleteToday.sort((a, b) {
      final priorityA = _calculateHabitPriority(a);
      final priorityB = _calculateHabitPriority(b);
      return priorityB.compareTo(priorityA);
    });
    
    return incompleteToday;
  }

  /// Trouve les habitudes pour la revue hebdomadaire
  Future<List<HabitAggregate>> findWeeklyReview() async {
    final all = await findAll();
    
    // Retourner celles qui ont eu de l'activité cette semaine
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    
    return all.where((habit) {
      final recentActivity = habit.completions.keys.any((dateKey) {
        final date = DateTime.parse('$dateKey 00:00:00');
        return date.isAfter(lastWeek);
      });
      return recentActivity;
    }).toList();
  }

  /// Trouve les habitudes prometteuses (nouvelles avec bon début)
  Future<List<HabitAggregate>> findPromisingHabits({
    int maxDaysOld = 14,
    int minStreak = 3,
    double minSuccessRate = 0.7,
  }) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxDaysOld));
    
    final specification = Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.createdAt.isAfter(cutoffDate) &&
                  habit.getCurrentStreak() >= minStreak &&
                  habit.getSuccessRate(days: maxDaysOld) >= minSuccessRate,
      'Habitudes prometteuses',
    );
    
    return await findBySpecification(specification);
  }

  /// Trouve les habitudes qui risquent d'être abandonnées
  Future<List<HabitAggregate>> findAtRiskHabits() async {
    final specification = Specifications.fromPredicate<HabitAggregate>(
      (habit) {
        final daysSinceCreation = DateTime.now().difference(habit.createdAt).inDays;
        final successRate = habit.getSuccessRate(days: 14);
        final currentStreak = habit.getCurrentStreak();
        
        // À risque si ancienne (>7 jours), faible taux de réussite (<40%) et pas de streak actuel
        return daysSinceCreation > 7 && 
               successRate < 0.4 && 
               currentStreak == 0;
      },
      'Habitudes à risque d\'abandon',
    );
    
    return await findBySpecification(specification);
  }

  /// Suggère des habitudes similaires basées sur une habitude existante
  Future<List<HabitAggregate>> findSimilarHabits(HabitAggregate referenceHabit) async {
    final all = await findAll();
    
    return all.where((habit) {
      if (habit.id == referenceHabit.id) return false;
      
      // Similaire si même catégorie ou même type ou même récurrence
      return habit.category == referenceHabit.category ||
             habit.type == referenceHabit.type ||
             habit.recurrenceType == referenceHabit.recurrenceType;
    }).take(5).toList();
  }

  /// Obtient les habitudes les plus cohérentes
  Future<List<HabitAggregate>> findMostConsistent({
    int days = 30,
    int limit = 10,
  }) async {
    final all = await findAll();
    
    // Calculer un score de cohérence pour chaque habitude
    final consistentHabits = <MapEntry<HabitAggregate, double>>[];
    
    for (final habit in all) {
      final successRate = habit.getSuccessRate(days: days);
      final streak = habit.getCurrentStreak();
      
      // Score basé sur le taux de réussite et la longueur du streak
      final consistencyScore = (successRate * 0.7) + (streak / days * 0.3);
      consistentHabits.add(MapEntry(habit, consistencyScore));
    }
    
    consistentHabits.sort((a, b) => b.value.compareTo(a.value));
    
    return consistentHabits
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  /// Obtient les recommandations pour améliorer les habitudes
  Future<Map<HabitAggregate, List<String>>> getImprovementRecommendations() async {
    final strugglingHabits = await findStrugglingHabits();
    final recommendations = <HabitAggregate, List<String>>{};
    
    for (final habit in strugglingHabits) {
      final habitRecommendations = <String>[];
      
      final successRate = habit.getSuccessRate();
      final streak = habit.getCurrentStreak();
      
      if (successRate < 0.3) {
        habitRecommendations.add('Réduire temporairement l\'objectif');
        habitRecommendations.add('Identifier et supprimer les obstacles');
      }
      
      if (streak == 0) {
        habitRecommendations.add('Recommencer avec un objectif très simple');
        habitRecommendations.add('Se concentrer uniquement sur cette habitude pendant quelques jours');
      }
      
      if (habit.type == HabitType.quantitative && 
          habit.targetValue != null && 
          habit.targetValue! > 1) {
        habitRecommendations.add('Réduire la valeur cible de moitié temporairement');
      }
      
      if (habitRecommendations.isNotEmpty) {
        recommendations[habit] = habitRecommendations;
      }
    }
    
    return recommendations;
  }

  double _calculateHabitPriority(HabitAggregate habit) {
    double priority = 0.0;
    
    // Bonus pour maintenir un streak existant
    final streak = habit.getCurrentStreak();
    if (streak > 0) {
      priority += streak * 0.1; // Plus le streak est long, plus c'est prioritaire
    }
    
    // Bonus pour un bon taux de réussite récent
    final recentSuccessRate = habit.getSuccessRate(days: 7);
    priority += recentSuccessRate * 2.0;
    
    // Malus pour les habitudes récemment créées (moins fiables)
    final age = DateTime.now().difference(habit.createdAt).inDays;
    if (age < 7) {
      priority *= 0.8;
    }
    
    return priority;
  }
}