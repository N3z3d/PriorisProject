# PLAN D'ACTION DÉTAILLÉ - PHASE 1
## Nettoyage du code mort (2 semaines)

---

## Vue d'ensemble

**Objectif:** Supprimer 76 fichiers de code mort et nettoyer les classes inutilisées
**Durée:** 2 semaines (40h)
**Score cible:** Passer de 75% à 82% de conformité

---

## Semaine 1 - Suppression fichiers critiques

### Jour 1-2: Préparation et validation (8h)

**Tasks:**
- [ ] Créer branche `refactor/phase1-cleanup-dead-code`
- [ ] Backup du projet actuel
- [ ] Exécuter tous les tests pour établir baseline
  ```bash
  flutter test > test_results_before.txt
  ```
- [ ] Vérifier que l'app compile et fonctionne
  ```bash
  flutter build --debug
  flutter run
  ```
- [ ] Documenter les résultats baseline

**Livrables:**
- Branche créée
- Baseline des tests (avant refactoring)
- Validation que tout fonctionne actuellement

---

### Jour 3: Lot 1 - Domain Layer (4h)

**Fichiers à supprimer (17 fichiers):**

```bash
# Créer un script de suppression
cat > delete_batch_1.sh << 'EOF'
#!/bin/bash

# Domain Layer - Code mort
rm lib/application/list_management/commands/create_list_command.dart
rm lib/domain/core/bounded_context.dart
rm lib/domain/core/events/event_bus.dart
rm lib/domain/habit/services/habit_analytics_service.dart
rm lib/domain/habit/specifications/habit_specifications.dart
rm lib/domain/list/services/list_optimization_service.dart
rm lib/domain/list/specifications/list_specifications.dart
rm lib/domain/list_management/value_objects/list_value_objects.dart
rm lib/domain/models/builders/list_item_builder.dart
rm lib/domain/services/calculation/list_calculation_service.dart
rm lib/domain/services/calculation/memoized_calculation_service.dart
rm lib/domain/services/core/extensible_error_classification_service.dart
rm lib/domain/services/insights/list_insights_service.dart
rm lib/domain/services/navigation/navigation_error_handler.dart
rm lib/domain/services/core/interfaces/data_import_interface.dart
rm lib/domain/services/persistence/common/persistence_types.dart

echo "Lot 1 complete: 16 fichiers domain layer supprimés"
EOF

chmod +x delete_batch_1.sh
./delete_batch_1.sh
```

**Validation:**
- [ ] Exécuter `flutter analyze`
- [ ] Exécuter `flutter test`
- [ ] Vérifier qu'aucune régression
- [ ] Commit: `refactor: Remove domain layer dead code (16 files)`

---

### Jour 4: Lot 2 - Data & Infrastructure (4h)

**Fichiers à supprimer (4 fichiers):**

```bash
cat > delete_batch_2.sh << 'EOF'
#!/bin/bash

# Data Layer
rm lib/data/repositories/paginated_repository.dart
rm lib/data/repositories/base/unified_repository_interface.dart
rm lib/data/repositories/impl/task_repository_impl.dart

# Infrastructure
rm lib/infrastructure/persistence/indexed_hive_repository.dart

echo "Lot 2 complete: 4 fichiers data/infra supprimés"
EOF

chmod +x delete_batch_2.sh
./delete_batch_2.sh
```

**Validation:**
- [ ] Exécuter `flutter analyze`
- [ ] Exécuter `flutter test`
- [ ] Vérifier compilation
- [ ] Commit: `refactor: Remove data/infrastructure dead code (4 files)`

---

### Jour 5: Lot 3 - Animations widgets (4h)

**Fichiers à supprimer (11 fichiers):**

```bash
cat > delete_batch_3.sh << 'EOF'
#!/bin/bash

# Animations
rm lib/presentation/animations/physics.dart
rm lib/presentation/animations/staggered_animations.dart
rm lib/presentation/animations/widgets/bounce_widget.dart
rm lib/presentation/animations/widgets/hoverable_widget.dart
rm lib/presentation/animations/widgets/pressable_widget.dart
rm lib/presentation/animations/widgets/shimmer_widget.dart
rm lib/presentation/animations/widgets/staggered_entrance_widget.dart
rm lib/presentation/animations/systems/celebrations/floating_hearts_widget.dart
rm lib/presentation/animations/systems/celebrations/gentle_rain_widget.dart
rm lib/presentation/animations/systems/celebrations/ripple_effect_widget.dart

echo "Lot 3 complete: 10 fichiers animations supprimés"
EOF

chmod +x delete_batch_3.sh
./delete_batch_3.sh
```

**Validation:**
- [ ] Tests UI passent
- [ ] Animations existantes fonctionnent toujours
- [ ] Commit: `refactor: Remove unused animation widgets (10 files)`

---

## Semaine 2 - Nettoyage présentation et classes

### Jour 6-7: Lot 4 - Pages & Services (8h)

**Fichiers à supprimer (14 fichiers):**

```bash
cat > delete_batch_4.sh << 'EOF'
#!/bin/bash

# Controllers
rm lib/presentation/controllers/base/base_controller.dart

# Duel page widgets
rm lib/presentation/pages/duel/services/duel_ui_components_builder.dart
rm lib/presentation/pages/duel/widgets/duel_header_widget.dart
rm lib/presentation/pages/duel/widgets/vs_separator_widget.dart

# Habits components
rm lib/presentation/pages/habits/components/habits_list_view.dart
rm lib/presentation/pages/habits/components/habits_page_header.dart
rm lib/presentation/pages/habits/components/habit_card_builder.dart
rm lib/presentation/pages/habits/services/habit_action_handler.dart

# Lists services/widgets
rm lib/presentation/pages/lists/services/lists_performance_monitor.dart
rm lib/presentation/pages/lists/services/lists_repository_service.dart
rm lib/presentation/pages/lists/services/lists_state_service.dart
rm lib/presentation/pages/lists/services/list_items_service.dart
rm lib/presentation/pages/lists/widgets/list_filters_widget.dart
rm lib/presentation/pages/lists/widgets/list_filter_widget.dart
rm lib/presentation/pages/lists/widgets/list_integration_summary.dart

echo "Lot 4 complete: 15 fichiers pages/services supprimés"
EOF

chmod +x delete_batch_4.sh
./delete_batch_4.sh
```

**Validation:**
- [ ] Tests des pages principales
- [ ] Navigation fonctionne
- [ ] Commit: `refactor: Remove unused page components (15 files)`

---

### Jour 8: Lot 5 - Theme & Widgets (4h)

**Fichiers à supprimer (5 fichiers):**

```bash
cat > delete_batch_5.sh << 'EOF'
#!/bin/bash

# Mixins & Theme
rm lib/presentation/mixins/text_controller_mixin.dart
rm lib/presentation/theme/elevation_system.dart
rm lib/presentation/theme/refactored_glassmorphism_system.dart
rm lib/presentation/widgets/advanced_loading_widget.dart
rm lib/presentation/services/haptic/haptic_wrapper_widget.dart

echo "Lot 5 complete: 5 fichiers theme/widgets supprimés"
EOF

chmod +x delete_batch_5.sh
./delete_batch_5.sh
```

**Validation:**
- [ ] Theme fonctionne correctement
- [ ] Widgets s'affichent normalement
- [ ] Commit: `refactor: Remove unused theme/widget files (5 files)`

---

### Jour 9: Nettoyage des exports et imports (4h)

**Tasks:**
- [ ] Chercher tous les fichiers `export.dart`
  ```bash
  find lib -name "export.dart" -o -name "exports.dart"
  ```
- [ ] Pour chaque export file, retirer les références aux fichiers supprimés
- [ ] Nettoyer les imports inutiles dans tout le projet
  ```bash
  # Utiliser un outil comme dart fix
  dart fix --dry-run
  dart fix --apply
  ```

**Validation:**
- [ ] Aucun import cassé
- [ ] `flutter analyze` propre
- [ ] Commit: `refactor: Clean up exports and imports`

---

### Jour 10: Tests finaux et validation (4h)

**Tasks:**
- [ ] Exécuter suite complète de tests
  ```bash
  flutter test > test_results_after.txt
  ```
- [ ] Comparer avant/après
  ```bash
  diff test_results_before.txt test_results_after.txt
  ```
- [ ] Tests d'intégration manuels
  - [ ] Lancer l'app
  - [ ] Tester chaque page principale
  - [ ] Vérifier navigation
  - [ ] Tester CRUD opérations

- [ ] Mesurer les gains
  ```bash
  # Compter lignes de code avant/après
  find lib -name "*.dart" | xargs wc -l > lines_count_after.txt
  ```

- [ ] Documenter les résultats dans un rapport

---

## Checklist de fin de Phase 1

### Tests
- [ ] Tous les tests passent (100%)
- [ ] Aucune régression détectée
- [ ] Couverture maintenue ou améliorée

### Code Quality
- [ ] `flutter analyze` = 0 erreurs
- [ ] `dart format` appliqué
- [ ] Aucun import cassé

### Documentation
- [ ] Rapport de suppression créé
- [ ] Changelog mis à jour
- [ ] Metrics documentées (lignes supprimées, gains)

### Git
- [ ] Tous les commits bien formatés
- [ ] Branche pushée
- [ ] Pull Request créée avec description détaillée
- [ ] Review demandée

---

## Métriques à mesurer

**Avant Phase 1:**
- Total fichiers lib/: 465
- Total lignes: ~150,000
- Code mort: 76 fichiers (10.6%)
- Score conformité: 75%

**Après Phase 1 (cibles):**
- Total fichiers lib/: ~389 (-76)
- Total lignes: ~142,000 (-8,000)
- Code mort: 0 fichiers
- Score conformité: 82% (+7%)

---

## Risques et mitigation

| Risque | Mitigation |
|--------|------------|
| Fichier "mort" encore référencé | Grep exhaustif avant suppression |
| Tests cassés | Suite de tests après chaque lot |
| Imports circulaires révélés | Analyse statique continue |
| Perte de fonctionnalités | Tests manuels de l'app |

---

## Critères de succès

✅ **Phase 1 réussie si:**
1. 76 fichiers de code mort supprimés
2. 0 régression de tests
3. App compile et fonctionne
4. Score conformité >= 82%
5. PR mergée et validée

---

## Prochaine étape

Une fois Phase 1 terminée → **Phase 2: Découpage fichiers critiques**
- Focus sur les 22 fichiers >500 lignes
- Commencer par les mocks générés
- Puis fichiers de localisation
- Ensuite fichiers métier critiques
