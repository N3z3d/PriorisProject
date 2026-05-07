# Story 8.9 : Corriger les casts `(value as double)` latents dans services domaine et présentation

Status: backlog

## Contexte

Story 8.5 a corrigé 4 occurrences de `(value as double)` dans `Habit` (entité principale).
La revue de code a identifié **11 occurrences restantes** dans d'autres fichiers — même cause,
même `CastError` latent quand Supabase retourne un entier JSON pour une colonne `double precision`.

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

## Référence

- Découvert lors de la revue de code story 8.5 (2026-05-07)
- `_bmad-output/implementation-artifacts/deferred-work.md` — section "Deferred from: code review of 8-5..."
