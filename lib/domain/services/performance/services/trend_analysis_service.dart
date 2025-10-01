import 'dart:math';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Service responsable uniquement de l'analyse de tendances
///
/// Respecte le Single Responsibility Principle en ne gérant que
/// l'analyse statistique et la prédiction de tendances
class TrendAnalysisService {
  /// Analyse une tendance à partir de points de données
  TrendAnalysis analyzeTrend(String metricName, List<DataPoint> dataPoints) {
    if (dataPoints.length < 3) {
      return TrendAnalysis(
        metricName: metricName,
        direction: TrendDirection.stable,
        slope: 0.0,
        confidence: 0.0,
        analysisTime: DateTime.now(),
        analysisPeriod: Duration.zero,
        prediction: 'Données insuffisantes pour l\'analyse',
      );
    }

    try {
      final analysisTime = DateTime.now();
      final period = dataPoints.last.timestamp.difference(dataPoints.first.timestamp);

      // Régression linéaire pour calculer la tendance
      final regression = _calculateLinearRegression(dataPoints);

      // Déterminer la direction
      final direction = _determineTrendDirection(regression.slope, regression.correlation);

      // Calculer la confiance
      final confidence = _calculateConfidence(regression.correlation, dataPoints.length);

      // Générer une prédiction
      final prediction = _generatePrediction(metricName, regression, direction, confidence);

      LoggerService.instance.info(
        'Analyse de tendance pour $metricName: ${direction.name} (confiance: ${(confidence * 100).toStringAsFixed(1)}%)',
        context: 'TrendAnalysisService',
      );

      return TrendAnalysis(
        metricName: metricName,
        direction: direction,
        slope: regression.slope,
        confidence: confidence,
        analysisTime: analysisTime,
        analysisPeriod: period,
        prediction: prediction,
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de l\'analyse de tendance pour $metricName',
        context: 'TrendAnalysisService',
        error: e,
      );

      return TrendAnalysis(
        metricName: metricName,
        direction: TrendDirection.stable,
        slope: 0.0,
        confidence: 0.0,
        analysisTime: DateTime.now(),
        analysisPeriod: Duration.zero,
        prediction: 'Erreur lors de l\'analyse',
      );
    }
  }

  /// Analyse les tendances de plusieurs métriques
  Map<String, TrendAnalysis> analyzeMultipleTrends(
    Map<String, List<DataPoint>> metricsData,
  ) {
    final results = <String, TrendAnalysis>{};

    for (final entry in metricsData.entries) {
      results[entry.key] = analyzeTrend(entry.key, entry.value);
    }

    LoggerService.instance.info(
      'Analyse de tendances multiples terminée: ${results.length} métriques analysées',
      context: 'TrendAnalysisService',
    );

    return results;
  }

  /// Prédit une valeur future basée sur la tendance
  double? predictFutureValue(
    List<DataPoint> dataPoints,
    Duration futureOffset,
  ) {
    if (dataPoints.length < 3) return null;

    try {
      final regression = _calculateLinearRegression(dataPoints);

      // Convertir le temps en heures depuis le premier point
      final baseTime = dataPoints.first.timestamp;
      final futureHours = futureOffset.inHours.toDouble();
      final lastDataHours = dataPoints.last.timestamp.difference(baseTime).inHours.toDouble();

      final futureTimePoint = lastDataHours + futureHours;
      final predictedValue = regression.intercept + (regression.slope * futureTimePoint);

      return predictedValue;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la prédiction de valeur future',
        context: 'TrendAnalysisService',
        error: e,
      );
      return null;
    }
  }

  /// Détecte les anomalies dans une série de données
  List<AnomalyDetection> detectAnomalies(
    String metricName,
    List<DataPoint> dataPoints, {
    double sensitivityFactor = 2.0,
  }) {
    if (dataPoints.length < 10) return [];

    try {
      final values = dataPoints.map((p) => p.value).toList();
      final mean = values.reduce((a, b) => a + b) / values.length;

      // Calculer l'écart-type
      final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
      final standardDeviation = sqrt(variance);

      final anomalies = <AnomalyDetection>[];
      final threshold = standardDeviation * sensitivityFactor;

      for (int i = 0; i < dataPoints.length; i++) {
        final point = dataPoints[i];
        final deviation = (point.value - mean).abs();

        if (deviation > threshold) {
          anomalies.add(AnomalyDetection(
            metricName: metricName,
            timestamp: point.timestamp,
            value: point.value,
            expectedValue: mean,
            deviation: deviation,
            severity: _calculateAnomalySeverity(deviation, standardDeviation),
          ));
        }
      }

      if (anomalies.isNotEmpty) {
        LoggerService.instance.info(
          'Anomalies détectées pour $metricName: ${anomalies.length} points anormaux',
          context: 'TrendAnalysisService',
        );
      }

      return anomalies;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la détection d\'anomalies pour $metricName',
        context: 'TrendAnalysisService',
        error: e,
      );
      return [];
    }
  }

  /// Calcule la volatilité d'une métrique
  double calculateVolatility(List<DataPoint> dataPoints) {
    if (dataPoints.length < 2) return 0.0;

    final values = dataPoints.map((p) => p.value).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;

    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;

    return sqrt(variance);
  }

  /// Identifie les cycles/patterns saisonniers
  SeasonalPattern? detectSeasonalPattern(
    String metricName,
    List<DataPoint> dataPoints, {
    Duration cycleDuration = const Duration(days: 1),
  }) {
    if (dataPoints.length < 20) return null;

    try {
      // Grouper les données par cycle
      final cycles = _groupDataByCycle(dataPoints, cycleDuration);

      if (cycles.length < 3) return null;

      // Calculer la corrélation entre cycles
      final correlation = _calculateCyclicalCorrelation(cycles);

      if (correlation < 0.5) return null; // Pas assez de corrélation pour un pattern

      return SeasonalPattern(
        metricName: metricName,
        cycleDuration: cycleDuration,
        correlation: correlation,
        detectedAt: DateTime.now(),
        cycleCount: cycles.length,
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la détection de pattern saisonnier pour $metricName',
        context: 'TrendAnalysisService',
        error: e,
      );
      return null;
    }
  }

  // === MÉTHODES PRIVÉES ===

  /// Calcule la régression linéaire
  LinearRegressionResult _calculateLinearRegression(List<DataPoint> dataPoints) {
    // Convertir les timestamps en heures depuis le premier point
    final baseTime = dataPoints.first.timestamp;
    final timeValues = dataPoints
        .map((p) => p.timestamp.difference(baseTime).inHours.toDouble())
        .toList();
    final yValues = dataPoints.map((p) => p.value).toList();

    final n = dataPoints.length.toDouble();
    final sumX = timeValues.reduce((a, b) => a + b);
    final sumY = yValues.reduce((a, b) => a + b);
    final sumXY = List.generate(timeValues.length, (i) => timeValues[i] * yValues[i])
        .reduce((a, b) => a + b);
    final sumXX = timeValues.map((x) => x * x).reduce((a, b) => a + b);
    final sumYY = yValues.map((y) => y * y).reduce((a, b) => a + b);

    // Calculer la pente et l'ordonnée à l'origine
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Calculer le coefficient de corrélation
    final numerator = n * sumXY - sumX * sumY;
    final denominator = sqrt((n * sumXX - sumX * sumX) * (n * sumYY - sumY * sumY));
    final correlation = denominator != 0 ? numerator / denominator : 0.0;

    return LinearRegressionResult(
      slope: slope,
      intercept: intercept,
      correlation: correlation,
    );
  }

  /// Détermine la direction de la tendance
  TrendDirection _determineTrendDirection(double slope, double correlation) {
    final correlationAbs = correlation.abs();

    if (correlationAbs < 0.3) {
      return TrendDirection.volatile;
    } else if (slope.abs() < 0.01) {
      return TrendDirection.stable;
    } else if (slope > 0) {
      return TrendDirection.increasing;
    } else {
      return TrendDirection.decreasing;
    }
  }

  /// Calcule la confiance dans l'analyse
  double _calculateConfidence(double correlation, int dataPointCount) {
    final correlationFactor = correlation.abs();
    final sizeFactor = min(1.0, dataPointCount / 50.0); // Plus de données = plus de confiance

    return correlationFactor * sizeFactor;
  }

  /// Génère une prédiction textuelle
  String _generatePrediction(
    String metricName,
    LinearRegressionResult regression,
    TrendDirection direction,
    double confidence,
  ) {
    final confidencePercent = (confidence * 100).round();

    switch (direction) {
      case TrendDirection.increasing:
        return 'Tendance à la hausse détectée (confiance: $confidencePercent%). '
               'La métrique devrait continuer à augmenter.';
      case TrendDirection.decreasing:
        return 'Tendance à la baisse détectée (confiance: $confidencePercent%). '
               'La métrique devrait continuer à diminuer.';
      case TrendDirection.stable:
        return 'Métrique stable (confiance: $confidencePercent%). '
               'Peu de variation attendue.';
      case TrendDirection.volatile:
        return 'Métrique volatile (confiance: $confidencePercent%). '
               'Comportement imprévisible, surveillance recommandée.';
    }
  }

  /// Calcule la sévérité d'une anomalie
  AnomalySeverity _calculateAnomalySeverity(double deviation, double standardDeviation) {
    final factor = deviation / standardDeviation;

    if (factor > 3.0) {
      return AnomalySeverity.critical;
    } else if (factor > 2.0) {
      return AnomalySeverity.high;
    } else {
      return AnomalySeverity.moderate;
    }
  }

  /// Groupe les données par cycle
  List<List<DataPoint>> _groupDataByCycle(List<DataPoint> dataPoints, Duration cycleDuration) {
    final cycles = <List<DataPoint>>[];
    final cycleDurationMs = cycleDuration.inMilliseconds;

    DateTime? cycleStart;
    List<DataPoint> currentCycle = [];

    for (final point in dataPoints) {
      if (cycleStart == null) {
        cycleStart = point.timestamp;
        currentCycle = [point];
      } else {
        final elapsed = point.timestamp.difference(cycleStart).inMilliseconds;

        if (elapsed < cycleDurationMs) {
          currentCycle.add(point);
        } else {
          if (currentCycle.isNotEmpty) {
            cycles.add(currentCycle);
          }
          cycleStart = point.timestamp;
          currentCycle = [point];
        }
      }
    }

    if (currentCycle.isNotEmpty) {
      cycles.add(currentCycle);
    }

    return cycles;
  }

  /// Calcule la corrélation cyclique
  double _calculateCyclicalCorrelation(List<List<DataPoint>> cycles) {
    if (cycles.length < 2) return 0.0;

    // Simplification: calculer la corrélation entre les moyennes de chaque cycle
    final cycleMeans = cycles.map((cycle) {
      final values = cycle.map((p) => p.value).toList();
      return values.reduce((a, b) => a + b) / values.length;
    }).toList();

    if (cycleMeans.length < 2) return 0.0;

    final mean = cycleMeans.reduce((a, b) => a + b) / cycleMeans.length;
    final variance = cycleMeans.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / cycleMeans.length;

    // Retourner l'inverse du coefficient de variation comme mesure de régularité
    return variance > 0 ? 1.0 / (sqrt(variance) / mean) : 0.0;
  }
}

// === CLASSES DE SUPPORT ===

class LinearRegressionResult {
  final double slope;
  final double intercept;
  final double correlation;

  const LinearRegressionResult({
    required this.slope,
    required this.intercept,
    required this.correlation,
  });
}

class DataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? tags;

  const DataPoint({
    required this.timestamp,
    required this.value,
    this.tags,
  });
}

enum TrendDirection { increasing, decreasing, stable, volatile }

class TrendAnalysis {
  final String metricName;
  final TrendDirection direction;
  final double slope;
  final double confidence;
  final DateTime analysisTime;
  final Duration analysisPeriod;
  final String? prediction;

  const TrendAnalysis({
    required this.metricName,
    required this.direction,
    required this.slope,
    required this.confidence,
    required this.analysisTime,
    required this.analysisPeriod,
    this.prediction,
  });
}

class AnomalyDetection {
  final String metricName;
  final DateTime timestamp;
  final double value;
  final double expectedValue;
  final double deviation;
  final AnomalySeverity severity;

  const AnomalyDetection({
    required this.metricName,
    required this.timestamp,
    required this.value,
    required this.expectedValue,
    required this.deviation,
    required this.severity,
  });
}

enum AnomalySeverity { moderate, high, critical }

class SeasonalPattern {
  final String metricName;
  final Duration cycleDuration;
  final double correlation;
  final DateTime detectedAt;
  final int cycleCount;

  const SeasonalPattern({
    required this.metricName,
    required this.cycleDuration,
    required this.correlation,
    required this.detectedAt,
    required this.cycleCount,
  });
}