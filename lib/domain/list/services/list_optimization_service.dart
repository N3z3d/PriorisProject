import 'dart:math' as math;
import '../../core/services/domain_service.dart';
import '../aggregates/custom_list_aggregate.dart';
import '../value_objects/list_item.dart';

/// Service du domaine pour l'optimisation des listes
/// 
/// Ce service fournit des algorithmes d'optimisation pour organiser
/// les éléments de liste de manière efficace et améliorer la productivité.
class ListOptimizationService extends LoggableDomainService {
  
  @override
  String get serviceName => 'ListOptimizationService';

  /// Optimise l'ordre des éléments d'une liste selon différents critères
  OptimizationResult optimizeOrder(
    CustomListAggregate list,
    OptimizationStrategy strategy,
  ) {
    return executeOperation(() {
      log('Optimisation de l\'ordre pour ${list.name} avec stratégie ${strategy.name}');
      
      final originalOrder = list.items.toList();
      final optimizedOrder = <ListItem>[];
      
      switch (strategy) {
        case OptimizationStrategy.priority:
          optimizedOrder.addAll(_optimizeByPriority(originalOrder));
          break;
        case OptimizationStrategy.elo:
          optimizedOrder.addAll(_optimizeByElo(originalOrder));
          break;
        case OptimizationStrategy.smart:
          optimizedOrder.addAll(_optimizeBySmartAlgorithm(originalOrder));
          break;
        case OptimizationStrategy.timeOptimal:
          optimizedOrder.addAll(_optimizeByTimeEstimate(originalOrder));
          break;
        case OptimizationStrategy.category:
          optimizedOrder.addAll(_optimizeByCategory(originalOrder));
          break;
        case OptimizationStrategy.momentum:
          optimizedOrder.addAll(_optimizeByMomentum(originalOrder));
          break;
      }
      
      final improvement = _calculateImprovement(originalOrder, optimizedOrder, strategy);
      
      log('Optimisation terminée - Amélioration estimée: ${(improvement * 100).toStringAsFixed(1)}%');
      
      return OptimizationResult(
        originalOrder: originalOrder,
        optimizedOrder: optimizedOrder,
        strategy: strategy,
        improvementScore: improvement,
        reasoning: _generateReasoning(strategy, originalOrder, optimizedOrder),
        statistics: _calculateStatistics(originalOrder, optimizedOrder),
      );
    });
  }

  /// Suggère la meilleure stratégie d'optimisation pour une liste
  OptimizationStrategy suggestStrategy(CustomListAggregate list) {
    return executeOperation(() {
      log('Analyse de la liste ${list.name} pour suggérer une stratégie');
      
      final items = list.items;
      if (items.isEmpty) {
        return OptimizationStrategy.priority;
      }
      
      // Analyser les caractéristiques de la liste
      final hasCategories = items.any((item) => item.category != null);
      final eloVariance = _calculateEloVariance(items);
      final progressRate = list.progress.percentage;
      final itemCount = items.length;
      
      log('Caractéristiques - Catégories: $hasCategories, Variance ELO: ${eloVariance.toStringAsFixed(1)}, Progression: ${(progressRate * 100).toStringAsFixed(1)}%');
      
      // Logique de décision pour la stratégie
      if (itemCount <= 5) {
        return OptimizationStrategy.priority; // Simple pour petites listes
      }
      
      if (hasCategories && itemCount >= 10) {
        return OptimizationStrategy.category; // Grouper par catégorie
      }
      
      if (eloVariance > 100 && progressRate < 0.3) {
        return OptimizationStrategy.momentum; // Commencer par le plus facile
      }
      
      if (progressRate > 0.7) {
        return OptimizationStrategy.elo; // Finir par le plus important
      }
      
      return OptimizationStrategy.smart; // Algorithme intelligent par défaut
    });
  }

  /// Calcule le score de difficulté optimal pour une liste
  DifficultyBalance calculateOptimalDifficulty(CustomListAggregate list) {
    return executeOperation(() {
      log('Calcul de l\'équilibre de difficulté pour ${list.name}');
      
      final items = list.items.where((item) => !item.isCompleted).toList();
      
      if (items.isEmpty) {
        return DifficultyBalance(
          easyCount: 0,
          mediumCount: 0,
          hardCount: 0,
          balance: DifficultyBalanceType.perfect,
          recommendation: 'Liste complétée!',
        );
      }
      
      // Catégoriser les éléments par difficulté (basé sur ELO)
      final easyItems = items.where((item) => item.eloScore.value < 1200).length;
      final mediumItems = items.where((item) => 
        item.eloScore.value >= 1200 && item.eloScore.value < 1400).length;
      final hardItems = items.where((item) => item.eloScore.value >= 1400).length;
      
      // Ratios optimaux: 40% facile, 40% moyen, 20% difficile
      final totalItems = items.length;
      final optimalEasy = (totalItems * 0.4).round();
      final optimalMedium = (totalItems * 0.4).round();
      final optimalHard = (totalItems * 0.2).round();
      
      // Analyser l'équilibre actuel
      final easyDiff = (easyItems - optimalEasy).abs();
      final mediumDiff = (mediumItems - optimalMedium).abs();
      final hardDiff = (hardItems - optimalHard).abs();
      
      final totalDiff = easyDiff + mediumDiff + hardDiff;
      
      DifficultyBalanceType balanceType;
      String recommendation;
      
      if (totalDiff <= 2) {
        balanceType = DifficultyBalanceType.perfect;
        recommendation = 'Équilibre optimal maintenu!';
      } else if (easyItems > optimalEasy + 2) {
        balanceType = DifficultyBalanceType.tooEasy;
        recommendation = 'Ajouter des défis plus complexes';
      } else if (hardItems > optimalHard + 2) {
        balanceType = DifficultyBalanceType.tooHard;
        recommendation = 'Ajouter des tâches plus accessibles';
      } else {
        balanceType = DifficultyBalanceType.unbalanced;
        recommendation = 'Rééquilibrer la distribution des difficultés';
      }
      
      log('Équilibre analysé - Facile: $easyItems, Moyen: $mediumItems, Difficile: $hardItems');
      
      return DifficultyBalance(
        easyCount: easyItems,
        mediumCount: mediumItems,
        hardCount: hardItems,
        balance: balanceType,
        recommendation: recommendation,
      );
    });
  }

  /// Suggère des éléments à ajouter pour compléter une liste
  List<ItemSuggestion> suggestItems(
    CustomListAggregate list,
    ListContext context,
  ) {
    return executeOperation(() {
      log('Génération de suggestions pour ${list.name}');
      
      final suggestions = <ItemSuggestion>[];
      final existingCategories = list.getCategories();
      
      // Suggestions basées sur le type de liste
      switch (list.type) {
        case ListType.SHOPPING:
          suggestions.addAll(_generateShoppingSuggestions(list, existingCategories));
          break;
        case ListType.TODO:
          suggestions.addAll(_generateTodoSuggestions(list, context));
          break;
        case ListType.MOVIES:
          suggestions.addAll(_generateMovieSuggestions(list));
          break;
        case ListType.BOOKS:
          suggestions.addAll(_generateBookSuggestions(list));
          break;
        case ListType.GOALS:
          suggestions.addAll(_generateGoalSuggestions(list, context));
          break;
        default:
          suggestions.addAll(_generateGenericSuggestions(list, context));
      }
      
      // Filtrer et scorer les suggestions
      final scoredSuggestions = suggestions
        .map((suggestion) => _scoreSuggestion(suggestion, list, context))
        .where((suggestion) => suggestion.relevanceScore > 0.3)
        .toList()
        ..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      
      log('${scoredSuggestions.length} suggestions générées');
      
      return scoredSuggestions.take(10).toList(); // Limiter à 10 suggestions
    });
  }

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
        ..sort((a, b) => completedByCategory[b]!.compareTo(completedByCategory[a]!));
      
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
        : Duration(minutes: completionTimes.reduce((a, b) => a + b) ~/ completionTimes.length);
      
      // Prédire les prochains éléments susceptibles d'être complétés
      final nextCandidates = incompleteItems
        .where((item) => 
          item.eloScore.value <= averageCompletedElo + 100 ||
          (item.category != null && preferredCategories.contains(item.category))
        )
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

  List<ListItem> _optimizeByPriority(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();
    
    incomplete.sort((a, b) => a.priority.compareTo(b.priority));
    
    return [...incomplete, ...completed];
  }

  List<ListItem> _optimizeByElo(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();
    
    incomplete.sort((a, b) => b.eloScore.value.compareTo(a.eloScore.value));
    
    return [...incomplete, ...completed];
  }

  List<ListItem> _optimizeBySmartAlgorithm(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();
    
    // Algorithme intelligent combinant priorité, ELO et âge
    incomplete.sort((a, b) {
      // Score composite
      final scoreA = _calculateSmartScore(a);
      final scoreB = _calculateSmartScore(b);
      return scoreB.compareTo(scoreA);
    });
    
    return [...incomplete, ...completed];
  }

  double _calculateSmartScore(ListItem item) {
    // Normaliser les valeurs entre 0 et 1
    final priorityScore = item.priority.score / 2.0; // Priority max ~2.0
    final eloScore = (item.eloScore.value - 800) / 1600; // ELO 800-2400 -> 0-1
    final ageScore = math.min(item.age.inDays / 30, 1.0); // Age max 30 jours
    
    // Pondération: 50% priorité, 30% ELO, 20% âge
    return (priorityScore * 0.5) + (eloScore * 0.3) + (ageScore * 0.2);
  }

  List<ListItem> _optimizeByTimeEstimate(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();
    
    // Estimer le temps basé sur l'ELO (plus haut = plus long)
    incomplete.sort((a, b) {
      final timeA = _estimateTime(a);
      final timeB = _estimateTime(b);
      return timeA.compareTo(timeB); // Plus court d'abord
    });
    
    return [...incomplete, ...completed];
  }

  Duration _estimateTime(ListItem item) {
    // Estimation basique basée sur l'ELO
    final baseMinutes = 10 + ((item.eloScore.value - 1000) / 100 * 5).round();
    return Duration(minutes: math.max(5, baseMinutes));
  }

  List<ListItem> _optimizeByCategory(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();
    
    // Grouper par catégorie, puis par priorité
    incomplete.sort((a, b) {
      final categoryCompare = (a.category ?? '').compareTo(b.category ?? '');
      if (categoryCompare != 0) return categoryCompare;
      return a.priority.compareTo(b.priority);
    });
    
    return [...incomplete, ...completed];
  }

  List<ListItem> _optimizeByMomentum(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();
    
    // Commencer par les plus faciles pour créer de l'élan
    incomplete.sort((a, b) => a.eloScore.value.compareTo(b.eloScore.value));
    
    return [...incomplete, ...completed];
  }

  double _calculateImprovement(List<ListItem> original, List<ListItem> optimized, OptimizationStrategy strategy) {
    // Calcul simplifié d'amélioration
    switch (strategy) {
      case OptimizationStrategy.priority:
        return _calculatePriorityImprovement(original, optimized);
      case OptimizationStrategy.momentum:
        return _calculateMomentumImprovement(optimized);
      default:
        return 0.15; // Amélioration générique estimée à 15%
    }
  }

  double _calculatePriorityImprovement(List<ListItem> original, List<ListItem> optimized) {
    // Calculer l'amélioration basée sur l'ordre des priorités
    double originalScore = 0;
    double optimizedScore = 0;
    
    for (int i = 0; i < original.length; i++) {
      final positionWeight = 1.0 - (i / original.length); // Plus haut = plus important
      originalScore += original[i].priority.score * positionWeight;
      if (i < optimized.length) {
        optimizedScore += optimized[i].priority.score * positionWeight;
      }
    }
    
    return originalScore > 0 ? (optimizedScore - originalScore) / originalScore : 0.0;
  }

  double _calculateMomentumImprovement(List<ListItem> optimized) {
    // L'amélioration du momentum est basée sur la facilité des premiers éléments
    final firstThird = optimized.take(optimized.length ~/ 3);
    final averageElo = firstThird.isEmpty 
      ? 1200 
      : firstThird.map((item) => item.eloScore.value).reduce((a, b) => a + b) / firstThird.length;
    
    // Plus les premiers éléments sont faciles, plus l'amélioration est grande
    return math.max(0.0, (1400 - averageElo) / 1400 * 0.3); // Max 30% d'amélioration
  }

  String _generateReasoning(OptimizationStrategy strategy, List<ListItem> original, List<ListItem> optimized) {
    switch (strategy) {
      case OptimizationStrategy.priority:
        return 'Éléments réorganisés par ordre de priorité décroissante pour maximiser l\'impact.';
      case OptimizationStrategy.elo:
        return 'Éléments triés par score ELO pour traiter d\'abord les plus importants.';
      case OptimizationStrategy.smart:
        return 'Optimisation intelligente combinant priorité, importance et âge des éléments.';
      case OptimizationStrategy.momentum:
        return 'Éléments faciles en premier pour créer de l\'élan et maintenir la motivation.';
      case OptimizationStrategy.category:
        return 'Regroupement par catégorie pour minimiser les changements de contexte.';
      case OptimizationStrategy.timeOptimal:
        return 'Optimisation temporelle : éléments courts d\'abord pour maximiser le nombre de complétions.';
    }
  }

  Map<String, dynamic> _calculateStatistics(List<ListItem> original, List<ListItem> optimized) {
    return {
      'totalItems': original.length,
      'incompleteItems': original.where((item) => !item.isCompleted).length,
      'averageElo': original.isEmpty ? 0 : original.map((item) => item.eloScore.value).reduce((a, b) => a + b) / original.length,
      'categoriesCount': original.map((item) => item.category).where((cat) => cat != null).toSet().length,
    };
  }

  double _calculateEloVariance(List<ListItem> items) {
    if (items.length < 2) return 0.0;
    
    final eloValues = items.map((item) => item.eloScore.value).toList();
    final average = eloValues.reduce((a, b) => a + b) / eloValues.length;
    final variance = eloValues.map((elo) => math.pow(elo - average, 2)).reduce((a, b) => a + b) / eloValues.length;
    
    return variance;
  }

  List<ItemSuggestion> _generateShoppingSuggestions(CustomListAggregate list, Set<String> categories) {
    // Suggestions basiques pour liste de courses
    return [
      ItemSuggestion('Fruits et légumes', 'Alimentation', 1100, 0.8, 'Catégorie essentielle manquante'),
      ItemSuggestion('Produits laitiers', 'Alimentation', 1050, 0.7, 'Compléter les produits de base'),
    ];
  }

  List<ItemSuggestion> _generateTodoSuggestions(CustomListAggregate list, ListContext context) {
    return [
      ItemSuggestion('Réviser les objectifs', 'Organisation', 1300, 0.6, 'Améliorer la planification'),
    ];
  }

  List<ItemSuggestion> _generateMovieSuggestions(CustomListAggregate list) {
    return [
      ItemSuggestion('Film recommandé', 'Divertissement', 1200, 0.5, 'Suggestion algorithmique'),
    ];
  }

  List<ItemSuggestion> _generateBookSuggestions(CustomListAggregate list) {
    return [
      ItemSuggestion('Livre de développement personnel', 'Lecture', 1250, 0.6, 'Équilibre des genres'),
    ];
  }

  List<ItemSuggestion> _generateGoalSuggestions(CustomListAggregate list, ListContext context) {
    return [
      ItemSuggestion('Objectif de santé', 'Santé', 1400, 0.7, 'Domaine de vie important'),
    ];
  }

  List<ItemSuggestion> _generateGenericSuggestions(CustomListAggregate list, ListContext context) {
    return [
      ItemSuggestion('Élément suggéré', 'Général', 1200, 0.4, 'Suggestion générique'),
    ];
  }

  ItemSuggestion _scoreSuggestion(ItemSuggestion suggestion, CustomListAggregate list, ListContext context) {
    // Pour le moment, retourner la suggestion telle quelle
    // Une implémentation plus sophistiquée analyserait le contexte
    return suggestion;
  }

  double _calculateCompletionVelocity(CustomListAggregate list) {
    final completedItems = list.getCompletedItems();
    if (completedItems.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final recentCompletions = completedItems
      .where((item) => item.completedAt != null && 
                      now.difference(item.completedAt!).inDays <= 7)
      .length;
    
    return recentCompletions / 7.0; // Éléments par jour
  }

  List<ListItem> _identifyStuckItems(List<ListItem> incompleteItems) {
    final now = DateTime.now();
    return incompleteItems
      .where((item) => now.difference(item.createdAt).inDays > 14) // Plus de 2 semaines
      .toList();
  }
}

// Modèles de données

enum OptimizationStrategy {
  priority,
  elo,
  smart,
  timeOptimal,
  category,
  momentum,
}

class OptimizationResult {
  final List<ListItem> originalOrder;
  final List<ListItem> optimizedOrder;
  final OptimizationStrategy strategy;
  final double improvementScore;
  final String reasoning;
  final Map<String, dynamic> statistics;

  const OptimizationResult({
    required this.originalOrder,
    required this.optimizedOrder,
    required this.strategy,
    required this.improvementScore,
    required this.reasoning,
    required this.statistics,
  });
}

class DifficultyBalance {
  final int easyCount;
  final int mediumCount;
  final int hardCount;
  final DifficultyBalanceType balance;
  final String recommendation;

  const DifficultyBalance({
    required this.easyCount,
    required this.mediumCount,
    required this.hardCount,
    required this.balance,
    required this.recommendation,
  });
}

enum DifficultyBalanceType {
  perfect,
  tooEasy,
  tooHard,
  unbalanced,
}

class ItemSuggestion {
  final String name;
  final String category;
  final double suggestedElo;
  final double relevanceScore;
  final String reason;

  const ItemSuggestion(
    this.name,
    this.category,
    this.suggestedElo,
    this.relevanceScore,
    this.reason,
  );
}

class ListContext {
  final String userPreferences;
  final DateTime timeOfDay;
  final Map<String, dynamic> environmentalFactors;

  const ListContext({
    required this.userPreferences,
    required this.timeOfDay,
    required this.environmentalFactors,
  });
}

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