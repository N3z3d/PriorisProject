import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/date_range.dart';

void main() {
  group('DateRange Value Object', () {
    group('Construction', () {
      test('should create DateRange with valid dates', () {
        // Arrange
        final start = DateTime(2023, 12, 1);
        final end = DateTime(2023, 12, 31);

        // Act
        final range = DateRange.create(start: start, end: end);

        // Assert
        expect(range.start, start);
        expect(range.end, end);
      });

      test('should throw ArgumentError when end is before start', () {
        // Arrange
        final start = DateTime(2023, 12, 31);
        final end = DateTime(2023, 12, 1);

        // Act & Assert
        expect(
          () => DateRange.create(start: start, end: end),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should create today range', () {
        // Arrange & Act
        final range = DateRange.today();

        // Assert
        expect(range.durationInDays, 1);
        expect(range.contains(DateTime.now()), isTrue);
      });

      test('should create this week range', () {
        // Arrange & Act
        final range = DateRange.thisWeek();

        // Assert
        expect(range.durationInDays, 7);
      });

      test('should create last N days range', () {
        // Arrange & Act
        final range = DateRange.lastDays(7);

        // Assert
        expect(range.durationInDays, 7);
        expect(range.contains(DateTime.now()), isTrue);
      });

      test('should throw ArgumentError for non-positive days', () {
        // Act & Assert
        expect(() => DateRange.lastDays(0), throwsA(isA<ArgumentError>()));
        expect(() => DateRange.lastDays(-1), throwsA(isA<ArgumentError>()));
      });
    });

    group('Contains and Overlaps', () {
      test('should check if date is contained', () {
        // Arrange
        final range = DateRange.create(
          start: DateTime(2023, 12, 1),
          end: DateTime(2023, 12, 31),
        );

        // Act & Assert
        expect(range.contains(DateTime(2023, 12, 15)), isTrue);
        expect(range.contains(DateTime(2023, 11, 30)), isFalse);
        expect(range.contains(DateTime(2024, 1, 1)), isFalse);
      });

      test('should check if ranges overlap', () {
        // Arrange
        final range1 = DateRange.create(
          start: DateTime(2023, 12, 1),
          end: DateTime(2023, 12, 15),
        );
        final range2 = DateRange.create(
          start: DateTime(2023, 12, 10),
          end: DateTime(2023, 12, 25),
        );
        final range3 = DateRange.create(
          start: DateTime(2023, 12, 20),
          end: DateTime(2023, 12, 31),
        );

        // Act & Assert
        expect(range1.overlapsWith(range2), isTrue);
        expect(range1.overlapsWith(range3), isFalse);
      });
    });

    group('Set Operations', () {
      test('should find intersection of ranges', () {
        // Arrange
        final range1 = DateRange.create(
          start: DateTime(2023, 12, 1),
          end: DateTime(2023, 12, 20),
        );
        final range2 = DateRange.create(
          start: DateTime(2023, 12, 10),
          end: DateTime(2023, 12, 25),
        );

        // Act
        final intersection = range1.intersectionWith(range2);

        // Assert
        expect(intersection, isNotNull);
        expect(intersection!.start, DateTime(2023, 12, 10));
        expect(intersection.end, DateTime(2023, 12, 20));
      });

      test('should return null for non-overlapping ranges', () {
        // Arrange
        final range1 = DateRange.create(
          start: DateTime(2023, 12, 1),
          end: DateTime(2023, 12, 10),
        );
        final range2 = DateRange.create(
          start: DateTime(2023, 12, 20),
          end: DateTime(2023, 12, 31),
        );

        // Act
        final intersection = range1.intersectionWith(range2);

        // Assert
        expect(intersection, isNull);
      });

      test('should find union of ranges', () {
        // Arrange
        final range1 = DateRange.create(
          start: DateTime(2023, 12, 1),
          end: DateTime(2023, 12, 15),
        );
        final range2 = DateRange.create(
          start: DateTime(2023, 12, 10),
          end: DateTime(2023, 12, 25),
        );

        // Act
        final union = range1.unionWith(range2);

        // Assert
        expect(union.start, DateTime(2023, 12, 1));
        expect(union.end, DateTime(2023, 12, 25));
      });
    });

    group('Transformations', () {
      test('should extend range by days', () {
        // Arrange
        final range = DateRange.create(
          start: DateTime(2023, 12, 1),
          end: DateTime(2023, 12, 10),
        );

        // Act
        final extended = range.extendByDays(5);

        // Assert
        expect(extended.start, range.start);
        expect(extended.end, DateTime(2023, 12, 15));
        expect(extended.durationInDays, 14);
      });

      test('should shift range by days', () {
        // Arrange
        final range = DateRange.create(
          start: DateTime(2023, 12, 1),
          end: DateTime(2023, 12, 10),
        );

        // Act
        final shifted = range.shiftByDays(5);

        // Assert
        expect(shifted.start, DateTime(2023, 12, 6));
        expect(shifted.end, DateTime(2023, 12, 15));
        expect(shifted.durationInDays, range.durationInDays);
      });
    });

    group('JSON Serialization', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final range = DateRange.create(
          start: DateTime(2023, 12, 15, 10, 30),
          end: DateTime(2023, 12, 31, 23, 59),
        );

        // Act
        final json = range.toJson();
        final deserialized = DateRange.fromJson(json);

        // Assert
        expect(deserialized, range);
      });
    });

    group('DateRangeType Enum', () {
      test('should create range from type', () {
        // Act & Assert
        expect(() => DateRangeType.today.createRange(), returnsNormally);
        expect(() => DateRangeType.thisWeek.createRange(), returnsNormally);
        expect(() => DateRangeType.last7Days.createRange(), returnsNormally);
        expect(DateRangeType.last7Days.createRange().durationInDays, 7);
      });

      test('should throw for custom type', () {
        // Act & Assert
        expect(
          () => DateRangeType.custom.createRange(),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}