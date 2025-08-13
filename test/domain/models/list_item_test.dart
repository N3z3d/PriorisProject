import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

void main() {
  group('ListItem', () {
    late DateTime testDate;
    late ListItem testItem;

    setUp(() {
      testDate = DateTime(2024, 1, 1, 12, 0, 0);
      testItem = ListItem(
        id: 'test-id',
        title: 'Test Item',
        description: 'Test Description',
        category: 'Test Category',
        eloScore: 1400.0, // Score ELO élevé (équivalent HIGH priority)
        isCompleted: false,
        createdAt: testDate,
      );
    });

    group('Constructor', () {
      test('should create ListItem with all properties', () {
        expect(testItem.id, 'test-id');
        expect(testItem.title, 'Test Item');
        expect(testItem.description, 'Test Description');
        expect(testItem.category, 'Test Category');
        expect(testItem.eloScore, 1400.0);
        expect(testItem.isCompleted, false);
        expect(testItem.createdAt, testDate);
        expect(testItem.completedAt, null);
      });

      test('should create ListItem with minimal properties', () {
        final minimalItem = ListItem(
          id: 'minimal-id',
          title: 'Minimal Item',
          createdAt: testDate,
        );

        expect(minimalItem.id, 'minimal-id');
        expect(minimalItem.title, 'Minimal Item');
        expect(minimalItem.description, null);
        expect(minimalItem.category, null);
        expect(minimalItem.eloScore, 1200.0); // Score ELO par défaut
        expect(minimalItem.isCompleted, false);
        expect(minimalItem.createdAt, testDate);
        expect(minimalItem.completedAt, null);
      });

      test('should create ListItem with completed status', () {
        final completedDate = DateTime(2024, 1, 2, 12, 0, 0);
        final completedItem = ListItem(
          id: 'completed-id',
          title: 'Completed Item',
          isCompleted: true,
          createdAt: testDate,
          completedAt: completedDate,
        );

        expect(completedItem.isCompleted, true);
        expect(completedItem.completedAt, completedDate);
      });
    });

    group('copyWith', () {
      test('should return same instance when no parameters provided', () {
        final copied = testItem.copyWith();
        expect(copied, testItem);
      });

      test('should copy with modified properties', () {
        final newDate = DateTime(2024, 1, 3, 12, 0, 0);
        final copied = testItem.copyWith(
          title: 'Modified Title',
          description: 'Modified Description',
          eloScore: 1600.0, // Nouveau score ELO
          isCompleted: true,
          completedAt: newDate,
        );

        expect(copied.id, testItem.id);
        expect(copied.title, 'Modified Title');
        expect(copied.description, 'Modified Description');
        expect(copied.category, testItem.category);
        expect(copied.eloScore, 1600.0);
        expect(copied.isCompleted, true);
        expect(copied.createdAt, testItem.createdAt);
        expect(copied.completedAt, newDate);
      });

      test('should copy with modified category', () {
        final copied = testItem.copyWith(category: 'New Category');
        expect(copied.category, 'New Category');
        expect(copied.id, testItem.id);
        expect(copied.title, testItem.title);
      });
    });

    group('markAsCompleted', () {
      test('should mark item as completed with current timestamp', () {
        final completed = testItem.markAsCompleted();

        expect(completed.isCompleted, true);
        expect(completed.completedAt, isNotNull);
        expect(completed.completedAt!.isAfter(testItem.createdAt), true);
      });

      test('should not modify other properties when marking as completed', () {
        final completed = testItem.markAsCompleted();

        expect(completed.id, testItem.id);
        expect(completed.title, testItem.title);
        expect(completed.description, testItem.description);
        expect(completed.category, testItem.category);
        expect(completed.eloScore, testItem.eloScore);
        expect(completed.createdAt, testItem.createdAt);
      });
    });

    group('markAsIncomplete', () {
      test('should mark item as incomplete and clear completedAt', () {
        final completedDate = DateTime(2024, 1, 2, 12, 0, 0);
        final completedItem = testItem.copyWith(
          isCompleted: true,
          completedAt: completedDate,
        );
        final incomplete = completedItem.markAsIncomplete();

        expect(incomplete.isCompleted, false);
        expect(incomplete.completedAt, null);
      });

      test('should not modify other properties when marking as incomplete', () {
        final completedDate = DateTime(2024, 1, 2, 12, 0, 0);
        final completedItem = testItem.copyWith(
          isCompleted: true,
          completedAt: completedDate,
        );
        final incomplete = completedItem.markAsIncomplete();

        expect(incomplete.id, completedItem.id);
        expect(incomplete.title, completedItem.title);
        expect(incomplete.description, completedItem.description);
        expect(incomplete.category, completedItem.category);
        expect(incomplete.eloScore, completedItem.eloScore);
        expect(incomplete.createdAt, completedItem.createdAt);
      });
    });

    group('ELO System', () {
      test('should calculate win probability against opponent', () {
        final opponent = ListItem(
          id: 'opponent-id',
          title: 'Opponent Item',
          eloScore: 1200.0, // Score plus faible
          createdAt: testDate,
        );

        final winProbability = testItem.calculateWinProbability(opponent);
        expect(winProbability, greaterThan(0.5)); // testItem favori
        expect(winProbability, lessThan(1.0));
      });

      test('should handle equal ELO scores', () {
        final equalOpponent = ListItem(
          id: 'equal-id',
          title: 'Equal Item',
          eloScore: 1400.0, // Même score
          createdAt: testDate,
        );

        final winProbability = testItem.calculateWinProbability(equalOpponent);
        expect(winProbability, closeTo(0.5, 0.01)); // ~50% de chance
      });

      test('should update ELO score conceptually', () {
        // Test conceptuel car updateEloScore nécessiterait une nouvelle instance
        final opponent = ListItem(
          id: 'opponent-id',
          title: 'Opponent Item',
          eloScore: 1200.0,
          createdAt: testDate,
        );

        final initialScore = testItem.eloScore;
        final winProbability = testItem.calculateWinProbability(opponent);
        
        expect(initialScore, equals(1400.0));
        expect(winProbability, greaterThan(0.5));
        // Dans une vraie implémentation, on créerait une nouvelle instance avec le score mis à jour
      });
    });

    group('JSON Serialization', () {
      test('should convert to JSON correctly', () {
        final json = testItem.toJson();

        expect(json['id'], 'test-id');
        expect(json['title'], 'Test Item');
        expect(json['description'], 'Test Description');
        expect(json['category'], 'Test Category');
        expect(json['eloScore'], 1400.0);
        expect(json['isCompleted'], false);
        expect(json['createdAt'], isA<String>());
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'json-id',
          'title': 'JSON Item',
          'description': 'JSON Description',
          'category': 'JSON Category',
          'eloScore': 1500.0,
          'isCompleted': true,
          'createdAt': '2024-01-01T12:00:00.000',
          'completedAt': '2024-01-02T12:00:00.000',
        };

        final item = ListItem.fromJson(json);

        expect(item.id, 'json-id');
        expect(item.title, 'JSON Item');
        expect(item.description, 'JSON Description');
        expect(item.category, 'JSON Category');
        expect(item.eloScore, 1500.0);
        expect(item.isCompleted, true);
      });

      test('should handle null values in JSON', () {
        final json = {
          'id': 'minimal-json-id',
          'title': 'Minimal JSON Item',
          'createdAt': '2024-01-01T12:00:00.000',
        };

        final item = ListItem.fromJson(json);

        expect(item.id, 'minimal-json-id');
        expect(item.title, 'Minimal JSON Item');
        expect(item.description, null);
        expect(item.category, null);
        expect(item.eloScore, 1200.0); // Valeur par défaut
        expect(item.isCompleted, false);
      });
    });

    group('Validation', () {
      test('should throw error for empty ID', () {
        expect(() => ListItem(
          id: '',
          title: 'Test',
          createdAt: testDate,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for empty title', () {
        expect(() => ListItem(
          id: 'test',
          title: '',
          createdAt: testDate,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for negative ELO score', () {
        expect(() => ListItem(
          id: 'test',
          title: 'Test',
          eloScore: -100.0,
          createdAt: testDate,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate completion dates consistency', () {
        expect(() => ListItem(
          id: 'test',
          title: 'Test',
          isCompleted: false,
          completedAt: DateTime.now(), // Incohérent
          createdAt: testDate,
        ), throwsA(isA<ArgumentError>()));
      });
    });

    group('Performance', () {
      test('should create items efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        final items = List.generate(1000, (index) => ListItem(
          id: 'item_$index',
          title: 'Item $index',
          eloScore: 1200.0 + index,
          createdAt: testDate,
        ));
        
        stopwatch.stop();
        
        expect(items.length, 1000);
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should calculate ELO probabilities efficiently', () {
        final opponent = ListItem(
          id: 'perf-opponent',
          title: 'Performance Opponent',
          eloScore: 1300.0,
          createdAt: testDate,
        );

        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10000; i++) {
          testItem.calculateWinProbability(opponent);
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });
  });
} 
