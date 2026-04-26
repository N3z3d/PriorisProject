# Story 7.1 : Corriger le schema mismatch habits.category et sécuriser avec un test d'intégration Supabase

Status: review

## Story

En tant que développeur,
je veux corriger le schema mismatch entre le modèle Dart et le schéma Supabase réel sur la table `habits`,
afin que la fonctionnalité habitudes soit opérationnelle en production et ne régresse plus.

## Acceptance Criteria

1. La colonne `category` est présente dans le schéma Supabase OU le modèle Dart est aligné sur le schéma réel sans la colonne.
2. L'application habitudes fonctionne en production (création, lecture, mise à jour, suppression).
3. Un test d'intégration Supabase (base réelle) couvre le CRUD habitudes et valide la cohérence modèle/schéma.
4. `flutter analyze` propre, `flutter build web` propre.
5. Aucune régression sur les autres fonctionnalités.

## Tasks / Subtasks

- [ ] AC1 — Diagnostiquer le schéma Supabase réel et décider de l'approche (AC: 1)
  - [ ] Ouvrir Dashboard Supabase → Table Editor → table `habits` → lister toutes les colonnes existantes **[ACTION UTILISATEUR REQUISE]**
  - [x] Comparer avec les champs sérialisés dans `Habit.toJson()` (`lib/domain/models/core/entities/habit.dart:320-347`)
  - [x] Vérifier les autres colonnes potentiellement absentes (voir liste complète dans Dev Notes)
  - [x] Décision : **Chemin A retenu** — `category` est utilisée dans 10+ fichiers UI (habit_card, habit_footer, add_habit_dialog, statistics, etc.). Chemin B casserait l'UI.

- [ ] AC1 Chemin A — Ajouter la colonne `category` dans Supabase (AC: 1)
  - [ ] Dans Dashboard Supabase → SQL Editor, exécuter `supabase/003_add_habits_columns.sql` **[ACTION UTILISATEUR REQUISE]**
  - [ ] Vérifier que la RLS ne bloque pas les inserts/selects sur cette colonne pour l'utilisateur authentifié **[ACTION UTILISATEUR REQUISE]**
  - [ ] Vérifier que `getHabitsByCategory()` dans `SupabaseHabitRepository` fonctionne toujours (`lib/data/repositories/supabase/supabase_habit_repository.dart:136-161`) **[ACTION UTILISATEUR REQUISE]**

- [x] AC1 Chemin B — Non retenu (Chemin A choisi — voir décision ci-dessus)

- [x] AC1 Correctif global — Aligner tous les champs du modèle sur le schéma réel (AC: 1)
  - [x] Migration `supabase/003_add_habits_columns.sql` couvre toutes les colonnes potentiellement manquantes avec `IF NOT EXISTS`
  - [x] `toJson()` conservé tel quel (Chemin A — les colonnes seront présentes après migration)

- [x] AC2 — Vérifier le CRUD habitudes en production (AC: 2)
  - [x] Créer une habitude → aucune erreur `PGRST204`, habitude persistée (confirmé par utilisateur après migration SQL)
  - [x] Lire la liste → les habitudes s'affichent correctement
  - [x] Correction "Marquer comme fait" : `HabitActionHandler.handleHabitAction` gère désormais l'action `'complete'` (routée vers `recordHabit`) — `lib/presentation/pages/habits/services/habit_action_handler.dart:26`
  - [x] Correction "Marquer comme fait" : `recordHabit` appelle `habit.markCompleted(true)` avant `updateHabit` — `lib/presentation/pages/habits/services/habit_action_handler.dart:47`
  - [x] Correction progress display : `_calculateProgress`, `_calculateStreak`, `_calculateWeeklyCompletions` dans `HabitCardBuilder` remplacent les placeholders par les méthodes réelles du modèle — `lib/presentation/pages/habits/components/habit_card_builder.dart`

- [x] AC3 — Écrire le test d'intégration Supabase (base réelle) (AC: 3)
  - [x] Créer le dossier `test/integration/repositories/` s'il n'existe pas
  - [x] Créer `test/integration/repositories/supabase_habit_repository_integration_test.dart`
  - [x] Implémenter le pattern `setUpAll` / `tearDownAll` (voir template dans Dev Notes)
  - [x] Authentifier avec le compte test (`test/manual/test_credentials.txt`)
  - [x] Couvrir le cycle CRUD complet : `saveHabit` → `getAllHabits` → `updateHabit` → `deleteHabit`
  - [x] Assertion : aucune `PostgrestException` sur aucun appel
  - [x] Cleanup : supprimer les données de test dans `tearDownAll`
  - [ ] Exécuter et valider (nécessite réseau + migration appliquée) **[ACTION UTILISATEUR REQUISE]**

- [ ] AC4 — Valider la qualité statique et le build (AC: 4)
  - [x] `flutter analyze --no-pub` → 0 erreur dans les fichiers créés/modifiés par la story
  - [ ] `flutter build web --no-tree-shake-icons` → bloqué par issue pré-existante (package_config.json pointe vers prioris-328, incompatible avec Dart SDK stable) **[BLOQUANT PRÉ-EXISTANT — hors scope 7.1]**
  - [ ] `flutter test --exclude-tags integration` → bloqué par la même issue pré-existante **[BLOQUANT PRÉ-EXISTANT]**

- [ ] AC5 — Vérifier l'absence de régression (AC: 5)
  - [ ] `flutter test test/infrastructure/services/web_auth_callback_stabilizer_test.dart` → bloqué par issue pré-existante **[BLOQUANT PRÉ-EXISTANT]**
  - [ ] Vérifier visuellement que les listes, tâches, et autres fonctionnalités ne sont pas impactées **[ACTION UTILISATEUR REQUISE]**

## Dev Notes

### Contexte critique — Erreur bloquante

```
PostgrestException(message: Could not find the 'category' column of 'habits', code: PGRST204)
```

Le code `PGRST204` (PostgREST) signifie : *"Column not found in the target table."* Supabase rejette la **requête entière** (INSERT ou UPDATE) dès qu'un champ inconnu est présent dans le corps JSON. Le modèle `Habit.toJson()` sérialise le champ `category` qui n'existe pas dans le schéma Supabase de production — ce qui bloque toute opération d'écriture sur les habitudes.

**Cause probable :** La colonne `category` a été ajoutée au modèle Dart mais la migration Supabase correspondante n'a jamais été appliquée en production.

### Arbre de décision (AC1)

**Avant de toucher au code, inspecter le Dashboard Supabase :**

1. Dashboard → Table Editor → table `habits` → colonnes
2. Si `category` est absente **et** non utilisée dans l'UI → **Chemin B** recommandé (supprimer du modèle)
3. Si `category` est une feature fonctionnelle voulue (filtre catégorie visible dans l'UI) → **Chemin A** (migration Supabase)

**Recommandation préférentielle : Chemin B** — La fonctionnalité catégorie n'est pas dans les AC de l'Epic 7 et aucune page UI ne propose de filtre par catégorie. Supprimer le champ est moins risqué qu'une migration de schéma en production.

### Autres colonnes potentiellement manquantes

Le `toJson()` du modèle `Habit` sérialise **26 champs**. D'autres mismatches sont possibles. Lors de l'inspection Supabase, comparer avec cette liste exhaustive issue de `Habit.toJson()` (`lib/domain/models/core/entities/habit.dart:320-347`) :

| Champ Dart | Colonne Supabase attendue | Risque si absente |
|-----------|--------------------------|-------------------|
| `category` | `category` | PGRST204 confirmé |
| `targetValue` | `target_value` | PGRST204 potentiel |
| `recurrenceType` | `recurrence_type` | PGRST204 potentiel |
| `intervalDays` | `interval_days` | PGRST204 potentiel |
| `weekdays` | `weekdays` | PGRST204 potentiel |
| `timesTarget` | `times_target` | PGRST204 potentiel |
| `monthlyDay` | `monthly_day` | PGRST204 potentiel |
| `quarterMonth` | `quarter_month` | PGRST204 potentiel |
| `yearlyMonth` | `yearly_month` | PGRST204 potentiel |
| `yearlyDay` | `yearly_day` | PGRST204 potentiel |
| `hourlyInterval` | `hourly_interval` | PGRST204 potentiel |
| `color` | `color` | PGRST204 potentiel |
| `icon` | `icon` | PGRST204 potentiel |
| `currentStreak` | `current_streak` | PGRST204 potentiel |
| `completions` | `completions` (jsonb) | PGRST204 potentiel |
| `userEmail` | `user_email` | PGRST204 potentiel |

**Action :** Pour chaque champ manquant dans Supabase, appliquer Chemin A (ADD COLUMN) ou Chemin B (retirer de `toJson()`).

### Template du test d'intégration (AC3)

```dart
// test/integration/repositories/supabase_habit_repository_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/supabase/supabase_habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';

@Tags(['integration'])
void main() {
  group('SupabaseHabitRepository — Intégration Supabase réelle', () {
    late SupabaseHabitRepository repository;
    String testHabitId = '';

    setUpAll(() async {
      await SupabaseService.initialize();
      await AuthService.instance.signIn(
        email: 'test_1776892399910_958@example.com',
        password: 'TestPassword123!',
      );
      repository = SupabaseHabitRepository();
    });

    tearDownAll(() async {
      if (testHabitId.isNotEmpty) {
        await repository.deleteHabit(testHabitId);
      }
      await AuthService.instance.signOut();
    });

    test('CRUD complet sans PostgrestException', () async {
      final habit = Habit(name: 'Test 7.1 Schema', type: HabitType.binary);
      testHabitId = habit.id;

      // CREATE
      await expectLater(
        () => repository.saveHabit(habit),
        returnsNormally,
        reason: 'saveHabit ne doit pas lever de PostgrestException',
      );

      // READ
      final habits = await repository.getAllHabits();
      expect(habits.any((h) => h.id == testHabitId), isTrue);

      // UPDATE
      final updated = habit.copyWith(name: 'Test 7.1 Schema Updated');
      await expectLater(
        () => repository.updateHabit(updated),
        returnsNormally,
        reason: 'updateHabit ne doit pas lever de PostgrestException',
      );

      // DELETE
      await expectLater(
        () => repository.deleteHabit(testHabitId),
        returnsNormally,
        reason: 'deleteHabit ne doit pas lever de PostgrestException',
      );
      testHabitId = ''; // nettoyé, pas besoin du tearDownAll
    });

    test('getAllHabits retourne une liste sans exception', () async {
      final habits = await repository.getAllHabits();
      expect(habits, isA<List<Habit>>());
    });
  });
}
```

**Exécution du test d'intégration (nécessite réseau et Supabase accessible) :**
```bash
flutter test test/integration/repositories/supabase_habit_repository_integration_test.dart --tags integration
```

**Ne PAS inclure dans `flutter test` standard** (CI/CD) — ce test nécessite un réseau réel.

### Fichiers à modifier

| Fichier | Modification |
|---------|-------------|
| `lib/domain/models/core/entities/habit.dart` | Retirer `category` (et tout autre champ manquant) du modèle — Chemin B |
| `lib/domain/models/core/entities/habit.g.dart` | Régénéré automatiquement — ne pas modifier à la main |
| `lib/data/repositories/supabase/supabase_habit_repository.dart` | Adapter `getHabitsByCategory()` si `category` supprimé |
| `test/integration/repositories/supabase_habit_repository_integration_test.dart` | **Nouveau** — test d'intégration CRUD |

### Fichiers à NE PAS toucher

- `lib/infrastructure/services/web_auth_callback_stabilizer.dart` — hors scope
- `lib/presentation/routes/app_routes.dart` — hors scope
- `lib/data/providers/auth_providers.dart` — hors scope
- Toute logique ELO, listes, tâches — hors scope (story 7.2)
- Tests existants dans `test/infrastructure/` — ne doivent pas régresser

### Patterns architecturaux à respecter

- **Layered/Hexagonal :** `Habit` est dans `domain/models/` ; le repository Supabase dans `data/repositories/supabase/`. Ne pas inverser les dépendances.
- **DIP :** `SupabaseHabitRepository` implémente l'interface `HabitRepository` du domain. Le domain ne sait pas que Supabase existe.
- **SRP :** `Habit.toJson()` reste dans la couche domaine. La sérialisation ne migre pas dans le repository.
- **Conventions :** snake_case en JSON côté Supabase, camelCase en Dart. Exemple : `targetValue` → `target_value`.

### Apprentissages de la story 7.0

- **Tests dès la première implémentation** : la review 7.0 a identifié l'absence de tests providers comme gap critique. Écrire le test d'intégration en parallèle du fix, pas après.
- **`flutter test` complet doit rester vert** : les failures pré-existantes liées aux fichiers `lib/l10n/app_localizations*.dart` supprimés (non régénérés) sont hors scope — ne pas les corriger dans cette story.
- **`Provider.autoDispose<bool>` préféré à `Provider<bool>`** pour les états ephémères (pattern établi story 7.0).
- **`deferred-work.md` est vide** : tous les items différés de l'Epic 6 sont soldés. Cette story repart d'une base propre.

### Commandes de validation

```bash
# Analyse statique
flutter analyze --no-pub

# Tests unitaires (exclure les tests d'intégration réseau)
flutter test --exclude-tags integration

# Tests stabilizer (régression critique)
flutter test test/infrastructure/services/web_auth_callback_stabilizer_test.dart

# Test d'intégration Supabase (nécessite réseau)
flutter test test/integration/repositories/supabase_habit_repository_integration_test.dart --tags integration

# Régénérer le code généré après modification de habit.dart
flutter pub run build_runner build --delete-conflicting-outputs

# Build web de validation
flutter build web --no-tree-shake-icons
```

### Project Structure Notes

- Architecture Layered/Hexagonal : `domain/` → `data/` → `infrastructure/` → `presentation/`
- Repositories concrets Supabase : `lib/data/repositories/supabase/`
- Tests d'intégration réels : `test/integration/` → créer sous-dossier `repositories/`
- Aucune contrainte de taille ≤500L sur `Habit` (actuellement ~390L) — rester sous le seuil après modification

### References

- `lib/domain/models/core/entities/habit.dart` — modèle complet, `toJson()`, `fromJson()`
- `lib/data/repositories/supabase/supabase_habit_repository.dart` — repository Supabase habits
- `test/integration/supabase_integration_validation_test.dart` — pattern de test d'intégration existant
- `test/manual/test_credentials.txt` — identifiants du compte de test Supabase
- `_bmad-output/planning-artifacts/epic-7.md` — Epic 7, story 7.1
- `_bmad-output/implementation-artifacts/7-0-dette-technique-differee-epic-6.md` — apprentissages et patterns story 7.0

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- flutter analyze : 0 erreur dans les fichiers créés par story 7.1 ; erreurs pré-existantes confirmées hors scope (app_localizations supprimés, optimization_metrics_calculator.dart, persistence_coordinator.dart)
- flutter build web / flutter test : bloqués par `.dart_tool/package_config.json` pointant vers `prioris-328` (Flutter 3.32.8) au lieu de `stable` (3.41.7). Issue pré-existante liée à un changement d'environnement puro non finalisé. Résolution : `flutter pub get` avec les conflits de dépendances résolus (`build_runner` vs `test`).

### Completion Notes List

- **Diagnostic AC1 (2026-04-23)** : Analyse statique du codebase — `category` est utilisée dans 10+ fichiers UI (habit_card.dart:88, habit_footer.dart:24, add_habit_dialog.dart:47, habit_card_builder.dart:94, habit_form_dialog_service.dart:55, habit_calculation_service.dart:58, points_calculation_service.dart:58, statistics/habits_tab_widget.dart:54). Chemin B casserait l'UI. **Chemin A retenu**.
- **Migration SQL créée (2026-04-23)** : `supabase/003_add_habits_columns.sql` — ajoute `category TEXT` (confirmé manquant via PGRST204) + 14 autres colonnes potentiellement manquantes avec `IF NOT EXISTS`. Doit être exécutée par l'utilisateur dans Supabase Dashboard → SQL Editor.
- **Test d'intégration créé (2026-04-23)** : `test/integration/repositories/supabase_habit_repository_integration_test.dart` — 4 tests : CRUD complet, category non-nulle, getAllHabits typé, getHabitsByCategory sans exception. Tagged `integration`, exclu du CI.
- **HALT — Actions utilisateur requises** :
  1. Ouvrir Supabase Dashboard → SQL Editor → exécuter `supabase/003_add_habits_columns.sql`
  2. Vérifier CRUD habitudes dans l'app (AC2)
  3. Résoudre issue puro `prioris-328` vs `stable` pour débloquer builds/tests (AC4/AC5)
  4. Exécuter `flutter test test/integration/repositories/supabase_habit_repository_integration_test.dart --tags integration` (AC3)

### File List

- supabase/003_add_habits_columns.sql (nouveau — migration SQL Chemin A)
- test/integration/repositories/supabase_habit_repository_integration_test.dart (nouveau — test d'intégration CRUD)
- test/domain/models/core/entities/habit_completion_test.dart (nouveau — 11 tests unitaires markCompleted/getSuccessRate/getCurrentStreak)
- lib/presentation/pages/habits/services/habit_action_handler.dart (fix — action 'complete' + markCompleted(true))
- lib/presentation/pages/habits/components/habit_card_builder.dart (fix — remplace placeholders par méthodes réelles du modèle)
- _bmad-output/implementation-artifacts/7-1-corriger-schema-mismatch-habits-category.md (mis à jour — cette story)
- _bmad-output/implementation-artifacts/sprint-status.yaml (mis à jour — in-progress → review)

## Change Log

- 2026-04-23 : Diagnostic Chemin A retenu, migration SQL créée, test d'intégration créé. HALT : actions utilisateur requises (Supabase dashboard + CRUD verification + env fix).
- 2026-04-23 : Fix "Marquer comme fait" — action 'complete' routée, markCompleted(true) appelé, progress display réel. 11 tests unitaires ajoutés. Story → review.
