import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_validation_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/refactored/lists_controller_slim.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_filter_manager.dart';
import 'package:prioris/presentation/pages/lists/services/list_item_sync_service.dart';
import 'package:prioris/presentation/pages/lists/services/lists_performance_monitor.dart';

// ─── Infrastructure de test ───────────────────────────────────────────────────

class _NullLogger implements ILogger {
  @override
  void debug(String m, {String? context, String? correlationId, dynamic data}) {}
  @override
  void info(String m, {String? context, String? correlationId, dynamic data}) {}
  @override
  void warning(String m, {String? context, String? correlationId, dynamic data}) {}
  @override
  void error(String m,
      {String? context,
      String? correlationId,
      dynamic error,
      StackTrace? stackTrace}) {}
  @override
  void fatal(String m,
      {String? context,
      String? correlationId,
      dynamic error,
      StackTrace? stackTrace}) {}
  @override
  void performance(String op, Duration d,
      {String? context,
      String? correlationId,
      Map<String, dynamic>? metrics}) {}
  @override
  void userAction(String a,
      {String? context,
      String? correlationId,
      Map<String, dynamic>? properties}) {}
}

class _DummyInitManager implements IListsInitializationManager {
  @override
  Future<void> initializeAdaptive() async {}
  @override
  Future<void> initializeLegacy() async {}
  @override
  Future<void> initializeAsync() async {}
  @override
  bool get isInitialized => true;
  @override
  String get initializationMode => 'dummy';
}

class _DummyPersistenceManager implements IListsPersistenceManager {
  @override
  Future<List<CustomList>> loadAllLists() async => [];
  @override
  Future<void> saveList(CustomList list) async {}
  @override
  Future<void> updateList(CustomList list) async {}
  @override
  Future<void> deleteList(String listId) async {}
  @override
  Future<List<ListItem>> loadListItems(String listId) async => [];
  @override
  Future<void> saveListItem(ListItem item) async {}
  @override
  Future<void> updateListItem(ListItem item) async {}
  @override
  Future<void> deleteListItem(String itemId) async {}
  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {}
  @override
  Future<List<CustomList>> forceReloadFromPersistence() async => [];
  @override
  Future<void> clearAllData() async {}
  @override
  Future<void> verifyListPersistence(String listId) async {}
  @override
  Future<void> verifyItemPersistence(String itemId) async {}
  @override
  Future<void> rollbackItems(List<ListItem> items) async {}
}

/// Enregistre chaque appel à [updateListItem] sans toucher à l'état Riverpod.
class _RecordingListsController extends ListsControllerSlim {
  final List<({String listId, ListItem item})> calls = [];

  _RecordingListsController()
      : super(
          initializationManager: _DummyInitManager(),
          performanceMonitor: ListsPerformanceMonitor(),
          crudOperations: ListsCrudOperations(
            persistence: _DummyPersistenceManager(),
            validator: ListsValidationService(),
            filterManager: ListsFilterManager(),
            stateManager: const ListsStateManager(),
            logger: _NullLogger(),
          ),
          stateManager: const ListsStateManager(),
          syncService: ListItemSyncService(const ListsStateManager()),
          logger: _NullLogger(),
        );

  @override
  Future<void> updateListItem(String listId, ListItem item) async {
    calls.add((listId: listId, item: item));
  }
}

/// Fake service qui retourne un [DuelResult] contrôlé sans I/O.
class _FakeUnifiedPrioritizationService extends UnifiedPrioritizationService {
  DuelResult? _stubbedResult;

  _FakeUnifiedPrioritizationService()
      : super(
          taskRepository: InMemoryTaskRepository(),
          converter: ListItemTaskConverter(),
        );

  void stubResult(DuelResult result) => _stubbedResult = result;

  @override
  Future<DuelResult> updateEloScoresFromDuel(Task winner, Task loser) async {
    return _stubbedResult ?? DuelResult(winner: winner, loser: loser);
  }
}

// ─── Provider de test ────────────────────────────────────────────────────────

final _duelServiceTestProvider =
    Provider<DuelService>((ref) => DuelService(ref));

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('DuelService._persistEloToLists', () {
    late _RecordingListsController recordingController;
    late _FakeUnifiedPrioritizationService fakeUnified;
    late ProviderContainer container;

    setUp(() {
      recordingController = _RecordingListsController();
      fakeUnified = _FakeUnifiedPrioritizationService();

      container = ProviderContainer(
        overrides: [
          listsControllerProvider.overrideWith((_) => recordingController),
          unifiedPrioritizationServiceProvider
              .overrideWithValue(fakeUnified),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('appelle updateListItem pour chaque task list-backed (tags non vides)', () async {
      final winner = Task(id: 'w', title: 'Winner', eloScore: 1216.0, tags: ['list-abc']);
      final loser = Task(id: 'l', title: 'Loser', eloScore: 1184.0, tags: ['list-abc']);
      fakeUnified.stubResult(DuelResult(winner: winner, loser: loser));

      final service = container.read(_duelServiceTestProvider);
      await service.processWinner(winner, loser);

      expect(recordingController.calls, hasLength(2),
          reason: 'updateListItem doit être appelé pour winner ET loser');
      expect(recordingController.calls.map((c) => c.listId).toSet(),
          equals({'list-abc'}));
    });

    test('ne appelle PAS updateListItem pour les tasks classiques (tags vides)', () async {
      final winner = Task(id: 'w', title: 'Classic W', eloScore: 1216.0, tags: []);
      final loser = Task(id: 'l', title: 'Classic L', eloScore: 1184.0, tags: []);
      fakeUnified.stubResult(DuelResult(winner: winner, loser: loser));

      final service = container.read(_duelServiceTestProvider);
      await service.processWinner(winner, loser);

      expect(recordingController.calls, isEmpty,
          reason: 'Les tâches sans tags ne doivent pas persister dans les listes Supabase');
    });

    test('appelle updateListItem uniquement pour la task list-backed (winner tags, loser classique)', () async {
      final winner = Task(id: 'w', title: 'W', eloScore: 1216.0, tags: ['list-xyz']);
      final loser = Task(id: 'l', title: 'L', eloScore: 1184.0, tags: []);
      fakeUnified.stubResult(DuelResult(winner: winner, loser: loser));

      final service = container.read(_duelServiceTestProvider);
      await service.processWinner(winner, loser);

      expect(recordingController.calls, hasLength(1));
      expect(recordingController.calls.first.listId, 'list-xyz');
    });

    test('le ListItem persisté contient le nouvel eloScore', () async {
      const listId = 'list-elo-check';
      final winner = Task(id: 'w', title: 'W', eloScore: 1216.0, tags: [listId]);
      fakeUnified.stubResult(
          DuelResult(winner: winner, loser: Task(id: 'l', title: 'L', eloScore: 1184.0, tags: [])));

      final service = container.read(_duelServiceTestProvider);
      await service.processWinner(winner, winner); // loser ignoré car stubResult forcé

      final savedItem = recordingController.calls
          .where((c) => c.item.id == winner.id)
          .firstOrNull;
      expect(savedItem, isNotNull);
      expect(savedItem!.item.eloScore, closeTo(1216.0, 0.001));
    });
  });
}
