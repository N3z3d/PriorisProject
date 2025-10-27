import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/controllers/duel_controller.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';

void main() {
  group('DuelController - paramètres de duel', () {
    late ProviderContainer container;
    late _RecordingDuelService duelService;
    late _InMemoryDuelSettingsStorage storage;

    setUp(() {
      duelService = _RecordingDuelService();
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

    tearDown(() => container.dispose());

    test('initialise un duel avec le nombre de cartes persisté', () async {
      storage.stored = const DuelSettings(
        mode: DuelMode.winner,
        cardsPerRound: 3,
        hideEloScores: true,
      );
      duelService.stubbedTasks = _buildTasks(4);

      final notifier = container.read(duelControllerProvider.notifier);
      await notifier.initialize();

      final state = container.read(duelControllerProvider);
      expect(state.currentDuel, isNotNull);
      expect(state.currentDuel, hasLength(3));
      expect(duelService.lastRequestedCount, 3);
    });

    test('updateCardsPerRound persiste et recharge le duel', () async {
      duelService.stubbedTasks = _buildTasks(4);
      final notifier = container.read(duelControllerProvider.notifier);
      await notifier.initialize();

      await notifier.updateMode(DuelMode.ranking);
      await notifier.updateCardsPerRound(4);

      final state = container.read(duelControllerProvider);
      expect(state.settings.cardsPerRound, 4);
      expect(duelService.lastRequestedCount, 4);
      expect(storage.lastSaved?.cardsPerRound, 4);
    });

    test('toggleEloVisibility met à jour le stockage', () async {
      final notifier = container.read(duelControllerProvider.notifier);
      await notifier.initialize();

      await notifier.toggleEloVisibility();

      final state = container.read(duelControllerProvider);
      expect(state.settings.hideEloScores, isFalse);
      expect(storage.lastSaved?.hideEloScores, isFalse);
    });

    test('updateMode change le mode de duel et le persiste', () async {
      final notifier = container.read(duelControllerProvider.notifier);
      await notifier.initialize();

      await notifier.updateMode(DuelMode.ranking);

      final state = container.read(duelControllerProvider);
      expect(state.settings.mode, DuelMode.ranking);
      expect(storage.lastSaved?.mode, DuelMode.ranking);
    });
  });
}

class _RecordingDuelService implements DuelFlowService {
  List<Task> stubbedTasks = const [];
  int lastRequestedCount = 0;

  @override
  Future<void> ensureListsLoaded() async {}

  @override
  Future<List<Task>> loadDuelTasks({required int count}) async {
    lastRequestedCount = count;
    if (stubbedTasks.length < count) {
      return stubbedTasks;
    }
    return stubbedTasks.take(count).toList();
  }

  @override
  Future<void> processWinner(Task winner, Task loser) async {}

  @override
  Task selectRandom(List<Task> tasks) {
    return tasks.first;
  }

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<List<Task>> loadAllTasksForRandomSelection() async => stubbedTasks;

  @override
  Future<void> processRanking(List<Task> orderedTasks) async {}
}

class _InMemoryDuelSettingsStorage implements DuelSettingsStorage {
  DuelSettings? stored;
  DuelSettings? lastSaved;

  @override
  Future<DuelSettings?> load() async => stored;

  @override
  Future<void> save(DuelSettings settings) async {
    stored = settings;
    lastSaved = settings;
  }
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
