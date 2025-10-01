import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../../lib/domain/services/resilience/circuit_breaker_service.dart';
import '../../../../lib/domain/services/resilience/circuit_breaker_config.dart';
import '../../../../lib/domain/services/resilience/circuit_breaker_state.dart';
import '../../../../lib/domain/services/resilience/circuit_breaker_exceptions.dart';

import 'circuit_breaker_service_test.mocks.dart';

abstract class TestService {
  Future<String> call();
}

@GenerateMocks([TestService])

void main() {
  group('CircuitBreakerService', () {
    late CircuitBreakerService circuitBreaker;
    late MockTestService mockService;
    late CircuitBreakerConfig config;

    setUp(() {
      mockService = MockTestService();
      config = const CircuitBreakerConfig(
        failureThreshold: 3,
        timeoutDuration: Duration(seconds: 5),
        recoveryTimeout: Duration(seconds: 30),
        maxRetries: 3,
        backoffMultiplier: 2.0,
      );
      circuitBreaker = CircuitBreakerService(config);
    });

    group('Circuit States', () {
      test('should start in closed state', () {
        expect(circuitBreaker.state, equals(CircuitBreakerState.closed));
        expect(circuitBreaker.failureCount, equals(0));
        expect(circuitBreaker.isOperational, isTrue);
      });

      test('should transition to open state after threshold failures', () async {
        // Mock service to always fail
        when(mockService.call()).thenThrow(Exception('Service error'));

        // Execute failures up to threshold
        for (int i = 0; i < config.failureThreshold; i++) {
          try {
            await circuitBreaker.execute(() => mockService.call());
          } catch (e) {
            // Expected to fail
          }
        }

        expect(circuitBreaker.state, equals(CircuitBreakerState.open));
        expect(circuitBreaker.failureCount, equals(config.failureThreshold));
        expect(circuitBreaker.isOperational, isFalse);
      });

      test('should reject requests immediately when open', () async {
        // Force circuit to open state
        circuitBreaker.forceOpen();

        expect(() => circuitBreaker.execute(() => mockService.call()),
            throwsA(isA<CircuitBreakerOpenException>()));

        // Verify service was never called
        verifyNever(mockService.call());
      });

      test('should transition to half-open after recovery timeout', () async {
        // Force circuit to open
        circuitBreaker.forceOpen();
        expect(circuitBreaker.state, equals(CircuitBreakerState.open));

        // Wait for recovery timeout (simulate by manually triggering)
        await circuitBreaker.attemptRecovery();

        expect(circuitBreaker.state, equals(CircuitBreakerState.halfOpen));
      });

      test('should close circuit after successful call in half-open state', () async {
        // Set to half-open state
        circuitBreaker.transitionToHalfOpen();
        when(mockService.call()).thenAnswer((_) async => 'success');

        final result = await circuitBreaker.execute(() => mockService.call());

        expect(result, equals('success'));
        expect(circuitBreaker.state, equals(CircuitBreakerState.closed));
        expect(circuitBreaker.failureCount, equals(0));
      });

      test('should reopen circuit after failure in half-open state', () async {
        // Set to half-open state
        circuitBreaker.transitionToHalfOpen();
        when(mockService.call()).thenThrow(Exception('Still failing'));

        try {
          await circuitBreaker.execute(() => mockService.call());
        } catch (e) {
          // Expected to fail
        }

        expect(circuitBreaker.state, equals(CircuitBreakerState.open));
      });
    });

    group('Retry Logic', () {
      test('should retry failed operations according to config', () async {
        var attempts = 0;
        when(mockService.call()).thenAnswer((_) async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Temporary failure');
          }
          return 'success after retries';
        });

        final result = await circuitBreaker.execute(() => mockService.call());

        expect(result, equals('success after retries'));
        expect(attempts, equals(3));
      });

      test('should apply exponential backoff between retries', () async {
        final stopwatch = Stopwatch()..start();
        var attempts = 0;

        when(mockService.call()).thenAnswer((_) async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Retry needed');
          }
          return 'success';
        });

        await circuitBreaker.execute(() => mockService.call());

        stopwatch.stop();
        // With backoff multiplier 2.0, expect at least some delay
        expect(stopwatch.elapsedMilliseconds, greaterThan(100));
      });

      test('should fail after max retries exceeded', () async {
        when(mockService.call()).thenThrow(Exception('Persistent failure'));

        expect(() => circuitBreaker.execute(() => mockService.call()),
            throwsA(isA<MaxRetriesExceededException>()));
      });
    });

    group('Timeout Handling', () {
      test('should timeout long-running operations', () async {
        when(mockService.call()).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 10)); // Longer than timeout
          return 'should not reach here';
        });

        expect(() => circuitBreaker.execute(() => mockService.call()),
            throwsA(isA<CircuitBreakerTimeoutException>()));
      });

      test('should not timeout fast operations', () async {
        when(mockService.call()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100)); // Fast operation
          return 'success';
        });

        final result = await circuitBreaker.execute(() => mockService.call());
        expect(result, equals('success'));
      });
    });

    group('Metrics and Monitoring', () {
      test('should track success metrics', () async {
        when(mockService.call()).thenAnswer((_) async => 'success');

        await circuitBreaker.execute(() => mockService.call());
        await circuitBreaker.execute(() => mockService.call());

        final metrics = circuitBreaker.getMetrics();
        expect(metrics.totalRequests, equals(2));
        expect(metrics.successfulRequests, equals(2));
        expect(metrics.failedRequests, equals(0));
        expect(metrics.successRate, equals(1.0));
      });

      test('should track failure metrics', () async {
        when(mockService.call()).thenThrow(Exception('Service error'));

        try {
          await circuitBreaker.execute(() => mockService.call());
        } catch (e) {
          // Expected failure
        }

        final metrics = circuitBreaker.getMetrics();
        expect(metrics.totalRequests, equals(1));
        expect(metrics.successfulRequests, equals(0));
        expect(metrics.failedRequests, equals(1));
        expect(metrics.successRate, equals(0.0));
      });

      test('should track average response time', () async {
        when(mockService.call()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return 'success';
        });

        await circuitBreaker.execute(() => mockService.call());

        final metrics = circuitBreaker.getMetrics();
        expect(metrics.averageResponseTime.inMilliseconds, greaterThan(90));
        expect(metrics.averageResponseTime.inMilliseconds, lessThan(150));
      });

      test('should provide detailed health status', () async {
        final healthStatus = circuitBreaker.getHealthStatus();

        expect(healthStatus.isHealthy, isTrue);
        expect(healthStatus.state, equals(CircuitBreakerState.closed));
        expect(healthStatus.uptime, isA<Duration>());
        expect(healthStatus.lastFailure, isNull);
      });
    });

    group('Configuration', () {
      test('should respect custom failure threshold', () async {
        final customConfig = CircuitBreakerConfig(
          failureThreshold: 1, // Single failure triggers open
          timeoutDuration: Duration(seconds: 5),
          recoveryTimeout: Duration(seconds: 30),
        );
        final customCircuitBreaker = CircuitBreakerService(customConfig);

        when(mockService.call()).thenThrow(Exception('Single failure'));

        try {
          await customCircuitBreaker.execute(() => mockService.call());
        } catch (e) {
          // Expected failure
        }

        expect(customCircuitBreaker.state, equals(CircuitBreakerState.open));
      });

      test('should allow runtime configuration updates', () {
        final newConfig = CircuitBreakerConfig(
          failureThreshold: 5,
          timeoutDuration: Duration(seconds: 10),
          recoveryTimeout: Duration(minutes: 1),
        );

        circuitBreaker.updateConfiguration(newConfig);

        expect(circuitBreaker.configuration.failureThreshold, equals(5));
        expect(circuitBreaker.configuration.timeoutDuration, equals(Duration(seconds: 10)));
      });
    });

    group('Fallback Mechanisms', () {
      test('should execute fallback when circuit is open', () async {
        circuitBreaker.forceOpen();

        final result = await circuitBreaker.executeWithFallback(
          () => mockService.call(),
          () async => 'fallback result',
        );

        expect(result, equals('fallback result'));
        verifyNever(mockService.call());
      });

      test('should use primary service when circuit is closed', () async {
        when(mockService.call()).thenAnswer((_) async => 'primary result');

        final result = await circuitBreaker.executeWithFallback(
          () => mockService.call(),
          () async => 'fallback result',
        );

        expect(result, equals('primary result'));
        verify(mockService.call()).called(1);
      });
    });

    group('Concurrent Operations', () {
      test('should handle concurrent requests safely', () async {
        when(mockService.call()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return 'success';
        });

        // Execute multiple concurrent requests
        final futures = List.generate(10, (index) =>
          circuitBreaker.execute(() => mockService.call())
        ).cast<Future<String>>();

        final results = await Future.wait(futures);

        expect(results.length, equals(10));
        expect(results.every((result) => result == 'success'), isTrue);
      });

      test('should track concurrent request metrics accurately', () async {
        when(mockService.call()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return 'success';
        });

        final futures = List.generate(5, (index) =>
          circuitBreaker.execute(() => mockService.call())
        ).cast<Future<String>>();

        await Future.wait(futures);

        final metrics = circuitBreaker.getMetrics();
        expect(metrics.totalRequests, equals(5));
        expect(metrics.successfulRequests, equals(5));
      });
    });

    group('Recovery Mechanisms', () {
      test('should automatically attempt recovery after timeout', () async {
        // Open the circuit
        circuitBreaker.forceOpen();
        expect(circuitBreaker.state, equals(CircuitBreakerState.open));

        // Simulate recovery timeout passing
        await circuitBreaker.attemptRecovery();
        expect(circuitBreaker.state, equals(CircuitBreakerState.halfOpen));

        // Successful call should close the circuit
        when(mockService.call()).thenAnswer((_) async => 'recovered');
        final result = await circuitBreaker.execute(() => mockService.call());

        expect(result, equals('recovered'));
        expect(circuitBreaker.state, equals(CircuitBreakerState.closed));
      });

      test('should reset failure count on successful recovery', () async {
        // Accumulate some failures
        when(mockService.call()).thenThrow(Exception('Failure'));

        try {
          await circuitBreaker.execute(() => mockService.call());
        } catch (e) { }

        expect(circuitBreaker.failureCount, greaterThan(0));

        // Successful call should reset counter
        when(mockService.call()).thenAnswer((_) async => 'success');
        await circuitBreaker.execute(() => mockService.call());

        expect(circuitBreaker.failureCount, equals(0));
      });
    });
  });
}