# Story 10.3 : Supprimer les fichiers orphelins et corriger les 177 erreurs d'analyse Dart

Status: done

## Story

En tant que développeur,
je veux que `puro flutter analyze --no-pub` retourne 0 erreur dans `lib/`,
afin que le gate CI d'analyse puisse être réactivé (story 11-2) et que le projet soit sain.

## Acceptance Criteria

1. `puro flutter analyze --no-pub` → 0 erreur (warnings et infos tolérés)
2. Aucun fichier actuellement utilisé par l'app ne disparaît (vérification via `flutter build web --release` qui doit compiler)
3. `puro flutter test --exclude-tags integration` → 0 régression par rapport à l'état pré-story

## Tasks / Subtasks

- [x] **T1 — Diagnostiquer chaque fichier en erreur** (23 fichiers, 177 erreurs)
  - [x] T1.1 — Vérifier si le fichier est référencé ailleurs dans `lib/` (`grep -r "nom_fichier" lib/`)
  - [x] T1.2 — Classer : orphelin pur (supprimer) vs utilisé mais cassé (corriger)

- [x] **T2 — Supprimer les fichiers orphelins confirmés**
  - [x] T2.1 — `lib/domain/services/persistence/persistence_coordinator.dart` (imports 6 modules inexistants)
  - [x] T2.2 — `lib/domain/services/persistence/unified_persistence_factory.dart`
  - [x] T2.3 — `lib/domain/services/persistence/unified_persistence_service.dart`
  - [x] T2.4 — `lib/domain/list/services/optimization/calculators/optimization_metrics_calculator.dart`
  - [x] T2.5 — `lib/presentation/animations/physics.dart` (physics/export.dart inexistant ; non importé)
  - [x] T2.6 — Autres orphelins identifiés en T1 : `domain/services/providers/service_providers.dart`, `presentation/pages/lists/services/lists_business_logic.dart`, `lists_event_handler.dart`, `lists_persistence_manager.dart`, `lists_state_service.dart`, `duel/services/duel_ui_components_builder.dart`

- [x] **T3 — Corriger les fichiers utilisés mais cassés**
  - [x] T3.1 — `lib/presentation/pages/lists/widgets/components/list_type_style_helper.dart` : ajout cases `ListType.TODO` et `ListType.IDEAS`
  - [x] T3.2 — `lib/presentation/pages/lists/widgets/list_type_selector.dart` : même correction
  - [x] T3.3 — Conflit `SortOption` : résolu par suppression de `lists_event_handler.dart` (seul fichier qui importait les deux sources simultanément)
  - [x] T3.4 — `habit_add_form.dart` : `availableCategories: const []` passé à HabitFormWidget ; `habits_list_view.dart` : retrait de `const` sur `Icon` avec `Colors.xxx[n]` ; `habit_tracking_section.dart` : `timesController.context` → `BuildContext` propagé via paramètre

- [x] **T4 — Validation**
  - [x] T4.1 — `puro flutter analyze --no-pub` → 0 erreur (2364 warnings/infos tolérés)
  - [x] T4.2 — `puro flutter build web --release` → `√ Built build\web`
  - [x] T4.3 — `puro flutter test --exclude-tags integration` → 2034 pass, 26 skip, 1 échec flaky préexistant (`ListsTransactionManager timeout` — confirmé en isolation)

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

### Review Findings

- [x] [Review][Decision→Defer] availableCategories: const [] — scope creep sur story 0-erreur analyze ; pattern correct existe via dialog path. Story 10-19 créée pour le fix propre. [lib/presentation/pages/habits/components/habit_add_form.dart:20]
- [x] [Review][Patch] Backslash dans import de skeleton_system_manager.dart — corrigé : `\loading\strategies\` → `/loading/strategies/` [lib/presentation/widgets/loading/managers/skeleton_system_manager.dart:11]
- [x] [Review][Patch] ListTypeSelector hauteur fixe 400px clippe TODO/IDEAS — corrigé : SizedBox(400) + Expanded supprimés, GridView shrinkWrap se dimensionne au contenu [lib/presentation/pages/lists/widgets/list_type_selector.dart:27]
- [x] [Review][Defer] TextEditingControllers (_cycleActiveController, _cycleLengthController) non disposés dans HabitFormWidget [lib/presentation/pages/habits/widgets/habit_form_widget.dart] — deferred, pre-existing
- [x] [Review][Defer] Mauvais callbacks cycle fields (onTimesChanged→_cycleActive, onIntervalEveryChanged→_cycleLength) dans AdvancedHabitTrackingSection — données saisies silencieusement ignorées [lib/presentation/pages/habits/widgets/components/advanced_habit_tracking_section.dart] — deferred, pre-existing
- [x] [Review][Defer] Boutons no-op (CTA créer habitude, retry erreur) dans HabitsListView — tappables mais ne font rien [lib/presentation/pages/habits/components/habits_list_view.dart] — deferred, pre-existing
- [x] [Review][Defer] Trois tables switch indépendantes icon/couleur pour ListType (list_type_style_helper, list_type_selector, list_type_helpers) — valeurs divergentes entre elles [DRY violation] — deferred, pre-existing
- [x] [Review][Defer] Chaîne 'Type de liste' hard-codée FR sans i18n dans ListTypeSelector [lib/presentation/pages/lists/widgets/list_type_selector.dart:33] — deferred, pre-existing
- [x] [Review][Defer] Risque setState après dispose dans callbacks async showDatePicker (HabitTrackingSection + AdvancedHabitTrackingSection) [habit_tracking_section.dart / advanced_habit_tracking_section.dart] — deferred, pre-existing
- [x] [Review][Defer] Incohérence couleur ListType entre colorValue (list_enums.dart) et helpers UI (TODO: teal vs indigo) [list_enums.dart vs list_type_style_helper.dart] — deferred, pre-existing
- [x] [Review][Defer] SortOption triple définition — T3.3 a supprimé le fichier conflictuel mais 3 enums coexistent encore (lists_state, lists_controller_interfaces, lists_filter_service) — cause racine non résolue [lists_state.dart, lists_controller_interfaces.dart, lists_filter_service.dart] — deferred, pre-existing
- [x] [Review][Defer] accessibility_service.dart importe flutter/material.dart depuis lib/domain/ (violation règle hexagonale lib/domain/CLAUDE.md) [lib/domain/services/ui/accessibility_service.dart:1] — deferred, pre-existing
- [x] [Review][Defer] Switch _toDomainSortOption non exhaustif — 6 cas sur 8 valeurs domain (ITEMS_COUNT_ASC/DESC manquants) [lists_controller.dart] — deferred, pre-existing
- [x] [Review][Defer] Swallow silencieux de toutes exceptions dans _safeCurrentUser — habits créées sans userId si AuthService lève [lib/presentation/pages/habits/widgets/habit_form_widget.dart] — deferred, pre-existing
- [x] [Review][Defer] HabitTrackingSection potentiellement dead code — HabitFormWidget instancie AdvancedHabitTrackingSection ; le fix context propagation peut ne pas couvrir le chemin d'exécution réel [lib/presentation/pages/habits/widgets/components/habit_tracking_section.dart] — deferred, pre-existing

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- Test flaky `ListsTransactionManager - should execute rollback even after timeout` : passe en isolation, échoue parfois en suite complète (timing). Pré-existant, non causé par cette story.

### Completion Notes List

- **T1** : 11 orphelins identifiés (aucun importé par du code actif). 5 fichiers actifs avec erreurs à corriger.
- **T2** : 11 fichiers supprimés — persistence layer (3), optimization calculator (1), physics.dart (1), domain/services/providers/service_providers.dart (1), listes services dans `services/` sous-dossier (4), duel_ui_components_builder (1). Le fichier `premium_animation_system.dart` (Groupe C) n'avait pas d'erreurs au moment de l'exécution.
- **T3** : ListType.TODO et ListType.IDEAS ajoutés dans 2 switches. `habit_add_form.dart` : `availableCategories: const []`. `habits_list_view.dart` : retrait de `const` invalide. `habit_tracking_section.dart` : propagation de `BuildContext` à `_buildCycleFields` et `_buildSpecificDatePicker`.
- **T4** : AC1 ✅ 0 erreur. AC2 ✅ build web OK. AC3 ✅ test flaky pré-existant confirmé.

### File List

**Supprimés :**
- `lib/domain/services/persistence/persistence_coordinator.dart`
- `lib/domain/services/persistence/unified_persistence_factory.dart`
- `lib/domain/services/persistence/unified_persistence_service.dart`
- `lib/domain/list/services/optimization/calculators/optimization_metrics_calculator.dart`
- `lib/presentation/animations/physics.dart`
- `lib/domain/services/providers/service_providers.dart`
- `lib/presentation/pages/lists/services/lists_business_logic.dart`
- `lib/presentation/pages/lists/services/lists_event_handler.dart`
- `lib/presentation/pages/lists/services/lists_persistence_manager.dart`
- `lib/presentation/pages/lists/services/lists_state_service.dart`
- `lib/presentation/pages/duel/services/duel_ui_components_builder.dart`

**Modifiés :**
- `lib/presentation/pages/lists/widgets/components/list_type_style_helper.dart`
- `lib/presentation/pages/lists/widgets/list_type_selector.dart`
- `lib/presentation/pages/habits/components/habit_add_form.dart`
- `lib/presentation/pages/habits/components/habits_list_view.dart`
- `lib/presentation/pages/habits/widgets/components/habit_tracking_section.dart`

### Change Log

- 2026-05-15 : Suppression de 11 fichiers orphelins + correction de 5 fichiers actifs. `flutter analyze --no-pub` → 0 erreur. Build web et tests validés.
