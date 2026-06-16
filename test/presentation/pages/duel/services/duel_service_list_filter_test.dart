import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/data/providers/list_prioritization_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/duel/controllers/duel_controller.dart';
import '../../duel_page_test_support.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';

void main() {
  group('DuelService — ensureListsLoaded', () {
    test(
      'E1 : les deux FutureProviders résolvent → initialize() réussit sans erreur',
      () async {
        final listA = _buildListWithItems('list-a', 'Voyages', 2);

        final container = ProviderContainer(overrides: [
          listPrioritizationSettingsStorageProvider
              .overrideWithValue(_InMemoryListSettingsStorage()),
          listsInitializationManagerProvider
              .overrideWith((_) async => _FakeInitManager()),
          listsPersistenceManagerProvider
              .overrideWith((_) async => _PersistenceManagerWithLists([listA])),
          duelSettingsStorageProvider
              .overrideWithValue(const InMemoryDuelSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
        ]);
        addTearDown(container.dispose);

        await container.read(duelControllerProvider.notifier).initialize();

        final state = container.read(duelControllerProvider);
        expect(state.errorMessage, isNull,
            reason:
                'ensureListsLoaded doit compléter sans erreur quand les deux providers résolvent');
        expect(state.isLoading, isFalse);
      },
    );

    test(
      'E2 : listsInitializationManagerProvider échoue → erreur propagée dans DuelController',
      () async {
        final container = ProviderContainer(overrides: [
          listPrioritizationSettingsStorageProvider
              .overrideWithValue(_InMemoryListSettingsStorage()),
          listsInitializationManagerProvider
              .overrideWith((_) async => throw Exception('Provider indisponible')),
          listsPersistenceManagerProvider
              .overrideWith((_) async => _PersistenceManagerWithLists([])),
          duelSettingsStorageProvider
              .overrideWithValue(const InMemoryDuelSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
        ]);
        addTearDown(container.dispose);

        await container.read(duelControllerProvider.notifier).initialize();

        final state = container.read(duelControllerProvider);
        expect(state.errorMessage, isNotNull,
            reason:
                'Une exception dans ensureListsLoaded doit remonter dans errorMessage');
      },
    );
  });

  group('DuelService — filtrage par listes sélectionnées', () {
    test(
      'T1 : loadNewDuel retourne uniquement les items de la liste sélectionnée après update settings',
      () async {
        final listA = _buildListWithItems('list-a', 'Voyages', 3);
        final listB = _buildListWithItems('list-b', 'Travail', 2);

        final container = ProviderContainer(overrides: [
          listPrioritizationSettingsStorageProvider
              .overrideWithValue(_InMemoryListSettingsStorage()),
          listsInitializationManagerProvider
              .overrideWith((_) async => _FakeInitManager()),
          listsPersistenceManagerProvider.overrideWith(
              (_) async => _PersistenceManagerWithLists([listA, listB])),
          duelSettingsStorageProvider
              .overrideWithValue(const InMemoryDuelSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
        ]);
        addTearDown(container.dispose);

        await container.read(duelControllerProvider.notifier).initialize();

        // Sélectionner uniquement list-a
        await container
            .read(listPrioritizationSettingsProvider.notifier)
            .update(ListPrioritizationSettings(enabledListIds: {'list-a'}));

        // La ligne corrigée dans DuelPage appelle ceci :
        await container.read(duelControllerProvider.notifier).loadNewDuel();

        final state = container.read(duelControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.currentDuel, isNotNull,
            reason: 'Un duel doit être chargé depuis les items de list-a');
        for (final task in state.currentDuel!) {
          expect(task.tags, contains('list-a'),
              reason: 'Seuls les items de list-a doivent être dans le duel');
        }
        expect(
          state.currentDuel!.any((task) => task.tags.contains('list-b')),
          isFalse,
          reason: 'Les items de list-b ne doivent pas apparaître après filtrage sur list-a',
        );
      },
    );

    test(
      'T2 : loadNewDuel retourne les items de toutes les listes quand enabledListIds est vide',
      () async {
        final listA = _buildListWithItems('list-a', 'Voyages', 2);
        final listB = _buildListWithItems('list-b', 'Travail', 2);

        final container = ProviderContainer(overrides: [
          listPrioritizationSettingsStorageProvider
              .overrideWithValue(_InMemoryListSettingsStorage()),
          listsInitializationManagerProvider
              .overrideWith((_) async => _FakeInitManager()),
          listsPersistenceManagerProvider.overrideWith(
              (_) async => _PersistenceManagerWithLists([listA, listB])),
          duelSettingsStorageProvider
              .overrideWithValue(const InMemoryDuelSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
        ]);
        addTearDown(container.dispose);

        // Settings par défaut : enabledListIds vide = toutes les listes
        await container.read(duelControllerProvider.notifier).initialize();
        await container.read(duelControllerProvider.notifier).loadNewDuel();

        final state = container.read(duelControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.currentDuel, isNotNull);
        // Avec enabledListIds vide, les items des deux listes sont éligibles
        expect(state.currentDuel!, isNotEmpty);
      },
    );

    test(
      'T3 : après update settings + loadNewDuel → isLoading=false et currentDuel non null',
      () async {
        final listA = _buildListWithItems('list-a', 'Voyages', 3);

        final container = ProviderContainer(overrides: [
          listPrioritizationSettingsStorageProvider
              .overrideWithValue(_InMemoryListSettingsStorage()),
          listsInitializationManagerProvider
              .overrideWith((_) async => _FakeInitManager()),
          listsPersistenceManagerProvider
              .overrideWith((_) async => _PersistenceManagerWithLists([listA])),
          duelSettingsStorageProvider
              .overrideWithValue(const InMemoryDuelSettingsStorage()),
          taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
        ]);
        addTearDown(container.dispose);

        // initialize() charge les listes dans listsControllerProvider
        await container.read(duelControllerProvider.notifier).initialize();

        await container
            .read(listPrioritizationSettingsProvider.notifier)
            .update(ListPrioritizationSettings(enabledListIds: {'list-a'}));
        await container.read(duelControllerProvider.notifier).loadNewDuel();

        final state = container.read(duelControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.currentDuel, isNotNull);
        expect(state.errorMessage, isNull);
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

class _InMemoryListSettingsStorage implements ListPrioritizationSettingsStorage {
  @override
  Future<ListPrioritizationSettings?> load() async => null;

  @override
  Future<void> save(ListPrioritizationSettings settings) async {}
}

class _EmptyTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getAllTasks() async => [];
  @override
  Future<List<Task>> getActiveTasks() async => [];
  @override
  Future<void> saveTask(Task task) async {}
  @override
  Future<void> updateTask(Task task) async {}
  @override
  Future<void> deleteTask(String id) async {}
  @override
  Future<List<Task>> getCompletedTasks() async => [];
  @override
  Future<List<Task>> getTasksByCategory(String cat) async => [];
  @override
  Future<void> clearAllTasks() async {}
  @override
  Future<void> updateEloScores(Task winner, Task loser) async {}
  @override
  Future<List<Task>> getRandomTasksForDuel() async => [];
}

class _PersistenceManagerWithLists implements IListsPersistenceManager {
  final List<CustomList> lists;
  _PersistenceManagerWithLists(this.lists);

  @override
  Future<List<CustomList>> loadAllLists() async => List.of(lists);

  @override
  Future<void> saveList(CustomList list) async {}

  @override
  Future<void> updateList(CustomList list) async {}

  @override
  Future<void> deleteList(String listId) async {}

  @override
  Future<List<ListItem>> loadListItems(String listId) async =>
      lists
          .firstWhere(
            (l) => l.id == listId,
            orElse: () => throw StateError(
                '_PersistenceManagerWithLists: listId "$listId" introuvable'),
          )
          .items;

  @override
  Future<void> saveListItem(ListItem item) async {}

  @override
  Future<void> updateListItem(ListItem item) async {}

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<void> saveMultipleItems(List<ListItem> items,
      {void Function(int, int)? onProgress}) async {}

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async => List.of(lists);

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> verifyListPersistence(String listId) async {}

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> rollbackItems(List<ListItem> items) async {}
}

CustomList _buildListWithItems(String id, String name, int itemCount) {
  return CustomList(
    id: id,
    name: name,
    type: ListType.CUSTOM,
    items: List.generate(
      itemCount,
      (i) => ListItem(
        id: '$id-item-$i',
        title: 'Item $i de $name',
        eloScore: 1200.0 + i * 10,
        createdAt: DateTime(2024, 1, 1),
        listId: id,
        isCompleted: false,
      ),
    ),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}
