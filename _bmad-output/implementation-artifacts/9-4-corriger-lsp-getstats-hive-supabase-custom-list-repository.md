# Story 9.4 : Corriger la violation LSP de getStats() — renommer les overrides infra Hive et Supabase

Status: done

## Story

En tant que développeur,
je veux renommer `getStats()` dans `HiveCustomListRepository` (→ `getDiagnostics()`) et dans `SupabaseCustomListRepository` (→ `getTypeDistribution()`),
afin que la méthode `getStats()` du port domaine `CustomListRepository` retourne une structure sémantiquement cohérente (`{count, completed, items}`) quelle que soit l'implémentation concrète.

## Acceptance Criteria

1. `HiveCustomListRepository` ne déclare plus `getStats()` — la méthode est renommée `getDiagnostics()` et retourne toujours `{totalLists, boxSize, isOpen, path, name}`
2. `SupabaseCustomListRepository` ne déclare plus `getStats()` — la méthode est renommée `getTypeDistribution()` et retourne toujours `Map<String, int>` avec le nombre de listes par type
3. `HiveCustomListRepository` et `SupabaseCustomListRepository` héritent du default `getStats()` de `CustomListRepository` (domain) — retourne `{count, completed, items}` via `getAllLists()`
4. Les 4 appels `.getStats()` sur `HiveCustomListRepository` dans `data_loss_diagnostic_test.dart` sont mis à jour vers `.getDiagnostics()`
5. `RecordingListRepository.getStats()` override est supprimé — la classe hérite du default domaine (aucun test ne l'appelait)
6. `puro flutter analyze --no-pub` → 0 nouvelle erreur
7. `puro flutter test --exclude-tags integration` → 0 régression

## Tasks / Subtasks

- [x] **T1 — Renommer dans HiveCustomListRepository** (AC: 1, 3)
  - [x] T1.1 — `lib/data/repositories/hive_custom_list_repository.dart` : renommer `getStats()` → `getDiagnostics()` + `implements` → `extends CustomListRepository`
  - [x] T1.2 — Doc-comment mis à jour : "Métriques de diagnostic de la box Hive (debug/monitoring) — non lié au contrat du port domaine"

- [x] **T2 — Renommer dans SupabaseCustomListRepository** (AC: 2, 3)
  - [x] T2.1 — `lib/data/repositories/supabase/supabase_custom_list_repository.dart` : renommer `getStats()` → `getTypeDistribution()` + `implements` → `extends CustomListRepository`
  - [x] T2.2 — Doc-comment mis à jour : "Distribution des listes par type pour l'utilisateur courant — non lié au contrat du port domaine"

- [x] **T3 — Mettre à jour data_loss_diagnostic_test.dart** (AC: 4)
  - [x] T3.1 — ligne 242 : `.getStats()` → `.getDiagnostics()`
  - [x] T3.2 — ligne 272 : `.getStats()` → `.getDiagnostics()`
  - [x] T3.3 — ligne 300 : `.getStats()` → `.getDiagnostics()`
  - [x] T3.4 — ligne 760 : `.getStats()` → `(listRepo2 as HiveCustomListRepository).getDiagnostics()` (cast nécessaire car registry retourne `CustomListRepository`)

- [x] **T4 — Nettoyer RecordingListRepository** (AC: 5)
  - [x] T4.1 — `test/test_utils/recording_list_repository.dart` : supprimer l'override `getStats()` + `implements` → `extends CustomListRepository`

- [x] **T5 — Validation finale** (AC: 6, 7)
  - [x] T5.1 — Grep : 0 appelant résiduel de `.getStats()` dans les adapters Hive/Supabase/RecordingListRepository
  - [x] T5.2 — `puro flutter analyze --no-pub` → 0 nouvelle erreur introduite
  - [x] T5.3 — `puro flutter test --exclude-tags integration` → 0 régression (amélioration : -9 → -2 tests, grâce à la conformité LSP)

---

## Dev Notes

### Contexte — origine du fix

Finding HIGH issu de la revue de code 9-3. Le port domaine `CustomListRepository` (abstract class dans `lib/domain/list/repositories/custom_list_repository.dart`) déclare une méthode `getStats()` avec une implémentation default qui retourne les stats métier (`{count, completed, items}`). Deux adapters overridaient silencieusement cette méthode avec des sémantiques incompatibles :

| Implémentation | `getStats()` retournait |
|---|---|
| Domain default (héritage) | `{count: int, completed: int, items: int}` — stats métier |
| `InMemoryCustomListRepository` | `{count: int, completed: int, items: int}` ✓ conforme |
| `SupabaseCustomListRepository` | `Map<String, int>` — nb de listes par type (`{'todo': 3, ...}`) |
| `HiveCustomListRepository` | `{totalLists, boxSize, isOpen, path, name}` — métriques infra |
| `RecordingListRepository` (test) | `{totalLists, totalWriteCount, operationsCount}` — recording metrics |

Personne en production n'appelle `_repository.getStats()` via le port `CustomListRepository` — le `CustomListStatsService` calcule ses propres stats directement via `getAllLists()`. Les seuls appelants directs sont :
- `test/diagnostics/data_loss_diagnostic_test.dart` (4 appels sur `HiveCustomListRepository` typé concretement)
- Personne pour `SupabaseCustomListRepository.getStats()`
- Personne pour `RecordingListRepository.getStats()`

### État exact des fichiers à modifier

**`lib/data/repositories/hive_custom_list_repository.dart:249-260`** (T1) :
```dart
/// Statistiques de la box Hive (pour debug/monitoring)
Future<Map<String, dynamic>> getStats() async {
  await _ensureInitialized();
  return {
    'totalLists': _box.length,
    'boxSize': _box.values.length,
    'isOpen': _box.isOpen,
    'path': _box.path,
    'name': _box.name,
  };
}
```
→ Renommer `getStats` en `getDiagnostics`, mettre à jour le doc-comment.

**`lib/data/repositories/supabase/supabase_custom_list_repository.dart:294-316`** (T2) :
```dart
/// Obtient les statistiques de l'utilisateur
Future<Map<String, int>> getStats() async {
  try {
    if (!_auth.isSignedIn) throw Exception('User not authenticated');
    final response = await _table().select(
      columns: 'list_type',
      builder: (query) => query
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false),
    );
    final stats = <String, int>{};
    for (final item in response) {
      final type = item['list_type'] as String;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  } catch (e) {
    throw Exception('Failed to get stats: $e');
  }
}
```
→ Renommer `getStats` en `getTypeDistribution`, mettre à jour le doc-comment.

**`test/test_utils/recording_list_repository.dart:242-250`** (T4) :
```dart
// CustomListRepository methods
@override
Future<Map<String, dynamic>> getStats() async {
  return {
    'totalLists': _storage.length,
    'totalWriteCount': _writeCount,
    'operationsCount': _operationsLog.length,
  };
}
```
→ Supprimer l'intégralité de ces 8 lignes. `RecordingListRepository` hérite alors du default domaine. Aucun test n'appelle `.getStats()` sur une instance `RecordingListRepository` (confirmé par grep — 0 résultat dans `lists_controller_adaptive_test.dart`).

### Cas `supabase_integration_validation_test.dart:115` — pas de changement

```dart
expect(customListRepo.getStats, isA<Function>());
```

Après T2, `SupabaseCustomListRepository` n'override plus `getStats()` mais **hérite** du default domaine. La méthode `getStats` est toujours présente → `isA<Function>()` passe. Pas de modification de ce fichier.

### Mocks auto-générés (`*.mocks.dart`) — pas de changement

Les mocks (`data_migration_service_test.mocks.dart`, etc.) mockent l'interface `CustomListRepository`. L'interface domaine ne change pas dans cette story → les mocks ne changent pas.

### Règle de dépendance hexagonale rappel

`getDiagnostics()` et `getTypeDistribution()` sont des méthodes **concrètes hors-port** des adapters. Elles n'appartiennent pas à `CustomListRepository` (l'interface). Le port domaine reste inchangé.

### Commandes de validation

```bash
# Vérifier qu'aucun appelant ne reste sur l'ancien nom (hors mocks, cache, habit)
grep -rn "\.getStats()" lib/ test/ --include="*.dart" | grep -v "mock\|cache_monitoring\|cache_service\|habit_repository\|list_providers\|cache_service_test"

# Analyse statique
puro flutter analyze --no-pub

# Tests sans intégration réseau
puro flutter test --exclude-tags integration
```

### Risques

| Risque | Mitigation |
|--------|-----------|
| Appelant oublié dans les mocks | Les mocks auto-générés mockent l'interface domain (inchangée) — pas impactés |
| `supabase_integration_validation_test.dart` casse | Non : `getStats` hérité du domaine, méthode toujours présente |
| `RecordingListRepository` suppression casse un test | Grep confirme 0 appelant de `.getStats()` dans `lists_controller_adaptive_test.dart` |

### Fichiers qui NE changent PAS

| Fichier | Raison |
|---------|--------|
| `lib/domain/list/repositories/custom_list_repository.dart` | Port inchangé — `getStats()` default reste en place |
| `lib/data/repositories/custom_list_repository.dart` | `InMemoryCustomListRepository.getStats()` retourne déjà `{count, completed, items}` — conforme, garder |
| `test/integration/supabase_integration_validation_test.dart` | Héritage domain, `getStats` toujours présent |
| `test/application/services/*.mocks.dart` et autres | Mockent l'interface domain inchangée |

### Références

- Finding D2 HIGH revue 9-3 : `_bmad-output/implementation-artifacts/9-3-deplacement-ports-customlist-et-listitem-vers-domaine.md#Review-Findings`
- Port domaine : `lib/domain/list/repositories/custom_list_repository.dart`
- ADR hexagonale : `docs/ADR/ADR-001-hexagonal.md`
- Règles domaine : `lib/domain/CLAUDE.md`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] T1 : HiveCustomListRepository — `getStats()` → `getDiagnostics()`, `implements` → `extends` (pour hériter du default domaine)
- [x] T2 : SupabaseCustomListRepository — `getStats()` → `getTypeDistribution()`, `implements` → `extends`
- [x] T3 : data_loss_diagnostic_test.dart — 4 appels mis à jour (dont 1 cast nécessaire car registry type `CustomListRepository`)
- [x] T4 : RecordingListRepository — override `getStats()` supprimé, `implements` → `extends`
- [x] T5 : Analyze 0 nouvelle erreur — Tests: -9 → -2 (amélioration, 0 régression introduite)
- [x] sprint-status mis à jour à `review`

### File List

- `lib/data/repositories/hive_custom_list_repository.dart` — MODIFIÉ (rename getStats→getDiagnostics, implements→extends)
- `lib/data/repositories/supabase/supabase_custom_list_repository.dart` — MODIFIÉ (rename getStats→getTypeDistribution, implements→extends)
- `test/diagnostics/data_loss_diagnostic_test.dart` — MODIFIÉ (4 appels getStats→getDiagnostics, dont cast ligne 760)
- `test/test_utils/recording_list_repository.dart` — MODIFIÉ (supprimer override getStats, implements→extends)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — MODIFIÉ (statut → review)
- `_bmad-output/implementation-artifacts/9-4-corriger-lsp-getstats-hive-supabase-custom-list-repository.md` — MODIFIÉ (story file)

### Review Findings

- [x] [Review][Patch] Message d'erreur obsolète dans `getTypeDistribution()` [lib/data/repositories/supabase/supabase_custom_list_repository.dart — `throw Exception('Failed to get stats: $e')`]
- [x] [Review][Defer] `cleanOldData @override` sans méthode parente dans `CustomListRepository` [test/test_utils/recording_list_repository.dart:226] — deferred, pre-existing lint warning (existait avant 9-4)
- [x] [Review][Defer] `getStats()` hérité appelle `getAllLists()` → throw si `getAllLists` configuré en échec [test/test_utils/recording_list_repository.dart] — deferred, pre-existing, aucun test affecté
- [x] [Review][Defer] Cast `(listRepo2 as HiveCustomListRepository)` [test/diagnostics/data_loss_diagnostic_test.dart:760] — deferred, by design (T3.4 story, registre typé CustomListRepository)
- [x] [Review][Defer] `supabase_integration_validation_test.dart:115` teste désormais le default domain plutôt que Supabase-specific — deferred, analysé et accepté dans Dev Notes
- [x] [Review][Defer] `HiveCustomListRepository.getStats()` retourne `items: 0` (getAllLists ne charge pas les items) — deferred, pre-existing, personne n'appelle via port
- [x] [Review][Defer] Méthodes `getDiagnostics()`/`getTypeDistribution()` publiques sur classes qui étendent le port — deferred, design choice documenté non-breaking
- [x] [Review][Defer] `implements` → `extends` couplage structurel plus fort que pure interface — deferred, décision architecture acceptée ADR-001
- [x] [Review][Defer] `InMemoryCustomListRepository` utilise encore `implements` (incohérence) — deferred, explicitement exclu du scope 9-4

## Change Log

- 2026-05-11 : Correction violation LSP — renommage `getStats()` → `getDiagnostics()` (Hive) et `getTypeDistribution()` (Supabase), passage `implements` → `extends` sur les 3 adapters (Hive, Supabase, RecordingList), 4 appels tests mis à jour, 0 régression (amélioration -9 → -2 tests en baseline)
