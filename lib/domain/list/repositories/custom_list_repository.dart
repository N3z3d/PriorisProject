import '../../core/interfaces/repository.dart';
import '../../core/specifications/specification.dart';
import '../../core/value_objects/export.dart';
import '../aggregates/custom_list_aggregate.dart';
import '../value_objects/list_item.dart';

/// Repository pour les listes personnalisées dans le domaine
/// 
/// Cette interface définit les opérations de persistance spécifiques
/// aux listes. L'implémentation concrète sera dans la couche infrastructure.
abstract class CustomListRepository extends PaginatedRepository<CustomListAggregate> 
    implements SearchableRepository<CustomListAggregate> {

  /// Trouve les listes par type
  Future<List<CustomListAggregate>> findByType(ListType type);

  /// Trouve les listes complétées
  Future<List<CustomListAggregate>> findCompleted();

  /// Trouve les listes incomplètes
  Future<List<CustomListAggregate>> findIncomplete();

  /// Trouve les listes vides
  Future<List<CustomListAggregate>> findEmpty();

  /// Trouve les listes avec un pourcentage de progression dans une plage
  Future<List<CustomListAggregate>> findByProgressRange(
    double minProgress,
    double maxProgress,
  );

  /// Trouve les listes créées dans une période
  Future<List<CustomListAggregate>> findCreatedBetween(DateTime start, DateTime end);

  /// Trouve les listes modifiées dans une période
  Future<List<CustomListAggregate>> findUpdatedBetween(DateTime start, DateTime end);

  /// Trouve les listes avec un nombre d'éléments dans une plage
  Future<List<CustomListAggregate>> findByItemCountRange(int minCount, int maxCount);

  /// Trouve les listes avec un score ELO moyen dans une plage
  Future<List<CustomListAggregate>> findByAverageEloRange(
    double minElo,
    double maxElo,
  );

  /// Trouve les listes contenant une catégorie spécifique
  Future<List<CustomListAggregate>> findContainingCategory(String category);

  /// Trouve les listes récemment actives
  Future<List<CustomListAggregate>> findRecentlyActive({int days = 7});

  /// Trouve les listes stagnantes (non modifiées depuis longtemps)
  Future<List<CustomListAggregate>> findStagnant({int days = 30});

  /// Trouve les listes prioritaires
  Future<List<CustomListAggregate>> findPriorities();

  /// Trouve les listes archivables
  Future<List<CustomListAggregate>> findArchivable({int daysAfterCompletion = 30});

  /// Obtient les statistiques globales des listes
  Future<ListStatistics> getStatistics({DateRange? dateRange});

  /// Obtient la distribution des types de listes
  Future<Map<ListType, int>> getTypeDistribution();

  /// Obtient les listes les plus productives
  Future<List<CustomListAggregate>> getMostProductive({int limit = 10});

  /// Obtient les listes avec les meilleurs scores ELO moyens
  Future<List<CustomListAggregate>> getHighestEloAverages({int limit = 10});

  /// Obtient toutes les catégories utilisées dans les listes
  Future<Set<String>> getAllCategories();

  /// Obtient l'utilisation des catégories
  Future<Map<String, int>> getCategoryUsage({int limit = 10});

  /// Sauvegarde plusieurs listes en lot
  Future<void> saveAll(List<CustomListAggregate> lists);

  /// Archive les listes complétées avant une date
  Future<int> archiveCompletedBefore(DateTime date);

  /// Met à jour un élément dans toutes les listes qui le contiennent
  Future<void> updateItemAcrossLists(String itemId, ListItem newItem);

  /// Supprime un élément de toutes les listes qui le contiennent
  Future<int> removeItemFromAllLists(String itemId);

  /// Clone une liste (crée une copie avec un nouvel ID)
  Future<CustomListAggregate> cloneList(String listId, {String? newName});

  /// Fusionne deux listes en une seule
  Future<CustomListAggregate> mergeLists(String primaryListId, String secondaryListId);

  /// Divise une liste en plusieurs selon un critère
  Future<List<CustomListAggregate>> splitList(
    String listId,
    ListSplitCriteria criteria,
  );
}

/// Critères pour diviser une liste
enum ListSplitCriteria {
  byCategory,
  byEloRange,
  byCompletionStatus,
  byCreationDate,
}

/// Statistiques des listes
class ListStatistics {
  final int totalLists;
  final int completedLists;
  final int incompleteLists;
  final int emptyLists;
  final double averageProgress;
  final double averageItemCount;
  final double averageEloScore;
  final int totalItems;
  final int completedItems;
  final Map<ListType, int> listsByType;
  final Map<String, int> listsByCategory;
  final List<CustomListAggregate> mostActive;
  final List<CustomListAggregate> leastActive;
  final Duration averageListAge;
  final Map<String, double> progressByType;

  const ListStatistics({
    required this.totalLists,
    required this.completedLists,
    required this.incompleteLists,
    required this.emptyLists,
    required this.averageProgress,
    required this.averageItemCount,
    required this.averageEloScore,
    required this.totalItems,
    required this.completedItems,
    required this.listsByType,
    required this.listsByCategory,
    required this.mostActive,
    required this.leastActive,
    required this.averageListAge,
    required this.progressByType,
  });

  factory ListStatistics.empty() {
    return const ListStatistics(
      totalLists: 0,
      completedLists: 0,
      incompleteLists: 0,
      emptyLists: 0,
      averageProgress: 0.0,
      averageItemCount: 0.0,
      averageEloScore: 0.0,
      totalItems: 0,
      completedItems: 0,
      listsByType: {},
      listsByCategory: {},
      mostActive: [],
      leastActive: [],
      averageListAge: Duration.zero,
      progressByType: {},
    );
  }

  double get globalCompletionRate => 
    totalItems > 0 ? completedItems / totalItems : 0.0;
}

/// Extensions utiles pour le repository des listes
extension CustomListRepositoryExtensions on CustomListRepository {
  /// Trouve les listes à réviser (presque terminées ou stagnantes)
  Future<List<CustomListAggregate>> findForReview() async {
    final almostDone = await findByProgressRange(0.8, 0.99);
    final stagnant = await findStagnant(days: 14);
    
    // Combiner et dédupliquer
    final allLists = <String, CustomListAggregate>{};
    
    for (final list in [...almostDone, ...stagnant]) {
      allLists[list.id] = list;
    }
    
    final lists = allLists.values.toList();
    lists.sort((a, b) => b.progress.percentage.compareTo(a.progress.percentage));
    
    return lists;
  }

  /// Trouve les listes recommandées pour aujourd'hui
  Future<List<CustomListAggregate>> findRecommendedForToday() async {
    final recentlyActive = await findRecentlyActive(days: 3);
    final priorities = await findPriorities();
    
    // Scoring et tri
    final scoredLists = <MapEntry<CustomListAggregate, double>>[];
    
    for (final list in [...recentlyActive, ...priorities]) {
      if (scoredLists.any((entry) => entry.key.id == list.id)) continue;
      
      double score = 0.0;
      
      // Score basé sur la progression récente
      score += list.progress.percentage * 0.4;
      
      // Bonus pour les listes récemment modifiées
      final daysSinceUpdate = DateTime.now().difference(list.updatedAt).inDays;
      if (daysSinceUpdate <= 1) {
        score += 1.0;
      } else if (daysSinceUpdate <= 3) {
        score += 0.5;
      }
      
      // Bonus pour les listes avec quelques éléments (ni trop peu ni trop)
      final itemCount = list.items.length;
      if (itemCount >= 3 && itemCount <= 15) score += 0.3;
      
      // Malus pour les listes vides ou complètes
      if (list.isEmpty || list.isCompleted) score -= 0.5;
      
      scoredLists.add(MapEntry(list, score));
    }
    
    scoredLists.sort((a, b) => b.value.compareTo(a.value));
    
    return scoredLists.take(5).map((entry) => entry.key).toList();
  }

  /// Trouve les listes similaires à une liste donnée
  Future<List<CustomListAggregate>> findSimilar(
    CustomListAggregate referenceList, {
    int limit = 5,
  }) async {
    final all = await findAll();
    
    final similarLists = <MapEntry<CustomListAggregate, double>>[];
    
    for (final list in all) {
      if (list.id == referenceList.id) continue;
      
      double similarity = 0.0;
      
      // Similarité par type
      if (list.type == referenceList.type) similarity += 0.3;
      
      // Similarité par catégories
      final commonCategories = list.getCategories()
          .intersection(referenceList.getCategories());
      similarity += commonCategories.length * 0.2;
      
      // Similarité par taille
      final sizeDiff = (list.items.length - referenceList.items.length).abs();
      if (sizeDiff <= 3) similarity += 0.2;
      
      // Similarité par niveau ELO
      final referencEloStats = referenceList.getEloStats();
      final listEloStats = list.getEloStats();
      final eloDiff = (listEloStats['average'] - referencEloStats['average']).abs();
      if (eloDiff <= 100) similarity += 0.3;
      
      if (similarity > 0.3) { // Seuil minimum de similarité
        similarLists.add(MapEntry(list, similarity));
      }
    }
    
    similarLists.sort((a, b) => b.value.compareTo(a.value));
    
    return similarLists.take(limit).map((entry) => entry.key).toList();
  }

  /// Trouve les listes nécessitant une optimisation
  Future<List<CustomListAggregate>> findNeedingOptimization() async {
    final specification = Specifications.fromPredicate<CustomListAggregate>(
      (list) {
        // Optimisation nécessaire si :
        // - Grande liste (>20 éléments) avec progression faible
        // - Liste ancienne avec peu de progression
        // - Beaucoup d'éléments de même catégorie non groupés
        
        final hasLotsOfItems = list.items.length > 20;
        final hasLowProgress = list.progress.percentage < 0.3;
        final isOld = DateTime.now().difference(list.createdAt).inDays > 30;
        
        return (hasLotsOfItems && hasLowProgress) || 
               (isOld && hasLowProgress);
      },
      'Listes nécessitant une optimisation',
    );
    
    return await findBySpecification(specification);
  }

  /// Obtient les insights sur l'utilisation des listes
  Future<ListUsageInsights> getUsageInsights() async {
    final stats = await getStatistics();
    final all = await findAll();
    
    // Analyser les patterns d'usage
    final dailyActivity = <int, int>{}; // Jour de la semaine -> activité
    final monthlyTrends = <int, int>{}; // Mois -> nouvelles listes créées
    
    for (final list in all) {
      // Activité par jour de la semaine
      final weekday = list.updatedAt.weekday;
      dailyActivity[weekday] = (dailyActivity[weekday] ?? 0) + 1;
      
      // Tendances mensuelles
      final month = list.createdAt.month;
      monthlyTrends[month] = (monthlyTrends[month] ?? 0) + 1;
    }
    
    // Identifier les types de listes les plus/moins utilisés
    final typeUsage = stats.listsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return ListUsageInsights(
      totalProductivity: stats.globalCompletionRate,
      mostActiveDay: _findMostActiveDay(dailyActivity),
      leastActiveDay: _findLeastActiveDay(dailyActivity),
      mostPopularType: typeUsage.isNotEmpty ? typeUsage.first.key : null,
      leastPopularType: typeUsage.isNotEmpty ? typeUsage.last.key : null,
      averageListLifespan: stats.averageListAge,
      completionTrends: stats.progressByType,
      recommendations: _generateUsageRecommendations(stats, all),
    );
  }

  int _findMostActiveDay(Map<int, int> dailyActivity) {
    if (dailyActivity.isEmpty) return 1;
    final sorted = dailyActivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  int _findLeastActiveDay(Map<int, int> dailyActivity) {
    if (dailyActivity.isEmpty) return 1;
    final sorted = dailyActivity.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.first.key;
  }

  List<String> _generateUsageRecommendations(
    ListStatistics stats,
    List<CustomListAggregate> allLists,
  ) {
    final recommendations = <String>[];
    
    if (stats.emptyLists > stats.totalLists * 0.2) {
      recommendations.add('Vous avez beaucoup de listes vides. Considérez les supprimer ou les remplir.');
    }
    
    if (stats.averageProgress < 0.3) {
      recommendations.add('Votre progression moyenne est faible. Essayez de vous concentrer sur moins de listes à la fois.');
    }
    
    if (stats.incompleteLists > stats.completedLists * 2) {
      recommendations.add('Vous avez beaucoup de listes incomplètes. Priorisez et terminez les plus importantes.');
    }
    
    final largeListsCount = allLists.where((list) => list.items.length > 30).length;
    if (largeListsCount > 0) {
      recommendations.add('$largeListsCount liste(s) très longue(s) détectée(s). Considérez les diviser en sous-listes.');
    }
    
    return recommendations;
  }
}

/// Insights sur l'utilisation des listes
class ListUsageInsights {
  final double totalProductivity;
  final int mostActiveDay;
  final int leastActiveDay;
  final ListType? mostPopularType;
  final ListType? leastPopularType;
  final Duration averageListLifespan;
  final Map<String, double> completionTrends;
  final List<String> recommendations;

  const ListUsageInsights({
    required this.totalProductivity,
    required this.mostActiveDay,
    required this.leastActiveDay,
    this.mostPopularType,
    this.leastPopularType,
    required this.averageListLifespan,
    required this.completionTrends,
    required this.recommendations,
  });

  String get mostActiveDayName => _getDayName(mostActiveDay);
  String get leastActiveDayName => _getDayName(leastActiveDay);

  String _getDayName(int dayOfWeek) {
    const days = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return dayOfWeek >= 1 && dayOfWeek <= 7 ? days[dayOfWeek] : 'Inconnu';
  }
}