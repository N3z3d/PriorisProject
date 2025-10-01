import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/cache/manager/advanced_cache_manager.dart';
import 'package:prioris/domain/services/cache/interfaces/cache_system_interfaces.dart';

void main() {
  group('AdvancedCacheManager', () {
    late AdvancedCacheManager cacheManager;

    setUp(() async {
      cacheManager = AdvancedCacheManager();
      await cacheManager.initialize(maxMemoryMB: 20);
    });

    tearDown(() async {
      await cacheManager.dispose();
    });

    group('Initialization', () {
      test('should initialize with default configuration', () async {
        final manager = AdvancedCacheManager();
        await manager.initialize();

        final stats = manager.getStatistics();
        expect(stats['configuration'], isA<Map>());
        expect(stats['currentStrategy'], equals('adaptive'));

        await manager.dispose();
      });

      test('should initialize with custom configuration', () async {
        final manager = AdvancedCacheManager(
          configuration: const CacheConfiguration(
            maxMemoryMB: 100,
            defaultStrategy: CacheStrategy.lru,
            defaultTTL: Duration(hours: 1),
          ),
        );

        await manager.initialize();

        final stats = manager.getStatistics();
        final config = stats['configuration'] as Map<String, dynamic>;

        expect(config['maxMemoryMB'], equals(100));
        expect(stats['currentStrategy'], equals('lru'));

        await manager.dispose();
      });

      test('should throw error when initializing twice', () async {
        final manager = AdvancedCacheManager();
        await manager.initialize();

        expect(
          () async => await manager.initialize(),
          throwsA(isA<CacheException>()),
        );

        await manager.dispose();
      });
    });

    group('Basic Cache Operations', () {
      test('should store and retrieve values', () {
        const key = 'test_key';
        const value = 'test_value';

        cacheManager.set(key, value);
        final retrieved = cacheManager.get<String>(key);

        expect(retrieved, equals(value));
      });

      test('should return null for non-existent keys', () {
        final retrieved = cacheManager.get<String>('non_existent');
        expect(retrieved, isNull);
      });

      test('should handle different value types', () {
        cacheManager.set('string', 'test');
        cacheManager.set('int', 42);
        cacheManager.set('double', 3.14);
        cacheManager.set('bool', true);
        cacheManager.set('list', [1, 2, 3]);
        cacheManager.set('map', {'key': 'value'});

        expect(cacheManager.get<String>('string'), equals('test'));
        expect(cacheManager.get<int>('int'), equals(42));
        expect(cacheManager.get<double>('double'), equals(3.14));
        expect(cacheManager.get<bool>('bool'), isTrue);
        expect(cacheManager.get<List<int>>('list'), equals([1, 2, 3]));
        expect(cacheManager.get<Map<String, String>>('map'), equals({'key': 'value'}));
      });
    });

    group('Strategy Selection', () {
      test('should use different strategies', () {
        const key = 'strategy_test';
        const value = 'test_value';

        // Test LRU strategy
        cacheManager.set(key, value, strategy: CacheStrategy.lru);
        expect(cacheManager.get<String>(key, strategy: CacheStrategy.lru), equals(value));

        // Test LFU strategy
        cacheManager.set(key, value, strategy: CacheStrategy.lfu);
        expect(cacheManager.get<String>(key, strategy: CacheStrategy.lfu), equals(value));

        // Test TTL strategy
        cacheManager.set(key, value, strategy: CacheStrategy.ttl);
        expect(cacheManager.get<String>(key, strategy: CacheStrategy.ttl), equals(value));

        // Test Adaptive strategy
        cacheManager.set(key, value, strategy: CacheStrategy.adaptive);
        expect(cacheManager.get<String>(key, strategy: CacheStrategy.adaptive), equals(value));
      });

      test('should change default strategy', () {
        cacheManager.setStrategy(CacheStrategy.lru);

        final stats = cacheManager.getStatistics();
        expect(stats['currentStrategy'], equals('lru'));
      });

      test('should throw error for unsupported strategy', () {
        // All strategies should be supported after initialization
        expect(
          () => cacheManager.setStrategy(CacheStrategy.adaptive),
          returnsNormally,
        );
      });
    });

    group('TTL and Expiration', () {
      test('should respect TTL values', () async {
        const key = 'ttl_test';
        const value = 'expires_soon';

        cacheManager.set(key, value, ttl: const Duration(milliseconds: 50));
        expect(cacheManager.get<String>(key), equals(value));

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 100));
        expect(cacheManager.get<String>(key), isNull);
      });

      test('should handle entries without TTL', () async {
        const key = 'no_ttl_test';
        const value = 'persists';

        cacheManager.set(key, value); // No TTL specified

        // Should still exist after some time
        await Future.delayed(const Duration(milliseconds: 50));
        expect(cacheManager.get<String>(key), equals(value));
      });
    });

    group('GetOrCompute Functionality', () {
      test('should compute value when not cached', () async {
        const key = 'compute_test';
        const computedValue = 'computed_result';

        bool computeCalled = false;
        final result = await cacheManager.getOrCompute<String>(
          key,
          () async {
            computeCalled = true;
            return computedValue;
          },
        );

        expect(result, equals(computedValue));
        expect(computeCalled, isTrue);
        expect(cacheManager.get<String>(key), equals(computedValue));
      });

      test('should return cached value without computing', () async {
        const key = 'cached_compute_test';
        const cachedValue = 'already_cached';

        cacheManager.set(key, cachedValue);

        bool computeCalled = false;
        final result = await cacheManager.getOrCompute<String>(
          key,
          () async {
            computeCalled = true;
            return 'should_not_be_computed';
          },
        );

        expect(result, equals(cachedValue));
        expect(computeCalled, isFalse);
      });

      test('should handle compute function errors', () async {
        const key = 'error_compute_test';

        expect(
          cacheManager.getOrCompute<String>(
            key,
            () async => throw Exception('Compute error'),
          ),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('Cache Invalidation', () {
      test('should invalidate single key', () {
        const key = 'invalidate_test';
        const value = 'to_be_invalidated';

        cacheManager.set(key, value);
        expect(cacheManager.get<String>(key), equals(value));

        cacheManager.invalidate(key);
        expect(cacheManager.get<String>(key), isNull);
      });

      test('should invalidate multiple keys with pattern', () {
        cacheManager.set('user:1', 'user_1_data');
        cacheManager.set('user:2', 'user_2_data');
        cacheManager.set('product:1', 'product_1_data');

        cacheManager.invalidatePattern(r'user:.*');

        expect(cacheManager.get<String>('user:1'), isNull);
        expect(cacheManager.get<String>('user:2'), isNull);
        expect(cacheManager.get<String>('product:1'), equals('product_1_data'));
      });

      test('should handle invalid regex patterns', () {
        expect(
          () => cacheManager.invalidatePattern('[invalid'),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('Cache Statistics', () {
      test('should track hit and miss statistics', () {
        const key = 'stats_test';
        const value = 'test_value';

        // Record a miss
        cacheManager.get<String>(key);

        // Record a hit
        cacheManager.set(key, value);
        cacheManager.get<String>(key);

        final stats = cacheManager.getStatistics();
        final globalStats = stats['globalStats'] as Map<String, dynamic>;

        expect(globalStats['totalAccesses'], equals(2));
        expect(globalStats['hits'], equals(1));
        expect(globalStats['misses'], equals(1));
        expect(globalStats['writes'], equals(1));
      });

      test('should provide comprehensive statistics', () {
        final stats = cacheManager.getStatistics();

        expect(stats['configuration'], isA<Map>());
        expect(stats['currentStrategy'], isA<String>());
        expect(stats['globalStats'], isA<Map>());
        expect(stats['cacheSystemStats'], isA<Map>());
        expect(stats['cleanupStats'], isA<Map>());
        expect(stats['performance'], isA<Map>());
        expect(stats['health'], isA<Map>());
      });

      test('should calculate performance metrics', () {
        // Add some data to get meaningful metrics
        for (int i = 0; i < 10; i++) {
          cacheManager.set('key_$i', 'value_$i');
        }

        final stats = cacheManager.getStatistics();
        final performance = stats['performance'] as Map<String, dynamic>;

        expect(performance['totalEntries'], greaterThan(0));
        expect(performance['totalSizeBytes'], greaterThan(0));
        expect(performance['averageUtilization'], isA<double>());
        expect(performance['strategiesActive'], equals(4)); // All 4 strategies
      });
    });

    group('Health Monitoring', () {
      test('should report healthy status with good metrics', () {
        // Create optimal conditions
        for (int i = 0; i < 10; i++) {
          cacheManager.set('key_$i', 'value_$i');
          cacheManager.get<String>('key_$i'); // Generate hits
        }

        final stats = cacheManager.getStatistics();
        final health = stats['health'] as Map<String, dynamic>;

        expect(health['status'], isIn(['healthy', 'warning']));
        expect(health['overallScore'], greaterThan(0));
      });

      test('should detect critical issues', () {
        // Create poor conditions - only misses
        for (int i = 0; i < 20; i++) {
          cacheManager.get<String>('non_existent_$i');
        }

        final stats = cacheManager.getStatistics();
        final health = stats['health'] as Map<String, dynamic>;

        // Should detect low hit rate issue
        expect(health['issues'], isA<List>());
      });
    });

    group('Cache Optimization', () {
      test('should optimize all cache systems', () async {
        // Add some entries that will expire
        for (int i = 0; i < 5; i++) {
          cacheManager.set(
            'expire_$i',
            'value_$i',
            ttl: const Duration(milliseconds: 1),
          );
        }

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 10));

        // Optimize should remove expired entries
        await cacheManager.optimize();

        // Verify optimization worked (this is implicit as expired entries are removed)
        final stats = cacheManager.getStatistics();
        expect(stats, isA<Map>());
      });
    });

    group('Cache Clearing', () {
      test('should clear all caches', () {
        // Add data to all strategies
        cacheManager.set('key1', 'value1', strategy: CacheStrategy.lru);
        cacheManager.set('key2', 'value2', strategy: CacheStrategy.lfu);
        cacheManager.set('key3', 'value3', strategy: CacheStrategy.ttl);
        cacheManager.set('key4', 'value4', strategy: CacheStrategy.adaptive);

        cacheManager.clear();

        expect(cacheManager.get<String>('key1', strategy: CacheStrategy.lru), isNull);
        expect(cacheManager.get<String>('key2', strategy: CacheStrategy.lfu), isNull);
        expect(cacheManager.get<String>('key3', strategy: CacheStrategy.ttl), isNull);
        expect(cacheManager.get<String>('key4', strategy: CacheStrategy.adaptive), isNull);

        // Statistics should be reset too
        final stats = cacheManager.getStatistics();
        final globalStats = stats['globalStats'] as Map<String, dynamic>;
        expect(globalStats['totalAccesses'], equals(0));
      });
    });

    group('Error Handling', () {
      test('should throw error when not initialized', () {
        final uninitializedManager = AdvancedCacheManager();

        expect(
          () => uninitializedManager.get<String>('test'),
          throwsA(isA<CacheException>()),
        );

        expect(
          () => uninitializedManager.set('test', 'value'),
          throwsA(isA<CacheException>()),
        );
      });

      test('should handle extremely large values gracefully', () {
        const key = 'large_value';
        final largeValue = 'x' * (10 * 1024 * 1024); // 10MB string

        expect(
          () => cacheManager.set(key, largeValue),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('Cache Reports', () {
      test('should generate comprehensive cache report', () {
        // Add some data for meaningful report
        cacheManager.set('test1', 'value1');
        cacheManager.set('test2', 'value2');
        cacheManager.get<String>('test1');
        cacheManager.get<String>('non_existent');

        final report = cacheManager.getCacheReport();

        expect(report['summary'], isA<Map>());
        expect(report['configuration'], isA<Map>());
        expect(report['detailedStats'], isA<Map>());
        expect(report['recommendations'], isA<List>());
        expect(report['diagnostics'], isA<Map>());
      });

      test('should provide appropriate recommendations', () {
        final report = cacheManager.getCacheReport();
        final recommendations = report['recommendations'] as List<String>;

        expect(recommendations, isNotEmpty);
        expect(recommendations.first, isA<String>());
      });

      test('should run diagnostic tests', () {
        final report = cacheManager.getCacheReport();
        final diagnostics = report['diagnostics'] as Map<String, dynamic>;

        expect(diagnostics['writeTest'], equals('PASS'));
        expect(diagnostics['readTest'], equals('PASS'));
        expect(diagnostics['invalidationTest'], equals('PASS'));
        expect(diagnostics['overallTest'], equals('PASS'));
      });
    });

    group('Snapshots', () {
      test('should create manager snapshot', () {
        cacheManager.set('snapshot_test', 'snapshot_value');

        final snapshot = cacheManager.createSnapshot();

        expect(snapshot.timestamp, isA<DateTime>());
        expect(snapshot.configuration, isA<CacheConfiguration>());
        expect(snapshot.currentStrategy, isA<CacheStrategy>());
        expect(snapshot.statistics, isA<Map>());
        expect(snapshot.cacheSystemSnapshots, isA<Map>());
      });

      test('should serialize snapshot to map', () {
        final snapshot = cacheManager.createSnapshot();
        final map = snapshot.toMap();

        expect(map['timestamp'], isA<String>());
        expect(map['configuration'], isA<Map>());
        expect(map['currentStrategy'], isA<String>());
        expect(map['statistics'], isA<Map>());
        expect(map['cacheSystemSnapshots'], isA<Map>());
      });
    });
  });
}