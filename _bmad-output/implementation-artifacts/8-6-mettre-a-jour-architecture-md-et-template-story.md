# Story 8.6 : Mettre à jour architecture.md et formaliser le template story

Status: done

## Story

En tant que développeur,
je veux que la documentation d'architecture reflète le code réel et que le template de story inclue la vérification compte non-créateur,
afin que les futurs développeurs ne soient pas induits en erreur et que la procédure de clôture soit complète.

## Acceptance Criteria

1. `_bmad-output/planning-artifacts/architecture.md` documente la déviation router guard introduite en 6.4 (AuthWrapper widget-based vs route guard classique) et reflète l'état réel du code à l'issue de l'Épic 7
2. Le template de story (`.claude/skills/bmad-create-story/template.md`) contient une ligne dédiée "Test non-créateur" dans la section Completion Notes
3. La procédure de vérification mobile avec rate limit Supabase actif est documentée dans `docs/TESTING_MOBILE_AUTH.md`
4. Thibaut confirme que `architecture.md` est cohérent avec le code Épic 7 (revue croisée manuelle)

## Tasks / Subtasks

- [x] **T1 — Créer `_bmad-output/planning-artifacts/architecture.md`** (AC: 1)
  - [x] T1.1 — Créer le fichier avec la structure définie dans Dev Notes
  - [x] T1.2 — Documenter la déviation AuthWrapper (widget-based auth gating vs route guard)
  - [x] T1.3 — Documenter le flux d'authentification complet (Supabase → WebAuthCallbackStabilizer → AuthWrapper)
  - [x] T1.4 — Documenter l'état réel de l'architecture après Épic 7 (stack, couches, fichiers clés)

- [x] **T2 — Créer `docs/TESTING_MOBILE_AUTH.md`** (AC: 3)
  - [x] T2.1 — Documenter la procédure de test mobile avec rate limit actif (voir Dev Notes)
  - [x] T2.2 — Documenter les cas de test auth callback (succès, lien expiré, navigateur différent)

- [x] **T3 — Mettre à jour `.claude/skills/bmad-create-story/template.md`** (AC: 2)
  - [x] T3.1 — Ajouter une ligne "Test non-créateur" dans la section `### Completion Notes List`
  - [x] T3.2 — La ligne doit être un item de checklist markdown : `- [ ] Test non-créateur : vérifier le flux avec un compte utilisateur non-créateur du projet`

- [ ] **T4 — Revue croisée manuelle par Thibaut** (AC: 4)
  - [ ] T4.1 — Thibaut lit `architecture.md` et vérifie la cohérence avec le code
  - [ ] T4.2 — Thibaut signe la revue dans la section Completion Notes de cette story

- [x] **T5 — Validation finale**
  - [x] T5.1 — `puro flutter analyze --no-pub` → erreurs pré-existantes uniquement (aucun fichier Dart modifié, 0 régression introduite)
  - [x] T5.2 — Vérifier que les chemins de fichiers documentés existent réellement

---

## Dev Notes

### Fichiers à créer / modifier

| Action | Fichier | Description |
|--------|---------|-------------|
| CRÉER | `_bmad-output/planning-artifacts/architecture.md` | Doc architecture — n'existe pas encore dans les planning-artifacts |
| CRÉER | `docs/TESTING_MOBILE_AUTH.md` | Procédure mobile auth avec rate limit |
| MODIFIER | `.claude/skills/bmad-create-story/template.md` | Ajouter "Test non-créateur" |

> **Attention** : `docs/ARCHITECTURE_GUIDE.md` existe mais est une doc aspirationnelle CQRS/DDD générée par un agent précédent — elle **ne reflète pas** le code réel. Ne pas la modifier. Le fichier cible est `_bmad-output/planning-artifacts/architecture.md`.

---

### Contenu attendu pour `architecture.md`

Le fichier doit documenter l'architecture **réelle** (pas aspirationnelle). Structure recommandée :

```markdown
# Architecture — PriorisProject

Dernière mise à jour : [date]
État : reflète le code après Épic 7 (commit 4233b24)

## Stack technique

- Flutter 3.32.8 (puro env `prioris-328`)
- Dart 3.8.x
- Supabase (auth + base de données)
- Riverpod (state management)
- SharedPreferences (consentement RGPD local)
- Hive (persistence locale — présent dans certains repos, usage partiel)

## Architecture globale

Architecture en couches (Layered) avec séparation présentation / application / domaine / infrastructure.
Pas de CQRS, pas de Command Bus, pas d'Event Sourcing en production (voir docs/ARCHITECTURE_GUIDE.md pour vision cible non encore implémentée).

## Flux d'authentification — DÉVIATION STORY 6.4

### Pattern classique (non utilisé)
Un route guard intercepte chaque navigation et redirige vers /login si non authentifié.
GoRouter `redirect` callback ou NavigatorObserver.

### Pattern réel — AuthWrapper widget-based

**Fichier** : `lib/presentation/pages/auth/auth_wrapper.dart`

AuthWrapper est un ConsumerWidget placé comme `home:` dans MaterialApp (non dans la route table).
Il observe deux providers Riverpod :
- `authUIStateProvider` → loading / signedIn / signedOut / error
- `consentProvider` → bool (consentement RGPD accordé)

Décision de rendu :
| État auth | Consentement | Page affichée |
|-----------|-------------|---------------|
| loading | — | CircularProgressIndicator |
| signedIn | true | HomePage |
| signedIn | false | ConsentGatePage |
| signedOut / error | — | LoginPage |

### Flux callback Supabase (magic link / email OTP)

1. Supabase redirige vers `https://app/#sb-xxxxx` ou `https://app/?code=xxx`
2. Flutter Web charge l'app ; `main.dart` appelle `WebAuthCallbackStabilizer.stabilizeFromCurrentOrIncomingSessionIfNeeded()`
3. Le stabilizer :
   - Détecte l'URL d'auth callback
   - Échange le code PKCE si présent, ou utilise la session existante
   - Persiste la session dans localStorage (`sb-<project>-auth-token`)
   - Sanitize l'URL (strip des params auth) via `history.replaceState`
   - Si pas de session → `_callbackWithoutSession = true`
4. Flutter route `/#sb-...` → `AppRoutes.generateRoute` détecte le fragment via `_isSupabaseCallbackRoute()` → route vers `AuthWrapper`
5. `AuthWrapper` lit `authUIStateProvider` → décide d'afficher HomePage ou LoginPage
6. `LoginPage.initState()` appelle `WebAuthCallbackStabilizer.consumeCallbackWithoutSession()` → affiche message d'erreur si lien expiré

**Fichiers clés** :
- `lib/infrastructure/services/web_auth_callback_stabilizer.dart` — logique de stabilisation
- `lib/presentation/routes/app_routes.dart` — `_isSupabaseCallbackRoute()` + route vers AuthWrapper
- `lib/presentation/pages/auth/auth_wrapper.dart` — widget de décision
- `lib/data/providers/auth_providers.dart` — `authUIStateProvider`
- `lib/data/providers/consent_providers.dart` — `consentProvider`

### Raison de la déviation

La déviation a été introduite en story 6.4 pour gérer les callbacks Supabase auth sur GitHub Pages
(fragments `#sb-xxx` capturés par le router Flutter avant history.replaceState).
Un route guard classique ne peut pas intercepter un widget `home:` sans être lui-même dans le router.
L'approche widget-based évite un cycle de navigation et fonctionne avant que le router soit initialisé.

## État des couches après Épic 7

[... à compléter par le dev agent avec les couches réelles observées dans lib/ ...]
```

---

### Contenu attendu pour `docs/TESTING_MOBILE_AUTH.md`

```markdown
# Procédure de test auth mobile — Prioris

## Rate limit Supabase

Supabase applique par défaut un rate limit sur l'envoi d'emails magic link :
- **3 à 4 emails / heure / adresse email** (plan gratuit)
- Dépasser ce seuil → erreur Supabase "Email rate limit exceeded" (429)

## Procédure de test mobile avec rate limit actif

### Option A — Email différent
Utiliser une adresse email différente de celle utilisée pour les tests précédents dans l'heure.
Exemple : tester avec `lambert.thibaut98+test2@gmail.com` (alias Gmail +tag).

### Option B — Attendre 1 heure
Attendre la fin de la fenêtre de rate limit (60 min depuis le dernier envoi).

### Option C — Console Supabase (développement uniquement)
1. Ouvrir le dashboard Supabase du projet
2. Authentication > Users > sélectionner l'utilisateur
3. Copier le lien magic link depuis les logs ou générer via "Send magic link"
4. Coller directement dans le navigateur mobile (bypasse l'envoi email)

## Cas de test auth callback à couvrir

| Scénario | URL simulée | Résultat attendu |
|----------|-------------|-----------------|
| Succès magic link | `https://app/?code=xxx&type=signup` | Redirect HomePage |
| Lien expiré | `https://app/#sb-expired` | LoginPage + message "lien expiré" |
| Navigateur différent | Fragment sans code verifier PKCE | LoginPage + message "session non établie" |
| Callback sans session | `https://app/#access_token=...` (token invalide) | LoginPage + message d'erreur |

## Vérification avec compte non-créateur

Avant la clôture de chaque Epic :
1. Se déconnecter du compte Thibaut
2. Se connecter avec un compte pilote externe (non créateur du projet Supabase)
3. Vérifier : affichage correct, pas de données du compte Thibaut visibles, RGPD consent flow fonctionnel
4. Tester les flux critiques : ajout item, duel, insights
```

---

### Modification exacte du template story

**Fichier** : `.claude/skills/bmad-create-story/template.md`

**État actuel** :
```markdown
### Completion Notes List

### File List
```

**État cible** :
```markdown
### Completion Notes List

- [ ] Test non-créateur : vérifier le flux avec un compte utilisateur non-créateur du projet Supabase

### File List
```

**Attention** : Cette modification s'applique aussi aux copies du template dans les dossiers miroir d'agents si nécessaire (`.agent/`, `.agents/`, `.augment/`, etc.) — à la discrétion du dev agent, car ces dossiers sont des copies synchronisées automatiquement.

---

### Précautions critiques

**1. Ne pas modifier `docs/ARCHITECTURE_GUIDE.md`**
Ce fichier est une vision cible aspirationnelle générée par un agent. Il décrit un pattern CQRS/DDD non implémenté. Le laisser intact pour référence future.

**2. `architecture.md` doit documenter le réel, pas l'idéal**
Pas de `CommandBus`, pas de `CustomListAggregate`, pas de `EventBus` — ces patterns n'existent pas dans le code actuel. Documenter uniquement ce qui est dans `lib/`.

**3. Pas de code Dart à modifier**
Cette story est 100% documentation. `flutter analyze` est lancé uniquement pour vérifier qu'aucun fichier Dart voisin n't été accidentellement modifié.

**4. Commandes via PowerShell + puro**
```powershell
# Vérification santé (pas de modification Dart → devrait passer sans surprise)
puro flutter analyze --no-pub
```

---

### Apprentissages des stories précédentes applicables

- **Story 7.0** : La déviation AuthWrapper a été introduite ici — voir commit `9e7c4ea` (`refactor(7.0): résoudre dette technique différée épic 6`) et commit `da9cab2` (`docs(bmad): close story 6.4 to review`)
- **Story 6.4** : Commit `c48c6f4` (`fix(auth): handle #sb route and mobile callback without session`) — c'est le commit qui a introduit `_isSupabaseCallbackRoute` et le routing vers `AuthWrapper`
- **Commandes Flutter via PowerShell + puro** (rappel transversal Épic 7)
- **`flutter analyze --no-pub` obligatoire avant de déclarer terminé** (rappel transversal Épic 7)

---

### Références

- `lib/presentation/pages/auth/auth_wrapper.dart` — implémentation AuthWrapper
- `lib/presentation/routes/app_routes.dart` — `_isSupabaseCallbackRoute()` + route callback
- `lib/infrastructure/services/web_auth_callback_stabilizer.dart` — stabilisation session
- `lib/data/providers/auth_providers.dart` — `authUIStateProvider`
- `lib/data/providers/consent_providers.dart` — `consentProvider`
- `.claude/skills/bmad-create-story/template.md` — template story à modifier
- `_bmad-output/planning-artifacts/` — dossier cible pour `architecture.md`
- `docs/ARCHITECTURE_GUIDE.md` — doc aspirationnelle (NE PAS MODIFIER)
- [Source: epic-8.md#Story 8.6] — acceptance criteria originaux

---

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

Aucun bug rencontré — story 100% documentation.

### Completion Notes List

- [x] T1 : `_bmad-output/planning-artifacts/architecture.md` créé — stack, couches, flux auth callback complet, déviation AuthWrapper documentée à partir du code réel (auth_wrapper.dart, app_routes.dart, supabase_service.dart, web_auth_callback_stabilizer.dart, prioris_app.dart)
- [x] T2 : `docs/TESTING_MOBILE_AUTH.md` créé — procédure rate limit, 3 options (alias email, attente, console Supabase), 5 cas de test callback, procédure compte non-créateur
- [x] T3 : `.claude/skills/bmad-create-story/template.md` mis à jour — ligne "Test non-créateur" ajoutée dans `### Completion Notes List`
- [ ] T4 : **EN ATTENTE REVUE MANUELLE THIBAUT** — lire `_bmad-output/planning-artifacts/architecture.md` et valider la cohérence avec le code
- [x] T5.1 : `puro flutter analyze` — 3683 issues pré-existantes dans test/, aucune régression Dart introduite (0 fichier Dart modifié)
- [x] T5.2 : Tous les chemins documentés vérifiés et existants (12/12 OK)
- [ ] Test non-créateur : vérifier le flux avec un compte utilisateur non-créateur du projet Supabase

### Review Findings

- [x] [Review][Patch] Email personnel PII hardcodé — `lambert.thibaut98+test2@gmail.com` remplacé par `yourname+test2@gmail.com` [`docs/TESTING_MOBILE_AUTH.md`]
- [x] [Review][Patch] Rate limit Supabase inexact — corrigé "par IP/projet selon configuration" + caveat Gmail +tag [`docs/TESTING_MOBILE_AUTH.md`]
- [x] [Review][Patch] Couche `application/` absente de "État des couches après Épic 7" — subsection ajoutée avec `common/`, `ports/`, `services/`, `export.dart` [`_bmad-output/planning-artifacts/architecture.md`]
- [x] [Review][Patch] `autoDispose` de `callbackWithoutSessionProvider` — mention `(autoDispose)` ajoutée dans tableau Fichiers clés [`_bmad-output/planning-artifacts/architecture.md`]
- [x] [Review][Patch] Commandes dev/CI sous `## Déploiement` — déplacées dans section `## Commandes développement locales` [`_bmad-output/planning-artifacts/architecture.md`]
- [x] [Review][Patch] Date périmée — corrigée en 2026-04-30 [`_bmad-output/planning-artifacts/architecture.md`]

### File List

- `_bmad-output/planning-artifacts/architecture.md` (CRÉÉ)
- `docs/TESTING_MOBILE_AUTH.md` (CRÉÉ)
- `.claude/skills/bmad-create-story/template.md` (MODIFIÉ)
- `_bmad-output/implementation-artifacts/8-6-mettre-a-jour-architecture-md-et-template-story.md` (MODIFIÉ — story file)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (MODIFIÉ — statut in-progress → review)
