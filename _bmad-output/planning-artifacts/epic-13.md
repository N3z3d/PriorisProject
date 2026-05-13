# Epic 13 : Fiabilité des Données & Tests E2E

**Objectif :** Sécuriser la couche de données locale avant d'ouvrir le produit à la production réelle — migrations Hive versionnées, stratégie de test hermétique, et filet de sécurité E2E sur les flux critiques. Sans cette base, chaque mise à jour du schéma local est un saut dans le vide, et les E2E écrits sur une architecture instable sont une dette déguisée.

**Source :** Party mode 2026-05-13 — consensus Winston Architect + Amelia Dev : "E2E au début du Lot 3, après CI/CD + migrations + décision mock Hive."

**Pré-requis :** Epic 11 stories 11.2 + 11.6 clôturées — CI/CD fonctionnel sur PR, pipeline vert.

**Budget estimé :** 0 € (outils open source — Playwright gratuit, Hive inclus, GitHub Actions inclus)

---

## Contexte technique

Prioris utilise **Hive** comme cache de persistance local Flutter. Actuellement, aucun système de migration versionnée n'existe — si le schéma des boxes Hive change entre deux versions, les données existantes des utilisateurs peuvent être corrompues silencieusement ou provoquer des crashes au démarrage.

De plus, l'absence de stratégie décidée sur le **mock Hive pour les tests** bloque l'écriture de tests E2E utiles. Winston (Architect) et Amelia (Dev) ont convergé sur ce point : écrire des E2E sans cette décision coûte 2 semaines au lieu de 2 jours.

---

## Critères de sortie de l'Epic 13

- [ ] Migrations Hive versionnées et testées — aucun crash de démarrage possible après mise à jour
- [ ] Stratégie mock Hive documentée et implementée (décision : mock vs instance réelle)
- [ ] Script seed/teardown fiable pour les fixtures de test
- [ ] Au moins 3 tests E2E sur les flux critiques (login → prioritisation → persistance) en CI

---

## Story 13.1 : Système de migrations Hive versionnées

**As a** développeur,
**I want** que les changements de schéma Hive soient gérés par un système de migrations versionnées,
**so that** une mise à jour de l'app ne corrompe jamais les données existantes d'un utilisateur.

**Contexte :** Hive supporte un mécanisme de `typeId` et de `HiveObject`. Actuellement, si un champ est ajouté ou supprimé d'un `HiveObject`, les boxes existantes contiennent des données dans l'ancien format. Sans migration, l'app crash ou ignore silencieusement les données.

**Plan :**
1. Inventorier toutes les `HiveObject` classes et leurs `typeId` actuels
2. Créer un `MigrationRunner` qui détecte la version du schéma stockée dans une box dédiée `_meta`
3. Implémenter les migrations comme des fonctions numérotées (version 0 → 1 → 2…)
4. Ajouter un test unitaire par migration : données v(n-1) → données v(n) correctes
5. Documenter le processus dans `docs/adr/ADR-002-hive-migrations.md`

**Acceptance Criteria :**
1. Une box Hive ouverte avec un schéma v(n-1) est migrée automatiquement vers v(n) au premier démarrage
2. Aucun crash de démarrage pour les utilisateurs avec des données existantes
3. `puro flutter test --exclude-tags integration` → 0 régression
4. `docs/adr/ADR-002-hive-migrations.md` documenté avec le versioning scheme

**Priorité :** 🔴 Haute — prérequis pour E2E et pour la production
**Effort estimé :** 3-5 jours

---

## Story 13.2 : Décision et implémentation de la stratégie mock Hive pour les tests

**As a** développeur,
**I want** une stratégie décidée et documentée pour l'utilisation de Hive dans les tests,
**so that** les tests E2E et d'intégration soient hermétiques, déterministes et rapides.

**Contexte :** Amelia a pointé que cette décision est un bloquant à 70% pour les E2E. Deux options :
- **Option A — Hive réel en mémoire** : `Hive.init()` avec un répertoire temporaire par test. Proche de la réalité, mais chaque test démarre avec un état propre grâce au teardown.
- **Option B — Mock Hive** : Remplacer les repositories Hive par des implémentations InMemory dans les tests. Plus rapide, mais éloigné du comportement réel de Hive (sérialisation, typeAdapters…).

**Recommandation :** Option A (Hive réel en répertoire temp) — les adaptateurs Hive font partie du code testé, il serait risqué de les mocker systématiquement.

**Plan :**
1. Décider et valider l'option avec l'équipe (ADR)
2. Créer un helper `TestHiveHelper.setUp()` / `tearDown()` dans `test/helpers/`
3. Ajouter l'initialisation dans `setUpAll` des tests qui nécessitent Hive
4. Documenter dans `docs/adr/ADR-003-hive-test-strategy.md`
5. Migrer les tests existants qui mockent Hive manuellement vers ce helper

**Acceptance Criteria :**
1. `ADR-003-hive-test-strategy.md` validé — décision documentée avec justification
2. `TestHiveHelper` implémenté et utilisé dans ≥ 1 test existant
3. Les tests utilisant `TestHiveHelper` sont isolés — exécution dans n'importe quel ordre → même résultat
4. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — prérequis bloquant pour Story 13.3 (E2E)
**Effort estimé :** 2-3 jours

---

## Story 13.3 : Mise en place des tests E2E sur les flux critiques

**As a** développeur,
**I want** un filet de tests E2E sur les flux utilisateurs critiques, intégrés en CI,
**so that** aucune régression sur le parcours principal ne passe en production sans être détectée.

**Contexte :** Playwright sur Flutter Web est mature depuis Flutter 3.24+. L'approche recommandée par Amelia : cibler les 3-4 flux critiques (login, création habitude, prioritisation, affichage résultats), pas une couverture exhaustive.

**Flux E2E cibles (priorité décroissante) :**
1. Login email → ConsentGatePage → HomePage avec habitudes chargées
2. Créer une habitude → la voir dans la liste → Hive persistance vérifiée
3. Lancer une session de prioritisation → voter → voir le résultat mis à jour
4. RevokeConsent → snackbar → retour ConsentGatePage (flux story 10.1)

**Plan :**
1. Configurer Playwright dans un sous-dossier `e2e/`
2. Créer un environnement de test dédié (`.env.test` + Supabase staging project ou mock)
3. Implémenter les 4 flux E2E listés ci-dessus
4. Ajouter job `e2e` dans GitHub Actions (déclenché sur PR vers `main`)
5. Configurer artefacts de screenshots/vidéo sur échec

**Acceptance Criteria :**
1. `npx playwright test` → les 4 flux passent en local
2. Job `e2e` vert sur PR → merge autorisé
3. Un test E2E en échec bloque la PR (status check required)
4. Les tests E2E ne dépendent pas de données d'utilisateurs réels (seed fixtures)
5. Screenshots et traces disponibles sur GitHub Actions en cas d'échec

**Pré-requis :** Stories 13.1 + 13.2 terminées, Epic 11 story 11.2 terminée (CI/CD gates)
**Priorité :** 🔴 Haute — filet de sécurité avant push notifications et offline mode
**Effort estimé :** 5-7 jours

---

## Story 13.4 : Script de seed et teardown pour les fixtures de test

**As a** développeur,
**I want** un script reproductible pour initialiser et nettoyer l'état de test (Hive + Supabase staging),
**so that** les tests E2E soient déterministes et ne se polluent pas entre eux.

**Contexte :** Sans seed/teardown, les tests E2E dépendent de l'état laissé par le test précédent — ce qui rend les pannes non reproductibles et les débogages cauchemardesque. C'est la précondition identifiée par Amelia avant l'Epic 13.3.

**Plan :**
1. Créer `e2e/fixtures/seed.ts` : initialise les données de test (utilisateur test, habitudes, listes)
2. Créer `e2e/fixtures/teardown.ts` : supprime toutes les données créées pendant le test
3. Intégrer dans `playwright.config.ts` via `globalSetup` / `globalTeardown`
4. Créer un utilisateur de test dédié dans Supabase staging (jamais utilisé en prod)
5. Documenter dans `e2e/README.md` : comment ajouter des fixtures, comment reset l'état

**Acceptance Criteria :**
1. `npx playwright test` exécuté deux fois de suite → même résultat (idempotent)
2. Données de test Supabase staging propres après chaque run (`teardown` effectif)
3. Données Hive locales isolées par répertoire temporaire par test
4. `e2e/README.md` documenté

**Priorité :** 🟡 Moyenne — prérequis pour avoir des E2E fiables
**Effort estimé :** 2-3 jours

---

## Critères de clôture de l'Épic 13

- [ ] ADR-002 (migrations Hive) et ADR-003 (mock strategy) documentés et validés
- [ ] `MigrationRunner` implémenté et testé — 0 crash possible sur données existantes
- [ ] `TestHiveHelper` utilisé dans les tests d'intégration existants
- [ ] 4 flux E2E verts en CI sur chaque PR vers `main`
- [ ] Seed/teardown idempotent — 2 runs successifs = même résultat

---

*Épic créé le 2026-05-13 — suite party mode multi-agents (Winston, Amelia convergence on E2E preconditions)*
