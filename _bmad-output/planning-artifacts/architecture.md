# Architecture — PriorisProject

Dernière mise à jour : 2026-04-30
État : reflète le code après Épic 7 (commit 4233b24)

---

## Stack technique

| Composant | Version / Détail |
|-----------|-----------------|
| Flutter | 3.32.8 (puro env `prioris-328`) |
| Dart | 3.8.x |
| Supabase | auth + base de données PostgreSQL (plan gratuit) |
| State management | Riverpod (flutter_riverpod) |
| Navigation | Navigator 1.0 (MaterialApp.onGenerateRoute) |
| Persistence locale | Hive (CustomList, ListItem, ListType adaptateurs TypedAdapter) |
| Consentement RGPD | SharedPreferences via ConsentService |
| i18n | Flutter Intl / ARB — fr, en, de, es |
| CI/CD | GitHub Actions → GitHub Pages (deploy manuel) |

---

## Architecture globale

Architecture en **couches (Layered)** avec séparation claire présentation / application / domaine / infrastructure.

```
lib/
├── core/           # Bootstrap, config, DI (non-métier), exceptions transversales
├── data/           # Providers Riverpod, repositories (interfaces + implémentations Supabase + Hive)
├── domain/         # Entités, value objects, services métier, interfaces repository
│   ├── models/     # Entités pures (Habit, CustomList, ListItem, …)
│   └── services/   # Services métier (ConsentService, EloService, InsightsService, …)
├── infrastructure/ # Services techniques (Supabase, logger, web auth stabilizer)
├── application/    # Ports, services d'application, orchestration
├── presentation/   # UI Flutter (pages, widgets, thème, animations, routes)
└── l10n/           # Fichiers de localisation générés (ARB → Dart)
```

> **Note** : `docs/ARCHITECTURE_GUIDE.md` est une vision cible aspirationnelle CQRS/DDD générée par un agent précédent. Elle décrit des patterns (`CommandBus`, `EventBus`, `CustomListAggregate`) **non implémentés** dans le code actuel. Ne pas s'y référer pour comprendre le code réel.

Pas de CQRS, pas de Command Bus, pas d'Event Sourcing en production.

---

## Flux d'authentification — DÉVIATION STORY 6.4

### Pattern classique (non utilisé)

Un route guard intercepte chaque navigation et redirige vers `/login` si non authentifié.
Typiquement : GoRouter `redirect` callback ou `NavigatorObserver`.

### Pattern réel — AuthWrapper widget-based

**Fichier** : `lib/presentation/pages/auth/auth_wrapper.dart`

`AuthWrapper` est un `ConsumerWidget` placé comme `home:` dans `MaterialApp` (via `lib/presentation/app/prioris_app.dart`), en dehors de la table de routes.

Il observe deux providers Riverpod :
- `authUIStateProvider` → `AuthUIState` : loading / signedIn / signedOut / error
- `consentProvider` → `AsyncValue<bool>` (consentement RGPD accordé)

#### Tableau de décision de rendu

| `authUIStateProvider` | `consentProvider` | Widget affiché |
|-----------------------|-------------------|----------------|
| `loading` | — | `CircularProgressIndicator` |
| `signedIn` | `loading` | `CircularProgressIndicator` |
| `signedIn` | `data(true)` | `HomePage` |
| `signedIn` | `data(false)` | `ConsentGatePage` |
| `signedIn` | `error` | `HomePage` (fallback) |
| `signedOut` | — | `LoginPage` |
| `error` | — | `LoginPage` |

### Flux callback Supabase (magic link / email OTP)

Le flux complet se déroule dans `lib/infrastructure/services/supabase_service.dart`, appelé depuis `lib/core/bootstrap/app_initializer.dart` :

```
1. Supabase redirige le navigateur vers :
      https://prioris.app/?code=xxx&type=signup   (PKCE)
   ou https://prioris.app/#sb-<project>-...        (fragment route-like)

2. Flutter Web charge l'app ; main.dart appelle AppInitializer.initialize()

3. SupabaseService.initialize() appelle :
   WebAuthCallbackStabilizer.stabilizeFromCurrentOrIncomingSessionIfNeeded()
   Le stabilizer :
   a. Détecte l'URL d'auth callback via isAuthCallbackUri()
   b. Si code verifier PKCE présent → exchangeSessionFromUrl() → échange PKCE
   c. Persiste la session dans localStorage (clé : sb-<projectRef>-auth-token)
   d. Sanitize l'URL via history.replaceState (strip params auth)
   e. Si pas de session → _callbackWithoutSession = true

4. Flutter route /#sb-... ou /?code=... → AppRoutes.generateRoute() :
   - _isSupabaseCallbackRoute() détecte le fragment sb- ou sb.
   - Route vers AuthWrapper (settings.name forcé à '/')

5. AuthWrapper lit authUIStateProvider → décide HomePage ou LoginPage

6. LoginPage.initState() lit callbackWithoutSessionProvider
   (consomme WebAuthCallbackStabilizer.consumeCallbackWithoutSession())
   → affiche message contextuel si lien expiré ou navigateur différent
```

**Raison de la déviation** : Introduite en story 6.4 pour GitHub Pages.
Les fragments `#sb-xxx` sont capturés par le router Flutter *avant* que `history.replaceState` ne s'exécute.
Un route guard classique ne peut pas intercepter le widget `home:` sans être lui-même dans la table de routes.
L'approche widget-based évite un cycle de navigation et fonctionne avant l'initialisation complète du router.

### Fichiers clés du flux auth

| Fichier | Rôle |
|---------|------|
| `lib/infrastructure/services/web_auth_callback_stabilizer.dart` | Logique de détection et stabilisation session callback |
| `lib/infrastructure/services/supabase_service.dart` | Initialisation Supabase + appel stabilizer |
| `lib/core/bootstrap/app_initializer.dart` | Séquence de démarrage (storage → config → services → repositories) |
| `lib/presentation/app/prioris_app.dart` | MaterialApp — pose `home: AuthWrapper()` |
| `lib/presentation/routes/app_routes.dart` | `_isSupabaseCallbackRoute()` + route callback vers AuthWrapper |
| `lib/presentation/pages/auth/auth_wrapper.dart` | Widget de décision auth/consent |
| `lib/data/providers/auth_providers.dart` | `authUIStateProvider`, `AuthUIState`, `callbackWithoutSessionProvider` (autoDispose) |
| `lib/data/providers/consent_providers.dart` | `consentProvider`, `ConsentNotifier` |

---

## État des couches après Épic 7

### Couche `core/`

| Module | Contenu réel |
|--------|-------------|
| `core/bootstrap/` | `AppInitializer` (séquence init), `AppLifecycleManager` |
| `core/config/` | `AppConfig` (URL Supabase, clé anon, env) |
| `core/di/` | Conteneur DI supprimé — utilise Riverpod providers directement |
| `core/exceptions/` | Exceptions transversales |
| `core/interfaces/` | Interfaces génériques |
| `core/patterns/` | Patterns créationnels / structurels (usage partiel) |
| `core/utils/` | Utilitaires partagés |

### Couche `data/`

| Module | Contenu réel |
|--------|-------------|
| `data/providers/` | Providers Riverpod (auth, consent, lists, habits, …) |
| `data/repositories/base/` | `HiveRepositoryRegistry` (rétrocompatibilité), base classes repository |
| `data/repositories/impl/` | Implémentations concrètes (Hive) |
| `data/repositories/interfaces/` | Interfaces repository |
| `data/repositories/supabase/` | Implémentations Supabase |

### Couche `domain/`

| Module | Contenu réel |
|--------|-------------|
| `domain/models/core/entities/` | `Habit`, `CustomList`, `ListItem`, `HabitFrequency`, … |
| `domain/models/core/enums/` | Enums métier |
| `domain/models/core/value_objects/` | Value objects |
| `domain/services/` | Services métier purs (EloService, InsightsService, ConsentService, LanguageService, …) |
| `domain/habit/`, `domain/list/`, `domain/task/` | Agrégats DDD partiels (présents en code, usage partiel) |

### Couche `application/`

| Module | Contenu réel |
|--------|-------------|
| `application/common/` | Utilitaires partagés couche application |
| `application/ports/` | Ports (interfaces entrantes/sortantes) — architecture hexagonale partielle |
| `application/services/` | Services d'application (orchestration use cases) |
| `application/export.dart` | Export barrel de la couche |

### Couche `infrastructure/`

| Module | Contenu réel |
|--------|-------------|
| `infrastructure/services/auth_service.dart` | Wrapper AuthService autour de Supabase Auth |
| `infrastructure/services/supabase_service.dart` | Init Supabase + stabilizer callback |
| `infrastructure/services/web_auth_callback_stabilizer.dart` | Logique stabilisation session web |
| `infrastructure/services/logger_service.dart` | Logger structuré |
| `infrastructure/security/` | `SignupGuard` (rate limit inscription) |

### Couche `presentation/`

| Module | Contenu réel |
|--------|-------------|
| `presentation/app/prioris_app.dart` | MaterialApp principal |
| `presentation/pages/` | Pages : auth, home, lists, habits, duel, insights, settings, … |
| `presentation/widgets/` | Widgets réutilisables (dialogs, forms, loading, cards, …) |
| `presentation/routes/app_routes.dart` | Navigator 1.0 (onGenerateRoute) |
| `presentation/theme/` | Thème, AppTheme (light fixé) |
| `presentation/animations/` | Transitions de page, célébrations |
| `presentation/controllers/` | Controllers Riverpod page-scoped |
| `presentation/services/` | Services UI (haptic, performance, accessibility, debug) |

---

## RGPD — état après Épic 7

- `ConsentService` : stocke le consentement dans `SharedPreferences`
- `ConsentGatePage` : affichée si `signedIn` mais `consentProvider = false`
- Story 7.7 : bases RGPD minimales (consentement, politique de confidentialité)
- **Dette restante** (Épic 8) : suppression auto compte (Art. 17), bouton Refuser (Art. 7.3) → story 8.2

---

## Déploiement

- **Cible** : GitHub Pages (`https://n3z3d.github.io/PriorisProject/`)
- **Pipeline** : GitHub Actions → `flutter build web` → push vers branche `gh-pages`
- **Prérequis** : `git push` vers `main` déclenche le workflow CI/CD
- **Puro** : environment `prioris-328` — binaire direct (non dans le PATH système)

```powershell
# Deploy
puro flutter build web --release --base-href /PriorisProject/
git push origin main  # déclenche GitHub Actions
```

## Commandes développement locales

```powershell
puro flutter analyze --no-pub
puro flutter test
```
