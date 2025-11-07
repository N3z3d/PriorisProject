# TODO priorisé — prochaine itération

## 1. Suites critiques restantes
- `test/application/services/**` (P0 Auth, persistence managers).
- `test/architecture/controller_lifecycle_test.dart`, `duplicate_id_conflicts_test.dart`, `rls_permission_test.dart` (skips à retirer).
- Tests widget/pages listes (ex. `test/presentation/pages/list_detail_page_*.dart`) pour valider la nouvelle i18n/dédup.

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

## 5. Rituels
- Lots <200 lignes + commits `feat|fix|refactor|test|chore(scope): …`.
- TDD systématique, journal `flutter_test_full.log` à jour (horodatage + compteur).
- Rafraîchir `docs/RECAPE_EXECUTION.md` et ce fichier à chaque session pour briefer les prochaines personnes.
