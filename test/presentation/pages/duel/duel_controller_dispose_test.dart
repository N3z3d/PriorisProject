import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/controllers/duel_controller.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';

/// Story 10.18 — code review : le rebuild des providers de persistance (auth /
/// consentement) peut disposer le [DuelController] pendant un `await`. Toute
/// mutation d'état post-dispose lève `StateError: after dispose`. On exerce
/// `updateMode` (qui n'a pas de `catch` externe gardé pour absorber l'erreur)
/// afin de prouver que `_loadNewDuelWithSettings` garde ses DEUX branches.
void main() {
  group('DuelController - course de dispose (mounted guards)', () {
    late ProviderContainer container;
    late _CompleterDuelService duelService;
    late _InMemoryDuelSettingsStorage storage;

    setUp(() {
      duelService = _CompleterDuelService();
      storage = _InMemoryDuelSettingsStorage();
      container = ProviderContainer(
        overrides: [
          duelSettingsStorageProvider.overrideWithValue(storage),
          duelControllerProvider.overrideWith((ref) {
            return DuelController(ref, duelService: duelService);
          }),
        ],
      );
    });

    test('dispose pendant loadDuelTasks (échec) ne lève pas StateError', () async {
      final notifier = container.read(duelControllerProvider.notifier);

      final future = notifier.updateMode(DuelMode.ranking);
      // Laisser l'await immédiat (settings) se résoudre et atteindre
      // loadDuelTasks, resté en attente sur le completer.
      await Future<void>.delayed(Duration.zero);

      container.dispose(); // rebuild persistance → controller disposé
      duelService.completer.completeError(DuelLoadingException('boom'));

      // Branche `on DuelLoadingException` : doit être gardée par `mounted`.
      await expectLater(future, completes);
    });

    test('dispose pendant loadDuelTasks (succès) ne lève pas StateError', () async {
      final notifier = container.read(duelControllerProvider.notifier);

      final future = notifier.updateMode(DuelMode.ranking);
      await Future<void>.delayed(Duration.zero);

      container.dispose();
      duelService.completer.complete(_buildTasks(3));

      await expectLater(future, completes);
    });
  });
}

class _CompleterDuelService implements DuelFlowService {
  final Completer<List<Task>> completer = Completer<List<Task>>();

  @override
  Future<void> ensureListsLoaded() async {}

  @override
  Future<List<Task>> loadDuelTasks({required int count}) => completer.future;

  @override
  Future<void> processWinner(Task winner, Task loser) async {}

  @override
  Task selectRandom(List<Task> tasks) => tasks.first;

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<List<Task>> loadAllTasksForRandomSelection() async => const [];

  @override
  Future<void> processRanking(List<Task> orderedTasks) async {}
}

class _InMemoryDuelSettingsStorage implements DuelSettingsStorage {
  DuelSettings? stored;

  @override
  Future<DuelSettings?> load() async => stored;

  @override
  Future<void> save(DuelSettings settings) async => stored = settings;
}

List<Task> _buildTasks(int count) {
  return List.generate(
    count,
    (index) => Task(
      id: 'task-${index + 1}',
      title: 'Tache ${index + 1}',
      eloScore: 1200 + index * 10,
      createdAt: DateTime(2024, 1, 1),
    ),
  );
}
