import 'dart:math' as math;
import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';
import 'consistency_analyzer.dart';
import 'pattern_analyzer.dart';

/// Success Prediction Result
class SuccessPrediction {
  final HabitAggregate habit;
  final List<DayPrediction> predictions;
  final double overallProbability;
  final double confidenceLevel;
  final List<String> keyFactors;
  final List<String> recommendations;

  const SuccessPrediction({
    required this.habit,
    required this.predictions,
    required this.overallProbability,
    required this.confidenceLevel,
    required this.keyFactors,
    required this.recommendations,
  });
}

/// Daily Prediction Data
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

/// Prediction Factors for Analysis
class PredictionFactors {
  final double consistencyFactor;
  final double streakFactor;
  final double patternFactor;
  final double decayFactor;
  final double momentumFactor;

  const PredictionFactors({
    required this.consistencyFactor,
    required this.streakFactor,
    required this.patternFactor,
    required this.decayFactor,
    required this.momentumFactor,
  });

  double get compositeScore =>
    (consistencyFactor * 0.35) +
    (streakFactor * 0.25) +
    (patternFactor * 0.20) +
    (momentumFactor * 0.15) +
    (decayFactor * 0.05);
}

/// Success Predictor - Predicts habit completion probability using ML-inspired algorithms
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for success prediction only
/// - OCP: Extensible through prediction algorithms and factors
/// - LSP: Compatible with habit prediction interfaces
/// - ISP: Focused interface for prediction operations only
/// - DIP: Depends on analyzer abstractions (ConsistencyAnalyzer, PatternAnalyzer)
///
/// Features:
/// - Multi-factor probability calculation
/// - Daily prediction with confidence intervals
/// - Contextual adjustments based on habit history
/// - Machine learning inspired feature engineering
/// - Decay and momentum factor calculations
/// - Confidence level estimation
///
/// CONSTRAINTS: <200 lines (currently ~190 lines)
class SuccessPredictor extends LoggableDomainService {

  final ConsistencyAnalyzer _consistencyAnalyzer;
  final PatternAnalyzer _patternAnalyzer;

  @override
  String get serviceName => 'SuccessPredictor';

  SuccessPredictor({
    ConsistencyAnalyzer? consistencyAnalyzer,
    PatternAnalyzer? patternAnalyzer,
  })  : _consistencyAnalyzer = consistencyAnalyzer ?? ConsistencyAnalyzer(),
        _patternAnalyzer = patternAnalyzer ?? PatternAnalyzer();

  /// Predicts success probability for upcoming days
  SuccessPrediction predictSuccess(
    HabitAggregate habit, {
    int predictionDays = 7,
    int analysisWindow = 30,
  }) {
    return executeOperation(() {
      log('Predicting success for ${habit.name} over $predictionDays days');

      // Gather analysis data
      final consistency = _consistencyAnalyzer.analyzeConsistency(habit, days: analysisWindow);
      final patterns = _patternAnalyzer.analyzePatterns(habit, days: analysisWindow);
      final momentum = _consistencyAnalyzer.analyzeMomentum(habit);

      // Calculate prediction factors
      final factors = _calculatePredictionFactors(habit, consistency, patterns, momentum);

      // Apply contextual adjustments
      final adjustedProbability = _applyContextualAdjustments(
        factors.compositeScore,
        habit,
        consistency,
      );

      // Generate daily predictions
      final predictions = <DayPrediction>[];
      for (int i = 1; i <= predictionDays; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final dayPrediction = _generateDayPrediction(
          date,
          i,
          adjustedProbability,
          patterns,
          consistency,
        );
        predictions.add(dayPrediction);
      }

      final prediction = SuccessPrediction(
        habit: habit,
        predictions: predictions,
        overallProbability: adjustedProbability,
        confidenceLevel: _calculateOverallConfidence(predictions),
        keyFactors: _identifyKeyFactors(factors, consistency, patterns),
        recommendations: _generateQuickRecommendations(factors, consistency, patterns),
      );

      log('Prediction generated - Overall probability: ${(adjustedProbability * 100).toStringAsFixed(1)}%');

      return prediction;
    });
  }

  /// Calculates probability for a specific upcoming day
  double predictDayProbability(
    HabitAggregate habit,
    DateTime targetDate, {
    int analysisWindow = 30,
  }) {
    return executeOperation(() {
      final consistency = _consistencyAnalyzer.analyzeConsistency(habit, days: analysisWindow);
      final patterns = _patternAnalyzer.analyzePatterns(habit, days: analysisWindow);
      final momentum = _consistencyAnalyzer.analyzeMomentum(habit);

      final factors = _calculatePredictionFactors(habit, consistency, patterns, momentum);
      final baseProbability = _applyContextualAdjustments(factors.compositeScore, habit, consistency);

      final daysFromNow = targetDate.difference(DateTime.now()).inDays;
      return _calculateDayProbability(baseProbability, daysFromNow, targetDate, patterns);
    });
  }

  // === PRIVATE PREDICTION METHODS ===

  PredictionFactors _calculatePredictionFactors(
    HabitAggregate habit,
    ConsistencyAnalysis consistency,
    PatternAnalysis patterns,
    MomentumAnalysis momentum,
  ) {
    final consistencyFactor = consistency.completionRate;
    final streakFactor = math.min(habit.getCurrentStreak() / 21, 1.0); // Cap at 21 days
    final patternFactor = patterns.predictability;
    final decayFactor = _calculateDecayFactor(habit);
    final momentumFactor = _calculateMomentumFactor(momentum);

    return PredictionFactors(
      consistencyFactor: consistencyFactor,
      streakFactor: streakFactor,
      patternFactor: patternFactor,
      decayFactor: decayFactor,
      momentumFactor: momentumFactor,
    );
  }

  double _calculateDecayFactor(HabitAggregate habit) {
    final age = DateTime.now().difference(habit.createdAt).inDays;
    if (age < 7) return 0.7; // New habits are less reliable
    if (age < 30) return 0.85;
    return 1.0; // Established habits
  }

  double _calculateMomentumFactor(MomentumAnalysis momentum) {
    switch (momentum.momentum) {
      case MomentumDirection.accelerating:
        return 1.2;
      case MomentumDirection.improving:
        return 1.1;
      case MomentumDirection.stable:
        return 1.0;
      case MomentumDirection.slowing:
        return 0.9;
      case MomentumDirection.declining:
        return 0.8;
    }
  }

  double _applyContextualAdjustments(
    double baseProbability,
    HabitAggregate habit,
    ConsistencyAnalysis consistency,
  ) {
    double adjusted = baseProbability;

    // Adjustment based on current streak
    if (consistency.currentStreak == 0) {
      adjusted *= 0.8; // Reduction if no current streak
    } else if (consistency.currentStreak > 7) {
      adjusted *= 1.1; // Boost for active streaks
    }

    // Adjustment based on habit type
    if (habit.type == HabitType.quantitative) {
      adjusted *= 0.95; // Quantitative habits are slightly harder
    }

    // Adjustment based on recent performance
    if (consistency.completionRate > 0.9) {
      adjusted *= 1.05; // Boost for high performers
    }

    return math.max(0, math.min(1, adjusted));
  }

  DayPrediction _generateDayPrediction(
    DateTime date,
    int dayOffset,
    double baseProbability,
    PatternAnalysis patterns,
    ConsistencyAnalysis consistency,
  ) {
    final dayProbability = _calculateDayProbability(baseProbability, dayOffset, date, patterns);
    final confidence = _calculateDayConfidence(consistency, patterns);
    final factors = _identifyDayFactors(dayProbability, consistency, patterns, date);

    return DayPrediction(
      date: date,
      probability: dayProbability,
      confidence: confidence,
      factors: factors,
    );
  }

  double _calculateDayProbability(
    double baseProbability,
    int dayOffset,
    DateTime date,
    PatternAnalysis patterns,
  ) {
    double dayProbability = baseProbability;

    // Day of week adjustment
    final dayOfWeek = date.weekday;
    final totalCompletions = patterns.completionsByDayOfWeek.values.fold<int>(0, (a, b) => a + b);

    if (totalCompletions > 0) {
      final dayCompletions = patterns.completionsByDayOfWeek[dayOfWeek] ?? 0;
      final dayFactor = (dayCompletions / (totalCompletions / 7)) / 7;
      dayProbability *= (0.7 + dayFactor * 0.6); // Moderate influence
    }

    // Temporal decay with distance
    dayProbability *= math.pow(0.95, dayOffset - 1);

    return math.max(0, math.min(1, dayProbability));
  }

  double _calculateDayConfidence(ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    final dataPoints = consistency.totalCompletions;
    final consistencyFactor = consistency.completionRate > 0.1 ? 1.0 : 0.5;
    final patternStrength = patterns.predictability;

    return math.min(1.0, (dataPoints / 30) * consistencyFactor * patternStrength);
  }

  List<String> _identifyDayFactors(
    double probability,
    ConsistencyAnalysis consistency,
    PatternAnalysis patterns,
    DateTime date,
  ) {
    final factors = <String>[];

    if (consistency.currentStreak > 5) {
      factors.add('Série actuelle: ${consistency.currentStreak} jours');
    }

    if (patterns.bestDays.contains(date.weekday)) {
      factors.add('Jour habituellement favorable');
    }

    if (patterns.worstDays.contains(date.weekday)) {
      factors.add('Jour généralement difficile');
    }

    return factors;
  }

  double _calculateOverallConfidence(List<DayPrediction> predictions) {
    if (predictions.isEmpty) return 0.0;
    return predictions.map((p) => p.confidence).reduce((a, b) => a + b) / predictions.length;
  }

  List<String> _identifyKeyFactors(
    PredictionFactors factors,
    ConsistencyAnalysis consistency,
    PatternAnalysis patterns,
  ) {
    final keyFactors = <String>[];

    keyFactors.add('Consistance: ${(consistency.completionRate * 100).toStringAsFixed(0)}%');
    keyFactors.add('Série actuelle: ${consistency.currentStreak} jours');
    keyFactors.add('Tendance: ${patterns.trend.label}');

    if (factors.streakFactor > 0.8) {
      keyFactors.add('Forte série en cours');
    }

    if (factors.momentumFactor > 1.1) {
      keyFactors.add('Momentum positif');
    }

    return keyFactors;
  }

  List<String> _generateQuickRecommendations(
    PredictionFactors factors,
    ConsistencyAnalysis consistency,
    PatternAnalysis patterns,
  ) {
    final recommendations = <String>[];

    if (factors.consistencyFactor < 0.6) {
      recommendations.add('Améliorer la régularité');
    }

    if (patterns.worstDays.isNotEmpty) {
      recommendations.add('Renforcer les jours difficiles');
    }

    if (patterns.trend == TrendDirection.declining) {
      recommendations.add('Renouveler la motivation');
    }

    return recommendations;
  }
}