# Story 8.9 : Corriger les casts `(value as double)` latents dans services domaine et présentation

Status: done

## Contexte

Story 8.5 a corrigé 4 occurrences de `(value as double)` dans `Habit` (entité principale).
La revue de code a identifié **11 occurrences restantes** dans d'autres fichiers — même cause,
même `CastError` latent quand Supabase retourne un entier JSON pour une colonne `double precision`.

## Hypothèses et arbitrages

- Source fonctionnelle principale : `_bmad-output/implementation-artifacts/deferred-work.md`, section "Deferred from: code review of 8-5".
- `epic-8.md` ne contient pas 8.7, 8.8 ni 8.9 ; ne pas l'utiliser comme source exhaustive pour cette story.
- Le correctif doit rester chirurgical : conversions `int|double -> double` uniquement, sans refonte de modèles, providers ou widgets.
- Ne pas traiter les autres `as double` hors scope (`eloScore`, cache, stats widgets, `list_item.g.dart`, `task.g.dart`) sauf si un test de 8.9 prouve un lien direct.

## Story

En tant que développeur,
je veux corriger tous les casts `(value as double)` restants dans les services domaine, la présentation et l'adaptateur Hive,
afin qu'aucune `CastError` ne puisse crasher l'app sur des données Supabase légitimes.

## Acceptance Criteria

1. Les 7 occurrences dans les services domaine utilisent `(value as num).toDouble()` — aucun `CastError` possible
2. L'adaptateur Hive `habit.g.dart:25` utilise `(fields[5] as num?)?.toDouble()` — path désérialisation Hive couvert
3. Les 3 occurrences dans la couche présentation (`habit_card.dart`, `habit_progress_bar.dart`, `habit_record_dialog.dart`) utilisent `(todayValue as num?)?.toDouble()` — plus de silent null (affichage 0% parasite)
4. `flutter analyze --no-pub` propre sur tous les fichiers modifiés
5. `flutter test --exclude-tags integration --no-pub` : 0 régression

## Tasks / Subtasks

- [x] **T0 — Test rouge minimal avant production** (AC: 1, 2, 3)
  - [x] T0.1 Ajouter des assertions qui échouent avec l'état actuel pour completions quantitatives `int` dans `HabitCompletionService`, `HabitStreakCalculator`, `HabitProgressCalculator`, `HabitPatternAnalyzer`, `HabitConsistencyCalculator` et `ProgressCalculationService`.
  - [x] T0.2 Ajouter un test provider pour `minProgress` et `maxProgress` avec valeur `int`.
  - [x] T0.3 Ajouter un test Hive adapter qui lit `targetValue` entier via `HabitAdapter.read`.
  - [x] T0.4 Ajouter/mettre à jour tests widgets pour `HabitProgressBar`, `HabitRecordDialog` et, si possible sans test fragile, `HabitCard` avec `todayValue: 5`.

- [x] **T1 — Corriger les services domaine et provider data** (AC: 1)
  - [x] T1.1 Remplacer les casts des completions quantitatives par `(value as num).toDouble()` dans les 6 services domaine listés.
  - [x] T1.2 Remplacer les casts de filtre avancé dans `list_providers.dart` par `(value as num).toDouble()` pour `minProgress` et `maxProgress`.
  - [x] T1.3 Ne pas ajouter d'import dans `lib/domain/`; les changements doivent rester Dart pur.

- [x] **T2 — Corriger le chemin Hive** (AC: 2)
  - [x] T2.1 Modifier manuellement `habit.g.dart` : `targetValue: (fields[5] as num?)?.toDouble()`.
  - [x] T2.2 Ne pas relancer `build_runner` dans cette story sauf nécessité explicitement justifiée ; le générateur réécrirait le fichier.

- [x] **T3 — Corriger les widgets de présentation** (AC: 3)
  - [x] T3.1 `habit_card.dart` : convertir `widget.todayValue` via `(widget.todayValue as num?)?.toDouble() ?? 0.0`.
  - [x] T3.2 `habit_progress_bar.dart` : appliquer le même pattern dans `_getProgressValue` et `_statusText`.
  - [x] T3.3 `habit_record_dialog.dart` : préremplir le champ via `(widget.currentValue as num?)?.toDouble().toString() ?? ''` (sans `?.` avant `toString` car `toDouble()` est non-nullable).

- [x] **T4 — Validation Green puis Refactor** (AC: 4, 5)
  - [x] T4.1 Lancer les tests ciblés ajoutés/modifiés.
  - [x] T4.2 Lancer `puro flutter analyze --no-pub`.
  - [x] T4.3 Lancer `puro flutter test --exclude-tags integration --no-pub`.
  - [x] T4.4 Refactor uniquement si duplication réelle dans les lignes touchées ; ne pas introduire helper global spéculatif.

### Review Findings

- [x] [Review][Patch] Aucun test pour le cast fix de `habit_card.dart:91` — `_getProgressValue()` non couvert par un test widget [lib/presentation/widgets/cards/habit_card.dart:91]
- [x] [Review][Patch] Tests `minProgress`/`maxProgress` vérifient seulement l'absence de crash (`returnsNormally`) sans asserter le résultat filtré [test/data/providers/list_providers_test.dart]
- [x] [Review][Patch] `habit_adapter_int_cast_test.dart` teste le pattern de cast en isolation (dynamic variable) et non via `HabitAdapter.read()` — si `build_runner` régénère le fichier, ce test continuerait à passer [test/domain/models/core/entities/habit_adapter_int_cast_test.dart]
- [x] [Review][Defer] Valeur `bool` dans completions d'une habitude quantitative déclenche `TypeError` sur `(value as num)` — mêmes 6 services domaine [lib/domain/habit/services/] — deferred, pre-existing
- [x] [Review][Defer] `task.g.dart` et `list_item.g.dart` utilisent encore `as double` pour `eloScore` dans l'adapter Hive — même classe de bug que le fix 8.9 [lib/domain/models/core/entities/task.g.dart, list_item.g.dart] — deferred, pre-existing, hors scope
- [x] [Review][Defer] `elo_score.dart`, `priority.dart`, `list_item.dart` utilisent `as double` sur les champs JSON — `CastError` latent si Supabase retourne un int [lib/domain/core/value_objects/, lib/domain/list/value_objects/] — deferred, pre-existing, hors scope
- [x] [Review][Defer] `premium_habit_card.dart` utilise `widget.todayValue as num` (non-nullable) sans guard pour `bool` — crash si habitude binary → quantitative sans migration [lib/presentation/widgets/cards/premium_habit_card.dart:173] — deferred, pre-existing
- [x] [Review][Defer] `minItems`/`maxItems` dans `_applyAdvancedFilter` utilisent encore `as int` — `TypeError` si une valeur `double` ou `String` est passée [lib/data/providers/list_providers.dart:233-235] — deferred, pre-existing, hors scope
- [x] [Review][Defer] `_statusText` affiche `"5.0 / 10.0 "` (espace trailing) si `unit` est null et `"0.0 / 0.0 "` si `targetValue` est null [lib/presentation/widgets/progress/habit_progress_bar.dart:107] — deferred, pre-existing
- [x] [Review][Defer] `habit_recommendation_engine.dart` utilise `value is double` — les valeurs `int` Supabase sont silencieusement exclues du calcul de moyenne [lib/domain/habit/services/analytics/habit_recommendation_engine.dart:163] — deferred, pre-existing, hors scope
- [x] [Review][Defer] Valeur `String` dans les completions (round-trip JSONB) déclenche `TypeError` sur `(value as num).toDouble()` — non testé, hors scope [lib/domain/habit/services/] — deferred, pre-existing
- [x] [Review][Defer] `double.nan` comme valeur de completion passe le cast silencieusement et sous-compte les séries ; pré-remplit le dialog avec `"NaN"` [habit_record_dialog.dart:34, services] — deferred, pre-existing

## Fichiers à modifier

### Services domaine — CRITICAL (CastError = crash runtime)

| Fichier | Ligne | Méthode |
|---|---|---|
| `lib/domain/habit/services/habit_streak_calculator.dart` | 147 | `_isSuccessfulCompletion()` |
| `lib/domain/habit/services/habit_progress_calculator.dart` | 111 | `_isSuccessfulCompletion()` |
| `lib/domain/habit/services/habit_completion_service.dart` | 113 | inline comparison |
| `lib/domain/habit/services/analytics/habit_pattern_analyzer.dart` | 89 | inline comparison |
| `lib/domain/habit/services/analytics/habit_consistency_calculator.dart` | 72 | inline comparison |
| `lib/domain/services/calculation/progress_calculation_service.dart` | 310 | `_calculateHabitProgress()` |
| `lib/data/providers/list_providers.dart` | 229-231 | filter lambda |

### Adaptateur Hive — HIGH (crash au démarrage si box corrompue)

| Fichier | Ligne | Champ |
|---|---|---|
| `lib/domain/models/core/entities/habit.g.dart` | 25 | `targetValue: fields[5] as double?` |

### Présentation — HIGH (silent null → affichage 0% parasite, pas de crash)

| Fichier | Ligne | Pattern |
|---|---|---|
| `lib/presentation/widgets/cards/habit_card.dart` | 91 | `widget.todayValue as double? ?? 0.0` |
| `lib/presentation/widgets/progress/habit_progress_bar.dart` | 88, 104 | `todayValue as double? ?? 0.0` |
| `lib/presentation/widgets/dialogs/habit_record_dialog.dart` | 34 | `widget.currentValue as double?` |

## Fix type par type

### Services domaine
```dart
// AVANT
(value as double) >= targetValue!
// APRÈS
(value as num).toDouble() >= targetValue!
```

### Hive adapter (édition manuelle — fichier généré)
```dart
// AVANT
targetValue: fields[5] as double?,
// APRÈS
targetValue: (fields[5] as num?)?.toDouble(),
```

### Présentation — silent null
```dart
// AVANT
final currentValue = todayValue as double? ?? 0.0;
// APRÈS
final currentValue = (todayValue as num?)?.toDouble() ?? 0.0;
```

## Précautions

- `habit.g.dart` est généré par `build_runner` — le modifier manuellement et ne **pas** relancer `build_runner` sans adapter le modèle source d'abord.
- `lib/domain/` — imports interdits : ne pas importer `supabase_flutter`, `hive`, `flutter`. Les fixes sont Dart pur.
- Tester en priorité les services domaine (T1) avant la présentation (T3).

## Dev Notes

### État actuel des fichiers UPDATE

- `habit_streak_calculator.dart`, `habit_progress_calculator.dart`, `habit_completion_service.dart` : même logique que `Habit` avant 8.5, avec comparaison quantitative `value >= targetValue`. Le comportement binaire `value == true` doit rester inchangé.
- `habit_pattern_analyzer.dart` et `habit_consistency_calculator.dart` lisent `HabitAggregate.completions` et classent une journée quantitative comme complétée si la valeur atteint `targetValue`. Les calculs de tendance/consistance ne doivent pas être modifiés.
- `progress_calculation_service.dart` mélange progression habitudes/tâches pour les graphiques ; ne toucher que `_calculateHabitProgress`.
- `list_providers.dart` filtre les listes via `advancedFilters`. `minItems`, `maxItems`, `isCompleted`, recherche, tri et statistiques sont hors scope.
- `habit.g.dart` est un adapter Hive généré. Le changement doit être limité au champ `targetValue`; ne pas modifier `typeId`, ordre des champs ou `write`.
- `habit_card.dart`, `habit_progress_bar.dart`, `habit_record_dialog.dart` reçoivent `todayValue/currentValue` en `dynamic`. Une valeur `int` ne doit plus devenir `0.0` ou champ vide.

### Patterns à reprendre de 8.5

- Pattern validé : `(value as num).toDouble()` pour les valeurs obligatoires déjà null-checkées.
- Pattern validé : `(json['target_value'] as num?)?.toDouble()` pour les valeurs optionnelles ; l'équivalent Hive attendu est `(fields[5] as num?)?.toDouble()`.
- Tests déjà ajoutés en 8.5 : `test/domain/models/core/entities/habit_completion_test.dart` couvre `Habit` avec completions `int`; 8.9 doit couvrir les services et widgets restants, pas dupliquer ces assertions.

### Tests recommandés

- `test/domain/habit/services/habit_aggregate_refactoring_test.dart` : ajouter cas `int` dans les groupes `HabitCompletionService`, `HabitStreakCalculator`, `HabitProgressCalculator`.
- Nouveau fichier ciblé possible : `test/domain/habit/services/habit_analytics_int_cast_test.dart` pour `HabitPatternAnalyzer` et `HabitConsistencyCalculator`.
- `test/domain/services/calculation/progress_calculation_service_test.dart` : ajouter un cas quantitatif `completions[dateKey] = 5` et vérifier une progression non nulle.
- `test/data/providers/list_providers_test.dart` : charger des listes avec progression, appliquer `advancedFilters: {'minProgress': 50}` et `{'maxProgress': 50}` avec entiers.
- `test/presentation/widgets/progress/habit_progress_bar_test.dart` : ajouter `todayValue: 5` et attendre `5.0 / 10.0 units`.
- `test/presentation/widgets/dialogs/habit_record_dialog_test.dart` : ouvrir avec `currentValue: 5` et vérifier que le champ contient `5.0` ou `5` selon le format retenu.

### Architecture et limites

- Architecture cible : layered/hexagonale partielle. Le domaine ne doit pas dépendre de Flutter, Hive, Supabase, data, infrastructure ou présentation.
- SRP : ne changer que la normalisation numérique au point de lecture. OCP/DIP : ne pas ajouter de service ou d'abstraction pour 11 casts simples.
- Taille : les fichiers ciblés sont sous les seuils de 500 lignes/classe et 50 lignes/méthode ; si un ajout de test force une méthode longue, extraire localement dans le test.
- Pas de nouvelle dépendance. Les packages locaux restent ceux du lockfile (`flutter_riverpod 2.6.1`, `supabase_flutter 2.10.3`, `hive 2.2.3`, `hive_generator 2.0.1`, `build_runner 2.4.13`).
- Recherche officielle 2026-05-08 : `dart:convert` décode les nombres JSON en `num`; `num` couvre `int` et `double`; `num.toDouble()` est l'API Dart officielle pour convertir sans CastError. `supabase_flutter` et `flutter_riverpod` ont des versions plus récentes sur pub.dev, mais aucune mise à jour n'est requise ni autorisée pour cette story.

### Previous Story Intelligence — 8.8

- La story 8.8 a corrigé un flux UI sensible en gardant les changements localisés et en ajoutant des tests unitaires/widget ciblés avant validation globale.
- Le dernier review a insisté sur les chemins d'erreur et effets de bord non évidents ; pour 8.9, chaque cast corrigé doit avoir au moins un test qui échoue avant correction.
- Aucun lien fonctionnel direct avec l'import interrompu : ne pas toucher `ImportInterruptService`, `BulkAddDialog`, `ListDetailPage` ou `HomePage`.

### Git Intelligence

- `02c91ce fix(8.4+8.5)` a établi le pattern `as num).toDouble()` dans `Habit` et les tests unitaires/intégration associés ; 8.9 doit prolonger ce pattern sans inventer une autre normalisation.
- `b102414 chore(tracking)` a créé la première version de cette story et marqué le statut en backlog ; cette version complète le contexte et passe le suivi en `ready-for-dev`.
- `b1d20d5 feat(8.7+8.8)` montre le standard récent : tests ciblés, revue des edge cases, puis validation globale. Reprendre cette discipline pour chaque couche touchée.

## Références

- Découvert lors de la revue de code story 8.5 (2026-05-07)
- `_bmad-output/implementation-artifacts/deferred-work.md` — section "Deferred from: code review of 8-5..."
- `_bmad-output/implementation-artifacts/8-5-corriger-formule-calculateaverageperday-et-cast-int-double-supabase.md`
- `_bmad-output/implementation-artifacts/8-8-reprendre-import-interrompu-depuis-liste.md`
- `_bmad-output/planning-artifacts/architecture.md`
- `lib/domain/CLAUDE.md`
- Dart API `num.toDouble()` : https://api.dart.dev/dart-core/num/toDouble.html
- Dart API `jsonDecode` / `JsonDecoder` : https://api.dart.dev/dart-convert/jsonDecode.html
- pub.dev `supabase_flutter` : https://pub.dev/packages/supabase_flutter
- pub.dev `flutter_riverpod` : https://pub.dev/packages/flutter_riverpod

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- T0.3 : `PatternAnalysis` n'a pas `mostProductiveDay` ni `completionsByDay` — corrigé en utilisant les vrais getters `completionsByDayOfWeek` et `bestDays`.
- T3.3 : analyzer a signalé `invalid_null_aware_operator` sur `?.toString()` après `?.toDouble()` — corrigé en `.toString()` (non-nullable après `toDouble()`).
- `clean_code_constraints_test.dart` : 1 échec préexistant sur `list_detail_page.dart: 515 lignes` — non lié à 8.9, hors scope.
- `lists_filter_manager_test.dart` : flakyness de timing en suite complète — passe systématiquement seul.

### Completion Notes List

- Story context créé/complété le 2026-05-08 : statut `ready-for-dev`, contexte architecture/tests/latest tech ajouté.
- Implémenté le 2026-05-09/10 par claude-sonnet-4-6.
- 11 occurrences de `(value as double)` / `(fields[5] as double?)` corrigées : 6 services domaine, 1 provider data, 1 adapter Hive, 3 widgets présentation.
- Pattern uniforme appliqué : `(value as num).toDouble()` (obligatoire) et `(value as num?)?.toDouble()` (optionnel).
- 29 nouveaux tests ajoutés (services, analytics, progress calculation, providers, widgets, adapter) — tous verts.
- 0 import interdit introduit dans `lib/domain/`. 0 warning analyze sur les fichiers modifiés.
- Aucune abstraction spéculative ajoutée (SRP/OCP/DIP respectés, 11 corrections chirurgicales).

### File List

- `lib/domain/habit/services/habit_streak_calculator.dart` (modifié)
- `lib/domain/habit/services/habit_progress_calculator.dart` (modifié)
- `lib/domain/habit/services/habit_completion_service.dart` (modifié)
- `lib/domain/habit/services/analytics/habit_pattern_analyzer.dart` (modifié)
- `lib/domain/habit/services/analytics/habit_consistency_calculator.dart` (modifié)
- `lib/domain/services/calculation/progress_calculation_service.dart` (modifié)
- `lib/data/providers/list_providers.dart` (modifié)
- `lib/domain/models/core/entities/habit.g.dart` (modifié — édition manuelle du fichier généré)
- `lib/presentation/widgets/cards/habit_card.dart` (modifié)
- `lib/presentation/widgets/progress/habit_progress_bar.dart` (modifié)
- `lib/presentation/widgets/dialogs/habit_record_dialog.dart` (modifié)
- `test/domain/habit/services/habit_aggregate_refactoring_test.dart` (modifié — ajout groupes int cast)
- `test/domain/habit/services/habit_analytics_int_cast_test.dart` (nouveau)
- `test/domain/services/calculation/progress_calculation_service_test.dart` (modifié — ajout groupe int cast)
- `test/data/providers/list_providers_test.dart` (modifié — ajout groupe Advanced Filters int cast)
- `test/presentation/widgets/progress/habit_progress_bar_test.dart` (modifié — ajout 2 tests int cast)
- `test/presentation/widgets/dialogs/habit_record_dialog_test.dart` (modifié — ajout test int cast)
- `test/domain/models/core/entities/habit_adapter_int_cast_test.dart` (nouveau)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modifié — statut `review`)
