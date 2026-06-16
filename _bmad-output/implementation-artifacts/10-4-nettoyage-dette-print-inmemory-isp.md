# Story 10.4 : Nettoyage dette technique — print(), InMemoryCustomListRepository, ISP

Status: done

## Story

En tant que développeur,
je veux supprimer les `print()` debug en production, aligner `InMemoryCustomListRepository` sur `extends` (comme les autres adapters), et nettoyer les doublons de méthodes génériques dans les sous-interfaces ISP,
afin que le code soit cohérent et la dette documentée en Épic 9 soit soldée.

## Acceptance Criteria

1. `grep -rn "print(" lib/data/providers/habits_state_provider.dart` → 0 résultat
2. `InMemoryCustomListRepository extends CustomListRepository` (pas `implements`)
3. Sous-interfaces ISP : méthodes génériques (`getAll`, `getById`, `save`, `update`, `delete`, `searchByName`, `searchByDescription`, `getByType`, `clearAll`) supprimées des interfaces — seules les méthodes nommées domaine restent (`getAllLists`, `getListById`, `saveList`, `updateList`, `deleteList`, `searchListsByName`, `searchListsByDescription`, `getListsByType`, `clearAllLists`)
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur
5. `puro flutter test --exclude-tags integration` → 0 régression

## Tasks / Subtasks

- [x] **T1 — Supprimer les print() dans HabitsNotifier** (AC: 1)
  - [x] T1.1 — Ouvrir `lib/data/providers/habits_state_provider.dart`
  - [x] T1.2 — Supprimer les 4 appels `print(...)` dans `loadHabits()` (lignes ~48, ~52, ~59, ~66)
  - [x] T1.3 — Conserver le commentaire du reentrancy guard (`// Reentrancy guard: don't fetch if already loading`) — la logique reste, seuls les prints sont supprimés

- [x] **T2 — Migrer InMemoryCustomListRepository de implements à extends** (AC: 2)
  - [x] T2.1 — Ouvrir `lib/data/repositories/custom_list_repository.dart`
  - [x] T2.2 — Changer `class InMemoryCustomListRepository implements CustomListRepository` → `class InMemoryCustomListRepository extends CustomListRepository`
  - [x] T2.3 — Supprimer l'override explicite de `getStats()` (la classe abstraite `CustomListRepository` fournit une implémentation par défaut via `getAllLists()` — identique en comportement)
  - [x] T2.4 — Les wrappers génériques (`getAll()→getAllLists()`, etc.) seront supprimés en T3 en même temps que leur déclaration dans les interfaces

- [x] **T3 — Nettoyer les sous-interfaces ISP** (AC: 3)
  - [x] T3.1 — Ouvrir `lib/domain/list/repositories/custom_list_repository.dart`
  - [x] T3.2 — `CustomListCrudRepositoryInterface` : supprimer `getAll`, `getById`, `save`, `update`, `delete` — garder `getAllLists`, `getListById`, `saveList`, `updateList`, `deleteList`
  - [x] T3.3 — `CustomListSearchRepositoryInterface` : supprimer `searchByName`, `searchByDescription` — garder `searchListsByName`, `searchListsByDescription`
  - [x] T3.4 — `CustomListFilterRepositoryInterface` : supprimer `getByType` — garder `getListsByType`
  - [x] T3.5 — `CustomListCleanRepositoryInterface` : supprimer `clearAll` — garder `clearAllLists`
  - [x] T3.6 — **InMemoryCustomListRepository** (`lib/data/repositories/custom_list_repository.dart`) : supprimer les 5 méthodes `@override` déléguantes génériques (bloc "Méthodes de l'interface BasicCrudRepositoryInterface" + searchByName/searchByDescription + getByType + clearAll). Les méthodes domaine nommées restent intactes.
  - [x] T3.7 — **HiveCustomListRepository** (`lib/data/repositories/hive_custom_list_repository.dart`) : supprimer le même bloc de 5+4 wrappers délégants (lignes ~19-46)
  - [x] T3.8 — **SupabaseCustomListRepository** (`lib/data/repositories/supabase/supabase_custom_list_repository.dart`) : supprimer les wrappers délégants équivalents (bloc lignes ~34-48)

- [x] **T4 — Validation** (AC: 4, 5)
  - [x] T4.1 — `puro flutter analyze --no-pub` → 0 erreur
  - [x] T4.2 — `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2034 pass, 26 skip, 1 flaky `ListsTransactionManager timeout` pré-existant)

### Review Findings

- [x] [Review][Defer] Observabilité perdue dans `loadHabits()` — prints supprimés sans remplacement logger structuré [lib/data/providers/habits_state_provider.dart] — deferred, pre-existing
- [x] [Review][Defer] `e.toString()` seul canal d'erreur — stack trace et type d'exception perdus [lib/data/providers/habits_state_provider.dart] — deferred, pre-existing
- [x] [Review][Defer] ISP sub-interfaces strictement minimales — tout code futur doit utiliser les noms domaine uniquement (intentionnel, 0 appelant actuel) [lib/domain/list/repositories/custom_list_repository.dart] — deferred, pre-existing
- [x] [Review][Defer] `print()` résiduels hors scope dans `repository_providers.dart` (~L124, 370, 375) et `HiveCustomListRepository._ensureInitialized()` — deferred, pre-existing

## Dev Notes

### Contexte dette

Ces trois items ont été reportés lors des reviews d'Epic 9 (stories 9.2, 9.3, 9.4) :
- **print() dans HabitsNotifier** : apparu dans 3 reviews successives, jamais adressé
- **`implements` vs `extends`** : `HiveCustomListRepository` et `SupabaseCustomListRepository` utilisent déjà `extends CustomListRepository` — l'InMemory est incohérent
- **Doublons ISP** : chaque sous-interface contient 2 noms pour la même opération (générique + domaine). Les génériques n'apportent rien ; aucun appelant externe ne les utilise (grep confirmé).

### print() — scope exact

**Fichier cible unique :** `lib/data/providers/habits_state_provider.dart`

Les 4 prints à supprimer sont dans `HabitsNotifier.loadHabits()` :
- `print('[HabitsProvider] D: loadHabits() blocked - already loading');` — dans le reentrancy guard
- `print('[HabitsProvider] I: Starting loadHabits() fetch');` — avant le fetch
- `print('[HabitsProvider] I: Fetched ${habits.length} habits successfully');` — après succès
- `print('[HabitsProvider] E: Failed to load habits - ${e.toString()}');` — dans catch

**Hors scope :** `HiveCustomListRepository._ensureInitialized()` contient `print('🔄 Auto-recovering...')` et `print('✅ Hive box auto-recovery...')` — AC1 ne mentionne que `habits_state_provider.dart`. Ne pas toucher Hive dans cette story.

### ISP — hiérarchie complète

Structure actuelle dans `lib/domain/list/repositories/custom_list_repository.dart` :

```
abstract CustomListCrudRepositoryInterface       ← contient getAll/getById/save/update/delete (à supprimer)
                                                 + getAllLists/getListById/saveList/updateList/deleteList (garder)
abstract CustomListSearchRepositoryInterface     ← contient searchByName/searchByDescription (à supprimer)
                                                 + searchListsByName/searchListsByDescription (garder)
abstract CustomListFilterRepositoryInterface     ← contient getByType (à supprimer)
                                                 + getListsByType (garder)
abstract CustomListCleanRepositoryInterface      ← contient clearAll (à supprimer)
                                                 + clearAllLists (garder)

abstract class CustomListRepository
    implements Crud + Search + Filter + Clean    ← inchangé
    default getStats() via getAllLists()          ← inchangé
```

### ISP — impact sur les implémentations

Les méthodes génériques dans les 3 implémentations sont **uniquement des wrappers délégants** (ex: `getAll() => getAllLists()`). Aucun appelant externe ne les invoque sur `CustomListRepository`. Grep `customListRepository\.(getAll|getById|save|update|delete|clearAll)\(` → 0 résultat.

Supprimer ces méthodes dans les 3 implémentations supprime le `@override` invalide (erreur `analyze` sinon) et nettoie ~20 lignes par fichier.

### extends vs implements — ce qui change pour InMemoryCustomListRepository

Avec `extends` :
- `getStats()` est **hérité** de `CustomListRepository` (utilise `getAllLists()`) → supprimer l'override redondant
- Les méthodes abstraites restantes (getAllLists, getListById, saveList, updateList, deleteList, searchListsByName, searchListsByDescription, getListsByType, clearAllLists) **doivent rester** en `@override` — elles sont les implémentations concrètes
- `_validateList()` est une méthode privée, pas dans l'interface → inchangée

L'implémentation default de `getStats()` dans l'abstract class :
```dart
Future<Map<String, dynamic>> getStats() async {
  final lists = await getAllLists();
  final completed = lists.where((list) => list.isCompleted).length;
  final itemCount = lists.fold<int>(0, (count, list) => count + list.items.length);
  return {'count': lists.length, 'completed': completed, 'items': itemCount};
}
```
Comportement identique à l'override actuel d'InMemory → suppression sans régression.

### Tests existants

- `test/domain/list/repositories/custom_list_repository_contract_test.dart` : teste `isA<CustomListRepository>()` sur les 3 implémentations — passera toujours avec `extends`
- `test/domain/models/custom_list_repository_test.dart` : utilise uniquement les méthodes domaine nommées (`getAllLists`, `getListsByType`, `clearAllLists`, etc.) — non impacté par la suppression des génériques
- Aucun test n'appelle `getAll()`, `getById()`, `save()`, etc. sur `InMemoryCustomListRepository`

### Commandes Flutter (toujours préfixer avec `puro`)

```bash
puro flutter analyze --no-pub
puro flutter test --exclude-tags integration
```

### Project Structure Notes

- `lib/data/providers/habits_state_provider.dart` — provider Riverpod, couche data
- `lib/data/repositories/custom_list_repository.dart` — InMemoryCustomListRepository + export du port domaine
- `lib/domain/list/repositories/custom_list_repository.dart` — port domaine hexagonal (ISP interfaces)
- `lib/data/repositories/hive_custom_list_repository.dart` — implémentation Hive
- `lib/data/repositories/supabase/supabase_custom_list_repository.dart` — implémentation Supabase

### References

- Source : epic-10.md story 10.6 (nettoyage dette)
- Deferred items : reviews 9.2, 9.3, 9.4 (print, implements, ISP doublons)
- Architecture hexagonale : `lib/domain/CLAUDE.md`, `docs/ADR/ADR-001-hexagonal.md`
- Baseline tests : story 10-3 Dev Agent Record (2034 pass, 26 skip, 1 flaky pré-existant)

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

Aucun blocage — les 3 items de dette étaient bien isolés, aucun appelant externe sur les méthodes génériques supprimées.

### Completion Notes List

- [x] T1 : 4 `print()` supprimés de `HabitsNotifier.loadHabits()` ; commentaire reentrancy guard conservé
- [x] T2 : `InMemoryCustomListRepository` migré de `implements` à `extends` ; override redondant de `getStats()` supprimé (hérité de `CustomListRepository`)
- [x] T3 : 9 déclarations génériques supprimées des 4 sous-interfaces ISP ; 9+4+5 wrappers délégants supprimés des 3 implémentations (InMemory, Hive, Supabase)
- [x] T4 : `flutter analyze --no-pub` → 0 nouvelle erreur ; tests → 2034 pass / 26 skip / 1 flaky pré-existant (ListsTransactionManager timeout)
- [x] sprint-status mis à jour à `review` pour cette story

### File List

- `lib/data/providers/habits_state_provider.dart`
- `lib/domain/list/repositories/custom_list_repository.dart`
- `lib/data/repositories/custom_list_repository.dart`
- `lib/data/repositories/hive_custom_list_repository.dart`
- `lib/data/repositories/supabase/supabase_custom_list_repository.dart`

### Change Log

- Nettoyage dette technique : suppression 4 print() debug, migration implements→extends, nettoyage 9 doublons ISP dans 4 interfaces + 3 implémentations (Date: 2026-05-15)
