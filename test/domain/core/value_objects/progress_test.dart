import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/progress.dart';

void main() {
  group('Progress Value Object', () {
    group('Factory Constructors - fromCounts', () {
      test('should create progress with valid counts', () {
        // Arrange & Act
        final progress = Progress.fromCounts(completed: 3, total: 5);

        // Assert
        expect(progress.completed, 3);
        expect(progress.total, 5);
        expect(progress.percentage, closeTo(0.6, 0.001));
        expect(progress.percentageDisplay, closeTo(60.0, 0.001));
        expect(progress.remaining, 2);
        expect(progress.lastUpdated, isNotNull);
      });

      test('should create 100% progress when completed equals total', () {
        // Arrange & Act
        final progress = Progress.fromCounts(completed: 5, total: 5);

        // Assert
        expect(progress.percentage, 1.0);
        expect(progress.percentageDisplay, 100.0);
        expect(progress.remaining, 0);
        expect(progress.isComplete, isTrue);
      });

      test('should create 0% progress when no items completed', () {
        // Arrange & Act
        final progress = Progress.fromCounts(completed: 0, total: 5);

        // Assert
        expect(progress.percentage, 0.0);
        expect(progress.percentageDisplay, 0.0);
        expect(progress.hasStarted, isFalse);
      });

      test('should handle zero total correctly', () {
        // Arrange & Act
        final progress = Progress.fromCounts(completed: 0, total: 0);

        // Assert
        expect(progress.percentage, 0.0);
        expect(progress.percentageDisplay, 0.0);
        expect(progress.remaining, 0);
      });

      test('should throw ArgumentError for negative completed', () {
        // Arrange & Act & Assert
        expect(
          () => Progress.fromCounts(completed: -1, total: 5),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for negative total', () {
        // Arrange & Act & Assert
        expect(
          () => Progress.fromCounts(completed: 3, total: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when completed exceeds total', () {
        // Arrange & Act & Assert
        expect(
          () => Progress.fromCounts(completed: 6, total: 5),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept custom lastUpdated date', () {
        // Arrange
        final customDate = DateTime(2023, 12, 15);

        // Act
        final progress = Progress.fromCounts(
          completed: 3,
          total: 5,
          lastUpdated: customDate,
        );

        // Assert
        expect(progress.lastUpdated, customDate);
      });
    });

    group('Factory Constructors - fromPercentage', () {
      test('should create progress from valid percentage', () {
        // Arrange & Act
        final progress = Progress.fromPercentage(percentage: 0.75);

        // Assert
        expect(progress.percentage, 0.75);
        expect(progress.percentageDisplay, 75.0);
        expect(progress.completed, 75);
        expect(progress.total, 100);
      });

      test('should handle boundary percentages', () {
        // Arrange & Act
        final zeroProgress = Progress.fromPercentage(percentage: 0.0);
        final fullProgress = Progress.fromPercentage(percentage: 1.0);

        // Assert
        expect(zeroProgress.percentage, 0.0);
        expect(zeroProgress.completed, 0);
        expect(fullProgress.percentage, 1.0);
        expect(fullProgress.completed, 100);
      });

      test('should throw ArgumentError for percentage below 0', () {
        // Arrange & Act & Assert
        expect(
          () => Progress.fromPercentage(percentage: -0.1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for percentage above 1', () {
        // Arrange & Act & Assert
        expect(
          () => Progress.fromPercentage(percentage: 1.1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept custom lastUpdated date', () {
        // Arrange
        final customDate = DateTime(2023, 12, 15);

        // Act
        final progress = Progress.fromPercentage(
          percentage: 0.5,
          lastUpdated: customDate,
        );

        // Assert
        expect(progress.lastUpdated, customDate);
      });
    });

    group('Named Constructors', () {
      test('should create empty progress', () {
        // Arrange & Act
        final progress = Progress.empty();

        // Assert
        expect(progress.completed, 0);
        expect(progress.total, 0);
        expect(progress.percentage, 0.0);
        expect(progress.hasStarted, isFalse);
      });

      test('should create complete progress with default total', () {
        // Arrange & Act
        final progress = Progress.complete();

        // Assert
        expect(progress.completed, 1);
        expect(progress.total, 1);
        expect(progress.percentage, 1.0);
        expect(progress.isComplete, isTrue);
      });

      test('should create complete progress with custom total', () {
        // Arrange & Act
        final progress = Progress.complete(total: 10);

        // Assert
        expect(progress.completed, 10);
        expect(progress.total, 10);
        expect(progress.percentage, 1.0);
        expect(progress.isComplete, isTrue);
      });

      test('should create complete progress with custom lastUpdated', () {
        // Arrange
        final customDate = DateTime(2023, 12, 15);

        // Act
        final progress = Progress.complete(
          total: 5,
          lastUpdated: customDate,
        );

        // Assert
        expect(progress.lastUpdated, customDate);
      });
    });

    group('Progress Status', () {
      test('should return notStarted for 0% progress', () {
        // Arrange & Act
        final progress = Progress.fromPercentage(percentage: 0.0);

        // Assert
        expect(progress.status, ProgressStatus.notStarted);
        expect(progress.status.label, 'Non commencé');
        expect(progress.status.colorCode, '#9E9E9E');
        expect(progress.status.iconName, 'radio_button_unchecked');
      });

      test('should return inProgress for small percentage', () {
        // Arrange & Act
        final progress = Progress.fromPercentage(percentage: 0.3);

        // Assert
        expect(progress.status, ProgressStatus.inProgress);
        expect(progress.status.label, 'En cours');
        expect(progress.status.colorCode, '#2196F3');
        expect(progress.status.iconName, 'play_circle_outline');
      });

      test('should return halfWay for 50-79% progress', () {
        // Arrange & Act
        final progress = Progress.fromPercentage(percentage: 0.65);

        // Assert
        expect(progress.status, ProgressStatus.halfWay);
        expect(progress.status.label, 'À mi-parcours');
        expect(progress.status.colorCode, '#FF9800');
        expect(progress.status.iconName, 'adjust');
      });

      test('should return almostDone for 80-99% progress', () {
        // Arrange & Act
        final progress = Progress.fromPercentage(percentage: 0.85);

        // Assert
        expect(progress.status, ProgressStatus.almostDone);
        expect(progress.status.label, 'Presque terminé');
        expect(progress.status.colorCode, '#4CAF50');
        expect(progress.status.iconName, 'check_circle_outline');
      });

      test('should return completed for 100% progress', () {
        // Arrange & Act
        final progress = Progress.fromPercentage(percentage: 1.0);

        // Assert
        expect(progress.status, ProgressStatus.completed);
        expect(progress.status.label, 'Terminé');
        expect(progress.status.colorCode, '#4CAF50');
        expect(progress.status.iconName, 'check_circle');
      });

      test('should handle boundary cases for status', () {
        // Arrange & Act
        final halfWayBoundary = Progress.fromPercentage(percentage: 0.5);
        final almostDoneBoundary = Progress.fromPercentage(percentage: 0.8);

        // Assert
        expect(halfWayBoundary.status, ProgressStatus.halfWay);
        expect(almostDoneBoundary.status, ProgressStatus.almostDone);
      });
    });

    group('Update Methods', () {
      test('should update completed count', () {
        // Arrange
        final original = Progress.fromCounts(completed: 3, total: 10);

        // Act
        final updated = original.updateCompleted(7);

        // Assert
        expect(updated.completed, 7);
        expect(updated.total, 10);
        expect(updated.percentage, closeTo(0.7, 0.001));
        expect(updated.lastUpdated, isNotNull);
        expect(updated.lastUpdated!.isAfter(original.lastUpdated!) || 
               updated.lastUpdated!.isAtSameMomentAs(original.lastUpdated!), isTrue);
      });

      test('should clamp completed count to valid range', () {
        // Arrange
        final original = Progress.fromCounts(completed: 3, total: 10);

        // Act
        final updatedNegative = original.updateCompleted(-1);
        final updatedExcessive = original.updateCompleted(15);

        // Assert
        expect(updatedNegative.completed, 0);
        expect(updatedExcessive.completed, 10);
      });

      test('should update total count', () {
        // Arrange
        final original = Progress.fromCounts(completed: 3, total: 5);

        // Act
        final updated = original.updateTotal(10);

        // Assert
        expect(updated.completed, 3);
        expect(updated.total, 10);
        expect(updated.percentage, closeTo(0.3, 0.001));
        expect(updated.lastUpdated, isNotNull);
      });

      test('should throw ArgumentError when new total is less than completed', () {
        // Arrange
        final original = Progress.fromCounts(completed: 8, total: 10);

        // Act & Assert
        expect(
          () => original.updateTotal(5),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Combination Methods', () {
      test('should combine two progresses correctly', () {
        // Arrange
        final progress1 = Progress.fromCounts(completed: 3, total: 5);
        final progress2 = Progress.fromCounts(completed: 7, total: 10);

        // Act
        final combined = progress1.combineWith(progress2);

        // Assert
        expect(combined.completed, 10);
        expect(combined.total, 15);
        expect(combined.percentage, closeTo(0.667, 0.001));
        expect(combined.lastUpdated, isNotNull);
      });

      test('should combine with empty progress', () {
        // Arrange
        final progress = Progress.fromCounts(completed: 3, total: 5);
        final empty = Progress.empty();

        // Act
        final combined = progress.combineWith(empty);

        // Assert
        expect(combined.completed, 3);
        expect(combined.total, 5);
        expect(combined.percentage, closeTo(0.6, 0.001));
      });
    });

    group('Comparison Methods', () {
      test('should compare progresses correctly', () {
        // Arrange
        final progress30 = Progress.fromPercentage(percentage: 0.3);
        final progress60 = Progress.fromPercentage(percentage: 0.6);
        final progress90 = Progress.fromPercentage(percentage: 0.9);

        // Act & Assert
        expect(progress90.compareTo(progress60), greaterThan(0));
        expect(progress60.compareTo(progress30), greaterThan(0));
        expect(progress30.compareTo(progress90), lessThan(0));
        expect(progress60.compareTo(progress60), 0);
      });

      test('should determine if progress is higher than another', () {
        // Arrange
        final higher = Progress.fromPercentage(percentage: 0.8);
        final lower = Progress.fromPercentage(percentage: 0.4);

        // Act & Assert
        expect(higher.isHigherThan(lower), isTrue);
        expect(lower.isHigherThan(higher), isFalse);
        expect(higher.isHigherThan(higher), isFalse);
      });
    });

    group('Boolean Properties', () {
      test('should determine if progress is complete', () {
        // Arrange
        final incomplete = Progress.fromPercentage(percentage: 0.99);
        final complete = Progress.fromPercentage(percentage: 1.0);

        // Act & Assert
        expect(incomplete.isComplete, isFalse);
        expect(complete.isComplete, isTrue);
      });

      test('should determine if progress has started', () {
        // Arrange
        final notStarted = Progress.fromPercentage(percentage: 0.0);
        final started = Progress.fromPercentage(percentage: 0.01);

        // Act & Assert
        expect(notStarted.hasStarted, isFalse);
        expect(started.hasStarted, isTrue);
      });
    });

    group('Equality and Hash', () {
      test('should be equal for same percentage, completed, and total', () {
        // Arrange
        final progress1 = Progress.fromCounts(completed: 3, total: 5);
        final progress2 = Progress.fromCounts(completed: 3, total: 5);

        // Act & Assert
        expect(progress1 == progress2, isTrue);
        expect(progress1.hashCode, progress2.hashCode);
      });

      test('should not be equal for different values', () {
        // Arrange
        final progress1 = Progress.fromCounts(completed: 3, total: 5);
        final progress2 = Progress.fromCounts(completed: 4, total: 5);

        // Act & Assert
        expect(progress1 == progress2, isFalse);
        expect(progress1.hashCode, isNot(progress2.hashCode));
      });

      test('should be identical when same instance', () {
        // Arrange
        final progress = Progress.fromCounts(completed: 3, total: 5);

        // Act & Assert
        expect(identical(progress, progress), isTrue);
        expect(progress == progress, isTrue);
      });
    });

    group('String Representation', () {
      test('should format toString correctly', () {
        // Arrange
        final progress = Progress.fromCounts(completed: 3, total: 5);

        // Act & Assert
        expect(progress.toString(), 'Progress(60.0%, 3/5)');
      });

      test('should format toString for complete progress', () {
        // Arrange
        final progress = Progress.complete(total: 10);

        // Act & Assert
        expect(progress.toString(), 'Progress(100.0%, 10/10)');
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly with lastUpdated', () {
        // Arrange
        final lastUpdated = DateTime(2023, 12, 15, 10, 30);
        final progress = Progress.fromCounts(
          completed: 3,
          total: 5,
          lastUpdated: lastUpdated,
        );

        // Act
        final json = progress.toJson();

        // Assert
        expect(json, {
          'percentage': closeTo(0.6, 0.001),
          'completed': 3,
          'total': 5,
          'lastUpdated': '2023-12-15T10:30:00.000',
        });
      });

      test('should serialize to JSON correctly without lastUpdated', () {
        // Arrange
        final progress = Progress.fromCounts(completed: 0, total: 0);

        // Act
        final json = progress.toJson();

        // Assert
        expect(json['percentage'], 0.0);
        expect(json['completed'], 0);
        expect(json['total'], 0);
        expect(json['lastUpdated'], isNotNull); // Should have been set automatically
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'percentage': 0.6,
          'completed': 3,
          'total': 5,
          'lastUpdated': '2023-12-15T10:30:00.000',
        };

        // Act
        final progress = Progress.fromJson(json);

        // Assert
        expect(progress.completed, 3);
        expect(progress.total, 5);
        expect(progress.percentage, closeTo(0.6, 0.001));
        expect(progress.lastUpdated, DateTime(2023, 12, 15, 10, 30));
      });

      test('should deserialize from JSON without lastUpdated', () {
        // Arrange
        final json = {
          'percentage': 0.4,
          'completed': 2,
          'total': 5,
          'lastUpdated': null,
        };

        // Act
        final progress = Progress.fromJson(json);

        // Assert
        expect(progress.completed, 2);
        expect(progress.total, 5);
        // fromCounts sets DateTime.now() when lastUpdated is null
        expect(progress.lastUpdated, isNotNull);
        expect(progress.lastUpdated!.isBefore(DateTime.now().add(Duration(seconds: 1))), isTrue);
      });

      test('should maintain equality through JSON round-trip', () {
        // Arrange
        final originalProgress = Progress.fromCounts(
          completed: 7,
          total: 10,
          lastUpdated: DateTime(2023, 12, 15),
        );

        // Act
        final json = originalProgress.toJson();
        final deserializedProgress = Progress.fromJson(json);

        // Assert
        expect(deserializedProgress.completed, originalProgress.completed);
        expect(deserializedProgress.total, originalProgress.total);
        expect(deserializedProgress.percentage, originalProgress.percentage);
        expect(deserializedProgress.lastUpdated, originalProgress.lastUpdated);
      });
    });
  });
}