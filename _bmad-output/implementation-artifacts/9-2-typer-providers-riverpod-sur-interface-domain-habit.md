# Story 9.2 : Typer les providers Riverpod sur l'interface domain pour habit

Status: done

## Story

En tant que développeur,
je veux que `habitRepositoryProvider` retourne `HabitRepository` (interface domain) et non `SupabaseHabitRepository` (implémentation concrète),
afin que la présentation dépende uniquement de l'abstraction et non d'un détail d'infrastructure.

## Acceptance Criteria

1. `habitRepositoryProvider` est typé `Provider<HabitRepository>` (et non inféré sur `SupabaseHabitRepository`) — **déjà satisfait depuis story 9.1** ; vérifier que le type explicite est maintenu.
2. `lib/data/providers/habits_state_provider.dart` importe `HabitRepository` **directement** depuis `lib/domain/habit/repositories/habit_repository.dart`, pas transitivement via `lib/data/`.
3. Les variables locales `repository` dans `HabitsNotifier` sont annotées explicitement `HabitRepository` (pas de type inféré).
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur.
5. `puro flutter test --exclude-tags integration` → 0 régression.

## Tasks / Subtasks

- [x] **T1 — Vérifier AC1 (Provider déjà typé)** (AC: 1)
  - [x] T1.1 — Confirmer que `lib/data/repositories/habit_repository.dart` ligne 68 lit bien `Provider<HabitRepository>` (pas d'inférence sur `SupabaseHabitRepository`).
  - [x] T1.2 — Ne rien modifier si c'est déjà le cas.

- [x] **T2 — Mettre à jour `lib/data/providers/habits_state_provider.dart`** (AC: 2, 3)
  - [x] T2.1 — Ajouter l'import direct : `import 'package:prioris/domain/habit/repositories/habit_repository.dart';`
  - [x] T2.2 — Dans `loadHabits()` : remplacer `final repository = _ref.read(habitRepositoryProvider)` par `final HabitRepository repository = _ref.read(habitRepositoryProvider)`.
  - [x] T2.3 — Idem dans `addHabit()`, `deleteHabit()`, `updateHabit()` (4 occurrences au total).
  - [x] T2.4 — Vérifier qu'aucun import redondant n'est introduit (`HabitRepository` ne doit pas provenir de `lib/data/`).

- [x] **T3 — Tests** (AC: 4, 5)
  - [x] T3.1 — Ajouter un test dans `test/data/providers/habits_state_provider_test.dart` : vérifier que `habitRepositoryProvider` accepte un `HabitRepository` (interface domain) comme override — prouve que le provider est typé sur l'abstraction.
  - [x] T3.2 — S'assurer que les 7 tests existants passent sans modification.

- [x] **T4 — Validation finale** (AC: 4, 5)
  - [x] T4.1 — `puro flutter analyze --no-pub` → 0 nouvelle erreur.
  - [x] T4.2 — `puro flutter test --exclude-tags integration` → 0 régression.

---

## Dev Notes

### Contexte architectural

Cette story est la suite directe de 9.1 (port `HabitRepository` déplacé dans `lib/domain/`).

**Règle de dépendance hexagonale :**
```
presentation/ → domain ← data/infrastructure
```

Le fichier `habits_state_provider.dart` vit dans `lib/data/providers/`. Il a le droit d'importer depuis `lib/domain/`. C'est même obligatoire : son import de `HabitRepository` doit être *direct* sur le domaine, pas transitif via `lib/data/repositories/`.

**Lire `lib/domain/CLAUDE.md` avant de toucher `lib/domain/`** — imports interdits listés explicitement. `habits_state_provider.dart` ne touche pas `lib/domain/`, donc cette règle ne s'applique pas directement ici.

---

### État actuel des fichiers (après story 9.1)

#### `lib/data/repositories/habit_repository.dart` — **NE CHANGE PAS**

Le provider est déjà correctement typé (AC1 satisfait) :

```dart
// ligne 3 — import domain déjà présent :
import 'package:prioris/domain/habit/repositories/habit_repository.dart';

// ligne 68 — type explicite déjà en place :
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return SupabaseHabitRepository(
    supabaseService: SupabaseService.instance,
    authService: AuthService.instance,
  );
});
```

Ne pas modifier ce fichier — le provider est correct.

#### `lib/data/providers/habits_state_provider.dart` — **À MODIFIER**

État actuel des imports (lignes 1–4) :
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/data/repositories/habit_repository.dart'; // ← fournit habitRepositoryProvider
```

`HabitRepository` est actuellement résolu **transitivement** via `lib/data/repositories/habit_repository.dart` (qui lui-même importe depuis domain). C'est le défaut référencé en deferred-work.md sous "9-1 : `habits_state_provider.dart` résout `HabitRepository` transitivement via data layer".

**Diff attendu pour les imports :**
```dart
// AJOUTER après l'import des providers :
import 'package:prioris/domain/habit/repositories/habit_repository.dart';
```

**Diff attendu pour les méthodes `HabitsNotifier` (4 occurrences) :**
```dart
// AVANT :
final repository = _ref.read(habitRepositoryProvider);

// APRÈS :
final HabitRepository repository = _ref.read(habitRepositoryProvider);
```

Les 4 occurrences sont dans :
- `loadHabits()` ligne ~55
- `addHabit()` ligne ~76
- `deleteHabit()` ligne ~90
- `updateHabit()` ligne ~107

**Rien d'autre ne change.** Le comportement runtime est identique — c'est une garantie statique de typage.

---

### Fichiers qui NE changent PAS

| Fichier | Raison |
|---------|--------|
| `lib/domain/habit/repositories/habit_repository.dart` | Port correct depuis 9.1 |
| `lib/data/repositories/habit_repository.dart` | Provider déjà typé `Provider<HabitRepository>` |
| `lib/data/repositories/supabase/supabase_habit_repository.dart` | Import domain correct depuis 9.1 |
| `test/domain/habit/repositories/habit_repository_contract_test.dart` | Tests contrat déjà corrects |
| `lib/presentation/pages/statistics_page.dart` | Hors scope 9.2 |
| `lib/presentation/widgets/dialogs/add_habit_dialog.dart` | Hors scope 9.2 |

---

### Test à écrire dans `test/data/providers/habits_state_provider_test.dart`

Le fichier de test existe déjà avec 7 tests (lignes 1–253). Ajouter un groupe de tests à la fin :

```dart
group('HabitsStateProvider - Typage sur interface domain', () {
  test('habitRepositoryProvider accepte HabitRepository (interface domain) comme override', () {
    // Prouve que le provider est typé sur l'abstraction, pas sur SupabaseHabitRepository
    final mockRepo = _MockHabitRepository();
    final container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    // Si le provider était inféré sur SupabaseHabitRepository,
    // overrideWithValue(_MockHabitRepository()) ne compilerait pas
    final repo = container.read(habitRepositoryProvider);
    expect(repo, isA<HabitRepository>());
    container.dispose();
  });

  test('HabitsNotifier.loadHabits() utilise HabitRepository (pas SupabaseHabitRepository)', () async {
    // Vérifie que le notifier ne dépend que de l'interface
    bool getAllHabitsCalled = false;
    final mockRepo = _MockHabitRepository(
      onGetAllHabits: () async {
        getAllHabitsCalled = true;
        return [];
      },
    );
    final container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    final keepAlive = container.listen(habitsStateProvider, (_, __) {});
    try {
      await container.read(habitsStateProvider.notifier).loadHabits();
      expect(getAllHabitsCalled, isTrue);
    } finally {
      keepAlive.close();
      container.dispose();
    }
  });
});
```

> **Note** : Ces tests compilent uniquement parce que `HabitRepository` est importé depuis `lib/domain/` dans le test (ligne 5 du fichier existant). La compilation est la preuve que le typage est correct.

---

### Commandes de validation

```bash
# Vérifier import direct dans habits_state_provider.dart
grep -n "import.*habit_repository" lib/data/providers/habits_state_provider.dart
# Doit montrer : domain/habit/repositories/habit_repository.dart (direct)

# Vérifier annotations explicites HabitRepository dans HabitsNotifier
grep -n "HabitRepository repository" lib/data/providers/habits_state_provider.dart
# Doit montrer 4 occurrences

# Analyse statique
puro flutter analyze --no-pub

# Tests (hors intégration réseau)
puro flutter test --exclude-tags integration
```

---

### Items différés de 9.1 à NE PAS corriger dans cette story

Les éléments suivants sont pré-existants et out-of-scope pour 9.2 :

| Item | Fichier | Pourquoi hors scope |
|------|---------|---------------------|
| `saveHabit` et `addHabit` identiques | `lib/data/repositories/habit_repository.dart:27-35` | Sémantique du port — story dédiée |
| `allHabitsProvider === habitsWithStatsProvider` | `habit_repository.dart:76-85` | Duplication pré-existante |
| `ref.read` dans `FutureProvider` | `habit_repository.dart:77,83` | Pattern pré-existant |
| `updateHabit` no-op silencieux | `habit_repository.dart:39-44` | Pré-existant |
| `watchAllHabits`/`getStatsByCategory` hors port | `supabase_habit_repository.dart:185-225` | Story dédiée 9.x |

---

### Risques et garde-fous

| Risque | Mitigation |
|--------|------------|
| Import circulaire `domain/` ← `data/` | Impossible : `habits_state_provider.dart` est dans `data/providers/`, pas dans `domain/`. L'import est data→domain (correct). |
| Régression sur les 7 tests existants | Les types changent en annotations statiques uniquement — comportement runtime identique. Exécuter `puro flutter test` avant de marquer done. |
| Annotation de type incorrecte | `HabitRepository` est l'interface, `SupabaseHabitRepository` en est l'implémentation — ne pas inverser. |

---

### References

- Epic 9 story 9.2 : `_bmad-output/planning-artifacts/epic-9.md#Story-9.2`
- ADR hexagonale : `docs/ADR/ADR-001-hexagonal.md`
- Règles domaine : `lib/domain/CLAUDE.md`
- Port domain : `lib/domain/habit/repositories/habit_repository.dart`
- Provider actuel : `lib/data/repositories/habit_repository.dart:68`
- Fichier cible : `lib/data/providers/habits_state_provider.dart:4,55,76,90,107`
- Tests existants : `test/data/providers/habits_state_provider_test.dart`
- Deferred 9.1 : `_bmad-output/implementation-artifacts/deferred-work.md` (section "9-1-deplacement-port-habit-repository-vers-domaine")

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

Correction mineure : les 2 nouveaux tests étaient placés hors de `void main()` → repositionnés à l'intérieur (groupe "Typage sur interface domain" ajouté comme 3ème groupe dans main).

### Completion Notes List

- [x] `lib/data/providers/habits_state_provider.dart` : import direct `domain/habit/repositories/habit_repository.dart` ajouté + 4 annotations `HabitRepository` explicites dans `loadHabits()`, `addHabit()`, `deleteHabit()`, `updateHabit()`
- [x] `test/data/providers/habits_state_provider_test.dart` : 2 nouveaux tests (groupe "Typage sur interface domain") ajoutés dans `main()` — 9 tests passent au total
- [x] `puro flutter analyze --no-pub` → 0 nouvelle erreur dans les fichiers modifiés (warnings préexistants inchangés)
- [x] `puro flutter test --exclude-tags integration` → 0 régression (2 échecs préexistants dans `ListsTransactionManager`, non liés)
- [x] sprint-status mis à jour à `review` pour la story 9.2

### Change Log

- 2026-05-11 : Story 9.2 implémentée — import direct `HabitRepository` depuis domain dans `habits_state_provider.dart`, 4 annotations de type explicites, 2 nouveaux tests de typage sur abstraction

### File List

- `lib/data/providers/habits_state_provider.dart` — MODIFIER (import domain + 4 annotations de type)
- `test/data/providers/habits_state_provider_test.dart` — MODIFIER (ajouter groupe "Typage sur interface domain", 2 tests)

### Review Findings

- [x] [Review][Defer] `print()` debug laissé en production dans `HabitsNotifier` [lib/data/providers/habits_state_provider.dart] — deferred, pre-existing
- [x] [Review][Defer] Race autoDispose+StateNotifier entre `saveHabit`/`updateHabit` et `loadHabits()` dans `HabitsNotifier` [lib/data/providers/habits_state_provider.dart] — deferred, pre-existing
- [x] [Review][Defer] `addHabit`, `deleteHabit`, `updateHabit` non couverts individuellement par des tests de typage sur l'interface domain [test/data/providers/habits_state_provider_test.dart] — deferred, beyond spec scope
