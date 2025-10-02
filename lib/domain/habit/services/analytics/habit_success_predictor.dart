import 'dart:math' as math;
import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';
import 'habit_consistency_calculator.dart';
import 'habit_pattern_analyzer.dart';
import 'habit_recommendation_engine.dart';

/// Service spécialisé pour la prédiction de succès des habitudes
/// Applique SRP - Une seule responsabilité: prédire le succès
class HabitSuccessPredictor extends LoggableDomainService {
  final HabitConsistencyCalculator _consistencyCalculator;
  final HabitPatternAnalyzer _patternAnalyzer;

  HabitSuccessPredictor({
    HabitConsistencyCalculator? consistencyCalculator,
    HabitPatternAnalyzer? patternAnalyzer,
  })  : _consistencyCalculator = consistencyCalculator ?? HabitConsistencyCalculator(),
        _patternAnalyzer = patternAnalyzer ?? HabitPatternAnalyzer();

  @override
  String get serviceName => 'HabitSuccessPredictor';

  /// Prédit la probabilité de succès pour les prochains jours
  SuccessPrediction predict(
    HabitAggregate habit, {
    int predictionDays = 7,
    int analysisWindow = 30,
  }) {
    return executeOperation(() {
      log('Prédiction de succès pour ${habit.name} sur $predictionDays jours');

      final consistency = _consistencyCalculator.calculate(habit, days: analysisWindow);
      final patterns = _patternAnalyzer.analyze(habit, days: analysisWindow);

      // Facteurs influençant la prédiction
      final consistencyFactor = consistency.completionRate;
      final streakFactor = math.min(habit.getCurrentStreak() / 21, 1.0); // Plafond à 21 jours
      final patternFactor = _calculatePatternStrength(patterns);
      final decayFactor = _calculateDecayFactor(habit, analysisWindow);

      // Calcul de la probabilité composite
      final baseProbability = (consistencyFactor * 0.4) +
                             (streakFactor * 0.3) +
                             (patternFactor * 0.2) +
                             (decayFactor * 0.1);

      // Ajustements contextuels
      final adjustedProbability = _applyContextualAdjustments(
        baseProbability,
        habit,
        consistency
      );

      final predictions = <DayPrediction>[];

      for (int i = 1; i <= predictionDays; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final dayProbability = _calculateDayProbability(
          adjustedProbability,
          i,
          date,
          patterns
        );

        predictions.add(DayPrediction(
          date: date,
          probability: dayProbability,
          confidence: _calculateConfidence(consistency, patterns),
          factors: _identifyKeyFactors(dayProbability, consistency, patterns),
        ));
      }

      final prediction = SuccessPrediction(
        habit: habit,
        predictions: predictions,
        overallProbability: adjustedProbability,
        confidenceLevel: _calculateOverallConfidence(predictions),
        keyFactors: _identifyMainFactors(consistency, patterns),
        recommendations: [],
      );

      log('Prédiction générée - Probabilité globale: ${(adjustedProbability * 100).toStringAsFixed(1)}%');

      return prediction;
    });
  }

  double _calculatePatternStrength(PatternAnalysis patterns) {
    return math.min(patterns.predictability, 1.0);
  }

  double _calculateDecayFactor(HabitAggregate habit, int days) {
    final age = DateTime.now().difference(habit.createdAt).inDays;
    if (age < 7) return 0.7; // Nouvelles habitudes sont moins fiables
    if (age < 30) return 0.85;
    return 1.0; // Habitudes établies
  }

  double _applyContextualAdjustments(double baseProbability, HabitAggregate habit, ConsistencyAnalysis consistency) {
    double adjusted = baseProbability;

    // Ajustement basé sur la récence des échecs
    if (consistency.currentStreak == 0) {
      adjusted *= 0.8; // Réduction si pas de streak actuel
    }

    // Ajustement basé sur le type d'habitude
    if (habit.type == HabitType.quantitative) {
      adjusted *= 0.95; // Les habitudes quantitatives sont légèrement plus difficiles
    }

    return math.max(0, math.min(1, adjusted));
  }

  double _calculateDayProbability(double baseProbability, int dayOffset, DateTime date, PatternAnalysis patterns) {
    double dayProbability = baseProbability;

    // Ajustement basé sur le jour de la semaine
    final dayOfWeek = date.weekday;
    final totalCompletions = patterns.completionsByDayOfWeek.values.fold<int>(0, (a, b) => a + b);

    if (totalCompletions > 0) {
      final dayCompletions = patterns.completionsByDayOfWeek[dayOfWeek] ?? 0;
      final dayFactor = (dayCompletions / (totalCompletions / 7)) / 7; // Normaliser
      dayProbability *= (0.7 + dayFactor * 0.6); // Influence modérée
    }

    // Dégradation avec la distance temporelle
    dayProbability *= math.pow(0.95, dayOffset - 1);

    return math.max(0, math.min(1, dayProbability));
  }

  double _calculateConfidence(ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    final dataPoints = consistency.totalCompletions;
    final consistencyFactor = consistency.completionRate > 0.1 ? 1.0 : 0.5;
    final patternStrength = patterns.predictability;

    return math.min(1.0, (dataPoints / 30) * consistencyFactor * patternStrength);
  }

  List<String> _identifyKeyFactors(double probability, ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    final factors = <String>[];

    if (consistency.currentStreak > 5) {
      factors.add('Série actuelle forte (${consistency.currentStreak} jours)');
    }

    if (consistency.completionRate > 0.8) {
      factors.add('Excellente consistance historique');
    }

    if (patterns.trend == TrendDirection.improving) {
      factors.add('Tendance positive récente');
    }

    return factors;
  }

  double _calculateOverallConfidence(List<DayPrediction> predictions) {
    if (predictions.isEmpty) return 0.0;
    return predictions.map((p) => p.confidence).reduce((a, b) => a + b) / predictions.length;
  }

  List<String> _identifyMainFactors(ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    final factors = <String>[];

    factors.add('Taux de complétion: ${(consistency.completionRate * 100).toStringAsFixed(0)}%');
    factors.add('Consistance: ${consistency.consistency.label}');
    factors.add('Tendance: ${patterns.trend.label}');

    return factors;
  }
}

/// Prédiction de succès pour une habitude
class SuccessPrediction {
  final HabitAggregate habit;
  final List<DayPrediction> predictions;
  final double overallProbability;
  final double confidenceLevel;
  final List<String> keyFactors;
  final List<HabitRecommendation> recommendations;

  const SuccessPrediction({
    required this.habit,
    required this.predictions,
    required this.overallProbability,
    required this.confidenceLevel,
    required this.keyFactors,
    required this.recommendations,
  });
}

/// Prédiction pour un jour spécifique
class DayPrediction {
  final DateTime date;
  final double probability;
  final double confidence;
  final List<String> factors;

  const DayPrediction({
    required this.date,
    required this.probability,
    required this.confidence,
    required this.factors,
  });
}
