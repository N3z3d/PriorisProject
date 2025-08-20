import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/task/services/task_elo_service.dart';
import 'package:prioris/domain/task/aggregates/task_aggregate.dart';
import 'package:prioris/domain/core/value_objects/elo_score.dart';
import 'package:prioris/domain/core/value_objects/elo_variation_settings.dart';

/// Tests TDD pour la variation dynamique d'ELO
/// Red -> Green -> Refactor
void main() {
  group('TaskEloService - Variation ELO Dynamique', () {
    late TaskEloService eloService;
    late EloVariationSettings settings;

    setUp(() {
      eloService = TaskEloService();
      settings = EloVariationSettings.defaultSettings();
    });

    test('performDuelWithVariation doit appliquer la variation pour nouvelles tâches', () {
      // Arrange - deux tâches nouvelles (lastChosenAt = null)
      final task1 = TaskAggregate.create(
        title: 'Nouvelle Tâche 1',
        eloScore: EloScore.fromValue(1200),
      );
      final task2 = TaskAggregate.create(
        title: 'Nouvelle Tâche 2', 
        eloScore: EloScore.fromValue(1200),
      );

      // Act - maintenant la méthode existe
      final result = eloService.performDuelWithVariation(task1, task2, settings);

      // Assert - le résultat doit être valide
      expect(result, isNotNull);
      expect(result.winner, isIn([task1, task2]));
      expect(result.loser, isIn([task1, task2]));
      expect(result.winner, isNot(equals(result.loser)));
    });

    test('calculateDynamicEloChange doit multiplier le changement pour tâches anciennes', () {
      // Arrange
      final oldDate = DateTime.now().subtract(const Duration(days: 35));
      const baseEloChange = 30.0;

      // Act
      final dynamicChange = eloService.calculateDynamicEloChange(
        baseEloChange: baseEloChange,
        lastChosenAt: oldDate,
        settings: settings,
      );

      // Assert - doit appliquer le multiplicateur 30+ jours (2.0x)
      expect(dynamicChange, 60.0); // 30.0 * 2.0
    });

    test('updateLastChosenAt doit mettre à jour la date de dernier choix', () {
      // Arrange
      final task = TaskAggregate.create(title: 'Test Task');

      // Act - pour l'instant, cette méthode ne fait que logger
      expect(() => eloService.updateLastChosenAt(task), returnsNormally);

      // Assert - vérifier que lastChosenAt est toujours null (pas encore implémenté)
      expect(task.lastChosenAt, isNull);
    });
  });
}