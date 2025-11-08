# TODO priorisé — prochaine itération

## 1. Suites critiques restantes (08 nov · 14:00 — 149 rouges, 28 actifs)

### P0 - Tests fonctionnels qui s'exécutent mais échouent (~28)
- **`lists_controller_adaptive_test.dart`** (création/CRUD/items) : vérifier mocks repo cohérents, rollback idempotent.
- **`operation_queue_test.dart`** (priority) : valider tri par priorité descendante.
- **`url_state_service_test.dart`** (navigation) : resolve/fallback list ID.
- **Tests intégration** : `supabase_connection_test`, `auth_flow_integration_test` (setup env mocké).
- **Widgets** : `task_edit_workflow_test`, `accessible_loading_state_test`, `habit_progress_bar_test`.
- **Repository** : `supabase_custom_list_repository_test` (JSON conversion).

### P1 - Tests obsolètes (121 loading failures)
- **63 fichiers** déplacés dans `test/_obsolete/` (README explicatif).
- Besoin d'audit : rewrite vs delete définitif (dépend de la fonctionnalité toujours présente).

### P2 - Skips TDD-RED intentionnels (~26)
- `test/architecture/controller_lifecycle_test.dart`, `duplicate_id_conflicts_test.dart`, `rls_permission_test.dart` (futures features).

## 2. Campagne i18n Habits + dédup
- Extraire les chaînes restantes (Habits modals/pages) vers `lib/l10n/app_fr.arb` et `app_en.arb`. Vérifier pluralisation.
- Refactoriser `lib/presentation/pages/lists/controllers/operations/lists_validation_service.dart` et `lists_controller_slim.dart` (helpers privés, <50 lignes/méthode, zéro duplication).
- Ajouter/adapter les tests widget/unitaires couvrant FR/EN.

## 3. Architecture
- Réactiver `test/architecture/fixed_architecture_validation_test.dart` après i18n/dédup.
- Vérifier les dépendances de couches (providers → services → infra) et ajuster les modules interdits si nécessaire.

## 4. Tooling & dépendances
- **Option A** maintenue : analyzer 6.x + toolchain legacy tant que Hive/build_runner n’ont pas d’alternative.
- Préparer l’ADR Option B (migration générateur/Hive ou switch vers autre stockage) une fois la base 100% verte.
- Dépendances candidates à l’upgrade après ADR : `flutter_riverpod`, `flutter_dotenv`, `logger`, `intl`, `lints`, packages `build_runner*`.
- **Rappel UI** : ne plus utiliser `Color.shadeXXX`; préférer les helpers `tone/lighten/darken` ou fournir une logique locale équivalente (voir `ui_color_utils.dart`).

## 5. Rituels
- Lots <200 lignes + commits `feat|fix|refactor|test|chore(scope): …`.
- TDD systématique, journal `flutter_test_full.log` à jour (horodatage + compteur).
- Rafraîchir `docs/RECAPE_EXECUTION.md` et ce fichier à chaque session pour briefer les prochaines personnes.

- Relancer flutter test global pour identifier les blocs restants (~189).
- Enchaîner avec i18n Habits + dédup, puis réactiver fixed_architecture_validation_test.

