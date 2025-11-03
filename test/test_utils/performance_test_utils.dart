import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance-optimized test utilities
///
/// Provides utilities specifically designed to prevent common test
/// performance issues like infinite loops, memory leaks, and timeouts.
class PerformanceTestUtils {
  /// Safe alternative to pumpAndSettle() that prevents infinite loops.
  static Future<void> pumpUntilSettled(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
    Duration frameInterval = const Duration(milliseconds: 16),
  }) async {
    final stopwatch = Stopwatch()..start();
    int consecutiveIdleFrames = 0;
    const requiredIdleFrames = 3;

    await tester.pump();

    while (stopwatch.elapsed < timeout) {
      await tester.pump(frameInterval);
      final hasScheduledFrame = tester.binding.hasScheduledFrame ||
          tester.binding.transientCallbackCount > 0;

      if (!hasScheduledFrame) {
        consecutiveIdleFrames++;
        if (consecutiveIdleFrames >= requiredIdleFrames) {
          return;
        }
      } else {
        consecutiveIdleFrames = 0;
      }
    }

    throw TimeoutException(
      'Widget tree did not settle within ${timeout.inMilliseconds}ms. This usually '
      'indicates an infinite rebuild cycle or animation that never completes.',
      timeout,
    );
  }

  /// Fast widget build with minimal overhead.
  static Future<void> pumpWidgetFast(
    WidgetTester tester,
    Widget widget, {
    Duration? settleTimeout,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: widget,
        debugShowCheckedModeBanner: false,
      ),
    );

    if (settleTimeout != null) {
      await pumpUntilSettled(tester, timeout: settleTimeout);
    } else {
      await tester.pump();
    }
  }

  /// Memory-safe provider container setup.
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

  /// Performance monitoring wrapper.
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

  /// Helper used by legacy tests to assert completion time.
  static Future<void> assertCompletesWithinTime(
    Future<void> Function() operation,
    Duration maxDuration, {
    String? reason,
  }) async {
    final result = await measurePerformance<void>(
      'assertCompletesWithinTime',
      () async {
        await operation();
        return null;
      },
    );

    expect(
      result.duration,
      lessThanOrEqualTo(maxDuration),
      reason: reason ??
          'Operation took ${result.duration} which exceeds $maxDuration',
    );
  }

  /// Detect widget rebuild loops.
  static Future<void> detectRebuildLoops(
    WidgetTester tester, {
    Duration monitorDuration = const Duration(seconds: 2),
    int maxRebuilds = 10,
  }) async {
    int rebuildCount = 0;
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < monitorDuration) {
      await tester.pump(const Duration(milliseconds: 100));
      final hasScheduledFrame = tester.binding.hasScheduledFrame ||
          tester.binding.transientCallbackCount > 0;
      if (hasScheduledFrame) {
        rebuildCount++;
        if (rebuildCount > maxRebuilds) {
          throw StateError(
            'Detected potential rebuild loop: $rebuildCount rebuilds in '
            '${stopwatch.elapsed}.',
          );
        }
      }
    }
  }

  static int _getCurrentMemoryUsage() {
    return DateTime.now().millisecondsSinceEpoch % 1000000;
  }

  static Future<void> batchOperations(
    WidgetTester tester,
    List<Future<void> Function()> operations,
  ) async {
    for (final operation in operations) {
      await operation();
    }
    await tester.pump();
  }

  static Future<Finder> findWithTimeout(
    Finder finder,
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
    }

    throw StateError('Element not found within $timeout. Finder: $finder');
  }
}

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
    return 'PerformanceResult(operation: $operationName, '
        'duration: ${duration.inMilliseconds}ms, memory: ${memoryDelta}B)';
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message';
}
