# Epic 17 : Release Engineering & Qualité Dev

**Objectif :** Mettre en place les outils et pratiques qui font passer un projet d'un "projet perso" à un "projet pro" : versioning sémantique automatisé, CHANGELOG généré, détection de secrets dans le CI, rotation documentée des secrets, et remplacement des faux benchmarks par des métriques réelles. Mary (Risk Analyst) a identifié les faux documents comme risque de crédibilité actif — suppression prioritaire.

**Source :** Gap analysis party mode 2026-05-13. Mary : "PERFORMANCE_BENCHMARKS.md et ACCESSIBILITY_COMPLIANCE_REPORT.md contiennent des chiffres inventés — risque de crédibilité certaine si partagés avec un partenaire ou auditeur." John : "release management = semver, CHANGELOG, tags — nécessaire avant production stable."

**Pré-requis :** Epic 11 story 11.6 terminée (CI/CD fonctionnel). Peut se faire en parallèle d'Epic 13.

**Budget estimé :** 0 € (tous les outils sont open source ou inclus dans GitHub)

---

## Critères de sortie de l'Epic 17

- [ ] Conventional Commits appliqués sur tous les nouveaux commits
- [ ] Script de release génère automatiquement la version semver + CHANGELOG + tag git
- [ ] Gitleaks détecte les secrets commités dans le CI — PR bloquée si secret détecté
- [ ] Procédure de rotation des secrets documentée dans `docs/runbooks/secrets-rotation.md`
- [ ] `docs/PERFORMANCE_BENCHMARKS.md` et `docs/ACCESSIBILITY_COMPLIANCE_REPORT.md` supprimés ou remplacés par de vraies métriques
- [ ] Web Vitals réels trackés et visibles

---

## Story 17.1 : Supprimer les faux documents de benchmark et accessibilité

**As a** Thibaut (responsable produit),
**I want** supprimer ou remplacer les documents de performance et accessibilité contenant des données fictives,
**so that** aucun partenaire, investisseur ou auditeur ne soit trompé par des chiffres inventés ("top 1% des apps Flutter", "100% WCAG AA").

**Contexte :** Deux fichiers contiennent des données entièrement inventées par un LLM :
- `docs/PERFORMANCE_BENCHMARKS.md` — chiffres de performance fictifs ("100ms LCP", "+1900% throughput")
- `docs/ACCESSIBILITY_COMPLIANCE_REPORT.md` — audit fictif ("100% WCAG AA", score Lighthouse 100/100)

Mary (Risk Analyst) a qualifié ce risque de **HIGH et de probabilité certaine** si ces fichiers sont partagés. La correction est immédiate et non négociable.

**Plan :**
1. Supprimer `docs/PERFORMANCE_BENCHMARKS.md`
2. Supprimer `docs/ACCESSIBILITY_COMPLIANCE_REPORT.md`
3. Créer `docs/METRICS.md` — fichier vierge avec structure réelle à remplir au fur et à mesure :
   - Performance : lancer Lighthouse et noter les vrais chiffres
   - Accessibilité : lancer axe DevTools et noter les vrais résultats
   - Section "TODO — métriques non encore mesurées"
4. Commit avec message `docs: supprimer faux benchmarks générés par IA — remplacés par METRICS.md`

**Acceptance Criteria :**
1. `docs/PERFORMANCE_BENCHMARKS.md` → supprimé du repo et de l'historique git (ou marqué [DEPRECATED - données fictives])
2. `docs/ACCESSIBILITY_COMPLIANCE_REPORT.md` → supprimé
3. `docs/METRICS.md` créé avec des vraies métriques Lighthouse (même si partielles)
4. Aucun fichier doc contenant des données inventées dans le repo

**IMPORTANT :** C'est la story la plus rapide de tout le backlog (1-2h). Elle doit être faite IMMÉDIATEMENT — avant toute démonstration publique ou partage du repo.

**Priorité :** 🔴 CRITIQUE — risque de crédibilité actif
**Effort estimé :** 1-2h

---

## Story 17.2 : Conventional Commits + Commitlint pre-commit hook

**As a** développeur,
**I want** que tous les commits suivent le format Conventional Commits, validé par un hook pre-commit,
**so that** le CHANGELOG soit générable automatiquement et l'historique git soit lisible par les outils de release.

**Contexte :** Conventional Commits est le standard utilisé par Angular, Vue, Electron, et des milliers de projets open source. Format : `type(scope): description`. Types : `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`. Le hook pre-commit bloque les commits non conformes.

**Outils :**
- `commitlint` + `@commitlint/config-conventional` (Node.js, via `npx`)
- `husky` pour les git hooks

**Plan :**
1. Créer `commitlint.config.js` à la racine avec `@commitlint/config-conventional`
2. Créer `.husky/commit-msg` qui exécute `npx --no commitlint --edit $1`
3. Initialiser husky : `npx husky install`
4. Ajouter `"prepare": "husky install"` dans `package.json` (ou `scripts/setup.sh`)
5. Documenter dans `CONTRIBUTING.md` : liste des types de commits avec exemples
6. Vérifier que les commits récents du repo sont rétroactivement conformes (sinon documenter l'exception)

**Acceptance Criteria :**
1. `git commit -m "random message"` → hook bloque avec message d'erreur clair
2. `git commit -m "feat(habits): ajouter rappel quotidien"` → commit accepté
3. `CONTRIBUTING.md` liste les types de commits avec exemples
4. Le hook fonctionne sur macOS, Linux, et Windows (Powershell)

**Priorité :** 🟡 Moyenne — fondation pour le CHANGELOG automatique
**Effort estimé :** 2-3h

---

## Story 17.3 : Versioning semver automatique + CHANGELOG + git tags

**As a** développeur,
**I want** qu'une commande unique génère la prochaine version semver, mette à jour CHANGELOG.md, et crée le tag git correspondant,
**so that** chaque release soit traçable et le CHANGELOG soit toujours à jour sans travail manuel.

**Contexte :** `standard-version` (déprécié) ou `release-it` (actif, très configuré) sont les outils standards. Avec Conventional Commits en place (story 17.2), ces outils lisent l'historique git pour déterminer si c'est un patch (fix), minor (feat) ou major (breaking change).

**Outil recommandé :** `release-it` — plus activement maintenu, compatible CI et release manuelle.

**Plan :**
1. Installer `release-it` : `npm install --save-dev release-it`
2. Créer `.release-it.json` avec configuration : bump semver, génèrer CHANGELOG, créer tag git
3. Ajouter script dans `package.json` : `"release": "release-it"`
4. Créer `CHANGELOG.md` initial avec l'entrée "Initial release" pour la version actuelle
5. Documenter la procédure de release dans `CONTRIBUTING.md`
6. Tester : `npm run release -- --dry-run` → vérifier que la prochaine version est correcte

**Acceptance Criteria :**
1. `npm run release` → bump version dans `pubspec.yaml`, mise à jour `CHANGELOG.md`, tag git créé
2. `git log --oneline --decorate` → tag `v1.x.x` visible
3. `CHANGELOG.md` contient les feat et fix depuis la dernière version
4. `npm run release -- --dry-run` → preview de la prochaine release sans modifier le repo
5. Procédure documentée dans `CONTRIBUTING.md`

**Priorité :** 🟡 Moyenne — nécessaire avant production stable mais pas bloquant
**Effort estimé :** 3-4h

---

## Story 17.4 : Gitleaks dans CI/CD — détection de secrets commités

**As a** développeur,
**I want** que le CI bloque automatiquement tout commit contenant un secret (clé API, token, password),
**so that** aucune credential ne soit jamais publiée dans le dépôt git public.

**Contexte :** GitHub a natif la détection de secrets sur les repos publics, mais uniquement sur les patterns connus (AWS, GitHub tokens…). Gitleaks est plus complet, configurable, et détecte les patterns custom (clés Supabase, Firebase, etc.). Un secret commité même sur une branche privée est considéré comme compromis — la rotation est la seule réponse.

**Outil :** Gitleaks (open source, GitHub Action disponible : `gitleaks/gitleaks-action`)

**Plan :**
1. Ajouter `gitleaks/gitleaks-action@v2` dans le job CI (avant le job de build)
2. Créer `.gitleaks.toml` avec les patterns supplémentaires (Supabase anon key, Supabase service role key, Firebase API key)
3. Tester en local : `gitleaks detect --source . --verbose`
4. Scanner l'historique git existant : `gitleaks detect --log-opts="--all"` — si secret trouvé dans l'historique → rotation immédiate
5. Documenter dans `docs/runbooks/secrets-rotation.md` la procédure en cas de détection

**Acceptance Criteria :**
1. Un commit avec une fausse clé Supabase dans le code → CI bloque avec rapport Gitleaks
2. `gitleaks detect --source .` → 0 secret dans l'état actuel du repo
3. L'historique git existant a été scanné — résultat documenté
4. `.gitleaks.toml` couvre les patterns Supabase + Firebase + JWT

**Priorité :** 🔴 Haute — risque de sécurité actif (repo probablement public)
**Effort estimé :** 2-3h

---

## Story 17.5 : Documentation de la rotation des secrets

**As a** Thibaut (propriétaire),
**I want** une procédure documentée pour faire la rotation de chaque secret en cas de compromission,
**so that** je sache exactement quoi faire dans les 10 minutes suivant la détection d'un secret exposé.

**Contexte :** Les secrets actuels du projet incluent (a minima) : Supabase anon key, Supabase service role key, Firebase API key, GitHub Secrets CI/CD. Mary a identifié l'absence de documentation de rotation comme risque résiduel — "petits trous dans la coque qui grossissent".

**Plan :**
1. Créer `docs/runbooks/secrets-rotation.md` :
   - Liste de tous les secrets du projet avec leur localisation (GitHub Secrets, `.env`, `firebase_options.dart`)
   - Pour chaque secret : procédure de rotation étape par étape
   - Supabase : comment révoquer une clé et en générer une nouvelle dans le Dashboard
   - Firebase : comment régénérer une clé API dans la Console Firebase
   - GitHub : comment mettre à jour un secret dans les Settings CI/CD
2. Documenter la règle : "un secret détecté = rotation immédiate, pas d'investigation d'abord"
3. Ajouter l'alerte Gitleaks dans le runbook (lien avec story 17.4)

**Acceptance Criteria :**
1. `docs/runbooks/secrets-rotation.md` liste tous les secrets et leur procédure de rotation
2. Chaque procédure a un délai cible (ex: Supabase key → rotée en < 15 min)
3. Règle "rotation immédiate avant investigation" documentée
4. Lien vers ce runbook dans `CONTRIBUTING.md` et depuis le rapport Gitleaks

**Priorité :** 🟡 Moyenne
**Effort estimé :** 2h (documentation)

---

## Critères de clôture de l'Épic 17

- [ ] Faux documents supprimés — `docs/METRICS.md` avec vraies métriques Lighthouse en place
- [ ] Conventional Commits validés par hook pre-commit sur chaque commit
- [ ] `npm run release` génère semver + CHANGELOG + tag git
- [ ] Gitleaks en CI — 0 secret détectable dans l'état actuel du repo
- [ ] `docs/runbooks/secrets-rotation.md` documenté pour chaque secret du projet
- [ ] `CONTRIBUTING.md` couvre : types de commits, procédure de release, runbooks

---

*Épic créé le 2026-05-13 — Mary Risk Analyst : "les faux documents sont un risque de crédibilité actif et certain." Gap analysis party mode : release management, Gitleaks, secrets rotation.*
