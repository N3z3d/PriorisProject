import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/elo_score.dart';

void main() {
  group('EloScore Value Object', () {
    group('Construction', () {
      test('should create initial EloScore with default value 1200', () {
        // Arrange & Act
        final score = EloScore.initial();

        // Assert
        expect(score.value, 1200.0);
        expect(score.asInt, 1200);
      });

      test('should create EloScore with valid value', () {
        // Arrange & Act
        final score = EloScore.fromValue(1500.0);

        // Assert
        expect(score.value, 1500.0);
        expect(score.asInt, 1500);
      });

      test('should throw ArgumentError for value below minimum', () {
        // Arrange & Act & Assert
        expect(
          () => EloScore.fromValue(-1.0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for value above maximum', () {
        // Arrange & Act & Assert
        expect(
          () => EloScore.fromValue(3001.0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept boundary values', () {
        // Arrange & Act
        final minScore = EloScore.fromValue(0.0);
        final maxScore = EloScore.fromValue(3000.0);

        // Assert
        expect(minScore.value, 0.0);
        expect(maxScore.value, 3000.0);
      });
    });

    group('Win Probability Calculation', () {
      test('should calculate 50% win probability for equal scores', () {
        // Arrange
        final score1 = EloScore.fromValue(1200.0);
        final score2 = EloScore.fromValue(1200.0);

        // Act
        final probability = score1.calculateWinProbability(score2);

        // Assert
        expect(probability, closeTo(0.5, 0.001));
      });

      test('should calculate higher win probability for higher score', () {
        // Arrange
        final higherScore = EloScore.fromValue(1400.0);
        final lowerScore = EloScore.fromValue(1200.0);

        // Act
        final probability = higherScore.calculateWinProbability(lowerScore);

        // Assert
        expect(probability, greaterThan(0.5));
        expect(probability, closeTo(0.76, 0.01));
      });

      test('should calculate lower win probability for lower score', () {
        // Arrange
        final lowerScore = EloScore.fromValue(1000.0);
        final higherScore = EloScore.fromValue(1400.0);

        // Act
        final probability = lowerScore.calculateWinProbability(higherScore);

        // Assert
        expect(probability, lessThan(0.5));
        expect(probability, closeTo(0.09, 0.01));
      });
    });

    group('ELO Update After Duel', () {
      test('should increase score after winning against equal opponent', () {
        // Arrange
        final initialScore = EloScore.fromValue(1200.0);
        final opponent = EloScore.fromValue(1200.0);

        // Act
        final updatedScore = initialScore.updateAfterDuel(
          opponent: opponent,
          won: true,
        );

        // Assert
        expect(updatedScore.value, greaterThan(initialScore.value));
        expect(updatedScore.value, closeTo(1216.0, 1.0));
      });

      test('should decrease score after losing against equal opponent', () {
        // Arrange
        final initialScore = EloScore.fromValue(1200.0);
        final opponent = EloScore.fromValue(1200.0);

        // Act
        final updatedScore = initialScore.updateAfterDuel(
          opponent: opponent,
          won: false,
        );

        // Assert
        expect(updatedScore.value, lessThan(initialScore.value));
        expect(updatedScore.value, closeTo(1184.0, 1.0));
      });

      test('should respect minimum score boundary', () {
        // Arrange
        final lowScore = EloScore.fromValue(10.0);
        final highOpponent = EloScore.fromValue(2000.0);

        // Act
        final updatedScore = lowScore.updateAfterDuel(
          opponent: highOpponent,
          won: false,
        );

        // Assert
        expect(updatedScore.value, greaterThanOrEqualTo(0.0));
      });

      test('should respect maximum score boundary', () {
        // Arrange
        final highScore = EloScore.fromValue(2990.0);
        final lowOpponent = EloScore.fromValue(500.0);

        // Act
        final updatedScore = highScore.updateAfterDuel(
          opponent: lowOpponent,
          won: true,
        );

        // Assert
        expect(updatedScore.value, lessThanOrEqualTo(3000.0));
      });

      test('should use custom K-factor', () {
        // Arrange
        final score = EloScore.fromValue(1200.0);
        final opponent = EloScore.fromValue(1200.0);

        // Act
        final updatedWithK16 = score.updateAfterDuel(
          opponent: opponent,
          won: true,
          kFactor: 16.0,
        );
        final updatedWithK64 = score.updateAfterDuel(
          opponent: opponent,
          won: true,
          kFactor: 64.0,
        );

        // Assert
        expect(updatedWithK16.value, closeTo(1208.0, 1.0));
        expect(updatedWithK64.value, closeTo(1232.0, 1.0));
        expect(updatedWithK64.value, greaterThan(updatedWithK16.value));
      });
    });

    group('ELO Categories', () {
      test('should categorize novice correctly', () {
        // Arrange & Act
        final score = EloScore.fromValue(500.0);

        // Assert
        expect(score.category, EloCategory.novice);
        expect(score.category.label, 'Novice');
        expect(score.category.colorCode, '#9E9E9E');
        expect(score.category.iconName, 'star_border');
      });

      test('should categorize beginner correctly', () {
        // Arrange & Act
        final score = EloScore.fromValue(1100.0);

        // Assert
        expect(score.category, EloCategory.beginner);
        expect(score.category.label, 'Débutant');
        expect(score.category.colorCode, '#4CAF50');
        expect(score.category.iconName, 'star_half');
      });

      test('should categorize intermediate correctly', () {
        // Arrange & Act
        final score = EloScore.fromValue(1300.0);

        // Assert
        expect(score.category, EloCategory.intermediate);
        expect(score.category.label, 'Intermédiaire');
        expect(score.category.colorCode, '#2196F3');
        expect(score.category.iconName, 'star');
      });

      test('should categorize advanced correctly', () {
        // Arrange & Act
        final score = EloScore.fromValue(1500.0);

        // Assert
        expect(score.category, EloCategory.advanced);
        expect(score.category.label, 'Avancé');
        expect(score.category.colorCode, '#9C27B0');
        expect(score.category.iconName, 'stars');
      });

      test('should categorize expert correctly', () {
        // Arrange & Act
        final score = EloScore.fromValue(1800.0);

        // Assert
        expect(score.category, EloCategory.expert);
        expect(score.category.label, 'Expert');
        expect(score.category.colorCode, '#FF9800');
        expect(score.category.iconName, 'military_tech');
      });

      test('should handle boundary cases for categories', () {
        // Arrange & Act
        final noviceBoundary = EloScore.fromValue(999.0);
        final beginnerBoundary = EloScore.fromValue(1000.0);
        final intermediateBoundary = EloScore.fromValue(1200.0);
        final advancedBoundary = EloScore.fromValue(1400.0);
        final expertBoundary = EloScore.fromValue(1600.0);

        // Assert
        expect(noviceBoundary.category, EloCategory.novice);
        expect(beginnerBoundary.category, EloCategory.beginner);
        expect(intermediateBoundary.category, EloCategory.intermediate);
        expect(advancedBoundary.category, EloCategory.advanced);
        expect(expertBoundary.category, EloCategory.expert);
      });
    });

    group('Comparison Operators', () {
      test('should compare scores correctly', () {
        // Arrange
        final score1200 = EloScore.fromValue(1200.0);
        final score1300 = EloScore.fromValue(1300.0);
        final score1200Duplicate = EloScore.fromValue(1200.0);

        // Act & Assert
        expect(score1300 > score1200, isTrue);
        expect(score1200 < score1300, isTrue);
        expect(score1300 >= score1200, isTrue);
        expect(score1200 <= score1300, isTrue);
        expect(score1200 >= score1200Duplicate, isTrue);
        expect(score1200 <= score1200Duplicate, isTrue);
      });
    });

    group('Equality and Hash', () {
      test('should be equal for same values', () {
        // Arrange
        final score1 = EloScore.fromValue(1200.0);
        final score2 = EloScore.fromValue(1200.0);

        // Act & Assert
        expect(score1 == score2, isTrue);
        expect(score1.hashCode, score2.hashCode);
      });

      test('should not be equal for different values', () {
        // Arrange
        final score1 = EloScore.fromValue(1200.0);
        final score2 = EloScore.fromValue(1300.0);

        // Act & Assert
        expect(score1 == score2, isFalse);
        expect(score1.hashCode, isNot(score2.hashCode));
      });

      test('should be identical when same instance', () {
        // Arrange
        final score = EloScore.fromValue(1200.0);

        // Act & Assert
        expect(identical(score, score), isTrue);
        expect(score == score, isTrue);
      });
    });

    group('String Representation', () {
      test('should format toString correctly', () {
        // Arrange
        final score = EloScore.fromValue(1234.56);

        // Act & Assert
        expect(score.toString(), 'EloScore(1235)');
      });

      test('should convert to int correctly', () {
        // Arrange
        final score = EloScore.fromValue(1234.67);

        // Act & Assert
        expect(score.asInt, 1235);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final score = EloScore.fromValue(1500.0);

        // Act
        final json = score.toJson();

        // Assert
        expect(json, {'value': 1500.0});
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {'value': 1500.0};

        // Act
        final score = EloScore.fromJson(json);

        // Assert
        expect(score.value, 1500.0);
      });

      test('should maintain equality through JSON round-trip', () {
        // Arrange
        final originalScore = EloScore.fromValue(1234.5);

        // Act
        final json = originalScore.toJson();
        final deserializedScore = EloScore.fromJson(json);

        // Assert
        expect(deserializedScore, originalScore);
      });
    });
  });
}