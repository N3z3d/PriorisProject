# Recap execution — 7 Nov 2025

## Contexte
- Base Flutter/Dart en stabilisation continue (Clean Code, SOLID, limite 200 lignes/lot).
- Lots A/B/C livrés : providers priorisés, overrides mémoire, journal/docs synchronisés.
- Nouvelle passe : sécuriser Insights + Habit Aggregate avant de rouvrir l'i18n Habits et la déduplication.

## Points clés (Lots A/B/C)
1. **Lot A – ListPrioritizationSettings**
   - Getter `ready` exposé, tests mis à jour pour attendre l'initialisation avant lecture/persistance.
   - Suite dédiée au vert (`flutter test test/data/providers/list_prioritization_settings_provider_test.dart`).
2. **Lot B – List Providers**
   - Overrides en mémoire généralisés + statistiques par défaut garanties (shape `global/byType`).
   - `list_providers_test.dart` repasse au vert.
3. **Lot C – Journal & documentation**
   - `flutter_test_full.log` enrichi après chaque suite ciblée (horodatage + compteur estimé).
   - `docs/RECAPE_EXECUTION.md` et `docs/TODO_NEXT_DEVS.md` maintiennent la feuille de route active.


## Pass URL State
- Tests navigation (`test/domain/services/navigation/url_state_service_test.dart`) consomment désormais directement `urlStateServiceProvider` (plus de couche manager).
- Overrides mémoire conservés (`createTestProviderContainer`), égalité/idempotence vérifiées via le service.
- Suite verte : `flutter test test/domain/services/navigation/url_state_service_test.dart` (21:20), journal mis à jour.


## Pass Insights + Habit
1. **Service Insights**
   - Chaînes moteur converties en ASCII + `\uXXXX`; helpers `_plural/_tasksCount/_daysCount` introduits pour éviter la duplication.
   - Nouvelles règles : erreur >10 tâches (`"15 t\u00E2ches en attente"`), vide (`"Aucune liste \u00E0 analyser"`), succès (`"Bon rythme de livraison"`), warning (`"Productivit\u00E9 basse"`), backlog (`"R\u00E9duisez le backlog"`), streaks `"S\u00E9rie de ${_daysCount(n)}"`, premiers pas `"Premi\u00E8res habitudes en cours"`.
   - Suite `flutter test test/domain/services/insights/insights_generation_service_test.dart` au vert.
2. **HabitAggregate**
   - Alias `HabitEvent = DomainEvent`, getter `domainEvents` réexposé via `EventPublisher`, garde-fou `InvalidHabitRecordException` pour les booléens sur habitudes quantitatives.
   - Tests référencés (`habit_aggregate_refactoring_test.dart`) au vert.
3. **Run global**
   - `flutter test` complet relancé (21:07). Run réussi, compteur estimé ≈194 suites toujours rouges (voir `flutter_test_full.log`).

## Journal (extraits)
- `[2025-11-07 19:48]` list_prioritization_settings_provider_test ✅ – reste ~197.
- `[2025-11-07 19:51]` list_providers_test ✅ – reste ~197.
- `[2025-11-07 21:05]` insights_generation_service_test ✅ – reste ~195.
- `[2025-11-07 21:06]` habit_aggregate_refactoring_test ✅ – reste ~194.
- `[2025-11-07 21:15]` flutter test (global) ✅ – baseline actualisée, reste ~194.

## Tests exécutés
- `flutter test test/data/providers/list_prioritization_settings_provider_test.dart`
- `flutter test test/data/providers/list_providers_test.dart`
- `flutter test test/domain/services/insights/insights_generation_service_test.dart`
- `flutter test test/domain/habit/services/habit_aggregate_refactoring_test.dart`
- `flutter test`

## Décisions tooling
- **Option A (retenue)** : rester sur analyzer 6.x / toolchain legacy tant que Hive/build_runner n'ont pas d'alternative compatible.
- **Option B (post-stabilisation)** : migration générateur/Hive (fork interne, changement de moteur, ou arrêt de la génération). À documenter via ADR une fois la base totalement verte.
