import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/id_generation_service.dart';

void main() {
  group('IdGenerationService', () {
    late IdGenerationService service;

    setUp(() {
      service = IdGenerationService();
    });

    group('generateListItemId', () {
      test('should generate non-empty ID', () {
        final id = service.generateListItemId();

        expect(id, isNotEmpty);
      });

      test('should generate unique IDs on consecutive calls', () {
        final id1 = service.generateListItemId();
        final id2 = service.generateListItemId();
        final id3 = service.generateListItemId();

        expect(id1, isNot(equals(id2)));
        expect(id2, isNot(equals(id3)));
        expect(id1, isNot(equals(id3)));
      });

      test('should generate UUID v4 format', () {
        final id = service.generateListItemId();

        // UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
        final uuidPattern = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        );

        expect(id, matches(uuidPattern), reason: 'ID should match UUID v4 format');
      });

      test('should generate 1000 unique IDs (collision test)', () {
        final ids = <String>{};

        for (var i = 0; i < 1000; i++) {
          ids.add(service.generateListItemId());
        }

        expect(ids.length, equals(1000), reason: 'All 1000 IDs should be unique');
      });
    });

    group('generateListId', () {
      test('should generate valid UUID v4', () {
        final id = service.generateListId();

        expect(id, isNotEmpty);

        final uuidPattern = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        );

        expect(id, matches(uuidPattern));
      });
    });

    group('generateBatchIds', () {
      test('should generate requested number of IDs', () {
        final ids = service.generateBatchIds(5);

        expect(ids.length, equals(5));
      });

      test('should generate all unique IDs in batch', () {
        final ids = service.generateBatchIds(100);

        final uniqueIds = ids.toSet();
        expect(uniqueIds.length, equals(100), reason: 'All batch IDs should be unique');
      });

      test('should throw on zero count', () {
        expect(
          () => service.generateBatchIds(0),
          throwsArgumentError,
        );
      });

      test('should throw on negative count', () {
        expect(
          () => service.generateBatchIds(-5),
          throwsArgumentError,
        );
      });

      test('all generated IDs should be valid UUID v4', () {
        final ids = service.generateBatchIds(10);

        final uuidPattern = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        );

        for (final id in ids) {
          expect(id, matches(uuidPattern));
        }
      });
    });

    group('Uniqueness stress test', () {
      test('should generate 10000 unique IDs across methods', () {
        final ids = <String>{};

        // Mix of individual and batch generation
        for (var i = 0; i < 5000; i++) {
          ids.add(service.generateListItemId());
        }

        for (var i = 0; i < 2500; i++) {
          ids.add(service.generateListId());
        }

        ids.addAll(service.generateBatchIds(2500));

        expect(ids.length, equals(10000), reason: 'All 10k IDs should be unique');
      });
    });
  });
}
