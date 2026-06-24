# Story 10.19 : Supprimer le cluster de code mort « SOLID habits page » (résout finding HIGH 10-3)

Status: done

## Origine et pivot

Finding HIGH identifié en code review story 10.3 : `HabitAddForm` passe `availableCategories: const []` à `HabitFormWidget`, rendant la dropdown catégories toujours vide.

**Diagnostic exhaustif (grep `lib/` + `test/`, directive CLAUDE.md #5) lors de la création de cette story :** `HabitAddForm` n'est **instancié nulle part**. C'est du code mort. Le formulaire d'ajout réellement utilisé (`habits_page.dart` → `HabitFormDialogService` → `HabitFormWidget`) câble déjà `availableCategories: existingCategories` correctement. Le bug décrit n'atteint jamais l'utilisateur.

L'analyse a révélé un **cluster complet d'implémentation parallèle « SOLID habits page » jamais branché** (header à onglets, list view, card builder, action handler, interfaces ISP). La page réelle utilise un arbre distinct et indépendant (`HabitsHeader` → `HabitsBody` → `HabitsList` → `HabitCard`).

**Décision (validée utilisateur 2026-06-17) :** pivoter la story en **suppression de code mort**. Le finding HIGH 10-3 est résolu par élimination.

## Story

En tant que mainteneur,
je veux supprimer l'implémentation parallèle morte de la page habitudes,
afin d'éliminer le finding HIGH 10-3 et ~1500 lignes de code non exécuté (mandat CLAUDE.md : aucun code mort).

## Acceptance Criteria

1. Tous les fichiers du cluster mort « SOLID habits page » sont supprimés
2. `puro flutter analyze --no-pub` → 0 nouvelle erreur référençant un symbole supprimé
3. `puro flutter test --exclude-tags integration` → 0 nouvelle régression (baseline 10-16 : 2122 pass / 26 skip / 1 fail pré-existant `clean_code_constraints`)
4. Le flux d'ajout d'habitude réel (dialog) reste fonctionnel et continue de proposer les catégories existantes

## Tasks / Subtasks

- [x] **T1 — Diagnostic exhaustif** : grep `lib/`+`test/` de chaque symbole pour confirmer 0 usage vivant (AC 1)
- [x] **T2 — Rapport de suppression contrôlée** : fichier | raison | références | décision, validé par l'utilisateur (CLAUDE.md suppression contrôlée étape 1)
- [x] **T3 — Suppression** : `git rm` des 7 fichiers du cluster (AC 1)
- [x] **T4 — Vérification analyse** : `puro flutter analyze --no-pub`, 0 référence aux symboles supprimés (AC 2)
- [x] **T5 — Vérification tests** : `puro flutter test --exclude-tags integration`, 0 nouvelle régression (AC 3)
- [x] **T6 — Vérification flux réel** : `habits_page.dart` → `HabitFormDialogService` → `HabitFormWidget` intact, indépendant du cluster supprimé (AC 4)

## Dev Notes

### Cluster supprimé (7 fichiers, ~1486 lignes)

| Fichier | Symbole | Lignes | Raison |
|---------|---------|-------:|--------|
| `lib/presentation/pages/habits/components/habit_add_form.dart` | `HabitAddForm` | 24 | 0 instanciation (origine du finding 10-3) |
| `lib/presentation/pages/habits/components/habits_page_header.dart` | `HabitsPageHeader`, `HabitsPageThemeProvider` | 276 | 0 instanciation |
| `lib/presentation/pages/habits/components/habits_list_view.dart` | `HabitsListView` | 309 | 0 instanciation |
| `lib/presentation/pages/habits/components/habit_card_builder.dart` | `HabitCardBuilder` | 489 | utilisé uniquement par `HabitsListView` (mort) |
| `lib/presentation/pages/habits/services/habit_action_handler.dart` | `HabitActionHandler` | 207 | utilisé uniquement par son test |
| `lib/presentation/pages/habits/interfaces/habits_page_interfaces.dart` | 8 interfaces `IHabits*` | 142 | référencé seulement par les fichiers ci-dessus (tous morts) |
| `test/presentation/pages/habits/services/habit_action_handler_test.dart` | test de `HabitActionHandler` | 39 | teste du code mort |

### Garanties

- Le live tree (`habits_body`/`habits_list`/`habit_card`) ne référence **aucune** de ces interfaces (grep confirmé).
- Le flux d'ajout réel câble déjà les catégories (`habit_form_dialog_service.dart:30` → `availableCategories: existingCategories`).
- `HabitActionHandler` portait une sémantique de record divergente (force `true`) vs `HabitsController.recordHabit` (toggle) — cf. deferred-work T2 working tree. Sa suppression résout aussi cette divergence (le chemin était mort).

### Effet de bord noté (hors scope, suivi optionnel)

`habit_card_builder.dart` avait reçu de l'i18n au commit 10-16 (`2598f09`) — travail sur du code mort, annulé par la suppression. Certaines clés ARB ajoutées spécifiquement pour lui (ex. `habitStreakDays`) peuvent devenir orphelines. Nettoyage ARB laissé en suivi optionnel pour rester chirurgical (ne pas toucher les clés partagées).

### References

- Finding origine : code review story 10.3
- Flux réel : `lib/presentation/pages/habits_page.dart:135` (`_showCreateHabitModal`)
- Référence catégories câblées : `lib/presentation/pages/habits/services/habit_form_dialog_service.dart:30`

## Dev Agent Record

### Agent Model Used

claude-opus-4-8

### Debug Log References

- `git rm` 7 fichiers → OK
- `puro flutter analyze --no-pub` → 0 référence aux symboles supprimés (97 erreurs résiduelles = baseline pré-existant `test_utils/`, non liées)
- `puro flutter test --exclude-tags integration` → 2121 pass / 26 skip / 1 fail. L'unique échec (`clean_code_constraints` : `list_detail_page.dart` = 610 lignes) est pré-existant et hors scope. Baisse de 2122→2121 = retrait du test du code mort supprimé. **0 nouvelle régression.**

### Completion Notes List

- [x] sprint-status mis à jour à `done` pour cette story
- [x] Diagnostic exhaustif effectué avant suppression (directive #5)
- [x] Suppression contrôlée en 2 étapes (rapport validé, puis diff)

### File List

**Supprimés :**
- `lib/presentation/pages/habits/components/habit_add_form.dart`
- `lib/presentation/pages/habits/components/habits_page_header.dart`
- `lib/presentation/pages/habits/components/habits_list_view.dart`
- `lib/presentation/pages/habits/components/habit_card_builder.dart`
- `lib/presentation/pages/habits/services/habit_action_handler.dart`
- `lib/presentation/pages/habits/interfaces/habits_page_interfaces.dart`
- `test/presentation/pages/habits/services/habit_action_handler_test.dart`

### Change Log

- 2026-06-17 — Story 10.19 pivotée de « câbler catégories » vers « suppression code mort » après diagnostic exhaustif. 7 fichiers / ~1486 lignes supprimés (cluster « SOLID habits page » orphelin). Finding HIGH 10-3 résolu par élimination. 0 erreur introduite, 0 nouvelle régression. Status → done.
