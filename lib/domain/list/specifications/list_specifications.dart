import '../../core/specifications/specification.dart';
import '../../core/value_objects/export.dart';
import '../aggregates/custom_list_aggregate.dart';
import '../value_objects/list_item.dart';

/// Spécifications pour les listes
class ListSpecifications {
  
  /// Spécification pour les listes complétées
  static Specification<CustomListAggregate> isCompleted() {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.isCompleted,
      'Liste complétée',
    );
  }

  /// Spécification pour les listes non complétées
  static Specification<CustomListAggregate> isIncomplete() {
    return isCompleted().not();
  }

  /// Spécification pour les listes vides
  static Specification<CustomListAggregate> isEmpty() {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.isEmpty,
      'Liste vide',
    );
  }

  /// Spécification pour les listes non vides
  static Specification<CustomListAggregate> isNotEmpty() {
    return isEmpty().not();
  }

  /// Spécification pour les listes avec un type spécifique
  static Specification<CustomListAggregate> hasType(ListType type) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.type == type,
      'Liste de type ${type.name}',
    );
  }

  /// Spécification pour les listes personnalisées
  static Specification<CustomListAggregate> isCustomType() {
    return hasType(ListType.CUSTOM);
  }

  /// Spécification pour les listes de courses
  static Specification<CustomListAggregate> isShoppingList() {
    return hasType(ListType.SHOPPING);
  }

  /// Spécification pour les listes TODO
  static Specification<CustomListAggregate> isTodoList() {
    return hasType(ListType.TODO);
  }

  /// Spécification pour les listes avec un nombre d'éléments supérieur à un seuil
  static Specification<CustomListAggregate> hasItemCountAbove(int minCount) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.items.length >= minCount,
      'Liste avec au moins $minCount éléments',
    );
  }

  /// Spécification pour les listes avec un nombre d'éléments inférieur à un seuil
  static Specification<CustomListAggregate> hasItemCountBelow(int maxCount) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.items.length <= maxCount,
      'Liste avec au maximum $maxCount éléments',
    );
  }

  /// Spécification pour les listes avec un nombre d'éléments dans une plage
  static Specification<CustomListAggregate> hasItemCountBetween(int minCount, int maxCount) {
    return hasItemCountAbove(minCount).and(hasItemCountBelow(maxCount));
  }

  /// Spécification pour les listes avec un pourcentage de progression supérieur à un seuil
  static Specification<CustomListAggregate> hasProgressAbove(double minProgress) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.progress.percentage >= minProgress,
      'Liste avec progression >= ${(minProgress * 100).toStringAsFixed(1)}%',
    );
  }

  /// Spécification pour les listes avec un pourcentage de progression inférieur à un seuil
  static Specification<CustomListAggregate> hasProgressBelow(double maxProgress) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.progress.percentage <= maxProgress,
      'Liste avec progression <= ${(maxProgress * 100).toStringAsFixed(1)}%',
    );
  }

  /// Spécification pour les listes créées après une date
  static Specification<CustomListAggregate> createdAfter(DateTime date) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.createdAt.isAfter(date),
      'Liste créée après ${date.day}/${date.month}/${date.year}',
    );
  }

  /// Spécification pour les listes modifiées après une date
  static Specification<CustomListAggregate> updatedAfter(DateTime date) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.updatedAt.isAfter(date),
      'Liste modifiée après ${date.day}/${date.month}/${date.year}',
    );
  }

  /// Spécification pour les listes créées dans les N derniers jours
  static Specification<CustomListAggregate> createdInLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return createdAfter(cutoffDate);
  }

  /// Spécification pour les listes modifiées dans les N derniers jours
  static Specification<CustomListAggregate> updatedInLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return updatedAfter(cutoffDate);
  }

  /// Spécification pour les listes avec un nom contenant un texte
  static Specification<CustomListAggregate> nameContains(String searchText) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.name.toLowerCase().contains(searchText.toLowerCase()),
      'Liste contenant "$searchText" dans le nom',
    );
  }

  /// Spécification pour les listes avec une description contenant un texte
  static Specification<CustomListAggregate> descriptionContains(String searchText) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.description != null &&
                list.description!.toLowerCase().contains(searchText.toLowerCase()),
      'Liste contenant "$searchText" dans la description',
    );
  }

  /// Spécification pour rechercher dans le nom ou la description
  static Specification<CustomListAggregate> containsText(String searchText) {
    return nameContains(searchText).or(descriptionContains(searchText));
  }

  /// Spécification pour les listes avec un score ELO moyen supérieur à un seuil
  static Specification<CustomListAggregate> hasAverageEloAbove(double minElo) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.getEloStats()['average'] >= minElo,
      'Liste avec ELO moyen >= $minElo',
    );
  }

  /// Spécification pour les listes avec un score ELO moyen inférieur à un seuil
  static Specification<CustomListAggregate> hasAverageEloBelow(double maxElo) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.getEloStats()['average'] <= maxElo,
      'Liste avec ELO moyen <= $maxElo',
    );
  }

  /// Spécification pour les listes contenant une catégorie spécifique
  static Specification<CustomListAggregate> containsCategory(String category) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.getCategories().contains(category),
      'Liste contenant la catégorie "$category"',
    );
  }

  /// Spécification pour les listes avec plusieurs catégories
  static Specification<CustomListAggregate> hasMultipleCategories() {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.getCategories().length > 1,
      'Liste avec plusieurs catégories',
    );
  }

  /// Spécification pour les listes avec un statut de progression spécifique
  static Specification<CustomListAggregate> hasProgressStatus(ProgressStatus status) {
    return Specifications.fromPredicate<CustomListAggregate>(
      (list) => list.progress.status == status,
      'Liste avec statut de progression ${status.label}',
    );
  }

  /// Spécification pour les listes à mi-parcours
  static Specification<CustomListAggregate> isHalfway() {
    return hasProgressStatus(ProgressStatus.halfWay);
  }

  /// Spécification pour les listes presque terminées
  static Specification<CustomListAggregate> isAlmostDone() {
    return hasProgressStatus(ProgressStatus.almostDone);
  }

  /// Spécification pour les listes non commencées
  static Specification<CustomListAggregate> isNotStarted() {
    return hasProgressStatus(ProgressStatus.notStarted);
  }

  /// Spécification pour les listes en cours
  static Specification<CustomListAggregate> isInProgress() {
    return hasProgressStatus(ProgressStatus.inProgress)
        .or(isHalfway())
        .or(isAlmostDone());
  }

  /// Spécification pour les listes prioritaires (récentes, non complétées, en cours)
  static Specification<CustomListAggregate> isPriority() {
    return isIncomplete()
        .and(isNotEmpty())
        .and(
          updatedInLastDays(7) // Récemment modifiée
            .or(hasProgressAbove(0.1)) // Avec un peu de progrès
        );
  }

  /// Spécification pour les listes stagnantes (anciennes sans progression)
  static Specification<CustomListAggregate> isStagnant({int daysSinceUpdate = 14}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysSinceUpdate));
    
    return isIncomplete()
        .and(isNotEmpty())
        .and(Specifications.fromPredicate<CustomListAggregate>(
          (list) => list.updatedAt.isBefore(cutoffDate),
          'Liste non modifiée depuis $daysSinceUpdate jours',
        ))
        .and(hasProgressBelow(0.5)); // Progression faible
  }

  /// Spécification pour les listes à archiver
  static Specification<CustomListAggregate> isArchivable({int daysAfterCompletion = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysAfterCompletion));
    
    return isCompleted()
        .and(Specifications.fromPredicate<CustomListAggregate>(
          (list) => list.updatedAt.isBefore(cutoffDate),
          'Liste complétée depuis plus de $daysAfterCompletion jours',
        ));
  }

  /// Spécification pour les listes de performance élevée (ELO moyen élevé)
  static Specification<CustomListAggregate> isHighPerformance({double minAverageElo = 1400}) {
    return hasAverageEloAbove(minAverageElo).and(isNotEmpty());
  }

  /// Spécification pour les listes de performance faible (ELO moyen faible)
  static Specification<CustomListAggregate> isLowPerformance({double maxAverageElo = 1000}) {
    return hasAverageEloBelow(maxAverageElo).and(isNotEmpty());
  }

  /// Spécification pour les listes nécessitant de l'attention
  static Specification<CustomListAggregate> needsAttention() {
    return isPriority()
        .or(isStagnant())
        .or(isAlmostDone()); // Presque finie, à terminer
  }

  /// Spécification pour les listes de taille optimale (ni trop courtes ni trop longues)
  static Specification<CustomListAggregate> hasOptimalSize({int minItems = 3, int maxItems = 20}) {
    return hasItemCountBetween(minItems, maxItems);
  }

  /// Spécification pour les grandes listes
  static Specification<CustomListAggregate> isLarge({int minItems = 50}) {
    return hasItemCountAbove(minItems);
  }

  /// Spécification pour les petites listes
  static Specification<CustomListAggregate> isSmall({int maxItems = 5}) {
    return hasItemCountBelow(maxItems).and(isNotEmpty());
  }
}

/// Spécifications pour les éléments de liste
class ListItemSpecifications {
  
  /// Spécification pour les éléments complétés
  static Specification<ListItem> isCompleted() {
    return Specifications.fromPredicate<ListItem>(
      (item) => item.isCompleted,
      'Élément complété',
    );
  }

  /// Spécification pour les éléments non complétés
  static Specification<ListItem> isIncomplete() {
    return isCompleted().not();
  }

  /// Spécification pour les éléments avec un score ELO supérieur à une valeur
  static Specification<ListItem> hasEloAbove(double minElo) {
    return Specifications.fromPredicate<ListItem>(
      (item) => item.eloScore.value >= minElo,
      'Élément avec ELO >= $minElo',
    );
  }

  /// Spécification pour les éléments avec une catégorie spécifique
  static Specification<ListItem> hasCategory(String category) {
    return Specifications.fromPredicate<ListItem>(
      (item) => item.category == category,
      'Élément de catégorie "$category"',
    );
  }

  /// Spécification pour les éléments sans catégorie
  static Specification<ListItem> hasNoCategory() {
    return Specifications.fromPredicate<ListItem>(
      (item) => item.category == null || item.category!.isEmpty,
      'Élément sans catégorie',
    );
  }

  /// Spécification pour les éléments créés dans les N derniers jours
  static Specification<ListItem> createdInLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return Specifications.fromPredicate<ListItem>(
      (item) => item.createdAt.isAfter(cutoffDate),
      'Élément créé dans les $days derniers jours',
    );
  }

  /// Spécification pour les éléments prioritaires (ELO élevé, non complétés)
  static Specification<ListItem> isPriority({double minElo = 1300}) {
    return isIncomplete().and(hasEloAbove(minElo));
  }

  /// Spécification pour les éléments avec un nom contenant un texte
  static Specification<ListItem> nameContains(String searchText) {
    return Specifications.fromPredicate<ListItem>(
      (item) => item.name.toLowerCase().contains(searchText.toLowerCase()),
      'Élément contenant "$searchText" dans le nom',
    );
  }
}