import 'package:prioris/domain/models/core/entities/custom_list.dart';

/// Service de calcul pour les listes personnalisées
class ListCalculationService {
  /// Calcule la progression d'une liste (0.0 à 1.0)
  double calculateProgress(CustomList list) {
    if (list.items.isEmpty) return 0.0;
    return list.completedCount / list.itemCount;
  }

  /// Calcule la progression moyenne d'un ensemble de listes
  double calculateAverageProgress(List<CustomList> lists) {
    if (lists.isEmpty) return 0.0;
    final total = lists.map((l) => calculateProgress(l)).reduce((a, b) => a + b);
    return total / lists.length;
  }

  /// Calcule le nombre total d'éléments complétés dans un ensemble de listes
  int countCompletedItems(List<CustomList> lists) {
    return lists.fold(0, (sum, l) => sum + l.completedCount);
  }

  /// Calcule le nombre total d'éléments dans un ensemble de listes
  int countTotalItems(List<CustomList> lists) {
    return lists.fold(0, (sum, l) => sum + l.itemCount);
  }

  /// Retourne la liste avec la meilleure progression
  CustomList? getBestProgressList(List<CustomList> lists) {
    if (lists.isEmpty) return null;
    return lists.reduce((a, b) => calculateProgress(a) > calculateProgress(b) ? a : b);
  }

  /// Retourne la liste avec la plus faible progression
  CustomList? getWorstProgressList(List<CustomList> lists) {
    if (lists.isEmpty) return null;
    return lists.reduce((a, b) => calculateProgress(a) < calculateProgress(b) ? a : b);
  }

  /// Retourne la distribution des priorités dans une liste
  /// (Anciennement getPriorityDistribution) — le concept de priorité étant supprimé,
  /// cette méthode retourne une Map vide pour préserver la compatibilité éventuelle.
  Map<String, int> getPriorityDistribution(CustomList list) => const {};

  /// Retourne la distribution des catégories dans une liste
  Map<String, int> getCategoryDistribution(CustomList list) {
    final Map<String, int> distribution = {};
    for (final item in list.items) {
      if (item.category != null) {
        distribution[item.category!] = (distribution[item.category!] ?? 0) + 1;
      }
    }
    return distribution;
  }

  /// La notion de tags n'existe plus dans `ListItem`; méthode conservée pour compatibilité et renvoie {}.
  Map<String, int> getTagDistribution(CustomList list) => const {};
} 
