import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/task/services/task_elo_service.dart';
import 'package:prioris/domain/task/aggregates/task_aggregate.dart';
import 'package:prioris/domain/core/value_objects/elo_score.dart';

/// Tests pour le mode aléatoire du système ELO
/// Selon l'approche TDD : Red -> Green -> Refactor
void main() {
  group('TaskEloService - Mode Aléatoire', () {
    late TaskEloService eloService;
    late List<TaskAggregate> testTasks;

    setUp(() {
      eloService = TaskEloService();
      
      // Créer des tâches de test avec différents scores ELO
      testTasks = [
        TaskAggregate.create(
          title: 'Tâche Facile',
          eloScore: EloScore.fromValue(1000),
        ),
        TaskAggregate.create(
          title: 'Tâche Moyenne',
          eloScore: EloScore.fromValue(1200),
        ),
        TaskAggregate.create(
          title: 'Tâche Difficile', 
          eloScore: EloScore.fromValue(1500),
        ),
        TaskAggregate.create(
          title: 'Tâche Expert',
          eloScore: EloScore.fromValue(1800),
        ),
      ];
    });

    test('selectRandomTask doit retourner une tâche aléatoire de la liste', () {
      // Arrange - nos tâches de test sont déjà créées

      // Act
      final selectedTask = eloService.selectRandomTask(testTasks);

      // Assert
      expect(selectedTask, isNotNull);
      expect(testTasks.contains(selectedTask), isTrue);
    });

    test('selectRandomTask doit retourner null pour une liste vide', () {
      // Arrange
      final emptyTasks = <TaskAggregate>[];

      // Act  
      final selectedTask = eloService.selectRandomTask(emptyTasks);

      // Assert
      expect(selectedTask, isNull);
    });

    test('selectRandomTask doit exclure les tâches complétées', () {
      // Arrange
      testTasks[0].complete(); // Marquer une tâche comme complétée
      testTasks[2].complete(); // Marquer une autre comme complétée

      // Act
      final selectedTask = eloService.selectRandomTask(testTasks);

      // Assert
      expect(selectedTask, isNotNull);
      expect(selectedTask!.isCompleted, isFalse);
      expect([testTasks[1], testTasks[3]].contains(selectedTask), isTrue);
    });

    test('selectRandomTask doit retourner null si toutes les tâches sont complétées', () {
      // Arrange
      for (final task in testTasks) {
        task.complete();
      }

      // Act
      final selectedTask = eloService.selectRandomTask(testTasks);

      // Assert
      expect(selectedTask, isNull);
    });

    test('multiple appels de selectRandomTask doivent potentiellement retourner des tâches différentes', () {
      // Arrange - tâches déjà créées
      final results = <TaskAggregate>{};

      // Act - faire plusieurs sélections pour tester la randomisation
      for (int i = 0; i < 20; i++) {
        final selected = eloService.selectRandomTask(testTasks);
        if (selected != null) {
          results.add(selected);
        }
      }

      // Assert - on devrait avoir au moins 2 tâches différentes sur 20 essais
      // (probabilité très élevée avec 4 tâches disponibles)
      expect(results.length, greaterThanOrEqualTo(2));
    });

    // TODO: Implémenter les tests pour la pondération par ancienneté
    // group('Mode aléatoire avec pondération par ancienneté', () {
    //   test('selectRandomTaskWithAgeWeight doit favoriser les tâches anciennes', () {
    //     // Ce test échouera jusqu'à ce qu'on implémente la méthode
    //     expect(() => eloService.selectRandomTaskWithAgeWeight(testTasks), 
    //            throwsA(isA<NoSuchMethodError>()));
    //   });
    // });
  });
}