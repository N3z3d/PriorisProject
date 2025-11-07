# TODO priorisé — prochaine itération

## 1. Suites critiques restantes (ordre suggéré)
1. `test/domain/services/navigation/url_state_service_test.dart`
   - Rejouer les scénarios offline/online en s'appuyant sur le `ListsController` réel + overrides mémoire.
   - Vérifier que les messages URL utilisent les nouvelles chaînes ASCII (`\uXXXX`).
2. `test/domain/services/insights/*` hors `insights_generation_service_test.dart`
   - Notamment `insights_aggregate_service_test.dart` et les agrégations statistiques.
   - Profiter des helpers `_plural/_tasksCount/_daysCount` pour éviter toute régression de format.
3. Suites applicatives P0 (`test/application/services/**`, `test/architecture/controller_lifecycle_test.dart`, etc.)
   - Continuer à désamorcer les historiques rouges en lots <200 lignes, journal à jour après chaque run.

## 2. i18n Habits + dédup (à lancer dès que 1. est vert)
- Extraire les chaînes restantes du formulaire Habits (`lib/presentation/pages/habits/**`) vers `lib/l10n/app_fr.arb` et `app_en.arb` (au moins FR/EN).
- Refactoriser `lib/presentation/pages/lists/controllers/operations/lists_validation_service.dart` et `lib/presentation/pages/lists/controllers/lists_controller_slim.dart` pour supprimer les duplications signalées (<50 lignes/méthode).
- Ajouter des tests widget/unitaires couvrant les clés traduites (FR/EN) et s'assurer que les helpers de validation sont factorisés.

## 3. Architecture
- Une fois la duplication nettoyée, réactiver `test/architecture/fixed_architecture_validation_test.dart` (retirer `@Skip`).
- Traiter également `test/architecture/duplicate_id_conflicts_test.dart` et `test/architecture/rls_permission_test.dart` si encore `@Skip`.
- Objectif : retrouver la couverture initiale des checks Clean Code / SOLID.

## 4. Tooling & dépendances
- **Option A (retenue)** : rester sur analyzer 6.x / toolchain legacy tant que Hive/build_runner n'ont pas d'alternative stable.
- **Option B (après stabilisation)** : préparer une ADR détaillant la migration (fork build_runner, changement de moteur de persistance ou arrêt de la génération Hive). Inclure l'impact CI/CD et les dépendances candidates (`flutter_riverpod`, `flutter_dotenv`, `logger`, `intl`, `lints`).

## 5. Rituels
- Petits lots (<200 lignes) + commits atomiques `feat|fix|test|chore(scope): …`.
- Toujours TDD : run ciblé avant/après correctif, mise à jour de `flutter_test_full.log` avec horodatage + compteur.
- Rafraîchir `docs/RECAPE_EXECUTION.md` et ce fichier à la fin de chaque session pour briefer les prochains devs.
