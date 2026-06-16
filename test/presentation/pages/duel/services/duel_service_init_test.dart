import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/data/providers/list_prioritization_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/controllers/duel_controller.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';

void main() {
  group('DuelService.ensureListsLoaded — correction race condition FutureProviders', () {
    test(
      'T1 : initialize reste isLoading=true tant que listsInitializationManagerProvider est en attente',
      () async {
        final initCompleter = Completer<IListsInitializationManager>();

        final container = ProviderContainer(overrides: [
          listsInitializationManagerProvider.overrideWith((_) => initCompleter.future),
          listsPersistenceManagerProvider.overrideWith((_) async => _EmptyPersistenceManager()),
          duelSettingsStorageProvider.overrideWithValue(_InMemoryDuelSettingsStorage()),
          listPrioritizationSettingsStorageProvider.overrideWithValue(_InMemoryListSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _FakeTaskRepository(_buildTasks(3))),
        ]);
        addTearDown(container.dispose);

        // Lance initialize sans await — la coroutine est suspendue sur Future.wait
        final future = container.read(duelControllerProvider.notifier).initialize();

        // Laisse un microtask passer pour que initialize() atteigne Future.wait
        await Future.delayed(Duration.zero);

        // Le FutureProvider n'est pas encore résolu → isLoading doit rester true
        expect(
          container.read(duelControllerProvider).isLoading,
          isTrue,
          reason: 'initialize() doit rester bloqué tant que listsInitializationManagerProvider est pending',
        );

        // Résout le FutureProvider
        initCompleter.complete(_FakeInitManager());

        // Attend la complétion réelle de initialize() — déterministe, sans délai arbitraire
        await future;

        // Après résolution, isLoading doit être false
        expect(
          container.read(duelControllerProvider).isLoading,
          isFalse,
          reason: 'initialize() doit se terminer après résolution des FutureProviders',
        );
      },
    );

    test(
      'T2 : initialize charge un duel valide une fois les FutureProviders résolus (pas de race condition)',
      () async {
        final initCompleter = Completer<IListsInitializationManager>();

        final container = ProviderContainer(overrides: [
          listsInitializationManagerProvider.overrideWith((_) => initCompleter.future),
          listsPersistenceManagerProvider.overrideWith((_) async => _EmptyPersistenceManager()),
          duelSettingsStorageProvider.overrideWithValue(_InMemoryDuelSettingsStorage()),
          listPrioritizationSettingsStorageProvider.overrideWithValue(_InMemoryListSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _FakeTaskRepository(_buildTasks(3))),
        ]);
        addTearDown(container.dispose);

        final future = container.read(duelControllerProvider.notifier).initialize();

        // Simule un léger délai asynchrone puis résout le provider
        await Future.delayed(const Duration(milliseconds: 20));
        initCompleter.complete(_FakeInitManager());

        await future;

        final state = container.read(duelControllerProvider);
        expect(state.isLoading, isFalse);
        expect(
          state.errorMessage,
          isNull,
          reason: 'Aucune race condition : errorMessage doit être null si des tâches existent',
        );
        expect(
          state.currentDuel,
          isNotNull,
          reason: 'Un duel doit être chargé au premier appel sans rafraîchissement',
        );
        expect(state.currentDuel!.length, greaterThanOrEqualTo(2));
      },
    );

    test(
      'T3 : initialize set errorMessage si listsInitializationManagerProvider échoue',
      () async {
        final container = ProviderContainer(overrides: [
          listsInitializationManagerProvider.overrideWith(
            (_) async => throw Exception('Init error simulé'),
          ),
          listsPersistenceManagerProvider.overrideWith((_) async => _EmptyPersistenceManager()),
          duelSettingsStorageProvider.overrideWithValue(_InMemoryDuelSettingsStorage()),
          listPrioritizationSettingsStorageProvider.overrideWithValue(_InMemoryListSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _FakeTaskRepository([])),
        ]);
        addTearDown(container.dispose);

        await container.read(duelControllerProvider.notifier).initialize();

        final state = container.read(duelControllerProvider);
        expect(state.isLoading, isFalse);
        expect(
          state.errorMessage,
          isNotNull,
          reason: "L'exception du FutureProvider doit être propagée dans errorMessage",
        );
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeInitManager implements IListsInitializationManager {
  @override
  Future<void> initializeAdaptive() async {}

  @override
  Future<void> initializeLegacy() async {}

  @override
  Future<void> initializeAsync() async {}

  @override
  bool get isInitialized => true;

  @override
  String get initializationMode => 'fake';
}

class _EmptyPersistenceManager implements IListsPersistenceManager {
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
  Future<void> saveMultipleItems(
    List<ListItem> items, {
    void Function(int, int)? onProgress,
  }) async {}

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

class _InMemoryDuelSettingsStorage implements DuelSettingsStorage {
  @override
  Future<DuelSettings?> load() async => null;

  @override
  Future<void> save(DuelSettings settings) async {}
}

class _InMemoryListSettingsStorage implements ListPrioritizationSettingsStorage {
  @override
  Future<ListPrioritizationSettings?> load() async => null;

  @override
  Future<void> save(ListPrioritizationSettings settings) async {}
}

class _FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks;

  _FakeTaskRepository(this._tasks);

  @override
  Future<List<Task>> getAllTasks() async => List.of(_tasks);

  @override
  Future<List<Task>> getActiveTasks() async =>
      _tasks.where((t) => !t.isCompleted).toList();

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<Task>> getCompletedTasks() async =>
      _tasks.where((t) => t.isCompleted).toList();

  @override
  Future<List<Task>> getTasksByCategory(String cat) async => [];

  @override
  Future<void> clearAllTasks() async => _tasks.clear();

  @override
  Future<void> updateEloScores(Task winner, Task loser) async {}

  @override
  Future<List<Task>> getRandomTasksForDuel() async => List.of(_tasks);
}

List<Task> _buildTasks(int n) => List.generate(
      n,
      (i) => Task(
        id: 'task-$i',
        title: 'Tâche $i',
        eloScore: 1200 + i * 10,
        createdAt: DateTime(2024, 1, 1),
      ),
    );
