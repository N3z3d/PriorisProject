# Story 7.9 : Tests d'intégration Supabase — harness partagé

Status: done

## Story

En tant que développeur,
je veux un harness d'intégration Supabase partagé et cohérent,
afin que tous les tests d'intégration se connectent réellement à Supabase sans dupliquer le code d'initialisation, et que le test ELO cassé depuis la story 7.2 soit enfin opérationnel.

## Acceptance Criteria

1. Un helper `test/integration/helpers/supabase_test_harness.dart` centralise `_readDotEnv()`, `_InMemoryGotrueAsyncStorage`, `setUp()` et `tearDown()` — ces utilitaires ne sont définis qu'à un seul endroit.
2. `supabase_list_item_elo_integration_test.dart` est migré pour utiliser `SupabaseTestHarness.setUp()` — l'appel `SupabaseService.initialize()` (qui lit l'URL mock de `flutter_test_config.dart`) est supprimé.
3. `supabase_habit_repository_integration_test.dart` est migré pour utiliser `SupabaseTestHarness.setUp()` — les définitions locales de `_readDotEnv()` et `_InMemoryGotrueAsyncStorage` sont supprimées.
4. Les credentials de test sont lus depuis `.env` (clés `INTEGRATION_TEST_EMAIL` + `INTEGRATION_TEST_PASSWORD`) avec fallback automatique sur `test/manual/test_credentials.txt` (format `Email: xxx` / `Password: xxx`). Les credentials hardcodés dans les fichiers de test sont supprimés.
5. `flutter test test/integration/repositories --tags integration` passe (toutes les suites vertes, réseau disponible).
6. `flutter test --exclude-tags integration` ne régresse pas — 0 nouveau échec CI, le harness n'est pas chargé par les tests unitaires.

---

## Tasks / Subtasks

- [x] AC4 — Vérifier/créer le compte de test dans Supabase (pré-requis bloquant)
  - [x] Ouvrir Supabase Dashboard → Authentication → Users → vérifier si `test_1777321162736_86@example.com` existe
  - [x] Si absent : créer via "Invite user" avec password `TestPassword123!`
  - [x] Vérifier que `test/manual/test_credentials.txt` contient ce compte (il devrait déjà l'être)

- [x] AC1 — Créer `test/integration/helpers/supabase_test_harness.dart`
  - [x] Définir la classe `SupabaseTestHarness` avec méthodes statiques `setUp()` et `tearDown()`
  - [x] Extraire `_readDotEnv()` en méthode statique privée (lecture du `.env` depuis la racine)
  - [x] Définir `_InMemoryGotrueAsyncStorage` comme classe interne au fichier harness
  - [x] Implémenter `_isSupabaseInitialized()` (guard idempotence via `try/catch Supabase.instance`)
  - [x] Implémenter `_readTestCredentials()` : `.env` en priorité, fallback `test_credentials.txt`

- [x] AC2 — Migrer `supabase_list_item_elo_integration_test.dart`
  - [x] Ajouter import `../helpers/supabase_test_harness.dart`
  - [x] Remplacer `setUpAll` : supprimer `SupabaseService.initialize()` + `AuthService.instance.signIn()` → `await SupabaseTestHarness.setUp()`
  - [x] Remplacer `tearDownAll` : conserver le cleanup d'item, remplacer `AuthService.instance.signOut()` → `await SupabaseTestHarness.tearDown()`
  - [x] Supprimer l'import `supabase_service.dart` devenu inutile

- [x] AC3 — Migrer `supabase_habit_repository_integration_test.dart`
  - [x] Supprimer les définitions locales `_readDotEnv()` et `_InMemoryGotrueAsyncStorage` (~27 lignes)
  - [x] Ajouter import `../helpers/supabase_test_harness.dart`
  - [x] Remplacer `setUpAll` : supprimer le bloc d'init Supabase de 14 lignes → `await SupabaseTestHarness.setUp()`
  - [x] Remplacer `tearDownAll` : conserver le cleanup d'habit, remplacer `AuthService.instance.signOut()` → `await SupabaseTestHarness.tearDown()`
  - [x] Vérifier et supprimer les imports `dart:io` et `gotrue` s'ils ne sont plus utilisés

- [x] AC5/AC6 — Validation
  - [x] `flutter analyze --no-pub` → 0 erreur dans les fichiers modifiés
  - [x] `flutter test test/integration/repositories --tags integration` → tous verts (réseau requis)
  - [x] `flutter test --exclude-tags integration` → comparer avant/après, 0 nouveau échec

---

## Dev Notes

### Contexte critique — pourquoi les tests d'intégration sont actuellement cassés

**Problème 1 — URL mock injectée par `flutter_test_config.dart`**

`test/flutter_test_config.dart` appelle `AppConfig.setTestEnvironment()` avec l'URL mock `'https://tests-prioris.supabase.co'` **avant TOUS les tests**, y compris ceux tagués `@Tags(['integration'])`. Les tags ne désactivent pas `flutter_test_config.dart`.

`SupabaseService.initialize()` lit `AppConfig.instance` qui a été écrasé → connexion vers `tests-prioris.supabase.co` (domaine inexistant) → timeout ou `SocketException`.

**Solution** : lire `.env` directement (bypass `AppConfig`) et appeler `Supabase.initialize()` avec les vraies valeurs, SANS passer par `SupabaseService`. C'est ce que `supabase_habit_repository_integration_test.dart` fait déjà — le harness encapsule exactement ce pattern.

**Problème 2 — Compte de test absent dans le projet Supabase réel**

Le compte `test_1776892399910_958@example.com` hardcodé dans les deux fichiers de test actuels n'existe pas dans le projet Supabase `vgowxrktjzgwrfivtvse.supabase.co`. Le compte correct est `test_1777321162736_86@example.com` (dans `test/manual/test_credentials.txt`). Le harness lit ce fichier automatiquement.

---

### Architecture du harness — code cible complet

**Fichier :** `test/integration/helpers/supabase_test_harness.dart`

```dart
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:gotrue/gotrue.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Harness partagé pour les tests d'intégration Supabase réelle.
///
/// Contourne [flutter_test_config.dart] qui injecte une URL mock pour
/// tous les tests. Lit [.env] directement et appelle [Supabase.initialize]
/// sans passer par [SupabaseService].
class SupabaseTestHarness {
  SupabaseTestHarness._();

  /// Initialise Supabase depuis [.env] et authentifie le compte de test.
  ///
  /// Idempotent : ignore si Supabase est déjà initialisé.
  /// À appeler dans [setUpAll].
  static Future<void> setUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    final env = _readDotEnv();
    final creds = _readTestCredentials(env);

    if (!_isSupabaseInitialized()) {
      await Supabase.initialize(
        url: env['SUPABASE_URL']!,
        anonKey: env['SUPABASE_ANON_KEY']!,
        authOptions: FlutterAuthClientOptions(
          detectSessionInUri: false,
          localStorage: const EmptyLocalStorage(),
          pkceAsyncStorage: _InMemoryGotrueAsyncStorage(),
        ),
      );
    }

    await AuthService.instance.signIn(
      email: creds['email']!,
      password: creds['password']!,
    );
    print('SupabaseTestHarness: connecté en tant que ${creds['email']}');
  }

  /// Déconnecte le compte de test. À appeler dans [tearDownAll].
  static Future<void> tearDown() async {
    await AuthService.instance.signOut();
  }

  static bool _isSupabaseInitialized() {
    try {
      Supabase.instance; // lève StateError si non initialisé
      return true;
    } catch (_) {
      return false;
    }
  }

  static Map<String, String> _readDotEnv() {
    final file = File('.env');
    if (!file.existsSync()) {
      throw StateError('.env introuvable — lancer depuis la racine du projet');
    }
    final result = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx < 0) continue;
      result[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim();
    }
    if (!result.containsKey('SUPABASE_URL') ||
        !result.containsKey('SUPABASE_ANON_KEY')) {
      throw StateError('.env doit contenir SUPABASE_URL et SUPABASE_ANON_KEY');
    }
    return result;
  }

  /// Priorité 1 : INTEGRATION_TEST_EMAIL / INTEGRATION_TEST_PASSWORD dans .env.
  /// Priorité 2 : test/manual/test_credentials.txt (format "Email: xxx" / "Password: xxx").
  static Map<String, String> _readTestCredentials(Map<String, String> env) {
    if (env.containsKey('INTEGRATION_TEST_EMAIL') &&
        env.containsKey('INTEGRATION_TEST_PASSWORD')) {
      return {
        'email': env['INTEGRATION_TEST_EMAIL']!,
        'password': env['INTEGRATION_TEST_PASSWORD']!,
      };
    }
    return _readCredentialsTxt();
  }

  static Map<String, String> _readCredentialsTxt() {
    final file = File('test/manual/test_credentials.txt');
    if (!file.existsSync()) {
      throw StateError(
        'Credentials manquants — ajouter INTEGRATION_TEST_EMAIL + '
        'INTEGRATION_TEST_PASSWORD dans .env, '
        'ou créer test/manual/test_credentials.txt',
      );
    }
    String? email, password;
    for (final line in file.readAsLinesSync()) {
      if (line.startsWith('Email:')) email = line.substring(6).trim();
      if (line.startsWith('Password:')) password = line.substring(9).trim();
    }
    if (email == null || password == null) {
      throw StateError(
        'Format test_credentials.txt invalide — attendu :\n'
        'Email: xxx\nPassword: xxx',
      );
    }
    return {'email': email, 'password': password};
  }
}

class _InMemoryGotrueAsyncStorage implements GotrueAsyncStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async => _store.remove(key);
}
```

**Taille :** ~90 lignes. Toutes les méthodes ≤ 30L. ✅

---

### Migration de `supabase_list_item_elo_integration_test.dart`

**Fichier :** `test/integration/repositories/supabase_list_item_elo_integration_test.dart`

**Remplacer le setUpAll existant** (supprime `SupabaseService.initialize()` et `AuthService.signIn` inline) :

```dart
// AJOUTER cet import :
import '../helpers/supabase_test_harness.dart';

// SUPPRIMER cet import (devenu inutile) :
// import 'package:prioris/infrastructure/services/supabase_service.dart';

// REMPLACER setUpAll par :
setUpAll(() async {
  await SupabaseTestHarness.setUp();
  repository = SupabaseListItemRepository();
  testItemId = '';
});

// REMPLACER tearDownAll par (conserver le cleanup d'item) :
tearDownAll(() async {
  if (testItemId.isNotEmpty) {
    await repository.delete(testItemId);
  }
  await SupabaseTestHarness.tearDown();
});
```

---

### Migration de `supabase_habit_repository_integration_test.dart`

**Fichier :** `test/integration/repositories/supabase_habit_repository_integration_test.dart`

**Supprimer du fichier** (environ 27 lignes en haut du fichier) :
- La fonction `_readDotEnv()` (lignes 18–30)
- La classe `_InMemoryGotrueAsyncStorage` (lignes 33–46)

**Supprimer ces imports s'ils ne sont plus utilisés** :
```dart
import 'dart:io';                         // utilisé uniquement par _readDotEnv()
import 'package:gotrue/gotrue.dart';      // utilisé uniquement par _InMemoryGotrueAsyncStorage
import 'package:flutter/widgets.dart';    // utilisé uniquement par WidgetsFlutterBinding (maintenant dans le harness)
```
**ATTENTION** : vérifier ligne par ligne que ces imports ne sont plus référencés avant de les supprimer. Si `package:flutter/widgets.dart` est utilisé ailleurs dans le fichier, le garder.

**Ajouter cet import** :
```dart
import '../helpers/supabase_test_harness.dart';
```

**Remplacer setUpAll** (supprime les 14 lignes d'init Supabase + signIn inline) :
```dart
setUpAll(() async {
  await SupabaseTestHarness.setUp();
  repository = SupabaseHabitRepository();
});
```

**Remplacer tearDownAll** (conserver le cleanup d'habit, remplacer signOut) :
```dart
tearDownAll(() async {
  if (testHabitId.isNotEmpty) {
    try {
      await repository.deleteHabit(testHabitId);
      print('Cleanup: habit $testHabitId deleted');
    } catch (e) {
      print('Cleanup warning: could not delete $testHabitId -- $e');
    }
  }
  await SupabaseTestHarness.tearDown();
});
```

---

### Précautions importantes

**1. Idempotence Supabase.initialize()**
`flutter test` lance chaque fichier dans un processus VM distinct → pas de collision inter-fichiers. La guard `_isSupabaseInitialized()` protège contre un double-appel hypothétique dans un même processus (ex. deux `group` dans le même fichier).

**2. Compte de test — email à utiliser**
Le harness lit en priorité `.env` (`INTEGRATION_TEST_EMAIL`), sinon `test/manual/test_credentials.txt`. Ce fichier contient actuellement `test_1777321162736_86@example.com`. Vérifier que ce compte existe dans le projet Supabase `vgowxrktjzgwrfivtvse.supabase.co`. Le compte `test_1776892399910_958@example.com` (anciennement hardcodé) était inexistant — ne pas utiliser.

**3. Isolation des données de test**
Les tests créent et suppriment leurs propres objets (habit ou list item). Le `tearDownAll` fait un try/catch pour le cleanup — pattern déjà en place, à conserver.

**4. Tag `@Tags(['integration'])` obligatoire**
Chaque fichier de test d'intégration DOIT avoir en tête (juste après les `// ignore_for_file:`) :
```dart
@Tags(['integration'])
library;
```
`supabase_habit_repository_integration_test.dart` a déjà les deux lignes. Vérifier que `supabase_list_item_elo_integration_test.dart` l'a aussi (il l'a, à la ligne 8, sans `library;` — laisser tel quel si le test passe).

**5. Import path relatif depuis `repositories/`**
```dart
import '../helpers/supabase_test_harness.dart';
```

---

### Ce qu'il NE FAUT PAS toucher

- `test/flutter_test_config.dart` — ne pas modifier, c'est le setup CI standard.
- `lib/infrastructure/services/supabase_service.dart` — utilisé par l'app en production.
- `test/integration/supabase_integration_validation_test.dart` — test structurel sans réseau, hors scope.
- `test/integration/auth_flow_integration_test.dart` — teste l'UI avec mocks, hors scope.
- Tous les tests unitaires (non tagués) — ne doivent pas être impactés.

---

### Commandes de validation

```powershell
# Analyse statique (0 erreur dans les fichiers modifiés)
flutter analyze --no-pub

# Suite d'intégration complète (réseau requis — non CI)
flutter test test/integration/repositories --tags integration

# Suite CI — vérifier 0 régression (base de référence : 67 échecs pré-existants)
flutter test --exclude-tags integration
```

---

### Apprentissages des stories précédentes applicables

- **`flutter analyze --no-pub`** obligatoire avant de déclarer terminé.
- **Commandes via PowerShell + puro** — le shell bash ne trouve pas `flutter`. Toujours utiliser PowerShell pour les commandes Flutter.
- **`WidgetsFlutterBinding.ensureInitialized()`** requis en `setUpAll` pour les tests VM utilisant des plugins (`supabase_flutter` en dépend).
- **Suite CI (`--exclude-tags integration`) : 67 échecs pré-existants** (DataMigrationService, ListsPersistenceService) — ne pas les compter comme régressions. Comparer avant/après.
- **Pattern `// ignore_for_file: avoid_print`** — les tests d'intégration utilisent `print()` pour les logs de cleanup, en accord avec les fichiers existants.
- **`EmptyLocalStorage`** et **`FlutterAuthClientOptions`** sont dans `supabase_flutter` — pas de package supplémentaire requis.
- **`GotrueAsyncStorage`** est dans `package:gotrue/gotrue.dart` — déjà dépendance transitive de `supabase_flutter`, aucun ajout à `pubspec.yaml` requis.

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- `supabase_habit_repository_integration_test.dart` : le READ du CRUD cherche par `name` au lieu de `id` car la table `habits` a un trigger DB qui génère son propre UUID à l'INSERT, écrasant le `id` fourni par Dart. Tous les 4 tests passent.
- `supabase_list_item_elo_integration_test.dart` : la FK `list_items.list_id → custom_lists.id` nécessite de créer une vraie ligne via `SupabaseCustomListRepository.saveList()`. Le teardown hard-delete les items avant la liste pour éviter la violation FK.
- `GotrueAsyncStorage` est réexporté par `supabase_flutter` — l'import `package:gotrue/gotrue.dart` est inutile dans le harness.
- Credential de test actif : `test_1777353630701_374@example.com` dans `test/manual/test_credentials.txt`.

### File List

- `test/integration/helpers/supabase_test_harness.dart` — NOUVEAU (AC1)
- `test/integration/repositories/supabase_list_item_elo_integration_test.dart` — MODIFIÉ (AC2)
- `test/integration/repositories/supabase_habit_repository_integration_test.dart` — MODIFIÉ (AC3)

---

## Review Findings

- [x] [Review][Patch] `test_credentials.txt` toujours traqué par git malgré l'ajout au `.gitignore` — `git rm --cached test/manual/test_credentials.txt` requis pour l'ôter de l'index (sinon le mot de passe reste dans l'historique git) [.gitignore / test/manual/test_credentials.txt]
- [x] [Review][Patch] `testListId` déclaré `late` → `LateInitializationError` opaque si `SupabaseTestHarness.setUp()` lève avant l'assignation — initialiser à `''` pour un teardown sans crash [test/integration/repositories/supabase_list_item_elo_integration_test.dart:21]
- [x] [Review][Patch] `SupabaseTestHarness.tearDown()` non enveloppé par try/catch dans le `tearDownAll` du test ELO — jette `StateError` si Supabase n'a jamais été initialisé (setUp raté), masquant la vraie cause [test/integration/repositories/supabase_list_item_elo_integration_test.dart:62]
- [x] [Review][Defer] `setUp()` re-entrant — `signIn()` appelé sans guard même si déjà authentifié (double-session GoTrue silencieuse en cas de crash-recovery) [test/integration/helpers/supabase_test_harness.dart:38-41] — deferred, pré-existant au design, tests lancés en processus séparés en pratique
- [x] [Review][Defer] Valeurs `.env` entre guillemets (`SUPABASE_URL="https://..."`) passées verbatim à `Supabase.initialize()` — URL invalide silencieuse [test/integration/helpers/supabase_test_harness.dart:65-70] — deferred, pré-existant dans `_readDotEnv`, non documenté dans le projet
- [x] [Review][Defer] `getAllHabits()` lookup par nom `'Test 7.1 Schema CRUD'` peut matcher des habitudes orphelines de runs précédents — accumulation silencieuse dans la DB de test [test/integration/repositories/supabase_habit_repository_integration_test.dart:61] — deferred, trade-off accepté (trigger DB écrase l'UUID Dart), documenté dans les completion notes
- [x] [Review][Defer] `_isSupabaseInitialized()` attrape toutes les exceptions via `catch (_)` — un StateError légitime (autre que "non initialisé") se transformerait en double-init [test/integration/helpers/supabase_test_harness.dart:50-57] — deferred, théorique tant que le SDK Supabase ne change pas le type d'exception sentinelle
- [x] [Review][Defer] `_InMemoryGotrueAsyncStorage` instance partagée si tests lancés avec `--concurrency` — race condition sur l'état d'auth [test/integration/helpers/supabase_test_harness.dart:116] — deferred, `flutter test` utilise des processus isolés par défaut pour les tests d'intégration
- [x] [Review][Defer] AC6 partiel — autres fichiers d'intégration non tagués `@Tags(['integration'])` (pré-existant, hors scope story 7.9) — deferred, pré-existant
- [x] [Review][Defer] `AuthService.signIn` — dépendance potentielle à `AppConfig` non initialisé en contexte test (à confirmer si tests échouent en CI) [test/integration/helpers/supabase_test_harness.dart:38] — deferred, probable faux-positif (4 tests passent per dev notes)
