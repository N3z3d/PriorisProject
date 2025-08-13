import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/priority.dart';

void main() {
  group('Priority Value Object', () {
    group('Factory Constructors', () {
      test('should create priority from ELO score without due date', () {
        // Arrange & Act
        final priority = Priority.fromEloAndDueDate(eloScore: 1200.0);

        // Assert
        expect(priority.level, PriorityLevel.low); // 0.25 < 0.5 -> low
        expect(priority.score, closeTo(0.25, 0.01)); // (1200-800)/1600 = 0.25
        expect(priority.reason, isNull);
      });

      test('should create priority with overdue task', () {
        // Arrange
        final now = DateTime(2023, 12, 15);
        final dueDate = DateTime(2023, 12, 10); // 5 days overdue

        // Act
        final priority = Priority.fromEloAndDueDate(
          eloScore: 1200.0,
          dueDate: dueDate,
          now: now,
        );

        // Assert
        expect(priority.level, PriorityLevel.medium); // 0.5 >= 0.5 -> medium
        expect(priority.score, closeTo(0.5, 0.01)); // 0.25 * 2.0 = 0.5
        expect(priority.reason, contains('Tâche en retard de 5 jour(s)'));
      });

      test('should create priority with task due today', () {
        // Arrange
        final now = DateTime(2023, 12, 15);
        final dueDate = DateTime(2023, 12, 15); // Due today

        // Act
        final priority = Priority.fromEloAndDueDate(
          eloScore: 1200.0,
          dueDate: dueDate,
          now: now,
        );

        // Assert
        expect(priority.score, closeTo(0.45, 0.01)); // 0.25 * 1.8 = 0.45
        expect(priority.reason, 'Échéance aujourd\'hui');
      });

      test('should create priority with task due tomorrow', () {
        // Arrange
        final now = DateTime(2023, 12, 15);
        final dueDate = DateTime(2023, 12, 16); // Due tomorrow

        // Act
        final priority = Priority.fromEloAndDueDate(
          eloScore: 1200.0,
          dueDate: dueDate,
          now: now,
        );

        // Assert
        expect(priority.score, closeTo(0.375, 0.01)); // 0.25 * 1.5 = 0.375
        expect(priority.reason, 'Échéance demain');
      });

      test('should create priority with task due in 3 days', () {
        // Arrange
        final now = DateTime(2023, 12, 15);
        final dueDate = DateTime(2023, 12, 18); // Due in 3 days

        // Act
        final priority = Priority.fromEloAndDueDate(
          eloScore: 1200.0,
          dueDate: dueDate,
          now: now,
        );

        // Assert
        expect(priority.score, closeTo(0.325, 0.01)); // 0.25 * 1.3 = 0.325
        expect(priority.reason, 'Échéance dans 3 jour(s)');
      });

      test('should create priority with task due in a week', () {
        // Arrange
        final now = DateTime(2023, 12, 15);
        final dueDate = DateTime(2023, 12, 20); // Due in 5 days

        // Act
        final priority = Priority.fromEloAndDueDate(
          eloScore: 1200.0,
          dueDate: dueDate,
          now: now,
        );

        // Assert
        expect(priority.score, closeTo(0.275, 0.01)); // 0.25 * 1.1 = 0.275
        expect(priority.reason, 'Échéance dans 5 jour(s)');
      });

      test('should clamp ELO score within valid range', () {
        // Arrange & Act
        final lowElo = Priority.fromEloAndDueDate(eloScore: 500.0);
        final highElo = Priority.fromEloAndDueDate(eloScore: 3000.0);

        // Assert
        expect(lowElo.score, 0.0); // Clamped to minimum
        expect(highElo.score, 1.0); // Clamped to maximum
      });

      test('should clamp final score to maximum 2.0', () {
        // Arrange
        final now = DateTime(2023, 12, 15);
        final dueDate = DateTime(2023, 12, 10); // Overdue

        // Act
        final priority = Priority.fromEloAndDueDate(
          eloScore: 2400.0, // High ELO
          dueDate: dueDate,
          now: now,
        );

        // Assert
        expect(priority.score, 2.0); // Clamped to maximum
      });
    });

    group('Specific Level Constructors', () {
      test('should create critical priority', () {
        // Arrange & Act
        final priority = Priority.critical(reason: 'Emergency task');

        // Assert
        expect(priority.level, PriorityLevel.critical);
        expect(priority.score, 2.0);
        expect(priority.reason, 'Emergency task');
      });

      test('should create high priority', () {
        // Arrange & Act
        final priority = Priority.high();

        // Assert
        expect(priority.level, PriorityLevel.high);
        expect(priority.score, 1.5);
        expect(priority.reason, isNull);
      });

      test('should create medium priority', () {
        // Arrange & Act
        final priority = Priority.medium(reason: 'Standard task');

        // Assert
        expect(priority.level, PriorityLevel.medium);
        expect(priority.score, 1.0);
        expect(priority.reason, 'Standard task');
      });

      test('should create low priority', () {
        // Arrange & Act
        final priority = Priority.low();

        // Assert
        expect(priority.level, PriorityLevel.low);
        expect(priority.score, 0.5);
        expect(priority.reason, isNull);
      });
    });

    group('Comparison Methods', () {
      test('should compare priorities correctly', () {
        // Arrange
        final low = Priority.low();
        final medium = Priority.medium();
        final high = Priority.high();
        final critical = Priority.critical();

        // Act & Assert
        expect(critical.compareTo(high), lessThan(0)); // Critical comes first
        expect(high.compareTo(medium), lessThan(0));
        expect(medium.compareTo(low), lessThan(0));
        expect(low.compareTo(critical), greaterThan(0));
      });

      test('should determine if priority is higher than another', () {
        // Arrange
        final high = Priority.high();
        final medium = Priority.medium();

        // Act & Assert
        expect(high.isHigherThan(medium), isTrue);
        expect(medium.isHigherThan(high), isFalse);
      });

      test('should determine if priority requires immediate action', () {
        // Arrange
        final low = Priority.low();
        final medium = Priority.medium();
        final high = Priority.high();
        final critical = Priority.critical();

        // Act & Assert
        expect(low.requiresImmediateAction, isFalse);
        expect(medium.requiresImmediateAction, isFalse);
        expect(high.requiresImmediateAction, isTrue);
        expect(critical.requiresImmediateAction, isTrue);
      });

      test('should determine if priority can be deferred', () {
        // Arrange
        final low = Priority.low();
        final medium = Priority.medium();
        final high = Priority.high();
        final critical = Priority.critical();

        // Act & Assert
        expect(low.canBeDeferred, isTrue);
        expect(medium.canBeDeferred, isTrue);
        expect(high.canBeDeferred, isFalse);
        expect(critical.canBeDeferred, isFalse);
      });
    });

    group('Equality and Hash', () {
      test('should be equal for same level, score, and reason', () {
        // Arrange
        final priority1 = Priority.high(reason: 'Important');
        final priority2 = Priority.high(reason: 'Important');

        // Act & Assert
        expect(priority1 == priority2, isTrue);
        expect(priority1.hashCode, priority2.hashCode);
      });

      test('should not be equal for different levels', () {
        // Arrange
        final high = Priority.high();
        final medium = Priority.medium();

        // Act & Assert
        expect(high == medium, isFalse);
        expect(high.hashCode, isNot(medium.hashCode));
      });

      test('should not be equal for different reasons', () {
        // Arrange
        final priority1 = Priority.high(reason: 'Reason A');
        final priority2 = Priority.high(reason: 'Reason B');

        // Act & Assert
        expect(priority1 == priority2, isFalse);
      });
    });

    group('String Representation', () {
      test('should format toString correctly with reason', () {
        // Arrange
        final priority = Priority.high(reason: 'Urgent task');

        // Act & Assert
        expect(priority.toString(), 'Priority(high, score: 1.50 (Urgent task))');
      });

      test('should format toString correctly without reason', () {
        // Arrange
        final priority = Priority.medium();

        // Act & Assert
        expect(priority.toString(), 'Priority(medium, score: 1.00)');
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final priority = Priority.high(reason: 'Important task');

        // Act
        final json = priority.toJson();

        // Assert
        expect(json, {
          'level': 'high',
          'score': 1.5,
          'reason': 'Important task',
        });
      });

      test('should serialize to JSON correctly without reason', () {
        // Arrange
        final priority = Priority.medium();

        // Act
        final json = priority.toJson();

        // Assert
        expect(json, {
          'level': 'medium',
          'score': 1.0,
          'reason': null,
        });
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'level': 'critical',
          'score': 2.0,
          'reason': 'Emergency',
        };

        // Act
        final priority = Priority.fromJson(json);

        // Assert
        expect(priority.level, PriorityLevel.critical);
        expect(priority.score, 2.0);
        expect(priority.reason, 'Emergency');
      });

      test('should handle invalid level gracefully', () {
        // Arrange
        final json = {
          'level': 'invalid_level',
          'score': 1.0,
          'reason': null,
        };

        // Act
        final priority = Priority.fromJson(json);

        // Assert
        expect(priority.level, PriorityLevel.medium); // Default fallback
      });

      test('should maintain equality through JSON round-trip', () {
        // Arrange
        final originalPriority = Priority.high(reason: 'Test');

        // Act
        final json = originalPriority.toJson();
        final deserializedPriority = Priority.fromJson(json);

        // Assert
        expect(deserializedPriority, originalPriority);
      });
    });
  });

  group('PriorityLevel Enum', () {
    test('should determine level from score correctly', () {
      // Act & Assert
      expect(PriorityLevel.fromScore(0.2), PriorityLevel.low);
      expect(PriorityLevel.fromScore(0.7), PriorityLevel.medium);
      expect(PriorityLevel.fromScore(1.2), PriorityLevel.high);
      expect(PriorityLevel.fromScore(1.8), PriorityLevel.critical);
    });

    test('should handle boundary scores correctly', () {
      // Act & Assert
      expect(PriorityLevel.fromScore(0.5), PriorityLevel.medium);
      expect(PriorityLevel.fromScore(1.0), PriorityLevel.high);
      expect(PriorityLevel.fromScore(1.5), PriorityLevel.critical);
    });

    test('should return correct colors for each level', () {
      // Act & Assert
      expect(PriorityLevel.low.colorCode, '#4CAF50');
      expect(PriorityLevel.medium.colorCode, '#FF9800');
      expect(PriorityLevel.high.colorCode, '#F44336');
      expect(PriorityLevel.critical.colorCode, '#9C27B0');
    });

    test('should return correct icons for each level', () {
      // Act & Assert
      expect(PriorityLevel.low.iconName, 'low_priority');
      expect(PriorityLevel.medium.iconName, 'priority_high');
      expect(PriorityLevel.high.iconName, 'priority_high');
      expect(PriorityLevel.critical.iconName, 'error');
    });
  });

  group('PriorityRange Class', () {
    test('should check if score is contained in range', () {
      // Arrange
      final range = PriorityRange(0.5, 1.0);

      // Act & Assert
      expect(range.contains(0.3), isFalse);
      expect(range.contains(0.5), isTrue);
      expect(range.contains(0.7), isTrue);
      expect(range.contains(1.0), isFalse); // End is exclusive
      expect(range.contains(1.2), isFalse);
    });

    test('should format toString correctly', () {
      // Arrange
      final range = PriorityRange(0.0, 0.5);

      // Act & Assert
      expect(range.toString(), 'PriorityRange(0.0 - 0.5)');
    });
  });
}