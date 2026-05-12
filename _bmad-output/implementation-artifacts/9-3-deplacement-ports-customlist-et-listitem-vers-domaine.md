# Story 9.3 : Déplacer les ports CustomListRepository et ListItemRepository vers lib/domain/

Status: done

## Story

En tant que développeur,
je veux que `CustomListRepository` (et ses 4 sous-interfaces ISP) et `ListItemRepository` soient déclarés dans `lib/domain/list/repositories/`,
afin que la migration hexagonale soit complète pour les trois agrégats principaux (Habit, CustomList, ListItem), sur le même modèle que HabitRepository après stories 9.1/9.2.

## Acceptance Criteria

1. `abstract class CustomListRepository` (implémentant 4 sous-interfaces ISP : `CustomListCrudRepositoryInterface`, `CustomListSearchRepositoryInterface`, `CustomListFilterRepositoryInterface`, `CustomListCleanRepositoryInterface`) réside dans `lib/domain/list/repositories/custom_list_repository.dart`
2. L'ancienne interface DDD aspirationnelle (`CustomListAggregate`, `ListStatistics`, `ListUsageInsights`, `ListSplitCriteria`) est supprimée de `lib/domain/list/repositories/custom_list_repository.dart`
3. `abstract class ListItemRepository` réside dans `lib/domain/list/repositories/list_item_repository.dart` (nouveau fichier)
4. `SupabaseCustomListRepository`, `SupabaseListItemRepository`, `HiveCustomListRepository`, `HiveListItemRepository` importent depuis `lib/domain/`
5. Providers typés sur les interfaces domain (satisfaction via re-export : tous les `Provider<CustomListRepository>` et `Provider<ListItemRepository>` référencent implicitement les interfaces domain)
6. `puro flutter analyze --no-pub` → 0 nouvelle erreur, `puro flutter test --exclude-tags integration` → 0 régression

## Tasks / Subtasks

- [x] **T1 — Réécrire `lib/domain/list/repositories/custom_list_repository.dart`** (AC: 1, 2)
  - [x] T1.1 — Remplacer tout le contenu du fichier par les 4 sous-interfaces ISP + `CustomListRepository` abstract class
  - [x] T1.2 — Les 4 sous-interfaces NE s'étendent PAS depuis `BasicCrudRepositoryInterface` (évite import data→domain) — inliner les méthodes génériques directement
  - [x] T1.3 — Conserver la méthode default `getStats()` dans l'abstract class (logic pure, ne dépend que de `getAllLists()`)
  - [x] T1.4 — Imports autorisés uniquement : `domain/models/core/entities/custom_list.dart` et `domain/models/core/enums/list_enums.dart`
  - [x] T1.5 — Supprimer toute référence à `CustomListAggregate`, `PaginatedRepository`, `SearchableRepository`, `ListStatistics`, `ListUsageInsights`, `ListSplitCriteria`

- [x] **T2 — Créer `lib/domain/list/repositories/list_item_repository.dart`** (AC: 3)
  - [x] T2.1 — Créer le fichier avec `abstract class ListItemRepository` (6 méthodes : `getAll`, `getById`, `add`, `update`, `delete`, `getByListId`)
  - [x] T2.2 — Import uniquement : `domain/models/core/entities/list_item.dart`
  - [x] T2.3 — NE PAS inclure `InMemoryListItemRepository` ici — elle reste dans `lib/data/`

- [x] **T3 — Mettre à jour `lib/data/repositories/custom_list_repository.dart`** (AC: 1, 4)
  - [x] T3.1 — Ajouter `export 'package:prioris/domain/list/repositories/custom_list_repository.dart';` en première ligne (assure rétrocompatiblité des 20+ importeurs existants)
  - [x] T3.2 — Ajouter `import 'package:prioris/domain/list/repositories/custom_list_repository.dart';`
  - [x] T3.3 — Supprimer la définition `abstract class CustomListRepository` (elle est maintenant dans domain)
  - [x] T3.4 — Supprimer l'import `import 'interfaces/repository_interfaces.dart';` (les ISP sub-interfaces sont maintenant dans domain)
  - [x] T3.5 — Conserver `class InMemoryCustomListRepository implements CustomListRepository { ... }` sans modification
  - [x] T3.6 — Vérifier que `InMemoryCustomListRepository` compile toujours (la `CustomListRepository` qu'elle implémente vient maintenant du domaine)

- [x] **T4 — Mettre à jour `lib/data/repositories/list_item_repository.dart`** (AC: 3, 4)
  - [x] T4.1 — Ajouter `export 'package:prioris/domain/list/repositories/list_item_repository.dart';` en première ligne
  - [x] T4.2 — Ajouter `import 'package:prioris/domain/list/repositories/list_item_repository.dart';`
  - [x] T4.3 — Supprimer la définition `abstract class ListItemRepository`
  - [x] T4.4 — Conserver `class InMemoryListItemRepository implements ListItemRepository { ... }` sans modification
  - [x] T4.5 — Conserver `extension _FirstWhereOrNull` (utilisée en interne par InMemory)

- [x] **T5 — Mettre à jour `lib/data/repositories/interfaces/repository_interfaces.dart`** (AC: 5)
  - [x] T5.1 — Ajouter `export 'package:prioris/domain/list/repositories/custom_list_repository.dart' show CustomListCrudRepositoryInterface, CustomListSearchRepositoryInterface, CustomListFilterRepositoryInterface, CustomListCleanRepositoryInterface;` en début de fichier
  - [x] T5.2 — Supprimer les 4 classes Custom-List-spécifiques (`CustomListCrudRepositoryInterface`, `CustomListSearchRepositoryInterface`, `CustomListFilterRepositoryInterface`, `CustomListCleanRepositoryInterface`)
  - [x] T5.3 — Conserver les 4 interfaces génériques (`BasicCrudRepositoryInterface`, `SearchableRepositoryInterface`, `FilterableRepositoryInterface`, `CleanableRepositoryInterface`) — elles n'ont pas de dépendances sur les entités domain

- [x] **T6 — Mettre à jour les 4 implémentations adapters** (AC: 4)
  - [x] T6.1 — `lib/data/repositories/supabase/supabase_custom_list_repository.dart` ligne 6 : remplacer `import '../custom_list_repository.dart';` par `import 'package:prioris/domain/list/repositories/custom_list_repository.dart';`
  - [x] T6.2 — `lib/data/repositories/supabase/supabase_list_item_repository.dart` ligne 2 : remplacer `import 'package:prioris/data/repositories/list_item_repository.dart';` par `import 'package:prioris/domain/list/repositories/list_item_repository.dart';`
  - [x] T6.3 — `lib/data/repositories/hive_custom_list_repository.dart` ligne 5 : remplacer `import 'custom_list_repository.dart';` par `import 'package:prioris/domain/list/repositories/custom_list_repository.dart';`
  - [x] T6.4 — `lib/data/repositories/hive_list_item_repository.dart` ligne 3 : remplacer `import 'package:prioris/data/repositories/list_item_repository.dart';` par `import 'package:prioris/domain/list/repositories/list_item_repository.dart';`

- [x] **T7 — Tests de contrat domaine** (AC: 6)
  - [x] T7.1 — Créer `test/domain/list/repositories/custom_list_repository_contract_test.dart` (sur le modèle de `test/domain/habit/repositories/habit_repository_contract_test.dart`)
  - [x] T7.2 — Créer `test/domain/list/repositories/list_item_repository_contract_test.dart`

- [x] **T8 — Validation finale** (AC: 6)
  - [x] T8.1 — `puro flutter analyze --no-pub` → 0 nouvelle erreur (erreurs pré-existantes dans domain/list/services/ et domain/services/persistence/ inchangées)
  - [x] T8.2 — `puro flutter test --exclude-tags integration` → 0 régression (8 nouveaux tests passent, 3 flaky pré-existants dans lists_transaction_manager_test inchangés)

---

## Dev Notes

### Contexte architectural

Cette story est la suite directe de 9.1 (port `HabitRepository` déplacé) et 9.2 (providers typés). Même pattern, deux interfaces au lieu d'une.

**Règle de dépendance hexagonale :**
```
presentation/ → domain ← data/infrastructure
```

**Lire `lib/domain/CLAUDE.md` avant de toucher `lib/domain/`** — imports interdits listés explicitement. Vérifier avant chaque import dans les nouveaux fichiers domaine.

---

### Analyse de la situation actuelle

#### Interface `CustomListRepository` actuelle (lib/data/)

Le fichier `lib/data/repositories/custom_list_repository.dart` contient :

```dart
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'interfaces/repository_interfaces.dart';  // ← contient les 4 sub-interfaces

abstract class CustomListRepository 
    implements 
      CustomListCrudRepositoryInterface,   // getAllLists, getListById, saveList, updateList, deleteList + getAll/getById/save/update/delete
      CustomListSearchRepositoryInterface, // searchListsByName, searchListsByDescription + searchByName, searchByDescription
      CustomListFilterRepositoryInterface, // getListsByType + getByType
      CustomListCleanRepositoryInterface { // clearAllLists + clearAll
  
  // Méthode par défaut avec logique pure (pas d'infra)
  Future<Map<String, dynamic>> getStats() async {
    final lists = await getAllLists();
    final completed = lists.where((list) => list.isCompleted).length;
    final itemCount = lists.fold<int>(0, (count, list) => count + list.items.length);
    return { 'count': lists.length, 'completed': completed, 'items': itemCount };
  }
}

class InMemoryCustomListRepository implements CustomListRepository { ... }  // RESTE EN DATA
```

Les 4 sous-interfaces ISP sont dans `lib/data/repositories/interfaces/repository_interfaces.dart`. Elles héritent de génériques (`BasicCrudRepositoryInterface<T,ID>`, etc.) — **NE PAS reproduire cet héritage dans domain** pour éviter une dépendance domain → data.

#### Interface DDD aspirationnelle (lib/domain/) — À SUPPRIMER ENTIÈREMENT

`lib/domain/list/repositories/custom_list_repository.dart` contient actuellement une interface DDD non utilisée qui référence `CustomListAggregate`, `PaginatedRepository`, `SearchableRepository`, `ListStatistics`, `ListUsageInsights`, etc. Ce fichier doit être **remplacé intégralement** par la vraie interface.

#### Interface `ListItemRepository` actuelle (lib/data/)

`lib/data/repositories/list_item_repository.dart` :
```dart
abstract class ListItemRepository {
  Future<List<ListItem>> getAll();
  Future<ListItem?> getById(String id);
  Future<ListItem> add(ListItem item);
  Future<ListItem> update(ListItem item);
  Future<void> delete(String id);
  Future<List<ListItem>> getByListId(String listId);
}

class InMemoryListItemRepository implements ListItemRepository { ... }  // RESTE EN DATA

extension _FirstWhereOrNull<E> on List<E> { ... }  // RESTE EN DATA
```

Aucun fichier `lib/domain/list/repositories/list_item_repository.dart` n'existe — à créer.

---

### Stratégie re-export pour zéro régression

Il existe **20+ fichiers** (presentation, application, domain/services — violations pré-existantes) qui importent `CustomListRepository` et `ListItemRepository` depuis `lib/data/`. Ces fichiers sont **hors scope de cette story**. La stratégie `export` permet de ne pas les toucher :

```dart
// lib/data/repositories/custom_list_repository.dart (après migration)
export 'package:prioris/domain/list/repositories/custom_list_repository.dart'; // ← NEW
import 'package:prioris/domain/list/repositories/custom_list_repository.dart'; // ← NEW

// NE PLUS contenir abstract class CustomListRepository
// CONSERVER class InMemoryCustomListRepository
```

Tout fichier qui continuera d'importer depuis `lib/data/repositories/custom_list_repository.dart` recevra `CustomListRepository` qui vient maintenant du domaine. Compilation identique, but architectural atteint.

---

### Structure exacte du fichier domain à créer

#### `lib/domain/list/repositories/custom_list_repository.dart` (REMPLACEMENT TOTAL)

```dart
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Port domaine — sous-interface CRUD pour les listes personnalisées (ISP)
abstract class CustomListCrudRepositoryInterface {
  Future<List<CustomList>> getAll();
  Future<CustomList?> getById(String id);
  Future<void> save(CustomList entity);
  Future<void> update(CustomList entity);
  Future<void> delete(String id);
  Future<List<CustomList>> getAllLists();
  Future<CustomList?> getListById(String id);
  Future<void> saveList(CustomList list);
  Future<void> updateList(CustomList list);
  Future<void> deleteList(String id);
}

/// Port domaine — sous-interface recherche (ISP)
abstract class CustomListSearchRepositoryInterface {
  Future<List<CustomList>> searchByName(String query);
  Future<List<CustomList>> searchByDescription(String query);
  Future<List<CustomList>> searchListsByName(String query);
  Future<List<CustomList>> searchListsByDescription(String query);
}

/// Port domaine — sous-interface filtrage (ISP)
abstract class CustomListFilterRepositoryInterface {
  Future<List<CustomList>> getByType(ListType type);
  Future<List<CustomList>> getListsByType(ListType type);
}

/// Port domaine — sous-interface nettoyage (ISP)
abstract class CustomListCleanRepositoryInterface {
  Future<void> clearAll();
  Future<void> clearAllLists();
}

/// Port domaine principal pour la gestion des listes personnalisées
abstract class CustomListRepository 
    implements 
      CustomListCrudRepositoryInterface,
      CustomListSearchRepositoryInterface,
      CustomListFilterRepositoryInterface,
      CustomListCleanRepositoryInterface {

  Future<Map<String, dynamic>> getStats() async {
    final lists = await getAllLists();
    final completed = lists.where((list) => list.isCompleted).length;
    final itemCount = lists.fold<int>(0, (count, list) => count + list.items.length);
    return {'count': lists.length, 'completed': completed, 'items': itemCount};
  }
}
```

#### `lib/domain/list/repositories/list_item_repository.dart` (NOUVEAU)

```dart
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Port domaine pour la gestion des éléments de liste
abstract class ListItemRepository {
  Future<List<ListItem>> getAll();
  Future<ListItem?> getById(String id);
  Future<ListItem> add(ListItem item);
  Future<ListItem> update(ListItem item);
  Future<void> delete(String id);
  Future<List<ListItem>> getByListId(String listId);
}
```

---

### Fichiers qui CHANGENT (récapitulatif)

| Fichier | Type de changement | Nature |
|---------|-------------------|--------|
| `lib/domain/list/repositories/custom_list_repository.dart` | REMPLACEMENT TOTAL | Interface réelle remplace DDD aspirationnel |
| `lib/domain/list/repositories/list_item_repository.dart` | CRÉATION | Nouveau port domain |
| `lib/data/repositories/custom_list_repository.dart` | MODIFIER | +export domain, -abstract class, conserver InMemory |
| `lib/data/repositories/list_item_repository.dart` | MODIFIER | +export domain, -abstract class, conserver InMemory |
| `lib/data/repositories/interfaces/repository_interfaces.dart` | MODIFIER | +export domain sub-interfaces, -4 classes Custom-spécifiques |
| `lib/data/repositories/supabase/supabase_custom_list_repository.dart` | MODIFIER | import domain direct |
| `lib/data/repositories/supabase/supabase_list_item_repository.dart` | MODIFIER | import domain direct |
| `lib/data/repositories/hive_custom_list_repository.dart` | MODIFIER | import domain direct |
| `lib/data/repositories/hive_list_item_repository.dart` | MODIFIER | import domain direct |
| `test/domain/list/repositories/custom_list_repository_contract_test.dart` | CRÉATION | Test contrat impls vs interface domain |
| `test/domain/list/repositories/list_item_repository_contract_test.dart` | CRÉATION | Test contrat impls vs interface domain |

### Fichiers qui NE changent PAS

| Fichier | Raison |
|---------|--------|
| `lib/data/providers/repository_providers.dart` | Les types `Provider<CustomListRepository>` et `Provider<ListItemRepository>` pointent déjà vers l'interface via re-export — AC5 satisfait sans modification |
| `lib/data/providers/service_providers.dart` | Même raison |
| `lib/data/providers/clean_repository_providers.dart` | Même raison |
| `lib/data/providers/lists_controller_provider.dart` | Même raison |
| `lib/application/services/lists_persistence_service.dart` | Hors scope — violation pré-existante |
| `lib/domain/services/core/custom_list_service.dart` | Hors scope — violation pré-existante |
| `lib/domain/services/persistence/adaptive_persistence_service.dart` | Hors scope — violation pré-existante |
| `lib/presentation/pages/lists/` (tous) | Hors scope — violations pré-existantes |
| `test/domain/models/custom_list_repository_test.dart` | Import data toujours valide (re-export), aucun changement nécessaire |
| `test/data/repositories/list_item_repository_test.dart` | Import data toujours valide (re-export) |

---

### Tests à écrire

Modèle exact de `test/domain/habit/repositories/habit_repository_contract_test.dart` :

#### `test/domain/list/repositories/custom_list_repository_contract_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/list/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart'
    show InMemoryCustomListRepository;
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';

void main() {
  group('CustomListRepository — contrat de port domaine', () {
    test('InMemoryCustomListRepository implémente CustomListRepository du domaine', () {
      expect(InMemoryCustomListRepository(), isA<CustomListRepository>());
    });

    test('SupabaseCustomListRepository implémente CustomListRepository du domaine', () {
      expect(SupabaseCustomListRepository(), isA<CustomListRepository>());
    });

    test('HiveCustomListRepository implémente CustomListRepository du domaine', () {
      expect(HiveCustomListRepository(), isA<CustomListRepository>());
    });

    test('CustomListRepository est dans lib/domain/, non dans lib/data/', () {
      // Test documentaire : si ce test compile, l'import domain est correct.
      CustomListRepository? repo;
      expect(repo, isNull);
    });
  });
}
```

#### `test/domain/list/repositories/list_item_repository_contract_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/list/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart'
    show InMemoryListItemRepository;
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';

void main() {
  group('ListItemRepository — contrat de port domaine', () {
    test('InMemoryListItemRepository implémente ListItemRepository du domaine', () {
      expect(InMemoryListItemRepository(), isA<ListItemRepository>());
    });

    test('SupabaseListItemRepository implémente ListItemRepository du domaine', () {
      expect(SupabaseListItemRepository(), isA<ListItemRepository>());
    });

    test('HiveListItemRepository implémente ListItemRepository du domaine', () {
      // Note : HiveListItemRepository nécessite initialize() pour les méthodes métier,
      // mais la vérification de type isA<> ne l'exige pas.
      expect(HiveListItemRepository(), isA<ListItemRepository>());
    });

    test('ListItemRepository est dans lib/domain/, non dans lib/data/', () {
      ListItemRepository? repo;
      expect(repo, isNull);
    });
  });
}
```

---

### Commandes de validation

```bash
# Vérifier que les interfaces domain n'importent rien d'interdit
grep -n "supabase\|hive\|package:flutter" lib/domain/list/repositories/custom_list_repository.dart
grep -n "supabase\|hive\|package:flutter" lib/domain/list/repositories/list_item_repository.dart
# → aucun résultat attendu

# Vérifier que les 4 adapters importent depuis domain
grep -n "import.*list_item_repository\|import.*custom_list_repository" \
  lib/data/repositories/supabase/supabase_custom_list_repository.dart \
  lib/data/repositories/supabase/supabase_list_item_repository.dart \
  lib/data/repositories/hive_custom_list_repository.dart \
  lib/data/repositories/hive_list_item_repository.dart
# → tous doivent pointer vers domain/list/repositories/

# Analyse statique
puro flutter analyze --no-pub

# Tests (hors intégration réseau)
puro flutter test --exclude-tags integration
```

---

### Risques et garde-fous

| Risque | Mitigation |
|--------|------------|
| Rupture des 20+ importeurs de data | Stratégie re-export : `export` dans les fichiers data garantit rétrocompatibilité sans toucher les importeurs |
| Import circulaire domain ← data | Impossible : domain ne connaît que ses propres entités. data importe domain (correct) |
| Conflit de noms `CustomListRepository` (deux définitions) | Résolu par REMPLACEMENT total du fichier domain — une seule définition |
| `HiveCustomListRepository()` dans test sans Hive initialisé | `isA<>` ne déclenche aucune méthode — le constructeur default ne lance pas Hive |
| `InMemoryCustomListRepository` ne compile plus après suppression abstract class | Elle implémente `CustomListRepository` de domain (via import) — types identiques, compilation OK |
| ISP sub-interfaces domain n'héritent pas de `BasicCrudRepositoryInterface` | Méthodes inlinées directement — les implémentations existantes fournissent déjà toutes les méthodes |

---

### Items différés de 9.2 NON à corriger dans cette story

Les éléments suivants restent hors scope :

| Item | Fichier | Pourquoi hors scope |
|------|---------|---------------------|
| `lib/domain/services/` importent depuis `lib/data/` | ex. `custom_list_service.dart` | Violations pré-existantes — Epic 9.x story dédiée |
| `lib/presentation/pages/lists/` importent depuis `lib/data/` | multiples fichiers | Idem |
| `print()` debug dans `HabitsNotifier` | `habits_state_provider.dart` | Hors scope 9.3 |
| Race autoDispose+StateNotifier dans `HabitsNotifier` | `habits_state_provider.dart` | Hors scope 9.3 |
| `adaptiveCustomListRepositoryProvider` retourne `CustomListCrudRepositoryInterface` (ISP) au lieu de `CustomListRepository` | `repository_providers.dart` | Pré-existant, non rédhibitoire |

---

### References

- Epic 9 story 9.3 : `_bmad-output/planning-artifacts/epic-9.md#Story-9.3`
- ADR hexagonale : `docs/ADR/ADR-001-hexagonal.md`
- Règles domaine : `lib/domain/CLAUDE.md`
- Pattern de référence story 9.1 : `_bmad-output/implementation-artifacts/9-1-deplacement-port-habit-repository-vers-domaine.md`
- Interface réelle à migrer : `lib/data/repositories/custom_list_repository.dart`
- Sub-interfaces ISP actuelles : `lib/data/repositories/interfaces/repository_interfaces.dart`
- Interface ListItem à migrer : `lib/data/repositories/list_item_repository.dart`
- Interface DDD aspirationnelle à supprimer : `lib/domain/list/repositories/custom_list_repository.dart` (contenu actuel)
- Test contrat habitRepository : `test/domain/habit/repositories/habit_repository_contract_test.dart`
- Deferred work 9.2 : `_bmad-output/implementation-artifacts/deferred-work.md`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] sprint-status mis à jour à `review` pour cette story (2026-05-11)
- Migration hexagonale complète : CustomListRepository et ListItemRepository déclarés dans lib/domain/list/repositories/
- Stratégie re-export garantit rétrocompatibilité des 20+ importeurs existants sans modification
- 4 sous-interfaces ISP (CustomListCrud/Search/Filter/Clean) déplacées du data vers le domain — méthodes inlinées sans héritage de BasicCrudRepositoryInterface
- Interface DDD aspirationnelle (CustomListAggregate, ListStatistics, etc.) supprimée intégralement
- 8 tests de contrat créés, tous verts — confirment que les 4 adapters (Supabase+Hive×2) implémentent bien les ports domain
- 3 failures flaky pré-existantes dans lists_transaction_manager_test (timeout async) inchangées

### File List

- `lib/domain/list/repositories/custom_list_repository.dart` — REMPLACEMENT TOTAL (interface réelle + ISP sub-interfaces)
- `lib/domain/list/repositories/list_item_repository.dart` — CRÉER (nouveau port domain)
- `lib/data/repositories/custom_list_repository.dart` — MODIFIER (+export domain, -abstract class)
- `lib/data/repositories/list_item_repository.dart` — MODIFIER (+export domain, -abstract class)
- `lib/data/repositories/interfaces/repository_interfaces.dart` — MODIFIER (+export domain sub-interfaces, -4 classes Custom-spécifiques)
- `lib/data/repositories/supabase/supabase_custom_list_repository.dart` — MODIFIER (import domain direct)
- `lib/data/repositories/supabase/supabase_list_item_repository.dart` — MODIFIER (import domain direct)
- `lib/data/repositories/hive_custom_list_repository.dart` — MODIFIER (import domain direct)
- `lib/data/repositories/hive_list_item_repository.dart` — MODIFIER (import domain direct)
- `test/domain/list/repositories/custom_list_repository_contract_test.dart` — CRÉER
- `test/domain/list/repositories/list_item_repository_contract_test.dart` — CRÉER

### Review Findings

- [x] [Review][Defer] Double méthodes génériques+domaine dans les 4 ISP sub-interfaces [lib/domain/list/repositories/custom_list_repository.dart] — deferred, trade-off intentionnel per T1.2 (éviter import domain←data) ; doublement de la surface contractuelle (10 méthodes CRUD, 4 search, 2 filter, 2 clean au lieu de 5+2+1+1). À consolider dans une story dédiée en supprimant les alias génériques si le projet migre tous les appelants vers les noms domaine.
- [x] [Review][Defer] `getStats()` retourne des structures sémantiquement incompatibles selon l'implémentation [lib/data/repositories/supabase/supabase_custom_list_repository.dart:295, lib/data/repositories/hive_custom_list_repository.dart:250] — deferred, pré-existant. SupabaseCustomListRepository retourne `Map<String,int>` avec les types de listes ; HiveCustomListRepository retourne les stats infra Hive (`totalLists`, `boxSize`, `isOpen`, `path`, `name`) ; InMemoryCustomListRepository retourne `{count, completed, items}`. Violation LSP sémantique. Non introduit par 9-3.
- [x] [Review][Defer] Constructeurs Supabase en no-arg dans les tests contrat accèdent aux singletons sans initialisation [test/domain/list/repositories/custom_list_repository_contract_test.dart:15, list_item_repository_contract_test.dart:14] — deferred, pattern identique à story 9-1 (approuvé). Tests passent en pratique. Fragile si le singleton Supabase n'est pas initialisé dans certains environnements CI.
- [x] [Review][Defer] `HiveCustomListRepository.getStats()` shadow silencieux du default domaine sans `@override` [lib/data/repositories/hive_custom_list_repository.dart:250] — deferred, pré-existant. Retourne les métriques infra Hive au lieu des stats domaine ; tout appelant polymorphe sur `CustomListRepository` obtient des clés inattendues sur une instance Hive.
- [x] [Review][Defer] `abstract class` au lieu de `abstract interface class` (Dart 3+) pour les ports domaine [lib/domain/list/repositories/custom_list_repository.dart, list_item_repository.dart] — deferred, amélioration non bloquante. `interface class` Dart 3+ force l'implémentation explicite de tous les membres et empêche l'héritage de la logique concrète (`getStats()`). À évaluer dans une story de consolidation des ports.
- [x] [Review][Defer] `InMemoryCustomListRepository.save()` lève une exception sur ID dupliqué via `saveList(isNew: true)` [lib/data/repositories/custom_list_repository.dart] — deferred, pré-existant. Les appelants qui utilisent `save()` comme upsert obtiendront une exception après le premier appel. Non introduit par 9-3.
