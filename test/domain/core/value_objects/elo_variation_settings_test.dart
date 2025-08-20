import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/elo_variation_settings.dart';

/// Tests TDD pour les paramètres de variation ELO
/// Phase Red -> Green -> Refactor
void main() {
  group('EloVariationSettings', () {
    test('devrait créer des paramètres par défaut', () {
      // Act
      final settings = EloVariationSettings.defaultSettings();

      // Assert
      expect(settings.newTaskMultiplier, 1.2);
      expect(settings.oldTaskMultiplier7Days, 1.5);
      expect(settings.oldTaskMultiplier30Days, 2.0);
      expect(settings.threshold7Days, 7);
      expect(settings.threshold30Days, 30);
    });

    test('devrait calculer le multiplicateur pour une nouvelle tâche (jamais choisie)', () {
      // Arrange
      final settings = EloVariationSettings.defaultSettings();

      // Act
      final multiplier = settings.calculateMultiplier(lastChosenAt: null);

      // Assert
      expect(multiplier, 1.2); // Nouvelle tâche
    });

    test('devrait calculer le multiplicateur pour une tâche récente (< 7 jours)', () {
      // Arrange
      final settings = EloVariationSettings.defaultSettings();
      final recentDate = DateTime.now().subtract(const Duration(days: 3));

      // Act
      final multiplier = settings.calculateMultiplier(lastChosenAt: recentDate);

      // Assert
      expect(multiplier, 1.0); // Pas de bonus
    });

    test('devrait calculer le multiplicateur pour une tâche de 7-29 jours', () {
      // Arrange
      final settings = EloVariationSettings.defaultSettings();
      final oldDate = DateTime.now().subtract(const Duration(days: 15));

      // Act
      final multiplier = settings.calculateMultiplier(lastChosenAt: oldDate);

      // Assert
      expect(multiplier, 1.5); // Bonus 7 jours
    });

    test('devrait calculer le multiplicateur pour une tâche de 30+ jours', () {
      // Arrange
      final settings = EloVariationSettings.defaultSettings();
      final veryOldDate = DateTime.now().subtract(const Duration(days: 45));

      // Act
      final multiplier = settings.calculateMultiplier(lastChosenAt: veryOldDate);

      // Assert
      expect(multiplier, 2.0); // Bonus 30 jours
    });

    test('devrait permettre de créer des paramètres personnalisés', () {
      // Act
      final customSettings = EloVariationSettings(
        newTaskMultiplier: 1.3,
        oldTaskMultiplier7Days: 1.8,
        oldTaskMultiplier30Days: 2.5,
        threshold7Days: 5,
        threshold30Days: 20,
      );

      // Assert
      expect(customSettings.newTaskMultiplier, 1.3);
      expect(customSettings.threshold7Days, 5);
    });

    test('devrait valider que les multiplicateurs sont positifs', () {
      // Act & Assert
      expect(
        () => EloVariationSettings(
          newTaskMultiplier: -1.0,
          oldTaskMultiplier7Days: 1.5,
          oldTaskMultiplier30Days: 2.0,
          threshold7Days: 7,
          threshold30Days: 30,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('devrait valider que threshold30Days > threshold7Days', () {
      // Act & Assert
      expect(
        () => EloVariationSettings(
          newTaskMultiplier: 1.2,
          oldTaskMultiplier7Days: 1.5,
          oldTaskMultiplier30Days: 2.0,
          threshold7Days: 30,
          threshold30Days: 7, // Invalide : 30 < 7
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}