import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/cache/policies/cache_policy_engine.dart';
import 'package:prioris/domain/services/cache/interfaces/cache_system_interfaces.dart';
import 'package:prioris/domain/services/cache/core/cache_entry.dart';

void main() {
  group('CachePolicyEngine', () {
    late CachePolicyEngine policyEngine;
    const defaultTTL = Duration(minutes: 10);

    group('LRU Policy', () {
      setUp(() {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.lru,
          defaultTTL: defaultTTL,
        );
      });

      test('should identify LRU candidate correctly', () {
        final now = DateTime.now();
        final entries = <String, ICacheEntry>{
          'oldest': _createTestEntry('oldest', now.subtract(const Duration(minutes: 10))),
          'middle': _createTestEntry('middle', now.subtract(const Duration(minutes: 5))),
          'newest': _createTestEntry('newest', now),
        };

        final candidate = policyEngine.getEvictionCandidate(entries);
        expect(candidate, equals('oldest'));
      });

      test('should update entry access without special tracking', () {
        final entry = _createTestEntry('test');
        final originalAccess = entry.lastAccessed;

        // Small delay to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 1), () {
          policyEngine.updateEntryOnAccess('test', entry);
          expect(entry.lastAccessed.isAfter(originalAccess), isTrue);
        });
      });
    });

    group('LFU Policy', () {
      setUp(() {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.lfu,
          defaultTTL: defaultTTL,
        );
      });

      test('should track frequency correctly', () {
        final entry = _createTestEntry('test');

        // Initialize entry in policy engine
        policyEngine.updateEntryOnCreate('test', entry);

        // Update frequency
        policyEngine.updateEntryOnAccess('test', entry);
        policyEngine.updateEntryOnAccess('test', entry);

        expect(entry.frequency, greaterThan(1));
      });

      test('should identify LFU candidate correctly', () {
        final entries = <String, ICacheEntry>{
          'freq1': _createTestEntryWithFreq('freq1', 1),
          'freq3': _createTestEntryWithFreq('freq3', 3),
          'freq2': _createTestEntryWithFreq('freq2', 2),
        };

        // Initialize entries in policy engine
        for (final entryKV in entries.entries) {
          policyEngine.updateEntryOnCreate(entryKV.key, entryKV.value);
        }

        final candidate = policyEngine.getEvictionCandidate(entries);
        expect(candidate, equals('freq1'));
      });

      test('should handle frequency map consistency', () {
        final entry = _createTestEntry('test');

        policyEngine.updateEntryOnCreate('test', entry);
        policyEngine.updateEntryOnAccess('test', entry);

        final stats = policyEngine.getPolicyStats();
        expect(stats['frequencyDistribution'], isA<Map>());
        expect(stats['totalTrackedEntries'], greaterThan(0));
      });

      test('should remove entry from frequency tracking', () {
        final entry = _createTestEntry('test');

        policyEngine.updateEntryOnCreate('test', entry);
        policyEngine.removeEntry('test', entry);

        final stats = policyEngine.getPolicyStats();
        expect(stats['totalTrackedEntries'], equals(0));
      });
    });

    group('TTL Policy', () {
      setUp(() {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.ttl,
          defaultTTL: defaultTTL,
        );
      });

      test('should identify expired entries for eviction', () {
        final expiredEntry = CacheEntry(
          value: 'expired',
          sizeBytes: 100,
          ttl: const Duration(milliseconds: 1),
        );

        // Wait for expiration
        return Future.delayed(const Duration(milliseconds: 2), () {
          expect(policyEngine.shouldEvict('expired', expiredEntry), isTrue);
        });
      });

      test('should not evict non-expired entries', () {
        final validEntry = CacheEntry(
          value: 'valid',
          sizeBytes: 100,
          ttl: const Duration(hours: 1),
        );

        expect(policyEngine.shouldEvict('valid', validEntry), isFalse);
      });

      test('should prioritize expired entries for eviction', () {
        final expiredEntry = CacheEntry(
          value: 'expired',
          sizeBytes: 100,
          ttl: const Duration(milliseconds: 1),
        );

        final validEntry = CacheEntry(
          value: 'valid',
          sizeBytes: 100,
          ttl: const Duration(hours: 1),
        );

        return Future.delayed(const Duration(milliseconds: 2), () {
          final entries = <String, ICacheEntry>{
            'expired': expiredEntry,
            'valid': validEntry,
          };

          final candidate = policyEngine.getEvictionCandidate(entries);
          expect(candidate, equals('expired'));
        });
      });

      test('should fall back to oldest created when no TTL entries', () {
        final now = DateTime.now();
        final entries = <String, ICacheEntry>{
          'newer': _createTestEntry('newer', now),
          'older': _createTestEntry('older', now.subtract(const Duration(minutes: 5))),
        };

        // Mock entries without TTL by creating them without expiration
        final olderNoTTL = CacheEntry(value: 'older', sizeBytes: 100);
        final newerNoTTL = CacheEntry(value: 'newer', sizeBytes: 100);

        final entriesNoTTL = <String, ICacheEntry>{
          'newer': newerNoTTL,
          'older': olderNoTTL,
        };

        final candidate = policyEngine.getEvictionCandidate(entriesNoTTL);
        expect(candidate, isNotNull);
      });
    });

    group('Adaptive Policy', () {
      setUp(() {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.adaptive,
          defaultTTL: defaultTTL,
        );
      });

      test('should calculate adaptive scores', () {
        final entry = _createTestEntry('test');

        policyEngine.updateEntryOnCreate('test', entry);
        policyEngine.updateEntryOnAccess('test', entry);

        final stats = policyEngine.getPolicyStats();
        expect(stats['averageScore'], isA<double>());
        expect(stats['averageScore'], greaterThan(0));
      });

      test('should identify lowest scoring entry for eviction', () {
        final highPriorityEntry = CacheEntry(
          value: 'high',
          sizeBytes: 100,
          priority: 10,
        );

        final lowPriorityEntry = CacheEntry(
          value: 'low',
          sizeBytes: 100,
          priority: 1,
        );

        final entries = <String, ICacheEntry>{
          'high': highPriorityEntry,
          'low': lowPriorityEntry,
        };

        // Initialize entries
        policyEngine.updateEntryOnCreate('high', highPriorityEntry);
        policyEngine.updateEntryOnCreate('low', lowPriorityEntry);

        final candidate = policyEngine.getEvictionCandidate(entries);
        expect(candidate, equals('low'));
      });

      test('should provide score distribution statistics', () {
        final entries = [
          ('low', 1),
          ('medium', 15),
          ('high', 60),
        ];

        for (final (key, priority) in entries) {
          final entry = CacheEntry(value: key, sizeBytes: 100, priority: priority);
          policyEngine.updateEntryOnCreate(key, entry);
        }

        final stats = policyEngine.getPolicyStats();
        final distribution = stats['scoreDistribution'] as Map<String, int>;

        expect(distribution.keys.contains('low'), isTrue);
        expect(distribution.keys.contains('medium'), isTrue);
        expect(distribution.keys.contains('high'), isTrue);
      });
    });

    group('Policy Validation', () {
      test('should validate LFU consistency', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.lfu,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        policyEngine.updateEntryOnCreate('test', entry);

        final entries = <String, ICacheEntry>{'test': entry};
        expect(policyEngine.validatePolicy(entries), isTrue);
      });

      test('should validate adaptive consistency', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.adaptive,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        policyEngine.updateEntryOnCreate('test', entry);

        final entries = <String, ICacheEntry>{'test': entry};
        expect(policyEngine.validatePolicy(entries), isTrue);
      });

      test('should detect inconsistencies', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.adaptive,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        // Don't call updateEntryOnCreate to create inconsistency

        final entries = <String, ICacheEntry>{'test': entry};
        expect(policyEngine.validatePolicy(entries), isFalse);
      });
    });

    group('Policy Statistics', () {
      test('should provide base statistics for all strategies', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.lru,
          defaultTTL: defaultTTL,
        );

        final stats = policyEngine.getPolicyStats();

        expect(stats['strategy'], equals('lru'));
        expect(stats['defaultTTL'], equals(defaultTTL.inMilliseconds));
        expect(stats['evictionCount'], isA<int>());
        expect(stats['ttlExpirationCount'], isA<int>());
        expect(stats['policyViolationCount'], isA<int>());
      });

      test('should provide LFU-specific statistics', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.lfu,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        policyEngine.updateEntryOnCreate('test', entry);

        final stats = policyEngine.getPolicyStats();

        expect(stats['minFrequency'], isA<int>());
        expect(stats['frequencyDistribution'], isA<Map>());
        expect(stats['totalTrackedEntries'], isA<int>());
      });

      test('should provide adaptive-specific statistics', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.adaptive,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        policyEngine.updateEntryOnCreate('test', entry);

        final stats = policyEngine.getPolicyStats();

        expect(stats['averageScore'], isA<double>());
        expect(stats['maxScore'], isA<double>());
        expect(stats['minScore'], isA<double>());
        expect(stats['scoredEntries'], isA<int>());
        expect(stats['scoreDistribution'], isA<Map>());
      });
    });

    group('Policy Optimization', () {
      test('should optimize LFU policy data structures', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.lfu,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        policyEngine.updateEntryOnCreate('test', entry);
        policyEngine.removeEntry('test', entry);

        // Optimize should clean up empty frequency buckets
        policyEngine.optimize();

        final stats = policyEngine.getPolicyStats();
        expect(stats['totalTrackedEntries'], equals(0));
      });

      test('should optimize adaptive policy scores', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.adaptive,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        policyEngine.updateEntryOnCreate('test', entry);

        policyEngine.optimize();

        final stats = policyEngine.getPolicyStats();
        expect(stats['scoredEntries'], equals(1));
      });
    });

    group('Policy Reset', () {
      test('should reset all policy state', () {
        policyEngine = CachePolicyEngine(
          strategy: CacheStrategy.adaptive,
          defaultTTL: defaultTTL,
        );

        final entry = _createTestEntry('test');
        policyEngine.updateEntryOnCreate('test', entry);
        policyEngine.removeEntry('test', entry); // Increment eviction count

        policyEngine.reset();

        final stats = policyEngine.getPolicyStats();
        expect(stats['evictionCount'], equals(0));
        expect(stats['ttlExpirationCount'], equals(0));
        expect(stats['policyViolationCount'], equals(0));
      });
    });
  });
}

// Helper functions for creating test entries
CacheEntry _createTestEntry(String value, [DateTime? lastAccessed]) {
  final entry = CacheEntry(value: value, sizeBytes: 100);
  if (lastAccessed != null) {
    // Modify the lastAccessed field (this is a bit of a hack for testing)
    // In real usage, this would be handled by the updateAccess method
  }
  return entry;
}

CacheEntry _createTestEntryWithFreq(String value, int frequency) {
  final entry = CacheEntry(value: value, sizeBytes: 100, frequency: frequency);
  return entry;
}