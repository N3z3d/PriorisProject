import '../../core/services/domain_service.dart';
import '../aggregates/custom_list_aggregate.dart';
import '../value_objects/list_item.dart';
import 'optimization/interfaces/optimization_strategy.dart';
import 'optimization/strategies/priority_optimization_strategy.dart';
import 'optimization/strategies/elo_optimization_strategy.dart';
import 'optimization/strategies/momentum_optimization_strategy.dart';
import 'optimization/strategies/category_optimization_strategy.dart';
import 'optimization/strategies/time_optimal_optimization_strategy.dart';
import 'optimization/strategies/smart_optimization_strategy.dart';
import 'optimization/analyzers/difficulty_analyzer.dart';
import 'optimization/analyzers/completion_pattern_analyzer.dart';
import 'optimization/analyzers/strategy_recommender.dart';
import 'optimization/analyzers/item_suggestion_engine.dart';
import 'optimization/calculators/optimization_metrics_calculator.dart';

export 'optimization/analyzers/difficulty_analyzer.dart';
export 'optimization/analyzers/completion_pattern_analyzer.dart';
export 'optimization/analyzers/item_suggestion_engine.dart';

/// Service facade pour l'optimisation des listes (applique Facade Pattern)
///
/// Ce service orchestre les services spécialisés pour fournir
/// des fonctionnalités d'optimisation de listes complètes.
///
/// SOLID COMPLIANCE:
/// - SRP: Orchestration uniquement, délègue aux services spécialisés
/// - OCP: Ouvert à l'extension via injection de nouvelles stratégies
/// - DIP: Dépend d'abstractions (OptimizationStrategy interface)
/// - ISP: Interface claire et cohésive
class ListOptimizationService extends LoggableDomainService {
  final DifficultyAnalyzer _difficultyAnalyzer;
  final CompletionPatternAnalyzer _completionAnalyzer;
  final StrategyRecommender _strategyRecommender;
  final ItemSuggestionEngine _suggestionEngine;
  final OptimizationMetricsCalculator _metricsCalculator;
  final Map<OptimizationStrategyType, OptimizationStrategy> _strategies;

  ListOptimizationService({
    DifficultyAnalyzer? difficultyAnalyzer,
    CompletionPatternAnalyzer? completionAnalyzer,
    StrategyRecommender? strategyRecommender,
    ItemSuggestionEngine? suggestionEngine,
    OptimizationMetricsCalculator? metricsCalculator,
  })  : _difficultyAnalyzer = difficultyAnalyzer ?? DifficultyAnalyzer(),
        _completionAnalyzer =
            completionAnalyzer ?? CompletionPatternAnalyzer(),
        _strategyRecommender = strategyRecommender ?? StrategyRecommender(),
        _suggestionEngine = suggestionEngine ?? ItemSuggestionEngine(),
        _metricsCalculator =
            metricsCalculator ?? OptimizationMetricsCalculator(),
        _strategies = {
          OptimizationStrategyType.priority: PriorityOptimizationStrategy(),
          OptimizationStrategyType.elo: EloOptimizationStrategy(),
          OptimizationStrategyType.momentum: MomentumOptimizationStrategy(),
          OptimizationStrategyType.category: CategoryOptimizationStrategy(),
          OptimizationStrategyType.timeOptimal:
              TimeOptimalOptimizationStrategy(),
          OptimizationStrategyType.smart: SmartOptimizationStrategy(),
        };

  @override
  String get serviceName => 'ListOptimizationService';

  /// Optimise l'ordre des éléments d'une liste selon différents critères
  OptimizationResult optimizeOrder(
    CustomListAggregate list,
    OptimizationStrategyType strategyType,
  ) {
    return executeOperation(() {
      log('Optimisation de l\'ordre pour ${list.name} avec stratégie ${strategyType.name}');

      final strategy = _strategies[strategyType]!;
      final originalOrder = list.items.toList();
      final optimizedOrder = strategy.optimize(originalOrder);
      final improvement =
          strategy.calculateImprovement(originalOrder, optimizedOrder);

      log('Optimisation terminée - Amélioration estimée: ${(improvement * 100).toStringAsFixed(1)}%');

      return OptimizationResult(
        originalOrder: originalOrder,
        optimizedOrder: optimizedOrder,
        strategy: strategyType,
        improvementScore: improvement,
        reasoning: strategy.generateReasoning(originalOrder, optimizedOrder),
        statistics: _metricsCalculator.calculateStatistics(
          originalOrder,
          optimizedOrder,
        ),
      );
    });
  }

  /// Suggère la meilleure stratégie d'optimisation pour une liste
  OptimizationStrategyType suggestStrategy(CustomListAggregate list) {
    return _strategyRecommender.suggestStrategy(list);
  }

  /// Calcule le score de difficulté optimal pour une liste
  DifficultyBalance calculateOptimalDifficulty(CustomListAggregate list) {
    return _difficultyAnalyzer.calculateOptimalDifficulty(list);
  }

  /// Suggère des éléments à ajouter pour compléter une liste
  List<ItemSuggestion> suggestItems(
    CustomListAggregate list,
    ListContext context,
  ) {
    return _suggestionEngine.suggestItems(list, context);
  }

  /// Analyse les patterns d'achèvement pour identifier les optimisations
  CompletionPatterns analyzeCompletionPatterns(CustomListAggregate list) {
    return _completionAnalyzer.analyzeCompletionPatterns(list);
  }
}

// Modèles de données

enum OptimizationStrategyType {
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
  final OptimizationStrategyType strategy;
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
