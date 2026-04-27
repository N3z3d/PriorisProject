# Story 7.5 : Améliorer les messages d'erreur et les états de chargement globaux

Status: review

## Story

En tant qu'utilisateur,
je veux voir des messages d'erreur clairs et des états de chargement cohérents dans toute l'application,
afin de comprendre ce qui se passe quand quelque chose échoue ou charge.

## Acceptance Criteria

1. Toutes les erreurs API/Supabase sont interceptées et affichées avec un message utilisateur lisible (pas de raw JSON/stack trace).
2. Tous les états de chargement ont un indicateur visuel cohérent (spinner + label selon le composant).
3. Les erreurs de connectivité réseau ont un message dédié et une action de retry.
4. Les messages d'erreur sont traduits en FR et EN (via i18n), avec best-effort pour ES et DE.
5. Tests widget couvrant les états d'erreur sur les composants principaux.

---

## Tasks / Subtasks

- [x] AC4 — Clés i18n génériques (AC: 4)
  - [x] Ajouter 7 clés dans `lib/l10n/app_fr.arb` (voir Dev Notes — section i18n)
  - [x] Ajouter les mêmes clés dans `lib/l10n/app_en.arb`, `app_es.arb`, `app_de.arb`
  - [x] Régénérer les localisations : `flutter gen-l10n`
  - [x] Vérifier `flutter analyze --no-pub` → 0 erreur

- [x] AC1+AC3 — Widget générique `AppErrorWidget` (AC: 1, 3, 5)
  - [x] Créer `lib/presentation/widgets/common/error/app_error_widget.dart`
  - [x] Implémenter `AppErrorWidget` (const constructor avec `title`, `message`, `isNetworkError`, `onRetry?`)
  - [x] Implémenter `AppErrorWidget.fromError({context, error, onRetry?})` — static factory utilisant `ExceptionHandler.handle()`
  - [x] Écrire `test/presentation/widgets/common/app_error_widget_test.dart` — 6 cas (voir Dev Notes)

- [x] AC1+AC2+AC3 — Fix `tasks_page.dart` (AC: 1, 2, 3)
  - [x] Importer `AppLocalizations`, `AppErrorWidget`
  - [x] Loading : remplacer `CircularProgressIndicator()` seul → `Column` avec `CircularProgressIndicator` + `Text(l10n.loading)`
  - [x] Error : remplacer `Center(child: Text('Erreur: $error'))` → `Center(child: AppErrorWidget.fromError(context: context, error: error, onRetry: () => ref.invalidate(allTasksProvider)))`

- [x] AC1+AC2 — Fix `list_detail_loader_page.dart` (AC: 1, 2)
  - [x] Importer `AppLocalizations`, `AppErrorWidget`
  - [x] Mettre à jour `_buildLoadingState()` → accepter `BuildContext context`, utiliser `l10n.loadingListDetail` au lieu du string hardcodé
  - [x] Mettre à jour les appels à `_buildLoadingState()` → passer `context` en argument
  - [x] `_buildErrorState` : remplacer `Text('Erreur: $error')` → `AppErrorWidget.fromError(context: context, error: error)` (sans retry — fallback pop via AppBar)
  - [x] `_buildNoListsState` : utiliser `l10n.noListsTitle` et `l10n.noListsBody`

- [x] AC1 — Fix `habits_controller.dart` (AC: 1)
  - [x] Importer `app_exception.dart`
  - [x] Remplacer les 3× `error.toString()` → `ExceptionHandler.handle(error).displayMessage`

- [x] AC1 — Fix `habit_action_handler.dart` (AC: 1)
  - [x] Importer `app_exception.dart`
  - [x] Remplacer les 4× `error.toString()` → `ExceptionHandler.handle(error).displayMessage`

- [x] AC3 — Wire retry habitudes (AC: 3)
  - [x] `habits_body.dart` : ajouter `required VoidCallback onRetry` au constructeur
  - [x] `habits_body.dart` : passer `onRetry: onRetry` à `HabitsErrorState`
  - [x] `habits_page.dart` : passer `onRetry: () => ref.read(habitsStateProvider.notifier).loadHabits()` à `HabitsBody`

- [x] Validation qualité finale
  - [x] `flutter analyze --no-pub` → 0 erreur dans les fichiers modifiés
  - [x] `flutter test test/presentation/widgets/common/app_error_widget_test.dart` → 6/6
  - [x] `flutter test --exclude-tags integration` → aucune régression (failures pré-existantes, 0 régression story 7.5)

---

## Dev Notes

### Architecture — Vue d'ensemble

Ce refactoring est **chirurgical** : corriger uniquement les points d'affichage raw d'erreurs identifiés. Ne pas modifier les patterns existants (HabitsErrorState, habitsError* i18n, etc.) au-delà du strict nécessaire.

**Infrastructure DÉJÀ EXISTANTE à réutiliser — NE PAS RÉINVENTER :**
- `lib/core/exceptions/app_exception.dart` — `AppException`, `ExceptionHandler`, `ErrorType`
  - `ExceptionHandler.handle(error)` → convertit n'importe quelle exception en `AppException`
  - `AppException.displayMessage` → toujours un message utilisateur lisible (jamais raw JSON)
  - `ErrorType.network` et `ErrorType.timeout` → détecter erreur réseau
- `lib/l10n/app_fr.arb` / `app_en.arb` — clés existantes pertinentes :
  - `"error"` → "Erreur" / "Error"
  - `"loading"` → "Chargement..." / "Loading..."
  - `"retry"` → "Réessayer" / "Retry"
  - `"habitsErrorNetwork"`, `"habitsErrorTimeout"`, `"habitsErrorUnexpected"` — déjà i18n pour habitudes
- `test/helpers/localized_widget.dart` — `localizedApp(Widget)` pour les tests widget avec l10n

**Fichiers à NE PAS TOUCHER (hors scope) :**
- `lib/presentation/pages/habits/components/habits_list_view.dart` — `buildErrorState()` est dead code (jamais appelé depuis l'extérieur), hors scope
- `lib/presentation/pages/lists/**` — controllers, state, event_handler — fix non prioritaire, hors scope story 7.5
- `lib/presentation/pages/auth/` — déjà correctement géré avec `LoginErrorDisplay`

---

### Section i18n — Clés à ajouter (AC4)

#### `lib/l10n/app_fr.arb` — ajouter AVANT le `}` final

```json
  "errorGenericTitle": "Une erreur est survenue",
  "@errorGenericTitle": {
    "description": "Titre générique d'état d'erreur"
  },
  "errorNetworkTitle": "Problème de connexion",
  "@errorNetworkTitle": {
    "description": "Titre d'état d'erreur réseau"
  },
  "errorNetworkMessage": "Vérifiez votre connexion internet et réessayez.",
  "@errorNetworkMessage": {
    "description": "Message d'erreur réseau avec invitation à réessayer"
  },
  "errorGenericMessage": "Une erreur inattendue s'est produite. Veuillez réessayer.",
  "@errorGenericMessage": {
    "description": "Message d'erreur générique avec invitation à réessayer"
  },
  "loadingListDetail": "Chargement de votre liste...",
  "@loadingListDetail": {
    "description": "Texte de chargement affiché sur la page de détail d'une liste"
  },
  "noListsTitle": "Aucune liste disponible",
  "@noListsTitle": {
    "description": "Titre état vide : aucune liste"
  },
  "noListsBody": "Créez votre première liste pour commencer.",
  "@noListsBody": {
    "description": "Corps état vide : invitation à créer une liste"
  }
```

#### `lib/l10n/app_en.arb` — mêmes clés en anglais

```json
  "errorGenericTitle": "An error occurred",
  "@errorGenericTitle": {
    "description": "Generic error state title"
  },
  "errorNetworkTitle": "Connection issue",
  "@errorNetworkTitle": {
    "description": "Network error state title"
  },
  "errorNetworkMessage": "Check your internet connection and try again.",
  "@errorNetworkMessage": {
    "description": "Network error message with retry invitation"
  },
  "errorGenericMessage": "An unexpected error occurred. Please try again.",
  "@errorGenericMessage": {
    "description": "Generic error message with retry invitation"
  },
  "loadingListDetail": "Loading your list...",
  "@loadingListDetail": {
    "description": "Loading text shown on the list detail page"
  },
  "noListsTitle": "No lists available",
  "@noListsTitle": {
    "description": "Empty state title: no lists"
  },
  "noListsBody": "Create your first list to get started.",
  "@noListsBody": {
    "description": "Empty state body: invitation to create a list"
  }
```

#### `lib/l10n/app_es.arb` et `app_de.arb` — best-effort (copie EN)

Ajouter les mêmes clés avec les valeurs anglaises (best-effort, cohérent avec story 7.4).

---

### Spec complète — `AppErrorWidget`

**Fichier** : `lib/presentation/widgets/common/error/app_error_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:prioris/core/exceptions/app_exception.dart';
import 'package:prioris/l10n/app_localizations.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final bool isNetworkError;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.isNetworkError = false,
    this.onRetry,
  });

  static Widget fromError({
    required BuildContext context,
    required Object error,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final appEx = error is AppException
        ? error
        : ExceptionHandler.handle(error);
    final isNetwork = appEx.type == ErrorType.network ||
        appEx.type == ErrorType.timeout;
    return AppErrorWidget(
      title: isNetwork ? l10n.errorNetworkTitle : l10n.errorGenericTitle,
      message: isNetwork ? l10n.errorNetworkMessage : l10n.errorGenericMessage,
      isNetworkError: isNetwork,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}
```

**Taille** : ~70 lignes (≤ 500L ✅, méthodes ≤ 50L ✅).

---

### Spec — Fix `tasks_page.dart`

**Imports à ajouter** (après les imports existants) :
```dart
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/common/error/app_error_widget.dart';
```

**Dans `build()`**, ajouter en premier dans le corps de la méthode :
```dart
final l10n = AppLocalizations.of(context)!;
```

**Remplacer le bloc `when`** (lignes 50-58) :
```dart
body: tasksAsync.when(
  data: (tasks) => tasks.isEmpty
      ? _buildEmptyState()
      : _buildTasksList(tasks),
  loading: () => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(l10n.loading),
      ],
    ),
  ),
  error: (error, stack) => Center(
    child: AppErrorWidget.fromError(
      context: context,
      error: error,
      onRetry: () => ref.invalidate(allTasksProvider),
    ),
  ),
),
```

---

### Spec — Fix `list_detail_loader_page.dart`

**Imports à ajouter** :
```dart
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/common/error/app_error_widget.dart';
```

**Mettre à jour `_buildLoadingState`** — ajouter `BuildContext context` en paramètre :
```dart
Widget _buildLoadingState(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.loadingListDetail),
        ],
      ),
    ),
  );
}
```

**Mettre à jour les 2 appels** (actuellement `_buildLoadingState()`) → `_buildLoadingState(context)`.

**Mettre à jour `_buildErrorState`** :
```dart
Widget _buildErrorState(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;
  return Scaffold(
    appBar: AppBar(title: Text(l10n.error)),
    body: Center(
      child: AppErrorWidget.fromError(context: context, error: error),
    ),
  );
}
```

**Mettre à jour `_buildNoListsState`** :
```dart
Widget _buildNoListsState(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Scaffold(
    appBar: AppBar(title: Text(l10n.noListsTitle)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noListsTitle),
          const SizedBox(height: 8),
          Text(l10n.noListsBody),
        ],
      ),
    ),
  );
}
```

---

### Spec — Fix `habits_controller.dart`

**Import à ajouter** :
```dart
import 'package:prioris/core/exceptions/app_exception.dart';
```

**Remplacer** `error.toString()` par `ExceptionHandler.handle(error).displayMessage` dans les 3 catch (lignes ~28, ~45, ~62). Exemple :
```dart
} catch (error) {
  state = state.copyWith(
    lastAction: HabitAction.added,
    lastActionMessage: _l10n.habitsActionCreateError(
      ExceptionHandler.handle(error).displayMessage,
    ),
    actionResult: ActionResult.error,
  );
}
```

---

### Spec — Fix `habit_action_handler.dart`

**Import à ajouter** :
```dart
import 'package:prioris/core/exceptions/app_exception.dart';
```

**Remplacer** `error.toString()` par `ExceptionHandler.handle(error).displayMessage` dans les 4 catch (lignes ~60, ~72, ~96, ~107). Exemple :
```dart
} catch (error) {
  if (_context.mounted) Navigator.of(_context).pop();
  _showActionError(
    _l10n.habitsActionRecordError(
      ExceptionHandler.handle(error).displayMessage,
    ),
  );
}
```

---

### Spec — Wire retry habitudes

**`lib/presentation/pages/habits/components/habits_body.dart`** :

Ajouter `required VoidCallback onRetry` dans le constructeur (après `this.error`), et le passer à `HabitsErrorState` :
```dart
// Dans le constructeur :
required this.onRetry,
// Dans la déclaration des champs :
final VoidCallback onRetry;
// Dans build() :
return HabitsErrorState(
  error: error!,
  onRetry: onRetry,  // ← remplace () {}
);
```

**`lib/presentation/pages/habits_page.dart`** :

Dans `HabitsBody(...)`, ajouter le paramètre :
```dart
onRetry: () => ref.read(habitsStateProvider.notifier).loadHabits(),
```

---

### Tests — `AppErrorWidget` (6 cas)

**Fichier** : `test/presentation/widgets/common/app_error_widget_test.dart`

Utiliser `localizedApp()` de `test/helpers/localized_widget.dart`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/exceptions/app_exception.dart';
import 'package:prioris/presentation/widgets/common/error/app_error_widget.dart';
import '../../../helpers/localized_widget.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('affiche icône error_outline pour erreur générique', ...);
    testWidgets('affiche icône wifi_off pour erreur réseau', ...);
    testWidgets('affiche le bouton Réessayer si onRetry fourni', ...);
    testWidgets('n\'affiche pas de bouton si onRetry null', ...);
    testWidgets('fromError : AppException.network → isNetworkError = true', ...);
    testWidgets('fromError : Exception générique → isNetworkError = false', ...);
  });
}
```

Cas nominaux et edge cases à couvrir :
1. `AppErrorWidget(title: 'T', message: 'M', isNetworkError: false)` → icône `Icons.error_outline` visible
2. `AppErrorWidget(title: 'T', message: 'M', isNetworkError: true)` → icône `Icons.wifi_off` visible
3. `AppErrorWidget(..., onRetry: () {})` → bouton avec `l10n.retry` visible
4. `AppErrorWidget(...)` sans onRetry → pas de bouton Réessayer
5. `AppErrorWidget.fromError(context, AppException.network(message: 'net'))` → widget réseau affiché
6. `AppErrorWidget.fromError(context, Exception('unknown'))` → widget générique affiché

---

### Commandes de validation

```bash
# Régénération i18n
flutter gen-l10n

# Analyse statique
flutter analyze --no-pub

# Tests AppErrorWidget
flutter test test/presentation/widgets/common/app_error_widget_test.dart

# Suite complète hors intégration réseau
flutter test --exclude-tags integration
```

---

### Apprentissages des stories précédentes

- `test/helpers/localized_widget.dart` existe depuis story 7.3 — utiliser `localizedApp()` pour les tests widget avec l10n (**NE PAS recréer**).
- `flutter analyze --no-pub` obligatoire avant de déclarer terminé.
- Les clés ARB avec `@clé` + `description` sont requises — inclure les métadonnées.
- `ExceptionHandler.handle(error)` ne jette pas — il retourne toujours un `AppException` safe.
- Vérifier `context.mounted` après tout `await` qui utilise `context` ensuite (pattern existant dans le projet).
- Environnement puro `prioris-328` — utiliser `flutter analyze --no-pub` et tests ciblés.

---

### Zones à NE PAS toucher dans cette story

- `habits_list_view.dart` — `buildErrorState()` est dead code (jamais appelé depuis l'extérieur) — hors scope
- `lists_state.dart`, `lists_event_handler.dart`, `lists_state_service.dart` — contiennent `'Erreur: $errorMessage'` (string déjà formée, non raw exception) — hors scope story 7.5

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- `flutter gen-l10n` nécessite PowerShell avec puro binary (bash shell ne trouve pas `flutter`)
- `habits_body_test.dart` utilisait `MaterialApp` nu → crash `AppLocalizations.of(context)!` dans `HabitCard._buildCategory` → corrigé avec `localizedApp()`

### Completion Notes List

- Tous les ACs implémentés en approche chirurgicale : seuls les fichiers identifiés en Dev Notes ont été modifiés
- Widget `AppErrorWidget` : ~70 lignes, SRP respecté, factory statique `fromError` découplée du build
- Clés i18n ajoutées avec métadonnées `@` dans les 4 locales (fr, en, es best-effort, de best-effort)
- `habits_body_test.dart` migré vers `localizedApp()` (fix pré-existant découvert lors de la validation)
- Failures pré-existantes dans la suite complète sont sans lien avec story 7.5 (duel, frequency_summary, architecture RED tests)

### File List

**Nouveaux :**
- `lib/presentation/widgets/common/error/app_error_widget.dart`
- `test/presentation/widgets/common/app_error_widget_test.dart`

**Modifiés :**
- `lib/l10n/app_fr.arb` — 7 nouvelles clés i18n
- `lib/l10n/app_en.arb` — 7 nouvelles clés i18n
- `lib/l10n/app_es.arb` — 7 nouvelles clés i18n (best-effort EN)
- `lib/l10n/app_de.arb` — 7 nouvelles clés i18n (best-effort EN)
- `lib/presentation/pages/tasks_page.dart` — loading/error states améliorés
- `lib/presentation/pages/list_detail_loader_page.dart` — loading/error/noLists states i18n + AppErrorWidget
- `lib/presentation/pages/habits/controllers/habits_controller.dart` — ExceptionHandler dans les 3 catch
- `lib/presentation/pages/habits/services/habit_action_handler.dart` — ExceptionHandler dans les 4 catch
- `lib/presentation/pages/habits/components/habits_body.dart` — onRetry wired
- `lib/presentation/pages/habits_page.dart` — onRetry passé à HabitsBody
- `test/presentation/pages/habits/components/habits_body_test.dart` — localizedApp() + onRetry

### Change Log

| Date       | Version | Description                                             | Author           |
|------------|---------|---------------------------------------------------------|------------------|
| 2026-04-26 | 1.0     | Implémentation complète story 7.5 — messages d'erreur et états de chargement globaux | claude-sonnet-4-6 |
