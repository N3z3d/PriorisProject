import '../../core/specifications/specification.dart';
import '../../core/value_objects/export.dart';
import '../aggregates/task_aggregate.dart';

/// Spécifications pour les tâches
class TaskSpecifications {
  
  /// Spécification pour les tâches complétées
  static Specification<TaskAggregate> completed() {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.isCompleted,
      'Tâche complétée',
    );
  }

  /// Spécification pour les tâches non complétées
  static Specification<TaskAggregate> incomplete() {
    return completed().not();
  }

  /// Spécification pour les tâches en retard
  static Specification<TaskAggregate> overdue() {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.isOverdue,
      'Tâche en retard',
    );
  }

  /// Spécification pour les tâches dues aujourd'hui
  static Specification<TaskAggregate> dueToday() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.dueDate != null &&
                task.dueDate!.isAfter(todayStart) &&
                task.dueDate!.isBefore(todayEnd),
      'Tâche due aujourd\'hui',
    );
  }

  /// Spécification pour les tâches dues dans une plage de dates
  static Specification<TaskAggregate> dueBetween(DateTime start, DateTime end) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.dueDate != null &&
                task.dueDate!.isAfter(start) &&
                task.dueDate!.isBefore(end),
      'Tâche due entre ${start.day}/${start.month} et ${end.day}/${end.month}',
    );
  }

  /// Spécification pour les tâches avec une catégorie spécifique
  static Specification<TaskAggregate> hasCategory(String category) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.category == category,
      'Tâche de catégorie "$category"',
    );
  }

  /// Spécification pour les tâches sans catégorie
  static Specification<TaskAggregate> hasNoCategory() {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.category == null || task.category!.isEmpty,
      'Tâche sans catégorie',
    );
  }

  /// Spécification pour les tâches avec un score ELO supérieur à une valeur
  static Specification<TaskAggregate> hasEloAbove(double minElo) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.eloScore.value >= minElo,
      'Tâche avec ELO >= $minElo',
    );
  }

  /// Spécification pour les tâches avec un score ELO inférieur à une valeur
  static Specification<TaskAggregate> hasEloBelow(double maxElo) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.eloScore.value <= maxElo,
      'Tâche avec ELO <= $maxElo',
    );
  }

  /// Spécification pour les tâches dans une plage ELO
  static Specification<TaskAggregate> hasEloInRange(double minElo, double maxElo) {
    return hasEloAbove(minElo).and(hasEloBelow(maxElo));
  }

  /// Spécification pour les tâches avec une priorité spécifique
  static Specification<TaskAggregate> hasPriority(PriorityLevel priorityLevel) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.priority.level == priorityLevel,
      'Tâche de priorité ${priorityLevel.label}',
    );
  }

  /// Spécification pour les tâches avec une priorité élevée ou critique
  static Specification<TaskAggregate> hasHighPriority() {
    return hasPriority(PriorityLevel.high).or(hasPriority(PriorityLevel.critical));
  }

  /// Spécification pour les tâches créées après une date
  static Specification<TaskAggregate> createdAfter(DateTime date) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.createdAt.isAfter(date),
      'Tâche créée après ${date.day}/${date.month}/${date.year}',
    );
  }

  /// Sp\u00E9cification pour les t\u00E2ches cr\u00E9\u00E9es dans les N derniers jours
  static Specification<TaskAggregate> createdInLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => !task.createdAt.isBefore(cutoffDate),
      'T\u00E2che cr\u00E9\u00E9e dans les $days derniers jours',
    );
  }

  /// Spécification pour les tâches complétées dans une plage de dates
  static Specification<TaskAggregate> completedBetween(DateTime start, DateTime end) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.isCompleted &&
                task.completedAt != null &&
                task.completedAt!.isAfter(start) &&
                task.completedAt!.isBefore(end),
      'Tâche complétée entre ${start.day}/${start.month} et ${end.day}/${end.month}',
    );
  }

  /// Spécification pour les tâches avec un titre contenant un texte
  static Specification<TaskAggregate> titleContains(String searchText) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.title.toLowerCase().contains(searchText.toLowerCase()),
      'Tâche contenant "$searchText" dans le titre',
    );
  }

  /// Spécification pour les tâches avec une description contenant un texte
  static Specification<TaskAggregate> descriptionContains(String searchText) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.description != null &&
                task.description!.toLowerCase().contains(searchText.toLowerCase()),
      'Tâche contenant "$searchText" dans la description',
    );
  }

  /// Spécification pour rechercher dans le titre ou la description
  static Specification<TaskAggregate> containsText(String searchText) {
    return titleContains(searchText).or(descriptionContains(searchText));
  }

  /// Spécification pour les tâches nécessitant une attention immédiate
  static Specification<TaskAggregate> requiresImmediateAttention() {
    return overdue()
        .or(dueToday())
        .or(hasHighPriority());
  }

  /// Spécification pour les tâches candidates aux duels (non complétées, ELO similaire)
  static Specification<TaskAggregate> isDuelCandidate(TaskAggregate referenceTask, {double eloTolerance = 200}) {
    final minElo = referenceTask.eloScore.value - eloTolerance;
    final maxElo = referenceTask.eloScore.value + eloTolerance;
    
    return incomplete()
        .and(hasEloInRange(minElo, maxElo))
        .and(Specifications.fromPredicate<TaskAggregate>(
          (task) => task.id != referenceTask.id,
          'Tâche différente de la référence',
        ));
  }

  /// Spécification pour les tâches archivables (complétées depuis plus de N jours)
  static Specification<TaskAggregate> archivable({int daysAfterCompletion = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysAfterCompletion));
    
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.isCompleted &&
                task.completedAt != null &&
                task.completedAt!.isBefore(cutoffDate),
      'Tâche archivable (complétée depuis plus de $daysAfterCompletion jours)',
    );
  }

  /// Spécification pour les tâches avec un score ELO dans une catégorie spécifique
  static Specification<TaskAggregate> hasEloCategory(EloCategory category) {
    return Specifications.fromPredicate<TaskAggregate>(
      (task) => task.eloScore.category == category,
      'Tâche de catégorie ELO ${category.label}',
    );
  }

  /// Spécification pour les tâches expertes (ELO élevé)
  static Specification<TaskAggregate> isExpertLevel() {
    return hasEloCategory(EloCategory.expert);
  }

  /// Spécification pour les tâches novices (ELO bas)
  static Specification<TaskAggregate> isNoviceLevel() {
    return hasEloCategory(EloCategory.novice);
  }

  /// Spécification composite pour les tâches à prioriser aujourd'hui
  static Specification<TaskAggregate> shouldPrioritizeToday() {
    return incomplete()
        .and(
          dueToday()
            .or(overdue())
            .or(hasHighPriority())
        );
  }

  /// Sp\u00E9cification pour les t\u00E2ches stagnantes (anciennes et non compl\u00E9t\u00E9es)
  static Specification<TaskAggregate> isStagnant({int daysSinceCreation = 14}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysSinceCreation));
    
    return incomplete()
        .and(Specifications.fromPredicate<TaskAggregate>(
          (task) =>
              task.createdAt.isBefore(cutoffDate) ||
              task.createdAt.isAtSameMomentAs(cutoffDate),
          'T\u00E2che cr\u00E9\u00E9e depuis plus de $daysSinceCreation jours',
        ));
  }
}
