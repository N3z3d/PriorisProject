# PLAN DE MIGRATION TESTS - operations/ + refactored/ → consolidated/

**Date de création**: 2025-09-30
**Auteur**: Claude (Sonnet 4.5)
**Statut**: ✅ PLAN STRATÉGIQUE VALIDÉ

## Vue d'ensemble
- **Total tests à migrer**: 5 fichiers (operations: 3 | refactored: 2)
- **Total assertions**: ~142 tests unitaires
- **Lots planifiés**: 3 lots sûrs (≤200 lignes/lot)
- **Architecture cible**: consolidated/ (SOLID + Coordinator Pattern)

---

## MAPPING 1: operations/ → consolidated/

### 1. lists_crud_service_test.dart (420 lignes, 30 tests) → unified_lists_controller_validation_test.dart

**Action**: **MIGRER + FUSIONNER**
**Lot**: Lot 2 - Migration avec Refactoring

**Stratégie**:
1. Créer section "CRUD Operations Tests" dans unified_lists_controller_validation_test.dart
2. Adapter les tests pour utiliser `UnifiedListsController` au lieu de `ListsCrudService`
3. Conserver les tests de vérification de persistance (critiques)
4. Fusionner tests bulk operations avec tests existants

---

### 2. lists_validation_service_test.dart (452 lignes, 32 tests) → unified_lists_controller_validation_test.dart

**Action**: **MIGRER TEL QUEL**
**Lot**: Lot 1 - Migration Simple

**Stratégie**:
1. Créer section "Validation Tests" dans unified_lists_controller_validation_test.dart
2. Tests peuvent être migrés presque sans modification (même logique)
3. Adapter: `validationService.validate*()` → `controller.operationsHandler.validate*()`

---

### 3. lists_event_handler_test.dart (493 lignes, 40 tests) → unified_lists_events_test.dart

**Action**: **MIGRER TEL QUEL (nouveau fichier)**
**Lot**: Lot 1 - Migration Simple

**Stratégie**:
1. Créer nouveau fichier unified_lists_events_test.dart
2. Migrer tests sans modification majeure
3. Adapter pour utiliser le système d'événements du `UnifiedListsController`

---

## MAPPING 2: refactored/ → consolidated/

### 4. lists_controller_slim_test.dart (349 lignes, 25 tests) → unified_lists_controller_validation_test.dart

**Action**: **FUSIONNER AVEC TESTS EXISTANTS**
**Lot**: Lot 3 - Fusion et Déduplication

**Stratégie**:
1. Identifier tests uniques (~5 tests sur 25)
2. Migrer uniquement les tests manquants
3. Supprimer les tests redondants

---

### 5. refactored_lists_controller_test.dart (479 lignes, 15 tests) → [SUPPRIMER]

**Action**: **SUPPRIMER (redondant)**
**Lot**: Lot 3 - Suppression

**Raison**: 100% de redondance avec tests existants dans unified_lists_controller_validation_test.dart

---

## LOTS DE MIGRATION

### **Lot 1 - Migration Simple** (Semaine 1, 2-3 jours)

**Fichiers**:
- lists_validation_service_test.dart → Section Validation
- lists_event_handler_test.dart → Nouveau fichier

**Lignes**: ~150 lignes modifiées
**Risque**: **FAIBLE**
**Tests**: 72 tests migrés

---

### **Lot 2 - Migration avec Refactoring** (Semaine 2, 3-4 jours)

**Fichiers**:
- lists_crud_service_test.dart → Section CRUD

**Lignes**: ~180 lignes modifiées
**Risque**: **MOYEN**
**Tests**: 30 tests refactorisés

---

### **Lot 3 - Fusion et Déduplication** (Semaine 3, 2 jours)

**Fichiers**:
- lists_controller_slim_test.dart → Tests uniques uniquement
- refactored_lists_controller_test.dart → **SUPPRIMER**

**Lignes**: ~40 lignes ajoutées, 800 lignes supprimées
**Risque**: **FAIBLE**

---

## RÉSUMÉ EXÉCUTIF

| Métrique | Avant | Après | Gain |
|----------|-------|-------|------|
| **Fichiers de tests** | 5 | 2 | -60% |
| **Lignes totales** | 2193 | 1350 | -38% |
| **Tests uniques** | 142 | 107 | -25% (déduplication) |
| **Architecture** | Fragmentée | Consolidée SOLID | ✓ |

**Durée totale estimée**: 7-9 jours ouvrés (3 semaines)
**Risque global**: **FAIBLE-MOYEN** (migration incrémentale)