import '../../core/services/domain_service.dart';
import '../aggregates/habit_aggregate.dart';
import 'analytics/habit_consistency_calculator.dart';
import 'analytics/habit_pattern_analyzer.dart';
import 'analytics/habit_success_predictor.dart';
import 'analytics/habit_recommendation_engine.dart';

// Re-exports pour la compatibilité
export 'analytics/habit_consistency_calculator.dart';
export 'analytics/habit_pattern_analyzer.dart';
export 'analytics/habit_success_predictor.dart';
export 'analytics/habit_recommendation_engine.dart';

/// Service de façade pour l'analyse des habitudes (Facade Pattern)
///
/// Orchestration simple des 4 services spécialisés:
/// - HabitConsistencyCalculator
/// - HabitPatternAnalyzer
/// - HabitSuccessPredictor
/// - HabitRecommendationEngine
///
/// Applique:
/// - SRP: Une seule responsabilité = orchestration
/// - Facade Pattern: Interface simple pour un sous-système complexe
/// - DIP: Dépend d'abstractions (injection de dépendances)
class HabitAnalyticsService extends LoggableDomainService {
  final HabitConsistencyCalculator _consistencyCalculator;
  final HabitPatternAnalyzer _patternAnalyzer;
  final HabitSuccessPredictor _successPredictor;
  final HabitRecommendationEngine _recommendationEngine;

  HabitAnalyticsService({
    HabitConsistencyCalculator? consistencyCalculator,
    HabitPatternAnalyzer? patternAnalyzer,
    HabitSuccessPredictor? successPredictor,
    HabitRecommendationEngine? recommendationEngine,
  })  : _consistencyCalculator = consistencyCalculator ?? HabitConsistencyCalculator(),
        _patternAnalyzer = patternAnalyzer ?? HabitPatternAnalyzer(),
        _successPredictor = successPredictor ?? HabitSuccessPredictor(),
        _recommendationEngine = recommendationEngine ?? HabitRecommendationEngine();

  @override
  String get serviceName => 'HabitAnalyticsService';

  /// Analyse la consistance d'une habitude sur une période
  ConsistencyAnalysis analyzeConsistency(
    HabitAggregate habit, {
    int days = 30,
  }) {
    return _consistencyCalculator.calculate(habit, days: days);
  }

  /// Analyse les patterns temporels d'une habitude
  PatternAnalysis analyzePatterns(
    HabitAggregate habit, {
    int days = 60,
  }) {
    return _patternAnalyzer.analyze(habit, days: days);
  }

  /// Prédit la probabilité de succès pour les prochains jours
  SuccessPrediction predictSuccess(
    HabitAggregate habit, {
    int predictionDays = 7,
    int analysisWindow = 30,
  }) {
    return _successPredictor.predict(
      habit,
      predictionDays: predictionDays,
      analysisWindow: analysisWindow,
    );
  }

  /// Génère des recommandations personnalisées pour améliorer l'habitude
  List<HabitRecommendation> generateRecommendations(
    HabitAggregate habit, {
    int analysisWindow = 30,
  }) {
    return _recommendationEngine.generate(habit, analysisWindow: analysisWindow);
  }
}
