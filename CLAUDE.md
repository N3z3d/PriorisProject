# CLAUDE.md — Directives de refactorisation du projet (Claude Code)

## Mandat
- Refactoriser le projet en appliquant **Clean Code** et **SOLID** de façon pragmatique, proportionnée au problème réel, sans abstraction spéculative ni refactorisation non demandée.
- **Analyser le projet** et **supprimer les fichiers inutiles**.
- Travailler en **TDD** : Red → Green → Refactor, en petits lots sûrs.

## Processus & Sécurité
0) **Clarification avant action** : avant toute modification, expliciter les hypothèses, ambiguïtés, risques et arbitrages. Si une ambiguïté peut provoquer une mauvaise refactorisation, demander confirmation au lieu de deviner.
1) **Cartographie** (sans code) : liste des modules, dépendances, zones mortes/dupliquées.
2) **Plan par lots** (≤ 200 lignes modifiées/lot). Pas de big bang. Chaque lot doit avoir un objectif observable et une vérification explicite : test, commande, diff attendu ou critère d’acceptation.
3) **Suppression contrôlée** :
   - Étape 1 (rapport) : fichier | raison | références | décision.
   - Étape 2 (diff) : supprimer uniquement ce qui a été validé.
4) Pas d’ajout de dépendances externes sans justification explicite.
5) **Diagnostic exhaustif** : quand le bug est un pattern (cast, duplication d’interface, violation architecturale), grepper l’ensemble du codebase (`grep -r "pattern" lib/`) avant d’ouvrir le fichier cible. Ne corriger que le fichier immédiat sans grep global est insuffisant.
6) **deferred-work.md comme source de stories** : les items `[Defer]` issus des reviews de code sont une source légitime de stories. Après clôture d’une story, consulter `deferred-work.md` pour identifier si des items nécessitent une story de suivi immédiate (priorité HIGH ou lien direct avec la story suivante planifiée).
7) **Finding `[Review][HIGH]` → story automatique** : tout finding marqué HIGH lors d’une review de code génère une story dédiée dans le backlog courant — pas seulement un item `deferred-work.md`. La mécanique deferred est pour les items MEDIUM/LOW.
8) **Décision HIGH de rétro → story créée avant clôture de la rétro** : toute décision ou item HIGH identifié pendant une rétrospective doit avoir une story créée dans l’epic suivant avant que le document de rétro soit sauvegardé. Une décision sans story est une intention, pas un engagement.

## Contraintes de taille
- **Maximum 500 lignes par classe**.
- **Maximum 50 lignes par méthode**.
- Si dépassement : extraire classes/fonctions/stratégies jusqu’à respecter les seuils.

## Organisation du code
- **Regrouper les classes qui évoluent ensemble** (cohésion forte, couplage faible).
- Respecter l’architecture cible choisie (cf. section “Architectures”).

## Règles générales de Clean Code
- Nommer classes/méthodes/variables **explicitement**.
- **Aucun code mort**. **Aucune duplication** (DRY).
- Méthodes **courtes et cohérentes** (une seule intention).
- **Changements chirurgicaux** : ne modifier que les lignes nécessaires à la demande. Ne pas reformater, renommer, déplacer ou “améliorer” du code adjacent sans lien direct avec l’objectif.
- Respect des conventions du repo (indentation, style, lint/format).
- **Tests unitaires systématiques** sur tout code modifié/ajouté.

## SOLID (obligatoire)
- **SRP** — Single Responsibility Principle
- **OCP** — Open/Closed Principle
- **LSP** — Liskov Substitution Principle
- **ISP** — Interface Segregation Principle
- **DIP** — Dependency Inversion Principle

## Design Patterns
- Utiliser un design pattern uniquement si le problème concret le justifie.
- Avant d’introduire un pattern, expliquer :
  1) le problème résolu,
  2) pourquoi une solution simple ne suffit pas,
  3) quel coût de complexité est ajouté.

## Architectures (choix guidé par le contexte)
- **Layered Architecture**
- **Hexagonal Architecture**
- **Microservices Architecture**
- **Event-Driven Architecture (EDA)**
- **CQRS** (Command Query Responsibility Segregation)
- **Event Sourcing**
- **Saga Pattern**
- **Serverless Patterns**
- **API Gateway**
- **Résilience** : Circuit Breaker, Retry Pattern (uniquement aux frontières I/O)

> Règle : privilégier **Layered/Hexagonal** par défaut. **Microservices/Serverless/CQRS/Event Sourcing/Saga** uniquement si la complexité métier/équipe/scale le justifie.

## TDD — Exigences de tests
- Toujours écrire un **test rouge minimal** avant d’implémenter.
- Couverture visée ≥ **85% lignes** sur le code modifié (qualité > pourcentage).
- Cas : **nominal + ≥3 edge cases** + erreurs attendues.
- Tests **déterministes** (isoler temps/réseau/IO via mocks/adapters).
- Pour les changements triviaux sans logique métier (typo, commentaire, renommage local, formatage ciblé), ne pas créer de test artificiel. Expliquer pourquoi aucun test n’est nécessaire.

## Sortie attendue (obligatoire pour chaque demande à Claude)
1) **Plan bref** (3–6 puces) décrivant l’approche.
2) **DIFF unifié uniquement** des fichiers à modifier/créer/supprimer.
3) **Tests** (diff des fichiers dans `tests/` ou équivalent).
4) **Checklist qualité** :
   - [ ] SOLID respecté (SRP/OCP/LSP/ISP/DIP)
   - [ ] ≤ 500 lignes par classe / ≤ 50 lignes par méthode
   - [ ] 0 duplication, 0 code mort
   - [ ] Nommage explicite, conventions respectées
   - [ ] Tests unitaires ajoutés/MAJ, cas limites couverts
   - [ ] Pas de nouvelle dépendance non justifiée
   - [ ] Si suppression : référencée dans le rapport approuvé

## Zones sensibles (ne pas toucher sans plan dédié)
- Pipelines CI/CD, schémas DB publics, contrats d’API publiés, config build/prod.
