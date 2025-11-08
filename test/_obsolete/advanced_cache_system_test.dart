import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../../lib/domain/services/cache/advanced_cache_system.dart';
import '../../../../lib/domain/services/cache/cache_policies.dart';
import '../../../../lib/domain/services/cache/cache_statistics.dart';
import '../../../../lib/domain/services/cache/cache_entry.dart';

import 'advanced_cache_system_test.mocks.dart';

abstract class MockStorage {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value);
  Future<void> remove(String key);
  Future<void> clear();
  Future<List<String>> keys();
}

@GenerateMocks([MockStorage])

void main() {
  group('AdvancedCacheSystem', () {
    late AdvancedCacheSystem cacheSystem;
    late MockMockStorage mockPersistentStorage;

    setUp(() {
      mockPersistentStorage = MockMockStorage();
      cacheSystem = AdvancedCacheSystem(
        config: CacheConfig(
          memorySize: 100,
          persistentCacheEnabled: true,
          compressionEnabled: true,
          encryptionEnabled: false, // Disabled for testing
          defaultTtl: Duration(minutes: 30),
        ),
        persistentStorage: mockPersistentStorage,
      );
    });

    group('Multi-Level Caching', () {
      test('should store and retrieve from memory cache', () async {
        const key = 'test_key';
        const value = 'test_value';

        await cacheSystem.set(key, value);
        final result = await cacheSystem.get<String>(key);

        expect(result, equals(value));
      });

      test('should fall back to persistent cache when not in memory', () async {
        const key = 'persistent_key';
        const value = 'persistent_value';

        // Mock persistent storage
        when(mockPersistentStorage.get<String>(key))
            .thenAnswer((_) async => value);

        final result = await cacheSystem.get<String>(key);

        expect(result, equals(value));
        verify(mockPersistentStorage.get<String>(key)).called(1);
      });

      test('should promote from persistent to memory cache on access', () async {
        const key = 'promotion_key';
        const value = 'promotion_value';

        // Mock persistent storage
        when(mockPersistentStorage.get<String>(key))
            .thenAnswer((_) async => value);

        // First access - should hit persistent storage
        final result1 = await cacheSystem.get<String>(key);
        expect(result1, equals(value));

        // Second access - should hit memory cache
        final result2 = await cacheSystem.get<String>(key);
        expect(result2, equals(value));

        // Verify persistent storage was called only once
        verify(mockPersistentStorage.get<String>(key)).called(1);
      });

      test('should handle cache misses gracefully', () async {
        const key = 'missing_key';

        when(mockPersistentStorage.get<String>(key))
            .thenAnswer((_) async => null);

        final result = await cacheSystem.get<String>(key);

        expect(result, isNull);
      });
    });

    group('Cache Policies', () {
      test('should evict items using LRU policy', () async {
        final smallCache = AdvancedCacheSystem(
          config: CacheConfig(
            memorySize: 2, // Small cache for testing eviction
            evictionPolicy: EvictionPolicy.lru,
          ),
        );

        await smallCache.set('key1', 'value1');
        await smallCache.set('key2', 'value2');
        await smallCache.set('key3', 'value3'); // Should evict key1

        final result1 = await smallCache.get('key1');
        final result2 = await smallCache.get('key2');
        final result3 = await smallCache.get('key3');

        expect(result1, isNull); // Evicted
        expect(result2, equals('value2'));
        expect(result3, equals('value3'));
      });

      test('should evict items using LFU policy', () async {
        final smallCache = AdvancedCacheSystem(
          config: CacheConfig(
            memorySize: 2,
            evictionPolicy: EvictionPolicy.lfu,
          ),
        );

        await smallCache.set('key1', 'value1');
        await smallCache.set('key2', 'value2');

        // Access key1 multiple times
        await smallCache.get('key1');
        await smallCache.get('key1');
        await smallCache.get('key2'); // key2 accessed less

        await smallCache.set('key3', 'value3'); // Should evict key2

        final result1 = await smallCache.get('key1');
        final result2 = await smallCache.get('key2');
        final result3 = await smallCache.get('key3');

        expect(result1, equals('value1'));
        expect(result2, isNull); // Evicted (less frequently used)
        expect(result3, equals('value3'));
      });

      test('should handle TTL expiration', () async {
        const shortTtl = Duration(milliseconds: 100);

        await cacheSystem.set('expiring_key', 'expiring_value', ttl: shortTtl);

        // Immediately should be available
        final result1 = await cacheSystem.get('expiring_key');
        expect(result1, equals('expiring_value'));

        // Wait for expiration
        await Future.delayed(Duration(milliseconds: 150));

        final result2 = await cacheSystem.get('expiring_key');
        expect(result2, isNull);
      });
    });

    group('Compression and Serialization', () {
      test('should compress large objects', () async {
        final largeObject = List.generate(1000, (i) => 'Item $i');
        const key = 'large_object';

        await cacheSystem.set(key, largeObject);
        final result = await cacheSystem.get<List<String>>(key);

        expect(result, equals(largeObject));

        // Verify compression was applied
        final stats = await cacheSystem.getStatistics();
        expect(stats.compressionRatio, lessThan(1.0));
      });

      test('should handle complex object serialization', () async {
        final complexObject = {
          'string': 'test',
          'number': 42,
          'list': [1, 2, 3],
          'nested': {'key': 'value'},
        };

        await cacheSystem.set('complex', complexObject);
        final result = await cacheSystem.get<Map<String, dynamic>>('complex');

        expect(result, equals(complexObject));
      });
    });

    group('Cache Warming and Prefetching', () {
      test('should warm cache with predefined keys', () async {
        final warmingData = {
          'warm1': 'value1',
          'warm2': 'value2',
          'warm3': 'value3',
        };

        await cacheSystem.warm(warmingData);

        for (final entry in warmingData.entries) {
          final result = await cacheSystem.get(entry.key);
          expect(result, equals(entry.value));
        }

        final stats = await cacheSystem.getStatistics();
        expect(stats.totalItems, equals(warmingData.length));
      });

      test('should prefetch related keys', () async {
        // Set up initial data
        await cacheSystem.set('user:123', {'name': 'John'});
        await cacheSystem.set('user:124', {'name': 'Jane'});
        await cacheSystem.set('user:125', {'name': 'Bob'});

        // Mock prefetch strategy
        final prefetchStrategy = (String key) async {
          if (key.startsWith('user:')) {
            return ['user:profile:${key.split(':')[1]}'];
          }
          return <String>[];
        };

        await cacheSystem.prefetch('user:123', prefetchStrategy);

        // Verify prefetch was attempted
        final stats = await cacheSystem.getStatistics();
        expect(stats.prefetchAttempts, greaterThan(0));
      });
    });

    group('Cache Statistics and Monitoring', () {
      test('should track cache hit rates', () async {
        await cacheSystem.set('hit_key', 'hit_value');

        // Hit
        await cacheSystem.get('hit_key');
        // Miss
        await cacheSystem.get('miss_key');

        final stats = await cacheSystem.getStatistics();
        expect(stats.hitRate, equals(0.5));
        expect(stats.missRate, equals(0.5));
      });

      test('should track memory usage', () async {
        await cacheSystem.set('memory_key', 'memory_value');

        final stats = await cacheSystem.getStatistics();
        expect(stats.memoryUsage, greaterThan(0));
        expect(stats.memoryUsagePercentage, greaterThan(0));
      });

      test('should provide detailed performance metrics', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await cacheSystem.set('perf_key_$i', 'value_$i');
          await cacheSystem.get('perf_key_$i');
        }

        stopwatch.stop();

        final stats = await cacheSystem.getStatistics();
        expect(stats.totalOperations, equals(200)); // 100 sets + 100 gets
        expect(stats.averageOperationTime.inMicroseconds, greaterThan(0));
      });
    });

    group('Concurrent Operations', () {
      test('should handle concurrent reads and writes safely', () async {
        const key = 'concurrent_key';
        final futures = <Future<void>>[];

        // Concurrent writes
        for (int i = 0; i < 10; i++) {
          futures.add(cacheSystem.set('${key}_$i', 'value_$i'));
        }

        // Concurrent reads
        for (int i = 0; i < 10; i++) {
          futures.add(cacheSystem.get('${key}_$i'));
        }

        await Future.wait(futures);

        // Verify all data is accessible
        for (int i = 0; i < 10; i++) {
          final result = await cacheSystem.get('${key}_$i');
          expect(result, equals('value_$i'));
        }
      });

      test('should prevent cache stampede with locking', () async {
        const key = 'stampede_key';
        var loadCallCount = 0;

        Future<String> expensiveLoad() async {
          loadCallCount++;
          await Future.delayed(Duration(milliseconds: 100));
          return 'expensive_result';
        }

        // Simulate multiple concurrent requests for the same key
        final futures = List.generate(5, (index) =>
          cacheSystem.getOrCompute(key, expensiveLoad)
        );

        final results = await Future.wait(futures);

        // All should get the same result
        expect(results.every((result) => result == 'expensive_result'), isTrue);

        // Load function should be called only once (cache stampede prevention)
        expect(loadCallCount, equals(1));
      });
    });

    group('Cache Invalidation', () {
      test('should invalidate single keys', () async {
        const key = 'invalidate_key';
        const value = 'invalidate_value';

        await cacheSystem.set(key, value);
        expect(await cacheSystem.get(key), equals(value));

        await cacheSystem.invalidate(key);
        expect(await cacheSystem.get(key), isNull);
      });

      test('should invalidate by pattern', () async {
        await cacheSystem.set('user:123', 'John');
        await cacheSystem.set('user:124', 'Jane');
        await cacheSystem.set('product:456', 'Widget');

        await cacheSystem.invalidatePattern('user:*');

        expect(await cacheSystem.get('user:123'), isNull);
        expect(await cacheSystem.get('user:124'), isNull);
        expect(await cacheSystem.get('product:456'), equals('Widget'));
      });

      test('should invalidate by tags', () async {
        await cacheSystem.setWithTags('tagged1', 'value1', ['user', 'profile']);
        await cacheSystem.setWithTags('tagged2', 'value2', ['user', 'settings']);
        await cacheSystem.setWithTags('tagged3', 'value3', ['product']);

        await cacheSystem.invalidateByTag('user');

        expect(await cacheSystem.get('tagged1'), isNull);
        expect(await cacheSystem.get('tagged2'), isNull);
        expect(await cacheSystem.get('tagged3'), equals('value3'));
      });
    });

    group('Cache Persistence', () {
      test('should persist cache to storage on shutdown', () async {
        await cacheSystem.set('persist1', 'value1');
        await cacheSystem.set('persist2', 'value2');

        await cacheSystem.persistToStorage();

        verify(mockPersistentStorage.set('persist1', any)).called(1);
        verify(mockPersistentStorage.set('persist2', any)).called(1);
      });

      test('should restore cache from storage on startup', () async {
        final restoredData = {
          'restored1': 'value1',
          'restored2': 'value2',
        };

        when(mockPersistentStorage.keys())
            .thenAnswer((_) async => restoredData.keys.toList());

        for (final entry in restoredData.entries) {
          when(mockPersistentStorage.get(entry.key))
              .thenAnswer((_) async => entry.value);
        }

        await cacheSystem.restoreFromStorage();

        for (final entry in restoredData.entries) {
          final result = await cacheSystem.get(entry.key);
          expect(result, equals(entry.value));
        }
      });
    });

    group('Memory Management', () {
      test('should trigger garbage collection when memory pressure is high', () async {
        // Fill cache close to capacity
        for (int i = 0; i < 95; i++) {
          await cacheSystem.set('gc_key_$i', 'value_$i');
        }

        final statsBefore = await cacheSystem.getStatistics();
        expect(statsBefore.memoryPressure, greaterThan(0.8));

        await cacheSystem.triggerGarbageCollection();

        final statsAfter = await cacheSystem.getStatistics();
        expect(statsAfter.memoryPressure, lessThan(statsBefore.memoryPressure));
      });

      test('should provide memory usage breakdown', () async {
        await cacheSystem.set('breakdown_key', 'breakdown_value');

        final breakdown = await cacheSystem.getMemoryBreakdown();

        expect(breakdown.keys, contains('total_memory'));
        expect(breakdown.keys, contains('used_memory'));
        expect(breakdown.keys, contains('available_memory'));
        expect(breakdown.keys, contains('cache_overhead'));
      });
    });

    tearDown(() async {
      await cacheSystem.dispose();
    });
  });
}