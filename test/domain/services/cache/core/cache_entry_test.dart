import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/cache/core/cache_entry.dart';

void main() {
  group('CacheEntry', () {
    group('Construction', () {
      test('should create cache entry with required properties', () {
        const value = 'test_value';
        const sizeBytes = 100;
        const priority = 5;

        final entry = CacheEntry(
          value: value,
          sizeBytes: sizeBytes,
          priority: priority,
        );

        expect(entry.value, equals(value));
        expect(entry.sizeBytes, equals(sizeBytes));
        expect(entry.priority, equals(priority));
        expect(entry.frequency, equals(1));
        expect(entry.isExpired, isFalse);
      });

      test('should create entry with TTL and expiration', () {
        const ttl = Duration(minutes: 5);
        final entry = CacheEntry(
          value: 'test',
          sizeBytes: 100,
          ttl: ttl,
        );

        expect(entry.expiresAt, isNotNull);
        expect(entry.isExpired, isFalse);

        // Verify expiration is approximately correct (within 1 second tolerance)
        final expectedExpiry = DateTime.now().add(ttl);
        final actualExpiry = entry.expiresAt!;
        expect(
          actualExpiry.difference(expectedExpiry).abs().inSeconds,
          lessThan(1),
        );
      });

      test('should create entry without TTL (no expiration)', () {
        final entry = CacheEntry(
          value: 'test',
          sizeBytes: 100,
        );

        expect(entry.expiresAt, isNull);
        expect(entry.isExpired, isFalse);
      });
    });

    group('Access Tracking', () {
      test('should update access time when updateAccess is called', () {
        final entry = CacheEntry(value: 'test', sizeBytes: 100);
        final originalAccess = entry.lastAccessed;

        // Small delay to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 1), () {
          entry.updateAccess();
          expect(entry.lastAccessed.isAfter(originalAccess), isTrue);
        });
      });

      test('should increment frequency and update access', () async {
        final entry = CacheEntry(value: 'test', sizeBytes: 100);
        final originalFrequency = entry.frequency;
        final originalAccess = entry.lastAccessed;

        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 1));
        entry.incrementFrequency();

        expect(entry.frequency, equals(originalFrequency + 1));
        expect(entry.lastAccessed.isAfter(originalAccess), isTrue);
      });
    });

    group('Expiration', () {
      test('should detect expired entries', () {
        final entry = CacheEntry(
          value: 'test',
          sizeBytes: 100,
          ttl: const Duration(milliseconds: 1),
        );

        // Entry should not be expired immediately
        expect(entry.isExpired, isFalse);

        // Wait for expiration
        return Future.delayed(const Duration(milliseconds: 2), () {
          expect(entry.isExpired, isTrue);
        });
      });

      test('should not expire entries without TTL', () {
        final entry = CacheEntry(value: 'test', sizeBytes: 100);
        expect(entry.isExpired, isFalse);

        // Even after some time, should not expire
        return Future.delayed(const Duration(milliseconds: 10), () {
          expect(entry.isExpired, isFalse);
        });
      });
    });

    group('Adaptive Scoring', () {
      test('should calculate adaptive score based on multiple factors', () {
        final entry = CacheEntry(
          value: 'test',
          sizeBytes: 1024, // 1KB
          priority: 10,
        );

        final score = entry.calculateAdaptiveScore();

        // Score should be positive and include frequency, priority, and size factors
        expect(score, greaterThan(0));
        expect(score, greaterThan(10)); // At least priority value
      });

      test('should give higher score to frequently accessed entries', () {
        final entry1 = CacheEntry(value: 'test1', sizeBytes: 100, priority: 5);
        final entry2 = CacheEntry(value: 'test2', sizeBytes: 100, priority: 5);

        // Increase frequency of entry2
        entry2.incrementFrequency();
        entry2.incrementFrequency();

        expect(entry2.calculateAdaptiveScore(), greaterThan(entry1.calculateAdaptiveScore()));
      });

      test('should give higher score to higher priority entries', () {
        final lowPriority = CacheEntry(value: 'low', sizeBytes: 100, priority: 1);
        final highPriority = CacheEntry(value: 'high', sizeBytes: 100, priority: 10);

        expect(highPriority.calculateAdaptiveScore(), greaterThan(lowPriority.calculateAdaptiveScore()));
      });
    });

    group('Age Calculation', () {
      test('should calculate age in seconds', () {
        final entry = CacheEntry(value: 'test', sizeBytes: 100);

        // Age should be at least 1 (minimum enforced in implementation)
        expect(entry.ageInSeconds, greaterThanOrEqualTo(1));
      });

      test('should increase age over time', () {
        final entry = CacheEntry(value: 'test', sizeBytes: 100);
        final initialAge = entry.ageInSeconds;

        return Future.delayed(const Duration(seconds: 1), () {
          expect(entry.ageInSeconds, greaterThan(initialAge));
        });
      });
    });

    group('Entry Copying', () {
      test('should create copy with new TTL', () {
        final original = CacheEntry(
          value: 'test',
          sizeBytes: 100,
          priority: 5,
          frequency: 3,
        );

        const newTTL = Duration(hours: 1);
        final copy = original.copyWithNewTTL(newTTL);

        expect(copy.value, equals(original.value));
        expect(copy.sizeBytes, equals(original.sizeBytes));
        expect(copy.priority, equals(original.priority));
        expect(copy.frequency, equals(original.frequency));
        expect(copy.expiresAt, isNotNull);
      });

      test('should create copy without TTL', () {
        final original = CacheEntry(
          value: 'test',
          sizeBytes: 100,
          ttl: const Duration(minutes: 30),
        );

        final copy = original.copyWithNewTTL(null);

        expect(copy.value, equals(original.value));
        expect(copy.expiresAt, isNull);
      });
    });

    group('Serialization', () {
      test('should convert to map with all properties', () {
        final entry = CacheEntry(
          value: 'test',
          sizeBytes: 100,
          priority: 5,
          frequency: 3,
          ttl: const Duration(minutes: 10),
        );

        final map = entry.toMap();

        expect(map['sizeBytes'], equals(100));
        expect(map['priority'], equals(5));
        expect(map['frequency'], equals(3));
        expect(map['isExpired'], isFalse);
        expect(map['created'], isA<String>());
        expect(map['lastAccessed'], isA<String>());
        expect(map['expiresAt'], isA<String>());
        expect(map['ageInSeconds'], isA<int>());
        expect(map['adaptiveScore'], isA<double>());
      });
    });
  });

  group('CacheSizeEstimator', () {
    group('Size Estimation', () {
      test('should estimate string size correctly', () {
        const shortString = 'test';
        const longString = 'this is a longer test string';

        final shortSize = CacheSizeEstimator.estimateSize(shortString);
        final longSize = CacheSizeEstimator.estimateSize(longString);

        expect(shortSize, equals(shortString.length * 2)); // UTF-16
        expect(longSize, equals(longString.length * 2));
        expect(longSize, greaterThan(shortSize));
      });

      test('should estimate primitive types correctly', () {
        expect(CacheSizeEstimator.estimateSize(42), equals(8));
        expect(CacheSizeEstimator.estimateSize(3.14), equals(8));
        expect(CacheSizeEstimator.estimateSize(true), equals(1));
        expect(CacheSizeEstimator.estimateSize(null), equals(0));
      });

      test('should estimate collection sizes', () {
        final list = [1, 2, 3, 4, 5];
        final map = {'key1': 'value1', 'key2': 'value2'};
        final set = {1, 2, 3};

        final listSize = CacheSizeEstimator.estimateSize(list);
        final mapSize = CacheSizeEstimator.estimateSize(map);
        final setSize = CacheSizeEstimator.estimateSize(set);

        expect(listSize, greaterThan(24)); // Base overhead + elements
        expect(mapSize, greaterThan(24));
        expect(setSize, greaterThan(24));
      });

      test('should provide default size for unknown objects', () {
        final customObject = DateTime.now();
        final size = CacheSizeEstimator.estimateSize(customObject);
        expect(size, equals(100)); // Default estimation
      });
    });

    group('Size Validation', () {
      test('should validate reasonable sizes', () {
        expect(CacheSizeEstimator.isReasonableSize(1000), isTrue);
        expect(CacheSizeEstimator.isReasonableSize(100000), isTrue);
        expect(CacheSizeEstimator.isReasonableSize(0), isFalse);
        expect(CacheSizeEstimator.isReasonableSize(-1), isFalse);
        expect(CacheSizeEstimator.isReasonableSize(10 * 1024 * 1024), isFalse); // > 10MB
      });

      test('should respect maximum size limits', () {
        const maxSize = 20; // 20MB
        final tenPercent = (maxSize * 1024 * 1024 * 0.1).toInt(); // 10% of 20MB

        expect(
          CacheSizeEstimator.isReasonableSize(
            tenPercent - 100000, // Well under 10%
            maxSizeMB: maxSize,
          ),
          isTrue,
        );

        expect(
          CacheSizeEstimator.isReasonableSize(
            tenPercent + 100000, // Well over 10%
            maxSizeMB: maxSize,
          ),
          isFalse,
        );
      });
    });

    group('Size Formatting', () {
      test('should format bytes correctly', () {
        expect(CacheSizeEstimator.formatSize(500), equals('500B'));
        expect(CacheSizeEstimator.formatSize(0), equals('0B'));
      });

      test('should format kilobytes correctly', () {
        expect(CacheSizeEstimator.formatSize(1024), equals('1.0KB'));
        expect(CacheSizeEstimator.formatSize(1536), equals('1.5KB'));
        expect(CacheSizeEstimator.formatSize(10240), equals('10.0KB'));
      });

      test('should format megabytes correctly', () {
        expect(CacheSizeEstimator.formatSize(1024 * 1024), equals('1.0MB'));
        expect(CacheSizeEstimator.formatSize(1536 * 1024), equals('1.5MB'));
        expect(CacheSizeEstimator.formatSize(10 * 1024 * 1024), equals('10.0MB'));
      });
    });
  });
}