# TODO priorisé – prochaine itération

## 1. Stabilisation tests domaine/providers (ordre proposé)
1. `test/domain/services/navigation/list_resolution_service_test.dart` – vérifier le wiring des repositories injectés et la résolution offline/online.
2. `test/domain/services/insights/` (start avec `insights_aggregate_service_test.dart`) – aligner les mocks `SafeMockFactory` avec les nouvelles signatures async.
3. `test/domain/habit/services/habit_aggregate_refactoring_test.dart` – confirmer la cohérence des agrégats suite aux changements d’i18n.
4. Relancer `flutter test` global après chaque bloc et mettre à jour `flutter_test_full.log` (objectif: faire baisser les ~197 échecs restants).

## 2. i18n Habits + déduplication listes (post-tests verts)
- Extraire les chaînes restantes du pop-up Habits (`lib/presentation/pages/habits/...`) vers `lib/l10n/app_*.arb`, garantir les variations FR/EN.
- Refactor `lib/presentation/pages/lists/controllers/operations/lists_validation_service.dart` et `lib/presentation/pages/lists/controllers/lists_controller_slim.dart` pour supprimer les duplications signalées (objectif <50 lignes/méthode).
- Une fois ces refactors terminés, réactiver `test/architecture/fixed_architecture_validation_test.dart` (retirer le `@Skip`) et le faire passer.

## 3. Tooling & dépendances (à documenter une fois la base verte)
- **Option A – conserver analyzer 6.x** : pas de migration Hive immédiate, on reste compatible avec les `build_runner_core/build_resolvers` actuels. ⇒ Risque : rester bloqué sur un SDK plus ancien, mais aucun chantier majeur court terme.
- **Option B – migrer (générateur compatible ou changement de stockage)** : nécessite soit un fork build_runner compatible Hive, soit l’abandon de la génération Hive (passage à Drift/Sembast/Supabase only). ⇒ Gain : accès aux dernières versions analyzer/build_runner, perte : chantier lourd + QA complète.
- Décision actuelle : Option A (legacy). Préparer une ADR dès que la base de tests est verte expliquant l’effort estimé pour Option B et la stratégie de switchover.
- Dépendances candidates à l’upgrade une fois la stack stabilisée : `flutter_riverpod`, `flutter_dotenv`, `logger`, `intl`, `lints`. Ne rien upgrader avant la résolution Hive/analyzer.

## 4. Rituels à maintenir
- Chaque suite ciblée ⇒ `flutter test <path>` puis log résultat + compteur estimé dans `flutter_test_full.log`.
- Conserver les lots <200 lignes et commits atomiques (`feat|fix|test|chore: ...`).
- Mettre à jour `docs/RECAPE_EXECUTION.md` et ce fichier après chaque session afin de garder l’historique pour les prochaines personnes.
