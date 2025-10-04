
# ANNEXE A - LISTE COMPLÈTE DES FICHIERS DE CODE MORT (76 fichiers)

## À supprimer immédiatement (Risque faible)

### Domain Layer (17 fichiers)
lib/application/list_management/commands/create_list_command.dart
lib/domain/core/bounded_context.dart
lib/domain/core/events/event_bus.dart
lib/domain/habit/services/habit_analytics_service.dart
lib/domain/habit/specifications/habit_specifications.dart
lib/domain/list/services/list_optimization_service.dart
lib/domain/list/specifications/list_specifications.dart
lib/domain/list_management/value_objects/list_value_objects.dart
lib/domain/models/builders/list_item_builder.dart
lib/domain/services/calculation/list_calculation_service.dart
lib/domain/services/calculation/memoized_calculation_service.dart
lib/domain/services/core/extensible_error_classification_service.dart
lib/domain/services/insights/list_insights_service.dart
lib/domain/services/navigation/navigation_error_handler.dart
lib/domain/services/core/interfaces/data_import_interface.dart
lib/domain/services/persistence/common/persistence_types.dart

### Data Layer (2 fichiers)
lib/data/repositories/paginated_repository.dart
lib/data/repositories/base/unified_repository_interface.dart
lib/data/repositories/impl/task_repository_impl.dart

### Infrastructure (1 fichier)
lib/infrastructure/persistence/indexed_hive_repository.dart

### Presentation - Animations (11 fichiers)
lib/presentation/animations/physics.dart
lib/presentation/animations/staggered_animations.dart
lib/presentation/animations/widgets/bounce_widget.dart
lib/presentation/animations/widgets/hoverable_widget.dart
lib/presentation/animations/widgets/pressable_widget.dart
lib/presentation/animations/widgets/shimmer_widget.dart
lib/presentation/animations/widgets/staggered_entrance_widget.dart
lib/presentation/animations/systems/celebrations/floating_hearts_widget.dart
lib/presentation/animations/systems/celebrations/gentle_rain_widget.dart
lib/presentation/animations/systems/celebrations/ripple_effect_widget.dart

### Presentation - Controllers (1 fichier)
lib/presentation/controllers/base/base_controller.dart

### Presentation - Pages (13 fichiers)
lib/presentation/pages/duel/services/duel_ui_components_builder.dart
lib/presentation/pages/duel/widgets/duel_header_widget.dart
lib/presentation/pages/duel/widgets/vs_separator_widget.dart
lib/presentation/pages/habits/components/habits_list_view.dart
lib/presentation/pages/habits/components/habits_page_header.dart
lib/presentation/pages/habits/components/habit_card_builder.dart
lib/presentation/pages/habits/services/habit_action_handler.dart
lib/presentation/pages/lists/services/lists_performance_monitor.dart
lib/presentation/pages/lists/services/lists_repository_service.dart
lib/presentation/pages/lists/services/lists_state_service.dart
lib/presentation/pages/lists/services/list_items_service.dart
lib/presentation/pages/lists/widgets/list_filters_widget.dart
lib/presentation/pages/lists/widgets/list_filter_widget.dart
lib/presentation/pages/lists/widgets/list_integration_summary.dart

### Presentation - Other (5 fichiers)
lib/presentation/mixins/text_controller_mixin.dart
lib/presentation/theme/elevation_system.dart
lib/presentation/theme/refactored_glassmorphism_system.dart
lib/presentation/widgets/advanced_loading_widget.dart
lib/presentation/services/haptic/haptic_wrapper_widget.dart

## Total: 76 fichiers identifiés comme code mort

## Instructions de suppression

1. Créer une branche: git checkout -b refactor/cleanup-dead-code
2. Supprimer les fichiers listés ci-dessus
3. Exécuter les tests: flutter test
4. Vérifier que l'app se compile: flutter build
5. Commit: git commit -m "refactor: Remove 76 dead code files"
6. Review et merge

## Gains estimés
- Réduction: ~5,000-8,000 lignes de code
- Amélioration lisibilité du projet
- Réduction du temps de compilation
- Facilitation de la navigation dans le code

