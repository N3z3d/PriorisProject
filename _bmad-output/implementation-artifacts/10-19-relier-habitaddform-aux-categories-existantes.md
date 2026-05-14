# Story 10.19 : Relier HabitAddForm aux catégories existantes via provider

Status: backlog

## Origine

Issue identifiée en code review story 10.3. `HabitAddForm` passe `availableCategories: const []` à `HabitFormWidget`, rendant la dropdown catégories toujours vide dans le formulaire inline d'ajout d'habitude. Le dialog path (`HabitFormDialogService`) fonctionne correctement — il lit les catégories existantes depuis le state.

## Story

En tant qu'utilisateur,
je veux voir mes catégories d'habitudes existantes dans le formulaire inline d'ajout,
afin de pouvoir réutiliser mes catégories sans les recréer manuellement à chaque ajout.

## Acceptance Criteria

1. `HabitAddForm` lit les catégories existantes depuis le provider approprié et les passe à `HabitFormWidget`
2. Parité fonctionnelle avec `HabitFormDialogService` : même liste de catégories proposée
3. `puro flutter test --exclude-tags integration` → 0 régression
4. Tests unitaires : cas catégories vides, cas catégories existantes non-vides

## Tasks / Subtasks

- [ ] **T1 — Identifier le provider** : trouver le provider Riverpod qui expose les catégories existantes (probablement depuis `habitsNotifierProvider` ou un provider dédié)
- [ ] **T2 — Injecter dans HabitAddForm** : transformer `HabitAddForm` pour lire les catégories via `ConsumerWidget` ou param injecté par le parent
- [ ] **T3 — Aligner avec le pattern dialog** : vérifier que `HabitFormDialogService` est bien le modèle de référence, extraire si nécessaire
- [ ] **T4 — Tests** : couvrir les ACs 1-4
- [ ] **T5 — Validation** : `puro flutter analyze --no-pub` → 0 erreur, tests pass

## Dev Notes

### Pattern de référence

`HabitFormDialogService` passe les catégories existantes correctement. L'utiliser comme modèle pour le fix.

### Fichiers concernés

- `lib/presentation/pages/habits/components/habit_add_form.dart` — widget à modifier
- `lib/presentation/pages/habits/widgets/habit_form_widget.dart` — consommateur de `availableCategories`
- Provider à identifier (probablement `lib/data/providers/habits_state_provider.dart`)
