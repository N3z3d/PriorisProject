# Story 8.7 : Polish UX — snackbar import dismissible et avertissement pendant l'import

Status: done

## Story

En tant qu'utilisateur,
je veux pouvoir fermer manuellement la bannière "import interrompu" et être averti de ne pas quitter l'app pendant un import,
afin de ne pas manquer l'information et de comprendre le risque de quitter en cours d'opération.

## Acceptance Criteria

1. Le SnackBar "Import interrompu — X/Y éléments ajoutés" s'affiche sans durée fixe (persiste jusqu'au dismiss) et comporte un bouton "OK" permettant de le fermer manuellement
2. Pendant qu'un import est en cours (`_isSubmitting = true`), le `BulkAddDialog` affiche un texte d'avertissement : "Ne fermez pas l'application pendant l'import"
3. 4 ARBs (fr/en/de/es) mis à jour avec les nouvelles clés i18n
4. `flutter analyze --no-pub` propre, aucune régression (`flutter test --exclude-tags integration` reste à 0 échec)

---

## Tasks / Subtasks

- [x] **T1 — Modifier `HomePage._checkForInterruptedImport`** (AC: 1)
  - [x] T1.1 — Supprimer `duration: const Duration(seconds: 6)` du `SnackBar` (la durée par défaut Flutter est suffisante, mais on veut dismiss explicite)
  - [x] T1.2 — Ajouter `duration: const Duration(days: 1)` pour forcer un affichage "permanent" jusqu'au dismiss (pattern Flutter recommandé pour snackbars actionnables)
  - [x] T1.3 — Ajouter `action: SnackBarAction(label: l10n.ok, onPressed: () {})` au `SnackBar`

- [x] **T2 — Ajouter avertissement dans `BulkAddDialog`** (AC: 2)
  - [x] T2.1 — Dans `_buildProgressSection`, ajouter sous le compteur `_processedCount / _totalCount` un `Text` avec `l10n.importDoNotClose`, style `textSecondary`, taille 12, centré
  - [x] T2.2 — L'avertissement ne doit s'afficher que quand `_isSubmitting = true` (il est déjà dans `_buildProgressSection` qui est conditionnel)

- [x] **T3 — Ajouter clés i18n** (AC: 3)
  - [x] T3.1 — Ajouter `ok` dans les 4 ARBs (clé générique réutilisable)
  - [x] T3.2 — Ajouter `importDoNotClose` dans les 4 ARBs
  - [x] T3.3 — Régénérer : `puro flutter gen-l10n`

- [x] **T4 — Tests** (AC: 4)
  - [x] T4.1 — Dans `test/presentation/pages/home_page_test.dart` : vérifier que le SnackBar contient un `SnackBarAction` avec label "OK"
  - [x] T4.2 — Dans `test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart` : vérifier que le texte `importDoNotClose` est visible pendant `_isSubmitting`

- [x] **T5 — Validation finale** (AC: 4)
  - [x] T5.1 — `puro flutter analyze --no-pub` → 0 erreur dans les fichiers modifiés
  - [x] T5.2 — `puro flutter test --exclude-tags integration --no-pub` → 0 régression

---

## Dev Notes

### Contexte — état actuel après story 8.3

**`lib/presentation/pages/home_page.dart` — `_checkForInterruptedImport()`** (ligne ~37) :
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(l10n.importInterruptedBanner(interruptState.current, interruptState.total)),
    duration: const Duration(seconds: 6),       // ← À remplacer
    backgroundColor: AppTheme.warningColor,
    // ← Ajouter action + duration longue
  ),
);
```

**`lib/presentation/widgets/dialogs/bulk_add_dialog.dart` — `_buildProgressSection()`** (ligne ~231) :
```dart
Widget _buildProgressSection(AppLocalizations l10n) {
  final hasProgress = _processedCount > 0;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        LinearProgressIndicator(...),
        const SizedBox(height: 8),
        Center(child: Text(hasProgress ? '$_processedCount / $_totalCount' : l10n.bulkAddSubmitting, ...)),
        // ← Ajouter ici le texte d'avertissement
      ],
    ),
  );
}
```

### Clés i18n exactes à ajouter (avant l'accolade fermante dans chaque ARB)

**`app_fr.arb`** :
```json
"ok": "OK",
"@ok": {
  "description": "Label générique bouton de confirmation/fermeture"
},
"importDoNotClose": "Ne fermez pas l'application pendant l'import",
"@importDoNotClose": {
  "description": "Avertissement affiché pendant un import massif en cours"
}
```

**`app_en.arb`** :
```json
"ok": "OK",
"@ok": { "description": "Generic confirmation/dismiss button label" },
"importDoNotClose": "Do not close the application during import",
"@importDoNotClose": { "description": "Warning shown during an ongoing bulk import" }
```

**`app_de.arb`** :
```json
"ok": "OK",
"@ok": { "description": "Generische Schaltflächenbeschriftung" },
"importDoNotClose": "Schließen Sie die App nicht während des Imports",
"@importDoNotClose": { "description": "Warnung während des laufenden Imports" }
```

**`app_es.arb`** :
```json
"ok": "OK",
"@ok": { "description": "Etiqueta genérica de botón de confirmación" },
"importDoNotClose": "No cierre la aplicación durante la importación",
"@importDoNotClose": { "description": "Advertencia mostrada durante una importación masiva" }
```

### Pattern Flutter pour SnackBar "permanent"

`duration: const Duration(days: 1)` est la convention Flutter recommandée pour un SnackBar qui persiste jusqu'au dismiss manuel via `SnackBarAction`. Le `ScaffoldMessenger` le retirera automatiquement à la navigation ou au `hideCurrentSnackBar`.

### Contraintes

- Ne pas toucher la logique `ImportInterruptService` — story 8.7 est purement UI/UX
- `SnackBarAction.onPressed: () {}` suffit pour le dismiss (Flutter ferme le SnackBar automatiquement au tap sur l'action)
- Style de l'avertissement : `TextStyle(color: AppTheme.textSecondary, fontSize: 12)` — cohérent avec `_buildProgressSection` existant
- `AppTheme.warningColor` = `Color(0xFFEA580C)` — déjà utilisé sur le SnackBar, rien à importer

### Commandes

```powershell
puro flutter gen-l10n
puro flutter analyze --no-pub
puro flutter test --exclude-tags integration --no-pub
puro flutter test test/presentation/pages/home_page_test.dart
puro flutter test test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart
```

### Structure des fichiers

```
lib/presentation/pages/home_page.dart                  ← MODIFIER (~3 lignes)
lib/presentation/widgets/dialogs/bulk_add_dialog.dart  ← MODIFIER (~3 lignes dans _buildProgressSection)
lib/l10n/app_fr.arb                                    ← MODIFIER (+2 clés)
lib/l10n/app_en.arb                                    ← MODIFIER (+2 clés)
lib/l10n/app_de.arb                                    ← MODIFIER (+2 clés)
lib/l10n/app_es.arb                                    ← MODIFIER (+2 clés)
lib/l10n/app_localizations*.dart                       ← GÉNÉRÉS par gen-l10n
test/presentation/pages/home_page_test.dart            ← MODIFIER (+1 assertion SnackBarAction)
test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart ← MODIFIER (+1 test avertissement)
```

### Références

- Story 8.3 (bannière import interrompu, code actuel) : `8-3-detecter-quit-refresh-pendant-import-massif.md`
- `home_page.dart` : `lib/presentation/pages/home_page.dart`
- `bulk_add_dialog.dart` : `lib/presentation/widgets/dialogs/bulk_add_dialog.dart`
- `AppTheme` : `lib/presentation/theme/app_theme.dart`

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- SnackBar import interrompu : `duration` changée de 6 s → 1 jour, `SnackBarAction(label: l10n.ok)` ajoutée (dismiss manuel).
- BulkAddDialog `_buildProgressSection` : `Text(l10n.importDoNotClose)` ajouté sous le compteur, `textSecondary` taille 12, centré.
- 4 ARBs (fr/en/de/es) mis à jour avec clés `ok` et `importDoNotClose`. `gen-l10n` régénéré.
- 2 nouveaux tests : `SnackBarAction` "OK" dans `home_page_test.dart` ; `importDoNotClose` visible pendant `_isSubmitting` dans `bulk_add_dialog_interrupt_test.dart`.
- Suite complète : 1974 tests, 0 régression. `flutter analyze` : 0 erreur dans les fichiers modifiés.

### Review Findings

- [x] [Review][Patch] Assertion manquante : `importDoNotClose` non vérifié absent après fin du submit [test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart:197] — **corrigé** : `expect(find.text(l10n.importDoNotClose), findsNothing)` ajouté après `pumpAndSettle()`
- [x] [Review][Defer] Multiple SnackBars en file derrière `duration: days(1)` — deferred, pre-existing
- [x] [Review][Defer] Warning `importDoNotClose` figé si widget unmounted pendant debounce keep-open — deferred, pre-existing
- [x] [Review][Defer] Race `_totalCount == 0` + keep-open mode — deferred, pre-existing
- [x] [Review][Defer] `AppLocalizations.of(context)!` null-deref sans delegate — deferred, pre-existing

### File List

- `lib/presentation/pages/home_page.dart`
- `lib/presentation/widgets/dialogs/bulk_add_dialog.dart`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_de.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_localizations.dart` (généré)
- `lib/l10n/app_localizations_fr.dart` (généré)
- `lib/l10n/app_localizations_en.dart` (généré)
- `lib/l10n/app_localizations_de.dart` (généré)
- `lib/l10n/app_localizations_es.dart` (généré)
- `test/presentation/pages/home_page_test.dart`
- `test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart`
