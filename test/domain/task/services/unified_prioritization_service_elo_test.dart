import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>()])
import 'unified_prioritization_service_elo_test.mocks.dart';

void main() {
  group('UnifiedPrioritizationService — calcul ELO', () {
    late UnifiedPrioritizationService service;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      service = UnifiedPrioritizationService(
        taskRepository: mockRepository,
        converter: ListItemTaskConverter(),
      );
      when(mockRepository.updateEloScores(any, any)).thenAnswer((_) async {});
    });

    test('égalité de scores : winner +16, loser -16 (K=32)', () async {
      final winner = Task(id: 'w', title: 'Winner', eloScore: 1200.0);
      final loser = Task(id: 'l', title: 'Loser', eloScore: 1200.0);

      final result = await service.updateEloScoresFromDuel(winner, loser);

      expect(result.winner.eloScore, closeTo(1216.0, 0.001));
      expect(result.loser.eloScore, closeTo(1184.0, 0.001));
    });

    test('favori qui gagne : gain réduit (probabilité > 0.5)', () async {
      // Winner avec avantage ELO : probabilité > 0.5 → gain < 16
      final winner = Task(id: 'w', title: 'Favori', eloScore: 1400.0);
      final loser = Task(id: 'l', title: 'Outsider', eloScore: 1200.0);

      final result = await service.updateEloScoresFromDuel(winner, loser);

      expect(result.winner.eloScore, greaterThan(1400.0));
      expect(result.winner.eloScore, lessThan(1416.0),
          reason: 'Le favori gagne peu car victoire attendue');
      expect(result.loser.eloScore, lessThan(1200.0));
    });

    test('outsider qui gagne : gain amplifié (probabilité < 0.5)', () async {
      final winner = Task(id: 'w', title: 'Outsider', eloScore: 1200.0);
      final loser = Task(id: 'l', title: 'Favori', eloScore: 1400.0);

      final result = await service.updateEloScoresFromDuel(winner, loser);

      expect(result.winner.eloScore, greaterThan(1216.0),
          reason: "L'outsider gagne beaucoup car victoire inattendue");
      expect(result.loser.eloScore, lessThan(1400.0));
    });

    test('les scores originaux ne sont pas mutés', () async {
      final winner = Task(id: 'w', title: 'W', eloScore: 1200.0);
      final loser = Task(id: 'l', title: 'L', eloScore: 1200.0);

      await service.updateEloScoresFromDuel(winner, loser);

      expect(winner.eloScore, 1200.0, reason: 'Task original immuable via copyWith');
      expect(loser.eloScore, 1200.0, reason: 'Task original immuable via copyWith');
    });

    test('DuelResult contient les deux tâches mises à jour', () async {
      final winner = Task(id: 'w', title: 'W', eloScore: 1200.0);
      final loser = Task(id: 'l', title: 'L', eloScore: 1200.0);

      final result = await service.updateEloScoresFromDuel(winner, loser);

      expect(result.winner.id, winner.id);
      expect(result.loser.id, loser.id);
      expect(result.winner.eloScore, isNot(equals(winner.eloScore)));
      expect(result.loser.eloScore, isNot(equals(loser.eloScore)));
    });

    test('updateEloScores est appelé une seule fois (pas de double calcul)', () async {
      final winner = Task(id: 'w', title: 'W', eloScore: 1200.0);
      final loser = Task(id: 'l', title: 'L', eloScore: 1200.0);

      await service.updateEloScoresFromDuel(winner, loser);

      verify(mockRepository.updateEloScores(any, any)).called(1);
    });
  });
}
