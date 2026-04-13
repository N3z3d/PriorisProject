# Cible pilote GitHub Pages

## Objectif

Ce lot prepare une cible pilote externe minimale pour la story `6.1` via GitHub Pages:

- URL cible attendue: `https://n3z3d.github.io/PriorisProject/`
- workflow dedie: `.github/workflows/deploy-pilot-pages.yml`
- deploiement manuel, separe du CI principal

Cette cible ne doit pas etre presentee comme active tant qu'un run GitHub Pages n'a pas reussi et que l'URL n'a pas ete verifiee sur desktop et telephone.

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

La build web utilise:

- `--base-href /PriorisProject/`
- `--dart-define=PRIORIS_APP_VERSION=pilot-pages-<run_number>`

## Activation

1. Ouvrir GitHub repository settings.
2. Verifier que GitHub Pages est autorise pour le repository.
3. Si GitHub le demande, regler la source Pages sur `GitHub Actions`.
4. Ajouter les variables obligatoires et, si utile, les variables optionnelles.
5. Lancer manuellement la workflow `Deploy Pilot Web to GitHub Pages`.
6. Attendre l'URL retournee par `actions/deploy-pages`.

## Verification attendue pour fermer 6.1

Une fois le premier deploiement reussi:

1. Verifier l'URL publique sur desktop.
2. Verifier la meme URL sur telephone.
3. Confirmer que l'identite pilote visible correspond a `PRIORIS_INSTANCE_NAME`.
4. Documenter la date de verification, l'URL finale et les limites connues dans la story `6.1`.

## Limites connues

- Ce lot ne prouve pas a lui seul qu'une URL publique est active; il prepare le chemin de deploiement.
- Le deploiement reste manuel pour eviter d'exposer chaque push comme une release pilote publique.
- Le fallback `SUPABASE_AUTH_REDIRECT_URL` pointe vers la racine GitHub Pages, pas vers `/auth/callback`, car l'application ne documente pas encore de route web dediee de callback dans `AppRoutes`.
- `PRIORIS_PILOT_SUPABASE_URL` et `PRIORIS_PILOT_SUPABASE_ANON_KEY` sont des valeurs clientes publiques dans une app web; elles ne remplacent pas une vraie hygiene de securite Supabase.
- Les preuves repo-owned locales restent secondaires tant que l'URL GitHub Pages n'a pas ete verifiee en conditions reelles.
