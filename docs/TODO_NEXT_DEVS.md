# TODO priorise — prochaine iteration

## 1. Suites domaine (ordre impose)
1. `test/domain/services/navigation/list_resolution_service_test.dart`  
   - Revalider le wiring offline/online et les repositories injectes.  
   - Ajouter des doubles coherents via `SafeMockFactory` si necessaire.
2. `test/domain/services/insights/` (dossier complet, commencer par `insights_aggregate_service_test.dart`)  
   - Mettre a jour les mocks (async/await), controler les agregations et invariants statistiques.
3. `test/domain/habit/services/habit_aggregate_refactoring_test.dart`  
   - Verifier la coherence des agrégats apres les travaux d'i18n et d'extraction de chaines.
4. Apres chaque lot : `flutter test <suite>` + entree dans `flutter_test_full.log` avec estimation des echecs restants.

## 2. i18n Habits + dedup (apres suites domaine vertes)
- Extraire les chaines restantes du formulaire Habits dans `lib/l10n/app_fr.arb` et `app_en.arb` (au moins FR/EN).  
- Refactoriser `lib/presentation/pages/lists/controllers/operations/lists_validation_service.dart` et `lists_controller_slim.dart` pour supprimer les duplications signalees (objectif <50 lignes par methode).  
- Reactiver `test/architecture/fixed_architecture_validation_test.dart` (retirer `@Skip`) et le remettre au vert une fois la duplication traitee.

## 3. Tooling et dependances
- **Option A (retenue pour l'instant)** : conserver analyzer 6.x et le tooling actuel (build_runner_core/build_resolvers legacy) tant que Hive n'a pas d'alternative. Minimiser les risques pendant la stabilisation.
- **Option B (a cadrer quand la base sera verte)** : migrer vers un generateur compatible (fork interne, suppression de la generation Hive ou changement de stockage). Implique un plan d'upgrade (CI + docs) et une validation complete.
- Depots en attente d'upgrade une fois la migration decidee : `flutter_riverpod`, `flutter_dotenv`, `logger`, `intl`, `lints`, packages build_runner associes.

## 4. Rituels obligatoires
- Petits lots (<200 lignes) + commits atomiques `feat|fix|test|chore(scope): ...`.
- Toujours lancer la suite cible avant/apres correctif (TDD), journaliser dans `flutter_test_full.log`.
- Mettre a jour `docs/RECAPE_EXECUTION.md` et ce fichier en fin de session pour briefer la prochaine personne.
