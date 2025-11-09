# Plan d'Action UX - Prioris v1.2.0
**Date**: 2025-01-09
**Base**: v1.1.0 (production-ready)

## Contexte
Suite aux retours UX sur le mode priorisé (cartes 2/3/4) et le module Habitudes, ce plan structure les correctifs et améliorations à implémenter.

## Priorisation des Tâches

### P0 - Bloquant UX/Valeur (Release 1.2.0)

#### #A1 - Mode 3 Cartes: Bouton VS & Alignement
**Problème**: Bouton VS chevauche les cartes; cartes trop basses
**Impact**: Expérience dégradée sur mode 3 cartes (cas d'usage fréquent)

**Root Cause Hypothèses**:
1. Positioned/Stack sans espace réservé
2. Parent avec crossAxisAlignment.end
3. Pas de SafeArea/SizedBox pour le bouton

**Solution**:
- Réserver zone dédiée pour bouton VS (SliverPersistentHeader ou SizedBox)
- Grille 3 colonnes avec hauteurs égales via AspectRatio
- childAspectRatio ~0.66-0.75

**DoD**:
- [ ] 0 chevauchement en mode 3 cartes
- [ ] Cartes alignées en haut
- [ ] Bouton VS centré verticalement (ou bandeau dédié)
- [ ] Test golden 3 cartes passant

**Fichiers**:
- `lib/presentation/pages/duel/duel_page.dart` (ou équivalent)
- `test/presentation/pages/duel/duel_layout_golden_test.dart` (nouveau)

---

#### #A2 - Mode 4 Cartes: Ratio & Visibilité
**Problème**: Cartes déformées, seulement 2/4 visibles
**Impact**: Mode 4 cartes inutilisable

**Root Cause Hypothèses**:
1. GridView sans childAspectRatio fixe
2. Pas de shrinkWrap/primaryfalse
3. Overflow vertical

**Solution**:
- SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.70)
- Activer shrinkWrap:true
- Forcer AspectRatio constant

**DoD**:
- [ ] 4 cartes simultanément visibles
- [ ] Grille 2×2 sans scroll (si hauteur écran le permet)
- [ ] Aucune déformation
- [ ] Test golden 4 cartes passant

**Fichiers**:
- `lib/presentation/pages/duel/duel_page.dart`
- `test/presentation/pages/duel/duel_layout_golden_test.dart`

---

#### #B3 - Persistance Habitude après Refresh
**Problème**: Habitude créée disparaît après actualisation
**Impact**: Fonction critique cassée; perte de données utilisateur

**Root Cause Hypothèses**:
1. Échec Supabase silencieux (RLS/schema)
2. Écriture OK mais lecture filtrée incorrectement
3. user_id manquant dans payload

**Plan Diagnostic**:
1. Logger avant/après createHabit() (payload, userId, timestamp)
2. Logger fetch post-refresh (filtres, limit, range)
3. Vérifier RLS policy (auth.uid() = user_id)
4. Test RecordingHabitRepository (comme Lists)

**Solution Potentielle**:
- Ajouter user_id à l'écriture explicitement
- Aligner colonnes/typage Supabase
- Gérer erreurs RLS et retry
- Fetch avec eq('user_id', currentUserId)

**DoD**:
- [ ] Après refresh, habitude présente
- [ ] Log écriture = succès
- [ ] Test e2e: create → refresh → assert present
- [ ] Aucune exception silencieuse

**Fichiers**:
- `lib/domain/repositories/habit_repository.dart` (ou implémentation Supabase)
- `lib/data/repositories/supabase_habit_repository.dart`
- `test/domain/repositories/habit_persistence_test.dart` (nouveau)

---

#### #B1 - Sélecteur Fréquence Paramétrique
**Problème**: Trop d'options actuelles; modèle confus
**Impact**: UX complexe; erreurs utilisateur

**Solution UX**:
**Bloc A - "Plusieurs fois par..."**:
- Champ numérique `n` (≥1)
- Liste déroulante `période` {jour, semaine, mois, an}
- Ex: "3 fois par semaine"

**Bloc B - "Tous les X..."**:
- Champ numérique `X` (≥1)
- Unité {heures, jours, semaines, mois}
- Ex: "tous les 2 jours", "toutes les 4 heures"

**Bloc C - "Quantité par période" (optionnel si quantitative)**:
- Champ quantité cible (ex: 8 verres)
- Période (jour/semaine...)

**DoD**:
- [ ] UI paramétrique (≤2 champs + liste unités)
- [ ] Résumé généré i18n (FR/EN)
- [ ] Singulier/pluriel correct
- [ ] Tests widget coverage

**Fichiers**:
- `lib/presentation/pages/habits/widgets/frequency_selector.dart` (nouveau)
- `lib/domain/models/habit/habit_frequency.dart` (refactor)
- `lib/l10n/app_en.arb` + `app_fr.arb`
- `test/presentation/pages/habits/widgets/frequency_selector_test.dart`

---

#### #B2/#C1 - Encodage/i18n Habitudes
**Problème**: Caractères spéciaux visibles ("crâ...", accents cassés)
**Impact**: Expérience dégradée; non-professionnel

**Solution**:
- Tous libellés moteur: ASCII + `\uXXXX` (P0-B spec)
- Tous libellés UI: ARB i18n
- Générateur résumé dynamique: "Boire 8 verres — 3 fois par jour"

**DoD**:
- [ ] 0 artefact d'encodage
- [ ] Scans statiques OK
- [ ] Tests i18n FR/EN verts
- [ ] Résumé cohérent avec choix

**Fichiers**:
- Audit: `lib/presentation/pages/habits/**/*.dart`
- `lib/l10n/app_en.arb` + `app_fr.arb`
- `lib/domain/services/habit_summary_service.dart` (nouveau service pur)

---

### P1 - Fort Levier (Release 1.2.x)

#### #C2 - Accessibilité & Erreurs
**Objectif**: Erreurs dans état UI + semantics lisibles

**Actions**:
- Erreurs création habitude dans state (pas exception qui fuit)
- Labels semantics lisibles (lecteurs d'écran)
- ValueKey pour actions (créer, fréquence, quantité)

**DoD**:
- [ ] Tests widget access OK
- [ ] ValueKeys présents
- [ ] Lecteurs d'écran lisent résumé et erreurs

**Fichiers**:
- `lib/presentation/pages/habits/habits_page.dart`
- `test/presentation/pages/habits/habits_accessibility_test.dart`

---

#### #D2 - Golden Tests Cartes & Habitudes
**Objectif**: Prévenir régressions layout

**Actions**:
- Golden tests 2/3/4 cartes
- Tests résumé fréquence/quantité
- Tests layout habitudes

**DoD**:
- [ ] Goldens 2/3/4 cartes
- [ ] Tests résumé fréquence
- [ ] Suites vertes

**Fichiers**:
- `test/presentation/pages/duel/duel_layout_golden_test.dart`
- `test/presentation/pages/habits/habit_summary_golden_test.dart`

---

### P2 - Améliorations (Release 1.3.0)

#### #A3 - Mode 2 Cartes: Non-Régression
**Action**: Verrouiller état actuel via golden tests

**DoD**:
- [ ] Golden test 2 cartes passant

---

#### #D1 - Télémétrie UX
**Objectif**: Métriques conversion & erreurs

**Actions**:
- Instrumenter: changement mode cartes (2/3/4)
- Convert: création habitude réussie
- Erreurs: RLS, validation

**DoD**:
- [ ] Métriques agrégées (sans PII)
- [ ] Déclenchées aux actions

---

## Notes d'Implémentation (Flutter/Riverpod)

### Grilles Mode Priorisé
```dart
GridView.count(
  crossAxisCount: cardMode == 3 ? 3 : 2,
  childAspectRatio: 0.70, // Constant pour éviter déformation
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  children: cards,
)
```

### Bouton VS
**Éviter**: `Positioned` flottant sans espace
**Préférer**: Bandeau dédié avec SizedBox réservé

```dart
Column(
  children: [
    SizedBox(height: 60, child: CenteredVSButton()),
    Expanded(child: CardsGrid()),
  ],
)
```

### Résumé Fréquence
Service pur pour test unitaire facile:

```dart
class HabitSummaryService {
  static String generateSummary(HabitFrequency freq, Locale locale) {
    // Logique i18n + singulier/pluriel
    return AppLocalizations.of(locale).habitSummary(...);
  }
}
```

### Persistance Habitude
**Toujours passer user_id**:

```dart
await supabase
  .from('habits')
  .insert({
    'name': name,
    'user_id': currentUserId, // CRITIQUE
    'frequency': frequency.toJson(),
  });
```

**Fetch avec filtre**:

```dart
final habits = await supabase
  .from('habits')
  .select()
  .eq('user_id', currentUserId)
  .order('created_at', ascending: false);
```

### Encodage
- **Strings UI**: `→ ARB`
- **Constantes moteur**: `→ ASCII + \uXXXX`

---

## Ordre d'Exécution Suggéré

### Sprint 1 (P0 Critique - 3-5 jours)
1. **#B3**: Persistance Habitudes (bloqueur données)
2. **#A1**: Mode 3 cartes (UX dégradée)
3. **#A2**: Mode 4 cartes (UX cassée)

### Sprint 2 (P0 UX - 2-3 jours)
4. **#B1**: Sélecteur fréquence paramétrique
5. **#B2/#C1**: Encodage/i18n

### Sprint 3 (P1 Qualité - 2 jours)
6. **#C2**: Accessibilité
7. **#D2**: Golden tests

### Sprint 4 (P2 Amélioration - 1 jour)
8. **#A3**: Non-régression 2 cartes
9. **#D1**: Télémétrie

---

## Métriques de Succès

### Technique
- [ ] 0 chevauchement layout (modes 2/3/4)
- [ ] 100% persistance habitudes après refresh
- [ ] 0 artefact encodage
- [ ] Tests golden verts (2/3/4 cartes)
- [ ] Architecture tests verts (maintenu)

### UX
- [ ] Résumé fréquence lisible (FR/EN)
- [ ] 4 cartes visibles en mode 4
- [ ] Accessibilité lecteurs d'écran
- [ ] Temps création habitude < 30s

### Qualité
- [ ] P0-B spec maintenue (ASCII + \uXXXX)
- [ ] i18n complet FR/EN pour Habitudes
- [ ] SOLID principles respectés
- [ ] Test coverage ≥85% sur code modifié

---

## Risques & Mitigation

### Risque #1: RLS Supabase complexe
**Mitigation**: RecordingHabitRepository + tests e2e avant Supabase

### Risque #2: Layout responsive fragile
**Mitigation**: Golden tests + tests sur multiples résolutions

### Risque #3: i18n incomplet
**Mitigation**: Audit statique + tests i18n automatisés

---

**Prochaine Action**: Commencer par #B3 (Persistance Habitudes) car c'est un bloqueur données critique.

**Responsable**: Claude Code AI Agent
**Tracking**: Ce document + GitHub Issues (si applicable)
**Version**: 1.0 (2025-01-09)
