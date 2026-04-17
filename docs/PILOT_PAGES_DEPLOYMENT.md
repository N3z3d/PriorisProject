# Cible pilote GitHub Pages

## Statut actuel

- URL publique active retenue pour le pilote: `https://n3z3d.github.io/PriorisProject/`
- Verification de configuration publique la plus recente: `2026-04-17`
- Constat public actuel:
  - le HTML GitHub Pages repond bien avec `base href="/PriorisProject/"`, `title=Prioris Pilot` et un `manifest.json` pilote
  - `assets/.env` sert maintenant `SUPABASE_URL=https://vgowxrktjzgwrfivtvse.supabase.co`
  - `auth/v1/settings` repond sur ce host et confirme que l'auth email est active
  - la verification repo-owned d'un login invite reste toutefois ouverte: les credentials stockes dans `test/manual/test_credentials.txt` retournent encore `invalid_credentials`
- Consequence story `6.1`:
  - l'entree publique est bien branchee sur une vraie instance Supabase
  - l'AC1 n'est pas encore fermee faute de preuve repo-owned d'un acces invite reussi sur cette build publique
- Source de verite unique de la cible pilote:
  - artefact de deploiement: `DEFAULT_PAGES_URL` dans `.github/workflows/deploy-pilot-pages.yml`
  - injection runtime: generation du `.env` de build avec `PRIORIS_INSTANCE_ENTRY_URL=${DEFAULT_PAGES_URL}`
  - consommation applicative: `AppConfig.pilotInstanceEntryUrl` et `AppConfig.pilotInstanceName`, reutilises par le runtime normal

## Objectif

Cette documentation fixe la cible pilote externe minimale de la story `6.1` via GitHub Pages:

- URL cible retenue: `https://n3z3d.github.io/PriorisProject/`
- workflow dedie: `.github/workflows/deploy-pilot-pages.yml`
- deploiement manuel, separe du CI principal

Cette cible est maintenant exposee publiquement avec un host Supabase reel. Les preuves repo-owned locales restent secondaires; pour fermer `6.1`, il reste a produire une verification d'acces invite reussie sur cette build publique.

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
  - si `PRIORIS_PILOT_FEEDBACK_URL` est absente, l'application ouvre `mailto:<email>` depuis `SettingsPage`

Regle lane `6.2`:

- pour toute build pilote externe reelle, configurer au moins un des deux canaux suivants: `PRIORIS_PILOT_FEEDBACK_URL` ou `PRIORIS_PILOT_SUPPORT_EMAIL`
- ne plus compter sur un fallback implicite vers le repository GitHub pour le support pilote

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
- `PRIORIS_PILOT_SUPPORT_EMAIL` si la variable GitHub correspondante est definie

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
5. Verifier que `PRIORIS_PILOT_SUPABASE_URL` cible un host Supabase reel et non un host placeholder connu du repo.
6. Lancer manuellement la workflow `Deploy Pilot Web to GitHub Pages`.
7. Verifier l'URL retournee par `actions/deploy-pages` et confirmer qu'elle reste `https://n3z3d.github.io/PriorisProject/`.
8. Re-verifier `assets/.env` public pour confirmer que `SUPABASE_URL` reste `https://vgowxrktjzgwrfivtvse.supabase.co` ou un autre host reel attendu.

Pour le lane `6.2`, la source de verite support pilote reste:

- `AppLocalizations` pour les labels, limites et contenus editoriaux in-app
- `AppConfig.pilotSupportInfo` pour les destinations reelles variables par environnement
- la workflow GitHub Pages uniquement pour injecter `PRIORIS_PILOT_FEEDBACK_URL` / `PRIORIS_PILOT_SUPPORT_EMAIL` dans la build pilote web

## Verification retenue pour 6.1

Verification actuellement retenue:

1. `https://n3z3d.github.io/PriorisProject/` repond bien publiquement avec le bootstrap Flutter attendu et des metadata pilote (`title`, `manifest`, `base href`).
2. `assets/.env` public confirme `SUPABASE_URL=https://vgowxrktjzgwrfivtvse.supabase.co`, `PRIORIS_INSTANCE_NAME=Prioris Pilot Invite` et `SUPABASE_AUTH_REDIRECT_URL=https://n3z3d.github.io/PriorisProject/`.
3. `auth/v1/settings` repond sur cette cible et confirme que l'auth email reste active.
4. Les preuves repo-owned existantes (`tests integration/presentation` + `flutter build web`) restent la preuve secondaire du chemin auth/shell normal, distincte de la verification publique.

## Limites connues

- La verification live `2026-04-16` couvre explicitement l'entree publique et l'identification pilote, pas une session authentifiee hebergee avec des credentials d'invitation reels conserves dans le repo.
- La verification de configuration publique `2026-04-17` confirme maintenant un host Supabase reel via `assets/.env`, mais la preuve repo-owned d'un compte invite reussi reste absente: les credentials conserves dans `test/manual/test_credentials.txt` retournent `invalid_credentials`.
- Le deploiement reste manuel pour eviter d'exposer chaque push comme une release pilote publique.
- Le fallback `SUPABASE_AUTH_REDIRECT_URL` pointe vers la racine GitHub Pages, pas vers `/auth/callback`, car l'application ne documente pas encore de route web dediee de callback dans `AppRoutes`.
- Si un email de validation redirige encore vers un `404` GitHub Pages apres redeploiement, verifier aussi cote Supabase:
  - `Site URL`
  - la allow-list des redirect URLs
  - que le template email utilise bien `{{ .ConfirmationURL }}` ou une personnalisation compatible avec la cible GitHub Pages retenue
- `PRIORIS_PILOT_SUPABASE_URL` et `PRIORIS_PILOT_SUPABASE_ANON_KEY` sont des valeurs clientes publiques dans une app web; elles ne remplacent pas une vraie hygiene de securite Supabase.
- Si `PRIORIS_PILOT_FEEDBACK_URL` n'est pas configuree mais que `PRIORIS_PILOT_SUPPORT_EMAIL` l'est, le support `6.2` ouvre un `mailto:` borne vers cette adresse.
- Si aucun des deux canaux n'est configure, la workflow echoue avant la build web.
- Les preuves repo-owned locales restent secondaires meme apres activation: elles servent a confirmer le chemin auth/shell normal, pas a remplacer la verification publique de la cible pilote.
