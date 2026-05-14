# Story 10.17 : Versionner les mocks et corriger la compatibilité Dart/CI

Status: ready-for-dev

## Story

En tant que développeur,
je veux que les tests Flutter passent en CI (GitHub Actions) avec 0 échec lié aux mocks ou à la version Dart,
afin que le gate CI de tests puisse être réactivé (story 11-2).

## Acceptance Criteria

1. `flutter test --exclude-tags integration` passe en CI (GitHub Actions, Flutter 3.32.8) sans erreur `language version X is too high`
2. Les fichiers `.mocks.dart` sont présents en CI sans nécessiter `build_runner` à chaque run
3. `puro flutter test --exclude-tags integration` → résultat identique en local et en CI
4. 0 régression de tests par rapport à l'état pré-story en local

## Tasks / Subtasks

- [ ] **T1 — Diagnostiquer la version Dart réelle de Flutter 3.32.8 en CI**
  - [ ] T1.1 — Ajouter temporairement un step `dart --version` dans ci.yml pour logger la version exacte
  - [ ] T1.2 — Comparer avec la version locale (`puro dart --version`)
  - [ ] T1.3 — Identifier quels packages ont une language version > Dart CI (test_api, matcher, etc.)

- [ ] **T2 — Fixer la version des packages de test si décalage**
  - [ ] T2.1 — Vérifier `pubspec.lock` : versions de `test`, `test_api`, `matcher`, `mockito`
  - [ ] T2.2 — Si packages trop récents pour CI-Dart : contraindre les versions dans `pubspec.yaml`
  - [ ] T2.3 — `puro flutter pub get` + vérifier que les tests passent localement

- [ ] **T3 — Versionner les fichiers .mocks.dart**
  - [ ] T3.1 — Vérifier que tous les `.mocks.dart` sont dans `.gitignore` (cause des 210 échecs CI)
  - [ ] T3.2 — Retirer les `.mocks.dart` du `.gitignore`
  - [ ] T3.3 — `puro flutter packages pub run build_runner build --delete-conflicting-outputs`
  - [ ] T3.4 — `git add test/**/*.mocks.dart` et committer

- [ ] **T4 — Retirer build_runner du ci.yml (devenu inutile)**
  - [ ] T4.1 — Supprimer le step `Generate mocks` de ci.yml

- [ ] **T5 — Validation CI**
  - [ ] T5.1 — Push → vérifier que le job `Test & Analysis` passe avec des tests qui passent
  - [ ] T5.2 — Compter les tests : doit être ≥ 2034 (état après story 10.1)

## Dev Notes

### Cause racine des 210 échecs CI

Deux causes indépendantes :

**Cause A — Mocks manquants** :
Les fichiers `.mocks.dart` (générés par `build_runner` + `mockito`) sont dans `.gitignore`. En CI, `build_runner` est lancé mais échoue à cause de Cause B → les mocks ne sont pas générés → 210 tests échouent immédiatement avec `No such file or directory`.

Solution : versionner les `.mocks.dart` (ils sont du code généré déterministe, safe à committer).

**Cause B — Version Dart incompatible** :
En CI, `flutter test` retourne :
```
Error: The language version 3.10 specified for the package 'test_api' is too high.
The highest supported language version is 3.8.
```

Cela indique que `subosito/flutter-action@v2` avec `flutter-version: '3.32.8'` installe un Dart 3.8, mais les packages `test_api`/`matcher` dans `pubspec.lock` nécessitent Dart 3.10. À investiguer : peut-être que puro Flutter 3.32.8 utilise un Dart différent (3.10+) que la version officielle 3.32.8 du channel stable.

### Fichiers .mocks.dart à committer

Vérifier lesquels existent localement et manquent en CI :
```
find test/ -name "*.mocks.dart" | sort
```

### Lien avec 11-2

Une fois cette story `done`, le gate `flutter test --exclude-tags integration` peut être réactivé comme bloquant dans `ci.yml` (story 11-2).

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List

### Change Log
