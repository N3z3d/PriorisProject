# Epic 11 : Production & Sortie du Pilote

**Objectif :** Faire passer Prioris du statut "pilote" à "production" — domaine personnalisé, CI/CD renforcé, sauvegardes DB fiables, monitoring actif. Non optionnel : sans cette base, la croissance utilisateur expose à des pertes de données et une fiabilité insuffisante.

**Source :** Party mode 2026-05-13 (Winston Architect, John PM, Amelia Dev, Sally UX) — convergence sur 5 axes : domaine, CI/CD, backups, monitoring, branching.

**Pré-requis :** Epic 10 clôturé — 0 bug critique connu, onboarding fonctionnel, données hermétiques domaine.

**Budget estimé :** ~35 €/mois (Supabase Pro ~25 €/mois + domaine ~10 €/an)

---

## Critères de sortie du pilote (gates non négociables — John PM)

Avant de basculer en production :

| Gate | Critère |
|------|---------|
| G1 — Zéro perte de données | Backup DB automatique testé + restauré avec succès |
| G2 — Onboarding fonctionnel | Story 10.15 (activation event) livrée et validée par Thibaut |
| G3 — Zéro bug critique | Aucun item `[Review][HIGH]` non adressé dans le backlog actif |
| G4 — CI/CD gate | PR bloquée si `flutter analyze --fatal-warnings` ou tests échouent |
| G5 — Domaine custom actif | app.prioris.fr opérationnel, Supabase Auth URLs mises à jour |

---

## Epic 11 : Production & Sortie du Pilote

### Story 11.1 : Configurer le domaine personnalisé app.prioris.fr

**As a** Thibaut (propriétaire),
**I want** que l'application soit accessible sur `app.prioris.fr` au lieu de `n3z3d.github.io/PriorisProject`,
**so that** l'URL soit crédible pour les utilisateurs externes et compatible avec une future transition vers un hébergement dédié.

**Contexte :** Actuellement déployé sur GitHub Pages sous l'URL GitHub. Pour sortir du pilote, l'URL doit refléter la marque Prioris. Implique : achat domaine, configuration CNAME GitHub Pages, mise à jour des Redirect URLs Supabase Auth.

**Plan :**
1. Acheter domaine `prioris.fr` (ou `.app`) — ~10 €/an (Namecheap, OVH, Gandi)
2. Créer sous-domaine `app.prioris.fr` → CNAME vers `n3z3d.github.io`
3. Ajouter fichier `CNAME` dans le dossier de build GitHub Pages (ou repo `gh-pages`)
4. Mettre à jour dans Supabase Dashboard → Authentication → URL Configuration :
   - Site URL : `https://app.prioris.fr`
   - Redirect URLs : ajouter `https://app.prioris.fr/**`
5. Vérifier que le callback email pilote (epic-6) fonctionne sur le nouveau domaine

**Acceptance Criteria :**
1. `https://app.prioris.fr` charge l'application sans erreur TLS/redirect
2. Connexion Supabase (email/OAuth) fonctionne sur le nouveau domaine
3. L'ancienne URL GitHub Pages redirige vers `app.prioris.fr` (ou redirige proprement)
4. Le fichier `CLAUDE.md` et la doc projet référencent la nouvelle URL

**Priorité :** 🔴 Haute — gate G5 de sortie du pilote
**Effort estimé :** 2-4h (achat domaine 15 min, config CNAME 30 min, tests 1-2h)

---

### Story 11.2 : Renforcer la CI/CD — gates test et analyse obligatoires

**As a** Thibaut (développeur),
**I want** que les PR soient bloquées automatiquement si `flutter analyze --fatal-warnings` ou les tests échouent,
**so that** aucune régression ne passe en production sans être détectée.

**Contexte :** Actuellement, la CI/CD GitHub Actions déploie sans faire tourner les tests ni l'analyse statique avec des warnings fataux. Un bug introduit en PR peut aller en production sans aucun frein automatique.

**Plan :**
1. Modifier `.github/workflows/` pour ajouter un job `quality-gate` avant le job `deploy` :
   ```yaml
   - run: flutter test --exclude-tags integration --coverage
   - run: flutter analyze --fatal-warnings
   ```
2. Configurer `needs: [quality-gate]` sur le job de déploiement
3. Ajouter `lcov` report upload (optionnel, pour visualisation coverage)
4. Créer environnements GitHub : `staging` (branch `develop`) et `production` (branch `main`)
5. Protéger la branche `main` : require status checks passing avant merge

**Acceptance Criteria :**
1. Un PR avec un test en échec est bloqué (merge impossible)
2. Un PR avec un `flutter analyze --fatal-warnings` non-zéro est bloqué
3. Le job de déploiement ne se lance que si `quality-gate` est vert
4. La branche `main` est protégée (required status checks)
5. Documentation dans `.github/README.md` ou `CONTRIBUTING.md` explique le workflow

**Priorité :** 🔴 Haute — gate G4 de sortie du pilote
**Effort estimé :** 2-4h

---

### Story 11.3 : Sauvegardes automatiques PostgreSQL (Supabase)

**As a** Thibaut (propriétaire),
**I want** que la base de données soit sauvegardée automatiquement avec une rétention ≥ 7 jours et qu'une restauration soit testée,
**so that** aucune panne Supabase ou erreur humaine ne puisse entraîner une perte de données irréversible.

**Contexte :** Actuellement sur Supabase Free tier — pas de Point-in-Time Recovery (PITR), pas de snapshots téléchargeables automatiques. Pour sortir du pilote avec des données réelles utilisateurs, c'est le risque non négociable selon John PM (gate G1).

**Deux stratégies :**
- **Option A (recommandée)** — Passer à Supabase Pro (~25 €/mois) : PITR intégré, snapshots journaliers téléchargeables, support prioritaire
- **Option B (DIY)** — Cron job `pg_dump` hebdomadaire vers Cloudflare R2/Backblaze B2 (~0,5 €/mois de stockage)

**Plan (Option A recommandée) :**
1. Upgrader projet Supabase vers le plan Pro dans le Dashboard
2. Vérifier que "Point-in-Time Recovery" est activé (Settings → Backups)
3. Télécharger un snapshot manuel et vérifier l'intégrité
4. Documenter la procédure de restauration dans `docs/runbooks/restore-db.md`
5. Créer une alerte Supabase (ou email alert) si backup échoue

**Acceptance Criteria :**
1. Supabase Pro activé (ou backup DIY opérationnel)
2. Un snapshot de la DB a été téléchargé et vérifié manuellement
3. `docs/runbooks/restore-db.md` existe avec les étapes de restauration
4. Une alerte est configurée en cas d'échec de backup

**Priorité :** 🔴 Haute — gate G1 de sortie du pilote
**Effort estimé :** 1-2h (+ ~25 €/mois si Supabase Pro)
**Coût :** Supabase Pro ~25 €/mois (à décider par Thibaut)

---

### Story 11.4 : Monitoring uptime et alertes production

**As a** Thibaut (propriétaire),
**I want** être alerté automatiquement si l'application ou Supabase devient indisponible,
**so that** je puisse réagir rapidement avant que les utilisateurs remontent le problème.

**Contexte :** Actuellement, Thibaut découvre les pannes quand un utilisateur se plaint. Pour une app en production, un monitoring proactif est le minimum.

**Plan :**
1. Créer un compte UptimeRobot (gratuit, monitoring toutes les 5 min)
2. Ajouter 2 moniteurs :
   - URL `https://app.prioris.fr` — ping HTTP
   - URL Supabase REST API endpoint — `GET /rest/v1/` (ou health check)
3. Configurer alertes email vers `lambert.thibaut98@gmail.com`
4. (Optionnel) Créer une status page publique UptimeRobot pour communiquer sur les incidents

**Acceptance Criteria :**
1. UptimeRobot monitore `https://app.prioris.fr` avec alerte email configurée
2. Un test manuel de downtime (simulation) déclenche l'alerte dans les 10 min
3. Documentation dans `docs/runbooks/incident-response.md`

**Priorité :** 🟡 Moyenne — non bloquant pour la sortie, mais indispensable post-launch
**Effort estimé :** 1h

---

### Story 11.5 : Stratégie de branching main/develop et protection des branches

**As a** développeur,
**I want** que `main` représente la production et `develop` le staging, avec des protections de branche adéquates,
**so that** aucun push direct sur `main` ne soit possible et que le chemin vers la production soit explicite.

**Contexte :** Actuellement, tout le développement se fait sur `main`. Pour une app en production avec des utilisateurs réels, les pushs directs sur `main` sont un risque. La stratégie recommandée : `main` = production (protégée), `develop` = staging (CI/CD → GitHub Pages staging), PR de `develop` → `main` pour chaque release.

**Plan :**
1. Créer branche `develop` depuis `main` (état identique au départ)
2. Configurer protection de branche sur `main` :
   - Require PR before merge
   - Require status checks (quality-gate de story 11.2) before merge
   - Restrict who can push to matching branches
3. Configurer GitHub Actions :
   - Push sur `develop` → déploiement sur URL staging (GitHub Pages `staging/` path ou sous-domaine)
   - Push sur `main` → déploiement sur `app.prioris.fr` (production)
4. Documenter le workflow dans `CONTRIBUTING.md`

**Acceptance Criteria :**
1. Branche `main` protégée — push direct rejeté, PR obligatoire
2. Status checks obligatoires avant merge sur `main`
3. `develop` → déploiement staging automatique
4. `main` → déploiement production automatique (app.prioris.fr)
5. `CONTRIBUTING.md` documente le workflow de release

**Priorité :** 🟡 Moyenne — activé après story 11.2 (CI/CD gates en place)
**Effort estimé :** 1-2h

---

### Story 11.6 : Corriger le workflow CI/CD cassé — Flutter 3.19 → 3.32.8

**⚠️ URGENT — INCIDENT ACTIF** : Le workflow GitHub Actions déploie actuellement avec Flutter 3.19.0 alors que le projet tourne sur Flutter 3.32.8 (puro env `prioris-328`). Conséquence : le job de déploiement tourne dans le vide ou échoue silencieusement. Chaque push sur `main` depuis des semaines n'a pas réellement déployé l'app.

**As a** développeur,
**I want** que le workflow CI/CD utilise la même version Flutter que le projet local,
**so that** chaque push sur `main` déploie réellement l'application sur GitHub Pages.

**Contexte technique identifié :**
- `.github/workflows/ci.yml` ligne `flutter-version: '3.19.0'` → doit être `'3.32.8'`
- Le job `deploy` est vide (seulement des commentaires) → ajouter les étapes de build et déploiement
- Ce bug a été identifié lors du gap analysis party mode 2026-05-13

**Plan :**
1. Modifier `.github/workflows/ci.yml` : `flutter-version: '3.19.0'` → `flutter-version: '3.32.8'`
2. Compléter le job `deploy` avec les étapes manquantes :
   - `flutter build web --release --base-href /PriorisProject/`
   - Deploy vers GitHub Pages via `peaceiris/actions-gh-pages`
3. Vérifier que le job de test (`flutter test --exclude-tags integration`) passe
4. Vérifier que le job `flutter analyze --no-pub` passe
5. Faire un push test → vérifier que le déploiement produit un artefact réel

**Acceptance Criteria :**
1. `flutter-version` dans `ci.yml` = `'3.32.8'`
2. Push sur `main` → job deploy vert → `https://n3z3d.github.io/PriorisProject/` mis à jour
3. Job test → vert (0 régression)
4. Job analyze → vert (0 erreur fatale)
5. Durée totale du pipeline < 10 minutes

**Priorité :** 🔴 CRITIQUE — premier point du plan d'implémentation défini en party mode. Bloque TOUT le reste.
**Effort estimé :** 1-2h

---

## Critères de clôture de l'Épic 11

- [ ] Les 5 gates de sortie du pilote (G1 → G5) sont tous verts
- [ ] Story 11.6 terminée en premier — CI/CD fonctionnel vérifié
- [ ] `https://app.prioris.fr` est l'URL officielle, documentée dans le README
- [ ] Backup DB testé avec restauration réussie
- [ ] CI/CD bloque les régressions (tests + analyze)
- [ ] Monitoring uptime actif
- [ ] Branche `main` protégée
- [ ] `docs/runbooks/` contient au minimum `restore-db.md` et `incident-response.md`

---

## Note budget mensuel estimé

| Poste | Coût |
|-------|------|
| Supabase Pro | ~25 €/mois |
| Domaine `prioris.fr` (ou `.app`) | ~10 €/an ≈ ~1 €/mois |
| UptimeRobot | Gratuit (plan de base) |
| GitHub Actions | Gratuit (plan public / 2000 min/mois) |
| **Total** | **~26 €/mois** |

---

*Épic créé le 2026-05-13 — suite party mode multi-agents (Winston, John, Amelia, Sally)*
