# Epic 9 : Fondation Architecture Hexagonale

**Objectif :** Migrer les ports repository vers `lib/domain/` conformément à l'ADR-001, établissant la frontière domaine/infrastructure que Clean Architecture impose. Chaque story est autonome et rétrocompatible — aucun big bang.

**Source :** ADR-001 (`docs/ADR/ADR-001-hexagonal.md`, 2026-04-29) — plan de migration Epic 9 → 11.

**Pré-requis :** ADR-001 accepté ✅, `lib/domain/CLAUDE.md` créé ✅.

---

## Epic 9 : Fondation Architecture Hexagonale

### Story 9.1 : Déplacer le port HabitRepository vers lib/domain/ (consolider doublon)

**As a** développeur,
**I want** que l'interface `HabitRepository` soit déclarée dans `lib/domain/habit/repositories/` et non dans `lib/data/repositories/`,
**so that** le domaine soit hermétique et que `SupabaseHabitRepository` dépende du domaine, pas l'inverse.

**Contexte :** Il existe actuellement DEUX interfaces `HabitRepository` :
- `lib/data/repositories/habit_repository.dart` → interface réelle (7 méthodes, entité `Habit`) utilisée par Supabase + providers
- `lib/domain/habit/repositories/habit_repository.dart` → interface DDD aspirationnelle (HabitAggregate) non utilisée, code mort

L'ADR exige que le port (l'interface) soit dans le domaine. L'adaptateur Supabase doit dépendre du domaine, pas le domaine de data.

**Acceptance Criteria :**
1. `abstract class HabitRepository` (7 méthodes : `getAllHabits`, `saveHabit`, `addHabit`, `updateHabit`, `deleteHabit`, `getHabitsByCategory`, `clearAllHabits`) réside dans `lib/domain/habit/repositories/habit_repository.dart`
2. L'ancienne interface DDD (`HabitAggregate`, `HabitStatistics`, `HabitTrend`, etc.) est supprimée de `lib/domain/habit/repositories/habit_repository.dart`
3. `SupabaseHabitRepository` importe `HabitRepository` depuis `lib/domain/`, pas `lib/data/`
4. `InMemoryHabitRepository` (dans `lib/data/`) importe `HabitRepository` depuis `lib/domain/`
5. `puro flutter analyze --no-pub` → 0 nouvelle erreur introduite
6. `puro flutter test --exclude-tags integration` → 0 régression sur les tests pré-existants
7. Aucun import `supabase_flutter`, `hive`, ou `package:flutter` (sauf `foundation.dart`) dans `lib/domain/habit/repositories/habit_repository.dart`

**Priorité :** 🔵 Fondation — première story de l'Epic 9

---

### Story 9.2 : Typer les providers Riverpod sur l'interface domain pour habit

**As a** développeur,
**I want** que `habitRepositoryProvider` retourne `HabitRepository` (interface domain) et non `SupabaseHabitRepository` (implémentation concrète),
**so that** la présentation dépende uniquement de l'abstraction et non d'un détail infrastructure.

**Contexte :** Après la story 9.1, l'interface est dans domain/ mais le provider dans `lib/data/repositories/habit_repository.dart` crée directement `SupabaseHabitRepository`. Les fichiers qui l'utilisent peuvent théoriquement typer leur variable sur `HabitRepository`, mais seul un type explicite au niveau du provider garantit l'isolation.

**Acceptance Criteria :**
1. `habitRepositoryProvider` est typé `Provider<HabitRepository>` (et non inféré sur `SupabaseHabitRepository`)
2. `habitsStateProvider.dart` importe `HabitRepository` depuis `lib/domain/`, pas `lib/data/`
3. `puro flutter analyze --no-pub` → 0 nouvelle erreur
4. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** Moyenne — suite directe de 9.1

---

### Story 9.3 : Déplacer les ports CustomListRepository et ListItemRepository vers lib/domain/

**As a** développeur,
**I want** que `CustomListRepository` et `ListItemRepository` soient déclarés dans `lib/domain/`, sur le même modèle que `HabitRepository` après 9.1,
**so that** la migration hexagonale soit complète pour les trois agrégats principaux (Habit, CustomList, ListItem).

**Contexte :** Même problème que HabitRepository : les interfaces réelles sont dans `lib/data/`, les interfaces domain sont aspirationnelles DDD non utilisées. `CustomListRepository` est plus complexe (ISP avec 4 sous-interfaces). `ListItemRepository` est simple.

**Acceptance Criteria :**
1. `abstract class CustomListRepository` (et ses 4 sous-interfaces ISP) réside dans `lib/domain/list/repositories/custom_list_repository.dart`
2. L'ancienne interface DDD `CustomListRepository` (avec `CustomListAggregate`) est supprimée
3. `abstract class ListItemRepository` réside dans `lib/domain/list/repositories/list_item_repository.dart` (nouveau fichier)
4. `SupabaseCustomListRepository`, `SupabaseListItemRepository`, `HiveCustomListRepository`, `HiveListItemRepository` importent depuis `lib/domain/`
5. Providers typés sur les interfaces domain
6. `puro flutter analyze --no-pub` → 0 nouvelle erreur, `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** Moyenne — suite de 9.2

---

## Critères de clôture de l'Epic 9

- [ ] `lib/domain/habit/repositories/habit_repository.dart` = port réel (pas DDD aspirationnel)
- [ ] `lib/domain/list/repositories/custom_list_repository.dart` = port réel
- [ ] `lib/domain/list/repositories/list_item_repository.dart` = port réel
- [ ] 0 import `supabase_flutter`/`hive`/`package:flutter` dans `lib/domain/*/repositories/`
- [ ] Tous les providers typés sur interfaces domain
- [ ] `puro flutter analyze --no-pub` propre
- [ ] `puro flutter test --exclude-tags integration` → 0 régression
- [ ] ADR-001 statut confirmé : "En cours (Epic 9 clôturé)"
