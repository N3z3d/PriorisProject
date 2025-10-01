/// SOLID Trend Analysis Service
/// Single Responsibility: Analyze performance trends and provide predictions only

import 'dart:math';
import '../interfaces/performance_interfaces.dart';
import '../models/performance_models.dart';
import './metrics_collector_service.dart';

/// Concrete implementation of trend analysis
/// Follows Single Responsibility Principle - only handles trend analysis
class TrendAnalyzerService implements ITrendAnalyzer {
  final MetricsCollectorService _metricsCollector;
  final Duration _defaultAnalysisPeriod;
  final double _minConfidenceThreshold;

  TrendAnalyzerService({
    required MetricsCollectorService metricsCollector,
    Duration defaultAnalysisPeriod = const Duration(hours: 1),
    double minConfidenceThreshold = 0.5,
  }) : _metricsCollector = metricsCollector,
       _defaultAnalysisPeriod = defaultAnalysisPeriod,
       _minConfidenceThreshold = minConfidenceThreshold;

  @override
  Map<String, TrendAnalysis> analyzeTrends({Duration? period}) {
    final analysisPeriod = period ?? _defaultAnalysisPeriod;
    final metrics = _metricsCollector.getCurrentMetrics();
    final trends = <String, TrendAnalysis>{};

    for (final metricName in metrics.keys) {
      final trend = analyzeMetricTrend(metricName, period: analysisPeriod);
      if (trend.confidence >= _minConfidenceThreshold) {
        trends[metricName] = trend;
      }
    }

    return trends;
  }

  @override
  TrendAnalysis analyzeMetricTrend(String metricName, {Duration? period}) {
    final analysisPeriod = period ?? _defaultAnalysisPeriod;
    final history = _metricsCollector.getMetricHistory(metricName, period: analysisPeriod);

    if (history.length < 2) {
      return TrendAnalysis(
        metricName: metricName,
        direction: TrendDirection.stable,
        slope: 0.0,
        correlation: 0.0,
        predictedValue: 0.0,
        confidence: 0.0,
        timeWindow: analysisPeriod,
        insights: ['Insufficient data for trend analysis'],
      );
    }

    // Prepare data for regression analysis
    final dataPoints = _prepareDataPoints(history);
    final regression = _calculateLinearRegression(dataPoints);

    // Analyze trend characteristics
    final direction = _determineTrendDirection(regression.slope, dataPoints);
    final volatility = _calculateVolatility(dataPoints);
    final predictions = _generatePredictions(regression, dataPoints.last);
    final insights = _generateInsights(metricName, regression, direction, volatility);

    return TrendAnalysis(
      metricName: metricName,
      direction: direction,
      slope: regression.slope,
      correlation: regression.correlation,
      predictedValue: predictions.nextValue,
      confidence: _calculateConfidence(regression, volatility),
      timeWindow: analysisPeriod,
      insights: insights,
    );
  }

  @override
  Map<String, double> predictMetrics({Duration? horizon}) {
    final predictionHorizon = horizon ?? const Duration(minutes: 30);
    final trends = analyzeTrends();
    final predictions = <String, double>{};

    for (final entry in trends.entries) {
      if (entry.value.confidence >= _minConfidenceThreshold) {
        final prediction = _predictFutureValue(
          entry.value,
          predictionHorizon,
        );
        predictions[entry.key] = prediction;
      }
    }

    return predictions;
  }

  @override
  List<String> generateRecommendations() {
    final trends = analyzeTrends();
    final recommendations = <String>[];

    for (final trend in trends.values) {
      if (trend.confidence < _minConfidenceThreshold) continue;

      recommendations.addAll(_generateMetricRecommendations(trend));
    }

    // Add general recommendations based on overall trend patterns
    recommendations.addAll(_generateGeneralRecommendations(trends));

    return recommendations.toSet().toList(); // Remove duplicates
  }

  /// Prepare data points for mathematical analysis
  List<DataPoint2D> _prepareDataPoints(List<DataPoint> history) {
    final points = <DataPoint2D>[];
    final firstTimestamp = history.first.timestamp.millisecondsSinceEpoch;

    for (final point in history) {
      final x = (point.timestamp.millisecondsSinceEpoch - firstTimestamp).toDouble();
      points.add(DataPoint2D(x: x, y: point.value));
    }

    return points;
  }

  /// Calculate linear regression for trend analysis
  LinearRegression _calculateLinearRegression(List<DataPoint2D> points) {
    if (points.length < 2) {
      return LinearRegression(slope: 0, intercept: 0, correlation: 0);
    }

    final n = points.length;
    final sumX = points.fold(0.0, (sum, p) => sum + p.x);
    final sumY = points.fold(0.0, (sum, p) => sum + p.y);
    final sumXY = points.fold(0.0, (sum, p) => sum + (p.x * p.y));
    final sumXX = points.fold(0.0, (sum, p) => sum + (p.x * p.x));
    final sumYY = points.fold(0.0, (sum, p) => sum + (p.y * p.y));

    final denominator = (n * sumXX - sumX * sumX);
    if (denominator == 0) {
      return LinearRegression(slope: 0, intercept: sumY / n, correlation: 0);
    }

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

    // Calculate correlation coefficient (R)
    final numerator = n * sumXY - sumX * sumY;
    final denomX = sqrt(n * sumXX - sumX * sumX);
    final denomY = sqrt(n * sumYY - sumY * sumY);
    final correlation = (denomX * denomY == 0) ? 0.0 : numerator / (denomX * denomY);

    return LinearRegression(
      slope: slope,
      intercept: intercept,
      correlation: correlation.abs(), // Use absolute value for confidence
    );
  }

  /// Determine trend direction based on slope and data analysis
  TrendDirection _determineTrendDirection(double slope, List<DataPoint2D> points) {
    final volatility = _calculateVolatility(points);
    final slopeThreshold = volatility * 0.1; // Adjust threshold based on volatility

    if (volatility > 2.0) {
      return TrendDirection.volatile;
    } else if (slope > slopeThreshold) {
      return TrendDirection.increasing;
    } else if (slope < -slopeThreshold) {
      return TrendDirection.decreasing;
    } else {
      return TrendDirection.stable;
    }
  }

  /// Calculate volatility (standard deviation of values)
  double _calculateVolatility(List<DataPoint2D> points) {
    if (points.isEmpty) return 0.0;

    final mean = points.fold(0.0, (sum, p) => sum + p.y) / points.length;
    final variance = points
        .fold(0.0, (sum, p) => sum + pow(p.y - mean, 2)) / points.length;

    return sqrt(variance);
  }

  /// Generate predictions based on trend analysis
  PredictionResult _generatePredictions(LinearRegression regression, DataPoint2D lastPoint) {
    // Predict next value using linear regression
    final nextX = lastPoint.x + (60 * 1000); // Assume 1 minute in the future
    final nextValue = regression.intercept + regression.slope * nextX;

    return PredictionResult(
      nextValue: nextValue,
      confidence: regression.correlation,
    );
  }

  /// Generate insights based on trend analysis
  List<String> _generateInsights(
    String metricName,
    LinearRegression regression,
    TrendDirection direction,
    double volatility,
  ) {
    final insights = <String>[];

    // Trend direction insights
    switch (direction) {
      case TrendDirection.increasing:
        insights.add('$metricName is trending upward');
        if (metricName.contains('error') || metricName.contains('latency')) {
          insights.add('Performance degradation detected');
        }
        break;
      case TrendDirection.decreasing:
        insights.add('$metricName is trending downward');
        if (metricName.contains('error') || metricName.contains('latency')) {
          insights.add('Performance improvement detected');
        }
        break;
      case TrendDirection.stable:
        insights.add('$metricName is stable');
        break;
      case TrendDirection.volatile:
        insights.add('$metricName shows high volatility');
        break;
    }

    // Volatility insights
    if (volatility > 1.5) {
      insights.add('High variability detected - investigate potential causes');
    } else if (volatility < 0.1) {
      insights.add('Very consistent performance');
    }

    // Correlation insights
    if (regression.correlation > 0.8) {
      insights.add('Strong trend pattern - predictions likely accurate');
    } else if (regression.correlation < 0.3) {
      insights.add('Weak trend pattern - predictions may be unreliable');
    }

    return insights;
  }

  /// Calculate confidence level for predictions
  double _calculateConfidence(LinearRegression regression, double volatility) {
    // Base confidence on correlation coefficient
    var confidence = regression.correlation;

    // Reduce confidence for high volatility
    if (volatility > 1.0) {
      confidence *= (1.0 - min(volatility / 5.0, 0.5));
    }

    // Ensure confidence is between 0 and 1
    return confidence.clamp(0.0, 1.0);
  }

  /// Predict future value based on trend and time horizon
  double _predictFutureValue(TrendAnalysis trend, Duration horizon) {
    final timeInMs = horizon.inMilliseconds.toDouble();
    return trend.predictedValue + (trend.slope * timeInMs);
  }

  /// Generate metric-specific recommendations
  List<String> _generateMetricRecommendations(TrendAnalysis trend) {
    final recommendations = <String>[];

    if (trend.confidence < 0.5) {
      return ['Insufficient data confidence for ${trend.metricName} recommendations'];
    }

    switch (trend.direction) {
      case TrendDirection.increasing:
        if (trend.metricName.contains('latency') || trend.metricName.contains('duration')) {
          recommendations.add('Response times increasing - consider performance optimization');
        }
        if (trend.metricName.contains('error')) {
          recommendations.add('Error rate rising - investigate error causes');
        }
        if (trend.metricName.contains('memory')) {
          recommendations.add('Memory usage growing - check for memory leaks');
        }
        break;

      case TrendDirection.decreasing:
        if (trend.metricName.contains('hit_rate') || trend.metricName.contains('success')) {
          recommendations.add('Success rate declining - review system health');
        }
        break;

      case TrendDirection.volatile:
        recommendations.add('${trend.metricName} shows inconsistent behavior - investigate stability');
        break;

      case TrendDirection.stable:
        // Stable metrics are generally good
        break;
    }

    return recommendations;
  }

  /// Generate general recommendations based on all trends
  List<String> _generateGeneralRecommendations(Map<String, TrendAnalysis> trends) {
    final recommendations = <String>[];
    final degradingMetrics = <String>[];
    final volatileMetrics = <String>[];

    for (final trend in trends.values) {
      if (trend.direction == TrendDirection.increasing &&
          (trend.metricName.contains('latency') ||
           trend.metricName.contains('error') ||
           trend.metricName.contains('memory'))) {
        degradingMetrics.add(trend.metricName);
      }

      if (trend.direction == TrendDirection.volatile) {
        volatileMetrics.add(trend.metricName);
      }
    }

    if (degradingMetrics.length >= 3) {
      recommendations.add('Multiple performance metrics degrading - consider system-wide optimization');
    }

    if (volatileMetrics.length >= 2) {
      recommendations.add('System instability detected - review recent changes');
    }

    if (trends.values.every((t) => t.confidence < 0.4)) {
      recommendations.add('Low prediction confidence - increase monitoring frequency');
    }

    return recommendations;
  }
}

/// Internal data structures for mathematical analysis
class DataPoint2D {
  final double x;
  final double y;

  const DataPoint2D({required this.x, required this.y});
}

class LinearRegression {
  final double slope;
  final double intercept;
  final double correlation;

  const LinearRegression({
    required this.slope,
    required this.intercept,
    required this.correlation,
  });
}

class PredictionResult {
  final double nextValue;
  final double confidence;

  const PredictionResult({
    required this.nextValue,
    required this.confidence,
  });
}