# Story 7.4 : Détection et gestion des doublons à l'ajout dans une liste

Status: done

## Story

En tant qu'utilisateur,
je veux être averti quand j'ajoute un élément déjà présent dans ma liste,
afin d'éviter les doublons accidentels et maintenir une liste propre.

## Acceptance Criteria

1. Lors de l'ajout d'un élément (simple ou en lot), si un doublon est détecté (même titre, insensible à la casse et aux accents), une alerte est affichée.
2. L'utilisateur peut choisir d'ignorer l'alerte et ajouter quand même, ou annuler.
3. La détection est client-side (en mémoire) avant tout appel serveur.
4. Pour l'import en lot, un rapport de doublons est affiché après import (dans le SnackBar de confirmation).
5. Tests unitaires sur la logique de détection, tests widget sur le flow UX.

---

## Tasks / Subtasks

- [x] AC3+AC5 — `DuplicateDetectionService` : logique pure de détection (AC: 3, 5)
  - [x] Créer `lib/domain/services/duplicate_detection_service.dart`
  - [x] Définir `DuplicateDetectionResult` avec `duplicateTitles` et `uniqueTitles`
  - [x] Implémenter `detect(List<ListItem> existing, List<String> incoming)` — case+accent-insensitive via `TextNormalizationService`, trim des deux côtés
  - [x] Écrire `test/domain/services/duplicate_detection_service_test.dart` : cas nominal + ≥ 3 edge cases

- [x] AC1+AC2 — `DuplicateWarningDialog` : widget de confirmation (AC: 1, 2)
  - [x] Créer `lib/presentation/widgets/dialogs/duplicate_warning_dialog.dart`
  - [x] Définir `enum DuplicateChoice { cancel, skipDuplicates, addAll }` dans ce fichier
  - [x] Mode **single** (`totalCount == 1`) : message simple, boutons [Annuler] [Ajouter quand même]
  - [x] Mode **bulk** (`totalCount > 1`) : "{duplicateCount} sur {totalCount} déjà dans la liste", boutons [Annuler] [Ignorer les doublons] [Tout ajouter]
  - [x] Si `uniqueCount == 0` en mode bulk : masquer [Ignorer les doublons]
  - [x] Utiliser les clés i18n (voir section Dev Notes)
  - [x] Écrire `test/presentation/widgets/dialogs/duplicate_warning_dialog_test.dart`

- [x] AC1+AC2+AC4 — Intégration dans `list_detail_page.dart` (AC: 1, 2, 4)
  - [x] Définir `class _DuplicateCancelException implements Exception {}` (private, locale au fichier)
  - [x] Dans `_showBulkAddDialog()`, déclarer `int _skippedCount = 0;` avant `showDialog`
  - [x] Dans le callback `onSubmit`, **avant** `addMultipleItems` :
    - Récupérer les items courants : `ref.read(listsControllerProvider).findListById(widget.list.id)?.items ?? []`
    - Appeler `DuplicateDetectionService().detect(existingItems, itemTitles)`
    - Si `result.hasDuplicates`, afficher `DuplicateWarningDialog` via `showDialog<DuplicateChoice>(context: context, ...)`
    - `DuplicateChoice.cancel` → `throw _DuplicateCancelException()` (garde le BulkAddDialog ouvert)
    - `DuplicateChoice.skipDuplicates` → `_skippedCount = result.duplicateTitles.length; titlesToAdd = result.uniqueTitles`
    - `DuplicateChoice.addAll` → `titlesToAdd = itemTitles` (inchangé)
    - Si `titlesToAdd.isEmpty` après skip → `throw _DuplicateCancelException()` (dialog reste ouvert)
  - [x] Après `showDialog<int>`, si `_skippedCount > 0` et `count != null && count > 0` : SnackBar avec `l10n.bulkAddImportSuccessWithSkipped(count, _skippedCount)`
  - [x] Sinon : SnackBar existant `l10n.bulkAddImportSuccess(count)`

- [x] AC1 — Clés i18n FR + EN + ES + DE (AC: 1)
  - [x] Ajouter dans `lib/l10n/app_fr.arb` et `lib/l10n/app_en.arb` les 7 clés listées dans Dev Notes
  - [x] Ajouter dans `lib/l10n/app_es.arb` et `lib/l10n/app_de.arb` les 7 clés (best-effort, copie EN)
  - [x] Regénérer les localisations : `flutter gen-l10n` ✅

- [x] Validation qualité finale
  - [x] `flutter analyze --no-pub` → 0 erreur dans les fichiers modifiés
  - [x] `flutter test test/domain/services/duplicate_detection_service_test.dart` → 9/9
  - [x] `flutter test test/presentation/widgets/dialogs/duplicate_warning_dialog_test.dart` → 6/6
  - [x] `flutter test test/presentation/widgets/dialogs/bulk_add_dialog_integration_test.dart` → 34/34 (non-régression)

---

## Dev Notes

### Architecture — Vue d'ensemble

```
list_detail_page._showBulkAddDialog()
  └─ BulkAddDialog.onSubmit(itemTitles, onProgress)
       └─ DuplicateDetectionService.detect(existing, itemTitles)
            └─ TextNormalizationService.normalizeForSorting()   ← DÉJÀ EXISTANT
       └─ [si hasDuplicates] showDialog<DuplicateChoice>(DuplicateWarningDialog)
            ├─ cancel         → throw _DuplicateCancelException()
            ├─ skipDuplicates → titlesToAdd = result.uniqueTitles
            └─ addAll         → titlesToAdd = itemTitles
       └─ addMultipleItems(titlesToAdd, onProgress: onProgress)
```

**SRP** : `DuplicateDetectionService` — logique seule. `DuplicateWarningDialog` — présentation seule.  
**DIP** : `list_detail_page` injecte le service par construction (pas de Riverpod pour un service pur stateless).  
**OCP** : `DuplicateDetectionService.detect` extensible sans modification (paramètres, pas de hardcode).

---

### `DuplicateDetectionService` — Spec complète

**Fichier** : `lib/domain/services/duplicate_detection_service.dart`

```dart
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/text/text_normalization_service.dart';

class DuplicateDetectionResult {
  final List<String> duplicateTitles;
  final List<String> uniqueTitles;

  const DuplicateDetectionResult({
    required this.duplicateTitles,
    required this.uniqueTitles,
  });

  bool get hasDuplicates => duplicateTitles.isNotEmpty;
}

class DuplicateDetectionService {
  static const _normalizer = TextNormalizationService();

  const DuplicateDetectionService();

  /// Détecte les doublons dans [incoming] par rapport à [existing].
  /// Comparaison insensible à la casse et aux accents, avec trim.
  DuplicateDetectionResult detect(
    List<ListItem> existing,
    List<String> incoming,
  ) {
    final existingNormalized = existing
        .map((item) => _normalizer.normalizeForSorting(item.title.trim()))
        .toSet();

    final duplicates = <String>[];
    final unique = <String>[];

    for (final title in incoming) {
      final normalized = _normalizer.normalizeForSorting(title.trim());
      if (existingNormalized.contains(normalized)) {
        duplicates.add(title);
      } else {
        unique.add(title);
        // Ajouter au set pour détecter les doublons INTRA-batch aussi
        existingNormalized.add(normalized);
      }
    }

    return DuplicateDetectionResult(
      duplicateTitles: duplicates,
      uniqueTitles: unique,
    );
  }
}
```

> **Note critique — détection intra-batch** : si l'utilisateur colle 3 fois "Café" dans le bulk add, seul le premier est gardé dans `unique`. Le service mute `existingNormalized` pendant la boucle pour détecter les doublons au sein du batch lui-même.

---

### `DuplicateWarningDialog` — Spec complète

**Fichier** : `lib/presentation/widgets/dialogs/duplicate_warning_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';

enum DuplicateChoice { cancel, skipDuplicates, addAll }

class DuplicateWarningDialog extends StatelessWidget {
  final List<String> duplicateTitles;
  final int totalCount;

  const DuplicateWarningDialog({
    super.key,
    required this.duplicateTitles,
    required this.totalCount,
  });

  int get _uniqueCount => totalCount - duplicateTitles.length;
  bool get _isSingleAdd => totalCount == 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.duplicateWarningTitle),
      content: _buildContent(l10n),
      actions: _buildActions(context, l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isSingleAdd) {
      return Text(l10n.duplicateWarningSingle(duplicateTitles.first));
    }
    return Text(
      l10n.duplicateWarningMultiple(duplicateTitles.length, totalCount),
    );
  }

  List<Widget> _buildActions(BuildContext context, AppLocalizations l10n) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(DuplicateChoice.cancel),
        child: Text(l10n.cancel),
      ),
      if (!_isSingleAdd && _uniqueCount > 0)
        TextButton(
          onPressed: () => Navigator.of(context).pop(DuplicateChoice.skipDuplicates),
          child: Text(l10n.duplicateWarningSkipAction(_uniqueCount)),
        ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(DuplicateChoice.addAll),
        child: Text(_isSingleAdd
            ? l10n.duplicateWarningAddAllSingle
            : l10n.duplicateWarningAddAllBulk(totalCount)),
      ),
    ];
  }
}
```

---

### Modification `list_detail_page.dart` — `_showBulkAddDialog`

**Import à ajouter** :
```dart
import 'package:prioris/domain/services/duplicate_detection_service.dart';
import 'package:prioris/presentation/widgets/dialogs/duplicate_warning_dialog.dart';
```

**Classe exception locale** (ajouter en haut du fichier, avant `class _ListDetailPageState`) :
```dart
class _DuplicateCancelException implements Exception {}
```

**Nouvelle implémentation de `_showBulkAddDialog`** :
```dart
Future<void> _showBulkAddDialog() async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  int skippedCount = 0;

  final count = await showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BulkAddDialog(
      onSubmit: (itemTitles, onProgress) async {
        final existing = ref
            .read(listsControllerProvider)
            .findListById(widget.list.id)
            ?.items ?? [];

        final result = const DuplicateDetectionService()
            .detect(existing, itemTitles);

        var titlesToAdd = itemTitles;

        if (result.hasDuplicates && context.mounted) {
          final choice = await showDialog<DuplicateChoice>(
            context: context,
            builder: (_) => DuplicateWarningDialog(
              duplicateTitles: result.duplicateTitles,
              totalCount: itemTitles.length,
            ),
          );

          if (choice == null || choice == DuplicateChoice.cancel) {
            throw _DuplicateCancelException();
          }
          if (choice == DuplicateChoice.skipDuplicates) {
            skippedCount = result.duplicateTitles.length;
            titlesToAdd = result.uniqueTitles;
          }
          // DuplicateChoice.addAll → titlesToAdd reste inchangé
        }

        if (titlesToAdd.isEmpty) throw _DuplicateCancelException();

        final idService = IdGenerationService();
        final ids = idService.generateBatchIds(titlesToAdd.length);
        final items = titlesToAdd.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final createdAt = DateTime.now().add(Duration(microseconds: index));
          return ListItem(
            id: ids[index],
            title: title,
            listId: widget.list.id,
            isCompleted: false,
            createdAt: createdAt,
          );
        }).toList();

        await ref
            .read(listsControllerProvider.notifier)
            .addMultipleItems(widget.list.id, items, onProgress: onProgress);
      },
    ),
  );

  if (count != null && count > 0 && context.mounted) {
    final message = skippedCount > 0
        ? l10n.bulkAddImportSuccessWithSkipped(count, skippedCount)
        : l10n.bulkAddImportSuccess(count);
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.successColor,
    ));
  }
}
```

> **Pourquoi `_DuplicateCancelException` au lieu de `return`** : si `onSubmit` retourne normalement (sans throw), `BulkAddDialog._handleSubmit` pop le dialog. Avec throw, le `catch (e)` interne remet `_isSubmitting = false` et garde le dialog ouvert — le texte de l'utilisateur est préservé. Ce mécanisme est la façon correcte d'annuler sans fermer le `BulkAddDialog`.

> **Attention context.mounted** : `showDialog<DuplicateChoice>` est appelé avec le `context` de la page (pas `dialogContext`). Vérifier `context.mounted` avant tout usage du context après un await.

---

### Clés i18n à ajouter

#### `lib/l10n/app_fr.arb`

```json
"duplicateWarningTitle": "Doublon détecté",
"@duplicateWarningTitle": {
  "description": "Titre du dialogue de détection de doublon"
},
"duplicateWarningSingle": "L'élément \"{title}\" est déjà dans votre liste.",
"@duplicateWarningSingle": {
  "description": "Message singulier de doublon",
  "placeholders": { "title": { "type": "String" } }
},
"duplicateWarningMultiple": "{duplicateCount, plural, one {{duplicateCount} élément est déjà} other {{duplicateCount} éléments sont déjà}} dans votre liste (sur {total}).",
"@duplicateWarningMultiple": {
  "description": "Message pluriel de doublon",
  "placeholders": {
    "duplicateCount": { "type": "int" },
    "total": { "type": "int" }
  }
},
"duplicateWarningSkipAction": "Ignorer ({uniqueCount} à ajouter)",
"@duplicateWarningSkipAction": {
  "description": "Bouton : ignorer les doublons et n'ajouter que les uniques",
  "placeholders": { "uniqueCount": { "type": "int" } }
},
"duplicateWarningAddAllSingle": "Ajouter quand même",
"@duplicateWarningAddAllSingle": {
  "description": "Bouton : ajouter l'élément malgré le doublon (mode single)"
},
"duplicateWarningAddAllBulk": "Tout ajouter ({count})",
"@duplicateWarningAddAllBulk": {
  "description": "Bouton : ajouter tous les éléments y compris les doublons (mode bulk)",
  "placeholders": { "count": { "type": "int" } }
},
"bulkAddImportSuccessWithSkipped": "{count, plural, one {{count} élément importé} other {{count} éléments importés}}, {skipped, plural, one {{skipped} doublon ignoré} other {{skipped} doublons ignorés}}",
"@bulkAddImportSuccessWithSkipped": {
  "description": "SnackBar après import avec doublons ignorés",
  "placeholders": {
    "count": { "type": "int" },
    "skipped": { "type": "int" }
  }
}
```

#### `lib/l10n/app_en.arb` — même clés en anglais

```json
"duplicateWarningTitle": "Duplicate detected",
"duplicateWarningSingle": "The item \"{title}\" is already in your list.",
"@duplicateWarningSingle": {
  "placeholders": { "title": { "type": "String" } }
},
"duplicateWarningMultiple": "{duplicateCount, plural, one {{duplicateCount} item is already} other {{duplicateCount} items are already}} in your list (out of {total}).",
"@duplicateWarningMultiple": {
  "placeholders": {
    "duplicateCount": { "type": "int" },
    "total": { "type": "int" }
  }
},
"duplicateWarningSkipAction": "Skip duplicates ({uniqueCount} to add)",
"@duplicateWarningSkipAction": {
  "placeholders": { "uniqueCount": { "type": "int" } }
},
"duplicateWarningAddAllSingle": "Add anyway",
"duplicateWarningAddAllBulk": "Add all ({count})",
"@duplicateWarningAddAllBulk": {
  "placeholders": { "count": { "type": "int" } }
},
"bulkAddImportSuccessWithSkipped": "{count, plural, one {{count} item imported} other {{count} items imported}}, {skipped, plural, one {{skipped} duplicate skipped} other {{skipped} duplicates skipped}}",
"@bulkAddImportSuccessWithSkipped": {
  "placeholders": {
    "count": { "type": "int" },
    "skipped": { "type": "int" }
  }
}
```

> Ajouter aussi dans `app_es.arb` et `app_de.arb` les mêmes clés (valeurs identiques à l'anglais pour l'instant, best-effort).

---

### Tests — `DuplicateDetectionService`

**Fichier** : `test/domain/services/duplicate_detection_service_test.dart`

Cas à couvrir :
1. **Nominal** : 1 doublon exact → `duplicateTitles.length == 1`, `uniqueTitles.length == N-1`
2. **Case-insensitive** : "Café" vs "café" → doublon
3. **Accent-insensitive** : "Cafe" vs "Café" → doublon
4. **Doublon intra-batch** : 2× "item" dans incoming, 1 déjà en base → 2 doublons retournés, 0 uniques
5. **Aucun doublon** : résultat vide `duplicateTitles`, tous en `uniqueTitles`
6. **Tout doublon** : `uniqueTitles.isEmpty`, `hasDuplicates == true`
7. **incoming vide** : `DuplicateDetectionResult(duplicateTitles: [], uniqueTitles: [])`
8. **existing vide** : tous uniques

```dart
test('détecte un doublon case-insensitive', () {
  const service = DuplicateDetectionService();
  final existing = [
    ListItem(id: '1', title: 'Café', listId: 'l1', createdAt: DateTime.now()),
  ];
  final result = service.detect(existing, ['café', 'Thé']);
  expect(result.duplicateTitles, ['café']);
  expect(result.uniqueTitles, ['Thé']);
  expect(result.hasDuplicates, isTrue);
});

test('détecte un doublon intra-batch', () {
  const service = DuplicateDetectionService();
  final result = service.detect([], ['item', 'Item', 'autre']);
  // 'Item' est doublon de 'item' (déjà ajouté dans le set pendant la boucle)
  expect(result.duplicateTitles, ['Item']);
  expect(result.uniqueTitles, ['item', 'autre']);
});
```

---

### Tests — `DuplicateWarningDialog`

**Fichier** : `test/presentation/widgets/dialogs/duplicate_warning_dialog_test.dart`

Utiliser `test/helpers/localized_widget.dart` (créé en story 7.3 — voir `localizedApp` helper).

Cas à couvrir :
1. Mode single : 1 doublon, 1 total → [Annuler] + [Ajouter quand même] visibles, pas de [Ignorer]
2. Mode bulk : 2 doublons, 5 total → [Annuler] + [Ignorer (3 à ajouter)] + [Tout ajouter (5)] visibles
3. Mode bulk "tout doublon" : 5 doublons, 5 total → [Annuler] + [Tout ajouter (5)], pas de [Ignorer] (uniqueCount == 0)
4. Tap [Annuler] → pop avec `DuplicateChoice.cancel`
5. Tap [Ignorer] → pop avec `DuplicateChoice.skipDuplicates`
6. Tap [Ajouter quand même] → pop avec `DuplicateChoice.addAll`

---

### Pattern clé : `_DuplicateCancelException` et `BulkAddDialog`

Le `BulkAddDialog._handleSubmit` (story 7.3, ne pas modifier) a ce catch :
```dart
} catch (e) {
  if (mounted) setState(() { _isSubmitting = false; });
}
```
Ce catch générique attrape `_DuplicateCancelException` → remet le dialog dans l'état éditable sans le fermer. C'est intentionnel et documenté ici.

---

### Patterns à NE PAS toucher (pre-existing, hors scope)

Ces items sont des défauts signalés dans la review 7.3 mais **différés** — ne pas les modifier dans cette story :

- `BulkAddDialog` : gestion d'erreur silencieuse, SnackBar d'erreur absent, strings hard-codées, "0/N" display, `SingleChildScrollView` layout
- `list_detail_page.dart` : `IdGenerationService` instanciée inline (violation DIP pré-existante)
- `lists_controller_slim.dart` : `addMultipleItemsToList` alias

---

### Commandes de validation

```bash
# Analyse statique — 0 erreur dans les fichiers modifiés
flutter analyze --no-pub

# Tests unitaires nouveaux
flutter test test/domain/services/duplicate_detection_service_test.dart
flutter test test/presentation/widgets/dialogs/duplicate_warning_dialog_test.dart

# Non-régression BulkAdd (tests 7.3)
flutter test test/presentation/widgets/dialogs/bulk_add_dialog_integration_test.dart
flutter test test/presentation/widgets/dialogs/bulk_add_dialog_edge_cases_test.dart
flutter test test/presentation/widgets/dialogs/bulk_add_dialog_debounce_test.dart
flutter test test/presentation/widgets/dialogs/bulk_add_dialog_progress_test.dart

# Suite complète (hors integration réseau)
flutter test --exclude-tags integration
```

---

### Taille des fichiers

- `DuplicateDetectionService` : ~45 lignes (sous 500L)
- `DuplicateWarningDialog` : ~65 lignes (sous 500L)
- `list_detail_page.dart` actuellement ~580L → après modification : ~600L — surveiller, ne pas dépasser 650L

---

### Apprentissages des stories précédentes

- `flutter analyze --no-pub` obligatoire avant de déclarer terminé
- `flutter test <fichier_cible>` pour chaque fichier modifié
- Environnement puro `prioris-328` — utiliser `flutter analyze --no-pub` et tests ciblés
- `test/helpers/localized_widget.dart` existe depuis story 7.3 — l'utiliser pour les tests widget avec l10n
- Vérifier `context.mounted` après tout `await` qui utilise `context` ensuite
- Les clés ARB `@clé` avec `description` sont requises pour les placeholders — inclure les métadonnées

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

Aucun blocage. Implémentation conforme aux specs Dev Notes sans déviation.

### Completion Notes List

- `DuplicateDetectionService` : service stateless, détection case+accent-insensitive + intra-batch. 9 tests, 100% pass.
- `DuplicateWarningDialog` : 3 modes (single / bulk / tout-doublon), pop avec `DuplicateChoice`. 6 tests widget, 100% pass.
- `list_detail_page.dart` : `_DuplicateCancelException` + nouveau `_showBulkAddDialog` avec détection avant appel serveur. Le throw dans `onSubmit` garde le BulkAddDialog ouvert via le catch générique pré-existant.
- 7 clés i18n ajoutées dans FR (traduction), EN (source), ES+DE (best-effort copie EN). `flutter gen-l10n` régénéré avec succès.
- `flutter analyze --no-pub` : 0 erreur dans les fichiers modifiés (avertissements `info` pré-existants uniquement).
- 34/34 tests de non-régression BulkAdd passent.

### File List

- `lib/domain/services/duplicate_detection_service.dart` — NEW
- `lib/presentation/widgets/dialogs/duplicate_warning_dialog.dart` — NEW
- `lib/presentation/pages/list_detail_page.dart` — MODIFIED: _showBulkAddDialog avec détection doublon
- `lib/l10n/app_fr.arb` — MODIFIED: +7 clés
- `lib/l10n/app_en.arb` — MODIFIED: +7 clés
- `lib/l10n/app_es.arb` — MODIFIED: +7 clés (best-effort, copie EN)
- `lib/l10n/app_de.arb` — MODIFIED: +7 clés (best-effort, copie EN)
- `test/domain/services/duplicate_detection_service_test.dart` — NEW: 8 cas
- `test/presentation/widgets/dialogs/duplicate_warning_dialog_test.dart` — NEW: 6 cas

### Change Log

- 2026-04-26 : Implémentation complète — DuplicateDetectionService, DuplicateWarningDialog, intégration list_detail_page, 7 clés i18n × 4 locales, 15 nouveaux tests (9 unitaires + 6 widget), 0 régression.

---

### Review Findings

Code review du 2026-04-26 — 6 patches · 8 différés · 6 écartés.

- [x] [Review][Patch] `_DuplicateCancelException` affiche le nom de classe Dart comme erreur UI — Fix: `BulkAddCancelException` public + catch spécifique avant catch-all + `_DuplicateCancelException extends BulkAddCancelException` [bulk_add_dialog.dart, list_detail_page.dart]
- [x] [Review][Patch] `context.mounted` non vérifié après `await showDialog<DuplicateChoice>` — Fix: guard ajouté immédiatement après le await [list_detail_page.dart]
- [x] [Review][Patch] `_uniqueCount` peut être négatif — Fix: assertions constructor `duplicateTitles.length > 0` et `<= totalCount` [duplicate_warning_dialog.dart]
- [x] [Review][Patch] `_processedCount` fallback vers `items.length` brut — Fix: `onProgress(titlesToAdd.length, titlesToAdd.length)` appelé après `addMultipleItems` [list_detail_page.dart]
- [x] [Review][Patch] `_buildContent` crash sur `.first` quand `duplicateTitles` est vide — Fix: assert constructor (couvert par P3) [duplicate_warning_dialog.dart]
- [x] [Review][Patch] Aucun test cancel path — Fix: 2 nouveaux tests dans `bulk_add_dialog_integration_test.dart` [test/presentation/widgets/dialogs/]
- [x] [Review][Defer] Mode `_keepOpen` : SnackBar jamais affiché, `skippedCount` perdu entre soumissions successives [list_detail_page.dart:287] — deferred, pré-existant + hors scope story
- [x] [Review][Defer] `TextNormalizationService` constness assumée sans injection [duplicate_detection_service.dart:17] — deferred, pré-existant
- [x] [Review][Defer] `messenger` non protégé contre perte du Scaffold post-await [list_detail_page.dart:223] — deferred, pré-existant pattern global
- [x] [Review][Defer] Titres vides/whitespace silencieusement écartés sans feedback (pré-existant BulkAddDialog) — deferred, pré-existant
- [x] [Review][Defer] `ListItem.title` whitespace-only normalise à `""` (pré-existant data integrity) — deferred, pré-existant
- [x] [Review][Defer] Caractères CJK/emoji sans normalisation NFC/NFD (pré-existant TextNormalizationService) — deferred, pré-existant
- [x] [Review][Defer] `AppLocalizations.of(context)!` non protégé — pattern global dans l'app — deferred, pré-existant
- [x] [Review][Defer] Absence de tests d'intégration page-level flow complet (cancel→propre, skip→SnackBar) — deferred, complexité disproportionnée au risque
