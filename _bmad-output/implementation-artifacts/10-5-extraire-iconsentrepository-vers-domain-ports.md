# Story 10.5 : Extraire IConsentRepository vers lib/domain/ports/

Status: done

## Story

En tant que développeur,
je veux que `ConsentService` ne dépende plus de `shared_preferences` directement dans `lib/domain/`,
afin que le domaine reste hermétique (0 import infrastructure dans `lib/domain/`) conformément à ADR-001.

## Acceptance Criteria

1. `lib/domain/ports/consent_repository.dart` existe — interface `IConsentRepository` sans import infrastructure
2. `ConsentService` n'importe plus `shared_preferences` ni aucun package infrastructure
3. `SharedPreferencesConsentRepository` dans `lib/data/repositories/` implémente `IConsentRepository`
4. `consentRepositoryProvider` injecte `SharedPreferencesConsentRepository` ; `consentServiceProvider` reçoit le repository via DIP
5. `puro flutter analyze --no-pub` → 0 nouvelle erreur
6. `puro flutter test --exclude-tags integration` → 0 régression

## Tasks / Subtasks

- [x] **T1 — Créer l'interface IConsentRepository** (AC: 1)
  - [x] T1.1 — Créer le dossier `lib/domain/ports/` s'il n'existe pas
  - [x] T1.2 — Créer `lib/domain/ports/consent_repository.dart` avec `abstract class IConsentRepository` contenant 3 méthodes : `hasAcceptedConsent()`, `acceptConsent()`, `revokeConsent()`
  - [x] T1.3 — Vérifier : aucun import `package:shared_preferences`, `package:hive`, `package:supabase_flutter`, `package:flutter` dans ce fichier

- [x] **T2 — Créer SharedPreferencesConsentRepository** (AC: 3)
  - [x] T2.1 — Créer `lib/data/repositories/shared_preferences_consent_repository.dart`
  - [x] T2.2 — Déplacer les constantes `_consentKey = 'privacy_consent_v1'` et `_consentDateKey = 'privacy_consent_date_v1'` dans cette classe
  - [x] T2.3 — Implémenter `IConsentRepository` avec la logique SharedPreferences (anciennement dans ConsentService) — y compris le `try/catch` sur l'écriture de la date

- [x] **T3 — Refactorer ConsentService** (AC: 2)
  - [x] T3.1 — Supprimer `import 'package:shared_preferences/shared_preferences.dart'`
  - [x] T3.2 — Ajouter `final IConsentRepository _repository;` + constructeur `ConsentService(this._repository)`
  - [x] T3.3 — Les 3 méthodes délèguent à `_repository` : `hasAcceptedConsent() => _repository.hasAcceptedConsent()`, etc.
  - [x] T3.4 — Conserver `static const String consentContactEmail = 'support@prioris.app'` (utilisé dans 3 fichiers présentation — ne pas toucher)

- [x] **T4 — Mettre à jour les providers Riverpod** (AC: 4)
  - [x] T4.1 — Dans `lib/data/providers/consent_providers.dart`, ajouter `consentRepositoryProvider = Provider<IConsentRepository>((ref) => SharedPreferencesConsentRepository())`
  - [x] T4.2 — Modifier `consentServiceProvider` : `Provider<ConsentService>((ref) => ConsentService(ref.watch(consentRepositoryProvider)))`
  - [x] T4.3 — Vérifier que `ConsentNotifier` et `consentProvider` ne changent pas (ils consomment toujours `consentServiceProvider`)

- [x] **T5 — Mettre à jour les tests ConsentService** (AC: 2, 6)
  - [x] T5.1 — Dans `test/domain/services/core/consent_service_test.dart` : supprimer l'import `shared_preferences`, ajouter une classe locale `FakeConsentRepository implements IConsentRepository`
  - [x] T5.2 — Réécrire les tests pour instancier `ConsentService(FakeConsentRepository())` — les cas nominaux et edge cases restent les mêmes
  - [x] T5.3 — Le test `acceptConsent persiste la date de consentement` est retiré (la logique date est maintenant dans SharedPreferencesConsentRepository, pas dans ConsentService)

- [x] **T6 — Ajouter tests SharedPreferencesConsentRepository** (AC: 3, 6)
  - [x] T6.1 — Créer `test/data/repositories/shared_preferences_consent_repository_test.dart`
  - [x] T6.2 — Tester avec `SharedPreferences.setMockInitialValues({})` : `hasAcceptedConsent` false initial, `acceptConsent → true`, `revokeConsent → false`, persistence entre instances, date enregistrée après accept, date supprimée après revoke, idempotence revoke

- [x] **T7 — Validation finale** (AC: 5, 6)
  - [x] T7.1 — `puro flutter analyze --no-pub` → 0 nouvelle erreur
  - [x] T7.2 — `puro flutter test --exclude-tags integration` → 0 régression (baseline : 2034 pass, 26 skip, 1 flaky pré-existant `ListsTransactionManager timeout`)

### Review Findings

- [x] [Review][Defer] `SharedPreferences.getInstance()` singleton non injectable dans le repository — DIP potentiel : injecter une instance `SharedPreferences` dans le constructeur permettrait un test en isolation réelle sans mock global ; amélioration non demandée par la spec [lib/data/repositories/shared_preferences_consent_repository.dart] — deferred, pre-existing
- [x] [Review][Defer] `acceptConsent` try/catch silencieux sur l'écriture de la date — comportement intentionnel documenté dans la spec ("audit trail incomplete but consent valid") ; le risque RGPD théorique (date absente = preuve de consentement incomplète) est accepté délibérément ; à adresser si une obligation légale plus stricte est identifiée [lib/data/repositories/shared_preferences_consent_repository.dart:18] — deferred, pre-existing
- [x] [Review][Defer] `IConsentRepository` n'expose pas la date de consentement — port minimaliste intentionnel ; la date n'était pas non plus queryable avant cette story ; si une story RGPD future nécessite `getConsentDate()`, il faudra l'ajouter au port [lib/domain/ports/consent_repository.dart] — deferred, pre-existing
- [x] [Review][Defer] `revokeConsent` : deux removes séquentiels non atomiques — en cas de crash entre les deux awaits, `_consentDateKey` peut persister après suppression du flag ; pattern identique à l'implémentation originale dans ConsentService, non introduit par cette story [lib/data/repositories/shared_preferences_consent_repository.dart:27] — deferred, pre-existing
- [x] [Review][Defer] `FakeConsentRepository` ne simule pas les exceptions — aucun test de chemin d'erreur sur `ConsentService` (propagation correcte depuis le repository) ; amélioration de couverture hors scope de la story [test/domain/services/core/consent_service_test.dart] — deferred
- [x] [Review][Defer] `ConsentGatePage` : état `AsyncValue.error` non géré — l'utilisateur peut rester bloqué si `SharedPreferences` échoue à l'initialisation (bouton actif, boucle d'erreur sans feedback) ; pre-existing dans la couche présentation, hors scope de cette story [lib/presentation/pages/consent_gate_page.dart] — deferred, pre-existing
- [x] [Review][Defer] `consentContactEmail` dans `ConsentService` — constante de configuration/présentation dans un service domaine, SRP borderline ; maintenu intentionnellement per spec (3 usages présentation) ; à déplacer dans une constante applicative si le service évolue [lib/domain/services/core/consent_service.dart:6] — deferred, pre-existing
- [x] [Review][Defer] Double-write `ConsentNotifier` (double-tap rapide) — `accept()` ne passe pas le state en `loading` pendant l'opération async, un double-tap peut déclencher deux appels concurrents à `acceptConsent()` ; pre-existing dans `ConsentNotifier`, non modifié par cette story [lib/data/providers/consent_providers.dart] — deferred, pre-existing

## Dev Notes

### Contexte ADR-001

Violation documentée depuis story 7.7 : `ConsentService` dans `lib/domain/services/core/consent_service.dart` importe `package:shared_preferences/shared_preferences.dart` — interdit par `lib/domain/CLAUDE.md` et ADR-001. La règle : le domaine ne dépend de rien. Référence : `docs/ADR/ADR-001-hexagonal.md`.

Nota : `lib/domain/ports/` n'existe pas encore dans le repo. Cette story crée ce dossier.

### Pattern existant à suivre

Le port domaine pour les habitudes (`lib/domain/habit/repositories/habit_repository.dart`) est le template de référence :
```dart
// Aucun import infrastructure — uniquement des imports domaine
abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  // ...
}
```

`IConsentRepository` suit exactement ce pattern mais dans `lib/domain/ports/` (emplacement spécifié dans l'epic pour les ports cross-cutting sans agrégat propre).

### État actuel de ConsentService

```dart
// lib/domain/services/core/consent_service.dart — ÉTAT AVANT
import 'package:shared_preferences/shared_preferences.dart';  // ← à supprimer

class ConsentService {
  static const String _consentKey = 'privacy_consent_v1';    // ← déplacer vers SharedPreferencesConsentRepository
  static const String _consentDateKey = 'privacy_consent_date_v1';  // ← idem
  static const String consentContactEmail = 'support@prioris.app';  // ← CONSERVER dans ConsentService

  Future<bool> hasAcceptedConsent() async { ... }  // ← déléguer à _repository
  Future<void> acceptConsent() async { ... }        // ← idem
  Future<void> revokeConsent() async { ... }        // ← idem
}
```

### ConsentService — état cible

```dart
// lib/domain/services/core/consent_service.dart — ÉTAT APRÈS
import 'package:prioris/domain/ports/consent_repository.dart';

class ConsentService {
  static const String consentContactEmail = 'support@prioris.app';

  const ConsentService(this._repository);

  final IConsentRepository _repository;

  Future<bool> hasAcceptedConsent() => _repository.hasAcceptedConsent();
  Future<void> acceptConsent() => _repository.acceptConsent();
  Future<void> revokeConsent() => _repository.revokeConsent();
}
```

### consentContactEmail — ne pas toucher

`ConsentService.consentContactEmail` est référencé dans 3 fichiers présentation :
- `lib/presentation/pages/privacy_policy_page.dart` (2 occurrences)
- `lib/presentation/pages/settings_page.dart` (2 occurrences avec `ClipboardData`)

Ne pas déplacer cette constante. Elle reste dans `ConsentService`.

### Logique date dans SharedPreferencesConsentRepository

Le `try/catch` dans `acceptConsent()` est intentionnel (commentaire l'explique) :
```dart
// Flag persisted; date write failed — audit trail incomplete but consent valid
```
Conserver exactement le même comportement dans l'implémentation.

### Provider — état cible

```dart
// lib/data/providers/consent_providers.dart — ÉTAT APRÈS
import 'package:prioris/domain/ports/consent_repository.dart';
import 'package:prioris/data/repositories/shared_preferences_consent_repository.dart';

final consentRepositoryProvider = Provider<IConsentRepository>(
  (ref) => SharedPreferencesConsentRepository(),
);

final consentServiceProvider = Provider<ConsentService>(
  (ref) => ConsentService(ref.watch(consentRepositoryProvider)),
);
// ConsentNotifier et consentProvider inchangés
```

### Tests — pattern FakeConsentRepository (pas de mockito)

Pour tester `ConsentService` isolément, utiliser une fake locale (pas de `@GenerateMocks` — interface trop simple) :

```dart
class FakeConsentRepository implements IConsentRepository {
  bool _consent = false;

  @override
  Future<bool> hasAcceptedConsent() async => _consent;

  @override
  Future<void> acceptConsent() async { _consent = true; }

  @override
  Future<void> revokeConsent() async { _consent = false; }
}
```

### Impact sur consent_notifier_revoke_test.dart

Ce test utilise le `ProviderContainer` réel avec `SharedPreferences.setMockInitialValues({})`. Après la story, la chaîne complète est :
`consentProvider → ConsentNotifier → ConsentService → IConsentRepository → SharedPreferencesConsentRepository → SharedPreferences`

Le test continuera à fonctionner sans modification car `SharedPreferences.setMockInitialValues({})` intercepte toujours les vraies prefs. **Ne pas modifier ce fichier** sauf si `puro flutter test` signale une régression.

### Items deferred à résoudre dans cette story

Issue identifiée dans `deferred-work.md` (review 8.2) :
- `DIP — ConsentService importe shared_preferences dans lib/domain/` → résolu par cette story
- `Future<void>.delayed(Duration.zero)` anti-pattern dans `consent_notifier_revoke_test.dart` → hors scope (accepté, pre-existing)
- `Clés SharedPreferences hardcodées dans 3 fichiers de test` → partiellement adressé (les tests ConsentService n'en auront plus besoin après refactoring)

### Project Structure Notes

- `lib/domain/ports/consent_repository.dart` — **nouveau** — interface IConsentRepository
- `lib/domain/services/core/consent_service.dart` — **modifier** — supprimer import sharedprefs, injecter IConsentRepository
- `lib/data/repositories/shared_preferences_consent_repository.dart` — **nouveau** — implémentation concrète
- `lib/data/providers/consent_providers.dart` — **modifier** — ajout consentRepositoryProvider, mise à jour consentServiceProvider
- `test/domain/services/core/consent_service_test.dart` — **modifier** — FakeConsentRepository, retirer import sharedprefs
- `test/data/repositories/shared_preferences_consent_repository_test.dart` — **nouveau** — tests implémentation

### Commandes Flutter (toujours préfixer avec `puro`)

```bash
puro flutter analyze --no-pub
puro flutter test --exclude-tags integration
```

### References

- Epic source : `_bmad-output/planning-artifacts/epic-10.md` — Story 10.2 (numéro epic, sprint story 10-5)
- ADR : `docs/ADR/ADR-001-hexagonal.md` — Règle de dépendance hexagonale
- Règles domaine : `lib/domain/CLAUDE.md` — imports interdits
- Pattern port existant : `lib/domain/habit/repositories/habit_repository.dart`
- ConsentService actuel : `lib/domain/services/core/consent_service.dart`
- Provider actuel : `lib/data/providers/consent_providers.dart`
- Tests existants : `test/domain/services/core/consent_service_test.dart`, `test/data/providers/consent_notifier_revoke_test.dart`
- Deferred items : `_bmad-output/implementation-artifacts/deferred-work.md` (review 8.2, DIP violation)
- Baseline tests : story 10-4 (2034 pass, 26 skip, 1 flaky `ListsTransactionManager timeout` pré-existant)

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- T7.2 : 2 échecs dans la suite complète provenant de `lists_transaction_manager_test.dart` (timeout sous charge) — confirmé pré-existant : le même fichier isolé passe 16/16. Aucune régression introduite par la story 10.5.

### Completion Notes List

- [x] T1 : `lib/domain/ports/consent_repository.dart` créé — `abstract class IConsentRepository` avec 3 méthodes, 0 import infrastructure.
- [x] T2 : `SharedPreferencesConsentRepository` créé dans `lib/data/repositories/` — constantes et logique SharedPreferences déplacées depuis ConsentService, try/catch date conservé.
- [x] T3 : `ConsentService` refactoré — suppression import shared_preferences, injection `IConsentRepository` via constructeur, `consentContactEmail` conservé.
- [x] T4 : `consent_providers.dart` mis à jour — `consentRepositoryProvider` ajouté, `consentServiceProvider` reçoit le repository via DIP, `ConsentNotifier` et `consentProvider` inchangés.
- [x] T5 : `consent_service_test.dart` réécrit — `FakeConsentRepository` locale, import sharedprefs supprimé, test date retiré (logique déplacée dans SharedPreferencesConsentRepository).
- [x] T6 : `shared_preferences_consent_repository_test.dart` créé — 9 tests couvrant : false initial, accept→true, persistence entre instances, date enregistrée, idempotence accept, revoke→false, date supprimée, idempotence revoke, revoke sur prefs vides.
- [x] T7 : `puro flutter analyze --no-pub` → 0 nouvelle erreur sur les fichiers de la story. Suite complète : 2036 pass, 26 skip, 2 flaky pré-existants `ListsTransactionManager` (confirmés non liés à cette story).
- [x] sprint-status mis à jour à `review` pour cette story

### File List

- `lib/domain/ports/consent_repository.dart` (nouveau)
- `lib/domain/services/core/consent_service.dart` (modifié)
- `lib/data/repositories/shared_preferences_consent_repository.dart` (nouveau)
- `lib/data/providers/consent_providers.dart` (modifié)
- `test/domain/services/core/consent_service_test.dart` (modifié)
- `test/data/repositories/shared_preferences_consent_repository_test.dart` (nouveau)

### Change Log

- 2026-05-15 : Création `lib/domain/ports/consent_repository.dart` — port IConsentRepository conforme ADR-001
- 2026-05-15 : Création `lib/data/repositories/shared_preferences_consent_repository.dart` — adaptateur SharedPreferences implémentant IConsentRepository
- 2026-05-15 : Refactoring `ConsentService` — suppression dépendance shared_preferences, injection IConsentRepository via DIP
- 2026-05-15 : Mise à jour `consent_providers.dart` — ajout consentRepositoryProvider, chaîne DIP complète
- 2026-05-15 : Réécriture `consent_service_test.dart` — FakeConsentRepository locale, tests domaine purs
- 2026-05-15 : Création `shared_preferences_consent_repository_test.dart` — 9 tests couvrant tous les cas nominaux et edge cases
