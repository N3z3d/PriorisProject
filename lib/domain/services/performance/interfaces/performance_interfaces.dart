/// SOLID Performance Monitoring Interfaces
/// Following Interface Segregation Principle - separate interfaces for different concerns

import 'dart:async';
import 'package:prioris/domain/services/performance/models/performance_models.dart';

/// Interface for basic metrics collection and recording
abstract class IMetricsCollector {
  /// Record a custom metric value
  void recordMetric(String name, double value, {Map<String, dynamic>? tags});

  /// Record a performance event
  void recordEvent(String eventType, Map<String, dynamic> details);

  /// Get current metrics snapshot
  Map<String, dynamic> getCurrentMetrics();

  /// Start tracking an operation
  IOperationTracker startOperation(String operationName);
}

/// Interface for operation tracking
abstract class IOperationTracker {
  /// Add context information to the operation
  void addContext(String key, dynamic value);

  /// Record an intermediate checkpoint
  void checkpoint(String checkpointName);

  /// Complete the operation successfully
  void complete({Map<String, dynamic>? result});

  /// Complete the operation with an error
  void completeWithError(Object error, {StackTrace? stackTrace});
}

/// Interface for alerting system
abstract class IPerformanceAlerting {
  /// Configure an alert handler for specific alert types
  void setAlertHandler(String alertType, Function(PerformanceAlert) handler);

  /// Set alert threshold for a metric
  void setAlertThreshold(String metricName, AlertThreshold threshold);

  /// Check if a metric value triggers an alert
  void checkAlerts(String metricName, double value);

  /// Get recent alerts
  List<PerformanceAlert> getRecentAlerts({Duration? period});

  /// Clear all alert handlers
  void clearAlertHandlers();
}

/// Interface for trend analysis and predictions
abstract class ITrendAnalyzer {
  /// Analyze trends for performance prediction
  Map<String, TrendAnalysis> analyzeTrends({Duration? period});

  /// Analyze trends for a specific metric
  TrendAnalysis analyzeMetricTrend(String metricName, {Duration? period});

  /// Predict future values based on historical trends
  Map<String, double> predictMetrics({Duration? horizon});

  /// Get recommendations based on trend analysis
  List<String> generateRecommendations();
}

/// Interface for memory profiling
abstract class IMemoryProfiler {
  /// Profile memory usage of an operation
  Future<T> profileOperation<T>(String operationName, Future<T> Function() operation);

  /// Get current memory statistics
  Map<String, dynamic> getMemoryStats();

  /// Get memory usage history
  List<MemorySnapshot> getMemoryHistory({Duration? period});

  /// Clear memory profiling data
  void clearMemoryData();
}

/// Interface for performance reporting
abstract class IPerformanceReporter {
  /// Generate a comprehensive performance report
  PerformanceReport generateReport({Duration? period});

  /// Generate a specific metric report
  MetricReport generateMetricReport(String metricName, {Duration? period});

  /// Export report in different formats
  Map<String, dynamic> exportReport(PerformanceReport report, {String format = 'json'});

  /// Get dashboard data for UI
  Map<String, dynamic> getDashboardData();
}

/// Interface for benchmarking operations
abstract class IBenchmarkRunner {
  /// Run automated benchmark for an operation
  Future<BenchmarkResult> benchmark(
    String operationName,
    Future<void> Function() operation, {
    int iterations = 100,
    Duration timeout = const Duration(seconds: 30),
    Map<String, dynamic>? context,
  });

  /// Run comparative benchmark between operations
  Future<ComparisonResult> compareBenchmarks(
    Map<String, Future<void> Function()> operations, {
    int iterations = 100,
  });

  /// Get benchmark history
  List<BenchmarkResult> getBenchmarkHistory({String? operationName});
}

/// Interface for system resource monitoring
abstract class ISystemResourceMonitor {
  /// Get current system resource metrics
  Map<String, dynamic> getSystemMetrics();

  /// Monitor system resources continuously
  void startSystemMonitoring({Duration interval = const Duration(seconds: 5)});

  /// Stop system resource monitoring
  void stopSystemMonitoring();

  /// Get system resource history
  List<SystemSnapshot> getSystemHistory({Duration? period});

  /// Check if system is under stress
  bool isSystemUnderStress();
}

/// Interface for data lifecycle management
abstract class IPerformanceDataManager {
  /// Cleanup old performance data
  void cleanupOldData({Duration? retention});

  /// Archive performance data
  Future<void> archiveData({Duration? cutoff});

  /// Import performance data from archive
  Future<void> importArchivedData({DateTime? from, DateTime? to});

  /// Get data storage statistics
  Map<String, dynamic> getStorageStats();
}

/// Main performance monitoring coordinator interface
abstract class IPerformanceMonitor {
  /// Initialize the performance monitoring system
  Future<void> initialize({PerformanceConfiguration? config});

  /// Get metrics collector instance
  IMetricsCollector get metricsCollector;

  /// Get alerting system instance
  IPerformanceAlerting get alerting;

  /// Get trend analyzer instance
  ITrendAnalyzer get trendAnalyzer;

  /// Get memory profiler instance
  IMemoryProfiler get memoryProfiler;

  /// Get performance reporter instance
  IPerformanceReporter get reporter;

  /// Get benchmark runner instance
  IBenchmarkRunner get benchmarkRunner;

  /// Get system resource monitor instance
  ISystemResourceMonitor get systemMonitor;

  /// Get data manager instance
  IPerformanceDataManager get dataManager;

  /// Check overall system health
  PerformanceHealthStatus getHealthStatus();

  /// Shutdown performance monitoring
  Future<void> shutdown();
}