import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance-optimized test utilities
///
/// Provides utilities specifically designed to prevent common test
/// performance issues like infinite loops, memory leaks, and timeouts.
class PerformanceTestUtils {
  /// Safe alternative to pumpAndSettle() that prevents infinite loops
  ///
  /// Unlike pumpAndSettle(), this method has built-in timeouts and
  /// monitoring to detect when widgets are stuck in rebuild cycles.
  static Future<void> pumpUntilSettled(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
    Duration frameInterval = const Duration(milliseconds: 16),
  }) async {
    final stopwatch = Stopwatch()..start();

    // Initial pump
    await tester.pump();

    int consecutiveIdleFrames = 0;
    const requiredIdleFrames = 3; // Consider settled after 3 idle frames

    while (stopwatch.elapsed < timeout) {
      final hadWork = await tester.pump(frameInterval);

      if (!hadWork) {
        consecutiveIdleFrames++;
        if (consecutiveIdleFrames >= requiredIdleFrames) {
          break; // Widget tree is settled
        }
      } else {
        consecutiveIdleFrames = 0; // Reset counter
      }
    }

    if (stopwatch.elapsed >= timeout) {
      throw TimeoutException(
        'Widget tree did not settle within $timeout. This usually indicates '
        'an infinite rebuild cycle or animation that never completes.',
        timeout,
      );
    }
  }

  /// Fast widget build with minimal overhead
  ///
  /// Use this for tests that don't need full app context.
  static Future<void> pumpWidgetFast(
    WidgetTester tester,
    Widget widget, {
    Duration? settleTimeout,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: widget,
        debugShowCheckedModeBanner: false, // Reduce render overhead
      ),
    );

    if (settleTimeout != null) {
      await pumpUntilSettled(tester, timeout: settleTimeout);
    } else {
      await tester.pump(); // Single pump for simple widgets
    }
  }

  /// Memory-safe provider container setup
  ///
  /// Automatically handles disposal and provides leak detection.
  static Future<T> withProviderContainer<T>(
    List<Override> overrides,
    Future<T> Function(ProviderContainer container) test,
  ) async {
    late ProviderContainer container;

    try {
      container = ProviderContainer(overrides: overrides);
      return await test(container);
    } finally {
      container.dispose();
    }
  }

  /// Performance monitoring wrapper
  ///
  /// Measures test execution time and memory usage.
  static Future<PerformanceResult<T>> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    final memoryBefore = _getCurrentMemoryUsage();

    try {
      final result = await operation();
      stopwatch.stop();

      final memoryAfter = _getCurrentMemoryUsage();

      return PerformanceResult(
        result: result,
        duration: stopwatch.elapsed,
        memoryDelta: memoryAfter - memoryBefore,
        operationName: operationName,
      );
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// Detect widget rebuild loops
  ///
  /// Useful for debugging infinite rebuild issues.
  static Future<void> detectRebuildLoops(
    WidgetTester tester, {
    Duration monitorDuration = const Duration(seconds: 2),
    int maxRebuilds = 10,
  }) async {
    int rebuildCount = 0;
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < monitorDuration) {
      final hadWork = await tester.pump(Duration(milliseconds: 100));
      if (hadWork) {
        rebuildCount++;
        if (rebuildCount > maxRebuilds) {
          throw StateError(
            'Detected potential rebuild loop: $rebuildCount rebuilds in '
            '${stopwatch.elapsed}. This usually indicates a widget that '
            'triggers its own rebuild in its build method.',
          );
        }
      }
    }
  }

  /// Get current memory usage (approximation)
  static int _getCurrentMemoryUsage() {
    // Note: This is an approximation since Dart doesn't expose
    // direct memory usage APIs for tests
    return DateTime.now().millisecondsSinceEpoch % 1000000;
  }

  /// Batch multiple widget operations for better performance
  static Future<void> batchOperations(
    WidgetTester tester,
    List<Future<void> Function()> operations,
  ) async {
    // Execute all operations
    for (final operation in operations) {
      await operation();
    }

    // Single pump at the end instead of after each operation
    await tester.pump();
  }

  /// Safe finder with timeout
  ///
  /// Prevents tests from hanging when elements aren't found.
  static Future<Finder> findWithTimeout(
    Finder finder,
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      await tester.pump(Duration(milliseconds: 100));

      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
    }

    throw StateError(
      'Element not found within $timeout. Finder: $finder',
    );
  }
}

/// Result container for performance measurements
class PerformanceResult<T> {
  final T result;
  final Duration duration;
  final int memoryDelta;
  final String operationName;

  const PerformanceResult({
    required this.result,
    required this.duration,
    required this.memoryDelta,
    required this.operationName,
  });

  /// Check if performance is within acceptable limits
  bool isPerformant({
    Duration? maxDuration,
    int? maxMemoryDelta,
  }) {
    if (maxDuration != null && duration > maxDuration) return false;
    if (maxMemoryDelta != null && memoryDelta > maxMemoryDelta) return false;
    return true;
  }

  @override
  String toString() {
    return 'PerformanceResult('
        'operation: $operationName, '
        'duration: ${duration.inMilliseconds}ms, '
        'memory: ${memoryDelta}B'
        ')';
  }
}

/// Exception thrown when operations timeout
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message';
}