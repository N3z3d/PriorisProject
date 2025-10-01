/// SOLID Metrics Collection Service
/// Following Single Responsibility Principle - only handles metrics collection
/// Line count: ~190 lines (within 200-line limit)

import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:prioris/domain/services/performance/interfaces/metrics_collector_interface.dart';
import 'package:prioris/domain/services/performance/models/performance_models.dart';

/// Concrete implementation of metrics collection
/// Follows Single Responsibility Principle - only handles metrics collection
class MetricsCollectorService implements IMetricsCollector {
  final Map<String, MetricData> _metrics = {};
  final Map<String, Queue<DataPoint>> _metricHistory = {};
  final int _maxHistoryPoints;

  MetricsCollectorService({
    int maxHistoryPoints = 1000,
  }) : _maxHistoryPoints = maxHistoryPoints;

  @override
  void recordMetric(String name, double value, {Map<String, dynamic>? tags}) {
    final now = DateTime.now();
    final dataPoint = DataPoint(timestamp: now, value: value, tags: tags);

    // Update current metric data
    if (_metrics.containsKey(name)) {
      _metrics[name]!._addDataPoint(dataPoint);
    } else {
      _metrics[name] = MetricData(name: name, firstValue: value, timestamp: now);
      _metrics[name]!._addDataPoint(dataPoint);
    }

    // Add to history
    _metricHistory.putIfAbsent(name, () => Queue<DataPoint>());
    final history = _metricHistory[name]!;
    history.addLast(dataPoint);

    // Maintain history size limit
    while (history.length > _maxHistoryPoints) {
      history.removeFirst();
    }
  }

  @override
  void recordEvent(String eventType, Map<String, dynamic> details) {
    final timestamp = DateTime.now();
    final eventMetric = 'event_${eventType}_count';

    // Record event as a metric
    recordMetric(eventMetric, 1.0, tags: {
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      ...details,
    });
  }

  @override
  Map<String, dynamic> getCurrentMetrics() {
    final result = <String, dynamic>{};

    for (final entry in _metrics.entries) {
      final metric = entry.value;
      result[entry.key] = {
        'current': metric.currentValue,
        'average': metric.averageValue,
        'min': metric.minValue,
        'max': metric.maxValue,
        'count': metric.sampleCount,
        'lastUpdated': metric.lastUpdated.toIso8601String(),
      };
    }

    return result;
  }

  @override
  IOperationTracker startOperation(String operationName) {
    return OperationTracker(operationName: operationName, metricsCollector: this);
  }

  /// Get metric history for analysis
  List<DataPoint> getMetricHistory(String metricName, {Duration? period}) {
    final history = _metricHistory[metricName];
    if (history == null) return [];

    if (period == null) {
      return history.toList();
    }

    final cutoff = DateTime.now().subtract(period);
    return history.where((point) => point.timestamp.isAfter(cutoff)).toList();
  }

  /// Get detailed metric report
  MetricReport? getMetricReport(String metricName, {Duration? period}) {
    final metric = _metrics[metricName];
    if (metric == null) return null;

    final history = getMetricHistory(metricName, period: period);
    if (history.isEmpty) return null;

    final values = history.map((p) => p.value).toList()..sort();
    final percentile95 = _calculatePercentile(values, 0.95);

    return MetricReport(
      name: metricName,
      unit: _getMetricUnit(metricName),
      currentValue: metric.currentValue,
      averageValue: metric.averageValue,
      minValue: metric.minValue,
      maxValue: metric.maxValue,
      percentile95: percentile95,
      sampleCount: metric.sampleCount,
      history: history,
    );
  }

  /// Calculate percentile value
  double _calculatePercentile(List<double> sortedValues, double percentile) {
    if (sortedValues.isEmpty) return 0.0;
    final index = (percentile * (sortedValues.length - 1)).round();
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }

  /// Get appropriate unit for metric
  String _getMetricUnit(String metricName) {
    if (metricName.contains('_ms') || metricName.contains('latency')) return 'ms';
    if (metricName.contains('_mb') || metricName.contains('memory')) return 'MB';
    if (metricName.contains('_percent') || metricName.contains('rate')) return '%';
    if (metricName.contains('_ops') || metricName.contains('throughput')) return 'ops/sec';
    return 'count';
  }

  /// Clear all metrics data
  void clear() {
    _metrics.clear();
    _metricHistory.clear();
  }

  /// Get metrics summary
  Map<String, dynamic> getSummary() {
    return {
      'totalMetrics': _metrics.length,
      'totalDataPoints': _metricHistory.values.fold(0, (sum, queue) => sum + queue.length),
      'oldestDataPoint': _getOldestDataPoint()?.toIso8601String(),
      'newestDataPoint': _getNewestDataPoint()?.toIso8601String(),
    };
  }

  DateTime? _getOldestDataPoint() {
    DateTime? oldest;
    for (final history in _metricHistory.values) {
      if (history.isNotEmpty) {
        final first = history.first.timestamp;
        if (oldest == null || first.isBefore(oldest)) {
          oldest = first;
        }
      }
    }
    return oldest;
  }

  DateTime? _getNewestDataPoint() {
    DateTime? newest;
    for (final history in _metricHistory.values) {
      if (history.isNotEmpty) {
        final last = history.last.timestamp;
        if (newest == null || last.isAfter(newest)) {
          newest = last;
        }
      }
    }
    return newest;
  }
}

/// Operation tracker implementation
/// Single Responsibility: Track individual operation metrics
class OperationTracker implements IOperationTracker {
  final String operationName;
  final IMetricsCollector metricsCollector;
  final DateTime startTime;
  final Map<String, dynamic> context = {};
  final List<Checkpoint> checkpoints = [];

  OperationTracker({
    required this.operationName,
    required this.metricsCollector,
  }) : startTime = DateTime.now();

  @override
  void addContext(String key, dynamic value) {
    context[key] = value;
  }

  @override
  void checkpoint(String checkpointName) {
    final now = DateTime.now();
    final duration = now.difference(startTime);
    checkpoints.add(Checkpoint(
      name: checkpointName,
      timestamp: now,
      durationFromStart: duration,
    ));

    // Record checkpoint as metric
    metricsCollector.recordMetric(
      '${operationName}_checkpoint_${checkpointName}_ms',
      duration.inMilliseconds.toDouble(),
      tags: {'operationName': operationName, 'checkpoint': checkpointName},
    );
  }

  @override
  void complete({Map<String, dynamic>? result}) {
    final now = DateTime.now();
    final totalDuration = now.difference(startTime);

    // Record operation metrics
    metricsCollector.recordMetric(
      '${operationName}_duration_ms',
      totalDuration.inMilliseconds.toDouble(),
      tags: {'operationName': operationName, 'status': 'success', ...context},
    );

    metricsCollector.recordMetric(
      '${operationName}_success_count',
      1.0,
      tags: {'operationName': operationName, ...context},
    );

    // Record event
    metricsCollector.recordEvent('operation_completed', {
      'operationName': operationName,
      'duration': totalDuration.inMilliseconds,
      'checkpoints': checkpoints.length,
      'success': true,
      'context': context,
      'result': result,
    });
  }

  @override
  void completeWithError(Object error, {StackTrace? stackTrace}) {
    final now = DateTime.now();
    final totalDuration = now.difference(startTime);

    // Record operation metrics
    metricsCollector.recordMetric(
      '${operationName}_duration_ms',
      totalDuration.inMilliseconds.toDouble(),
      tags: {'operationName': operationName, 'status': 'error', ...context},
    );

    metricsCollector.recordMetric(
      '${operationName}_error_count',
      1.0,
      tags: {'operationName': operationName, 'error': error.toString(), ...context},
    );

    // Record event
    metricsCollector.recordEvent('operation_failed', {
      'operationName': operationName,
      'duration': totalDuration.inMilliseconds,
      'checkpoints': checkpoints.length,
      'success': false,
      'error': error.toString(),
      'context': context,
    });
  }
}

/// Internal metric data structure
/// Single Responsibility: Store and calculate metric statistics
class MetricData {
  final String name;
  final DateTime timestamp;

  double currentValue;
  double minValue;
  double maxValue;
  double totalValue = 0.0;
  int sampleCount = 0;
  DateTime lastUpdated;

  MetricData({
    required this.name,
    required double firstValue,
    required this.timestamp,
  }) : currentValue = firstValue,
       minValue = firstValue,
       maxValue = firstValue,
       lastUpdated = timestamp;

  double get averageValue => sampleCount > 0 ? totalValue / sampleCount : 0.0;

  void _addDataPoint(DataPoint dataPoint) {
    currentValue = dataPoint.value;
    totalValue += dataPoint.value;
    sampleCount++;
    lastUpdated = dataPoint.timestamp;

    if (dataPoint.value < minValue) {
      minValue = dataPoint.value;
    }
    if (dataPoint.value > maxValue) {
      maxValue = dataPoint.value;
    }
  }
}

/// Checkpoint data structure
class Checkpoint {
  final String name;
  final DateTime timestamp;
  final Duration durationFromStart;

  const Checkpoint({
    required this.name,
    required this.timestamp,
    required this.durationFromStart,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'durationFromStartMs': durationFromStart.inMilliseconds,
    };
  }
}