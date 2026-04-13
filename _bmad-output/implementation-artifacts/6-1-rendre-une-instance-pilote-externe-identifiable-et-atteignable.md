# Story 6.1: Rendre une instance pilote externe identifiable et atteignable

Status: in-progress

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

En tant que premier utilisateur externe invite,
Je veux acceder a une instance pilote reelle clairement identifiee depuis mon appareil supporte,
afin d'utiliser Prioris sans dependre d'un runtime local ni d'un harnais repo-owned.

## Acceptance Criteria

1. Etant donne un petit groupe d'utilisateurs pilotes explicitement invites, quand l'un de ces utilisateurs ouvre le point d'entree retenu pour le pilote sur desktop ou telephone, alors il atteint une instance pilote reelle utilisable sans prerequis locaux du repo, et l'instance indique clairement qu'il s'agit du pilote, ce qui est supporte et quelles limites sont encore connues.
2. Etant donne que le produit distingue maintenant preuve repo-owned locale et pilote externe reel, quand cette story est verifiee, alors sa cloture documente la cible de deploiement ou d'hebergement, la preuve desktop, la preuve telephone et les limites retenues, et aucune preuve locale seule n'est presentee comme preuve suffisante du pilote reel.
3. Etant donne que ce lane ne doit pas rouvrir le coeur produit, quand l'acces pilote est mis en place, alors il reutilise le shell, l'authentification et les frontieres deja prouvees, et il n'introduit ni re-architecture d'auth, ni nouveau chemin de persistance, ni semantique de synchro parallele.

## Tasks / Subtasks

- [ ] Nommer et brancher une cible pilote reelle unique, distincte du runtime local, sans creer un second produit. (AC: 1, 2, 3)
  - [ ] Documenter un point d'entree pilote explicite et sa source de verite unique, au niveau du build, du runtime ou des artefacts de deploiement, au lieu de disperser des libelles/URLs pilotes en dur dans plusieurs widgets.
  - [x] Reutiliser le chemin runtime normal `PriorisApp -> AuthWrapper -> LoginPage/HomePage` sans introduire de route parallele, de shell alternatif ni de bypass repo-owned.
  - [x] Si une identite pilote visible est ajoutee dans l'application, la deriver d'une seule source de config ou de metadata de build plutot que de dupliquer un nom d'instance dans `web/index.html`, `manifest.json`, `LoginHeader`, `HomePage` ou `SettingsPage`.

- [x] Rendre l'instance pilote identifiable des l'entree et apres authentification sur desktop et telephone. (AC: 1, 3)
  - [x] Ajuster uniquement les surfaces vraiment necessaires pour rendre le pilote identifiable et atteignable: metadata web (`web/index.html`, `web/manifest.json`), branding d'entree auth, shell ou surface d'information deja existante si elle porte legitiment l'identite du pilote.
  - [x] Expliciter qu'il s'agit du pilote, ce qui est supporte et quelles limites sont connues, avec une copy localisee, comprehensible pour un non-createur et coherente entre desktop et telephone.
  - [x] Conserver des affordances accessibles et sobres: focus visible, labels utiles, cibles tactiles suffisantes, pas de texte ambigu entre etat du pilote, erreur technique et limite connue.

- [x] Garder la story sur la frontiere acces/identification de l'instance, pas sur le support pilote riche. (AC: 2, 3)
  - [x] Ne pas rouvrir `auth`, `persistance`, `synchro`, onboarding riche, legal/public pages hebergees, billing, analytics ou marketing public.
  - [x] Ne pas transformer `Aide`, `Feedback`, `Confidentialite` ou `Conditions` en canaux riches ici; si un repere minimal est indispensable pour l'identite du pilote, le garder borne et laisser `6.2` fermer le support pilote reel.
  - [x] Ne pas presenter le runtime local Docker, le harnais `signed_in_smoke` ou une simple preuve repo-owned comme validation suffisante d'une instance pilote externe reelle.

- [ ] Fermer une matrice de preuve distincte pour l'instance pilote reelle et les preuves repo-owned corrigees a la bonne frontiere. (AC: 1, 2, 3)
  - [x] Ajouter ou etendre des tests presentation/integration sur le chemin authentifie normal pour prouver les reperes d'identification pilote sur desktop et sur telephone.
  - [x] Si les metadata web ou le bootstrap web sont touches, verifier explicitement qu'ils restent compatibles avec le bootstrap Flutter normal (`flutter build web`, `index.html`, `manifest.json`) et ne cassent ni le `base href` ni le chargement `flutter_bootstrap.js`.
  - [ ] Documenter en closeout la cible pilote hebergee, la preuve desktop, la preuve telephone, la date de verification et les limites retenues; toute preuve locale repo-owned n'est qu'un support secondaire.

- [x] Documenter explicitement la frontiere d'implementation, les fichiers probables et les hors-scope avant `dev-story`. (AC: 2, 3)
  - [x] Nommer la frontiere principale `web entry / presentation shell / auth entry -> providers auth existants -> runtime courant`, sans branchement direct UI -> infrastructure.
  - [x] Lister les fichiers a lire avant implementation et ceux a ne pas recycler tels quels (`signed_in_smoke`, `widgets/onboarding`) pour eviter les contresens de scope.
  - [x] Nommer des le story authoring la preuve desktop attendue, la preuve telephone attendue et la limite acceptee si une verification manuelle sur cible pilote reelle reste necessaire.

## Dev Notes

### Story Context

- `6.1` ouvre `Epic 6` apres la cloture d'`Epic 5`. Le lane `Epic 5` a deja ferme l'acces externe credible (`5.1`), la comprehension initiale du shell (`5.2`) et la surface de parametrage pilote honnete (`5.3`). Le plus petit prochain pas observable n'est donc pas un nouveau flux produit, mais la designation et l'identification d'une vraie instance pilote externe distincte du runtime local. [Source: `_bmad-output/planning-artifacts/epics.md`; `_bmad-output/implementation-artifacts/5-1-rendre-lacces-au-produit-credible-pour-un-premier-utilisateur-externe.md`; `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`]
- Le PRD formalise ce lane comme une phase "premier pilote externe reel", avec trois exigences fortes: une instance pilote reelle explicitement distincte du runtime local, des points de contact pilotes reels, et des criteres de sortie observables. `6.1` ne ferme que la premiere brique de ce triptyque. [Source: `_bmad-output/planning-artifacts/prd.md`]
- L'architecture autorise explicitement `Epic 6` a toucher la designation de la cible pilote reelle et les informations de version associees, mais interdit toute derive vers une ouverture publique large, une re-architecture auth/persistence/synchro ou un systeme de support riche. [Source: `_bmad-output/planning-artifacts/architecture.md`]
- Le runtime local documente dans `docs/LOCAL_RUNTIME.md` sert volontairement une preuve locale LAN (`localhost` / IP locale) et dit explicitement qu'il ne fournit pas d'URL publique. Ce runtime ne peut donc pas etre presente comme la cible pilote reelle de `6.1`, seulement comme une preuve repo-owned secondaire. [Source: `docs/LOCAL_RUNTIME.md`]
- Le repo possede deja plusieurs surfaces visibles pouvant porter l'identite du pilote sans nouveau shell: `LoginHeader`, `LoginPage`, `HomePage`, `SettingsPage`, `web/index.html` et `web/manifest.json`. Le travail attendu est de choisir le plus petit ensemble coherent de points d'appui, pas de multiplier les banners ou les parcours. [Source: `lib/presentation/pages/auth/components/login_header.dart`; `lib/presentation/pages/home_page.dart`; `lib/presentation/pages/settings_page.dart`; `web/index.html`; `web/manifest.json`]

### Technical Requirements

- Etat de depart exact a prouver pour `6.1`: un utilisateur externe explicitement invite, sur un navigateur supporte, ouvre le point d'entree retenu pour le pilote depuis desktop ou telephone et arrive sur une vraie instance pilote identifiable, sans dependre d'un conteneur local, d'un harnais smoke ni d'une manipulation repo-owned.
- La cible pilote doit etre nommee et derivable d'une source unique. La story ne doit pas laisser un nom d'instance, une URL ou une version d'environnement se dupliquer librement dans plusieurs fichiers. Si une metadata de build ou de config runtime est necessaire, elle doit etre centralisee et relue depuis la meme source a tous les endroits visibles.
- `LoginHeader` affiche aujourd'hui `Prioris` et le mode `connexion / inscription`, mais ne distingue pas un pilote externe reel d'un runtime de dev. `SettingsPage` expose deja depuis `5.3` des informations de pilote et de version honnetes. `6.1` doit reutiliser ces surfaces de facon coherente plutot que raconter une histoire differente sur chaque ecran. [Source: `lib/presentation/pages/auth/components/login_header.dart`; `lib/presentation/pages/settings_page.dart`]
- `web/index.html` et `web/manifest.json` portent encore des metadata generiques (`A new Flutter project.`, `prioris`). Si l'identification du pilote doit exister au niveau navigateur ou installation web, ce sont les premiers candidats a realigner. [Source: `web/index.html`; `web/manifest.json`]
- Le chemin auth ferme par `5.1` reste la seule entree runtime valide: `PriorisApp -> AuthWrapper -> LoginPage/HomePage`. `6.1` ne doit pas introduire de nouvelle route publique autonome, de landing page marketing ou de wizard d'invitation. [Source: `_bmad-output/implementation-artifacts/5-1-rendre-lacces-au-produit-credible-pour-un-premier-utilisateur-externe.md`; `lib/presentation/app/prioris_app.dart`; `lib/presentation/pages/auth/auth_wrapper.dart`]
- Les points de contact riches (`Aide`, `Feedback`, `Confidentialite`, `Conditions`) sont le territoire naturel de `6.2`. `6.1` peut seulement s'appuyer sur un repere deja existant s'il sert directement a identifier la cible pilote, sans absorber la fermeture du support reel.
- Toute nouvelle chaine visible doit passer par `AppLocalizations`. Aucun texte durable ne doit etre ajoute directement dans les widgets, et aucun fichier genere `lib/l10n/app_localizations*.dart` ne doit etre edite a la main. [Source: `_bmad-output/project-context.md`; `lib/l10n/app_fr.arb`]
- Aucune dependance externe nouvelle n'est justifiee ici. La stack actuelle et les affordances Flutter existantes suffisent pour rendre le pilote identifiable et nommer sa cible.

### Architecture Compliance

- Respecter la frontiere existante `presentation shell / auth entry -> Riverpod providers existants -> services courants`. Aucun widget de `6.1` ne doit lire directement `.env`, Supabase ou une configuration brute hors abstraction deja prevue par le repo.
- `6.1` peut toucher:
  - l'identite visible de l'instance pilote dans les surfaces d'entree ou de shell existantes
  - les metadata web (`index.html`, `manifest.json`) si elles participent a rendre le pilote identifiable
  - une source unique de metadata de build/config si elle evite la duplication de l'identite pilote
  - les tests presentation/integration lies a cette frontiere
- `6.1` ne doit pas toucher sans nouveau cadrage:
  - `UnifiedPersistenceService`
  - `PersistenceCoordinator`
  - la semantique globale de synchro visible
  - un nouveau chemin auth ou un bypass `Navigator` direct vers `HomePage`
  - un help center externe, une page marketing publique, du billing ou de l'analytics
- Si un point d'entree routeable supplementaire est envisage, il doit rester dans les routes existantes et ne pas casser la navigation primaire; en cas de doute, ne pas ouvrir `app_routes.dart` dans `6.1`.

### Library / Framework Requirements

- Rester sur la stack actuelle du repo sans upgrade ni nouvelle dependance: Flutter web, Riverpod `2.4.9`, Hive/SharedPreferences existants, `flutter_localizations`, `intl`, Supabase Flutter `2.5.6`. [Source: `_bmad-output/project-context.md`; `pubspec.yaml`]
- D'apres la FAQ officielle Flutter web, les navigateurs supportes incluent Chrome, Safari, Edge et Firefox sur mobile et desktop. La story doit donc formuler ses preuves au minimum sur desktop Chrome stable courant et mobile Safari/Chrome dans les formats de reference deja retenus par le PRD. [Source: `https://docs.flutter.dev/platform-integration/web/faq`]
- D'apres la documentation officielle Flutter web initialization, `flutter build web` produit `flutter_bootstrap.js` dans `build/web`, et `web/index.html` reste un point d'entree templated critique pour le chargement et le `base href`. Si `6.1` touche l'identite web, il faut preserver cette structure et ne pas casser le bootstrap. [Source: `https://docs.flutter.dev/platform-integration/web/initialization`]
- La meme documentation indique aussi que `assetBase` et le `base href` deviennent importants si les assets sont servis depuis un sous-repertoire ou un CDN. Si la cible pilote reelle est hebergee hors racine, `6.1` doit documenter cette contrainte explicitement au lieu de hardcoder des chemins absolus fragiles. [Source: `https://docs.flutter.dev/platform-integration/web/initialization`]
- D'apres la documentation Flutter WebAssembly a jour, une build Wasm ne peut pas tourner sur iOS quel que soit le navigateur, et Safari/WebKit restent encore limites pour le renderer Wasm. Comme `PTR2` et `PTR3` imposent un telephone iPhone/Safari de reference, `6.1` ne doit pas faire d'une build `--wasm` la preuve primaire du pilote reel; la baseline de verification doit rester compatible mobile Safari. [Source: `https://docs.flutter.dev/platform-integration/web/wasm`]
- Si un build Wasm est explore plus tard pour performance, il devra rester un choix secondaire et documente, pas le prerequis d'entree du premier pilote reel.

### File Structure Requirements

- Fichiers a lire avant implementation:
  - `lib/presentation/app/prioris_app.dart`
  - `lib/presentation/pages/auth/auth_wrapper.dart`
  - `lib/presentation/pages/auth/login_page.dart`
  - `lib/presentation/pages/auth/components/login_header.dart`
  - `lib/presentation/pages/home_page.dart`
  - `lib/presentation/pages/settings_page.dart`
  - `lib/core/config/app_config.dart`
  - `lib/core/bootstrap/app_initializer.dart`
  - `web/index.html`
  - `web/manifest.json`
  - `docs/LOCAL_RUNTIME.md`
  - `test/presentation/pages/home_page_test.dart`
  - `test/presentation/pages/settings_page_test.dart`
  - `test/integration/auth_flow_integration_test.dart`
  - `test/integration/signed_in_smoke_integration_test.dart`
- Fichiers susceptibles d'etre modifies pendant `dev-story`:
  - `lib/presentation/pages/auth/components/login_header.dart`
  - `lib/presentation/pages/auth/login_page.dart` seulement si l'identification pilote y est necessaire
  - `lib/presentation/pages/home_page.dart`
  - `lib/presentation/pages/settings_page.dart` seulement si elle porte legitimement l'identite pilote deja existante
  - `lib/core/config/app_config.dart` ou une abstraction voisine si une source unique de metadata pilote est necessaire
  - `web/index.html`
  - `web/manifest.json`
  - `lib/l10n/app_fr.arb`
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_es.arb`
  - `lib/l10n/app_de.arb`
  - tests presentation/integration associes
- Fichiers a ne pas utiliser comme preuve principale ou comme base directe de `6.1`:
  - `docs/LOCAL_RUNTIME.md` comme cible pilote reelle
  - `lib/main_signed_in_smoke.dart`
  - `lib/smoke/signed_in_smoke.dart`
  - `test/integration/signed_in_smoke_integration_test.dart` comme preuve primaire du pilote reel
  - `lib/presentation/widgets/onboarding/` comme chemin runtime normal du pilote

### Testing Requirements

- Verification ciblee minimale attendue pendant `dev-story`:
  - `flutter gen-l10n` si des fichiers `.arb` changent
  - `flutter analyze --no-pub lib/presentation/app/prioris_app.dart lib/presentation/pages/auth/auth_wrapper.dart lib/presentation/pages/auth/login_page.dart lib/presentation/pages/auth/components/login_header.dart lib/presentation/pages/home_page.dart lib/presentation/pages/settings_page.dart lib/core/config/app_config.dart lib/core/bootstrap/app_initializer.dart test/presentation/pages/home_page_test.dart test/presentation/pages/settings_page_test.dart test/integration/auth_flow_integration_test.dart test/integration/signed_in_smoke_integration_test.dart`
  - `flutter test test/presentation/pages/home_page_test.dart`
  - `flutter test test/presentation/pages/settings_page_test.dart`
  - `flutter test test/integration/auth_flow_integration_test.dart`
  - `flutter build web` si `web/index.html`, `web/manifest.json` ou des metadata de build web sont modifies
- Cas de test minimaux a couvrir:
  - desktop: le point d'entree normal du pilote et le shell affichent une identite pilote explicite et non ambigue
  - telephone: la meme information essentielle reste visible et comprehensible sur un viewport de reference `390x844`
  - aucune copy visible ne renvoie au runtime local, au repo, a un harnais smoke ou a une exigence de contexte createur
  - aucune reouverture d'auth/persistance/synchro n'est introduite pour afficher l'identite du pilote
  - si les metadata web sont modifiees, le bootstrap Flutter reste intact et le build web reste fonctionnel
- Matrice de preuve requise pour fermer `6.1`:
  - une preuve desktop repo-owned sur le chemin runtime normal
  - une preuve telephone repo-owned sur le meme chemin
  - une preuve documentaire de la cible pilote reelle: URL/hosting, date de verification, navigateur/appareil, limites connues
  - une note explicite indiquant que la preuve locale repo-owned ne remplace pas la validation du pilote reel

### Lane Intelligence

- Il n'existe pas encore de story precedente dans `Epic 6`. Les apprentissages a reutiliser viennent donc du lane externe ferme en `Epic 5`, pas d'une story `6.0`.
- `5.1` a deja verrouille la regle "pas de nouveau flux auth ni de bypass du shell". `6.1` doit conserver cette discipline et rendre la cible pilote reelle identifiable sans remettre en cause le contrat d'acces etabli. [Source: `_bmad-output/implementation-artifacts/5-1-rendre-lacces-au-produit-credible-pour-un-premier-utilisateur-externe.md`]
- `5.3` a deja nettoye `SettingsPage` pour expliquer honnetement le pilote, la langue, la version et les limites courantes. `6.1` doit s'appuyer sur cette semantique au lieu de recreer une seconde histoire du pilote dans une autre surface. [Source: `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`]
- La retro Epic 5 et la readiness `Epic 6` convergent sur une meme exigence: distinguer clairement preuve repo-owned locale, readiness de deploiement et validation externe reelle. Toute solution qui melange ces trois niveaux doit etre rejetee pendant `dev-story`. [Source: `_bmad-output/implementation-artifacts/epic-5-retro-2026-04-12.md`; `_bmad-output/planning-artifacts/implementation-readiness-report-2026-04-12.md`]

### Git Intelligence Summary

- Les 5 derniers commits visibles du depot portent surtout sur habitudes, list detail et tooling; ils ne donnent pas de pattern recent specifique pour le lane `pilote externe reel`.
- Conclusion actionable: pour `6.1`, la verite d'implementation est le code runtime actuel (`PriorisApp`, auth entry, shell, metadata web, settings`) et les story files `5.1` a `5.3`, pas un precedent Git recent.

### Latest Tech Information

- Flutter web supported browsers:
  - Chrome (mobile & desktop)
  - Safari (mobile & desktop)
  - Edge (mobile & desktop)
  - Firefox (mobile & desktop)
  Cela confirme que la matrice desktop + telephone du projet reste alignable sans changement de stack. [Source: `https://docs.flutter.dev/platform-integration/web/faq`]
- Flutter web initialization:
  - `flutter build web` produit `flutter_bootstrap.js` dans `build/web`
  - `web/index.html` reste le point d'entree a conserver et peut etre personnalise sans casser le bootstrap si ses tokens/template sont preserves
  - `assetBase` et le `base href` deviennent critiques si la cible pilote heberge les assets hors racine
  [Source: `https://docs.flutter.dev/platform-integration/web/initialization`]
- Flutter Wasm:
  - `flutter build web --wasm` existe, mais la doc officielle precise qu'une app Flutter compilee en Wasm ne peut pas tourner sur iOS quel que soit le navigateur
  - Safari/WebKit reste encore limite pour ce renderer
  - pour `6.1`, la preuve primaire doit donc rester compatible avec iPhone/Safari, et toute exploration Wasm doit etre documentee comme option secondaire
  [Source: `https://docs.flutter.dev/platform-integration/web/wasm`]

### Project Context Reference

- `tasks/todo.md` reste la source de verite du slice courant et doit contenir le plan, la revue, les validations executees et la prochaine etape BMAD.
- `_bmad-output/project-context.md` impose:
  - pas d'edition manuelle des fichiers generes
  - pas de texte durable hardcode comme solution normale
  - pas de chemin direct `presentation -> infrastructure`
  - petits lots verifies avant toute declaration de fin
  - replanification immediate si l'implementation force une dependance ou une integration externe non prevue
- Si des fichiers `.arb` changent pendant `dev-story`, relancer `flutter gen-l10n` avant `analyze` et `test`.

### Project Structure Notes

- `PriorisApp` garde aujourd'hui `MaterialApp`, la localisation, le theme et le wrapper responsive; c'est le bon point de verite pour le runtime courant. [Source: `lib/presentation/app/prioris_app.dart`]
- `LoginHeader` reste un point d'entree tres compact et facile a realigner si l'identite pilote doit etre visible avant auth. [Source: `lib/presentation/pages/auth/components/login_header.dart`]
- `SettingsPage` porte deja depuis `5.3` une section pilote et un affichage de version honnete. Si `6.1` a besoin d'y faire apparaitre l'identite de l'instance, le bon travail est de prolonger cette source de verite, pas de la dupliquer ailleurs. [Source: `lib/presentation/pages/settings_page.dart`]
- `web/index.html` et `web/manifest.json` sont encore generiques et constituent probablement la dette la plus evidente si l'instance doit etre identifiable depuis le navigateur ou l'installation web. [Source: `web/index.html`; `web/manifest.json`]

### References

- Planning canonique:
  - `_bmad-output/planning-artifacts/epics.md`
  - `_bmad-output/planning-artifacts/prd.md`
  - `_bmad-output/planning-artifacts/architecture.md`
  - `_bmad-output/planning-artifacts/ux-guidance-minimale.md`
  - `_bmad-output/planning-artifacts/implementation-readiness-report-2026-04-12.md`
- Contexte implementation:
  - `_bmad-output/implementation-artifacts/5-1-rendre-lacces-au-produit-credible-pour-un-premier-utilisateur-externe.md`
  - `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`
  - `_bmad-output/implementation-artifacts/epic-5-retro-2026-04-12.md`
  - `_bmad-output/project-context.md`
  - `docs/LOCAL_RUNTIME.md`
- Code et tests:
  - `lib/presentation/app/prioris_app.dart`
  - `lib/presentation/pages/auth/auth_wrapper.dart`
  - `lib/presentation/pages/auth/login_page.dart`
  - `lib/presentation/pages/auth/components/login_header.dart`
  - `lib/presentation/pages/home_page.dart`
  - `lib/presentation/pages/settings_page.dart`
  - `lib/core/config/app_config.dart`
  - `lib/core/bootstrap/app_initializer.dart`
  - `web/index.html`
  - `web/manifest.json`
  - `test/presentation/pages/home_page_test.dart`
  - `test/presentation/pages/settings_page_test.dart`
  - `test/integration/auth_flow_integration_test.dart`
  - `test/integration/signed_in_smoke_integration_test.dart`
- Documentation officielle:
  - `https://docs.flutter.dev/platform-integration/web/faq`
  - `https://docs.flutter.dev/platform-integration/web/initialization`
  - `https://docs.flutter.dev/platform-integration/web/wasm`

## Change Log

- 2026-04-12: story creee via workflow `create-story` pour ouvrir `Epic 6` sur le plus petit slice observable du lane `pilote externe reel`: rendre une vraie instance pilote identifiable et atteignable, sans confondre runtime local, preuve repo-owned et cible pilote hebergee.
- 2026-04-13: implementation `dev-story` sur le chemin runtime normal avec source unique d'identite pilote dans `AppConfig`, preuves desktop/telephone repo-owned et closeout maintenu `in-progress` faute de cible pilote publique canonique documentee dans le depot.

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Implementation Plan

- Ecrire d'abord les tests rouges qui prouvent l'identite pilote sur le chemin runtime normal desktop + telephone, et qui echouent encore si l'application reste generique ou ambigue sur la nature du pilote.
- Introduire ensuite une source unique de metadata d'instance pilote, puis la brancher sur le plus petit ensemble de surfaces necessaires (entry/auth, shell, metadata web) sans rouvrir `6.2`.
- Fermer enfin la matrice de preuve avec `analyze`, tests cibles, build web si pertinent, et une note de closeout qui nomme explicitement la cible hebergee reelle.

### Debug Log References

- Workflow `create-story` + analyse exhaustive de:
  - `_bmad-output/planning-artifacts/epics.md`
  - `_bmad-output/planning-artifacts/prd.md`
  - `_bmad-output/planning-artifacts/architecture.md`
  - `_bmad-output/planning-artifacts/ux-guidance-minimale.md`
  - `_bmad-output/project-context.md`
  - `_bmad-output/implementation-artifacts/5-1-rendre-lacces-au-produit-credible-pour-un-premier-utilisateur-externe.md`
  - `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`
  - `docs/LOCAL_RUNTIME.md`
  - documentation officielle Flutter web (`faq`, `initialization`, `wasm`)
- Implementation `dev-story`:
  - lecture ciblee de `lib/core/config/app_config.dart`, `lib/presentation/app/prioris_app.dart`, `lib/presentation/pages/auth/components/login_header.dart`, `lib/presentation/pages/home_page.dart`, `lib/presentation/pages/settings_page.dart`, `web/index.html`, `web/manifest.json`
  - verification repository/deploiement via `.env`, `docs/LOCAL_RUNTIME.md`, `git remote -v`, `.github/workflows/ci.yml` et recherche d'URLs publiques
  - audit GitHub du repository public `N3z3d/PriorisProject` pour confirmer l'absence de branche Pages existante et la faisabilite d'une cible GitHub Pages dediee
  - commandes executees:
    - `flutter gen-l10n`
    - `flutter --version`
    - `dart format lib/core/config/app_config.dart lib/presentation/app/prioris_app.dart lib/presentation/pages/auth/components/login_header.dart lib/presentation/pages/home_page.dart lib/presentation/pages/settings_page.dart lib/presentation/widgets/pilot/pilot_instance_notice.dart test/core/config/app_config_test.dart test/presentation/pages/home_page_test.dart test/presentation/pages/settings_page_test.dart test/integration/auth_flow_integration_test.dart`
    - `flutter analyze --no-pub lib/presentation/app/prioris_app.dart lib/presentation/pages/auth/auth_wrapper.dart lib/presentation/pages/auth/login_page.dart lib/presentation/pages/auth/components/login_header.dart lib/presentation/pages/home_page.dart lib/presentation/pages/settings_page.dart lib/core/config/app_config.dart lib/core/bootstrap/app_initializer.dart test/presentation/pages/home_page_test.dart test/presentation/pages/settings_page_test.dart test/integration/auth_flow_integration_test.dart test/integration/signed_in_smoke_integration_test.dart`
    - `flutter analyze --no-pub lib/presentation/pages/settings_page.dart test/presentation/pages/settings_page_test.dart`
    - `flutter test test/core/config/app_config_test.dart test/presentation/pages/home_page_test.dart test/presentation/pages/settings_page_test.dart test/integration/auth_flow_integration_test.dart`
    - `flutter test test/presentation/pages/settings_page_test.dart`
    - `flutter build web`
    - `flutter build web --release --base-href=/PriorisProject/ --dart-define=PRIORIS_APP_VERSION=pilot-local`

### Completion Notes List

- `AppConfig` centralise maintenant l'identite pilote via `PRIORIS_INSTANCE_NAME`, `PRIORIS_INSTANCE_ENTRY_URL`, `pilotInstanceName`, `pilotInstanceEntryUrl`, `hasExplicitPilotInstance` et `applicationTitle`.
- Le chemin runtime normal est reutilise sans route parallele: `PriorisApp -> AuthWrapper -> LoginPage/HomePage`. L'identite pilote visible passe par `LoginHeader`, `HomePage`, `SettingsPage` et le nouveau widget partage `PilotInstanceNotice`.
- La copy pilote reste localisee via `AppLocalizations`; un badge explicite `pilotIdentityBadge` a ete ajoute en FR/EN/ES/DE puis regenere.
- Les preuves repo-owned desktop + telephone sont fermees par les tests `app_config`, `home_page`, `settings_page` et `auth_flow_integration`; `flutter build web` reste vert.
- Le chemin de deploiement externe minimal est maintenant prepare:
  - nouvelle workflow GitHub Pages manuelle `deploy-pilot-pages.yml`
  - generation d'un `.env` de build dans GitHub Actions
  - build Pages validee localement avec `--base-href=/PriorisProject/`
  - documentation d'activation dans `docs/PILOT_PAGES_DEPLOYMENT.md`
- Choix de securite explicite pour cette cible web: `SUPABASE_URL` et la cle publique client `anon` sont traitees comme des variables GitHub de build, pas comme des secrets forts, parce qu'elles seront exposees dans le bundle web. `service_role` et tout secret backend restent interdits.
- Le depot ne fournit toujours pas de cible pilote publique canonique: `.env` garde un redirect local (`http://localhost:3000/auth/callback`), `docs/LOCAL_RUNTIME.md` ne documente que des URLs locales/LAN, et aucun artefact de deploiement public n'a ete trouve. La story reste donc `in-progress` et ne doit pas etre cloturee comme preuve suffisante d'un pilote externe reel.
- La limite restante est reduite mais non fermee: il faut encore un premier run GitHub Pages reussi, une URL publique finale verifiee et une preuve desktop + telephone sur cette URL avant de pouvoir passer la story en `review`.

### File List

- `lib/core/config/app_config.dart`
- `lib/presentation/app/prioris_app.dart`
- `lib/presentation/pages/auth/components/login_header.dart`
- `lib/presentation/pages/home_page.dart`
- `lib/presentation/pages/settings_page.dart`
- `lib/presentation/widgets/pilot/pilot_instance_notice.dart`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_de.arb`
- `lib/l10n/app_localizations.dart`
- `lib/l10n/app_localizations_fr.dart`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_es.dart`
- `lib/l10n/app_localizations_de.dart`
- `test/core/config/app_config_test.dart`
- `test/presentation/pages/home_page_test.dart`
- `test/presentation/pages/settings_page_test.dart`
- `test/integration/auth_flow_integration_test.dart`
- `.github/workflows/deploy-pilot-pages.yml`
- `docs/PILOT_PAGES_DEPLOYMENT.md`
- `_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `tasks/todo.md`
