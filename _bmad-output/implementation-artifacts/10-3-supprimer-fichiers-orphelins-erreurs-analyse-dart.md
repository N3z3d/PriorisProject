# Story 10.3 : Supprimer les fichiers orphelins et corriger les 177 erreurs d'analyse Dart

Status: ready-for-dev

## Story

En tant que développeur,
je veux que `puro flutter analyze --no-pub` retourne 0 erreur dans `lib/`,
afin que le gate CI d'analyse puisse être réactivé (story 11-2) et que le projet soit sain.

## Acceptance Criteria

1. `puro flutter analyze --no-pub` → 0 erreur (warnings et infos tolérés)
2. Aucun fichier actuellement utilisé par l'app ne disparaît (vérification via `flutter build web --release` qui doit compiler)
3. `puro flutter test --exclude-tags integration` → 0 régression par rapport à l'état pré-story

## Tasks / Subtasks

- [ ] **T1 — Diagnostiquer chaque fichier en erreur** (23 fichiers, 177 erreurs)
  - [ ] T1.1 — Vérifier si le fichier est référencé ailleurs dans `lib/` (`grep -r "nom_fichier" lib/`)
  - [ ] T1.2 — Classer : orphelin pur (supprimer) vs utilisé mais cassé (corriger)

- [ ] **T2 — Supprimer les fichiers orphelins confirmés**
  - [ ] T2.1 — `lib/domain/services/persistence/persistence_coordinator.dart` (imports 6 modules inexistants)
  - [ ] T2.2 — `lib/domain/services/persistence/unified_persistence_factory.dart`
  - [ ] T2.3 — `lib/domain/services/persistence/unified_persistence_service.dart`
  - [ ] T2.4 — `lib/domain/list/services/optimization/calculators/optimization_metrics_calculator.dart`
  - [ ] T2.5 — `lib/presentation/theme/systems/premium_animation_system.dart` (PremiumPhysicsAnimations undefined)
  - [ ] T2.6 — Autres fichiers orphelins identifiés en T1

- [ ] **T3 — Corriger les fichiers utilisés mais cassés**
  - [ ] T3.1 — `lib/presentation/pages/lists/widgets/components/list_type_style_helper.dart` : ajouter case `ListType.TODO`
  - [ ] T3.2 — `lib/presentation/pages/lists/widgets/list_type_selector.dart` : même correction
  - [ ] T3.3 — Résoudre le conflit `SortOption` défini dans deux fichiers (renommer ou centraliser)
  - [ ] T3.4 — Corriger les autres fichiers utilisés identifiés en T1

- [ ] **T4 — Validation**
  - [ ] T4.1 — `puro flutter analyze --no-pub` → 0 erreur
  - [ ] T4.2 — `puro flutter build web --release` → compile sans erreur
  - [ ] T4.3 — `puro flutter test --exclude-tags integration` → 0 régression

## Dev Notes

### Fichiers en erreur (23 fichiers, 177 erreurs — état 2026-05-14)

**Groupe A — Persistence layer orpheline** (imports de modules jamais créés) :
- `lib/domain/services/persistence/persistence_coordinator.dart` — importe `lists_persistence_service.dart`, `items_persistence_service.dart`, `data_management_service.dart`, `migration_service.dart`, `deduplication_service.dart`, `interfaces/unified_persistence_interface.dart` → aucun n'existe
- `lib/domain/services/persistence/unified_persistence_factory.dart` — même pattern
- `lib/domain/services/persistence/unified_persistence_service.dart` — même pattern
- `lib/domain/services/providers/service_providers.dart` — probablement lié

**Groupe B — Optimization calculator orphelin** :
- `lib/domain/list/services/optimization/calculators/optimization_metrics_calculator.dart` — import `../../core/services/domain_service.dart` inexistant + extends classe inconnue

**Groupe C — Animations premium non implémentées** :
- `lib/presentation/theme/systems/premium_animation_system.dart` — utilise `PremiumPhysicsAnimations`, `PremiumTransitionAnimations`, `PremiumAdvancedAnimations` non définis
- `lib/presentation/animations/physics.dart`
- `lib/presentation/widgets/loading/factories/skeleton_service_factory.dart`
- `lib/presentation/widgets/loading/managers/skeleton_system_manager.dart`
- `lib/presentation/widgets/loading/strategies/animation_strategies.dart`
- `lib/presentation/widgets/indicators/services/premium_sync_style_service.dart`

**Groupe D — Lists services cassés** (probablement après refacto Epic 9) :
- `lib/presentation/pages/lists/services/lists_business_logic.dart`
- `lib/presentation/pages/lists/services/lists_event_handler.dart`
- `lib/presentation/pages/lists/services/lists_persistence_manager.dart`
- `lib/presentation/pages/lists/services/lists_state_service.dart`

**Groupe E — Autres** :
- `lib/presentation/pages/habits/components/habit_add_form.dart`
- `lib/presentation/pages/habits/components/habits_list_view.dart`
- `lib/presentation/pages/habits/widgets/components/habit_tracking_section.dart`
- `lib/presentation/pages/duel/services/duel_ui_components_builder.dart`
- `lib/presentation/pages/lists/widgets/components/list_type_style_helper.dart` → `ListType.TODO` absent du switch
- `lib/presentation/pages/lists/widgets/list_type_selector.dart` → même problème
- `lib/presentation/services/accessibility/accessibility_service.dart`
- `lib/presentation/widgets/onboarding/components/onboarding_header.dart`

### Conflit SortOption

`SortOption` est défini dans :
- `lib/domain/services/core/lists_filter_service.dart`
- `lib/presentation/pages/lists/models/lists_state.dart`

L'analyseur voit un conflit d'ambiguïté et refuse les assignements `SortOption → SortOption`. Fix : utiliser un seul point de définition (probablement `domain/`) et supprimer l'autre, ou aliaser avec `import ... as`.

### Commandes Flutter

Toujours préfixer avec `puro` (env `prioris-328`) :
- `puro flutter analyze --no-pub`
- `puro flutter build web --release`
- `puro flutter test --exclude-tags integration`

### Lien avec 11-2

Une fois cette story `done`, le gate `flutter analyze --no-pub` peut être réactivé comme bloquant dans `ci.yml` (story 11-2).

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List

### Change Log
