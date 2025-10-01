import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/cache/statistics/cache_statistics_service.dart';

void main() {
  group('CacheStatisticsService', () {
    late CacheStatisticsService statisticsService;

    setUp(() {
      statisticsService = CacheStatisticsService();
    });

    tearDown(() {
      statisticsService.dispose();
    });

    group('Basic Statistics Recording', () {
      test('should record access correctly', () {
        expect(statisticsService.hitRate, equals(0.0));
        expect(statisticsService.missRate, equals(0.0));

        statisticsService.recordAccess();
        statisticsService.recordHit();

        expect(statisticsService.hitRate, equals(1.0));
        expect(statisticsService.missRate, equals(0.0));
      });

      test('should record miss correctly', () {
        statisticsService.recordAccess();
        statisticsService.recordMiss();

        expect(statisticsService.hitRate, equals(0.0));
        expect(statisticsService.missRate, equals(1.0));
      });

      test('should calculate correct hit and miss rates', () {
        // Record 3 accesses: 2 hits, 1 miss
        statisticsService.recordAccess();
        statisticsService.recordHit();

        statisticsService.recordAccess();
        statisticsService.recordHit();

        statisticsService.recordAccess();
        statisticsService.recordMiss();

        expect(statisticsService.hitRate, closeTo(0.667, 0.001));
        expect(statisticsService.missRate, closeTo(0.333, 0.001));
      });

      test('should record writes and evictions', () {
        statisticsService.recordWrite();
        statisticsService.recordEviction();

        final stats = statisticsService.getStatistics();
        expect(stats['writes'], equals(1));
        expect(stats['evictions'], equals(1));
      });
    });

    group('Performance Metrics', () {
      test('should calculate requests per second', () {
        // Record multiple accesses
        for (int i = 0; i < 10; i++) {
          statisticsService.recordAccess();
        }

        // Should have positive RPS (exact value depends on timing)
        expect(statisticsService.requestsPerSecond, greaterThanOrEqualTo(0.0));
      });

      test('should track recent requests per second', () {
        // Record accesses
        for (int i = 0; i < 5; i++) {
          statisticsService.recordAccess();
        }

        expect(statisticsService.recentRequestsPerSecond, greaterThanOrEqualTo(0.0));
      });

      test('should calculate effectiveness score', () {
        // Perfect scenario: all hits, some usage
        statisticsService.recordAccess();
        statisticsService.recordHit();
        statisticsService.recordWrite();

        final score = statisticsService.effectivenessScore;
        expect(score, greaterThan(0.0));
        expect(score, lessThanOrEqualTo(100.0));
      });
    });

    group('Performance Grading', () {
      test('should assign correct performance grades', () {
        // High effectiveness scenario
        for (int i = 0; i < 100; i++) {
          statisticsService.recordAccess();
          statisticsService.recordHit();
        }
        statisticsService.recordWrite();

        final report = statisticsService.getPerformanceReport();
        final grade = report['summary']['grade'];

        expect(['A+', 'A', 'B'].contains(grade), isTrue);
      });

      test('should provide access frequency classification', () {
        final stats = statisticsService.getStatistics();
        final performance = stats['performance'] as Map<String, dynamic>;
        final frequency = performance['accessFrequency'];

        expect(['High', 'Medium', 'Low', 'Minimal'].contains(frequency), isTrue);
      });
    });

    group('Statistics Reset', () {
      test('should reset all statistics', () {
        // Record some stats
        statisticsService.recordAccess();
        statisticsService.recordHit();
        statisticsService.recordWrite();
        statisticsService.recordEviction();

        // Verify stats exist
        expect(statisticsService.hitRate, greaterThan(0.0));

        // Reset and verify
        statisticsService.reset();
        expect(statisticsService.hitRate, equals(0.0));
        expect(statisticsService.missRate, equals(0.0));

        final stats = statisticsService.getStatistics();
        expect(stats['totalAccesses'], equals(0));
        expect(stats['hits'], equals(0));
        expect(stats['misses'], equals(0));
        expect(stats['writes'], equals(0));
        expect(stats['evictions'], equals(0));
      });
    });

    group('Performance Recommendations', () {
      test('should provide recommendations for low hit rate', () {
        // Create low hit rate scenario
        for (int i = 0; i < 10; i++) {
          statisticsService.recordAccess();
          statisticsService.recordMiss();
        }

        final report = statisticsService.getPerformanceReport();
        final recommendations = report['recommendations'] as List<String>;

        expect(recommendations.any((r) => r.contains('hit rate')), isTrue);
      });

      test('should provide recommendations for no writes', () {
        // Access without writes
        statisticsService.recordAccess();
        statisticsService.recordMiss();

        final report = statisticsService.getPerformanceReport();
        final recommendations = report['recommendations'] as List<String>;

        expect(
          recommendations.any((r) => r.contains('No writes detected')),
          isTrue,
        );
      });

      test('should indicate optimal performance when appropriate', () {
        // Good scenario
        for (int i = 0; i < 10; i++) {
          statisticsService.recordAccess();
          statisticsService.recordHit();
        }
        statisticsService.recordWrite();

        final report = statisticsService.getPerformanceReport();
        final recommendations = report['recommendations'] as List<String>;

        // Should either have specific recommendations or indicate optimal performance
        expect(recommendations, isNotEmpty);
      });
    });

    group('Statistics Snapshots', () {
      test('should create accurate snapshot', () {
        // Record some statistics
        statisticsService.recordAccess();
        statisticsService.recordHit();
        statisticsService.recordWrite();

        final snapshot = statisticsService.createSnapshot();

        expect(snapshot.totalAccesses, equals(1));
        expect(snapshot.hits, equals(1));
        expect(snapshot.writes, equals(1));
        expect(snapshot.hitRate, equals(1.0));
        expect(snapshot.timestamp, isA<DateTime>());
      });

      test('should compare snapshots correctly', () {
        // Initial snapshot
        statisticsService.recordAccess();
        statisticsService.recordHit();
        final snapshot1 = statisticsService.createSnapshot();

        // Add more statistics
        statisticsService.recordAccess();
        statisticsService.recordMiss();
        statisticsService.recordWrite();
        final snapshot2 = statisticsService.createSnapshot();

        final comparison = snapshot2.compareTo(snapshot1);

        expect(comparison['accessesDelta'], equals(1));
        expect(comparison['hitsDelta'], equals(0));
        expect(comparison['missesDelta'], equals(1));
        expect(comparison['writesDelta'], equals(1));
      });
    });

    group('Comprehensive Statistics', () {
      test('should provide complete statistics map', () {
        // Record varied statistics
        statisticsService.recordAccess();
        statisticsService.recordHit();
        statisticsService.recordAccess();
        statisticsService.recordMiss();
        statisticsService.recordWrite();
        statisticsService.recordEviction();

        final stats = statisticsService.getStatistics();

        // Verify all expected fields are present
        expect(stats['totalAccesses'], isA<int>());
        expect(stats['hits'], isA<int>());
        expect(stats['misses'], isA<int>());
        expect(stats['writes'], isA<int>());
        expect(stats['evictions'], isA<int>());
        expect(stats['hitRate'], isA<double>());
        expect(stats['missRate'], isA<double>());
        expect(stats['uptimeSeconds'], isA<int>());
        expect(stats['requestsPerSecond'], isA<double>());
        expect(stats['recentRequestsPerSecond'], isA<double>());
        expect(stats['effectivenessScore'], isA<double>());
        expect(stats['performance'], isA<Map>());
      });

      test('should handle edge cases gracefully', () {
        // No statistics recorded
        final stats = statisticsService.getStatistics();

        expect(stats['hitRate'], equals(0.0));
        expect(stats['missRate'], equals(0.0));
        expect(stats['requestsPerSecond'], greaterThanOrEqualTo(0.0));
        expect(stats['effectivenessScore'], equals(0.0));
      });
    });
  });

  group('CacheStatisticsSnapshot', () {
    test('should serialize to map correctly', () {
      final snapshot = CacheStatisticsSnapshot(
        timestamp: DateTime.now(),
        totalAccesses: 100,
        hits: 80,
        misses: 20,
        writes: 50,
        evictions: 5,
        hitRate: 0.8,
        requestsPerSecond: 10.5,
      );

      final map = snapshot.toMap();

      expect(map['totalAccesses'], equals(100));
      expect(map['hits'], equals(80));
      expect(map['misses'], equals(20));
      expect(map['writes'], equals(50));
      expect(map['evictions'], equals(5));
      expect(map['hitRate'], equals(0.8));
      expect(map['requestsPerSecond'], equals(10.5));
      expect(map['timestamp'], isA<String>());
    });

    test('should compare snapshots with delta calculation', () {
      final snapshot1 = CacheStatisticsSnapshot(
        timestamp: DateTime.now().subtract(const Duration(seconds: 60)),
        totalAccesses: 50,
        hits: 40,
        misses: 10,
        writes: 25,
        evictions: 2,
        hitRate: 0.8,
        requestsPerSecond: 5.0,
      );

      final snapshot2 = CacheStatisticsSnapshot(
        timestamp: DateTime.now(),
        totalAccesses: 100,
        hits: 85,
        misses: 15,
        writes: 50,
        evictions: 3,
        hitRate: 0.85,
        requestsPerSecond: 8.0,
      );

      final delta = snapshot2.compareTo(snapshot1);

      expect(delta['accessesDelta'], equals(50));
      expect(delta['hitsDelta'], equals(45));
      expect(delta['missesDelta'], equals(5));
      expect(delta['writesDelta'], equals(25));
      expect(delta['evictionsDelta'], equals(1));
      expect(delta['hitRateDelta'], closeTo(0.05, 0.001));
      expect(delta['rpsChange'], closeTo(3.0, 0.001));
      expect(delta['timeDelta'], equals(60));
    });
  });
}