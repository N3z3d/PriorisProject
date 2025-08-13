# Guide d'utilisation du système UI Premium Prioris

## Vue d'ensemble

Le système UI Premium de Prioris offre une expérience utilisateur haut de gamme avec 5 fonctionnalités principales :

1. **Glassmorphisme** - Effets de verre moderne pour tous les overlays
2. **Animations Physics-Based** - Animations réalistes avec physique (ressorts, rebonds, gravité)
3. **Effets de Particules** - Célébrations visuelles pour les succès
4. **Loading Skeletons Premium** - Chargement élégant avec effet shimmer
5. **Haptic Feedback Avancé** - Retours tactiles contextuels et différenciés

## Installation

### 1. Import unique

```dart
import 'package:prioris/presentation/theme/premium_exports.dart';
```

### 2. Initialisation

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le système premium
  await PremiumUISystem.initialize();
  
  runApp(MyApp());
}
```

## Utilisation rapide

### Boutons Premium

```dart
// Bouton standard avec tous les effets
PremiumUISystem.premiumButton(
  text: 'Confirmer',
  onPressed: () => print('Tapped!'),
  icon: Icons.check,
  style: ButtonStyle.primary,
  enableHaptics: true,
  enablePhysics: true,
)

// FAB premium
PremiumUISystem.premiumFAB(
  onPressed: () => print('FAB tapped!'),
  enableGlass: true,
  child: Icon(Icons.add),
)
```

### Cartes Premium

```dart
PremiumUISystem.premiumCard(
  enablePhysics: true,
  enableHaptics: true,
  showLoading: false, // Active le skeleton automatiquement
  skeletonType: SkeletonType.taskCard,
  onTap: () => print('Card tapped!'),
  child: YourContent(),
)
```

### Modals et Bottom Sheets

```dart
// Modal avec glassmorphisme
context.showPremiumModal(
  YourModalContent(),
);

// Bottom sheet premium
context.showPremiumBottomSheet(
  YourBottomSheetContent(),
);
```

### Feedback et Notifications

```dart
// Succès avec particules
context.showPremiumSuccess(
  'Tâche complétée !',
  type: SuccessType.major, // Déclenche les confettis
);

// Erreur
context.showPremiumError('Une erreur est survenue');

// Avertissement
context.showPremiumWarning('Attention requise');
```

### Loading et Skeletons

```dart
// Loading overlay
final loadingOverlay = PremiumUISystem.showPremiumLoading(
  context: context,
  message: 'Chargement en cours...',
);

// Dismisser
loadingOverlay.remove();

// Skeleton adaptatif
AdaptiveSkeletonLoader(
  isLoading: isDataLoading,
  skeletonType: SkeletonType.list,
  child: YourWidget(),
)
```

## Fonctionnalités détaillées

### 1. Glassmorphisme

#### Modals et Dialogs
```dart
Glassmorphism.glassModal(
  child: YourContent(),
  blur: 15.0,
  opacity: 0.1,
  barrierDismissible: true,
)
```

#### Bottom Sheets
```dart
Glassmorphism.glassBottomSheet(
  height: 400,
  enableDragHandle: true,
  child: YourContent(),
)
```

#### Boutons de verre
```dart
Glassmorphism.glassButton(
  onPressed: () {},
  child: Text('Bouton verre'),
  blur: 10.0,
  opacity: 0.2,
)
```

### 2. Animations Physics-Based

#### Animation de ressort
```dart
PhysicsAnimations.springAnimation(
  trigger: shouldAnimate,
  duration: Duration(milliseconds: 800),
  dampingRatio: 0.8,
  stiffness: 100.0,
  child: YourWidget(),
)
```

#### Rebond élastique
```dart
PhysicsAnimations.elasticBounce(
  trigger: shouldBounce,
  bounceHeight: 1.3,
  bounceCount: 3,
  child: YourWidget(),
)
```

#### Scale avec ressort
```dart
PhysicsAnimations.springScale(
  onTap: () => print('Tapped with physics!'),
  scaleFactor: 0.9,
  springCurve: Curves.elasticOut,
  child: YourWidget(),
)
```

#### Gravité avec rebonds
```dart
PhysicsAnimations.gravityBounce(
  trigger: shouldDrop,
  height: 100.0,
  bounceDamping: 0.7,
  child: YourWidget(),
)
```

### 3. Effets de Particules

#### Confettis pour succès majeur
```dart
ParticleEffects.confettiExplosion(
  trigger: taskCompleted,
  particleCount: 50,
  colors: [Colors.red, Colors.blue, Colors.green],
)
```

#### Étoiles scintillantes pour streaks
```dart
ParticleEffects.sparkleEffect(
  trigger: streakAchieved,
  sparkleCount: 20,
  maxSize: 8.0,
)
```

#### Feux d'artifice pour accomplissements
```dart
ParticleEffects.fireworksEffect(
  trigger: goalAchieved,
  fireworkCount: 5,
)
```

#### Cœurs flottants pour favoris
```dart
ParticleEffects.floatingHearts(
  trigger: favoriteAdded,
  heartCount: 8,
)
```

### 4. Loading Skeletons Premium

#### Skeletons prédéfinis
```dart
// Carte de tâche
PremiumSkeletons.taskCardSkeleton(
  showPriority: true,
  showProgress: true,
)

// Carte d'habitude
PremiumSkeletons.habitCardSkeleton(
  showStreak: true,
  showChart: true,
)

// Liste d'éléments
PremiumSkeletons.listSkeleton(
  itemCount: 5,
  itemHeight: 80,
)

// Graphique
PremiumSkeletons.chartSkeleton(
  height: 200,
  showLegend: true,
)
```

#### Page complète
```dart
PageSkeletonLoader(
  pageType: SkeletonPageType.dashboard,
)
```

### 5. Haptic Feedback Avancé

#### Feedbacks de base
```dart
await PremiumHapticService.instance.lightImpact();
await PremiumHapticService.instance.mediumImpact();
await PremiumHapticService.instance.heavyImpact();
```

#### Feedbacks contextuels
```dart
// Succès (double vibration)
await PremiumHapticService.instance.success();

// Erreur (vibration forte répétée)
await PremiumHapticService.instance.error();

// Avertissement
await PremiumHapticService.instance.warning();
```

#### Feedbacks spécialisés Prioris
```dart
// Tâche ajoutée
await PremiumHapticService.instance.taskAdded();

// Tâche complétée
await PremiumHapticService.instance.taskCompleted();

// Habitude accomplie
await PremiumHapticService.instance.habitCompleted();

// Milestone de streak
await PremiumHapticService.instance.streakMilestone(14);

// Changement de priorité
await PremiumHapticService.instance.priorityChanged(1, 3);
```

#### Wrapper automatique
```dart
HapticWrapper(
  tapIntensity: HapticIntensity.medium,
  longPressIntensity: HapticIntensity.heavy,
  onTap: () => print('Tap with haptic!'),
  child: YourWidget(),
)
```

## Optimisation des performances

### Détection adaptative
```dart
// Le système détecte automatiquement les capacités de l'appareil
if (context.supportsPremiumEffects) {
  // Activer tous les effets
} else {
  // Version allégée
}

// Intensité adaptée
final intensity = context.effectIntensity; // 0.5 à 1.0
```

### Configuration globale
```dart
// Désactiver globalement les haptics
PremiumHapticService.instance.setEnabled(false);

// Vérifier le support
if (PremiumHapticService.instance.hasVibrator) {
  // Supporter les vibrations personnalisées
}
```

## Exemples d'intégration complète

### Carte de tâche premium
```dart
class PremiumTaskCard extends StatelessWidget {
  final Task task;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PremiumUISystem.premiumCard(
      enablePhysics: context.supportsPremiumEffects,
      enableHaptics: true,
      showLoading: isLoading,
      skeletonType: SkeletonType.taskCard,
      onTap: () => _handleTaskTap(context),
      child: Column(
        children: [
          TaskHeader(task: task),
          TaskProgress(task: task),
          TaskActions(task: task),
        ],
      ),
    );
  }

  void _handleTaskTap(BuildContext context) async {
    if (task.isCompleted) return;
    
    // Marquer comme complété avec tous les effets
    await PremiumHapticService.instance.taskCompleted();
    
    context.showPremiumSuccess(
      'Tâche complétée !',
      type: task.priority > 3 
        ? SuccessType.major 
        : SuccessType.standard,
    );
  }
}
```

### Navigation premium
```dart
class PremiumNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Glassmorphism.glassNavigationBar(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Accueil', 0),
          _buildNavItem(Icons.task_alt, 'Tâches', 1),
          _buildNavItem(Icons.auto_awesome, 'Habitudes', 2),
          _buildNavItem(Icons.analytics, 'Stats', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return HapticWrapper(
      tapIntensity: HapticIntensity.light,
      onTap: () => _navigateToPage(index),
      child: PhysicsAnimations.springScale(
        onTap: () => _navigateToPage(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(label),
          ],
        ),
      ),
    );
  }
}
```

## Bonnes pratiques

### Performance
- Utilisez `context.supportsPremiumEffects` pour désactiver les effets sur les appareils peu puissants
- Limitez le nombre de particules avec `PremiumUtils.getOptimalParticleCount()`
- Respectez les préférences d'accessibilité avec `PremiumUtils.shouldReduceMotion()`

### Accessibilité
- Les animations respectent automatiquement les préférences "Réduire les mouvements"
- Les haptics ne se déclenchent que si supportés par l'appareil
- Les skeletons maintiennent la structure sémantique

### UX
- Utilisez les particules avec parcimonie (succès majeurs uniquement)
- Variez l'intensité des haptics selon le contexte
- Préférez les animations subtiles pour les interactions fréquentes

### Développement
- Importez toujours via `premium_exports.dart`
- Initialisez le système au démarrage de l'app
- Testez sur différents appareils pour vérifier les performances

## Dépannage

### Les haptics ne fonctionnent pas
```dart
// Vérifier l'initialisation
await PremiumHapticService.instance.initialize();

// Vérifier si activé
if (!PremiumHapticService.instance.isEnabled) {
  PremiumHapticService.instance.setEnabled(true);
}

// Vérifier le support matériel
if (!PremiumHapticService.instance.hasVibrator) {
  print('Appareil ne supporte pas les vibrations');
}
```

### Les animations sont saccadées
```dart
// Désactiver sur appareils peu puissants
final enableEffects = context.supportsPremiumEffects;

// Réduire l'intensité
final intensity = context.effectIntensity;
final particleCount = (baseCount * intensity).round();
```

### Les effets de verre ne s'affichent pas
- Vérifiez que le widget parent a un background
- Assurez-vous que `BackdropFilter` a du contenu à flouter
- Testez sur un appareil réel (l'émulateur peut avoir des problèmes)

## Support et contributions

Pour tout problème ou suggestion d'amélioration du système premium, créez une issue dans le projet avec le label `premium-ui`.