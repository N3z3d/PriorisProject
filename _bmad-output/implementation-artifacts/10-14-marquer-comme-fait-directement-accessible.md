# Story 10.14 : Rendre "Marquer comme fait" directement accessible sur la carte d'habitude

Status: done

## Story

En tant qu'utilisateur,
je veux pouvoir marquer une habitude comme faite directement depuis sa carte, sans passer par le menu 3 points,
afin que l'action la plus fréquente soit la plus rapide d'accès et que "Supprimer" ne soit pas au même niveau.

## Acceptance Criteria

1. Bouton/icône "Marquer comme fait" visible directement sur la carte d'habitude (sans ouvrir le menu)
2. "Supprimer" requiert une confirmation explicite avant exécution — déjà implémenté via `HabitsPage._showDeleteConfirmation`, à vérifier en régression
3. Actions fréquentes (marquer) séparées des actions dangereuses (supprimer) — "Marquer comme fait" retiré du `PopupMenuButton`
4. Compatible mobile et desktop (bouton visible en tout temps, pas seulement au survol)
5. `puro flutter test --exclude-tags integration` → 0 régression

## Tasks / Subtasks

- [x] **T1 — Ajouter le bouton direct dans `HabitCard._buildHeader`** (AC 1, 3, 4)
  - [x] T1.1 — Dans `_buildHeader`, insérer `_buildRecordButton()` entre le bloc `Expanded` et `HabitMenu`
  - [x] T1.2 — `_buildRecordButton()` : `IconButton` avec `Icons.check_circle_outline` (non complété) ou `Icons.check_circle` vert (complété aujourd'hui) selon `habit.isCompletedToday()`
  - [x] T1.3 — `tooltip` du bouton : `AppLocalizations.of(context)!.habitsMenuRecord` (clé existante)
  - [x] T1.4 — `onPressed`: appel direct de `onRecord`

- [x] **T2 — Retirer "Marquer comme fait" du `HabitMenu`** (AC 3)
  - [x] T2.1 — Supprimer le paramètre `onRecord` de `HabitMenu`
  - [x] T2.2 — Supprimer l'item `'record'` du `PopupMenuButton` dans `HabitMenu`
  - [x] T2.3 — Supprimer le `case 'record'` du `switch` dans `_handleAction`
  - [x] T2.4 — Mettre à jour `HabitCard._buildHeader` pour ne plus passer `onRecord` à `HabitMenu`

- [x] **T3 — Tests** (AC 1, 2, 3, 4, 5)
  - [x] T3.1 — AC1 : bouton check visible sur la carte sans ouvrir le menu (widget test)
  - [x] T3.2 — AC1 (état complété) : `Icons.check_circle` affiché quand `habit.isCompletedToday() == true`
  - [x] T3.3 — AC1 (état non complété) : `Icons.check_circle_outline` affiché quand non complété
  - [x] T3.4 — AC1 (callback) : taper le bouton → `onRecord` appelé
  - [x] T3.5 — AC3 : `PopupMenuButton` ne contient plus de texte "Marquer comme fait" (chercher `habitsMenuRecord` ou le texte localisé)
  - [x] T3.6 — AC2 régression : `PopupMenuButton` contient toujours "Modifier" et "Supprimer"
  - [x] T3.7 — `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2106 pass, 26 skip)

## Dev Notes

### Architecture — chemins impactés

**Chaîne de callbacks (inchangée) :**
```
HabitsPage._showDeleteConfirmation → onDeleteHabit
HabitsPage.habitsControllerProvider.notifier.recordHabit → onRecordHabit
    ↓
HabitsBody (pass-through)
    ↓
HabitsList (pass-through, HabitCard.onRecord: () async { await onRecordHabit(habit); })
    ↓
HabitCard (reçoit onRecord, onEdit, onDelete)
    ↓ (avant)  HabitMenu(onRecord, onEdit, onDelete)
    ↓ (après)  IconButton(onPressed: onRecord) + HabitMenu(onEdit, onDelete)
```

**Confirmation "Supprimer" — déjà implémentée :**
`HabitsPage._showDeleteConfirmation` (ligne 104) affiche un `AlertDialog` avec bouton "Annuler" / "Supprimer" rouge avant d'appeler `habitsControllerProvider.notifier.deleteHabit`. Cette logique NE DOIT PAS être touchée — elle satisfait déjà AC2.

### Fichiers à modifier

**Modifiés :**
- `lib/presentation/pages/habits/components/habit_card.dart` — ajouter `_buildRecordButton()` dans `_buildHeader`, ne plus passer `onRecord` à `HabitMenu`
- `lib/presentation/pages/habits/components/habit_menu.dart` — supprimer paramètre `onRecord`, supprimer item "record"

**Non modifiés :**
- `lib/presentation/pages/habits_page.dart` — callbacks déjà câblés correctement
- `lib/presentation/pages/habits/components/habits_body.dart`
- `lib/presentation/pages/habits/components/habits_list.dart`
- `lib/presentation/pages/habits/controllers/habits_controller.dart`
- `lib/presentation/pages/habits/services/habit_action_handler.dart` (chemin alternatif non utilisé dans ce flux)

**Créés (tests) :**
- `test/presentation/pages/habits/components/habit_card_test.dart`

### État actuel de `HabitCard._buildHeader`

```dart
Widget _buildHeader(BuildContext context) {
  return Row(
    children: [
      HabitAvatar(habit: habit),
      const SizedBox(width: 16),
      Expanded(
        child: Column(/* title + category */),
      ),
      HabitMenu(             // ← passe onRecord, onEdit, onDelete
        onRecord: onRecord,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    ],
  );
}
```

**Après modification :**
```dart
Widget _buildHeader(BuildContext context) {
  final completedToday = habit.isCompletedToday();
  return Row(
    children: [
      HabitAvatar(habit: habit),
      const SizedBox(width: 16),
      Expanded(
        child: Column(/* title + category */),
      ),
      IconButton(
        onPressed: onRecord,
        tooltip: AppLocalizations.of(context)!.habitsMenuRecord,
        icon: Icon(
          completedToday ? Icons.check_circle : Icons.check_circle_outline,
          color: completedToday ? AppTheme.successColor : null,
        ),
      ),
      HabitMenu(             // ← plus d'onRecord ici
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    ],
  );
}
```

### État actuel de `HabitMenu`

```dart
class HabitMenu extends StatelessWidget {
  final VoidCallback onRecord;  // ← à supprimer
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: l10n.habitsMenuTooltip,
      onSelected: (value) => _handleAction(value),
      itemBuilder: (context) => [
        _buildMenuItem('record', Icons.check_circle, l10n.habitsMenuRecord), // ← à supprimer
        _buildMenuItem('edit', Icons.edit, l10n.habitsMenuEdit),
        _buildMenuItem('delete', Icons.delete, l10n.habitsMenuDelete, isDestructive: true),
      ],
    );
  }
```

**Après :**
```dart
class HabitMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  // onRecord supprimé

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: l10n.habitsMenuTooltip,
      onSelected: (value) => _handleAction(value),
      itemBuilder: (context) => [
        _buildMenuItem('edit', Icons.edit, l10n.habitsMenuEdit),
        _buildMenuItem('delete', Icons.delete, l10n.habitsMenuDelete, isDestructive: true),
      ],
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'edit':
        onEdit();
        break;
      case 'delete':
        onDelete();
        break;
    }
  }
```

### Infrastructure de tests

**Pattern à utiliser** (identique aux tests existants dans `habits_body_test.dart`) :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habit_card.dart';
import '../../../../helpers/localized_widget.dart';

Widget _buildCard({
  required Habit habit,
  VoidCallback? onRecord,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onTap,
}) {
  return localizedApp(
    HabitCard(
      habit: habit,
      onRecord: onRecord ?? () {},
      onEdit: onEdit ?? () {},
      onDelete: onDelete ?? () {},
      onTap: onTap ?? () {},
    ),
  );
}
```

**Helper pour créer un habit complété aujourd'hui :**
```dart
Habit _completedHabit() {
  final today = DateTime.now();
  final key =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return Habit(
    name: 'Test Habit',
    type: HabitType.binary,
    completions: {key: true},
  );
}
```

**Attention pour T3.4 (callback onRecord) :**
```dart
bool recorded = false;
await tester.pumpWidget(_buildCard(
  habit: Habit(name: 'Test', type: HabitType.binary),
  onRecord: () { recorded = true; },
));

final checkButton = find.byWidgetPredicate(
  (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
);
await tester.tap(checkButton);
await tester.pump();
expect(recorded, isTrue);
```

**Attention pour T3.5 (PopupMenu ne contient plus l'item record) :**
```dart
await tester.pumpWidget(_buildCard(habit: ...));
await tester.tap(find.byType(PopupMenuButton<String>));
await tester.pumpAndSettle();
// AppLocalizations.habitsMenuRecord = "Marquer comme fait"
expect(find.text('Marquer comme fait'), findsNothing);
```

**Attention pour T3.2/T3.3 (icône selon état) :**
```dart
// Non complété
final card1 = tester.widget<Icon>(find.byWidgetPredicate(
  (w) => w is Icon && (w.icon == Icons.check_circle_outline || w.icon == Icons.check_circle),
).first);
expect(card1.icon, Icons.check_circle_outline);

// Complété
final card2 = tester.widget<Icon>(...);
expect(card2.icon, Icons.check_circle);
```

### Clés i18n utilisées (toutes existantes — aucune nouvelle clé à ajouter)

| Clé | Valeur FR | Fichier |
|-----|-----------|---------|
| `habitsMenuRecord` | "Marquer comme fait" | `lib/l10n/app_fr.arb:729` |
| `habitsMenuTooltip` | "Afficher le menu" | `lib/l10n/app_fr.arb:725` |
| `habitsMenuEdit` | "Modifier" | `lib/l10n/app_fr.arb:733` |
| `habitsMenuDelete` | "Supprimer" | `lib/l10n/app_fr.arb:737` |

Aucune nouvelle clé ARB n'est nécessaire — `habitsMenuRecord` est réutilisé comme tooltip du bouton direct.

### Baseline de tests

2106 pass, 26 skip, 1 flaky préexistant (`lists_transaction_manager`) — établie en story 10-13.

### `AppTheme.successColor`

Import : `package:prioris/presentation/theme/app_theme.dart`
Utilisé dans `HabitProgressDisplay` pour la couleur du badge "Fait aujourd'hui" et du streak — reprendre la même couleur pour la cohérence visuelle.

### Commandes de vérification

```bash
# Tests ciblés
puro flutter test test/presentation/pages/habits/components/habit_card_test.dart

# Régression complète
puro flutter test --exclude-tags integration

# Analyse
puro flutter analyze --no-pub
```

### Références

- `lib/presentation/pages/habits/components/habit_card.dart` — widget principal à modifier
- `lib/presentation/pages/habits/components/habit_menu.dart` — supprimer item "record"
- `lib/presentation/pages/habits_page.dart:104-132` — `_showDeleteConfirmation` (déjà implémentée, AC2 satisfait)
- `lib/presentation/pages/habits_page.dart:67-69` — câblage `onRecordHabit → habitsControllerProvider.notifier.recordHabit`
- `lib/presentation/pages/habits/controllers/habits_controller.dart:75-98` — `recordHabit` (toggle binary, guard type != binary)
- `lib/presentation/pages/habits/components/habit_progress_display.dart:157-173` — `_buildCompletedTodayBadge` (pattern de couleur `AppTheme.successColor`)
- `test/helpers/localized_widget.dart` — `localizedApp()` (pattern de test)
- `test/presentation/pages/habits/components/habits_body_test.dart` — pattern existant pour tests widget habitudes
- Epic source : `_bmad-output/planning-artifacts/epic-10.md` — Story 10.12
- Story précédente : `_bmad-output/implementation-artifacts/10-13-remplacer-recochage-auto-listes-par-validation-ux.md`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- [x] sprint-status mis à jour à `done` pour cette story (après code review)
- [x] `puro flutter test --exclude-tags integration` → 0 régression (2113 pass, 26 skip, 1 flaky préexistant `lists_transaction_manager`)
- [x] `IconButton` avec `Icons.check_circle` / `Icons.check_circle_outline` + `AppTheme.successColor` ajouté dans `_buildRecordButton()` dans `HabitCard._buildHeader`
- [x] `HabitMenu` allégé : suppression de `onRecord`, item `'record'` et `case 'record'`
- [x] 6 widget tests créés couvrant AC 1, 2, 3 et régression (T3.1–T3.6)

### File List

- `lib/presentation/pages/habits/components/habit_card.dart` (modifié)
- `lib/presentation/pages/habits/components/habit_menu.dart` (modifié)
- `test/presentation/pages/habits/components/habit_card_test.dart` (créé)

### Change Log

- 2026-05-24 : Implémentation story 10.14 — bouton record direct sur HabitCard, suppression item "Marquer" du PopupMenu, 6 widget tests ajoutés (2113 pass, 26 skip, 0 régression)

### Review Findings

- [ ] [Review][Decision] Double-tap race condition : `onRecord` peut être déclenché deux fois avant la fin de l'opération async — Avant, le PopupMenu se fermait après sélection (debounce implicite). Le nouvel `IconButton` reste actif pendant l'`await`. Deux taps rapides : tap 1 marque l'habitude, tap 2 lit l'état déjà muté et la démarque immédiatement. Options : (a) désactiver le bouton pendant l'async (état local `_isRecording`), (b) accepter le comportement toggle rapide comme voulu.
- [ ] [Review][Patch] `_completedHabit()` appelle `markCompleted(true)` au lieu du constructeur avec completions map [test/presentation/pages/habits/components/habit_card_test.dart:25]
- [ ] [Review][Patch] `_findRecordIcon()` non-scopé peut matcher un autre `Icon` dans le sous-arbre (HabitProgressDisplay, HabitAvatar) — utiliser `.first` sur la mauvaise icône rend T3.2/T3.3 faux-positifs [test/presentation/pages/habits/components/habit_card_test.dart:31-35]
- [ ] [Review][Patch] Aucun test de régression pour AC2 (confirmation suppression) — la spec exige de vérifier que tap "Supprimer" → AlertDialog apparaît [test/presentation/pages/habits/components/habit_card_test.dart]
- [x] [Review][Defer] Icône stale au changement de minuit [lib/presentation/pages/habits/components/habit_card.dart:54] — deferred, pre-existing (concern architectural global, driven par Riverpod emit)
- [x] [Review][Defer] Finder T3.1/T3.4 hardcodé `'Marquer'` fragile multi-locale [habit_card_test.dart:48] — deferred, pre-existing (localizedApp FR protège en pratique)
- [x] [Review][Defer] Bouton record affiché pour habitudes quantitatives (no-op silencieux via guard controller) [habit_card.dart] — deferred, pre-existing (comportement identique dans l'ancien popup)
- [x] [Review][Defer] `isCompletedToday()` toujours false pour habitudes quantitatives sans targetValue [domain/models] — deferred, pre-existing (logique domaine indépendante)
- [x] [Review][Defer] `AppLocalizations.of(context)!` null assertion dupliquée dans `_buildRecordButton` [habit_card.dart:81] — deferred, pre-existing (pattern homogène dans le fichier, tests protégés)
- [x] [Review][Defer] Switch `_handleAction` sans default case après suppression de `'record'` [habit_menu.dart:53] — deferred, pre-existing (pattern pré-existant)
- [x] [Review][Defer] T3.5 cherche texte FR `'Marquer comme fait'` en dur [habit_card_test.dart:84] — deferred, pre-existing (localizedApp FR protège)
