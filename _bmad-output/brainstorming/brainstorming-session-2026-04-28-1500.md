---
stepsCompleted: [1, 2, 3]
inputDocuments: []
session_topic: 'Choix architecture cible PriorisProject : Layered vs Hexagonal vs Clean Architecture vs Microservices'
session_goals: 'Recommandation votée par agents + stratégie de migration progressive sans casser la production'
selected_approach: 'ai-recommended'
techniques_used: ['Role Playing', 'Six Thinking Hats', 'Constraint Mapping']
ideas_generated: []
context_file: ''
---

# Session de brainstorming — Architecture cible PriorisProject

**Date :** 2026-04-28
**Facilitateur :** Claude Sonnet 4.6

## Session Overview

**Topic :** Choix architecture cible PriorisProject — Layered actuelle vs Hexagonal vs Clean Architecture vs Microservices
**Goals :** Vote des agents + recommandation d'architecture + stratégie de migration progressive (app en production, ne pas casser)

### Contexte projet

- Flutter 3.32.8 / Dart 3.8 / Supabase / Riverpod / Hive
- App mobile + web (GitHub Pages)
- Architecture actuelle : Layered (couches présentation/application/domaine/infrastructure)
- Epic 9+ pour la migration
- Contrainte forte : app en production, migration incrémentale obligatoire

### Session Setup

Session de délibération multi-agents. Chaque agent défend une position architecturale, argumente pour son cas spécifique à PriorisProject ET de façon générique, puis un vote collectif produit une recommandation finale avec plan de migration.

---

## Résultats de la session

### Phase 1 — Débat des avocats (Role Playing)

Vote agents : **Hexagonale 3/4** (Layered : maintenir avec réserves, Hexagonale : ✅, Clean Architecture : Hexagonale d'abord, Microservices : hors scope)

### Phase 2 — Six Thinking Hats

Verdict : **Hexagonale confirmée**. Nuances clés :
- Pas de Use Cases imposés (concept Clean Architecture, pas Hexagonal)
- Migration domaine par domaine, pas en big bang
- ADR obligatoire avant toute ligne de code

Découverte : "Hexagonal Lite" était un abus de langage — Hexagonal n'a jamais requis de Use Cases. On vise **Hexagonal complet**.

### Phase 3 — Constraint Mapping

Découverte critique : deux systèmes de repositories en parallèle. Interface active (`HabitRepository`) dans `lib/data/` au lieu de `lib/domain/` — 40-50% du chemin déjà parcouru.

Plan de migration : Epic 9 (fondation) → Epic 10 (consolidation) → Epic 11 (audit).

### Livrables produits

- `lib/domain/CLAUDE.md` — règles Hexagonal pour la couche domaine ✅
- `docs/ADR/ADR-001-hexagonal.md` — décision formalisée ✅

### Décision finale

**Architecture Hexagonale** — Ports & Adapters, Alistair Cockburn.
Migration incrémentale Epic 9→11. Gouvernance via `lib/domain/CLAUDE.md`.
