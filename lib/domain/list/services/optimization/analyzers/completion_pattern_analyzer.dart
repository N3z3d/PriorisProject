import '../../../core/services/domain_service.dart';
import '../../aggregates/custom_list_aggregate.dart';
import '../../value_objects/list_item.dart';

/// Analyseur de patterns de complétion
///
/// Analyse les habitudes de complétion de l'utilisateur pour identifier
/// les optimisations possibles et prédire les prochaines tâches susceptibles
/// d'être complétées.
///
/// SOLID:
/// - SRP: Responsabilité unique d'analyse des patterns de complétion
/// - OCP: Extensible via héritage sans modification
/// - DIP: Dépend de l'abstraction LoggableDomainService
class CompletionPatternAnalyzer extends LoggableDomainService {
  @override
  String get serviceName => 'CompletionPatternAnalyzer';

  /// Analyse les patterns d'achèvement pour identifier les optimisations
  CompletionPatterns analyzeCompletionPatterns(CustomListAggregate list) {
    return executeOperation(() {
      log('Analyse des patterns d\'achèvement pour ${list.name}');

      final completedItems = list.getCompletedItems();
      final incompleteItems = list.getIncompleteItems();

      if (completedItems.isEmpty) {
        return CompletionPatterns.empty();
      }

      // Analyser les caractéristiques des éléments complétés
      final completedByCategory = <String, int>{};
      final completedElos = <double>[];

      for (final item in completedItems) {
        if (item.category != null) {
          completedByCategory[item.category!] =
              (completedByCategory[item.category!] ?? 0) + 1;
        }
        completedElos.add(item.eloScore.value);
      }

      // Identifier les patterns
      final preferredCategories = completedByCategory.entries
          .where((entry) => entry.value >= 2)
          .map((entry) => entry.key)
          .toList()
        ..sort((a, b) =>
            completedByCategory[b]!.compareTo(completedByCategory[a]!));

      final averageCompletedElo = completedElos.isEmpty
          ? 0.0
          : completedElos.reduce((a, b) => a + b) / completedElos.length;

      // Analyser la vitesse de complétion
      final completionTimes = completedItems
          .where((item) => item.completionTime != null)
          .map((item) => item.completionTime!.inMinutes)
          .toList();

      final averageCompletionTime = completionTimes.isEmpty
          ? Duration.zero
          : Duration(
              minutes:
                  completionTimes.reduce((a, b) => a + b) ~/
                      completionTimes.length);

      // Prédire les prochains éléments susceptibles d'être complétés
      final nextCandidates = incompleteItems
          .where((item) =>
              item.eloScore.value <= averageCompletedElo + 100 ||
              (item.category != null &&
                  preferredCategories.contains(item.category)))
          .take(3)
          .toList();

      log('Patterns identifiés - Catégories préférées: ${preferredCategories.join(", ")}');

      return CompletionPatterns(
        preferredCategories: preferredCategories,
        averageEloCompleted: averageCompletedElo,
        averageCompletionTime: averageCompletionTime,
        nextLikelyCandidates: nextCandidates,
        completionVelocity: _calculateCompletionVelocity(list),
        stuckItems: _identifyStuckItems(incompleteItems),
      );
    });
  }

  /// Calcule la vélocité de complétion (éléments par jour sur 7 jours)
  double _calculateCompletionVelocity(CustomListAggregate list) {
    final completedItems = list.getCompletedItems();
    if (completedItems.isEmpty) return 0.0;

    final now = DateTime.now();
    final recentCompletions = completedItems
        .where((item) =>
            item.completedAt != null &&
            now.difference(item.completedAt!).inDays <= 7)
        .length;

    return recentCompletions / 7.0; // Éléments par jour
  }

  /// Identifie les éléments bloqués (non complétés depuis > 14 jours)
  List<ListItem> _identifyStuckItems(List<ListItem> incompleteItems) {
    final now = DateTime.now();
    return incompleteItems
        .where((item) =>
            now.difference(item.createdAt).inDays > 14) // Plus de 2 semaines
        .toList();
  }
}

/// Patterns de complétion d'une liste
class CompletionPatterns {
  final List<String> preferredCategories;
  final double averageEloCompleted;
  final Duration averageCompletionTime;
  final List<ListItem> nextLikelyCandidates;
  final double completionVelocity;
  final List<ListItem> stuckItems;

  const CompletionPatterns({
    required this.preferredCategories,
    required this.averageEloCompleted,
    required this.averageCompletionTime,
    required this.nextLikelyCandidates,
    required this.completionVelocity,
    required this.stuckItems,
  });

  factory CompletionPatterns.empty() {
    return const CompletionPatterns(
      preferredCategories: [],
      averageEloCompleted: 0.0,
      averageCompletionTime: Duration.zero,
      nextLikelyCandidates: [],
      completionVelocity: 0.0,
      stuckItems: [],
    );
  }
}
