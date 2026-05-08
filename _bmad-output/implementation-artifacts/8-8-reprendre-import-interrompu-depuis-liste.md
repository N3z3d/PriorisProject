# Story 8.8 : Reprendre un import interrompu depuis la page liste

Status: done

## Story

En tant qu'utilisateur,
je veux pouvoir reprendre un import interrompu directement depuis la page de la liste concernée,
afin de compléter l'import sans ressaisir manuellement les éléments restants.

## Acceptance Criteria

1. Quand un import est interrompu (quit/refresh), les items non encore traités sont persistés dans SharedPreferences (en plus de `current`/`total` déjà persistés par story 8.3)
2. À la réouverture de la **page de la liste concernée** (`ListDetailPage`), si un import interrompu la concerne, une bannière s'affiche : "Import interrompu — X/Y ajoutés · N éléments en attente" avec deux actions : [Reprendre] [Ignorer]
3. "Reprendre" ouvre le `BulkAddDialog` en mode multiple avec les items restants pré-remplis dans le champ texte (un par ligne) et les soumet immédiatement
4. "Ignorer" efface l'état persisté sans réimporter
5. La bannière homepage de la story 8.3 reste inchangée (elle est toujours affichée, mais sans action "Reprendre" — la reprise se fait depuis la liste)
6. `flutter analyze --no-pub` propre, aucune régression

---

## Tasks / Subtasks

- [x] **T1 — Étendre `ImportInterruptService`** (AC: 1, 2, 3, 4)
  - [x] T1.1 — Ajouter 3 nouvelles clés SharedPreferences : `_listIdKey = 'import_interrupt_list_id_v1'`, `_listNameKey = 'import_interrupt_list_name_v1'`, `_pendingItemsKey = 'import_interrupt_pending_items_v1'`
  - [x] T1.2 — Ajouter méthode `onImportStarted(String listId, String listName, List<String> allItems)` : persiste les 3 nouvelles clés (items sérialisés en JSON `jsonEncode(allItems)`) + appelle `onProgress(0, allItems.length)` pour initialiser `current`/`total`
  - [x] T1.3 — Modifier `onProgress(int current, int total)` : si `_pendingItemsKey` existe dans SharedPreferences, mettre à jour uniquement `current`/`total` (les items restants sont calculés à la lecture)
  - [x] T1.4 — Modifier `onComplete()` : ajouter `prefs.remove(_listIdKey)`, `prefs.remove(_listNameKey)`, `prefs.remove(_pendingItemsKey)` dans le `Future.wait`
  - [x] T1.5 — Modifier `checkAndLoadPersistedState()` : si `_pendingItemsKey` présent, décoder JSON et stocker dans `_startupInterrupt` étendu avec `listId`, `listName`, `remainingItems` (= `allItems.sublist(current)`)
  - [x] T1.6 — Modifier le type de `_startupInterrupt` en record étendu : `({int current, int total, String? listId, String? listName, List<String>? pendingItems})?`
  - [x] T1.7 — Ajouter `peekPendingResume(String listId)` : retourne `({int current, int total, List<String> pendingItems})?` si `_startupInterrupt?.listId == listId` (sans consommer)
  - [x] T1.8 — Ajouter `consumePendingResume()` : efface `_startupInterrupt`, retourne les données (comme `consumeStartupInterrupt` mais spécifique reprise)
  - [x] T1.9 — Mettre à jour les tests unitaires : `test/infrastructure/services/import_interrupt_service_test.dart` — ajouter tests pour `onImportStarted`, `peekPendingResume`, `consumePendingResume`, items restants calculés correctement

- [x] **T2 — Modifier `BulkAddDialog`** (AC: 1, 3)
  - [x] T2.1 — Ajouter paramètre optionnel `initialItems` : `final List<String>? initialItems` dans le constructeur de `BulkAddDialog`
  - [x] T2.2 — Dans `_BulkAddDialogState.initState()` : si `widget.initialItems != null && widget.initialItems!.isNotEmpty`, pré-remplir `_controller.text = widget.initialItems!.join('\n')` et `_currentMode = BulkAddMode.multiple`
  - [x] T2.3 — Dans `_handleSubmit()` : appeler `await ImportInterruptService.instance.onImportStarted(widget.listId!, widget.listName!, items)` si `widget.listId != null` avant de lancer `widget.onSubmit`. Sinon (dialog sans list context) : comportement inchangé (fire `onProgress` directement)
  - [x] T2.4 — Ajouter `final String? listId` et `final String? listName` au constructeur de `BulkAddDialog` (paramètres optionnels)

- [x] **T3 — Modifier `list_detail_page.dart`** (AC: 2, 3, 4)
  - [x] T3.1 — Dans `_showBulkAddDialog()` : passer `listId: widget.list.id` et `listName: widget.list.name` à `BulkAddDialog` (via `_openBulkAddDialog`)
  - [x] T3.2 — Dans `ListDetailPage` (ou `_ListDetailPageState.initState`) : appeler `_checkForPendingImport()` via `addPostFrameCallback`
  - [x] T3.3 — Implémenter `_checkForPendingImport()` avec bannière SnackBar (Reprendre + Ignorer)
  - [x] T3.4 — Ajouter `_showBulkAddDialogWithItems(List<String> items)` et `_openBulkAddDialog({List<String>? initialItems})` (DRY)

- [x] **T4 — Ajouter clés i18n** (AC: 6)
  - [x] T4.1 — Ajouter dans les 4 ARBs : `importResumeBanner`, `importResumeConfirm`, `importResumeIgnore`
  - [x] T4.2 — Régénérer : `puro flutter gen-l10n`

- [x] **T5 — Tests** (AC: 6)
  - [x] T5.1 — Tests unitaires `ImportInterruptService` : `onImportStarted` persiste items JSON, `peekPendingResume` retourne les items restants, `consumePendingResume` efface l'état
  - [x] T5.2 — Tests widget `BulkAddDialog` : `initialItems` pré-remplit le champ et passe en mode multiple
  - [x] T5.3 — Test widget `ListDetailPage` : si pending import pour ce `listId`, bannière de reprise visible

- [x] **T6 — Validation finale**
  - [x] T6.1 — `puro flutter analyze --no-pub` → 0 erreur dans les fichiers modifiés
  - [x] T6.2 — `puro flutter test --exclude-tags integration --no-pub` → 0 régression (1 test flaky pré-existant non lié)

---

## Dev Notes

### Architecture de la persistance étendue

`ImportInterruptService` après cette story gère deux niveaux :
- **Niveau 8.3** (bannière homepage) : `current`, `total` → affichage informatif dans `HomePage`
- **Niveau 8.8** (reprise) : `listId`, `listName`, `pendingItems` JSON → reprise active depuis `ListDetailPage`

Les deux niveaux coexistent dans le même `_startupInterrupt`. Si `pendingItems == null` (import sans `listId`, ex: tests ou appel sans context), seul le comportement 8.3 est actif.

### Calcul des items restants

```dart
// Dans checkAndLoadPersistedState() :
final allItemsJson = prefs.getString(_pendingItemsKey);
if (allItemsJson != null) {
  final allItems = List<String>.from(jsonDecode(allItemsJson) as List);
  final remainingItems = current < allItems.length
      ? allItems.sublist(current)
      : <String>[];
  _startupInterrupt = (
    current: current,
    total: total,
    listId: prefs.getString(_listIdKey),
    listName: prefs.getString(_listNameKey),
    pendingItems: remainingItems,
  );
}
```

### Deux boutons dans le SnackBar content (pas de double SnackBarAction)

Flutter ne supporte qu'une `SnackBarAction`. Pour avoir Reprendre + Ignorer :

```dart
SnackBar(
  content: Row(
    children: [
      Expanded(child: Text(l10n.importResumeBanner(...))),
      TextButton(
        onPressed: () { /* ignorer */ ScaffoldMessenger.of(context).hideCurrentSnackBar(); ImportInterruptService.instance.consumePendingResume(); },
        child: Text(l10n.importResumeIgnore, style: TextStyle(color: Colors.white70)),
      ),
    ],
  ),
  action: SnackBarAction(label: l10n.importResumeConfirm, onPressed: () { /* reprendre */ }),
  duration: const Duration(days: 1),
  backgroundColor: AppTheme.warningColor,
)
```

### Clés i18n exactes

**`app_fr.arb`** :
```json
"importResumeBanner": "Import interrompu — {current}/{total} ajoutés · {remaining} en attente",
"@importResumeBanner": {
  "placeholders": {
    "current": { "type": "int" },
    "total": { "type": "int" },
    "remaining": { "type": "int" }
  }
},
"importResumeConfirm": "Reprendre",
"@importResumeConfirm": { "description": "Bouton pour reprendre l'import interrompu" },
"importResumeIgnore": "Ignorer",
"@importResumeIgnore": { "description": "Bouton pour ignorer et effacer l'import interrompu" }
```

**`app_en.arb`** :
```json
"importResumeBanner": "Import interrupted — {current}/{total} added · {remaining} pending",
"importResumeConfirm": "Resume",
"importResumeIgnore": "Dismiss"
```

**`app_de.arb`** :
```json
"importResumeBanner": "Import unterbrochen — {current}/{total} hinzugefügt · {remaining} ausstehend",
"importResumeConfirm": "Fortsetzen",
"importResumeIgnore": "Verwerfen"
```

**`app_es.arb`** :
```json
"importResumeBanner": "Importación interrumpida — {current}/{total} añadidos · {remaining} pendientes",
"importResumeConfirm": "Reanudar",
"importResumeIgnore": "Descartar"
```

### Contraintes

- Ajouter `import 'dart:convert';` dans `import_interrupt_service.dart` pour `jsonEncode`/`jsonDecode`
- `BulkAddDialog.listId`/`listName` sont optionnels — tous les appels existants sans ces paramètres continuent de fonctionner (pas de breaking change)
- `_showBulkAddDialog` dans `list_detail_page.dart` passe actuellement `widget.list.id` dans le callback `onSubmit` (ligne ~273). Passer `listId: widget.list.id` et `listName: widget.list.title` directement au constructeur est un ajout non-breaking.
- Taille `ImportInterruptService` après modifications : ~80 lignes (< 500 lignes ✓)
- `peekPendingResume` ne consomme pas `_startupInterrupt` — c'est intentionnel pour permettre à `HomePage` d'afficher la bannière 8.3 ET à `ListDetailPage` d'afficher la bannière de reprise

### Attention — `HomePage` bannière 8.3

`HomePage._checkForInterruptedImport()` appelle `consumeStartupInterrupt()` qui efface `_startupInterrupt`. Si l'utilisateur arrive sur `HomePage` avant d'ouvrir la liste, `_startupInterrupt` est consommé et `peekPendingResume` dans `ListDetailPage` retourne null.

**Solution** : modifier `_checkForInterruptedImport()` dans `HomePage` pour utiliser `peekStartupInterrupt()` (nouveau, non-destructif) au lieu de `consumeStartupInterrupt()`. `consumeStartupInterrupt()` n'est appelé que dans `ListDetailPage.consumePendingResume()`.

Ajouter `peekStartupInterrupt()` à `ImportInterruptService` :
```dart
({int current, int total, String? listId, String? listName, List<String>? pendingItems})?
    peekStartupInterrupt() => _startupInterrupt;
```

Modifier `HomePage._checkForInterruptedImport()` : utiliser `peekStartupInterrupt()` (sans null-out) → affiche la bannière sans effacer l'état. `ListDetailPage.consumePendingResume()` efface l'état définitivement.

**Conséquence** : si l'utilisateur ignore la bannière homepage ET ignore la bannière liste, l'état reste persisté jusqu'au prochain démarrage (comportement acceptable).

### Structure des fichiers

```
lib/infrastructure/services/import_interrupt_service.dart         ← MODIFIER (~+40 lignes)
lib/presentation/widgets/dialogs/bulk_add_dialog.dart             ← MODIFIER (~+15 lignes)
lib/presentation/pages/list_detail_page.dart                      ← MODIFIER (~+30 lignes)
lib/presentation/pages/home_page.dart                             ← MODIFIER (~3 lignes : consume→peek)
lib/l10n/app_fr.arb + app_en.arb + app_de.arb + app_es.arb       ← MODIFIER (+3 clés chacun)
lib/l10n/app_localizations*.dart                                  ← GÉNÉRÉS par gen-l10n
test/infrastructure/services/import_interrupt_service_test.dart   ← MODIFIER (+5 tests)
test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart ← MODIFIER (+2 tests)
test/presentation/pages/list_detail_page_test.dart                ← MODIFIER (+1 test reprise)
```

### Références

- Story 8.3 (ImportInterruptService actuel) : `8-3-detecter-quit-refresh-pendant-import-massif.md`
- Story 8.7 (clé `ok` déjà ajoutée) : `8-7-polish-ux-snackbar-import-et-avertissement-fermeture.md`
- `import_interrupt_service.dart` : `lib/infrastructure/services/import_interrupt_service.dart`
- `bulk_add_dialog.dart` : `lib/presentation/widgets/dialogs/bulk_add_dialog.dart`
- `list_detail_page.dart` : `lib/presentation/pages/list_detail_page.dart` (ligne ~223 : `_showBulkAddDialog`)
- `home_page.dart` : `lib/presentation/pages/home_page.dart` (ligne ~37 : `_checkForInterruptedImport`)

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- T1 : `ImportInterruptService` étendu avec 5 nouvelles clés SP + `onImportStarted`, `peekPendingResume`, `consumePendingResume`, `peekStartupInterrupt`. `_startupInterrupt` passé en record étendu à 5 champs.
- T2 : `BulkAddDialog` enrichi de `listId`, `listName`, `initialItems`. `initState` pré-remplit le texte et passe en mode multiple. `_handleSubmit` appelle `onImportStarted` si `listId` présent.
- T3 : `list_detail_page.dart` — `_checkForPendingImport` injecté via `addPostFrameCallback` dans `initState`. SnackBar avec bouton Ignorer (TextButton dans content) + SnackBarAction Reprendre. `_showBulkAddDialog`/`_showBulkAddDialogWithItems` redirigent vers `_openBulkAddDialog` (DRY).
- `home_page.dart` : `consumeStartupInterrupt` → `peekStartupInterrupt` (non-destructif) pour permettre à `ListDetailPage` de consommer l'état en premier.
- T4 : 3 clés i18n ajoutées dans les 4 ARBs (FR/EN/DE/ES) + gen-l10n.
- T5 : 32 tests verts — 12 unitaires service, 8 widget BulkAddDialog, 6 widget ListDetailPage, 6 HomePage.
- T6 : 0 erreur analyse sur fichiers modifiés. 1 test flaky pré-existant (`lists_transaction_manager` timeout) non lié.

### File List

- lib/infrastructure/services/import_interrupt_service.dart
- lib/presentation/widgets/dialogs/bulk_add_dialog.dart
- lib/presentation/pages/list_detail_page.dart
- lib/presentation/pages/home_page.dart
- lib/l10n/app_fr.arb
- lib/l10n/app_en.arb
- lib/l10n/app_de.arb
- lib/l10n/app_es.arb
- lib/l10n/app_localizations.dart
- lib/l10n/app_localizations_fr.dart
- lib/l10n/app_localizations_en.dart
- lib/l10n/app_localizations_de.dart
- lib/l10n/app_localizations_es.dart
- test/infrastructure/services/import_interrupt_service_test.dart
- test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart
- test/presentation/pages/list_detail_page_test.dart

### Review Findings

- [x] [Review][Decision] D1 — AC5 : bannière HomePage — Validé. Duration(days:1) + SnackBarAction OK nécessaires (snackbar permanent non dismissable sinon). AC5 mis à jour pour autoriser le polish. Cohérent avec story 8.7.
- [x] [Review][Decision] D2 — AC3 "soumet immédiatement" — Validé comme pré-remplissage. Auto-submit dangereux (reprise accidentelle irréversible) ; texte pré-rempli + mode multiple + clic Ajouter est la bonne UX.
- [x] [Review][Patch] P1 (High) — Ignore + Resume double-consume : Resume peut obtenir null et échouer silencieusement [list_detail_page.dart _checkForPendingImport] — FIXED: itemsToResume capturé avant closures, Resume utilise la variable locale
- [x] [Review][Patch] P2 (High) — onImportStarted reset progress à 0 pendant reprise : double interruption affiche 0/N au lieu du vrai compteur [bulk_add_dialog.dart _handleSubmit] — FIXED: guard `widget.initialItems == null`
- [x] [Review][Patch] P3 (High) — jsonDecode sans try-catch : crash au démarrage sur JSON corrompu [import_interrupt_service.dart checkAndLoadPersistedState] — FIXED: try-catch, malformed JSON traité comme "no pending items"
- [x] [Review][Patch] P4 (Low) — _isValid=true bypass _validateInput pour items whitespace-only [bulk_add_dialog.dart initState] — FIXED: `_controller.text.trim().isNotEmpty`
- [x] [Review][Patch] P5 (Low) — onComplete().ignore() dans path Ignorer : sémantiquement incorrect, erreurs I/O avalées [list_detail_page.dart _checkForPendingImport Ignorer callback] — FIXED: supprimé, consume seul suffit
- [x] [Review][Defer] Def1 — _startupInterrupt reste en mémoire si utilisateur ne navigue pas vers la liste [import_interrupt_service.dart] — deferred, pré-existant, intentionnel per Dev Notes 8.8 (borné à la session)

## Change Log

| Date | Description |
|------|-------------|
| 2026-05-07 | Implémentation complète story 8.8 — reprise d'import interrompu depuis ListDetailPage. ImportInterruptService étendu (5 nouvelles clés SP, peekPendingResume, consumePendingResume, peekStartupInterrupt, onImportStarted). BulkAddDialog enrichi (initialItems, listId, listName). list_detail_page.dart : bannière SnackBar avec Reprendre/Ignorer. HomePage : consume→peek non-destructif. i18n 4 langues. 32 tests verts. |
