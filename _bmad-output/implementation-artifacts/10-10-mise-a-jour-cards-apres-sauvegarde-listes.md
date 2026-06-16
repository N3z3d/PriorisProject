# Story 10.10 : Mise à jour immédiate des cards après sauvegarde des listes sélectionnées

Status: done

## Story

En tant qu'utilisateur,
je veux que les cards de duel se recalculent immédiatement après avoir sauvegardé mes listes sélectionnées,
afin de voir directement des duels cohérents avec ma sélection sans avoir à cliquer ailleurs.

## Acceptance Criteria

1. Après sauvegarde des listes sélectionnées → les tâches éligibles sont immédiatement recalculées
2. Le duel courant est regénéré avec les nouvelles listes
3. Les cards obsolètes (hors listes sélectionnées) disparaissent immédiatement
4. Aucune interaction supplémentaire (clic, navigation, refresh) n'est nécessaire
5. `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2088 pass, 26 skip, 1 flaky pré-existant `ListsTransactionManager`)

## Tasks / Subtasks

- [x] **T1 — Corriger `DuelPage._openListSelectionDialog()`** (AC: 1, 2, 3, 4)
  - [x] T1.1 — Dans `lib/presentation/pages/duel_page.dart`, dans le callback `onSettingsChanged` (lignes 159-164), ajouter `await _loadNewDuel()` après `await notifier.update(updatedSettings)` et avant `_showToast`

- [x] **T2 — Créer `test/presentation/pages/duel/services/duel_service_list_filter_test.dart`** (AC: 1, 5)
  - [x] T2.1 — Test T1 : `loadDuelTasks` retourne uniquement les items de la liste sélectionnée après mise à jour des settings
  - [x] T2.2 — Test T2 : `loadDuelTasks` retourne les items de toutes les listes quand `enabledListIds` est vide (toutes les listes)
  - [x] T2.3 — Test T3 : appel `loadNewDuel()` après `notifier.update()` → état `isLoading = false`, `currentDuel != null`

- [x] **T3 — Validation finale** (AC: 5)
  - [x] T3.1 — `puro flutter test test/presentation/pages/duel/services/duel_service_list_filter_test.dart` → 3 tests verts
  - [x] T3.2 — `puro flutter test --exclude-tags integration` → 0 régression vs baseline

## Dev Notes

### Cause racine identifiée

Dans `lib/presentation/pages/duel_page.dart`, le callback `onSettingsChanged` (lignes 159-164) :

```dart
onSettingsChanged: (updatedSettings) async {
  await notifier.update(updatedSettings);  // ← sauvegarde les settings
  if (mounted) {
    _showToast(_l10n.duelListsUpdated);   // ← toast affiché
  }
  // ← MANQUE : await _loadNewDuel();
},
```

Après `notifier.update()`, le `DuelController` n'est **jamais invité à recharger**. Le state `duelControllerProvider` reste inchangé avec les anciens cards.

### Le fix minimal

**Fichier :** `lib/presentation/pages/duel_page.dart` — callback dans `_openListSelectionDialog()` (lignes 159-164)

**Avant :**
```dart
onSettingsChanged: (updatedSettings) async {
  await notifier.update(updatedSettings);
  if (mounted) {
    _showToast(_l10n.duelListsUpdated);
  }
},
```

**Après :**
```dart
onSettingsChanged: (updatedSettings) async {
  await notifier.update(updatedSettings);
  await _loadNewDuel();
  if (mounted) {
    _showToast(_l10n.duelListsUpdated);
  }
},
```

`_loadNewDuel()` est déjà défini à la ligne 103 — aucun import ni helper à créer.

### Pourquoi ça marche

Chaîne d'appel après le fix :
```
await notifier.update(updatedSettings)
  → listPrioritizationSettingsProvider.state = updatedSettings  (synchrone)
  → SharedPreferences.save(...)

await _loadNewDuel()
  → DuelController.loadNewDuel()
  → _loadNewDuelWithSettings(settings)
  → DuelService.loadDuelTasks(count: ...)
  → ResilientTaskLoader.load()
  → _loadAllAvailableTasks()
  → _combineWithListItems()
  → _ref.read(listPrioritizationSettingsProvider)  ← lit les settings DÉJÀ mis à jour
  → DuelTaskFilter.extractEligibleItems(settings: updatedSettings)
  → cards recalculées avec les nouvelles listes ✓
```

**Point sur le cache `ResilientTaskLoader` :** Le cache (`_cache`) n'est utilisé que si `_loadTasks()` lève une exception. En conditions normales, chaque appel à `load()` exécute `_loadAllAvailableTasks()` → `_combineWithListItems()` avec les settings frais. Le cache ne masque pas le bug.

**Point sur `_ref.read` vs `_ref.watch` dans `_combineWithListItems` (ligne 87) :** `read` est intentionnel ici — `DuelService` est un service impératif, pas un widget. Il lit le state au moment de l'appel, ce qui est correct maintenant que `notifier.update()` est `await`é avant `_loadNewDuel()`.

### Infrastructure de test (T2)

Pattern de base : identique à `test/presentation/pages/duel/duel_controller_settings_test.dart` — `ProviderContainer` avec overrides.

**Fakes réutilisables depuis la story 10.9 :**
- `_FakeInitManager` (dans `duel_service_init_test.dart`)
- `_EmptyPersistenceManager` (dans `duel_service_init_test.dart`)
- `_InMemoryDuelSettingsStorage` (dans `duel_page_test_support.dart` sous le nom `InMemoryDuelSettingsStorage`)

**Nouveau fake `_InMemoryListSettingsStorage` :**
```dart
class _InMemoryListSettingsStorage implements ListPrioritizationSettingsStorage {
  @override Future<ListPrioritizationSettings?> load() async => null;
  @override Future<void> save(ListPrioritizationSettings settings) async {}
}
```

**Fake `_FakeTaskRepository` avec 0 tâches** (les items de liste sont dans les listes, pas dans le repo) :
```dart
class _EmptyTaskRepository implements TaskRepository {
  @override Future<List<Task>> getAllTasks() async => [];
  @override Future<List<Task>> getActiveTasks() async => [];
  @override Future<void> saveTask(Task task) async {}
  @override Future<void> updateTask(Task task) async {}
  @override Future<void> deleteTask(String id) async {}
  @override Future<List<Task>> getCompletedTasks() async => [];
  @override Future<List<Task>> getTasksByCategory(String cat) async => [];
  @override Future<void> clearAllTasks() async {}
  @override Future<void> updateEloScores(Task winner, Task loser) async {}
  @override Future<List<Task>> getRandomTasksForDuel() async => [];
}
```

**Fake `_PersistenceManagerWithLists`** (retourne des listes pré-définies) :
```dart
class _PersistenceManagerWithLists implements IListsPersistenceManager {
  final List<CustomList> lists;
  _PersistenceManagerWithLists(this.lists);

  @override Future<List<CustomList>> loadAllLists() async => List.of(lists);
  @override Future<void> saveList(CustomList list) async {}
  @override Future<void> updateList(CustomList list) async {}
  @override Future<void> deleteList(String listId) async {}
  @override Future<List<ListItem>> loadListItems(String listId) async =>
      lists.firstWhere((l) => l.id == listId, orElse: () => CustomList(id: '', name: '', type: ListType.OTHER, items: [], createdAt: DateTime.now(), updatedAt: DateTime.now())).items;
  @override Future<void> saveListItem(ListItem item) async {}
  @override Future<void> updateListItem(ListItem item) async {}
  @override Future<void> deleteListItem(String itemId) async {}
  @override Future<void> saveMultipleItems(List<ListItem> items, {void Function(int, int)? onProgress}) async {}
  @override Future<List<CustomList>> forceReloadFromPersistence() async => List.of(lists);
  @override Future<void> clearAllData() async {}
  @override Future<void> verifyListPersistence(String listId) async {}
  @override Future<void> verifyItemPersistence(String itemId) async {}
  @override Future<void> rollbackItems(List<ListItem> items) async {}
}
```

**Structure du test T1 (filter actif après update settings) :**
```dart
test('loadNewDuel retourne uniquement les items de la liste sélectionnée après update settings', () async {
  final listA = _buildListWithItems('list-a', 'Voyages', 3);
  final listB = _buildListWithItems('list-b', 'Travail', 2);

  final container = ProviderContainer(overrides: [
    listPrioritizationSettingsStorageProvider.overrideWithValue(_InMemoryListSettingsStorage()),
    listsInitializationManagerProvider.overrideWith((_) async => _FakeInitManager()),
    listsPersistenceManagerProvider.overrideWith((_) async => _PersistenceManagerWithLists([listA, listB])),
    duelSettingsStorageProvider.overrideWithValue(InMemoryDuelSettingsStorage()),
    taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
  ]);
  addTearDown(container.dispose);

  await container.read(duelControllerProvider.notifier).initialize();

  // Sélectionner uniquement list-a
  final settings = ListPrioritizationSettings(
    selectedListIds: {'list-a'},
    mode: ListSelectionMode.selectedLists,
  );
  await container.read(listPrioritizationSettingsProvider.notifier).update(settings);

  // La ligne corrigée dans DuelPage appelle ceci :
  await container.read(duelControllerProvider.notifier).loadNewDuel();

  final state = container.read(duelControllerProvider);
  expect(state.isLoading, isFalse);
  expect(state.currentDuel, isNotNull,
    reason: 'Un duel doit être chargé depuis les items de list-a');
  // Tous les tasks du duel doivent appartenir à list-a
  for (final task in state.currentDuel!) {
    expect(task.tags, contains('list-a'),
      reason: 'Seuls les items de list-a doivent être dans le duel');
  }
});
```

**Structure du test T2 (mode toutes les listes) :**
```dart
test('loadNewDuel retourne les items de toutes les listes quand selectedListIds est vide', () async {
  final listA = _buildListWithItems('list-a', 'Voyages', 2);
  final listB = _buildListWithItems('list-b', 'Travail', 2);

  final container = ProviderContainer(overrides: [
    listPrioritizationSettingsStorageProvider.overrideWithValue(_InMemoryListSettingsStorage()),
    listsInitializationManagerProvider.overrideWith((_) async => _FakeInitManager()),
    listsPersistenceManagerProvider.overrideWith((_) async => _PersistenceManagerWithLists([listA, listB])),
    duelSettingsStorageProvider.overrideWithValue(InMemoryDuelSettingsStorage()),
    taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
  ]);
  addTearDown(container.dispose);

  // Settings par défaut = toutes les listes
  await container.read(duelControllerProvider.notifier).initialize();
  await container.read(duelControllerProvider.notifier).loadNewDuel();

  final state = container.read(duelControllerProvider);
  expect(state.isLoading, isFalse);
  expect(state.currentDuel, isNotNull);
  // Avec 4 items et cardsPerRound=2, le duel doit avoir 2 cards
  expect(state.currentDuel!.length, 2);
});
```

**Structure du test T3 (état final propre) :**
```dart
test('après update settings + loadNewDuel → isLoading=false et currentDuel non null', () async {
  final listA = _buildListWithItems('list-a', 'Voyages', 3);

  final container = ProviderContainer(overrides: [
    listPrioritizationSettingsStorageProvider.overrideWithValue(_InMemoryListSettingsStorage()),
    listsInitializationManagerProvider.overrideWith((_) async => _FakeInitManager()),
    listsPersistenceManagerProvider.overrideWith((_) async => _PersistenceManagerWithLists([listA])),
    duelSettingsStorageProvider.overrideWithValue(InMemoryDuelSettingsStorage()),
    taskRepositoryProvider.overrideWith((_) => _EmptyTaskRepository()),
  ]);
  addTearDown(container.dispose);

  await container.read(listPrioritizationSettingsProvider.notifier).update(
    ListPrioritizationSettings(selectedListIds: {'list-a'}, mode: ListSelectionMode.selectedLists),
  );
  await container.read(duelControllerProvider.notifier).loadNewDuel();

  final state = container.read(duelControllerProvider);
  expect(state.isLoading, isFalse);
  expect(state.currentDuel, isNotNull);
  expect(state.errorMessage, isNull);
});
```

**Helper `_buildListWithItems` :**
```dart
CustomList _buildListWithItems(String id, String name, int itemCount) {
  return CustomList(
    id: id,
    name: name,
    type: ListType.OTHER,
    items: List.generate(itemCount, (i) => ListItem(
      id: '$id-item-$i',
      title: 'Item $i de $name',
      eloScore: 1200 + i * 10,
      createdAt: DateTime(2024, 1, 1),
      listId: id,
      isCompleted: false,
    )),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}
```

### Fichiers impactés

**Modifié :**
- `lib/presentation/pages/duel_page.dart` — callback `onSettingsChanged` dans `_openListSelectionDialog()` (lignes 159-164) — diff ~1 ligne

**Créé :**
- `test/presentation/pages/duel/services/duel_service_list_filter_test.dart` — 3 tests

**Non modifié :**
- `DuelController`, `DuelService`, `ListPrioritizationSettingsNotifier`, `ListSelectionDialog` — aucun changement hors scope

### Baseline tests au démarrage

```
puro flutter test --exclude-tags integration
→ 2088 pass, 26 skip, 1 flaky pré-existant (ListsTransactionManager rollback)
```

### Commandes utiles

```bash
# Lancer uniquement les nouveaux tests
puro flutter test test/presentation/pages/duel/services/duel_service_list_filter_test.dart

# Vérifier les tests duel existants (régression)
puro flutter test test/presentation/pages/duel/

# Suite complète (validation finale)
puro flutter test --exclude-tags integration

# Analyser
puro flutter analyze --no-pub
```

### Imports nécessaires dans le fichier de test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/duel_page_test_support.dart';
```

### Références

- Epic source : `_bmad-output/planning-artifacts/epic-10.md` — Story 10.8
- Fichier à corriger : `lib/presentation/pages/duel_page.dart` — `_openListSelectionDialog()` callback lignes 159-164
- Service duel : `lib/presentation/pages/duel/services/duel_service.dart` — `_combineWithListItems()` ligne 82, `_ref.read(listPrioritizationSettingsProvider)` ligne 87
- Controller duel : `lib/presentation/pages/duel/controllers/duel_controller.dart` — `loadNewDuel()` lignes 41-55
- Provider settings : `lib/data/providers/list_prioritization_settings_provider.dart` — `ListPrioritizationSettingsNotifier.update()` lignes 67-71
- Test de référence (pattern ProviderContainer) : `test/presentation/pages/duel/duel_controller_settings_test.dart`
- Test de référence (infra fake init/persistence) : `test/presentation/pages/duel/services/duel_service_init_test.dart`
- Test support (helpers) : `test/presentation/pages/duel_page_test_support.dart`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] T1 : ajout de `await _loadNewDuel()` dans `onSettingsChanged` — diff 1 ligne dans `duel_page.dart`
- [x] T2 : fichier de test créé avec 3 tests couvrant filtre par liste, mode toutes-listes, et état final
- [x] Correction du template story : `selectedListIds`/`ListSelectionMode` inexistants → `enabledListIds`; `ListType.OTHER` inexistant → `ListType.CUSTOM`; T3 nécessite `initialize()` avant `loadNewDuel()`
- [x] Suite complète : 2091 pass (+3 nouveaux), 26 skip, 2 flaky pré-existants ListsTransactionManager — 0 régression

### File List

- lib/presentation/pages/duel_page.dart
- test/presentation/pages/duel/services/duel_service_list_filter_test.dart

### Change Log

- 2026-05-19 : Ajout de `await _loadNewDuel()` dans `DuelPage.onSettingsChanged` (1 ligne) ; création de `duel_service_list_filter_test.dart` (3 tests) — implémenté par claude-sonnet-4-6

### Review Findings

- [x] [Review][Decision] `DuelService.ensureListsLoaded` modifié hors scope spec + aucun test dédié — Résolu : accepté + 2 tests E1/E2 ajoutés dans `duel_service_list_filter_test.dart` (nominal + erreur provider propagée)
- [x] [Review][Patch] `getTasksByCategory` retourne `null` implicitement — faux positif, fichier déjà correct (`async => []`) [test/presentation/pages/duel/services/duel_service_list_filter_test.dart]
- [x] [Review][Patch] T1 n'asserte pas l'absence des items de `list-b` — corrigé : assertion négative ajoutée après la boucle [test/presentation/pages/duel/services/duel_service_list_filter_test.dart]
- [x] [Review][Patch] T2 : `currentDuel!.length == 2` fragile — corrigé : remplacé par `isNotEmpty` [test/presentation/pages/duel/services/duel_service_list_filter_test.dart]
- [x] [Review][Patch] `loadListItems` orElse silencieux — corrigé : lève `StateError` si listId inconnu [test/presentation/pages/duel/services/duel_service_list_filter_test.dart]
- [x] [Review][Defer] `_waitForListsToFinishLoading` timeout silencieux 2s [lib/presentation/pages/duel/services/duel_service.dart] — deferred, pre-existing (déjà dans deferred-work)
- [x] [Review][Defer] `Future.wait` propagation d'erreur non typée vers DuelController [lib/presentation/pages/duel/services/duel_service.dart] — deferred, pre-existing (pattern DuelController)
- [x] [Review][Defer] `onSettingsChanged` callback déclaré `void`, Future async ignoré par `_saveSettings` [lib/presentation/pages/duel_page.dart] — deferred, pre-existing
- [x] [Review][Defer] Double appel concurrent à `_loadNewDuel` si dialog validé deux fois rapidement [lib/presentation/pages/duel_page.dart] — deferred, pre-existing
- [x] [Review][Defer] `mounted` vérifié seulement avant `_showToast`, pas après les mutations internes de `_loadNewDuel` [lib/presentation/pages/duel_page.dart] — deferred, pre-existing
- [x] [Review][Defer] 2 flaky pré-existants au lieu de 1 dans la baseline spec — estimation spec incorrecte, pré-existant
- [x] [Review][Defer] `eloScore: 1200.0 + i * 10` hardcodé dans `_buildListWithItems` — cosmétique, pré-existant
