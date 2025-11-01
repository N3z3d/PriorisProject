# Prioris - Classement ELO et Selection Aleatoire

## Principe du classement

- Le classement Prioris applique un systeme ELO unique a toutes les taches eligibles.
- Chaque duel 1v1 met a jour les scores des deux taches (gagnant contre perdant) via `UnifiedPrioritizationService.updateEloScoresFromDuel`.
- Un classement multi-cartes (mode "Classement") simule une serie de confrontations pairwise pour produire un ordre complet.
- Les vues UI (`PriorityDuelArena`, `PriorityDuelView`) consomment les scores deja ordonnes via `tasksSortedByEloProvider`.

## Couverture actuellement en place

| Cas | Fichier de test | Verifications principales |
| --- | --------------- | ------------------------- |
| Mise a jour ELO 1v1 (service unifie) | `test/domain/task/services/unified_prioritization_service_test.dart` | Le service delegue au repository `updateEloScores`, validations d'arguments incluses. |
| Mise a jour ELO cote repository / integration listes | `test/integration/duel_list_item_integration_test.dart` | Confirme que les listes derivees appellent `updateEloScoresFromDuel` et invalidation des providers. |
| Mise a jour ELO via l'UI (controller duel) | `test/presentation/pages/duel_page_prioritization_test.dart` | Verifie que `processWinner` est declenche et que le duel est recharge. |
| Maintien des scores lors d'edition | `test/presentation/pages/duel_page_task_edit_integration_test.dart` | Les actions d'edition conservent ou reappliquent les scores ELO. |
| Coherence metier (gains / pertes) | `test/extended_features_test.dart` section `updateEloScore` | Valide l'evolution des scores dans `Task.updateEloScore`. |

> Aucun test specifique n'est necessaire pour les modes 2 / 3 / 4 cartes : la logique ELO passe toujours par `updateEloScoresFromDuel`. Les tests de layout (`priority_duel_view_test.dart`) couvrent les arrangements multi-cartes.

## Selection aleatoire

- Implementation : `DuelService.selectRandom` (modes duel et classement).
- Tests dedies : `test/domain/task/services/task_elo_service_random_test.dart`
  - Gestion des listes vides (`null` ou exception).
  - Exclusion des taches completees.
  - Variabilite observee sur des appels successifs.
- Integration controller : `test/presentation/pages/duel/duel_controller_settings_test.dart` confirme le melange avant soumission en mode classement.

## Resilience reseau et cache de duel

- `ResilientTaskLoader` repartit le chargement, applique retries et fallback cache (`test/presentation/pages/duel/services/resilient_task_loader_test.dart`).
- `DuelController` capture `DuelLoadingException` pour remettre les messages d'erreur a zero des que des taches reviennent.

## Points clefs

- Les tests metiers couvrent les mises a jour ELO et la selection aleatoire independamment de l'UI.
- L'UI pilote ces services via `DuelService` et `DuelController`, verifies par des tests widget et integration.
- La verif de wording localise (dont les tooltips duel) est couverte par `test/l10n/app_localizations_fr_test.dart`.
