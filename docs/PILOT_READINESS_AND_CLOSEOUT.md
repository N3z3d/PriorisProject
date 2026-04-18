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
- Statut public verifie le `2026-04-18`: aucun canal de feedback public concret n'est observable dans `assets/.env` sur la build active
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
| Variables / entrees requises | `PRIORIS_PILOT_SUPABASE_URL`, `PRIORIS_PILOT_SUPABASE_ANON_KEY` et un canal concret via `PRIORIS_PILOT_FEEDBACK_URL`, `PRIORIS_PILOT_SUPPORT_EMAIL` ou le fallback workflow `support@prioris-app.com` | Non sur la build active. Le depot prepare maintenant `support@prioris-app.com` comme email minimal par defaut, mais `assets/.env` public relu le `2026-04-18` n'expose encore aucun canal; une nouvelle publication concrete reste necessaire |
| Support minimal | `SettingsPage` expose `Aide`, `Feedback`, `Confidentialite`, `Conditions` avec une source de verite unique | Oui. Ferme par `6.2` via `AppConfig.pilotSupportInfo` |
| Canal de feedback | Une build pilote reelle expose un canal explicite joignable, sans fallback implicite GitHub | Non sur la build publique active. Resolution canonique: `PRIORIS_PILOT_FEEDBACK_URL`, sinon `mailto:` via `PRIORIS_PILOT_SUPPORT_EMAIL`; le depot prepare maintenant `support@prioris-app.com` comme baseline minimale, mais aucune destination publique concrete n'est encore observable le `2026-04-18` |
| Preuve desktop | La build publique pilote reste identifiable et utilisable sur desktop | Oui. Verification publique `2026-04-16` + preuves repo-owned `6.1` / `6.2` |
| Preuve telephone | La meme information essentielle reste visible et exploitable sur telephone | Oui. Verification publique `2026-04-16` en `390x844` + preuves repo-owned `6.1` / `6.2` |
| Validation externe reelle | Un utilisateur invite a complete le parcours attendu sur la cible publique | Oui. Rerun publique `2026-04-18` reussie |
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
- `2026-04-18`: relecture publique de `assets/.env`; aucun canal de feedback/support n'y est observable sur la build active
- `2026-04-18`: preparation repo-owned d'un rerun minimal avec `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com` par defaut dans la workflow Pages si aucun override n'est fourni
- `6.2`: support minimal reel ferme sur le chemin `HomePage -> SettingsPage`, avec source de verite unique et sans fallback implicite vers le repository GitHub

## Decision de lancement

La decision de lancement ou de rerun doit etre ecrite explicitement avec l'un des statuts suivants:

- `GO`: tous les bloqueurs sont verts et aucune limite restante ne remet en cause l'objectif du pilote
- `GO avec limites`: les bloqueurs sont verts mais une ou plusieurs limites connues doivent etre surveillees pendant le pilote
- `NO-GO`: au moins un bloqueur reste ouvert ou non revalide

### Statut canonique a date

- Statut courant pour tout nouveau rerun pilote: `NO-GO`
- Motif bloquant: la resolution du canal est definie cote code via `AppConfig.pilotSupportInfo`, et la repo-owned baseline de republication est maintenant `support@prioris-app.com` par defaut, mais la build publique active relue le `2026-04-18` n'expose encore ni `PRIORIS_PILOT_FEEDBACK_URL` ni `PRIORIS_PILOT_SUPPORT_EMAIL` dans `assets/.env`
- Condition minimale de retour a `GO` ou `GO avec limites`: republier puis re-verifier sur la build publique une destination de feedback concrete, au minimum `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com` ou un override explicite
- Destination feedback a consigner au moment du rerun:
  - URL feedback pilote:
  - Email support pilote: `support@prioris-app.com` par defaut workflow, sauf override explicite

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
