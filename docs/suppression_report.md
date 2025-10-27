# Rapport de suppression contrôlée — 2025-10-19

| Fichier | Raison | Références | Décision |
| --- | --- | --- | --- |
| `test/integration/solid_refactoring_integration_test.dart` | Test hérité qui importe des modules supprimés (`ListsDependencyContainer`, `PersistenceStrategyFactory`, etc.), donc compilation impossible. | `Test-Path lib\core\di\lists_dependency_container.dart` → False ; `rg "ListsDependencyContainer"` (uniquement ce test). | Supprimer |
| `test/presentation/pages/lists/controllers/consolidated/unified_lists_controller_validation_test.dart` | Test lié à l'ancien contrôleur consolidé, dossier `presentation/pages/lists/controllers/consolidated` supprimé. | `Test-Path lib\presentation\pages\lists\controllers\consolidated` → False ; `rg "UnifiedListsController"` (uniquement ce test). | Supprimer |
| `test/presentation/controllers/refactored_lists_controller_test.mocks.dart` | Fichier de mocks généré, plus aucun test ne l'importe ni n'utilise les symboles. | `rg "refactored_lists_controller_test.mocks.dart"` (aucun résultat) ; `rg "MockListsOrchestrator"` (uniquement ce fichier). | Supprimer |
| `.dart_tool/` | Artefact Flutter/Dart généré automatiquement. | `.gitignore:27` contient `.dart_tool/`. | Supprimer |
| `build/` | Sortie de compilation Flutter, régénérable. | `.gitignore:33` contient `/build/`. | Supprimer |
| `coverage/lcov.info` | Rapport de couverture généré. | `.gitignore:82` contient `coverage/`. | Supprimer |
| `logs/prioris.log` | Fichier de logs runtime volumineux, non utilisé par le code. | `rg "logs/prioris.log"` → uniquement `compliance_table.md` (statut NOK). | Supprimer |
| `.flutter-plugins-dependencies` | Liste des plugins générée par Flutter, régénérable. | `.gitignore:29` contient `.flutter-plugins-dependencies`. | Supprimer |

| `tests/` | Dossier doublon vide, aucun test ne l'utilise. | 'Get-ChildItem tests' (vide) ; 'rg "tests/" -g "*.dart"' (aucune occurrence). | Supprimer |
| `test/temp_habits_ui/habits.hive`, `test/temp_habits_ui/habits.lock`, `test/temp_habits_ui/tasks.hive`, `test/temp_habits_ui/tasks.lock` | Artefacts Hive de prototypage non utilises par les tests actuels. | 'rg "temp_habits_ui"' (uniquement `compliance_table.md`) ; aucun test ne reference ces fichiers. | Supprimer |
