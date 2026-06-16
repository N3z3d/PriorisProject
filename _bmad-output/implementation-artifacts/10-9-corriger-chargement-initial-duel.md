# Story 10.9 : Corriger le chargement initial du duel (fail au premier chargement)

Status: done

## Story

En tant qu'utilisateur,
je veux que la page Prioriser charge le duel directement sans afficher "Pas assez de tâches éligibles",
afin de ne pas avoir à rafraîchir pour commencer à prioriser.

## Acceptance Criteria

1. Si des tâches ou items de liste éligibles existent, le duel se charge directement au premier chargement — sans rafraîchissement manuel
2. L'état de chargement (spinner) est affiché pendant la récupération des données
3. Le message "Pas assez de tâches éligibles" n'apparaît que si aucune tâche éligible n'existe réellement (pas à cause d'une race condition)
4. `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2084 pass, 26 skip, 1 flaky pré-existant `ListsTransactionManager`)

## Tasks / Subtasks

- [x] **T1 — Corriger `DuelService.ensureListsLoaded()`** (AC: 1, 2, 3)
  - [x] T1.1 — Dans `lib/presentation/pages/duel/services/duel_service.dart`, modifier `ensureListsLoaded()` pour attendre la résolution de `listsInitializationManagerProvider.future` et `listsPersistenceManagerProvider.future` avant d'appeler `loadLists()`
  - [x] T1.2 — Utiliser `Future.wait([...])` pour les deux FutureProviders en parallèle
  - [x] T1.3 — Conserver l'appel `await _ref.read(listsControllerProvider.notifier).loadLists()` et `await _waitForListsToFinishLoading()` après le `Future.wait`

- [x] **T2 — Créer `test/presentation/pages/duel/services/duel_service_init_test.dart`** (AC: 1, 4)
  - [x] T2.1 — Test T1 : `initialize` reste en `isLoading=true` pendant que `listsInitializationManagerProvider` n'a pas résolu (vérifie le timing via Completer)
  - [x] T2.2 — Test T2 : `initialize` charge un duel valide une fois les FutureProviders résolus (sans erreur d'état liée à la race condition)
  - [x] T2.3 — Test T3 : `initialize` propage l'exception si `listsInitializationManagerProvider` échoue → `errorMessage` non null dans l'état

- [x] **T3 — Validation finale** (AC: 4)
  - [x] T3.1 — `puro flutter test test/presentation/pages/duel/services/duel_service_init_test.dart` → 3 tests verts
  - [x] T3.2 — `puro flutter test --exclude-tags integration` → 0 régression vs baseline 2084/26/1flaky

## Dev Notes

### Cause racine identifiée

`listsControllerProvider` est un `StateNotifierProvider` qui dépend (via `ref.watch`) de deux `FutureProvider`s :
- `listsInitializationManagerProvider`
- `listsPersistenceManagerProvider`

Quand ces FutureProviders ne sont **pas encore résolus**, `listsControllerProvider` crée un `_LoadingListsController` (dummy, `_DummyInitManager` + `_DummyPersistenceManager`, retourne des listes vides).

**Séquence problématique (avant fix) :**
```
T=0  : FutureProviders démarrent (async)
T=1  : addPostFrameCallback → DuelController.initialize() démarre
T=2  : ensureListsLoaded() → _ref.read(listsControllerProvider.notifier)
        ↳ retourne _LoadingListsController (FutureProviders pas encore résolus)
T=3  : loadLists() sur le dummy → aucune liste chargée, isLoading = false immédiatement
T=4  : _waitForListsToFinishLoading → !state.isLoading == true → sort immédiatement
T=5  : _combineWithListItems → lists vides → 0 tâches
T=6  : errorMessage = "Pas assez de taches eligibles" affiché ← bug
T=100: FutureProviders résolvent → vrai RefactoredListsController créé + _bootstrap() charge listes
        ← mais trop tard, le DuelController est déjà en état d'erreur
```

**Séquence correcte (après fix) :**
```
T=0  : FutureProviders démarrent
T=1  : initialize() → ensureListsLoaded()
T=2  : await Future.wait([initFuture, persistenceFuture])
        ↳ BLOQUE jusqu'à résolution des deux FutureProviders
T=100: FutureProviders résolvent → vrai RefactoredListsController créé + _bootstrap() démarre
T=101: Future.wait se débloque → loadLists() appelé sur le vrai controller
T=102: listes chargées → _combineWithListItems trouve des tâches → duel OK
```

**Pourquoi ça marche après "Réessayer" (sans fix) :**
Quand l'utilisateur tape "Réessayer", `loadNewDuel()` est appelé. À ce moment-là, les FutureProviders ont eu le temps de résoudre, le vrai `RefactoredListsController` est créé et `_bootstrap()` a déjà chargé les vraies listes. `_combineWithListItems` lit ces listes → duel OK.

### Le fix minimal

**Fichier à modifier :** `lib/presentation/pages/duel/services/duel_service.dart` — méthode `ensureListsLoaded()` (lignes 44-49 actuellement)

**Avant (lignes 44-49) :**
```dart
@override
Future<void> ensureListsLoaded() async {
  await _ref.read(listsControllerProvider.notifier).loadLists();
  await _waitForListsToFinishLoading();
}
```

**Après :**
```dart
@override
Future<void> ensureListsLoaded() async {
  await Future.wait([
    _ref.read(listsInitializationManagerProvider.future),
    _ref.read(listsPersistenceManagerProvider.future),
  ]);
  await _ref.read(listsControllerProvider.notifier).loadLists();
  await _waitForListsToFinishLoading();
}
```

**Import à ajouter dans `duel_service.dart` :**
```dart
import 'package:prioris/data/providers/lists_controller_provider.dart';
```

`listsControllerProvider` est déjà importé depuis `lists_controller_provider.dart`. `listsInitializationManagerProvider` et `listsPersistenceManagerProvider` sont déclarés dans le même fichier — pas de nouvel import nécessaire.

**Vérification :** Confirmer que `listsInitializationManagerProvider` et `listsPersistenceManagerProvider` sont bien exportés (pas privés) dans `lists_controller_provider.dart`.

### Comportement de `_waitForListsToFinishLoading` après le fix

Quand `Future.wait` se débloque, le vrai `RefactoredListsController` est en train d'exécuter `_bootstrap()` (lancé dans son constructeur). `_bootstrap()` set `state.isLoading = true` synchroniquement avant tout `await`. Donc quand on appelle `loadLists()` puis `_waitForListsToFinishLoading`, `isLoading` est `true` → la boucle de polling attend correctement la fin de `_bootstrap()`.

### Infrastructure de test nécessaire (T2)

Pattern de base : identique à `test/presentation/pages/duel/duel_controller_settings_test.dart` — `ProviderContainer` avec overrides.

Pour contrôler le timing des FutureProviders dans les tests, utiliser un `Completer` :

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/data/providers/list_prioritization_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/controllers/duel_controller.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
```

**Fake minimal pour `IListsInitializationManager`** (aucune initialisation réelle) :
```dart
class _FakeInitManager implements IListsInitializationManager {
  @override Future<void> initializeAdaptive() async {}
  @override Future<void> initializeLegacy() async {}
  @override Future<void> initializeAsync() async {}
  @override bool get isInitialized => true;
  @override String get initializationMode => 'fake';
}
```

**Fake minimal pour `IListsPersistenceManager`** (listes vides — pas d'items Hive nécessaires) :
```dart
class _EmptyPersistenceManager implements IListsPersistenceManager {
  @override Future<List<CustomList>> loadAllLists() async => [];
  @override Future<void> saveList(CustomList list) async {}
  @override Future<void> updateList(CustomList list) async {}
  @override Future<void> deleteList(String listId) async {}
  @override Future<List<ListItem>> loadListItems(String listId) async => [];
  @override Future<void> saveListItem(ListItem item) async {}
  @override Future<void> updateListItem(ListItem item) async {}
  @override Future<void> deleteListItem(String itemId) async {}
  @override Future<void> saveMultipleItems(List<ListItem> items, {void Function(int, int)? onProgress}) async {}
  @override Future<List<CustomList>> forceReloadFromPersistence() async => [];
  @override Future<void> clearAllData() async {}
  @override Future<void> verifyListPersistence(String listId) async {}
  @override Future<void> verifyItemPersistence(String itemId) async {}
  @override Future<void> rollbackItems(List<ListItem> items) async {}
}
```

**Fakes settings storage** (éviter SharedPreferences dans les tests) :
```dart
class _InMemoryDuelSettingsStorage implements DuelSettingsStorage {
  @override Future<DuelSettings?> load() async => null;
  @override Future<void> save(DuelSettings settings) async {}
}

class _InMemoryListSettingsStorage implements ListPrioritizationSettingsStorage {
  @override Future<ListPrioritizationSettings?> load() async => null;
  @override Future<void> save(ListPrioritizationSettings settings) async {}
}
```

**Fake `TaskRepository`** avec 3 tâches pour T2 (assez pour un duel) :
```dart
class _FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks;
  _FakeTaskRepository(this._tasks);
  @override Future<List<Task>> getAllTasks() async => List.of(_tasks);
  @override Future<List<Task>> getActiveTasks() async => _tasks.where((t) => !t.isCompleted).toList();
  @override Future<void> saveTask(Task task) async => _tasks.add(task);
  @override Future<void> updateTask(Task task) async {}
  @override Future<void> deleteTask(String id) async {}
  @override Future<List<Task>> getCompletedTasks() async => _tasks.where((t) => t.isCompleted).toList();
  @override Future<List<Task>> getTasksByCategory(String cat) async => [];
  @override Future<void> clearAllTasks() async => _tasks.clear();
  @override Future<void> updateEloScores(Task winner, Task loser) async {}
  @override Future<List<Task>> getRandomTasksForDuel() async => List.of(_tasks);
}

List<Task> _buildTasks(int n) => List.generate(n, (i) => Task(
  id: 'task-$i', title: 'Tâche $i',
  eloScore: 1200 + i * 10,
  createdAt: DateTime(2024, 1, 1),
));
```

**Structure de test T1 (timing)** :
```dart
test('initialize reste en isLoading=true tant que listsInitializationManagerProvider est en attente', () async {
  final initCompleter = Completer<IListsInitializationManager>();

  final container = ProviderContainer(overrides: [
    listsInitializationManagerProvider.overrideWith((_) => initCompleter.future),
    listsPersistenceManagerProvider.overrideWith((_) async => _EmptyPersistenceManager()),
    duelSettingsStorageProvider.overrideWithValue(_InMemoryDuelSettingsStorage()),
    listPrioritizationSettingsStorageProvider.overrideWithValue(_InMemoryListSettingsStorage()),
    taskRepositoryProvider.overrideWith((_) => _FakeTaskRepository(_buildTasks(3))),
  ]);
  addTearDown(container.dispose);

  // Lance initialize sans await
  container.read(duelControllerProvider.notifier).initialize();

  // Laisse un microtask passer
  await Future.delayed(Duration.zero);

  // Vérifie que le duel est encore en chargement (FutureProvider pas résolu)
  expect(container.read(duelControllerProvider).isLoading, isTrue);

  // Résout le FutureProvider
  initCompleter.complete(_FakeInitManager());

  // Attend que initialize() se termine
  await Future.delayed(const Duration(milliseconds: 200));

  // Vérifie que l'état est sorti du chargement
  expect(container.read(duelControllerProvider).isLoading, isFalse);
});
```

**Structure de test T2 (pas d'erreur race condition)** :
```dart
test('initialize charge un duel valide une fois les FutureProviders résolus', () async {
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
  
  // Résout après un délai simulé
  await Future.delayed(const Duration(milliseconds: 20));
  initCompleter.complete(_FakeInitManager());
  
  await future;
  
  final state = container.read(duelControllerProvider);
  expect(state.isLoading, isFalse);
  expect(state.currentDuel, isNotNull,
    reason: 'Un duel doit être chargé si des tâches existent — pas de race condition');
  expect(state.currentDuel!.length, greaterThanOrEqualTo(2));
});
```

**Structure de test T3 (erreur propagée)** :
```dart
test('initialize set errorMessage si listsInitializationManagerProvider échoue', () async {
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
  expect(state.errorMessage, isNotNull);
});
```

### Point d'attention : `loadLists()` et `_bootstrap()` en parallèle

Quand `Future.wait` se débloque, le vrai `RefactoredListsController` est peut-être en train d'exécuter `_bootstrap()` qui appelle déjà `loadLists()` en interne. L'appel explicite à `loadLists()` dans `ensureListsLoaded()` peut donc être le deuxième appel. C'est acceptable — le résultat est idempotent (les listes sont chargées depuis la même source).

Si `loadLists()` a un guard sur `_isInitialized` qui empêche un double appel pendant `_bootstrap()`, le comportement est toujours correct : `_waitForListsToFinishLoading()` attendra que `_bootstrap()` finisse.

### Fichiers impactés

**Modifié :**
- `lib/presentation/pages/duel/services/duel_service.dart` — méthode `ensureListsLoaded()` uniquement (diff ~3 lignes)

**Créé :**
- `test/presentation/pages/duel/services/duel_service_init_test.dart` — 3 tests de régression

**Non modifié :**
- `DuelController`, `DuelPage`, `ListsControllerSlim`, `_LoadingListsController` — aucun changement hors scope

### Baseline tests au démarrage

```
puro flutter test --exclude-tags integration
→ 2084 pass, 26 skip, 1 flaky pré-existant (ListsTransactionManager rollback)
```

### Commandes utiles

```bash
# Lancer uniquement les nouveaux tests
puro flutter test test/presentation/pages/duel/services/duel_service_init_test.dart

# Vérifier les tests duel existants (régression)
puro flutter test test/presentation/pages/duel/

# Suite complète (validation finale)
puro flutter test --exclude-tags integration

# Analyser
puro flutter analyze --no-pub
```

### References

- Epic source : `_bmad-output/planning-artifacts/epic-10.md` — Story 10.7 (correspondance sprint-key 10-9)
- Fichier à corriger : `lib/presentation/pages/duel/services/duel_service.dart` — `ensureListsLoaded()` lignes 44-49
- Controller du duel : `lib/presentation/pages/duel/controllers/duel_controller.dart` — `initialize()` lignes 22-38
- Page du duel : `lib/presentation/pages/duel_page.dart` — `initState` addPostFrameCallback ligne 31
- Providers listes : `lib/data/providers/lists_controller_provider.dart` — `listsControllerProvider`, `listsInitializationManagerProvider`, `listsPersistenceManagerProvider`
- Controller listes : `lib/presentation/pages/lists/controllers/refactored/lists_controller_slim.dart` — `_bootstrap()` lignes 44-60
- Test de référence (pattern ProviderContainer) : `test/presentation/pages/duel/duel_controller_settings_test.dart`
- Test de référence (infra fake) : `test/presentation/pages/duel_page_test_support.dart`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] sprint-status mis à jour à `review` pour cette story
- Race condition corrigée : `ensureListsLoaded()` attend désormais `Future.wait([initFuture, persistenceFuture])` avant d'appeler `loadLists()`, garantissant que le vrai `RefactoredListsController` est actif.
- 3 tests créés couvrant : timing (Completer), absence de race condition, propagation d'erreur.
- 0 régression sur la suite complète (2088 pass, 26 skip, 1 flaky pré-existant `ListsTransactionManager` inchangé).

### File List

- lib/presentation/pages/duel/services/duel_service.dart
- test/presentation/pages/duel/services/duel_service_init_test.dart

### Change Log

- 2026-05-18 : Fix race condition chargement initial duel — `ensureListsLoaded()` attend `Future.wait` sur les deux FutureProviders avant `loadLists()`. 3 tests de régression ajoutés.

### Review Findings

- [x] [Review][Patch] Test T1 : remplacer `Future.delayed(300ms)` par `await future` pour éliminer le timing flaky [test/presentation/pages/duel/services/duel_service_init_test.dart:50]
- [x] [Review][Defer] Aucun timeout sur `Future.wait` dans `ensureListsLoaded()` [lib/presentation/pages/duel/services/duel_service.dart:48] — deferred, choix architectural (FutureProviders résolvent dans le flux normal)
- [x] [Review][Defer] Invalidation auth pendant `Future.wait` — provider invalidé si changement auth concurrentiel [lib/presentation/pages/duel/services/duel_service.dart:48] — deferred, pre-existing (architecture auth plus large)
- [x] [Review][Defer] `_waitForListsToFinishLoading` timeout silencieux — expire sans signal d'erreur [lib/presentation/pages/duel/services/duel_service.dart] — deferred, pre-existing
- [x] [Review][Defer] `_waitForListsToFinishLoading` ne distingue pas fin normale vs fin en erreur [lib/presentation/pages/duel/services/duel_service.dart] — deferred, pre-existing
- [x] [Review][Defer] Appels concurrents à `initialize()` sans garde [lib/presentation/pages/duel/controllers/duel_controller.dart] — deferred, pre-existing dans DuelController
- [x] [Review][Defer] T3 : contenu de `errorMessage` non vérifié (`isNotNull` seulement) [test/presentation/pages/duel/services/duel_service_init_test.dart] — deferred, nice-to-have
- [x] [Review][Defer] Échec de `listsPersistenceManagerProvider` seul non testé [test/presentation/pages/duel/services/duel_service_init_test.dart] — deferred, gap de couverture
- [x] [Review][Defer] AC2 (spinner) non couvert par les nouveaux tests — deferred, pre-existing gap dans DuelController
- [x] [Review][Defer] AC3 (message "Pas assez de tâches") sans test de non-régression explicite — deferred, nice-to-have
