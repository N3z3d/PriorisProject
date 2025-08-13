import '../../core/specifications/specification.dart';
import '../../core/value_objects/export.dart';
import '../aggregates/habit_aggregate.dart';

/// Spécifications pour les habitudes
class HabitSpecifications {
  
  /// Spécification pour les habitudes complétées aujourd'hui
  static Specification<HabitAggregate> completedToday() {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.isCompletedToday(),
      'Habitude complétée aujourd\'hui',
    );
  }

  /// Spécification pour les habitudes non complétées aujourd'hui
  static Specification<HabitAggregate> incompleteToday() {
    return completedToday().not();
  }

  /// Spécification pour les habitudes de type binaire
  static Specification<HabitAggregate> isBinary() {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.type == HabitType.binary,
      'Habitude binaire',
    );
  }

  /// Spécification pour les habitudes de type quantitatif
  static Specification<HabitAggregate> isQuantitative() {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.type == HabitType.quantitative,
      'Habitude quantitative',
    );
  }

  /// Spécification pour les habitudes avec une catégorie spécifique
  static Specification<HabitAggregate> hasCategory(String category) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.category == category,
      'Habitude de catégorie "$category"',
    );
  }

  /// Spécification pour les habitudes sans catégorie
  static Specification<HabitAggregate> hasNoCategory() {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.category == null || habit.category!.isEmpty,
      'Habitude sans catégorie',
    );
  }

  /// Spécification pour les habitudes avec un streak supérieur à une valeur
  static Specification<HabitAggregate> hasStreakAbove(int minStreak) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.getCurrentStreak() >= minStreak,
      'Habitude avec streak >= $minStreak',
    );
  }

  /// Spécification pour les habitudes avec un streak inférieur à une valeur
  static Specification<HabitAggregate> hasStreakBelow(int maxStreak) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.getCurrentStreak() <= maxStreak,
      'Habitude avec streak <= $maxStreak',
    );
  }

  /// Spécification pour les habitudes avec un taux de réussite supérieur à un seuil
  static Specification<HabitAggregate> hasSuccessRateAbove(double minRate, {int days = 30}) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.getSuccessRate(days: days) >= minRate,
      'Habitude avec taux de réussite >= ${(minRate * 100).toStringAsFixed(1)}% sur $days jours',
    );
  }

  /// Spécification pour les habitudes avec un taux de réussite inférieur à un seuil
  static Specification<HabitAggregate> hasSuccessRateBelow(double maxRate, {int days = 30}) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.getSuccessRate(days: days) <= maxRate,
      'Habitude avec taux de réussite <= ${(maxRate * 100).toStringAsFixed(1)}% sur $days jours',
    );
  }

  /// Spécification pour les habitudes créées après une date
  static Specification<HabitAggregate> createdAfter(DateTime date) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.createdAt.isAfter(date),
      'Habitude créée après ${date.day}/${date.month}/${date.year}',
    );
  }

  /// Spécification pour les habitudes créées dans les N derniers jours
  static Specification<HabitAggregate> createdInLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return createdAfter(cutoffDate);
  }

  /// Spécification pour les habitudes avec un nom contenant un texte
  static Specification<HabitAggregate> nameContains(String searchText) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.name.toLowerCase().contains(searchText.toLowerCase()),
      'Habitude contenant "$searchText" dans le nom',
    );
  }

  /// Spécification pour les habitudes avec une description contenant un texte
  static Specification<HabitAggregate> descriptionContains(String searchText) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.description != null &&
                  habit.description!.toLowerCase().contains(searchText.toLowerCase()),
      'Habitude contenant "$searchText" dans la description',
    );
  }

  /// Spécification pour rechercher dans le nom ou la description
  static Specification<HabitAggregate> containsText(String searchText) {
    return nameContains(searchText).or(descriptionContains(searchText));
  }

  /// Spécification pour les habitudes avec une valeur cible spécifique
  static Specification<HabitAggregate> hasTargetValue(double targetValue) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.targetValue == targetValue,
      'Habitude avec valeur cible $targetValue',
    );
  }

  /// Spécification pour les habitudes avec une valeur cible supérieure à un seuil
  static Specification<HabitAggregate> hasTargetValueAbove(double minValue) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.targetValue != null && habit.targetValue! >= minValue,
      'Habitude avec valeur cible >= $minValue',
    );
  }

  /// Spécification pour les habitudes avec une unité spécifique
  static Specification<HabitAggregate> hasUnit(String unit) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.unit == unit,
      'Habitude avec unité "$unit"',
    );
  }

  /// Spécification pour les habitudes avec un type de récurrence spécifique
  static Specification<HabitAggregate> hasRecurrenceType(RecurrenceType recurrenceType) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.recurrenceType == recurrenceType,
      'Habitude avec récurrence ${recurrenceType.name}',
    );
  }

  /// Spécification pour les habitudes quotidiennes
  static Specification<HabitAggregate> isDaily() {
    return hasRecurrenceType(RecurrenceType.dailyInterval)
        .or(hasRecurrenceType(RecurrenceType.timesPerDay));
  }

  /// Spécification pour les habitudes hebdomadaires
  static Specification<HabitAggregate> isWeekly() {
    return hasRecurrenceType(RecurrenceType.weeklyDays)
        .or(hasRecurrenceType(RecurrenceType.timesPerWeek));
  }

  /// Spécification pour les habitudes excellentes (taux de réussite élevé et streak long)
  static Specification<HabitAggregate> isExcellent({int minStreak = 7, double minSuccessRate = 0.8}) {
    return hasStreakAbove(minStreak).and(hasSuccessRateAbove(minSuccessRate));
  }

  /// Spécification pour les habitudes en difficulté (taux de réussite faible)
  static Specification<HabitAggregate> isStruggling({double maxSuccessRate = 0.5, int days = 14}) {
    return hasSuccessRateBelow(maxSuccessRate, days: days);
  }

  /// Spécification pour les habitudes nécessitant une attention
  static Specification<HabitAggregate> needsAttention() {
    return incompleteToday()
        .and(
          hasStreakAbove(2) // Avait un bon streak
            .or(hasSuccessRateAbove(0.6, days: 7)) // Ou bon taux récent
        );
  }

  /// Spécification pour les habitudes stagnantes (anciennes avec peu de progrès)
  static Specification<HabitAggregate> isStagnant({
    int daysSinceCreation = 30,
    int maxStreak = 3,
    double maxSuccessRate = 0.3,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysSinceCreation));
    
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.createdAt.isBefore(cutoffDate),
      'Habitude créée depuis plus de $daysSinceCreation jours',
    )
    .and(hasStreakBelow(maxStreak))
    .and(hasSuccessRateBelow(maxSuccessRate, days: daysSinceCreation));
  }

  /// Spécification pour les habitudes prometteuses (nouvelles avec bon début)
  static Specification<HabitAggregate> isPromising({
    int maxDaysOld = 14,
    int minStreak = 3,
    double minSuccessRate = 0.7,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxDaysOld));
    
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.createdAt.isAfter(cutoffDate),
      'Habitude créée dans les $maxDaysOld derniers jours',
    )
    .and(hasStreakAbove(minStreak))
    .and(hasSuccessRateAbove(minSuccessRate, days: maxDaysOld));
  }

  /// Spécification pour les habitudes avec milestone de streak récent
  static Specification<HabitAggregate> hasRecentMilestone({int days = 7}) {
    final streakMilestones = [3, 7, 14, 30, 100, 365];
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => streakMilestones.contains(habit.getCurrentStreak()),
      'Habitude avec milestone de streak récent',
    );
  }

  /// Spécification pour les habitudes prioritaires aujourd'hui
  static Specification<HabitAggregate> shouldPrioritizeToday() {
    return incompleteToday()
        .and(
          hasStreakAbove(1) // Maintenir le streak
            .or(hasSuccessRateAbove(0.7, days: 7)) // Ou bonne performance récente
            .or(needsAttention()) // Ou besoin d'attention
        );
  }

  /// Spécification pour les habitudes selon leur progression
  static Specification<HabitAggregate> hasProgressLevel(ProgressStatus status, {int days = 30}) {
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.calculateProgress(days: days).status == status,
      'Habitude avec progression ${status.label}',
    );
  }

  /// Spécification pour les habitudes complètement établies
  static Specification<HabitAggregate> isEstablished({int minStreak = 21, double minSuccessRate = 0.8}) {
    return hasStreakAbove(minStreak)
        .and(hasSuccessRateAbove(minSuccessRate, days: minStreak));
  }

  /// Spécification pour les habitudes candidates à l'archivage
  static Specification<HabitAggregate> isArchivable({
    int daysSinceCreation = 90,
    double maxSuccessRate = 0.2,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysSinceCreation));
    
    return Specifications.fromPredicate<HabitAggregate>(
      (habit) => habit.createdAt.isBefore(cutoffDate),
      'Habitude créée depuis plus de $daysSinceCreation jours',
    )
    .and(hasSuccessRateBelow(maxSuccessRate, days: 30))
    .and(hasStreakBelow(1));
  }
}