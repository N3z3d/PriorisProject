# Story 10.8 : Tests domaine purs sans Supabase

Status: done

## Story

En tant que développeur,
je veux des tests unitaires pour les services domaine qui s'exécutent sans connexion Supabase, sans Hive initialisé et sans SharedPreferences réels,
afin que la suite CI soit plus rapide et fiable, et que la correction de l'architecture hexagonale (Epic 10) soit prouvée par des tests isolés.

## Acceptance Criteria

1. `ConsentService` : tests enrichis avec propagation d'exceptions depuis `IConsentRepository` — aucun appel SharedPreferences réel
2. `CustomListCrudService`, `CustomListSearchService`, `CustomListStatsService`, `CustomListService` (composite) : tests unitaires créés avec des fakes `CustomListRepository` — aucun import Hive ni Supabase dans les services testés
3. `AdaptivePersistenceService` : tests unitaires créés couvrant les modes localFirst/cloudFirst, la déduplication, et la gestion des erreurs duplicate/permission — aucun Hive ni Supabase réel
4. Tous les nouveaux tests s'exécutent sans tag `integration` et sans réseau
5. `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2046 pass, 26 skip, 1 flaky pré-existant `ListsTransactionManager`), nouveaux tests verts

## Tasks / Subtasks

- [x] **T1 — Enrichir `consent_service_test.dart` avec cas exception** (AC: 1)
  - [x] T1.1 — Ajouter `_ThrowingConsentRepository` inline (implements `IConsentRepository`, toutes méthodes lèvent une `Exception`)
  - [x] T1.2 — Ajouter groupe `ConsentService exception propagation` : vérifier que `hasAcceptedConsent()`, `acceptConsent()`, `revokeConsent()` propagent chacun l'exception du repository (3 tests)

- [x] **T2 — Créer `test/domain/services/core/custom_list_service_test.dart`** (AC: 2, 4)
  - [x] T2.1 — Déclarer `_FakeCustomListRepository extends CustomListRepository` inline (stockage `Map<String, CustomList>` en mémoire — pas de validation stricte) pour isoler des comportements de `InMemoryCustomListRepository` qui valide les doublons
  - [x] T2.2 — Groupe `CustomListCrudService` : tester `getAllLists`, `addList`, `updateList`, `deleteList`, `clearAllLists` (5 tests nominaux + edge case liste vide)
  - [x] T2.3 — Groupe `CustomListSearchService` : tester `getListsByType` (filtrage par type), `searchLists` (correspondance partielle, insensible à la casse, aucun résultat, champ description) (4 tests)
  - [x] T2.4 — Groupe `CustomListStatsService` : tester `getGlobalProgress` (liste vide → 0.0, 0 éléments → 0.0, calcul normal), `getStats` (clés `totalLists`, `totalItems`, `completedItems`, `averageProgress`) (5 tests)
  - [x] T2.5 — Groupe `CustomListService` (composite) : vérifier que chaque méthode délègue correctement au sous-service — utiliser un fake commun partagé entre les 3 sous-services pour vérifier la cohérence de la délégation (3 tests de smoke)

- [x] **T3 — Créer `test/domain/services/persistence/adaptive_persistence_service_test.dart`** (AC: 3, 4)
  - [x] T3.1 — Déclarer `_FakeListItemRepository implements ListItemRepository` inline (stockage `Map<String, ListItem>`, lève `Exception('duplicate')` si ID déjà présent dans `add`)
  - [x] T3.2 — Groupe `initialize / updateAuthenticationState` : vérifier que `currentMode` bascule correctement entre `localFirst` et `cloudFirst` (3 tests)
  - [x] T3.3 — Groupe `mode localFirst (non authentifié)` : `getAllLists` ne lit que le local, `saveList` écrit uniquement en local, `deleteList` opère uniquement en local (3 tests)
  - [x] T3.4 — Groupe `mode cloudFirst (authentifié)` : `getAllLists` fusionne local + cloud, `saveList` écrit local puis cloud, `deleteList` tente cloud puis local (3 tests)
  - [x] T3.5 — Groupe `gestion des erreurs duplicate` : `saveList` avec doublon en local → `updateList`, `saveList` avec doublon en cloud → `updateList` cloud (2 tests)
  - [x] T3.6 — Groupe `gestion des erreurs permission` : `saveItem` avec erreur 403 sur cloud → silencieux, `deleteItem` avec erreur permission cloud → silencieux (2 tests)
  - [x] T3.7 — Groupe `gestion des items` : `getItemsByListId` retourne items fusionnés en cloudFirst, `saveItem`/`updateItem`/`deleteItem` nominaux (4 tests)

- [x] **T4 — Validation finale** (AC: 5)
  - [x] T4.1 — `puro flutter test test/domain/services/core/consent_service_test.dart` → tous verts
  - [x] T4.2 — `puro flutter test test/domain/services/core/custom_list_service_test.dart` → tous verts
  - [x] T4.3 — `puro flutter test test/domain/services/persistence/adaptive_persistence_service_test.dart` → tous verts
  - [x] T4.4 — `puro flutter test --exclude-tags integration` → 0 régression vs baseline

### Review Findings

- [x] [Review][Decision] `_PermissionOnSaveListRepository` déclarée mais jamais utilisée → supprimée (dead code) [test/domain/services/persistence/adaptive_persistence_service_test.dart]
- [x] [Review][Patch] Merge même ID local+cloud non testé → 2 tests ajoutés (`getAllLists retient la version cloud`, `getItemsByListId retient la version cloud`) [test/domain/services/persistence/adaptive_persistence_service_test.dart]
- [x] [Review][Patch] Test duplicate-error état incohérent → `_DuplicateOnSaveListRepository` corrigé (throw seulement si clé existante) + pré-graine + assertion état final [test/domain/services/persistence/adaptive_persistence_service_test.dart]
- [x] [Review][Patch] `getStats` ne valide pas `averageProgress` → assertion `closeTo(0.25, 0.001)` ajoutée [test/domain/services/core/custom_list_service_test.dart]
- [x] [Review][Patch] `currentMode` toString fragile → déjà correct dans le vrai fichier (enum direct) — dismissed
- [x] [Review][Patch] Test cloud-duplicate manque `localList.saveCount` → assertion ajoutée [test/domain/services/persistence/adaptive_persistence_service_test.dart]
- [x] [Review][Defer] Test cross-instance SharedPreferences supprimé — couverture attendue dans `shared_preferences_consent_repository_test.dart` (adapter layer) [test/domain/services/core/consent_service_test.dart] — deferred, pre-existing
- [x] [Review][Defer] Date de consentement non couverte dans les tests domaine — adapter-layer concern [test/domain/services/core/consent_service_test.dart] — deferred, pre-existing
- [x] [Review][Defer] Fake updateList ignore silencieusement les IDs inconnus — comportement fake acceptable pour tester le service [test/domain/services/core/custom_list_service_test.dart] — deferred, pre-existing
- [x] [Review][Defer] Tests smoke composite ne couvrent pas updateList/deleteList au niveau composite — by design [test/domain/services/core/custom_list_service_test.dart] — deferred, pre-existing
- [x] [Review][Defer] deleteList ne vérifie pas l'absence réelle post-suppression — count assertions suffisantes en unit test [test/domain/services/persistence/adaptive_persistence_service_test.dart] — deferred, pre-existing
- [x] [Review][Defer] Chemins erreurs complexes items non testés (duplicate cloud, updateItem cloud permission avec item absent local, rethrow non-permission) [test/domain/services/persistence/adaptive_persistence_service_test.dart] — deferred, pre-existing
- [x] [Review][Defer] Opérations items en mode localFirst non testées [test/domain/services/persistence/adaptive_persistence_service_test.dart] — deferred, pre-existing

## Dev Notes

### Contexte et motivation

L'Epic 10 a migré les services domaine vers des ports (`IConsentRepository`, `IAuthService`, `ITaskRepository`, `CustomListRepository`, `ListItemRepository`). Story 10-8 valide cette migration par des tests qui prouvent que les services domaine sont testables en isolation totale — sans Supabase, sans Hive initialisé, sans SharedPreferences réels.

**État actuel des tests domaine :**

| Service | Tests existants | Manques |
|---------|----------------|---------|
| `ConsentService` | ✅ `consent_service_test.dart` — FakeConsentRepository, 8 tests | Propagation exceptions (deferred 10-5) |
| `CustomListCrudService` | ❌ Aucun | Tests CRUD complets |
| `CustomListSearchService` | ❌ Aucun | Tests filtrage + searchLists (logique interne) |
| `CustomListStatsService` | ❌ Aucun | Tests calcul getGlobalProgress + getStats |
| `CustomListService` (composite) | ❌ Aucun | Tests délégation |
| `AdaptivePersistenceService` | ❌ Aucun | Tests modes + gestion erreurs |
| `UnifiedPrioritizationService` | ✅ `unified_prioritization_service_test.dart` — Mockito `MockTaskRepository` | Tests déjà purs sans Supabase — hors scope cette story |

### Services concernés — imports clés

**`lib/domain/services/core/consent_service.dart`**
- Importe uniquement `package:prioris/domain/ports/consent_repository.dart`
- 3 méthodes déléguées : `hasAcceptedConsent()`, `acceptConsent()`, `revokeConsent()`
- Constante statique `consentContactEmail`

**`lib/domain/services/core/custom_list_service.dart`**
- Importe `package:prioris/domain/list/repositories/custom_list_repository.dart` (port domaine)
- 3 services spécialisés + 1 composite : `CustomListCrudService`, `CustomListSearchService`, `CustomListStatsService`, `CustomListService`
- `CustomListSearchService.searchLists()` a une logique interne (filtrage sur name + description) — c'est le principal cas à tester
- `CustomListStatsService` calcule `getGlobalProgress()` et `getStats()` — logique arithmétique interne

**`lib/domain/services/persistence/adaptive_persistence_service.dart`**
- Importe uniquement les ports domaine : `CustomListRepository`, `ListItemRepository`
- Logique : mode localFirst / cloudFirst, merge des listes, déduplication, gestion erreurs string-matching (`duplicate`, `exists`, `already`, `existe`, `déjà`, `403`, `permission`, `forbidden`)
- **Attention** : le switch `_shouldUseCloud()` dépend de `_isInitialized && _currentMode == cloudFirst` — appeler `initialize()` ou `updateAuthenticationState()` avant tout test de cloudFirst

### Pattern de fake recommandé pour les tests

**Fake inline pour `CustomListRepository`** (T2.1) — à déclarer dans le fichier test :
```dart
class _FakeCustomListRepository extends CustomListRepository {
  final _lists = <String, CustomList>{};

  @override Future<List<CustomList>> getAllLists() async => _lists.values.toList();
  @override Future<CustomList?> getListById(String id) async => _lists[id];
  @override Future<void> saveList(CustomList list) async => _lists[list.id] = list;
  @override Future<void> updateList(CustomList list) async { if (_lists.containsKey(list.id)) _lists[list.id] = list; }
  @override Future<void> deleteList(String id) async => _lists.remove(id);
  @override Future<void> clearAllLists() async => _lists.clear();
  @override Future<List<CustomList>> getListsByType(ListType type) async => _lists.values.where((l) => l.type == type).toList();
  @override Future<List<CustomList>> searchListsByName(String q) async => _lists.values.where((l) => l.name.toLowerCase().contains(q.toLowerCase())).toList();
  @override Future<List<CustomList>> searchListsByDescription(String q) async => _lists.values.where((l) => l.description?.toLowerCase().contains(q.toLowerCase()) ?? false).toList();
}
```
Ce fake ne valide pas les doublons (contrairement à `InMemoryCustomListRepository`) — il teste le comportement DU SERVICE, pas du repository.

**Fake inline pour `ListItemRepository`** (T3.1) :
```dart
class _FakeListItemRepository implements ListItemRepository {
  final _items = <String, ListItem>{};

  @override Future<List<ListItem>> getAll() async => _items.values.toList();
  @override Future<ListItem?> getById(String id) async => _items[id];
  @override Future<ListItem> add(ListItem item) async {
    if (_items.containsKey(item.id)) throw Exception('duplicate');
    _items[item.id] = item;
    return item;
  }
  @override Future<ListItem> update(ListItem item) async {
    _items[item.id] = item;
    return item;
  }
  @override Future<void> delete(String id) async => _items.remove(id);
  @override Future<List<ListItem>> getByListId(String listId) async =>
      _items.values.where((i) => i.listId == listId).toList();
}
```

**Fake pour AdaptivePersistenceService (T3 : tester duplicate/cloud)**

Pour tester le chemin duplicate + cloudRepository, créer un `_ThrowingCustomListRepository` qui lève une exception avec la string "duplicate" ou "403 permission" selon le besoin du test. Exemple :
```dart
class _DuplicateCustomListRepository extends _FakeCustomListRepository {
  @override
  Future<void> saveList(CustomList list) => throw Exception('duplicate entry');
}
class _PermissionCustomListRepository extends _FakeCustomListRepository {
  @override
  Future<void> saveList(CustomList list) => throw Exception('403 forbidden');
}
```

### Cas limites importants pour `CustomListStatsService`

```dart
// Cas 1 : listes vides → 0.0
service.getGlobalProgress() → 0.0

// Cas 2 : liste avec 0 items → 0.0 (éviter division par zéro)
list.itemCount == 0 → 0.0

// Cas 3 : calcul correct
// 2 listes : list1 (3 items, 1 completedCount), list2 (7 items, 3 completedCount)
// getGlobalProgress() → 4/10 = 0.4
```

Attention : `getGlobalProgress()` utilise `l.itemCount` et `l.completedCount` qui sont des propriétés calculées sur `CustomList`. Créer les instances `CustomList` avec des `items` appropriés pour que ces propriétés retournent les valeurs attendues. Vérifier la définition de `itemCount` et `completedCount` dans `CustomList`.

### Création d'instances CustomList dans les tests

`CustomList extends HiveObject` mais les instances se créent sans initialiser Hive (confirmé par les tests existants `custom_list_repository_test.dart`). Patron minimal :
```dart
final list = CustomList(
  id: 'test-id',
  name: 'Ma liste',
  type: ListType.TODO,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);
```

De même, `ListItem extends HiveObject` : instances créables directement (confirmé par `unified_prioritization_service_test.dart`).

### Règle de dépendance dans les fichiers de test

Les tests peuvent importer depuis n'importe quelle couche (ils sont dans `test/`, pas dans `lib/domain/`). La contrainte hexagonale s'applique uniquement aux fichiers dans `lib/domain/`, `lib/application/`, etc.

Cependant, pour cette story, les fakes sont déclarés inline dans les tests (pattern utilisé dans `consent_service_test.dart`) — ils n'importent PAS depuis `lib/data/`. C'est intentionnel : on teste le comportement du service domain avec un double de test minimal, pas avec l'implémentation data.

### Fichiers de test existants à NE PAS modifier (sauf T1)

- `test/domain/task/services/unified_prioritization_service_test.dart` — déjà pur sans Supabase, hors scope
- `test/domain/task/services/unified_prioritization_service_elo_test.dart` — idem
- `test/domain/list/repositories/custom_list_repository_contract_test.dart` — contrat repository, hors scope

### Baseline tests au démarrage de la story

```
puro flutter test --exclude-tags integration
→ 2046 pass, 26 skip, 1 flaky pré-existant (ListsTransactionManager rollback)
```

La régression est acceptable uniquement si le flaky pré-existant apparaît. Tout autre test rouge est un bloquant.

### Commandes utiles

```bash
# Lancer uniquement les nouveaux tests
puro flutter test test/domain/services/core/consent_service_test.dart
puro flutter test test/domain/services/core/custom_list_service_test.dart
puro flutter test test/domain/services/persistence/adaptive_persistence_service_test.dart

# Suite complète (validation finale)
puro flutter test --exclude-tags integration

# Vérifier que les services domaine n'importent rien d'infra
grep -r "import.*supabase\|import.*hive\|import.*shared_preferences" lib/domain/
```

### Project Structure Notes

**Fichiers créés :**
- `test/domain/services/core/custom_list_service_test.dart` — nouveau
- `test/domain/services/persistence/adaptive_persistence_service_test.dart` — nouveau (dossier `test/domain/services/persistence/` à créer si absent)

**Fichiers modifiés :**
- `test/domain/services/core/consent_service_test.dart` — ajout groupe exception propagation
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — statut story → done

**Fichiers NON modifiés :**
- Aucun fichier de production (`lib/`) n'est modifié — c'est une story de tests uniquement

### References

- Epic source : `_bmad-output/planning-artifacts/epic-10.md` — Story 10.5 (correspondance sprint-key 10-8)
- Services à tester : `lib/domain/services/core/consent_service.dart`, `lib/domain/services/core/custom_list_service.dart`, `lib/domain/services/persistence/adaptive_persistence_service.dart`
- Ports utilisés : `lib/domain/ports/consent_repository.dart`, `lib/domain/list/repositories/custom_list_repository.dart`, `lib/domain/list/repositories/list_item_repository.dart`
- Test de référence (pattern fake) : `test/domain/services/core/consent_service_test.dart`
- Interfaces service list : `lib/domain/services/core/interfaces/list_service_interface.dart`
- Entités : `lib/domain/models/core/entities/custom_list.dart`, `lib/domain/models/core/entities/list_item.dart`
- Deferred item relatif : deferred-work.md → "FakeConsentRepository sans simulation d'exceptions" (review 10-5)
- ADR hexagonal : `docs/ADR/ADR-001-hexagonal.md`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] T1 : `consent_service_test.dart` enrichi — `_ThrowingConsentRepository` inline + groupe exception propagation (3 tests). Résultat : 10 tests verts.
- [x] T2 : `custom_list_service_test.dart` créé — `_FakeCustomListRepository` inline (sans validation doublons), CrudService (6 tests), SearchService (4 tests), StatsService (5 tests), CustomListService composite (3 tests). Résultat : 18 tests verts.
- [x] T3 : `adaptive_persistence_service_test.dart` créé — fakes avec compteurs (`saveCount`, `updateCount`, `deleteCount`), initialize (3), localFirst (3), cloudFirst (3), duplicate (2), permission (2), items (4). Résultat : 17 tests verts.
- [x] T4 : `puro flutter test --exclude-tags integration` → 2084 pass (+38 nouveaux), 26 skip, 1 flaky pré-existant `ListsTransactionManager`. Zéro régression.
- [x] sprint-status mis à jour à `review` pour cette story (2026-05-17)

### File List

**Créés :**
- `test/domain/services/core/custom_list_service_test.dart`
- `test/domain/services/persistence/adaptive_persistence_service_test.dart`

**Modifiés :**
- `test/domain/services/core/consent_service_test.dart`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

## Change Log

- 2026-05-17 : Story implémentée — 3 fichiers de test ajoutés/modifiés, 38 nouveaux tests verts, zéro régression vs baseline 2046/26/1flaky. Status → review.
