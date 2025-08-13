import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Service d'insights pour les listes personnalisées
class ListInsightsService {
  /// Génère un résumé d'insights pour une liste
  Map<String, dynamic> generateInsights(CustomList list) {
    final total = list.itemCount;
    final completed = list.completedCount;
    final progress = list.getProgress();
    final mostUsedCategory = _getMostUsed(list.items.map((i) => i.category).whereType<String>().toList());
    final oldestItem = list.items.isEmpty ? null : _getOldestItem(list.items);
    final newestItem = list.items.isEmpty ? null : _getNewestItem(list.items);

    return {
      'totalItems': total,
      'completedItems': completed,
      'progress': progress,
      'mostUsedCategory': mostUsedCategory,
      'oldestItem': oldestItem,
      'newestItem': newestItem,
    };
  }

  /// Génère des recommandations d'action pour améliorer la complétion
  List<String> generateRecommendations(CustomList list) {
    final recs = <String>[];
    if (list.items.isEmpty) {
      recs.add("Ajoutez des éléments à votre liste pour commencer.");
      return recs;
    }
    if (list.getProgress() < 0.3) {
      recs.add("Essayez de compléter quelques éléments pour progresser.");
    } else if (list.getProgress() < 0.7) {
      recs.add("Bonne progression ! Continuez à compléter vos éléments.");
    } else if (list.getProgress() < 1.0) {
      recs.add("Vous êtes proche de la complétion totale, bravo !");
    } else {
      recs.add("Félicitations, vous avez complété toute la liste !");
    }
    
    // Recommandations basées sur les scores ELO élevés (tâches importantes)
    final highEloItems = list.items.where((i) => i.eloScore > 1600.0 && !i.isCompleted);
    if (highEloItems.isNotEmpty) {
      recs.add("Traitez en priorité les éléments avec un score ELO élevé (> 1600).");
    }
    
    // Recommandations basées sur les dates d'échéance
    final now = DateTime.now();
    final overdueTasks = list.items.where((i) => 
        !i.isCompleted && 
        i.dueDate != null && 
        i.dueDate!.isBefore(now));
    if (overdueTasks.isNotEmpty) {
      recs.add("Attention : ${overdueTasks.length} élément(s) en retard à traiter !");
    }
    
    return recs;
  }

  /// Génère un insight sur la répartition des scores ELO
  String getEloScoreInsight(CustomList list) {
    final total = list.itemCount;
    if (total == 0) return "Aucune donnée de score ELO.";
    
    final urgent = list.items.where((i) => i.eloScore >= 1700.0).length;
    final important = list.items.where((i) => i.eloScore >= 1500.0 && i.eloScore < 1700.0).length;
    final normal = list.items.where((i) => i.eloScore >= 1300.0 && i.eloScore < 1500.0).length;
    final low = list.items.where((i) => i.eloScore < 1300.0).length;
    
    return "Scores ELO : $urgent urgent (≥1700), $important important (1500-1699), $normal normal (1300-1499), $low faible (<1300).";
  }

  /// Génère un insight sur la répartition des catégories
  String getCategoryInsight(CustomList list) {
    final categories = _getCategories(list);
    if (categories.isEmpty) return "Aucune catégorie renseignée.";
    return "Catégories utilisées : ${categories.join(', ')}.";
  }

  /// Génère un insight sur les échéances
  String getDueDateInsight(CustomList list) {
    final now = DateTime.now();
    final withDueDate = list.items.where((i) => i.dueDate != null).length;
    final overdue = list.items.where((i) => i.dueDate != null && i.dueDate!.isBefore(now) && !i.isCompleted).length;
    final upcoming = list.items.where((i) => 
        i.dueDate != null && 
        i.dueDate!.isAfter(now) && 
        i.dueDate!.isBefore(now.add(const Duration(days: 7))) &&
        !i.isCompleted).length;
    
    if (withDueDate == 0) return "Aucune échéance définie.";
    return "Échéances : $overdue en retard, $upcoming à venir cette semaine, ${withDueDate - overdue - upcoming} autres.";
  }

  /// Obtient la liste des catégories utilisées
  List<String> _getCategories(CustomList list) {
    return list.items
        .map((i) => i.category)
        .whereType<String>()
        .toSet()
        .toList();
  }

  /// Obtient l'élément le plus ancien
  ListItem? _getOldestItem(List<ListItem> items) {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
  }

  /// Obtient l'élément le plus récent
  ListItem? _getNewestItem(List<ListItem> items) {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  /// Méthode utilitaire pour trouver la valeur la plus fréquente dans une liste
  T? _getMostUsed<T>(List<T> values) {
    if (values.isEmpty) return null;
    final counts = <T, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
} 
