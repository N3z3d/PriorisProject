@echo off
REM Phase 1 - Cleanup dead code files

echo Suppression des fichiers de code mort restants...

REM Presentation - Theme
if exist "lib\presentation\animations\physics.dart" git rm "lib\presentation\animations\physics.dart"
if exist "lib\presentation\mixins\text_controller_mixin.dart" git rm "lib\presentation\mixins\text_controller_mixin.dart"
if exist "lib\presentation\theme\elevation_system.dart" git rm "lib\presentation\theme\elevation_system.dart"
if exist "lib\presentation\theme\refactored_glassmorphism_system.dart" git rm "lib\presentation\theme\refactored_glassmorphism_system.dart"
if exist "lib\presentation\controllers\base\base_controller.dart" git rm "lib\presentation\controllers\base\base_controller.dart"

REM Data Layer
if exist "lib\data\repositories\paginated_repository.dart" git rm "lib\data\repositories\paginated_repository.dart"
if exist "lib\data\repositories\base\unified_repository_interface.dart" git rm "lib\data\repositories\base\unified_repository_interface.dart"
if exist "lib\data\repositories\impl\task_repository_impl.dart" git rm "lib\data\repositories\impl\task_repository_impl.dart"

REM Domain - Calculation
if exist "lib\domain\services\calculation\list_calculation_service.dart" git rm "lib\domain\services\calculation\list_calculation_service.dart"
if exist "lib\domain\services\calculation\memoized_calculation_service.dart" git rm "lib\domain\services\calculation\memoized_calculation_service.dart"

REM Domain - Core
if exist "lib\domain\services\core\extensible_error_classification_service.dart" git rm "lib\domain\services\core\extensible_error_classification_service.dart"
if exist "lib\domain\services\core\interfaces\data_import_interface.dart" git rm "lib\domain\services\core\interfaces\data_import_interface.dart"

REM Domain - Insights
if exist "lib\domain\services\insights\list_insights_service.dart" git rm "lib\domain\services\insights\list_insights_service.dart"

REM Domain - Persistence
if exist "lib\domain\services\persistence\common\persistence_types.dart" git rm "lib\domain\services\persistence\common\persistence_types.dart"

REM Presentation - Pages services
if exist "lib\presentation\pages\duel\services\duel_ui_components_builder.dart" git rm "lib\presentation\pages\duel\services\duel_ui_components_builder.dart"
if exist "lib\presentation\pages\habits\components\habits_list_view.dart" git rm "lib\presentation\pages\habits\components\habits_list_view.dart"
if exist "lib\presentation\pages\habits\components\habits_page_header.dart" git rm "lib\presentation\pages\habits\components\habits_page_header.dart"
if exist "lib\presentation\pages\habits\components\habit_card_builder.dart" git rm "lib\presentation\pages\habits\components\habit_card_builder.dart"
if exist "lib\presentation\pages\habits\services\habit_action_handler.dart" git rm "lib\presentation\pages\habits\services\habit_action_handler.dart"
if exist "lib\presentation\pages\lists\services\lists_performance_monitor.dart" git rm "lib\presentation\pages\lists\services\lists_performance_monitor.dart"
if exist "lib\presentation\pages\lists\services\lists_repository_service.dart" git rm "lib\presentation\pages\lists\services\lists_repository_service.dart"
if exist "lib\presentation\pages\lists\services\lists_state_service.dart" git rm "lib\presentation\pages\lists\services\lists_state_service.dart"
if exist "lib\presentation\pages\lists\services\list_items_service.dart" git rm "lib\presentation\pages\lists\services\list_items_service.dart"

echo.
echo Suppression terminee!
echo.

git status --short
