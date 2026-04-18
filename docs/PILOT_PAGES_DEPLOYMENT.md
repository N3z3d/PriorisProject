# Cible pilote GitHub Pages

## Statut actuel

- URL publique active retenue pour le pilote: `https://n3z3d.github.io/PriorisProject/`
- Verification de configuration publique la plus recente: `2026-04-17`
- Verification externe publique la plus recente: `2026-04-18`
- Constat public actuel:
  - le HTML GitHub Pages repond bien avec `base href="/PriorisProject/"`, `title=Prioris Pilot` et un `manifest.json` pilote
  - `assets/.env` sert maintenant `SUPABASE_URL=https://vgowxrktjzgwrfivtvse.supabase.co`
  - `assets/.env` public relu le `2026-04-18` n'expose ni `PRIORIS_PILOT_FEEDBACK_URL` ni `PRIORIS_PILOT_SUPPORT_EMAIL`
  - `auth/v1/settings` repond sur ce host et confirme que l'auth email est active
  - la rerun publique utilisateur du `2026-04-18` a ferme le flux `creation de compte -> email de validation -> lien de confirmation -> connexion` sur la cible publique
- Consequence story `6.1`:
  - l'entree publique est bien branchee sur une vraie instance Supabase
  - la story `6.1` est fermee en `done`; la cible publique est maintenant la reference canonique du premier pilote externe reel
- Source de verite unique de la cible pilote:
  - artefact de deploiement: `DEFAULT_PAGES_URL` dans `.github/workflows/deploy-pilot-pages.yml`
  - injection runtime: generation du `.env` de build avec `PRIORIS_INSTANCE_ENTRY_URL=${DEFAULT_PAGES_URL}`
  - consommation applicative: `AppConfig.pilotInstanceEntryUrl` et `AppConfig.pilotInstanceName`, reutilises par le runtime normal
  - baseline repo-owned pour le prochain rerun: publication par defaut de `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com` si aucun override n'est fourni

## Gate documentaire associe

- Le gate decisionnel et le cadre de closeout du pilote vivent dans [PILOT_READINESS_AND_CLOSEOUT.md](C:/Users/Thibaut/Desktop/PriorisProject/docs/PILOT_READINESS_AND_CLOSEOUT.md).
- A date, ce gate traite tout nouveau rerun pilote comme `NO-GO` tant qu'une destination feedback concrete n'a pas ete republiee puis re-verifiee sur la build publique.
- Ce document reste le runbook technique de la cible Pages: URL canonique, workflow, variables, build et limites de deploiement.

## Objectif

Cette documentation fixe la cible pilote externe minimale de la story `6.1` via GitHub Pages:

- URL cible retenue: `https://n3z3d.github.io/PriorisProject/`
- workflow dedie: `.github/workflows/deploy-pilot-pages.yml`
- deploiement manuel, separe du CI principal

Cette cible est maintenant exposee publiquement avec un host Supabase reel et une rerun publique utilisateur fermee le `2026-04-18`. Les preuves repo-owned locales restent secondaires et ne remplacent pas le gate documentaire du pilote.

## Pourquoi GitHub Pages

- Le repository `N3z3d/PriorisProject` est public.
- Aucune branche `gh-pages` ni cible publique existante n'etait presente dans le depot.
- `web/index.html` supporte deja un `base href` injecte a la build Flutter.
- Le lot reste borne au web pilote et n'ouvre ni nouvelle route produit ni nouvelle persistance.

## Variables GitHub requises

Variables de repository obligatoires:

- `PRIORIS_PILOT_SUPABASE_URL`
- `PRIORIS_PILOT_SUPABASE_ANON_KEY`

Variables de repository optionnelles:

- `PRIORIS_PILOT_INSTANCE_NAME`
  - fallback workflow: `Prioris Pilot`
- `PRIORIS_PILOT_SUPABASE_AUTH_REDIRECT_URL`
  - fallback workflow: `https://n3z3d.github.io/PriorisProject/`
- `PRIORIS_PILOT_FEEDBACK_URL`
  - si renseignee, alimente directement le canal support/feedback reel affiche dans `SettingsPage`
- `PRIORIS_PILOT_SUPPORT_EMAIL`
  - override workflow du support email pilote; si `PRIORIS_PILOT_FEEDBACK_URL` est absente, l'application ouvre `mailto:<email>` depuis `SettingsPage`
  - fallback workflow source-controle: `support@prioris-app.com`

Regle lane `6.2`:

- pour toute build pilote externe reelle, exposer au moins un canal concret: `PRIORIS_PILOT_FEEDBACK_URL`, `PRIORIS_PILOT_SUPPORT_EMAIL`, ou le fallback workflow source-controle `support@prioris-app.com`
- ne plus compter sur un fallback implicite vers le repository GitHub pour le support pilote
- la source de verite runtime du canal reste `AppConfig.pilotSupportInfo`: `PRIORIS_PILOT_FEEDBACK_URL` prioritaire, sinon `mailto:` via `PRIORIS_PILOT_SUPPORT_EMAIL`
- la build publique active relue le `2026-04-18` ne montre encore aucun de ces canaux dans `assets/.env`; avant tout nouveau rerun pilote, republier puis re-verifier une destination concrete
- le plus petit rerun propre prepare par ce depot publiera au minimum `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com` tant qu'aucun override GitHub n'est fourni

## Pourquoi ce ne sont pas des secrets forts

Pour une application web Flutter, `SUPABASE_URL` et la cle publique client `anon` sont embarquees dans le bundle JavaScript servi au navigateur. Elles ne restent donc pas secrete une fois le site deploie.

Consequence pratique:

- les stocker comme variables GitHub est acceptable
- les stocker comme secrets GitHub n'apporte pas une vraie confidentialite supplementaire cote navigateur
- la vraie protection doit venir des policies Supabase et de la configuration serveur

Ne jamais mettre dans GitHub Actions pour cette cible web:

- `service_role`
- base de donnees password
- JWT secret
- toute cle serveur reservee au backend

## Build generee

La workflow genere un `.env` de build avant `flutter build web` avec:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_AUTH_REDIRECT_URL`
- `ENVIRONMENT=production`
- `DEBUG_MODE=false`
- `PRIORIS_INSTANCE_NAME`
- `PRIORIS_INSTANCE_ENTRY_URL=https://n3z3d.github.io/PriorisProject/`
- `PRIORIS_PILOT_FEEDBACK_URL` si la variable GitHub correspondante est definie
- `PRIORIS_PILOT_SUPPORT_EMAIL` si la variable GitHub correspondante est definie, sinon `support@prioris-app.com`

La build web utilise:

- `--base-href /PriorisProject/`
- `--dart-define=PRIORIS_APP_VERSION=pilot-pages-<run_number>`

Depuis le correctif signup `2026-04-17`, le runtime transmet aussi explicitement `SUPABASE_AUTH_REDIRECT_URL` a Supabase via `emailRedirectTo` pendant l'inscription et la reinitialisation de mot de passe. La cible GitHub Pages retenue reste donc la meme source de verite pour les retours email.

Avant la build web, la workflow execute aussi `dart run tool/validate_pilot_pages_config.dart` pour refuser explicitement un `PILOT_SUPABASE_URL` vide, non-HTTPS, non-Supabase ou connu comme placeholder / host mort.

## Activation / rerun

1. Ouvrir GitHub repository settings.
2. Verifier que GitHub Pages est autorise pour le repository.
3. Si GitHub le demande, regler la source Pages sur `GitHub Actions`.
4. Ajouter les variables obligatoires et, si utile, les variables optionnelles.
5. Si un canal de feedback plus riche est souhaite, renseigner `PRIORIS_PILOT_FEEDBACK_URL`; sinon la workflow publiera par defaut `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com`.
6. Verifier que `PRIORIS_PILOT_SUPABASE_URL` cible un host Supabase reel et non un host placeholder connu du repo.
7. Lancer manuellement la workflow `Deploy Pilot Web to GitHub Pages`.
8. Verifier l'URL retournee par `actions/deploy-pages` et confirmer qu'elle reste `https://n3z3d.github.io/PriorisProject/`.
9. Re-verifier `assets/.env` public pour confirmer que `SUPABASE_URL` reste `https://vgowxrktjzgwrfivtvse.supabase.co` ou un autre host reel attendu.
10. Re-verifier que `assets/.env` public expose maintenant soit `PRIORIS_PILOT_FEEDBACK_URL`, soit `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com`, soit un support email override.

Pour le lane `6.2`, la source de verite support pilote reste:

- `AppLocalizations` pour les labels, limites et contenus editoriaux in-app
- `AppConfig.pilotSupportInfo` pour les destinations reelles variables par environnement
- la workflow GitHub Pages uniquement pour injecter `PRIORIS_PILOT_FEEDBACK_URL` / `PRIORIS_PILOT_SUPPORT_EMAIL` dans la build pilote web, avec `support@prioris-app.com` comme email minimal par defaut si aucun override n'est fourni

## Verification retenue pour 6.1

Verification actuellement retenue:

1. `https://n3z3d.github.io/PriorisProject/` repond bien publiquement avec le bootstrap Flutter attendu et des metadata pilote (`title`, `manifest`, `base href`).
2. `assets/.env` public confirme `SUPABASE_URL=https://vgowxrktjzgwrfivtvse.supabase.co`, `PRIORIS_INSTANCE_NAME=Prioris Pilot Invite` et `SUPABASE_AUTH_REDIRECT_URL=https://n3z3d.github.io/PriorisProject/`.
3. `auth/v1/settings` repond sur cette cible et confirme que l'auth email reste active.
4. La rerun publique utilisateur du `2026-04-18` ferme le flux `creation de compte -> email de validation -> lien de confirmation -> connexion` sur la cible publique.
5. Les preuves repo-owned existantes (`tests integration/presentation` + `flutter build web`) restent la preuve secondaire du chemin auth/shell normal, distincte de la verification publique.

## Limites connues

- La verification live `2026-04-16` couvre explicitement l'entree publique et l'identification pilote, pas une session authentifiee hebergee avec des credentials d'invitation reels conserves dans le repo.
- La verification de configuration publique `2026-04-17` et la rerun publique `2026-04-18` sont les preuves canoniques actuelles; `test/manual/test_credentials.txt` doit etre traite comme un artefact stale non canonique pour ce lane.
- Le deploiement reste manuel pour eviter d'exposer chaque push comme une release pilote publique.
- Le fallback `SUPABASE_AUTH_REDIRECT_URL` pointe vers la racine GitHub Pages, pas vers `/auth/callback`, car l'application ne documente pas encore de route web dediee de callback dans `AppRoutes`.
- Si un email de validation redirige encore vers un `404` GitHub Pages apres redeploiement, verifier aussi cote Supabase:
  - `Site URL`
  - la allow-list des redirect URLs
  - que le template email utilise bien la variable de confirmation d'URL prevue par Supabase, ou une personnalisation compatible avec la cible GitHub Pages retenue
- `PRIORIS_PILOT_SUPABASE_URL` et `PRIORIS_PILOT_SUPABASE_ANON_KEY` sont des valeurs clientes publiques dans une app web; elles ne remplacent pas une vraie hygiene de securite Supabase.
- Si `PRIORIS_PILOT_FEEDBACK_URL` n'est pas configuree mais que `PRIORIS_PILOT_SUPPORT_EMAIL` l'est, le support `6.2` ouvre un `mailto:` borne vers cette adresse.
- Si aucun override de canal n'est configure pour un nouveau rerun, la workflow publie maintenant `PRIORIS_PILOT_SUPPORT_EMAIL=support@prioris-app.com` par defaut.
- La build publique active relue le `2026-04-18` n'expose pourtant aucun de ces deux canaux dans `assets/.env`; traiter cet ecart comme un blocage documentaire `NO-GO` tant qu'une destination concrete n'a pas ete republiee puis reverifiee.
- Les preuves repo-owned locales restent secondaires meme apres activation: elles servent a confirmer le chemin auth/shell normal, pas a remplacer la verification publique de la cible pilote.
