# Story 10.7 : Corriger les violations d'imports lib/domain/ → lib/data/

Status: done

## Story

En tant que développeur,
je veux que aucun fichier dans `lib/domain/` n'importe depuis `lib/data/` ou `lib/infrastructure/`,
afin que la règle de dépendance hexagonale (domain ne dépend de rien) soit pleinement respectée — `grep -r "import.*data/" lib/domain/` → 0 résultat.

## Acceptance Criteria

1. `grep -r "import.*data/" lib/domain/` → 0 résultat (aucune violation restante)
2. `lib/domain/services/core/custom_list_service.dart` importe uniquement depuis `lib/domain/list/repositories/`
3. `lib/domain/services/persistence/adaptive_persistence_service.dart` importe uniquement depuis `lib/domain/list/repositories/`
4. `lib/domain/task/services/unified_prioritization_service.dart` dépend de `ITaskRepository` (port domaine, pas la data layer)
5. `lib/domain/services/navigation/` ne contient plus `list_resolution_service.dart` ni `url_state_service.dart` (déplacés vers `lib/application/services/navigation/`)
6. `lib/domain/ports/task_repository.dart` existe — interface `ITaskRepository` pure, sans import infrastructure
7. `lib/application/services/lists_persistence_service.dart` et `data_migration_service.dart` importent depuis `lib/domain/list/repositories/` (pas `lib/data/`)
8. `puro flutter analyze --no-pub` → 0 nouvelle erreur
9. `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2036 pass, 26 skip, 2 flaky `ListsTransactionManager` pré-existants)

## Tasks / Subtasks

- [x] **T1 — Corriger `custom_list_service.dart`** (AC: 1, 2)
  - [x] T1.1 — Remplacer `import 'package:prioris/data/repositories/custom_list_repository.dart'` par `import 'package:prioris/domain/list/repositories/custom_list_repository.dart'`
  - [x] T1.2 — Vérifier : `CustomListRepository` utilisé est bien la classe abstraite de domain (même contrat, import différent)
  - [x] T1.3 — `puro flutter analyze --no-pub` → 0 erreur sur ce fichier

- [x] **T2 — Corriger `adaptive_persistence_service.dart`** (AC: 1, 3)
  - [x] T2.1 — Remplacer `import 'package:prioris/data/repositories/custom_list_repository.dart'` → `import 'package:prioris/domain/list/repositories/custom_list_repository.dart'`
  - [x] T2.2 — Remplacer `import 'package:prioris/data/repositories/list_item_repository.dart'` → `import 'package:prioris/domain/list/repositories/list_item_repository.dart'`
  - [x] T2.3 — Vérifier que les types `CustomListRepository` et `ListItemRepository` sont identiques (pas de régression de contrat)

- [x] **T3 — Créer `ITaskRepository` et corriger `unified_prioritization_service.dart`** (AC: 4, 6)
  - [x] T3.1 — Créer `lib/domain/ports/task_repository.dart` avec `abstract class ITaskRepository` — sans import infrastructure
  - [x] T3.2 — Copier dans `ITaskRepository` les 10 méthodes de `abstract class TaskRepository` (lib/data) : `getAllTasks`, `saveTask`, `updateTask`, `deleteTask`, `getActiveTasks`, `getCompletedTasks`, `getTasksByCategory`, `clearAllTasks`, `updateEloScores`, `getRandomTasksForDuel`
  - [x] T3.3 — Dans `lib/data/repositories/task_repository.dart` : ajouter `import 'package:prioris/domain/ports/task_repository.dart'` et `implements ITaskRepository` à `abstract class TaskRepository`
  - [x] T3.4 — Dans `lib/domain/task/services/unified_prioritization_service.dart` : remplacer `import 'package:prioris/data/repositories/task_repository.dart'` → `import 'package:prioris/domain/ports/task_repository.dart'` et changer `final TaskRepository taskRepository` → `final ITaskRepository taskRepository`
  - [x] T3.5 — Vérifier que `lib/data/providers/prioritization_providers.dart` compile sans modification (il fournit `TaskRepository` qui implémente `ITaskRepository`)
  - [x] T3.6 — Vérifier que les tests de `UnifiedPrioritizationService` compilent : `MockTaskRepository` implements `TaskRepository` which implements `ITaskRepository` — aucun changement de test requis

- [x] **T4 — Déplacer les services de navigation hors de `lib/domain/`** (AC: 1, 5)
  - [x] T4.1 — Créer le dossier `lib/application/services/navigation/` s'il n'existe pas
  - [x] T4.2 — Copier `lib/domain/services/navigation/list_resolution_service.dart` → `lib/application/services/navigation/list_resolution_service.dart`
  - [x] T4.3 — Dans le fichier déplacé : mettre à jour les imports si nécessaire (pas de changement attendu car les imports existants sont déjà `data/providers/` et `flutter_riverpod` — légitimes en application layer)
  - [x] T4.4 — Copier `lib/domain/services/navigation/url_state_service.dart` → `lib/application/services/navigation/url_state_service.dart`
  - [x] T4.5 — Dans `url_state_service.dart` : mettre à jour l'import de `list_resolution_service` → `package:prioris/application/services/navigation/list_resolution_service.dart`
  - [x] T4.6 — Supprimer les fichiers originaux dans `lib/domain/services/navigation/`
  - [x] T4.7 — Mettre à jour les tests : `test/domain/services/navigation/list_resolution_service_test.dart` et `url_state_service_test.dart` — déplacer vers `test/application/services/navigation/` et corriger les imports
  - [x] T4.8 — Vérifier qu'aucune autre référence dans `lib/` n'importe depuis les anciens chemins `lib/domain/services/navigation/`

- [x] **T5 — Corriger `lists_persistence_service.dart` et `data_migration_service.dart`** (AC: 7)
  - [x] T5.1 — Dans `lib/application/services/lists_persistence_service.dart` : remplacer `import 'package:prioris/data/repositories/custom_list_repository.dart'` → `import 'package:prioris/domain/list/repositories/custom_list_repository.dart'`
  - [x] T5.2 — Dans `lib/application/services/lists_persistence_service.dart` : remplacer `import 'package:prioris/data/repositories/list_item_repository.dart'` → `import 'package:prioris/domain/list/repositories/list_item_repository.dart'`
  - [x] T5.3 — Dans `lib/application/services/data_migration_service.dart` : remplacer `import '../../data/repositories/custom_list_repository.dart'` → `import '../../domain/list/repositories/custom_list_repository.dart'`
  - [x] T5.4 — Vérifier `puro flutter analyze --no-pub` → 0 erreur sur ces fichiers

- [x] **T6 — Validation finale** (AC: 8, 9)
  - [x] T6.1 — `grep -r "import.*data/" lib/domain/` → 0 résultat
  - [x] T6.2 — `puro flutter analyze --no-pub` → 0 nouvelle erreur
  - [x] T6.3 — `puro flutter test --exclude-tags integration` → 0 régression

## Dev Notes

### Contexte ADR-001

L'objectif est que `lib/domain/` soit hermétique : aucun import depuis `lib/data/`, `lib/infrastructure/`, ou `lib/presentation/`. Référence : `docs/ADR/ADR-001-hexagonal.md`, `lib/domain/CLAUDE.md`.

Règle de dépendance hexagonale :
```
presentation/ → application/ → domain ← data/infrastructure
```
Les fichiers `lib/data/` PEUVENT importer `lib/domain/ports/` — la dépendance va dans le bon sens.

### Inventaire complet des violations (résultat de grep au 2026-05-16)

```
lib/domain/services/core/custom_list_service.dart:3:
  import 'package:prioris/data/repositories/custom_list_repository.dart';

lib/domain/services/navigation/list_resolution_service.dart:3:
  import 'package:prioris/data/providers/lists_controller_provider.dart';

lib/domain/services/persistence/adaptive_persistence_service.dart:1:
  import 'package:prioris/data/repositories/custom_list_repository.dart';

lib/domain/services/persistence/adaptive_persistence_service.dart:2:
  import 'package:prioris/data/repositories/list_item_repository.dart';

lib/domain/task/services/unified_prioritization_service.dart:4:
  import 'package:prioris/data/repositories/task_repository.dart';
```

### Pourquoi chaque fix est sûr

**T1 — `custom_list_service.dart`** : `lib/data/repositories/custom_list_repository.dart` est un fichier qui RE-EXPORTE `lib/domain/list/repositories/custom_list_repository.dart` et ajoute `InMemoryCustomListRepository`. Le type `CustomListRepository` utilisé par `custom_list_service.dart` est déjà défini dans le domain. Changer l'import vers la source directe ne casse rien.

**T2 — `adaptive_persistence_service.dart`** : Même pattern. `lib/data/repositories/list_item_repository.dart` re-exporte `lib/domain/list/repositories/list_item_repository.dart`. Swap direct.

**T3 — `unified_prioritization_service.dart`** : `abstract class TaskRepository` dans `lib/data/` a une API simple (`getAllTasks`, `updateEloScores`, etc.) différente de `lib/domain/task/repositories/task_repository.dart` (complexe, `TaskAggregate`, non utilisé nulle part). La solution : créer `ITaskRepository` dans `lib/domain/ports/` avec les mêmes méthodes que `TaskRepository` (data), ajouter `implements ITaskRepository` à `abstract class TaskRepository` (data). Ainsi les mocks de tests (`MockTaskRepository` qui implements `TaskRepository`) restent valides pour `ITaskRepository`.

**T4 — `list_resolution_service.dart` et `url_state_service.dart`** : Ces services utilisent `Ref` (Riverpod) et des providers de la couche data — ils n'ont rien à faire dans `lib/domain/`. Aucun fichier dans `lib/` (hors `url_state_service.dart` lui-même) n'importe `list_resolution_service.dart`. Déplacement safe vers `lib/application/services/navigation/`. Les tests sont à déplacer aussi vers `test/application/services/navigation/`.

**T5 — `lib/application/`** : Les services application PEUVENT dépendre des ports domain. Ils ne devraient pas importer depuis `lib/data/repositories/` directement mais depuis les ports domain. Le type `CustomListRepository` est le même (il vient de `lib/domain/list/repositories/`).

### Port ITaskRepository — cible

```dart
// lib/domain/ports/task_repository.dart — NOUVEAU
import 'package:prioris/domain/models/core/entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> getAllTasks();
  Future<void> saveTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> getActiveTasks();
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getTasksByCategory(String category);
  Future<void> clearAllTasks();
  Future<void> updateEloScores(Task winner, Task loser);
  Future<List<Task>> getRandomTasksForDuel();
}
```

Vérifier : aucun import `package:supabase_flutter`, `package:hive`, `package:flutter`, `package:prioris/data/`, `package:prioris/infrastructure/` dans ce fichier.

### Mise à jour TaskRepository (lib/data)

```dart
// lib/data/repositories/task_repository.dart — MODIFIER
import 'package:flutter_riverpod/flutter_riverpod.dart';  // existant
import 'package:prioris/domain/models/core/entities/task.dart';  // existant
import 'package:prioris/domain/ports/task_repository.dart';  // AJOUTER

abstract class TaskRepository implements ITaskRepository {  // MODIFIER
  // ... méthodes inchangées
}
```

### UnifiedPrioritizationService — cible

```dart
// lib/domain/task/services/unified_prioritization_service.dart — MODIFIER
import 'package:prioris/domain/ports/task_repository.dart';  // NOUVEAU (remplace data/)

class UnifiedPrioritizationService {
  final ITaskRepository taskRepository;  // MODIFIER (était TaskRepository)
  // ... reste inchangé
}
```

### Ordre d'implémentation recommandé (TDD)

1. Créer `lib/domain/ports/task_repository.dart` (ITaskRepository)
2. Mettre à jour `lib/data/repositories/task_repository.dart` : `implements ITaskRepository`
3. Mettre à jour `lib/domain/task/services/unified_prioritization_service.dart`
4. Corriger les imports simples (T1, T2, T5)
5. Déplacer les fichiers navigation (T4) — s'assurer que le dossier destination existe
6. `puro flutter analyze --no-pub` après chaque step
7. `puro flutter test --exclude-tags integration` en fin

### Commandes utiles

```bash
# Vérifier les violations restantes
grep -r "import.*data/" lib/domain/

# Analyse et tests
puro flutter analyze --no-pub
puro flutter test --exclude-tags integration

# Tests spécifiques après chaque groupe de changements
puro flutter test test/domain/task/services/
puro flutter test test/application/services/
```

### Attention — Coexistence de deux `TaskRepository`

`lib/domain/task/repositories/task_repository.dart` définit `abstract class TaskRepository extends PaginatedRepository<TaskAggregate>` — interface avancée avec `TaskAggregate`, **non utilisée nulle part dans le codebase** (grep vérifié au 2026-05-16). Elle ne crée pas de conflit de nommage car elle est dans un package path différent (`domain/task/repositories/` vs `domain/ports/`). Le DEV AGENT ne doit PAS modifier ce fichier dans cette story.

### Mocks versionnés — Attention

Le projet versionne les mocks (story 10-2). L'import de `TaskRepository` dans `unified_prioritization_service_test.dart` restera valide (le mock `MockTaskRepository` implements `TaskRepository` which implements `ITaskRepository`). **Aucune régénération de mock n'est requise** pour cette story.

### Files à déplacer — structure test

Les tests de navigation sont actuellement dans `test/domain/services/navigation/`. Après déplacement des sources :
- `test/domain/services/navigation/list_resolution_service_test.dart` → `test/application/services/navigation/list_resolution_service_test.dart`
- `test/domain/services/navigation/url_state_service_test.dart` → `test/application/services/navigation/url_state_service_test.dart`
- Les imports dans ces tests : changer `domain/services/navigation/` → `application/services/navigation/`

### Project Structure Notes

**Fichiers créés :**
- `lib/domain/ports/task_repository.dart` — nouveau port `ITaskRepository`
- `lib/application/services/navigation/list_resolution_service.dart` — déplacé depuis domain
- `lib/application/services/navigation/url_state_service.dart` — déplacé depuis domain
- `test/application/services/navigation/list_resolution_service_test.dart` — déplacé depuis test/domain/
- `test/application/services/navigation/url_state_service_test.dart` — déplacé depuis test/domain/

**Fichiers modifiés :**
- `lib/domain/services/core/custom_list_service.dart` — swap import l.3
- `lib/domain/services/persistence/adaptive_persistence_service.dart` — swap imports l.1-2
- `lib/domain/task/services/unified_prioritization_service.dart` — import + type `ITaskRepository`
- `lib/data/repositories/task_repository.dart` — ajouter `implements ITaskRepository`
- `lib/application/services/lists_persistence_service.dart` — swap imports l.8-9
- `lib/application/services/data_migration_service.dart` — swap import l.7

**Fichiers supprimés :**
- `lib/domain/services/navigation/list_resolution_service.dart`
- `lib/domain/services/navigation/url_state_service.dart`
- `test/domain/services/navigation/list_resolution_service_test.dart`
- `test/domain/services/navigation/url_state_service_test.dart`

### References

- Epic source : `_bmad-output/planning-artifacts/epic-10.md` — Story 10.4
- ADR : `docs/ADR/ADR-001-hexagonal.md` — Règle de dépendance hexagonale
- Règles domaine : `lib/domain/CLAUDE.md` — imports interdits dans lib/domain/
- Pattern port existant : `lib/domain/ports/consent_repository.dart`, `lib/domain/ports/auth_service.dart`
- Port domain CustomListRepository : `lib/domain/list/repositories/custom_list_repository.dart`
- Port domain ListItemRepository : `lib/domain/list/repositories/list_item_repository.dart`
- Service à corriger (T1) : `lib/domain/services/core/custom_list_service.dart`
- Service à corriger (T2) : `lib/domain/services/persistence/adaptive_persistence_service.dart`
- Service à corriger (T3) : `lib/domain/task/services/unified_prioritization_service.dart`
- Services à déplacer (T4) : `lib/domain/services/navigation/list_resolution_service.dart`, `url_state_service.dart`
- Services application à corriger (T5) : `lib/application/services/lists_persistence_service.dart`, `data_migration_service.dart`
- Baseline tests : 2036 pass, 26 skip, 2 flaky `ListsTransactionManager` pré-existants (story 10-6)

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] T1 : `lib/domain/services/core/custom_list_service.dart` — swap import data/ → domain/list/repositories/ (1 ligne)
- [x] T2 : `lib/domain/services/persistence/adaptive_persistence_service.dart` — swap 2 imports data/ → domain/list/repositories/ (2 lignes)
- [x] T3 : Création de `lib/domain/ports/task_repository.dart` (ITaskRepository, 10 méthodes, 0 import infra). `lib/data/repositories/task_repository.dart` enrichi de `implements ITaskRepository`. `unified_prioritization_service.dart` : import + type → ITaskRepository. Aucune régénération de mock requise.
- [x] T4 : `list_resolution_service.dart` et `url_state_service.dart` déplacés de `lib/domain/services/navigation/` → `lib/application/services/navigation/`. Import de list_resolution dans url_state mis à jour. Tests déplacés de `test/domain/services/navigation/` → `test/application/services/navigation/`. Aucun résidu dans lib/.
- [x] T5 : `lists_persistence_service.dart` et `data_migration_service.dart` — swap imports data/repositories/ → domain/list/repositories/.
- [x] T6 : grep lib/domain/ → 0 violation. analyze → 0 nouvelle erreur. tests → 2042 pass, 26 skip, 2 flaky pre-existants (ListsTransactionManager).
- [x] sprint-status mis à jour à `review` pour cette story

### File List

**Créés :**
- `lib/domain/ports/task_repository.dart`
- `lib/application/services/navigation/list_resolution_service.dart`
- `lib/application/services/navigation/url_state_service.dart`
- `test/application/services/navigation/list_resolution_service_test.dart`
- `test/application/services/navigation/url_state_service_test.dart`

**Modifiés :**
- `lib/domain/services/core/custom_list_service.dart`
- `lib/domain/services/persistence/adaptive_persistence_service.dart`
- `lib/domain/task/services/unified_prioritization_service.dart`
- `lib/data/repositories/task_repository.dart`
- `lib/application/services/lists_persistence_service.dart`
- `lib/application/services/data_migration_service.dart`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

**Supprimés :**
- `lib/domain/services/navigation/list_resolution_service.dart`
- `lib/domain/services/navigation/url_state_service.dart`
- `test/domain/services/navigation/list_resolution_service_test.dart`
- `test/domain/services/navigation/url_state_service_test.dart`

### Review Findings

- [x] [Review][Decision] AC8/AC9 : Confirmé — analyze 0 nouvelle erreur, 2042 pass / 26 skip / 2 flaky pré-existants (ListsTransactionManager)
- [x] [Review][Patch] `_BlockingConsentService` manque l'argument super-constructeur — corrigé : ajout `_NullConsentRepository` + `super(const _NullConsentRepository())` [test/presentation/pages/auth/auth_wrapper_consent_test.dart:15]
- [x] [Review][Patch] Variables locales `navigator` et `newSettings` inutilisées supprimées de `_silentUrlUpdate` [lib/application/services/navigation/url_state_service.dart:44]
- [x] [Review][Defer] `UrlStateService._updateBrowserUrl` no-op complet — URL jamais mise à jour, `navigator` et `newSettings` créés mais inutilisés [lib/application/services/navigation/url_state_service.dart] — deferred, pré-existant dans fichier déplacé
- [x] [Review][Defer] Print statements emoji dans services de navigation (9 appels) — pré-existants dans fichiers déplacés [lib/application/services/navigation/] — deferred
- [x] [Review][Defer] Tests de persistance date `ConsentService` supprimés (RGPD) — couverture attendue dans `shared_preferences_consent_repository_test.dart` [test/domain/services/core/consent_service_test.dart] — deferred
- [x] [Review][Defer] `authServiceProvider` typé `Provider<AuthService>` au lieu de `Provider<IAuthService>` — bypasse l'abstraction du port [lib/data/providers/auth_providers.dart:15] — deferred, dette story 10-6
- [x] [Review][Defer] Deux `abstract class TaskRepository` coexistent avec des sémantiques différentes (data vs domain) — risque confusion future [lib/data/repositories/task_repository.dart vs lib/domain/task/repositories/task_repository.dart] — deferred, pré-existant
- [x] [Review][Defer] `HiveCustomListRepository.getStats` orphelin après ISP cleanup — dead code résiduel [lib/data/repositories/hive_custom_list_repository.dart] — deferred
- [x] [Review][Defer] `UrlStateService` stocke `BuildContext` comme champ — anti-pattern Flutter, contexte peut devenir stale [lib/application/services/navigation/url_state_service.dart] — deferred, pré-existant dans fichier déplacé

### Change Log

- 2026-05-17 : Suppression de toutes les violations d'imports `lib/domain/ → lib/data/` : swaps d'imports (T1, T2, T5), port ITaskRepository (T3), déplacement services navigation (T4).

