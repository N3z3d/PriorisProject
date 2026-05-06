# Story 8.3 : Détecter quit/refresh pendant import massif

Status: done

## Story

En tant qu'utilisateur,
je veux être informé de l'état partiel de mon import si je quitte ou rafraîchis l'application en cours d'opération,
afin de comprendre combien d'éléments ont été importés et ne pas perdre de données silencieusement.

## Acceptance Criteria

1. Si l'utilisateur quitte l'app (`AppLifecycleState.paused/detached`) pendant un import en cours, un message d'état est persisté (nombre d'éléments traités / total)
2. Au retour dans l'app, l'état partiel est affiché : "Import interrompu — X/Y éléments ajoutés"
3. Si l'utilisateur rafraîchit la page web pendant l'import, le message d'état partiel est affiché au rechargement (via SharedPreferences qui, sur Flutter Web, utilise localStorage)
4. Tests widget couvrant les scénarios : import complet, interruption mid-import, retour après interruption
5. `flutter analyze --no-pub` propre, aucune régression (suite `flutter test --exclude-tags integration` reste à 0 échec)

---

## Tasks / Subtasks

- [x] **T1 — Créer `ImportInterruptService`** (AC: 1, 2, 3)
  - [x] T1.1 — Créer `lib/infrastructure/services/import_interrupt_service.dart` — singleton, SharedPreferences-backed, API : `onProgress`, `onComplete`, `checkAndLoadPersistedState`, `consumeStartupInterrupt`
  - [x] T1.2 — Créer `test/infrastructure/services/import_interrupt_service_test.dart` — 5 tests unitaires (voir Dev Notes)

- [x] **T2 — Connecter `ImportInterruptService` au cycle de démarrage** (AC: 2, 3)
  - [x] T2.1 — Dans `lib/core/bootstrap/app_initializer.dart`, appeler `await ImportInterruptService.instance.checkAndLoadPersistedState()` à la fin de `_initializeServices()` (après `SupabaseService.initialize()` et `languageService.initialize()`)

- [x] **T3 — Modifier `BulkAddDialog` : suivi de progression + cycle de vie** (AC: 1)
  - [x] T3.1 — Ajouter `WidgetsBindingObserver` mixin à `_BulkAddDialogState`
  - [x] T3.2 — Dans `initState` : appeler `WidgetsBinding.instance.addObserver(this)` ; dans `dispose` : appeler `WidgetsBinding.instance.removeObserver(this)`
  - [x] T3.3 — Override `didChangeAppLifecycleState` : si `_isSubmitting && (state == paused || state == detached)` → appeler `ImportInterruptService.instance.onProgress(_processedCount, _totalCount).ignore()`
  - [x] T3.4 — Dans `_handleSubmit` : dans le callback `onProgress`, appeler `ImportInterruptService.instance.onProgress(current, total).ignore()` (fire-and-forget, non-bloquant)
  - [x] T3.5 — Dans `_handleSubmit` : appeler `await ImportInterruptService.instance.onComplete()` dans les chemins succès (avant `Navigator.pop` ou avant reset keep-open), dans le `on BulkAddCancelException` et dans le `catch (e)` final

- [x] **T4 — Modifier `HomePage` : afficher la bannière au démarrage** (AC: 2, 3)
  - [x] T4.1 — Convertir `HomePage` de `ConsumerWidget` en `ConsumerStatefulWidget` + `ConsumerState<HomePage>` (migration 1:1, voir Dev Notes — section Migration exacte)
  - [x] T4.2 — Dans `_HomePageState.initState()`, appeler `_checkForInterruptedImport()` 
  - [x] T4.3 — Implémenter `_checkForInterruptedImport()` : consomme `ImportInterruptService.instance.consumeStartupInterrupt()`, si non-null → `addPostFrameCallback` → `showSnackBar` avec `l10n.importInterruptedBanner(current, total)` (duration: 6 secondes)

- [x] **T5 — Ajouter la clé i18n `importInterruptedBanner`** (AC: 2, 3)
  - [x] T5.1 — Ajouter dans les 4 ARBs (voir Dev Notes — Clés i18n exactes)
  - [x] T5.2 — Régénérer : `puro flutter gen-l10n`

- [x] **T6 — Tests widget `BulkAddDialog`** (AC: 4)
  - [x] T6.1 — Créer `test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart` — 4 tests (voir Dev Notes)

- [x] **T7 — Validation finale** (AC: 5)
  - [x] T7.1 — `puro flutter analyze --no-pub` → 0 erreur dans les fichiers modifiés (infos sort_constructors pré-existantes, pas d'erreur)
  - [x] T7.2 — `puro flutter test --exclude-tags integration --no-pub` → +1956 ~26 : All tests passed! (0 régression, 26 skipped pré-existants)
  - [ ] T7.3 — Test manuel : démarrer un import de 10+ items, fermer/rouvrir l'app (ou simuler lifecycle), vérifier snackbar au retour

---

## Dev Notes

### Contexte technique — ce qui existe

#### Flux actuel de l'import massif

```
BulkAddDialog._handleSubmit()
  → widget.onSubmit(items, onProgress)    ← liste vient de list_detail_page.dart
  → [onProgress(current, total)] × N     ← callback appelé par addMultipleItems
  → Navigator.pop(processedCount)
```

Dans `lib/presentation/pages/list_detail_page.dart` (ligne ~223) :
```dart
Future<void> _showBulkAddDialog() async {
  final count = await showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BulkAddDialog(
      onSubmit: (itemTitles, onProgress) async {
        // ... duplicate detection, item creation ...
        await ref.read(listsControllerProvider.notifier)
            .addMultipleItems(widget.list.id, items, onProgress: onProgress);
        onProgress(titlesToAdd.length, titlesToAdd.length); // completion mark
      },
    ),
  );
  if (count != null && count > 0 && context.mounted) { /* show success snackbar */ }
}
```

#### Pattern singleton infrastructure existant

`LoggerService.instance`, `WebAuthCallbackStabilizer` (static methods). Pattern suivi :
```dart
class ImportInterruptService {
  static final ImportInterruptService instance = ImportInterruptService._();
  ImportInterruptService._();
  // ...
}
```

#### Pattern platform-web existant (NE PAS utiliser pour cette story)

Le projet utilise `dart:html` via des fichiers `_web.dart` / `_stub.dart` pour `WebAuthCallbackBrowserAdapter`. **Cette story n'a pas besoin de ce pattern** : `SharedPreferences` sur Flutter Web utilise déjà `localStorage` en interne — pas de code plateforme spécifique requis.

#### Pattern lifecycle + WidgetsBindingObserver existant

`lib/core/bootstrap/app_lifecycle_manager.dart` utilise déjà ce pattern. `_BulkAddDialogState` doit l'adopter de façon identique.

---

### T1.1 — `lib/infrastructure/services/import_interrupt_service.dart` (NOUVEAU)

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ImportInterruptService {
  static final ImportInterruptService instance = ImportInterruptService._();
  ImportInterruptService._();

  static const String _progressKey = 'import_interrupt_current_v1';
  static const String _totalKey = 'import_interrupt_total_v1';

  ({int current, int total})? _startupInterrupt;

  // Appelé une seule fois par AppInitializer._initializeServices()
  Future<void> checkAndLoadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_progressKey);
    final total = prefs.getInt(_totalKey);
    if (current != null && total != null && total > 0) {
      _startupInterrupt = (current: current, total: total);
      await Future.wait([prefs.remove(_progressKey), prefs.remove(_totalKey)]);
    }
  }

  // Appelé une seule fois par HomePage.initState() — read-and-clear
  ({int current, int total})? consumeStartupInterrupt() {
    final result = _startupInterrupt;
    _startupInterrupt = null;
    return result;
  }

  // Appelé par BulkAddDialog sur chaque onProgress (fire-and-forget)
  Future<void> onProgress(int current, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_progressKey, current),
      prefs.setInt(_totalKey, total),
    ]);
  }

  // Appelé par BulkAddDialog sur succès/annulation/erreur
  Future<void> onComplete() async {
    _startupInterrupt = null;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.remove(_progressKey), prefs.remove(_totalKey)]);
  }
}
```

**Contraintes :** 
- Classe < 500 lignes ✓ (~40 lignes)
- `shared_preferences` est déjà une dépendance du projet (utilisé par `ConsentService`)
- Pas de nouveau package requis

---

### T1.2 — `test/infrastructure/services/import_interrupt_service_test.dart` (NOUVEAU)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ImportInterruptService', () {
    test('onProgress persiste current/total dans SharedPreferences', () async {
      final service = ImportInterruptService.instance;
      await service.onProgress(5, 10);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), equals(5));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(10));
    });

    test('onComplete efface les clés de SharedPreferences', () async {
      final service = ImportInterruptService.instance;
      await service.onProgress(3, 10);
      await service.onComplete();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
      expect(prefs.getInt('import_interrupt_total_v1'), isNull);
    });

    test('checkAndLoadPersistedState charge l\'état depuis SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 42,
        'import_interrupt_total_v1': 100,
      });
      final service = ImportInterruptService.instance;
      // Reset du singleton pour ce test
      await service.onComplete(); // clear _startupInterrupt
      await service.checkAndLoadPersistedState();
      final result = service.consumeStartupInterrupt();
      expect(result, isNotNull);
      expect(result!.current, equals(42));
      expect(result.total, equals(100));
    });

    test('checkAndLoadPersistedState efface les clés après lecture', () async {
      SharedPreferences.setMockInitialValues({
        'import_interrupt_current_v1': 7,
        'import_interrupt_total_v1': 20,
      });
      final service = ImportInterruptService.instance;
      await service.checkAndLoadPersistedState();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
    });

    test('consumeStartupInterrupt retourne null si aucun état persisté', () async {
      final service = ImportInterruptService.instance;
      await service.onComplete(); // garantit _startupInterrupt = null
      expect(service.consumeStartupInterrupt(), isNull);
    });
  });
}
```

> **Note** : `ImportInterruptService` est un singleton statique. Les tests peuvent interférer entre eux si `_startupInterrupt` est pollué. Utiliser `await service.onComplete()` en `setUp` si le singleton est partagé (à ajouter dans `setUp` si nécessaire selon l'isolation constatée).

---

### T2.1 — `lib/core/bootstrap/app_initializer.dart` (MODIFIER)

Ajouter dans `_initializeServices()` **après** `languageService.initialize()` :

```dart
// Import à ajouter en haut du fichier :
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';

// Dans _initializeServices(), après languageService.initialize() :
await ImportInterruptService.instance.checkAndLoadPersistedState();
logger.debug('Import interrupt state checked', context: _context);
```

**Pourquoi ici** : `_initializeServices()` est le bon endroit — SharedPreferences est disponible à ce stade (Hive et config déjà initialisés), et l'appel précède la création du `ProviderScope` dans `main.dart` → le state sera disponible quand `HomePage` se montera.

---

### T3 — Modifications `lib/presentation/widgets/dialogs/bulk_add_dialog.dart` (MODIFIER)

**État actuel** : 280 lignes. `_BulkAddDialogState extends State<BulkAddDialog> with TickerProviderStateMixin`.

**Import à ajouter en haut :**
```dart
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';
```

**Changement 1 — Déclaration de la classe State (ligne ~52) :**
```dart
// AVANT
class _BulkAddDialogState extends State<BulkAddDialog> with TickerProviderStateMixin {

// APRÈS
class _BulkAddDialogState extends State<BulkAddDialog>
    with TickerProviderStateMixin, WidgetsBindingObserver {
```

**Changement 2 — `initState()` : ajouter l'observer :**
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this); // ← AJOUTER
  _controller = TextEditingController();
  // ... reste inchangé
}
```

**Changement 3 — `dispose()` : retirer l'observer :**
```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this); // ← AJOUTER en premier
  _controller.dispose();
  _focusNode.dispose();
  _tabController.dispose();
  super.dispose();
}
```

**Changement 4 — Override `didChangeAppLifecycleState` (ajouter après `dispose`) :**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (_isSubmitting &&
      (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached)) {
    ImportInterruptService.instance
        .onProgress(_processedCount, _totalCount)
        .ignore();
  }
}
```

**Changement 5 — `_handleSubmit()` : call service dans le callback onProgress (ligne ~112) :**
```dart
// Dans widget.onSubmit(items, (current, total) { ... })
final submitFuture = widget.onSubmit(items, (current, total) {
  if (mounted) setState(() { _processedCount = current; _totalCount = total; });
  ImportInterruptService.instance.onProgress(current, total).ignore(); // ← AJOUTER
});
```

**Changement 6 — `_handleSubmit()` : appel onComplete dans les chemins de sortie :**

_Chemin keep-open (succès) :_
```dart
if (_keepOpen) {
  await Future.wait([
    submitFuture,
    Future.delayed(const Duration(milliseconds: 300)),
  ]);
  await ImportInterruptService.instance.onComplete(); // ← AJOUTER
  if (mounted) {
    setState(() { _isSubmitting = false; _processedCount = 0; _totalCount = 0; });
    _controller.clear();
    _focusNode.requestFocus();
  }
```

_Chemin normal (succès, ligne ~128) :_
```dart
} else {
  await submitFuture;
  await ImportInterruptService.instance.onComplete(); // ← AJOUTER
  if (mounted) {
    Navigator.of(context).pop(_processedCount > 0 ? _processedCount : items.length);
  }
}
```

_Chemin `BulkAddCancelException` :_
```dart
on BulkAddCancelException {
  await ImportInterruptService.instance.onComplete(); // ← AJOUTER
  if (mounted) setState(() { _isSubmitting = false; _submitError = null; });
}
```

_Chemin `catch (e)` :_
```dart
catch (e) {
  await ImportInterruptService.instance.onComplete(); // ← AJOUTER
  if (mounted) setState(() { _isSubmitting = false; _submitError = e.toString(); });
}
```

**Après modifications** : ~310 lignes. Bien sous les 500.

---

### T4 — Migration `lib/presentation/pages/home_page.dart` (MODIFIER)

**Migration `ConsumerWidget` → `ConsumerStatefulWidget`**

`HomePage` est actuellement un `ConsumerWidget`. La migration est chirurgicale — seul le wrapper change.

**Imports à ajouter en haut :**
```dart
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';
```
(L'import `app_localizations.dart` est déjà présent ou à ajouter si absent)

**Changement de la classe :**
```dart
// AVANT
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... corps existant ...
  }
  
  // ... toutes les méthodes _build* existantes ...
}

// APRÈS
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    _checkForInterruptedImport();
  }

  void _checkForInterruptedImport() {
    final interruptState =
        ImportInterruptService.instance.consumeStartupInterrupt();
    if (interruptState == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (l10n == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importInterruptedBanner(
            interruptState.current,
            interruptState.total,
          )),
          duration: const Duration(seconds: 6),
          backgroundColor: AppTheme.warningColor, // ou Colors.orange si absent
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // IDENTIQUE à l'ancien build de ConsumerWidget — ref est accessible directement
    final currentPage = ref.watch(currentPageProvider);
    // ... reste du build() INCHANGÉ ...
  }

  // Toutes les méthodes _build* restent INCHANGÉES, déplacées dans _HomePageState
  // Elles continuent d'utiliser context et ref comme paramètres (inchangé)
}
```

**Précaution** : `AppTheme.warningColor` — vérifier que cette constante existe dans `lib/presentation/theme/app_theme.dart`. Si absente, utiliser `Colors.orange` ou `AppTheme.errorColor`. Ne pas créer une nouvelle constante.

**Précaution** : `AppLocalizations.of(context)` peut être null si `AppLocalizations` n'est pas importé. Vérifier les imports existants de `home_page.dart`.

---

### T5 — Clés i18n (4 ARBs)

**Clé à ajouter dans les 4 fichiers ARB** — insérer à la fin du fichier (avant l'accolade fermante) :

**`lib/l10n/app_fr.arb`** :
```json
"importInterruptedBanner": "Import interrompu — {current}/{total} éléments ajoutés",
"@importInterruptedBanner": {
  "placeholders": {
    "current": { "type": "int" },
    "total": { "type": "int" }
  }
}
```

**`lib/l10n/app_en.arb`** :
```json
"importInterruptedBanner": "Import interrupted — {current}/{total} items added",
"@importInterruptedBanner": {
  "placeholders": {
    "current": { "type": "int" },
    "total": { "type": "int" }
  }
}
```

**`lib/l10n/app_de.arb`** :
```json
"importInterruptedBanner": "Import unterbrochen — {current}/{total} Elemente hinzugefügt",
"@importInterruptedBanner": {
  "placeholders": {
    "current": { "type": "int" },
    "total": { "type": "int" }
  }
}
```

**`lib/l10n/app_es.arb`** :
```json
"importInterruptedBanner": "Importación interrumpida — {current}/{total} elementos añadidos",
"@importInterruptedBanner": {
  "placeholders": {
    "current": { "type": "int" },
    "total": { "type": "int" }
  }
}
```

**Commande :** `puro flutter gen-l10n`

---

### T6 — `test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart` (NOUVEAU)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/infrastructure/services/import_interrupt_service.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/localized_widget.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ImportInterruptService.instance.onComplete(); // reset singleton
  });

  group('BulkAddDialog — interruption detection', () {
    testWidgets('import complet : état effacé de SharedPreferences', (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) {
            onProgress(1, 1);
            return completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      completer.complete();
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
      expect(prefs.getInt('import_interrupt_total_v1'), isNull);
    });

    testWidgets('import en cours : onProgress persiste dans SharedPreferences',
        (tester) async {
      late void Function(int, int) capturedProgress;
      final completer = Completer<void>();

      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) {
            capturedProgress = onProgress;
            return completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      capturedProgress(3, 10);
      await tester.pump();

      // Laisser le temps au fire-and-forget de s'exécuter
      await tester.pump(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), equals(3));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(10));

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('annulation pendant import : état effacé (BulkAddCancelException)',
        (tester) async {
      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) async {
            onProgress(2, 5);
            throw BulkAddCancelException();
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), isNull);
    });

    testWidgets(
        'lifecycle paused pendant import : état déjà persisté (état vérifié)',
        (tester) async {
      late void Function(int, int) capturedProgress;
      final completer = Completer<void>();

      await tester.pumpWidget(localizedApp(
        BulkAddDialog(
          onSubmit: (items, onProgress) {
            capturedProgress = onProgress;
            return completer.future;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      capturedProgress(5, 10);
      await tester.pump(const Duration(milliseconds: 50));

      // Simuler AppLifecycleState.paused
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 50));

      // L'état doit être persisté (écrit par onProgress + renforcé par didChangeAppLifecycleState)
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('import_interrupt_current_v1'), equals(5));
      expect(prefs.getInt('import_interrupt_total_v1'), equals(10));

      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
```

---

### Précautions critiques

1. **`WidgetsBindingObserver` + `AppLifecycleManager`** : deux observateurs actifs simultanément ne posent pas de problème — `WidgetsBinding` supporte de multiples observateurs. `AppLifecycleManager` continue d'exister et de gérer Hive ; `_BulkAddDialogState` gère uniquement son import en cours.

2. **Fire-and-forget `.ignore()`** : `onProgress` est appelé potentiellement 300× en 30 secondes. Chaque appel est fire-and-forget (`.ignore()` supprime le lint warning `unawaited_futures`). SharedPreferences est thread-safe et les écritures successives s'écrasent naturellement. La dernière écriture persistée est la plus récente.

3. **Isolation du singleton dans les tests** : `ImportInterruptService.instance` est un singleton de classe. Les tests partagent la même instance. Ajouter `await ImportInterruptService.instance.onComplete()` dans le `setUp()` de chaque groupe de tests pour garantir un état propre.

4. **`AppTheme.warningColor`** : Si cette constante n'existe pas dans `app_theme.dart`, utiliser `Colors.orange[700]` directement. Ne pas ajouter de constante hors scope.

5. **`AppLocalizations` import dans `home_page.dart`** : vérifier que `import 'package:prioris/l10n/app_localizations.dart';` est déjà présent (probable, la page est localisée) avant d'ajouter.

6. **Comportement sur web F5 ≠ comportement mobile** : Sur Flutter Web, quand l'utilisateur fait F5, Flutter est détruit sans déclencher `AppLifecycleState.paused` de façon fiable. La robustesse de la solution web repose sur le fait que chaque `onProgress` écrit dans SharedPreferences (qui est localStorage sur web). Dès lors, après F5, l'app relit les clés dans `checkAndLoadPersistedState()` et le state est disponible. C'est le design voulu — pas un bug.

7. **Ne pas toucher `list_detail_page.dart`** : La story 7.3 a déjà implémenté le threading de `onProgress` à travers les couches. Le callback `onProgress` est appelé correctement. La seule modification est dans `BulkAddDialog` (T3) qui intercepte ce callback.

8. **Commandes PowerShell + puro uniquement** :
   ```powershell
   puro flutter gen-l10n
   puro flutter analyze --no-pub
   puro flutter test --exclude-tags integration --no-pub
   puro flutter test test/infrastructure/services/import_interrupt_service_test.dart
   puro flutter test test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart
   ```

9. **Hors scope (ne pas adresser)** : Les review findings déférés de la story 7.3 (strings françaises hard-codées, "0/N" affiché immédiatement, etc.) restent hors scope.

---

### Structure des fichiers

```
lib/infrastructure/services/import_interrupt_service.dart       ← NOUVEAU
lib/core/bootstrap/app_initializer.dart                         ← MODIFIER (~+3 lignes)
lib/presentation/widgets/dialogs/bulk_add_dialog.dart           ← MODIFIER (~+20 lignes)
lib/presentation/pages/home_page.dart                           ← MODIFIER (migration StatefulWidget + initState)
lib/l10n/app_fr.arb                                             ← MODIFIER (+1 clé avec @)
lib/l10n/app_en.arb                                             ← MODIFIER (+1 clé avec @)
lib/l10n/app_de.arb                                             ← MODIFIER (+1 clé avec @)
lib/l10n/app_es.arb                                             ← MODIFIER (+1 clé avec @)
lib/l10n/app_localizations*.dart                                ← GÉNÉRÉS par gen-l10n

test/infrastructure/services/import_interrupt_service_test.dart ← NOUVEAU
test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart ← NOUVEAU
```

---

### Références

- Story 7.3 (feedback opérations longues, AC implémenté + review findings déférés) : `_bmad-output/implementation-artifacts/7-3-feedback-visuel-operations-longues.md`
- Story 8.2 (pattern i18n ARB + gen-l10n + tests widget) : `_bmad-output/implementation-artifacts/8-2-implementer-revokeconsent-rgpd-art-7-3.md`
- `AppLifecycleManager` existant : `lib/core/bootstrap/app_lifecycle_manager.dart`
- `AppInitializer` : `lib/core/bootstrap/app_initializer.dart`
- `BulkAddDialog` (code actuel) : `lib/presentation/widgets/dialogs/bulk_add_dialog.dart`
- `HomePage` (code actuel) : `lib/presentation/pages/home_page.dart`
- Pattern `callbackWithoutSessionProvider` (one-shot static flag + LoginPage.initState) : `lib/infrastructure/services/web_auth_callback_stabilizer.dart` + `lib/presentation/pages/auth/login_page.dart`
- `test/helpers/localized_widget.dart` — helper existant pour les tests widget avec localisation FR
- `deferred-work.md` — review findings story 7.3 (hors scope cette story)

---

## Dev Agent Record

### Agent Model Used
claude-sonnet-4-6

### Debug Log References
- T1.2 test 3 : `checkAndLoadPersistedState` échouait car `onComplete()` dans le corps du test effaçait les clés juste après `setMockInitialValues`. Corrigé en supprimant l'appel `onComplete()` redondant dans le test (setUp gère déjà la réinitialisation).
- T6 / régression : l'ajout de `await onComplete()` dans `BulkAddDialog._handleSubmit` bloquait les tests existants qui n'initialisaient pas SharedPreferences. Corrigé en ajoutant `setUp(() async { SharedPreferences.setMockInitialValues({}); await ImportInterruptService.instance.onComplete(); })` dans les 4 fichiers de tests BulkAddDialog existants.

### Completion Notes List
- `ImportInterruptService` créé (~40 lignes) : singleton SharedPreferences-backed avec 4 méthodes (onProgress, onComplete, checkAndLoadPersistedState, consumeStartupInterrupt)
- `AppInitializer._initializeServices()` : appel de `checkAndLoadPersistedState()` après `languageService.initialize()`
- `BulkAddDialog` : ajout `WidgetsBindingObserver` mixin, observer add/remove, `didChangeAppLifecycleState`, appels fire-and-forget `onProgress`, `await onComplete()` dans tous les chemins de sortie
- `HomePage` migré de `ConsumerWidget` → `ConsumerStatefulWidget` + `_HomePageState` avec `initState` + `_checkForInterruptedImport()` (snackbar 6s avec `AppTheme.warningColor`)
- 4 ARBs (fr/en/de/es) mis à jour avec `importInterruptedBanner` + `gen-l10n` régénéré
- 9 fichiers de localisation générés automatiquement
- 5 tests unitaires + 4 tests widget nouveaux : 9/9 passent
- 4 fichiers de tests BulkAddDialog existants mis à jour pour initialiser SharedPreferences
- Suite complète : +1956 ~26 (26 skipped pré-existants dans lists_transaction_manager), 0 régression

### Change Log
- 2026-05-05 : Implémentation story 8.3 — détection quit/refresh pendant import massif (claude-sonnet-4-6)

---

## Review Findings

*Code review — 2026-05-06*

- [x] [Review][Decision] `AppLifecycleState.hidden` ajouté au guard — étendu à `hidden` (desktop/web). [bulk_add_dialog.dart:95]

- [x] [Review][Patch] Test "retour après interruption" ajouté — `home_page_test.dart` : 2 nouveaux tests vérifient SnackBar présent/absent selon état singleton. [test/presentation/pages/home_page_test.dart]

- [x] [Review][Patch] `AppLocalizations.of(context)!` — null guard silencieux remplacé par `!` (cohérent avec reste du fichier). [home_page.dart:44]

- [x] [Review][Patch] Guard `current > 0` ajouté dans `checkAndLoadPersistedState` — prévient bannière "0/N". [import_interrupt_service.dart:16]

- [x] [Review][Patch] Test lifecycle isolé — les 2 tests lifecycle effacent les prefs avant de déclencher `handleAppLifecycleStateChanged` pour exercer `didChangeAppLifecycleState` indépendamment. Test `hidden` ajouté. [test/…/bulk_add_dialog_interrupt_test.dart]

- [x] [Review][Defer] Race condition écritures `onProgress` concurrentes — fire-and-forget par design, dernière écriture gagne, tradeoff documenté en spec. [import_interrupt_service.dart:28]
- [x] [Review][Defer] `checkAndLoadPersistedState` non idempotente sur double-appel — appelée une seule fois par design via AppInitializer. [import_interrupt_service.dart:13]
- [x] [Review][Defer] Isolation singleton dans les tests — limitation fondamentale du pattern statique ; nécessiterait injection de dépendance.
- [x] [Review][Defer] Absence de gestion d'erreur `Future.wait([prefs.remove])` — `SharedPreferences.remove` échoue rarement ; propagation acceptable. [import_interrupt_service.dart:37]
- [x] [Review][Defer] `_totalCount` diverge après skip doublons — complexité pré-existante dans `list_detail_page.dart`, hors scope story 8.3.
- [x] [Review][Defer] Fermeture onglet web sans lifecycle `paused`/`detached` — limitation Flutter Web documentée (Dev Notes §6) ; les écritures `onProgress` in-progress dans localStorage couvrent ce cas.
- [x] [Review][Defer] Plusieurs `BulkAddDialog` simultanés — non possible dans le flux UX actuel.
- [x] [Review][Defer] Geste "predictive back" Android 14+ sans `onComplete` — `PopScope(canPop: !_isSubmitting)` bloque les pops normaux en cours d'import.

### File List
lib/infrastructure/services/import_interrupt_service.dart (NOUVEAU)
lib/core/bootstrap/app_initializer.dart (MODIFIÉ)
lib/presentation/widgets/dialogs/bulk_add_dialog.dart (MODIFIÉ)
lib/presentation/pages/home_page.dart (MODIFIÉ)
lib/l10n/app_fr.arb (MODIFIÉ)
lib/l10n/app_en.arb (MODIFIÉ)
lib/l10n/app_de.arb (MODIFIÉ)
lib/l10n/app_es.arb (MODIFIÉ)
lib/l10n/app_localizations.dart (GÉNÉRÉ)
lib/l10n/app_localizations_fr.dart (GÉNÉRÉ)
lib/l10n/app_localizations_en.dart (GÉNÉRÉ)
lib/l10n/app_localizations_de.dart (GÉNÉRÉ)
lib/l10n/app_localizations_es.dart (GÉNÉRÉ)
test/infrastructure/services/import_interrupt_service_test.dart (NOUVEAU)
test/presentation/widgets/dialogs/bulk_add_dialog_interrupt_test.dart (NOUVEAU)
test/presentation/widgets/dialogs/bulk_add_dialog_progress_test.dart (MODIFIÉ — setUp SharedPreferences)
test/presentation/widgets/dialogs/bulk_add_dialog_debounce_test.dart (MODIFIÉ — setUp SharedPreferences)
test/presentation/widgets/dialogs/bulk_add_dialog_edge_cases_test.dart (MODIFIÉ — setUp SharedPreferences)
test/presentation/widgets/dialogs/bulk_add_dialog_integration_test.dart (MODIFIÉ — setUp SharedPreferences)
