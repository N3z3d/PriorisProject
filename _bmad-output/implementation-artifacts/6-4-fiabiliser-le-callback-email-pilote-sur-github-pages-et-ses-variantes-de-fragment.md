# Story 6.4: Fiabiliser le callback email pilote sur GitHub Pages et ses variantes de fragment

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

En tant que premier utilisateur externe invite,
Je veux que tout lien email Supabase me ramene vers un etat connu de Prioris sur la build publique, meme quand le callback prend une forme `?code=...`, `/#sb`, `/#sb...` ou une autre variante hash / fragment route-like,
afin d'entrer dans le pilote sans `Route non trouvee` et de conserver ma session apres refresh.

## Acceptance Criteria

1. Etant donne un lien email Supabase ouvert depuis desktop ou telephone sur la cible publique GitHub Pages, quand le callback arrive sous forme query (`?code=...`) ou hash / fragment route-like (`/#sb`, `/#sb-...`, `/#access_token=...`), alors l'application atteint un etat connu du shell ou de l'authentification, et elle n'affiche jamais `Route non trouvee`.
2. Etant donne que le pilote est servi sous `/PriorisProject/`, quand le callback est consomme puis que l'utilisateur recharge immediatement la page, alors le payload one-shot est nettoye proprement et le refresh ne rejoue pas un etat casse ni une route inconnue.
3. Etant donne que `Epic 6` doit rester borne, quand la story est implementee, alors elle reutilise les frontieres auth / bootstrap / routing existantes (`WebAuthCallbackStabilizer`, `SupabaseService`, `AppRoutes`) et ajoute une preuve repo-owned ciblee plus une recette publique desktop et telephone datee.

## Tasks / Subtasks

- [x] Etendre `WebAuthCallbackStabilizer.isAuthCallbackUri` pour reconnaitre les fragments Supabase route-like. (AC: 1, 2)
  - [x] Ajouter une detection des fragments qui commencent par `sb` (sans `=` ni `&`) comme signal de callback Supabase.
  - [x] Verifier que `_parseFragmentParameters` retourne `null` pour `"sb"` et que la nouvelle branche prend le relais.
  - [x] Etendre `stripAuthCallbackPayload` pour supprimer proprement un fragment `#sb` ou `#sb-...` sans laisser un fragment residuel route-like dans l'URL sanitisee.
  - [x] S'assurer que `stabilizeFromCurrentOrIncomingSessionIfNeeded` remplace l'URL `/#sb` par l'URL de base propre (`/PriorisProject/` ou `/`) via `browserAdapter.replaceUrl`.

- [x] Verifier et durcir le point de chute dans `AppRoutes.generateRoute` pour les fragments route-like residuels. (AC: 1)
  - [x] Inspecter si le routeur Flutter recoit jamais une route `#sb` ou `/PriorisProject/#sb` comme `settings.name` quand le stabilizer ne l'intercepte pas.
  - [x] Si oui, ajouter une branche de garde qui detecte les routes `#sb`-prefixees et redirige vers `/` au lieu d'appeler `_errorRoute`.
  - [x] Ne pas modifier la logique de routing existante pour `/`, `/list-detail`, `/agents-monitoring`.

- [x] Ecrire les tests unitaires cibles pour les nouvelles branches de `WebAuthCallbackStabilizer`. (AC: 1, 2, 3)
  - [x] `isAuthCallbackUri` retourne `true` pour `https://host/#sb`.
  - [x] `isAuthCallbackUri` retourne `true` pour `https://host/#sb-access_token=...` (variante prefixee).
  - [x] `isAuthCallbackUri` retourne `false` pour `https://host/#settings` (fragment app normal).
  - [x] `stripAuthCallbackPayload` retourne `https://host/PriorisProject/` pour `https://host/PriorisProject/#sb`.
  - [x] `stripAuthCallbackPayload` retourne `https://host/PriorisProject/` pour `https://host/PriorisProject/#sb-access_token=tok&refresh_token=ref`.
  - [x] Le refresh apres nettoyage ne rejoue pas l'URL casse (tester que l'URL resultante ne contient plus `#sb`).

- [x] Executer la matrice de verification repo-owned. (AC: 3)
  - [x] `flutter analyze --no-pub` sans nouveau warning.
  - [x] `flutter test test/infrastructure/services/web_auth_callback_stabilizer_test.dart` vert.
  - [x] `flutter test test/integration/auth_flow_integration_test.dart` vert.
  - [x] `flutter build web` propre.

- [ ] Documenter la preuve publique de cloture. (AC: 1, 2, 3)
  - [ ] Redeployer la build via le workflow `Deploy Pilot Web to GitHub Pages`.
  - [ ] Rejouer la recette `email -> callback -> arrivee -> refresh` sur desktop (Chrome / Edge 1280x800) avec la cible publique `https://n3z3d.github.io/PriorisProject/`.
  - [ ] Rejouer la meme recette sur telephone (Chrome Android ou Safari iPhone 390x844).
  - [ ] Dater les preuves (2026-04-XX) et les ajouter dans le Dev Agent Record de cette story.
  - [ ] Mettre a jour `docs/PILOT_READINESS_AND_CLOSEOUT.md` vers `GO` si les preuves passent.

## Dev Notes

### Story Context

- Le commit `4f5120e fix: stabilize web auth callback refresh` (2026-04-19) a stabilise les callbacks PKCE (`?code=...`) et les fragments implicites avec tokens (`#access_token=...&refresh_token=...`). Il a introduit `WebAuthCallbackStabilizer`, `WebAuthCallbackBrowserAdapter`, les fichiers platform-stub/web, et les tests unitaires et d'integration. [Source: `git show 4f5120e --stat`]
- La preuve publique du 2026-04-20 montre que `https://n3z3d.github.io/PriorisProject/#sb` atterrit sur `Route non trouvee`. Le fragment `sb` seul n'est pas reconnu par `isAuthCallbackUri` car `_parseFragmentParameters("sb")` retourne `null` (pas de `=` ni `&`). [Source: `_bmad-output/planning-artifacts/sprint-change-proposal-2026-04-20.md`; `lib/infrastructure/services/web_auth_callback_stabilizer.dart:334-345`]
- La Sprint Change Proposal `2026-04-20` a ete approuvee; `epic-6` est rouvert en `in-progress` et `6.4` est en `backlog`. [Source: `_bmad-output/implementation-artifacts/sprint-status.yaml`]

### Technical Requirements

- **Cause racine identifiee:** Dans `isAuthCallbackUri`, `_parseFragmentParameters(uri.fragment)` retourne `null` si le fragment ne contient pas `=` ou `&`. Pour `#sb`, le fragment est `"sb"`, la methode retourne `null`, et `isAuthCallbackUri` retourne `false`. Le stabilizer ne s'active pas, l'URL reste `/#sb`, et Flutter router voit `#sb` comme route inconnue.
- **Fix principal:** Etendre `isAuthCallbackUri` pour reconnaitre les fragments Supabase route-like en ajoutant une branche: `if (fragment == 'sb' || fragment.startsWith('sb-') || fragment.startsWith('sb.'))` → retourner `true`. Valider la pattern avec la doc Supabase auth (les prefixes `sb` et `sb-` sont des marqueurs Supabase courants dans les flows email).
- **Fix secondaire:** S'assurer que `stripAuthCallbackPayload` supprime completement le fragment `#sb` (et ses variantes) de l'URL resultante. Actuellement, si `fragmentParameters == null`, `_buildFilteredFragment` retourne `rawFragment` tel quel. Pour un fragment `"sb"` reconnu comme Supabase route-like, il faut retourner `""` (fragment vide).
- **Anti-pattern a eviter:** Ne pas modifier `app_routes.dart` pour silencieusement rediriger tout fragment inconnu vers `/`. Cette approche masquerait des bugs de routing. La bonne correction est dans le stabilizer, pas dans le router.
- **Constraint:** `detectSessionInUri: false` est deja positionne dans `SupabaseService.initialize()` pour eviter le double-traitement. Garder ce parametre tel quel.

### Architecture Compliance

- Les fichiers autorises pour `6.4` sont:
  - `lib/infrastructure/services/web_auth_callback_stabilizer.dart` (correction principale)
  - `test/infrastructure/services/web_auth_callback_stabilizer_test.dart` (nouveaux cas de test)
  - `test/infrastructure/services/web_auth_callback_stabilizer_browser_test.dart` (si necesssaire pour le flow web reel)
  - `test/integration/auth_flow_integration_test.dart` (si le scenario `#sb` doit etre couvert)
  - `docs/PILOT_READINESS_AND_CLOSEOUT.md` (mise a jour du gate si preuve verte)
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` (passage a `done` apres cloture)
- Les fichiers a ne pas toucher sans nouveau cadrage:
  - `lib/presentation/routes/app_routes.dart` (sauf si la branche guard residuelle est explicitement justifiee par une evidence de route `#sb` passant au router)
  - `lib/core/bootstrap/app_initializer.dart`, `lib/presentation/app/prioris_app.dart`, `lib/presentation/pages/auth/auth_wrapper.dart`
  - toute logique de persistance, synchro, habitudes, listes, taches
- Respecter la frontiere architecture: la normalisation du callback auth web public, y compris les variantes hash / fragment route-like, reste dans `SupabaseService` et `WebAuthCallbackStabilizer`. [Source: `_bmad-output/planning-artifacts/architecture.md` synchro 2026-04-20]

### Library / Framework Requirements

- **Supabase auth flows:** Supabase utilise differents flux selon le type d'email:
  - Magic Link / Email OTP: utilise le flow implicite et peut produire `#access_token=...&refresh_token=...`
  - Confirmation email (signup): peut passer par PKCE (`?code=...`) ou par fragment
  - Les fragments `#sb`, `#sb-...` sont des prefixes Supabase pour les URL de callback dans certains flows
- **Flutter web routing:** Sur GitHub Pages avec base href `/PriorisProject/`, le routeur Flutter recoit la partie chemin apres le base href. Un fragment comme `#sb` est traite comme route par le routeur si le stabilizer ne l'intercepte pas.
- **Versions actives:** `supabase_flutter` version existante deja prouvee par `6.1`-`6.3`. Pas d'upgrade de dependance pour cette story.
- **Pattern `browserAdapter.replaceUrl`:** utilise `history.replaceState` via la plateforme web pour remplacer l'URL sans reload. L'URL de remplacement doit pointer vers le base path propre (`/PriorisProject/`) pour que le routeur retrouve la route `/`. [Source: `lib/infrastructure/services/web_auth_callback_platform_web.dart`]

### File Structure Requirements

- Fichiers a lire avant implementation:
  - `lib/infrastructure/services/web_auth_callback_stabilizer.dart` (complet, deja lu)
  - `lib/infrastructure/services/supabase_service.dart` (complet, deja lu)
  - `lib/presentation/routes/app_routes.dart` (complet, deja lu)
  - `test/infrastructure/services/web_auth_callback_stabilizer_test.dart`
  - `test/infrastructure/services/web_auth_callback_stabilizer_browser_test.dart`
  - `test/integration/auth_flow_integration_test.dart`
  - `docs/PILOT_READINESS_AND_CLOSEOUT.md`
  - `lib/infrastructure/services/web_auth_callback_platform_web.dart`
  - `lib/infrastructure/services/web_auth_callback_platform_stub.dart`
- Fichiers les plus probables a modifier:
  - `lib/infrastructure/services/web_auth_callback_stabilizer.dart` (correction `isAuthCallbackUri` + `_buildFilteredFragment`)
  - `test/infrastructure/services/web_auth_callback_stabilizer_test.dart` (nouveaux cas `#sb`)
  - `docs/PILOT_READINESS_AND_CLOSEOUT.md` (mise a jour gate si preuve verte)
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` (status final)

### Testing Requirements

- Tests unitaires requis (dans `web_auth_callback_stabilizer_test.dart`):
  - `isAuthCallbackUri` retourne `true` pour `https://n3z3d.github.io/PriorisProject/#sb`
  - `isAuthCallbackUri` retourne `true` pour `https://host/#sb-access_token=tok&refresh_token=ref` (variante prefixee Supabase)
  - `isAuthCallbackUri` retourne `false` pour `https://host/#settings` (fragment app non-Supabase)
  - `isAuthCallbackUri` retourne `false` pour `https://host/` (URL sans fragment)
  - `stripAuthCallbackPayload` retourne `https://n3z3d.github.io/PriorisProject/` (sans fragment) pour `https://n3z3d.github.io/PriorisProject/#sb`
  - Regression: les tests existants pour `?code=...`, `#access_token=...` restent verts
- Tests d'integration:
  - Verifier dans `auth_flow_integration_test.dart` que le scenario `/#sb` ne produit plus de route inconnue apres le passage du stabilizer
- Commandes de verification:
  - `flutter analyze --no-pub`
  - `flutter test test/infrastructure/services/web_auth_callback_stabilizer_test.dart`
  - `flutter test test/integration/auth_flow_integration_test.dart`
  - `flutter build web`

### Previous Story Intelligence

- `6.3` a produit `docs/PILOT_READINESS_AND_CLOSEOUT.md` avec un gate documentaire et un cadre de closeout. Apres `6.4`, ce document doit passer de `NO-GO` (bloqueur callback `#sb`) a `GO` si les preuves publiques sont vertes. [Source: `_bmad-output/implementation-artifacts/6-3-documenter-le-gate-de-readiness-et-le-closeout-du-pilote.md`]
- `6.1` a ferme la cible pilote `https://n3z3d.github.io/PriorisProject/` et le workflow GitHub Pages. `6.4` redeploie sur cette meme cible sans modifier la configuration Pages.
- La structure de test introduite par `4f5120e` dans `web_auth_callback_stabilizer_test.dart` et `web_auth_callback_stabilizer_browser_test.dart` est la reference a etendre pour les nouveaux cas `#sb`. Ne pas creer un nouveau fichier de test; ajouter les cas dans les fichiers existants.
- Le code de `WebAuthCallbackStabilizer` a ete fortement structure par `4f5120e`: toujours utiliser le pattern `@visibleForTesting` pour exposer les helpers aux tests, et garder les methodes privees `_parseFragmentParameters` et `_buildFilteredFragment` internes. Les nouveaux cas peuvent etre couverts via les methodes publiques `isAuthCallbackUri` et `stripAuthCallbackPayload`.

### Git Intelligence Summary

- `4f5120e fix: stabilize web auth callback refresh` (2026-04-19): Ce commit a ajoute 656 lignes sur 8 fichiers. Il introduit le `WebAuthCallbackStabilizer` complet avec support PKCE, support fragment implicite (`#access_token=...`), les adapters platform-stub/web, et les tests unitaires + integration. C'est la base sur laquelle `6.4` s'appuie.
- Le commit ne couvre pas les fragments `#sb` nus (sans `=`): c'est le gap que `6.4` doit fermer.
- `cab5db7 fix: publish public signup confirmation flow` et `bb4893f fix: publish default pilot support channel` montrent que les recentes corrections ont touche le flux d'inscription public et le support pilote. Ces fixes ne touchent pas le routing.

### Latest Tech Information

- **Supabase email callback patterns (2026):** Les emails Supabase (magic link, confirmation, reset) utilisent une URL de redirect configuree dans le dashboard Supabase. Le SDK Flutter `supabase_flutter` attend un callback sous forme `?code=...` (PKCE) ou `#access_token=...&refresh_token=...` (implicite). La variante `#sb` peut apparaitre quand Supabase utilise un prefixe interne pour differencier ses propres fragments des fragments d'application.
- **GitHub Pages + Flutter web:** GitHub Pages sert uniquement `index.html`. Le routeur Flutter web recoit l'URL complete et extrait le chemin/fragment selon la strategie URL configuree. Si la strategie est `PathUrlStrategy` (pas de hash), un fragment `#sb` est traite comme fragment HTML pur et passe au routeur. Si la strategie est `HashUrlStrategy` (defaut Flutter web), le fragment est interprete comme route.
- **flutter_web_plugins routing:** Le runtime Flutter web initialise le routeur depuis `window.location.href`. Un fragment `#sb` sans correspondance de route declenche `generateRoute` avec `settings.name = '/sb'` ou `settings.name = '#sb'` selon la strategie. La correction dans le stabilizer (replaceUrl avant le premier frame) empeche ce chemin.

### Project Context Reference

- `tasks/todo.md` est la source de verite du slice actif; a mettre a jour pendant l'implementation.
- `_bmad-output/project-context.md` impose des preuves desktop + telephone, des dates absolues et une distinction stricte entre preuve repo-owned et validation externe reelle.
- Le gate pilote `docs/PILOT_READINESS_AND_CLOSEOUT.md` doit etre mis a jour vers `GO` uniquement apres que les preuves publiques ont ete effectivement rejoues et dates.

### Project Structure Notes

- Pattern etabli par `4f5120e`: les methodes `isAuthCallbackUri` et `stripAuthCallbackPayload` sont exposees comme `@visibleForTesting` et testees directement. Suivre ce pattern pour les nouveaux cas.
- La methode `_parseFragmentParameters` est privee et retourne `null` pour les fragments sans `=` ni `&`. Ne pas modifier cette semantique; ajouter la logique Supabase route-like AVANT l'appel a `_parseFragmentParameters` dans `isAuthCallbackUri`.
- Le fichier `web_auth_callback_platform_web.dart` contient l'implementation `dart:html` de `replaceBrowserUrl`. Sur la plateforme stub, c'est un no-op. Pas de modification a prevoir ici.

### References

- Planning canonique:
  - `_bmad-output/planning-artifacts/epics.md` (Story 6.4 ajoutee par sprint-change-proposal-2026-04-20)
  - `_bmad-output/planning-artifacts/sprint-change-proposal-2026-04-20.md` (analyse technique complete)
  - `_bmad-output/planning-artifacts/architecture.md` (frontiere `Epic 6` etendue au callback hash / fragment route-like)
- Contexte implementation:
  - `_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md`
  - `_bmad-output/implementation-artifacts/6-3-documenter-le-gate-de-readiness-et-le-closeout-du-pilote.md`
  - `_bmad-output/implementation-artifacts/sprint-status.yaml`
- Code a modifier:
  - `lib/infrastructure/services/web_auth_callback_stabilizer.dart`
  - `lib/infrastructure/services/supabase_service.dart` (lecture seule probable)
  - `lib/presentation/routes/app_routes.dart` (lecture seule probable)
- Tests a etendre:
  - `test/infrastructure/services/web_auth_callback_stabilizer_test.dart`
  - `test/infrastructure/services/web_auth_callback_stabilizer_browser_test.dart`
  - `test/integration/auth_flow_integration_test.dart`
- Documentation pilote:
  - `docs/PILOT_READINESS_AND_CLOSEOUT.md`
  - `docs/PILOT_PAGES_DEPLOYMENT.md`
  - `.github/workflows/deploy-pilot-pages.yml`

## Change Log

- 2026-04-20: story creee via workflow `create-story` a partir de la Sprint Change Proposal approuvee du 2026-04-20. La cause racine du `#sb -> Route non trouvee` est identifiee dans `WebAuthCallbackStabilizer.isAuthCallbackUri`. Le fix principal est dans `web_auth_callback_stabilizer.dart`.

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- Analyse de `git show 4f5120e --stat` pour comprendre la base existante
- Lecture de `lib/infrastructure/services/web_auth_callback_stabilizer.dart` (complet)
- Lecture de `lib/infrastructure/services/supabase_service.dart` (complet)
- Lecture de `lib/presentation/routes/app_routes.dart` (complet)
- Lecture de `_bmad-output/planning-artifacts/sprint-change-proposal-2026-04-20.md` (complet)
- Lecture de `_bmad-output/implementation-artifacts/6-3-documenter-le-gate-de-readiness-et-le-closeout-du-pilote.md` (complet)
- Lecture de `_bmad-output/implementation-artifacts/sprint-status.yaml` (complet)

### Completion Notes List

- La cause racine est precise: `_parseFragmentParameters("sb")` retourne `null` car `"sb"` ne contient pas `=` ni `&`, donc `isAuthCallbackUri` retourne `false` pour `/#sb`.
- Le fix doit etre minimal: etendre `isAuthCallbackUri` avec une branche Supabase route-like, et corriger `_buildFilteredFragment` pour retourner `""` sur ce cas.
- Ne pas re-architecturer le routeur; la correction doit se faire dans le stabilizer avant le premier frame Flutter.
- La preuve publique (desktop + telephone) est obligatoire pour fermer cette story.

### File List

