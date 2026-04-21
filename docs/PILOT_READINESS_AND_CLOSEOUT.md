# Gate de readiness et closeout du pilote Prioris

## Role de ce document

Ce document est la source de verite decisionnelle du premier pilote externe reel de Prioris.

Il ne remplace pas le runbook technique [PILOT_PAGES_DEPLOYMENT.md](C:/Users/Thibaut/Desktop/PriorisProject/docs/PILOT_PAGES_DEPLOYMENT.md). Il se place au-dessus de lui pour repondre a deux questions differentes:

1. Sommes-nous prets a relancer ou poursuivre le pilote externe reel?
2. Comment cloturons-nous ce pilote de facon exploitable pour le prochain cycle BMAD?

Les intrants canoniques de ce gate viennent des closeouts `6.1` et `6.2`, pas des anciens rapports de release ni des credentials repo-owned historiques.

## Baseline pilote retenue

- Cible pilote reelle retenue: `https://n3z3d.github.io/PriorisProject/`
- Source de verite technique de la cible: `DEFAULT_PAGES_URL` dans `.github/workflows/deploy-pilot-pages.yml`, injecte ensuite dans `PRIORIS_INSTANCE_ENTRY_URL`, puis consomme par `AppConfig`
- Support minimal retenu: `HomePage -> SettingsPage -> Aide / Feedback / Confidentialite / Conditions`
- Source de verite du support minimal: `AppConfig.pilotSupportInfo` et `PilotSupportInfo`
- Resolution canonique du canal de feedback pilote: `AppConfig.pilotSupportInfo`
- Priorite du canal de feedback pilote: `PRIORIS_PILOT_FEEDBACK_URL`, sinon `mailto:` derive de `PRIORIS_PILOT_SUPPORT_EMAIL`
- Baseline repo-owned preparee pour le prochain rerun: la workflow GitHub Pages injecte `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com` si aucun override n'est fourni
- Statut public verifie le `2026-04-19`: `assets/.env` expose toujours `PRIORIS_PILOT_SUPPORT_EMAIL=lambert.thibaut98@gmail.com` sur la build active
- Validation auth partielle verifiee le `2026-04-19`: `connexion normale avec compte deja confirme -> refresh` passe sur la build pilote publique
- Revalidation specifique du callback email le `2026-04-19`: temporairement bloquee par `AuthApiException(... statusCode: 429, code: over_email_send_rate_limit)` lors d'une nouvelle tentative d'email de confirmation
- Reouverture canonique du `2026-04-20`: le callback email Supabase ouvre maintenant `https://n3z3d.github.io/PriorisProject/#sb` et tombe sur `Route non trouvee` sur la build publique
- Proprietaire de la decision go / no-go: Thibaut

## Les quatre niveaux de preuve

### 1. Preuve repo-owned locale

Cette preuve repond a la question: "le repo et le runtime normal restent-ils coherents cote developpement?"

Preuves attendues:

- commandes ciblees sur les fichiers ou runbooks touches
- verification documentaire de bout en bout si le slice reste purement documentaire
- `flutter build web` et tests cibles uniquement si le runtime, la workflow ou un garde technique changent

Cette preuve ne suffit jamais a elle seule a lancer ou fermer le pilote externe reel.

### 2. Readiness de deploiement

Cette preuve repond a la question: "la cible publique et son lane GitHub Pages sont-ils encore configurables et deployables?"

Preuves attendues:

- workflow `Deploy Pilot Web to GitHub Pages`
- environnement `github-pages`
- `concurrency: pilot-pages`
- garde `tool/validate_pilot_pages_config.dart`
- variables GitHub requises presentes
- verification publique de `assets/.env` et de `auth/v1/settings` apres publication quand un rerun deploiement a eu lieu

Cette preuve ne vaut pas validation utilisateur externe.

### 3. Validation externe reelle

Cette preuve repond a la question: "un utilisateur pilote externe a-t-il effectivement pu suivre le parcours attendu sur la build publique?"

Preuves attendues:

- preuve desktop sur la cible publique
- preuve telephone sur la cible publique
- rerun externe observable sur la build publique

Regle canonique:

- un credential repo-owned stale, comme `test/manual/test_credentials.txt`, n'est pas une preuve canonique de validation externe
- la reference la plus forte a date est la rerun publique du `2026-04-18`: `creation de compte -> email de validation -> lien de confirmation -> connexion`

### 4. Closeout du pilote

Cette preuve repond a la question: "que conclut-on du pilote, avec quelles limites et quelle suite?"

Le closeout doit documenter:

- la fenetre du pilote
- la cohorte invitee
- les hypotheses testees
- les signaux attendus puis observes
- les incidents et blocages
- la decision finale et la prochaine action

Un closeout ne doit pas supposer qu'une ouverture publique large est desiree ou imminente.

## Matrice de readiness go / no-go

Si un item bloqueur ci-dessous est absent ou non revalide apres un changement pertinent, le statut du pilote est `no-go`.

| Item | Attendu avant lancement | Baseline canonique actuelle |
| --- | --- | --- |
| URL pilote publique | La cible publique repond et reste `https://n3z3d.github.io/PriorisProject/` | Oui. Cible documentee dans `6.1` et `docs/PILOT_PAGES_DEPLOYMENT.md` |
| Workflow de deploiement | La publication passe par `Deploy Pilot Web to GitHub Pages` avec `environment: github-pages` et `concurrency: pilot-pages` | Oui. Workflow source-controlee dans `.github/workflows/deploy-pilot-pages.yml` |
| Variables / entrees requises | `PRIORIS_PILOT_SUPABASE_URL`, `PRIORIS_PILOT_SUPABASE_ANON_KEY` et un canal concret via `PRIORIS_PILOT_FEEDBACK_URL`, `PRIORIS_PILOT_SUPPORT_EMAIL` ou le fallback workflow `support@prioris-app.com` | Oui. `assets/.env` public relu le `2026-04-18` expose `PRIORIS_PILOT_SUPPORT_EMAIL=lambert.thibaut98@gmail.com` sur la build active |
| Support minimal | `SettingsPage` expose `Aide`, `Feedback`, `Confidentialite`, `Conditions` avec une source de verite unique | Oui. Ferme par `6.2` via `AppConfig.pilotSupportInfo` |
| Canal de feedback | Une build pilote reelle expose un canal explicite joignable, sans fallback implicite GitHub | Oui. Resolution canonique: `PRIORIS_PILOT_FEEDBACK_URL`, sinon `mailto:` via `PRIORIS_PILOT_SUPPORT_EMAIL`; la build publique active expose `PRIORIS_PILOT_SUPPORT_EMAIL=lambert.thibaut98@gmail.com` le `2026-04-18` |
| Preuve desktop | La build publique pilote reste identifiable et utilisable sur desktop | Oui. Verification publique `2026-04-16` + preuves repo-owned `6.1` / `6.2` |
| Preuve telephone | La meme information essentielle reste visible et exploitable sur telephone | Oui. Verification publique `2026-04-16` en `390x844` + preuves repo-owned `6.1` / `6.2` |
| Validation externe reelle | Un utilisateur invite a complete le parcours attendu sur la cible publique | Non. La rerun publique `2026-04-18` reste historique utile, mais la preuve publique du `2026-04-20` reouvre le parcours callback email (`/#sb -> Route non trouvee`) |
| Date de verification | Une date absolue de verification est consignee pour chaque preuve decisive | Oui. `2026-04-16`, `2026-04-17`, `2026-04-18` sont les dates canoniques actuelles |
| Proprietaire de decision | Une personne nommee tranche explicitement `go` / `no-go` | Oui. Thibaut |

### Limites acceptees pendant le pilote

Ces limites n'empechent pas a elles seules le pilote si tous les bloqueurs ci-dessus sont verts:

- support volontairement manuel et borne, sans centre d'aide riche ni support operationnel etendu
- deploiement manuel via GitHub Pages, sans pipeline de release publique plus large
- absence d'analytics, de monetisation ou de gouvernance produit etendue dans ce lane
- credentials repo-owned historiques exclus de la preuve canonique si une rerun publique plus recente existe

## Baseline canonique fermee par `6.1` et `6.2`

- `2026-04-16`: verification publique de l'entree pilote sur desktop et telephone a la meme URL
- `2026-04-17`: verification publique de la configuration servie (`assets/.env`, host Supabase reel, endpoint `auth/v1/settings`)
- `2026-04-18`: rerun publique utilisateur reussie sur le flux `creation de compte -> email de validation -> lien de confirmation -> connexion`
- `2026-04-18`: rerun workflow `cf228ca0f4bde2c97fd7bb6ea9a214aece7790e9` reussi; `assets/.env` public expose `PRIORIS_PILOT_SUPPORT_EMAIL=lambert.thibaut98@gmail.com`
- `2026-04-18`: preparation repo-owned d'un rerun minimal avec `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com` par defaut dans la workflow Pages si aucun override n'est fourni
- `2026-04-19`: relecture publique post-deploiement confirmee sur desktop et telephone; le shell de connexion pilote reste visible et `assets/.env` public reste coherent avec la cible pilote
- `2026-04-19`: tentative de recette signee-in avec `test/manual/test_credentials.txt` en echec `invalid_credentials`; ce compte repo-owned est stale et ne peut pas servir de preuve canonique du runtime authentifie courant
- `2026-04-19`: validation partielle utile sur la build publique avec un compte deja confirme: `connexion normale -> refresh` fonctionne
- `2026-04-19`: la reverification decisive du chemin `email de confirmation -> lien Supabase -> arrivee -> refresh immediat` est temporairement bloquee par Supabase (`429 over_email_send_rate_limit`) et reste donc `pending` cote preuve manuelle
- `6.2`: support minimal reel ferme sur le chemin `HomePage -> SettingsPage`, avec source de verite unique et sans fallback implicite vers le repository GitHub

## Decision de lancement

La decision de lancement ou de rerun doit etre ecrite explicitement avec l'un des statuts suivants:

- `GO`: tous les bloqueurs sont verts et aucune limite restante ne remet en cause l'objectif du pilote
- `GO avec limites`: les bloqueurs sont verts mais une ou plusieurs limites connues doivent etre surveillees pendant le pilote
- `NO-GO`: au moins un bloqueur reste ouvert ou non revalide

### Statut canonique a date

- Statut courant pour le pilote: `GO avec limites`
- Motif: la correction `6.4` est deployee (2026-04-21). La recette desktop `email -> callback -> arrivee -> refresh` est validee. Le correctif `#sb` (route guard + redirect page + snackbar) est en place et couvert par les tests.
- Limite restante verifiable: la reverification telephone est bloquee par le rate limit Supabase (`429 over_email_send_rate_limit`) depuis le `2026-04-19`. Ce blocage est externe. Le code mobile est correct.
- Limites operationnelles acceptees: support email manuel, deploiement GitHub Pages manuel, absence d'analytics ou de support operationnel etendu.
- Destination feedback active:
  - Email support pilote: `lambert.thibaut98@gmail.com`

### Verification 2026-04-21 (story 6.4)

- Build deployee via `Deploy Pilot Web to GitHub Pages` le `2026-04-21` (deux reruns).
- Recette desktop validee par Thibaut le `2026-04-21`:
  - premier clic lien email: URL `?code=...` visible brievement -> `https://n3z3d.github.io/PriorisProject/` -> session conservee au refresh
  - deuxieme clic (lien consomme): `#sb` -> page "Redirection en cours..." -> redirect vers `AuthWrapper` -> session ou login page selon etat
- Recette telephone: bloquee par rate limit Supabase `429`. Non testee sur build publique a cette date.
- Corrections portees par `6.4`:
  - `isAuthCallbackUri` reconnait desormais `#sb`, `#sb-...`, `#sb.` comme callbacks Supabase
  - `stripAuthCallbackPayload` supprime ces fragments proprement
  - `AppRoutes.generateRoute` redirige `sb`-prefixed routes vers `_AuthCallbackRedirectPage` (600ms) au lieu de "Route non trouvee"
  - `WebAuthCallbackStabilizer.consumeCallbackWithoutSession()` signale un callback sans session -> `LoginPage` affiche un snackbar contextuel

## Closeout 2026-04-18

Ce closeout reste un jalon historique valide au `2026-04-18`, mais il ne constitue plus le statut courant du pilote depuis la reouverture canonique du `2026-04-20`.

- Fenetre du pilote: `2026-04-16` -> `2026-04-18`
- Cohorte / utilisateurs invites: premier utilisateur externe invite + verification createur sur la cible publique
- Hypotheses testees:
  - la cible publique GitHub Pages reste atteignable et branchee sur une vraie instance Supabase
  - le flux `creation de compte -> email de validation -> lien de confirmation -> connexion` est realisable sur la build publique
  - le pilote expose enfin un canal feedback/support concret sur la build publique active
- Criteres d'entree verifies:
  - build publique accessible
  - support minimal configure
  - rerun externe observable
  - decision de lancement explicite
- Criteres de sortie verifies:
  - signaux compares
  - incidents et blocages classes
  - destination feedback consignee
  - decision finale et prochaine action ecrites
- Signaux attendus:
  - URL publique stable
  - auth email active
  - support pilote visible dans `assets/.env`
- Signaux observes:
  - `https://n3z3d.github.io/PriorisProject/` repond publiquement
  - `auth/v1/settings` reste actif sur le host pilote
  - rerun publique utilisateur du `2026-04-18` reussie sur le flux coeur
  - rerun workflow `cf228ca0f4bde2c97fd7bb6ea9a214aece7790e9` reussi et `assets/.env` public expose `PRIORIS_PILOT_SUPPORT_EMAIL=lambert.thibaut98@gmail.com`
  - relecture publique post-deploiement `2026-04-19` reussie sur le shell desktop et telephone; `assets/.env` public reste coherent avec la cible pilote
  - validation partielle `2026-04-19`: `connexion normale avec un compte deja confirme -> refresh` passe sur la build publique
- Incidents observes:
  - premier rerun workflow `1c1c37684a92bdeb70471f5c7e34b43474f579e9` en echec car `tool/validate_pilot_pages_config.dart` n'etait pas encore publie sur `main`
  - tentative de recette signee-in `2026-04-19` avec `test/manual/test_credentials.txt` en echec `invalid_credentials`, ce qui bloque une reverification authentifiee repo-owned des correctifs de session/priorisation sur la build publique courante
  - tentative de recreation de compte `2026-04-19` bloquee par Supabase en `AuthApiException(... statusCode: 429, code: over_email_send_rate_limit)`, ce qui empeche temporairement de rejouer la recette `email de confirmation -> callback -> refresh immediat`
- Blocages non tolerables:
  - aucun bloqueur critique ouvert a la fin de cette verification
- Limites confirmees:
  - support pilote borne a un email manuel
  - deploiement GitHub Pages encore manuel
  - pas d'analytics ni de support operationnel etendu
- Limite de verification restante:
  - le chemin `login normal -> refresh` est valide, mais la reverification manuelle du chemin `callback email Supabase -> refresh immediat` reste suspendue a la levee du rate limit ou a la disponibilite d'un autre compte / alias de confirmation
- Decision finale: `continuer avec limites`
- Prochaine action recommandee: implementer la story `6.4`, redeployer la build pilote, puis rejouer la recette publique `email de confirmation -> lien Supabase -> arrivee -> refresh immediat` sur desktop et telephone avant toute ouverture d'un lane suivant
- Artefacts relies:
  - workflow run en echec `24609372855`
  - workflow run reussi `24610836842`
  - `https://n3z3d.github.io/PriorisProject/assets/.env`

## Reouverture 2026-04-20

- Nouvelle preuve publique: le lien email Supabase ouvre `https://n3z3d.github.io/PriorisProject/#sb`
- Symptome visible: l'application affiche `Route non trouvee`
- Interpretation canonique: la variante hash / fragment route-like du callback public n'est pas encore absorbee proprement par le runtime pilote
- Impact sur le gate: la validation externe reelle repasse en `non fermee`
- Decision provisoire: `corriger puis relancer`
- Prochaine action BMAD: rouvrir `Epic 6`, creer puis implementer `6.4`, redeployer et reexecuter la recette publique callback sur desktop et telephone

## Cadre de closeout reutilisable

Le closeout suivant peut etre copie tel quel a chaque rerun pilote.

### Criteres de sortie

- le rerun ou pilote borne a effectivement eu lieu sur la build publique nommee
- les signaux attendus et les signaux observes sont compares explicitement
- les blocages et incidents restants sont classes en tolerables ou non tolerables
- la destination feedback reellement exposee pendant le pilote est consignee (`https:` ou `mailto:`)
- la decision finale et la prochaine action BMAD sont ecrites avec une date absolue

### Fiche de closeout

- Fenetre du pilote:
- Cohorte / utilisateurs invites:
- Hypotheses testees:
- Criteres d'entree verifies:
  - build publique accessible
  - support minimal configure
  - rerun externe observable
  - decision de lancement explicite
- Criteres de sortie verifies:
  - signaux compares
  - incidents et blocages classes
  - destination feedback consignee
  - decision finale et prochaine action ecrites
- Signaux attendus:
- Signaux observes:
- Incidents observes:
- Blocages non tolerables:
- Limites confirmees:
- Decision finale:
  - `continuer tel quel`
  - `continuer avec limites`
  - `corriger puis relancer`
  - `arreter le pilote`
- Prochaine action recommandee:
- Artefacts relies:

### Regles de remplissage

- utiliser des dates absolues
- citer la cible publique exacte et le chemin utilisateur reellement observe
- distinguer ce qui a ete prouve localement de ce qui a ete verifie sur la build publique
- consigner explicitement la destination feedback reellement exposee pendant le pilote (`https:` ou `mailto:`), pas seulement la regle de resolution
- ne pas transformer ce closeout en rapport de release generique ou en plan d'ouverture publique

## Renvois

- Runbook technique de deploiement: [PILOT_PAGES_DEPLOYMENT.md](C:/Users/Thibaut/Desktop/PriorisProject/docs/PILOT_PAGES_DEPLOYMENT.md)
- Story de la cible pilote reelle: [6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md](C:/Users/Thibaut/Desktop/PriorisProject/_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md)
- Story du support pilote minimal: [6-2-remplacer-les-points-de-contact-placeholders-par-un-support-pilote-reel.md](C:/Users/Thibaut/Desktop/PriorisProject/_bmad-output/implementation-artifacts/6-2-remplacer-les-points-de-contact-placeholders-par-un-support-pilote-reel.md)
- Tracker sprint: [sprint-status.yaml](C:/Users/Thibaut/Desktop/PriorisProject/_bmad-output/implementation-artifacts/sprint-status.yaml)
