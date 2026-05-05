# Story 9.1 : Déplacer le port HabitRepository vers lib/domain/ (consolider doublon)

Status: ready-for-dev

## Story

En tant que développeur,
je veux que l'interface `HabitRepository` soit déclarée dans `lib/domain/habit/repositories/` et non dans `lib/data/repositories/`,
afin que le domaine soit hermétique et que `SupabaseHabitRepository` dépende du domaine, jamais l'inverse.

## Acceptance Criteria

1. `abstract class HabitRepository` (7 méthodes : `getAllHabits`, `saveHabit`, `addHabit`, `updateHabit`, `deleteHabit`, `getHabitsByCategory`, `clearAllHabits`) réside dans `lib/domain/habit/repositories/habit_repository.dart`
2. L'ancienne interface DDD (`HabitAggregate`, `HabitStatistics`, `HabitTrend`, `TrendDirection`, `HabitRepositoryExtensions`) est supprimée de `lib/domain/habit/repositories/habit_repository.dart`
3. `SupabaseHabitRepository` importe `HabitRepository` depuis `package:prioris/domain/habit/repositories/habit_repository.dart` (pas `lib/data/`)
4. `InMemoryHabitRepository` (dans `lib/data/repositories/habit_repository.dart`) importe `HabitRepository` depuis `package:prioris/domain/habit/repositories/habit_repository.dart`
5. `puro flutter analyze --no-pub` → 0 nouvelle erreur introduite
6. `puro flutter test --exclude-tags integration` → 0 régression sur les tests pré-existants
7. Aucun import `supabase_flutter`, `hive`, ou `package:flutter` (sauf `package:flutter/foundation.dart` si strictement nécessaire) dans `lib/domain/habit/repositories/habit_repository.dart`

## Tasks / Subtasks

- [ ] **T1 — Remplacer le contenu de `lib/domain/habit/repositories/habit_repository.dart`** (AC: 1, 2, 7)
  - [ ] T1.1 — Supprimer toute la classe DDD existante (HabitAggregate, HabitStatistics, HabitTrend, TrendDirection, HabitRepositoryExtensions, PaginatedRepository, SearchableRepository)
  - [ ] T1.2 — Écrire la nouvelle interface simple : `abstract class HabitRepository` avec les 7 méthodes (voir Dev Notes)
  - [ ] T1.3 — Vérifier : aucun import hive/supabase/flutter dans ce fichier

- [ ] **T2 — Mettre à jour `lib/data/repositories/supabase/supabase_habit_repository.dart`** (AC: 3)
  - [ ] T2.1 — Remplacer `import '../habit_repository.dart'` par `import 'package:prioris/domain/habit/repositories/habit_repository.dart'`
  - [ ] T2.2 — S'assurer que `class SupabaseHabitRepository implements HabitRepository` compile

- [ ] **T3 — Mettre à jour `lib/data/repositories/habit_repository.dart`** (AC: 4)
  - [ ] T3.1 — Supprimer `abstract class HabitRepository { ... }` (les 7 méthodes)
  - [ ] T3.2 — Ajouter `import 'package:prioris/domain/habit/repositories/habit_repository.dart'`
  - [ ] T3.3 — S'assurer que `InMemoryHabitRepository implements HabitRepository` compile
  - [ ] T3.4 — Les providers (`habitRepositoryProvider`, `allHabitsProvider`, `habitsWithStatsProvider`) restent dans ce fichier sans modification

- [ ] **T4 — Vérifier les fichiers qui importent HabitRepository** (AC: 5)
  - [ ] T4.1 — `lib/data/providers/habits_state_provider.dart` : toujours OK car importe `habit_repository.dart` pour les providers (pas pour le type)
  - [ ] T4.2 — `lib/presentation/pages/statistics_page.dart` : importe pour `habitRepositoryProvider` → aucun changement nécessaire
  - [ ] T4.3 — `lib/presentation/widgets/dialogs/add_habit_dialog.dart` : idem → aucun changement nécessaire
  - [ ] T4.4 — `lib/core/interfaces/repository_interfaces.dart` : ne référence pas `HabitRepository` → vérifier, aucun changement attendu

- [ ] **T5 — Vérifier les tests** (AC: 6)
  - [ ] T5.1 — `test/data/providers/habits_state_provider_test.dart` : vérifie que les imports compilent
  - [ ] T5.2 — `test/integration/auth_flow_integration_test.dart` : vérifie que les imports compilent
  - [ ] T5.3 — `test/presentation/pages/home_page_test.dart` : vérifie que les imports compilent
  - [ ] T5.4 — Écrire un test unitaire `test/domain/habit/repositories/habit_repository_contract_test.dart` (voir Dev Notes)

- [ ] **T6 — Validation finale** (AC: 5, 6)
  - [ ] T6.1 — `puro flutter analyze --no-pub` → 0 nouvelle erreur
  - [ ] T6.2 — `puro flutter test --exclude-tags integration` → 0 régression

---

## Dev Notes

### Contexte architectural

Cette story implémente l'étape 9.2 de l'ADR-001 (`docs/ADR/ADR-001-hexagonal.md`).

**Règle de dépendance hexagonale :**
```
presentation/ → domain ← data/infrastructure
```
Le domaine ne dépend de rien. `data/` dépend du domaine.

**Lire `lib/domain/CLAUDE.md` avant de toucher `lib/domain/`** — imports interdits listés explicitement.

---

### Fichiers à modifier

| Action | Fichier | Ce qui change |
|--------|---------|---------------|
| REMPLACER contenu | `lib/domain/habit/repositories/habit_repository.dart` | Interface DDD → interface réelle 7 méthodes |
| MODIFIER | `lib/data/repositories/habit_repository.dart` | Supprimer abstract class, ajouter import domain |
| MODIFIER | `lib/data/repositories/supabase/supabase_habit_repository.dart` | Changer import vers domain |
| CRÉER | `test/domain/habit/repositories/habit_repository_contract_test.dart` | Test contrat interface |

**Fichiers qui NE changent PAS** (ils importent `lib/data/repositories/habit_repository.dart` pour les providers, pas pour le type) :
- `lib/data/providers/habits_state_provider.dart`
- `lib/presentation/pages/statistics_page.dart`
- `lib/presentation/widgets/dialogs/add_habit_dialog.dart`
- `test/data/providers/habits_state_provider_test.dart`
- `test/integration/auth_flow_integration_test.dart`
- `test/presentation/pages/home_page_test.dart`

---

### Contenu attendu pour `lib/domain/habit/repositories/habit_repository.dart`

```dart
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Port de persistance pour les habitudes.
/// 
/// Déclaré dans le domaine — implémenté dans lib/data/ (Supabase, InMemory).
/// Règle : aucun import hive / supabase_flutter / flutter dans ce fichier.
abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<void> saveHabit(Habit habit);
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String habitId);
  Future<List<Habit>> getHabitsByCategory(String category);
  Future<void> clearAllHabits();
}
```

> **Ne pas ajouter** de méthodes supplémentaires (pas de `getStatistics`, `findByType`, etc.) — cela appartient à story 9.2+ ou Epic 10. Respecter le principe YAGNI.

---

### État actuel de `lib/data/repositories/habit_repository.dart` (avant modification)

Le fichier contient trois blocs :
1. `abstract class HabitRepository` (7 méthodes) → **À SUPPRIMER** (déplacé dans domain/)
2. `class InMemoryHabitRepository implements HabitRepository` → **À GARDER**, ajuster l'import
3. Providers Riverpod (`habitRepositoryProvider`, `allHabitsProvider`, `habitsWithStatsProvider`) → **À GARDER**, aucune modification

Après modification, le fichier aura ce début :
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/habit/repositories/habit_repository.dart'; // ← ajouté
import 'package:prioris/data/repositories/supabase/supabase_habit_repository.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
// ... suite inchangée
```

---

### Doublon existant dans lib/domain/ — À supprimer entièrement

`lib/domain/habit/repositories/habit_repository.dart` contient actuellement (code mort) :
- `abstract class HabitRepository extends PaginatedRepository<HabitAggregate>` — **supprimer**
- `class HabitStatistics` — **supprimer**
- `class HabitTrend` — **supprimer**
- `enum TrendDirection` — **supprimer**
- `extension HabitRepositoryExtensions on HabitRepository` — **supprimer**

Aucun fichier dans `lib/` n'importe depuis `lib/domain/habit/repositories/habit_repository.dart` (vérifié par grep). Le remplacement est donc sans risque de régression import.

---

### Test à écrire : `test/domain/habit/repositories/habit_repository_contract_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/habit/repositories/habit_repository.dart';
import 'package:prioris/data/repositories/habit_repository.dart'
    show InMemoryHabitRepository;
import 'package:prioris/data/repositories/supabase/supabase_habit_repository.dart';

void main() {
  group('HabitRepository — contrat de port domaine', () {
    test('InMemoryHabitRepository implémente HabitRepository du domaine', () {
      // Vérifie que l'adapter test implémente bien le port domain
      expect(InMemoryHabitRepository(), isA<HabitRepository>());
    });

    test('SupabaseHabitRepository implémente HabitRepository du domaine', () {
      // Vérifie que l'adapter Supabase implémente bien le port domain
      expect(SupabaseHabitRepository(), isA<HabitRepository>());
    });

    test('HabitRepository est dans lib/domain/, non dans lib/data/', () {
      // Test documentaire : garantit que quiconque lit ce test sait où est le port
      // Vérification statique : si ce test compile, l'import domain est correct
      HabitRepository? repo;
      expect(repo, isNull); // trivial — valeur du test = import qui compile
    });
  });

  group('InMemoryHabitRepository — comportement de base', () {
    late HabitRepository repo;

    setUp(() {
      repo = InMemoryHabitRepository();
    });

    test('getAllHabits retourne liste vide initialement', () async {
      final habits = await repo.getAllHabits();
      expect(habits, isEmpty);
    });

    test('addHabit puis getAllHabits retourne l\'habitude ajoutée', () async {
      // Importer Habit nécessaire pour ce test — voir imports
      // Cas nominal
    });

    test('deleteHabit supprime l\'habitude existante', () async {
      // Edge case : suppression existante
    });

    test('deleteHabit sur ID inexistant ne lève pas d\'exception', () async {
      // Edge case : suppression inexistante — comportement défensif
      await expectLater(
        () => repo.deleteHabit('id-inexistant'),
        returnsNormally,
      );
    });

    test('clearAllHabits vide le repository', () async {
      // Edge case : reset
    });
  });
}
```

> **Note** : Le test `SupabaseHabitRepository implémente HabitRepository` nécessite de mocker les dépendances (`SupabaseService`, `AuthService`). Si trop complexe, utiliser `isA<HabitRepository>` sur une instance avec dépendances nullables (le constructeur les accepte).

---

### Commandes de validation

```bash
# Vérifier aucun import interdit dans le port domain
grep -n "supabase\|hive\|flutter" lib/domain/habit/repositories/habit_repository.dart

# Vérifier que SupabaseHabitRepository importe depuis domain
grep -n "import.*habit_repository" lib/data/repositories/supabase/supabase_habit_repository.dart

# Analyse statique
puro flutter analyze --no-pub

# Tests (hors intégration réseau)
puro flutter test --exclude-tags integration
```

---

### Risques et garde-fous

| Risque | Mitigation |
|--------|------------|
| Import circulaire domain ↔ data | Impossible par construction : domain n'importe pas data. Vérifier avec `analyze`. |
| Casser `InMemoryHabitRepository` dans les tests | T5 : compiler + exécuter tous les tests existants avant merge |
| Regressions sur providers Riverpod | Les providers restent dans `lib/data/` — aucun changement, risque nul |
| La classe DDD `HabitRepository` d'`domain/` était utilisée quelque part | Grep préalable confirme 0 import → suppression sûre |

---

### References

- ADR hexagonale : `docs/ADR/ADR-001-hexagonal.md#Plan-de-migration` (sections 9.2)
- Règles domaine : `lib/domain/CLAUDE.md`
- Interface réelle à déplacer : `lib/data/repositories/habit_repository.dart:8-16`
- Interface DDD à supprimer : `lib/domain/habit/repositories/habit_repository.dart:1-348`
- Supabase adapter : `lib/data/repositories/supabase/supabase_habit_repository.dart:7-11`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [ ] Test non-créateur : vérifier le flux avec un compte utilisateur non-créateur du projet Supabase
- [ ] `puro flutter analyze --no-pub` → 0 nouvelle erreur
- [ ] `puro flutter test --exclude-tags integration` → 0 régression
- [ ] Grep confirmé : aucun import hive/supabase/flutter dans `lib/domain/habit/repositories/habit_repository.dart`

### File List
