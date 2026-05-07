# Story 8.5 : Corriger formule calculateAveragePerDay et cast int→double Supabase

Status: done

## Story

En tant que développeur,
je veux corriger deux bugs de calcul dans `HabitCalculationService` et un `CastError` latent dans `Habit`,
afin que les métriques d'habitudes soient correctes et que l'app ne crashe pas sur des données Supabase légitimes.

## Acceptance Criteria

1. `calculateAveragePerDay` retourne la moyenne correcte (`sum/n`), couverte par tests unitaires incluant cas limites (n=0, valeurs négatives)
2. `Habit.getSuccessRate()`, `Habit.getCurrentStreak()`, et `Habit.isCompletedToday()` utilisent `(value as num).toDouble()` — aucun `CastError` sur des entiers Supabase
3. `Habit.fromJson()` parse `target_value` via `(json['target_value'] as num?)?.toDouble()` — aucun `CastError` si Supabase retourne un entier JSON
4. Tests unitaires ajoutés/mis à jour pour les deux corrections (cast + formule)
5. Un test d'intégration dans le fichier existant `supabase_habit_repository_integration_test.dart` vérifie que lire une habitude quantitative depuis Supabase (avec `targetValue` comme entier dans le JSON) ne lève pas d'exception
6. `flutter analyze --no-pub` propre, aucune régression

## Tasks / Subtasks

- [x] **T1 — Corriger la formule `calculateAveragePerDay`** (AC: 1)
  - [x] T1.1 — Dans `lib/domain/services/calculation/habit_calculation_service.dart`, ligne 46 : remplacer `return (totalCompletions / habits.length) * habits.length;` par `return totalCompletions / habits.length;`
  - [x] T1.2 — Dans `test/domain/services/calculation/habit_calculation_service_test.dart`, ligne 84-85 : corriger le test existant dont le commentaire `// (1.0 + 0.0) / 2 * 2 = 1.0` validait la formule buggée — le résultat correct est `0.5`
  - [x] T1.3 — Ajouter 3 cas limites dans le groupe `calculateAveragePerDay` : liste vide (retourne 0.0), une seule habitude à 100% (retourne 1.0), trois habitudes avec taux différents (retourne la moyenne correcte)

- [x] **T2 — Corriger les casts `int`→`double` dans `Habit`** (AC: 2, 3)
  - [x] T2.1 — `isCompletedToday()` ligne 197 : `(value as double)` → `(value as num).toDouble()`
  - [x] T2.2 — `getSuccessRate()` ligne 222 : `(value as double)` → `(value as num).toDouble()`
  - [x] T2.3 — `getCurrentStreak()` ligne 246 : `(value as double)` → `(value as num).toDouble()`
  - [x] T2.4 — `fromJson()` ligne 359 : `json['target_value'] as double?` → `(json['target_value'] as num?)?.toDouble()`

- [x] **T3 — Tests unitaires cast** (AC: 4)
  - [x] T3.1 — Dans `test/domain/models/core/entities/habit_completion_test.dart`, ajouter un groupe `Habit quantitative — cast int→double Supabase` avec 4 tests (getSuccessRate, getCurrentStreak, isCompletedToday, fromJson)

- [x] **T4 — Test d'intégration Supabase** (AC: 5)
  - [x] T4.1 — Dans `test/integration/repositories/supabase_habit_repository_integration_test.dart`, ajouter un test `getSuccessRate() ne crashe pas apres lecture depuis Supabase` (tagué `integration`)

- [x] **T5 — Validation finale** (AC: 6)
  - [x] T5.1 — `puro flutter analyze --no-pub` → 0 erreur dans les fichiers modifiés (2 info pré-existants sort_constructors_first ignorés)
  - [x] T5.2 — `puro flutter test --exclude-tags integration --no-pub` → 1972 tests verts, 0 régression (≥ 1965)
  - [x] T5.3 — Tests du groupe `calculateAveragePerDay` tous verts avec les nouvelles assertions (20/20)

---

## Dev Notes

### Bug 1 — Formule `calculateAveragePerDay` : cause réelle

**Fichier** : `lib/domain/services/calculation/habit_calculation_service.dart` lignes 39–47

La formule actuelle :
```dart
static double calculateAveragePerDay(List<Habit> habits) {
  if (habits.isEmpty) return 0.0;
  
  final totalCompletions = habits
      .map((habit) => habit.getSuccessRate())
      .reduce((a, b) => a + b);
  
  return (totalCompletions / habits.length) * habits.length;  // BUG ligne 46
}
```

`(totalCompletions / habits.length) * habits.length` se simplifie algébriquement à `totalCompletions`. La méthode retourne donc la **somme** des taux, pas la **moyenne**. Pour 2 habitudes avec `getSuccessRate()` → `[1.0, 0.0]`, le résultat est `1.0` (au lieu de `0.5`).

**Fix** :
```dart
return totalCompletions / habits.length;
```

**Impact** : La méthode n'est pas utilisée par `InsightsPage` (source : retrospective 7.8), mais elle peut l'être dans des stories futures. Correction proactive obligatoire.

**Test existant à corriger** (`habit_calculation_service_test.dart` ligne 84-85) :
```dart
// AVANT (validait la formule buggée) :
expect(result, equals(1.0)); // (1.0 + 0.0) / 2 * 2 = 1.0

// APRÈS (valide la formule correcte) :
expect(result, equals(0.5)); // (1.0 + 0.0) / 2 = 0.5
```

---

### Bug 2 — Cast `int`→`double` depuis Supabase : cause réelle

**Fichier** : `lib/domain/models/core/entities/habit.dart`

Supabase stocke les valeurs numériques en PostgreSQL. Quand une colonne `double precision` contient une valeur entière (ex: `1` au lieu de `1.0`), le JSON retourné est `{"target_value": 1}` — un entier JSON, pas un flottant. Dart décode cela en `int`, pas en `double`. `(value as double)` lève alors `CastError: type 'int' is not a subtype of type 'double'`.

**3 occurrences dans `habit.dart`** :

**T2.1** — `isCompletedToday()` ligne 197 :
```dart
// AVANT :
(value as double) >= targetValue!
// APRÈS :
(value as num).toDouble() >= targetValue!
```

**T2.2** — `getSuccessRate()` ligne 222 :
```dart
// AVANT :
(value as double) >= targetValue!
// APRÈS :
(value as num).toDouble() >= targetValue!
```

**T2.3** — `getCurrentStreak()` ligne 246 :
```dart
// AVANT :
(value as double) >= targetValue!
// APRÈS :
(value as num).toDouble() >= targetValue!
```

**T2.4** — `fromJson()` ligne 359 :
```dart
// AVANT :
targetValue: json['target_value'] as double?,
// APRÈS :
targetValue: (json['target_value'] as num?)?.toDouble(),
```

`(value as num).toDouble()` fonctionne quel que soit le type numérique retourné par Supabase (`int` ou `double`). C'est le pattern idiomatique Dart pour les JSON hétérogènes.

---

### T3 — Tests unitaires cast (habit_completion_test.dart)

Ajouter dans le fichier existant un nouveau groupe après le groupe `Habit.getCurrentStreak` :

```dart
group('Habit quantitative — cast int→double Supabase', () {
  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  test('getSuccessRate ne crashe pas si la completion est un int', () {
    final habit = Habit(
      name: 'Quantitative',
      type: HabitType.quantitative,
      targetValue: 3.0,
      completions: {
        dateKey(DateTime.now()): 5, // int, pas double
      },
    );
    expect(() => habit.getSuccessRate(), returnsNormally);
    expect(habit.getSuccessRate(), 1.0 / 7); // 1 jour réussi sur 7
  });

  test('getCurrentStreak ne crashe pas si la completion est un int', () {
    final habit = Habit(
      name: 'Quantitative',
      type: HabitType.quantitative,
      targetValue: 3.0,
      completions: {
        dateKey(DateTime.now()): 5, // int
      },
    );
    expect(() => habit.getCurrentStreak(), returnsNormally);
    expect(habit.getCurrentStreak(), 1);
  });

  test('isCompletedToday ne crashe pas si la completion est un int', () {
    final habit = Habit(
      name: 'Quantitative',
      type: HabitType.quantitative,
      targetValue: 3.0,
      completions: {
        dateKey(DateTime.now()): 5, // int
      },
    );
    expect(() => habit.isCompletedToday(), returnsNormally);
    expect(habit.isCompletedToday(), isTrue);
  });

  test('fromJson ne crashe pas si target_value est un int JSON', () {
    final json = {
      'id': 'test-id',
      'name': 'Test',
      'type': 'quantitative',
      'target_value': 5, // int JSON, pas 5.0
      'created_at': DateTime.now().toIso8601String(),
      'completions': <String, dynamic>{},
    };
    expect(() => Habit.fromJson(json), returnsNormally);
    final habit = Habit.fromJson(json);
    expect(habit.targetValue, equals(5.0));
    expect(habit.targetValue, isA<double>());
  });
});
```

---

### T4 — Test d'intégration Supabase

Ajouter dans `test/integration/repositories/supabase_habit_repository_integration_test.dart` un test au sein du groupe existant `SupabaseHabitRepository -- Integration Supabase reelle` :

```dart
test('getSuccessRate() ne crashe pas apres lecture depuis Supabase', () async {
  // Créer une habitude quantitative avec targetValue entière
  final habit = Habit(
    name: 'Test 8.5 Cast Int-Double',
    type: HabitType.quantitative,
    targetValue: 3.0,
  );
  testHabitId = habit.id;

  await repository.saveHabit(habit);

  final allHabits = await repository.getAllHabits();
  final saved = allHabits.where((h) => h.name == 'Test 8.5 Cast Int-Double').toList();
  expect(saved.isNotEmpty, isTrue);
  testHabitId = saved.first.id;

  // getSuccessRate() et getCurrentStreak() ne doivent pas lever CastError
  expect(() => saved.first.getSuccessRate(), returnsNormally);
  expect(() => saved.first.getCurrentStreak(), returnsNormally);

  await repository.deleteHabit(testHabitId);
  testHabitId = '';
});
```

Ce test est tagué `integration` (héritage du fichier `@Tags(['integration'])`) et ne s'exécute pas en CI. Il sert à valider le cast réel en conditions Supabase.

---

### Cas limites à couvrir dans `calculateAveragePerDay` (T1.3)

```dart
test('une seule habitude à 100% retourne 1.0', () {
  final now = DateTime.now();
  final habit = Habit(name: 'Habit 1', type: HabitType.binary);
  for (int i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    habit.completions[dateKey] = true;
  }
  expect(HabitCalculationService.calculateAveragePerDay([habit]), equals(1.0));
});

test('trois habitudes avec taux différents retourne la moyenne correcte', () {
  final now = DateTime.now();
  final habit0 = Habit(name: 'H0', type: HabitType.binary); // 0%
  final habit1 = Habit(name: 'H1', type: HabitType.binary); // ~57% (4/7)
  final habit2 = Habit(name: 'H2', type: HabitType.binary); // 100%
  for (int i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    habit0.completions[dateKey] = false;
    if (i < 4) habit1.completions[dateKey] = true;
    habit2.completions[dateKey] = true;
  }
  final result = HabitCalculationService.calculateAveragePerDay([habit0, habit1, habit2]);
  // (0 + 4/7 + 1) / 3 = (11/7) / 3 ≈ 0.524
  expect(result, closeTo((4.0 / 7 + 1.0) / 3.0, 0.001));
});
```

---

### Structure des fichiers modifiés/créés

```
lib/domain/services/calculation/habit_calculation_service.dart    ← MODIFIER (ligne 46)
lib/domain/models/core/entities/habit.dart                        ← MODIFIER (lignes 197, 222, 246, 359)

test/domain/services/calculation/habit_calculation_service_test.dart   ← MODIFIER (corriger test + 3 nouveaux cas)
test/domain/models/core/entities/habit_completion_test.dart            ← MODIFIER (ajouter groupe cast)
test/integration/repositories/supabase_habit_repository_integration_test.dart  ← MODIFIER (ajouter test intégration)
```

---

### Précautions critiques

1. **`lib/domain/` — imports interdits** : `habit.dart` et `habit_calculation_service.dart` sont dans `lib/domain/`. Ne pas importer `supabase_flutter`, `hive`, `flutter`, ni `prioris/data/` (cf. `lib/domain/CLAUDE.md`). Les fixes sont purement Dart pur — aucun import ajouté.

2. **Test existant `calculateAveragePerDay` doit être corrigé** : le test ligne 84-85 attendait `1.0` (résultat buggué). Après fix, la valeur correcte est `0.5`. Ne pas laisser les deux assertions contradictoires.

3. **Portée du fix cast** : toutes les habitudes de type `quantitative` qui ont des completions issues de Supabase sont affectées. Les habitudes `binary` ne sont pas concernées (leurs valeurs sont des `bool`, pas des `num`). Ne pas modifier la logique `binary`.

4. **`fromJson` target_value** : `(json['target_value'] as num?)?.toDouble()` couvre `null`, `int`, et `double` — les 3 cas possibles depuis Supabase. Ne pas utiliser `double.tryParse()` (le JSON est déjà numérique, pas string).

5. **Commandes PowerShell + puro** :
   ```powershell
   puro flutter analyze --no-pub
   puro flutter test --exclude-tags integration --no-pub
   puro flutter test test/domain/services/calculation/habit_calculation_service_test.dart
   puro flutter test test/domain/models/core/entities/habit_completion_test.dart
   # Pour le test intégration Supabase (réseau requis) :
   puro flutter test test/integration/repositories/supabase_habit_repository_integration_test.dart --tags integration
   ```

---

### Références

- `lib/domain/services/calculation/habit_calculation_service.dart` ligne 46 — formule buggée `calculateAveragePerDay`
- `lib/domain/models/core/entities/habit.dart` lignes 197, 222, 246, 359 — casts `(value as double)`
- `test/domain/services/calculation/habit_calculation_service_test.dart` ligne 84-85 — test à corriger
- `test/domain/models/core/entities/habit_completion_test.dart` — tests unitaires existants habitude
- `test/integration/repositories/supabase_habit_repository_integration_test.dart` — test intégration Supabase
- `_bmad-output/implementation-artifacts/deferred-work.md` — "Bug formule calculateAveragePerDay" + "Cast int→double depuis JSON Supabase" (section retro 7.8)
- `_bmad-output/planning-artifacts/epic-8.md` — Story 8.5 contexte et AC
- `lib/domain/CLAUDE.md` — imports interdits dans `lib/domain/`

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] T1.1 : formule `calculateAveragePerDay` corrigée (`sum/n` au lieu de `sum`) — ligne 46 de `habit_calculation_service.dart`
- [x] T1.2 : test existant corrigé (assertion `1.0` → `0.5`, commentaire mis à jour)
- [x] T1.3 : 3 nouveaux cas limites `calculateAveragePerDay` verts (liste vide, 1 habitude 100%, 3 habitudes mix)
- [x] T2.1–T2.4 : 4 occurrences `(value as double)` → `(value as num).toDouble()` dans `isCompletedToday`, `getSuccessRate`, `getCurrentStreak` et `fromJson`
- [x] T3 : groupe `Habit quantitative — cast int→double Supabase` (4 tests) vert — `habit_completion_test.dart`
- [x] T4 : test intégration Supabase ajouté (tagué `integration`) — `supabase_habit_repository_integration_test.dart`
- [x] T5 : analyze 0 erreur dans les fichiers modifiés ; 1972 tests verts (≥ 1965) ; 0 régression
- [ ] Test non-créateur : vérifier le flux avec un compte utilisateur non-créateur du projet Supabase

### File List

lib/domain/services/calculation/habit_calculation_service.dart (MODIFIÉ)
lib/domain/models/core/entities/habit.dart (MODIFIÉ)
test/domain/services/calculation/habit_calculation_service_test.dart (MODIFIÉ)
test/domain/models/core/entities/habit_completion_test.dart (MODIFIÉ)
test/integration/repositories/supabase_habit_repository_integration_test.dart (MODIFIÉ)

---

### Review Findings

- [x] [Review][Decision] AC1 "valeurs négatives" — résolu : test ajouté avec completion entière `-1` pour habitude quantitative ; documenté que les valeurs négatives ne sont pas un cas d'usage normal mais que le cast et la comparaison sont corrects [AC1]

- [x] [Review][Patch] `isCompletedToday()` absent du test d'intégration Supabase — ajouté [test/integration/repositories/supabase_habit_repository_integration_test.dart] [AC2+AC5]
- [x] [Review][Patch] Test `liste vide retourne 0.0` dupliqué — supprimé [test/domain/services/calculation/habit_calculation_service_test.dart]
- [x] [Review][Patch] Float equality `1.0 / 7` sans `closeTo` — corrigé avec `closeTo(1.0 / 7, 1e-9)` [test/domain/models/core/entities/habit_completion_test.dart]
- [x] [Review][Patch] Double appel `Habit.fromJson(json)` dans test — simplifié en un seul appel [test/domain/models/core/entities/habit_completion_test.dart]

- [x] [Review][Defer] 7 fichiers production conservent `(value as double)` non corrigés par story 8-5 [lib/domain/habit/services/habit_streak_calculator.dart:147, habit_progress_calculator.dart:111, habit_completion_service.dart:113, analytics/habit_pattern_analyzer.dart:89, analytics/habit_consistency_calculator.dart:72, lib/domain/services/calculation/progress_calculation_service.dart:310, lib/data/providers/list_providers.dart:229-231] — deferred, pre-existing
- [x] [Review][Defer] Hive adapter `habit.g.dart:25` — `targetValue: fields[5] as double?` non corrigé (path désérialisation Hive) — deferred, pre-existing
- [x] [Review][Defer] Présentation — silent null cast `as double?` dans 3 fichiers (habit_card.dart:91, habit_progress_bar.dart:88-104, habit_record_dialog.dart:34) — deferred, pre-existing
- [x] [Review][Defer] Hardcoded `7` en double occurrence dans `habit_progress_display.dart` (non dérivé d'une constante partagée — couplage fragile si la fenêtre change) — deferred, pre-existing
- [x] [Review][Defer] ARB `@habitProgressSuccessfulDays` placeholders déclarés sans `"type": "int"` (cohérent avec le projet mais non typé) [lib/l10n/app_de.arb, app_es.arb] — deferred, pre-existing
