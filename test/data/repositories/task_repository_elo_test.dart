import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

void main() {
  group('InMemoryTaskRepository.updateEloScores', () {
    late InMemoryTaskRepository repository;

    setUp(() {
      repository = InMemoryTaskRepository();
    });

    test('persiste les scores reçus sans les recalculer', () async {
      final winner = Task(title: 'Winner', eloScore: 1216.0);
      final loser = Task(title: 'Loser', eloScore: 1184.0);
      await repository.saveTask(winner);
      await repository.saveTask(loser);

      await repository.updateEloScores(winner, loser);

      final tasks = await repository.getAllTasks();
      final savedWinner = tasks.firstWhere((t) => t.id == winner.id);
      final savedLoser = tasks.firstWhere((t) => t.id == loser.id);

      expect(savedWinner.eloScore, closeTo(1216.0, 0.001),
          reason: 'Le score du gagnant ne doit pas être recalculé une 2e fois');
      expect(savedLoser.eloScore, closeTo(1184.0, 0.001),
          reason: 'Le score du perdant ne doit pas être recalculé une 2e fois');
    });

    test('ne modifie pas les scores si les tâches ne sont pas en mémoire', () async {
      final winner = Task(title: 'Ghost Winner', eloScore: 1300.0);
      final loser = Task(title: 'Ghost Loser', eloScore: 1100.0);

      await repository.updateEloScores(winner, loser);

      expect(await repository.getAllTasks(), isEmpty,
          reason: 'Aucune tâche ne doit être créée pour des entités fantômes');
    });

    test('persiste les scores limites sans les modifier (pas de recalcul)', () async {
      final high = Task(title: 'High', eloScore: 2990.0);
      final low = Task(title: 'Low', eloScore: 210.0);
      await repository.saveTask(high);
      await repository.saveTask(low);

      await repository.updateEloScores(high, low);

      final tasks = await repository.getAllTasks();
      expect(tasks.firstWhere((t) => t.id == high.id).eloScore, closeTo(2990.0, 0.001),
          reason: 'Le score élevé doit être persisté tel quel, sans recalcul');
      expect(tasks.firstWhere((t) => t.id == low.id).eloScore, closeTo(210.0, 0.001),
          reason: 'Le score bas doit être persisté tel quel, sans recalcul');
    });

    test('updateEloScores met bien à jour les deux tâches en mémoire', () async {
      final winner = Task(title: 'W', eloScore: 1350.0);
      final loser = Task(title: 'L', eloScore: 1050.0);
      await repository.saveTask(winner);
      await repository.saveTask(loser);

      final updatedWinner = winner.copyWith(eloScore: 1370.0);
      final updatedLoser = loser.copyWith(eloScore: 1030.0);
      await repository.updateEloScores(updatedWinner, updatedLoser);

      final tasks = await repository.getAllTasks();
      expect(tasks.firstWhere((t) => t.id == winner.id).eloScore,
          closeTo(1370.0, 0.001));
      expect(tasks.firstWhere((t) => t.id == loser.id).eloScore,
          closeTo(1030.0, 0.001));
    });
  });
}
