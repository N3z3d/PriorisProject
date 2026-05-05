# ADR-001 — Adoption de l'architecture Hexagonale

**Date :** 2026-04-29
**Statut :** Accepté
**Décideurs :** Thibaut Lambert + session brainstorming multi-agents (2026-04-28)
**Référence session :** `_bmad-output/brainstorming/brainstorming-session-2026-04-28-1500.md`

---

## Contexte

PriorisProject utilise une architecture en couches (Layered) depuis l'Epic 3.
Après l'Epic 7, le code est stable en production et les patterns de couplage commencent à poser des problèmes :
- `SupabaseHabitRepository` est difficile à tester sans connexion réseau réelle
- Les interfaces repository existent dans la mauvaise couche (`lib/data/` au lieu de `lib/domain/`)
- Un changement de backend (ex: Supabase → Firebase) nécessiterait de toucher le domaine

Une session de brainstorming a comparé quatre architectures candidates :
Layered, Hexagonale, Clean Architecture (Uncle Bob), Microservices.

---

## Décision

Adopter l'**Architecture Hexagonale** (Ports & Adapters, Alistair Cockburn 2005).

Verdict du vote des agents : 3/4 pour Hexagonale, confirmé par évaluation Six Thinking Hats.

---

## Définition Hexagonale pour ce projet

### Ports (interfaces — déclarés dans `lib/domain/`)
Toute dépendance externe est abstraite par une interface dans le domaine :
- `domain/habit/repositories/habit_repository.dart` → port de persistance habitudes
- `domain/list/repositories/custom_list_repository.dart` → port listes
- `domain/*/repositories/*.dart` → ports domaine

### Adapters (implémentations — dans `lib/data/` ou `lib/infrastructure/`)
Les implémentations concrètes connectent le domaine au monde extérieur :
- `data/repositories/supabase/supabase_habit_repository.dart` → adapter Supabase
- `data/repositories/hive_*_repository.dart` → adapter Hive (persistance locale)
- `infrastructure/services/auth_service.dart` → adapter auth Supabase

### Règle de dépendance
```
presentation/  →  domain  ←  data/infrastructure
```
Le domaine ne dépend de rien. Tout le reste dépend du domaine.

---

## Ce que cette architecture N'IMPOSE PAS

- **Pas de Use Cases obligatoires** — les Use Cases sont un concept Clean Architecture (Uncle Bob), pas Hexagonal. Les controllers Riverpod restent le point d'entrée UI légitime.
- **Pas de Command Bus, Event Bus, CQRS** — hors scope pour ce projet.
- **Pas de migration big bang** — migration domaine par domaine, Epic 9 → 11.

---

## Alternatives écartées

| Architecture | Raison du rejet |
|---|---|
| Layered maintenue | Couplage infrastructure/domaine croissant, testabilité faible |
| Clean Architecture | Boilerplate Use Cases disproportionné pour app solo |
| Microservices | Inadapté : app mobile solo, pas de scale organisationnel |

---

## État actuel du code (2026-04-29)

Distance estimée vers Hexagonale complète : **40-50%** déjà parcouru.

Ce qui est déjà en place :
- Interfaces repository dans `lib/data/repositories/` (port au mauvais endroit)
- Implémentations Supabase séparées dans `lib/data/repositories/supabase/`
- Injection de dépendances via Riverpod providers

Ce qui manque :
- Ports dans `lib/domain/` (pas `lib/data/`)
- Providers Riverpod typés sur l'interface, pas l'implémentation
- Domaine hermétique (0 import Supabase/Hive/Flutter dans `lib/domain/`)

---

## Plan de migration

### Epic 9 — Fondation
| Story | Action |
|-------|--------|
| 9.1 | ADR + `lib/domain/CLAUDE.md` ✅ (cette story) |
| 9.2 | Déplacer ports `HabitRepository` → `lib/domain/habit/repositories/` (consolider doublon) |
| 9.3 | Typer providers Riverpod sur interface pour domaine `habit` |
| 9.4 | Même travail pour `CustomListRepository` et `ListItemRepository` |

### Epic 10 — Consolidation
| Story | Action |
|-------|--------|
| 10.1 | Ports pour AuthService et ConsentService |
| 10.2 | Tests domaine purs sans Supabase sur services migrés |
| 10.3 | Extraire logique métier Elo/Insights des controllers → `domain/services/` |

### Epic 11 — Audit final
Vérification : 0 import `supabase_flutter` / `hive` / `flutter` dans `lib/domain/`.

---

## Conséquences

**Positives :**
- Tests domaine sans réseau ni Supabase
- Migration backend (Supabase → autre) ne touche pas le domaine
- Onboarding futur facilité par contrat clair

**Négatives / risques :**
- Refactoring des imports sur 2-3 Epics
- Risque temporaire de casser les imports existants lors de chaque déplacement de port
- Discipline requise : chaque PR doit vérifier les règles `lib/domain/CLAUDE.md`
