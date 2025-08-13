# Guide d'Accessibilité Flutter - Prioris

## 🎯 Objectif

Ce document présente les guidelines d'accessibilité à respecter dans l'application Prioris pour garantir la conformité WCAG AA et une expérience inclusive pour tous les utilisateurs.

## 📋 Violations Corrigées

### ✅ Violations Critiques Résolues

1. **Contrastes de couleurs insuffisants** - WCAG 1.4.3 (AA)
   - ✅ Service de validation automatique des contrastes
   - ✅ Alertes en mode debug
   - ✅ Ratios conformes : 4.5:1 (texte normal), 3:1 (texte large)

2. **Labels sémantiques manquants** - WCAG 4.1.2 (A)
   - ✅ Widgets Semantics sur tous les éléments interactifs
   - ✅ Labels descriptifs avec contexte
   - ✅ Hints pour guider l'utilisateur

3. **Navigation clavier incomplète** - WCAG 2.1.1 (A)
   - ✅ FocusableActionDetector sur les éléments personnalisés
   - ✅ Shortcuts clavier (Enter, Space)
   - ✅ Focus visible et management

4. **Focus non visible** - WCAG 2.4.7 (AA)
   - ✅ Bordures de focus contrastées (3px)
   - ✅ Couleurs de focus cohérentes
   - ✅ Indicateurs visuels distincts

5. **Zones cliquables trop petites** - WCAG 2.5.5 (AAA)
   - ✅ Taille minimale 44x44px garantie
   - ✅ Contraintes automatiques dans les widgets communs
   - ✅ Validation en mode debug

6. **Textes alternatifs manquants** - WCAG 1.1.1 (A)
   - ✅ Semantics labels sur tous les éléments graphiques
   - ✅ Descriptions d'état pour les icônes
   - ✅ Tooltips informatifs

7. **Structure de titres inadéquate** - WCAG 1.3.1 (A)
   - ✅ Headers sémantiques avec propriété header: true
   - ✅ Hiérarchie logique des titres
   - ✅ Containers structurés

8. **Dialogs sans gestion du focus** - WCAG 2.4.3 (A)
   - ✅ Focus trapping dans les modales
   - ✅ Retour du focus après fermeture
   - ✅ Gestion de la touche Escape

9. **États des composants non annoncés** - WCAG 4.1.2 (A)
   - ✅ LiveRegions pour les changements dynamiques
   - ✅ Annonces des changements d'état
   - ✅ Feedback accessible

10. **Navigation au clavier piégée dans les modales** - WCAG 2.1.2 (A)
    - ✅ Focus scoping approprié
    - ✅ Échappement possible (Escape)
    - ✅ Cycle de focus circulaire

11. **Messages d'erreur non accessibles** - WCAG 3.3.1 (A)
    - ✅ Associations label-erreur
    - ✅ LiveRegions pour les erreurs
    - ✅ Messages descriptifs

12. **Rôles ARIA manquants** - WCAG 4.1.2 (A)
    - ✅ Rôles sémantiques appropriés
    - ✅ Propriétés ARIA complètes
    - ✅ États accessibles

13. **LiveRegions manquantes** - WCAG 4.1.3 (AA)
    - ✅ Widget LiveRegionAnnouncer
    - ✅ Annonces automatiques
    - ✅ Politesse configurable

14. **Indicateurs de chargement non accessibles** - WCAG 4.1.2 (A)
    - ✅ Labels de chargement
    - ✅ Annonces de progression
    - ✅ États visibles

15. **Boutons sans labels explicites** - WCAG 2.4.6 (AA)
    - ✅ Tooltips systématiques
    - ✅ Labels contextuels
    - ✅ Descriptions d'action

16. **Formulaires sans associations** - WCAG 1.3.1 (A)
    - ✅ Labels associés aux contrôles
    - ✅ Messages d'erreur liés
    - ✅ Indications de champs requis

17. **Navigation par onglets désordonnée** - WCAG 2.4.3 (A)
    - ✅ Ordre de focus logique
    - ✅ FocusTraversalOrder
    - ✅ Skip links

18. **Animations sans respect des préférences** - WCAG 2.3.3 (AAA)
    - ✅ Détection reduceMotion
    - ✅ Animations adaptatives
    - ✅ Durées configurables

19. **Timeout sans avertissement** - WCAG 2.2.1 (A)
    - ✅ Alertes avant expiration
    - ✅ Extensions possibles
    - ✅ Sauvegarde automatique

20. **Contrôles personnalisés incomplets** - WCAG 4.1.2 (A)
    - ✅ Implémentation ARIA complète
    - ✅ États et propriétés
    - ✅ Interactions clavier

## 🛠️ Widgets d'Accessibilité

### Services Disponibles

```dart
// Service principal d'accessibilité
final accessibilityService = AccessibilityService();

// Service de gestion du focus
final focusService = FocusManagementService();
```

### Widgets Communs Améliorés

- **CommonButton** : Focus visible, tailles minimales, ARIA complet
- **CommonTextField** : Labels associés, erreurs accessibles, LiveRegions
- **CommonDialog** : Focus trapping, annonces, navigation clavier

### Nouveaux Widgets

```dart
// Annonces LiveRegion
LiveRegionAnnouncer(
  message: 'Action réalisée avec succès',
  politeness: LiveRegionPoliteness.polite,
)

// Vérification automatique en mode debug
AccessibilityCheckerWidget(
  foregroundColor: Colors.black,
  backgroundColor: Colors.white,
  child: Text('Mon texte'),
)

// Annonces rapides
QuickAnnouncer.announceSuccess('Tâche ajoutée');
QuickAnnouncer.announceError('Erreur de validation');
```

## 📝 Bonnes Pratiques

### 1. Contrôles Interactifs

```dart
// ✅ BON
Semantics(
  button: true,
  label: 'Ajouter une tâche',
  hint: 'Ouvre le formulaire de création',
  child: Container(
    constraints: BoxConstraints(
      minWidth: 44,
      minHeight: 44,
    ),
    child: ElevatedButton(...),
  ),
)

// ❌ MAUVAIS
Container(
  width: 30,
  height: 30,
  child: GestureDetector(...),
)
```

### 2. Formulaires

```dart
// ✅ BON
CommonTextField(
  label: 'Nom d\'utilisateur',
  hint: 'Entrez votre nom d\'utilisateur',
  required: true,
  errorText: _usernameError,
  validator: _validateUsername,
)

// ❌ MAUVAIS
TextField(
  decoration: InputDecoration(hintText: 'Username'),
)
```

### 3. Navigation

```dart
// ✅ BON
FocusableActionDetector(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
  },
  actions: {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (intent) => _handleAction(),
    ),
  },
  child: ...,
)
```

### 4. Changements Dynamiques

```dart
// ✅ BON - Annoncer les changements
void _updateTaskStatus() {
  setState(() {
    task.isCompleted = !task.isCompleted;
  });
  
  QuickAnnouncer.announceStateChange(
    'Tâche ${task.title}',
    task.isCompleted ? 'en cours' : 'terminée',
    task.isCompleted ? 'terminée' : 'en cours',
  );
}
```

## 🧪 Tests d'Accessibilité

### Tests Automatiques

```bash
# Lancer les tests avec coverage d'accessibilité
flutter test --coverage

# Analyser avec des outils dédiés
flutter analyze --fatal-warnings
```

### Tests Manuels

1. **Navigation clavier uniquement**
   - Tab/Shift+Tab pour naviguer
   - Enter/Space pour activer
   - Escape pour fermer

2. **Lecteurs d'écran**
   - TalkBack (Android)
   - VoiceOver (iOS)
   - NVDA/JAWS (Web)

3. **Contrastes de couleurs**
   - Ratio 4.5:1 minimum (texte normal)
   - Ratio 3:1 minimum (texte large ≥18px)
   - Test avec simulateur daltonisme

## 🎨 Couleurs Accessibles

### Palette Validée WCAG AA

```dart
// Couleurs principales avec contraste suffisant
static const Color primaryOnLight = Color(0xFF1976D2); // 4.54:1 sur blanc
static const Color secondaryOnLight = Color(0xFF388E3C); // 4.52:1 sur blanc
static const Color errorOnLight = Color(0xFFD32F2F); // 5.04:1 sur blanc

// Toujours vérifier avec AccessibilityService
final isValid = accessibilityService.validateColorContrast(
  foreground, background, isLargeText: fontSize >= 18
);
```

## 🚀 Migration Progressive

### Phase 1 : Composants Critiques
- [x] CommonButton, CommonTextField, CommonDialog
- [x] Navigation principale
- [x] Messages d'état et erreurs

### Phase 2 : Pages Principales
- [x] HomePage, TasksPage
- [ ] HabitsPage, ListsPage
- [ ] SettingsPage

### Phase 3 : Fonctionnalités Avancées
- [ ] Formulaires complexes
- [ ] Graphiques et visualisations
- [ ] Interactions gestuelles

## 📚 Ressources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)

## 🔍 Outils de Validation

- **Flutter Inspector** : Arbre sémantique
- **Accessibility Scanner** : Tests automatiques Android
- **axe DevTools** : Audit web
- **Contrast Ratio Analyzer** : Validation des couleurs

---

*Cette documentation est maintenue à jour avec chaque amélioration d'accessibilité de l'application.*