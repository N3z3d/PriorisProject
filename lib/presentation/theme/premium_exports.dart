/// Export central pour tous les composants Premium UI de Prioris
/// 
/// Ce fichier regroupe tous les exports des fonctionnalités premium
/// pour faciliter leur importation dans l'application.
library premium_exports;

import 'package:flutter/material.dart';
import 'premium_ui_system.dart';
import 'interfaces/premium_ui_interfaces.dart';

// ============ SYSTÈME UI UNIFIÉ - REFACTORED SOLID ARCHITECTURE ============
export 'premium_ui_system.dart'; // Backward compatible facade
// export 'premium_ui_manager.dart'; // New SOLID architecture manager - implementation pending
export 'interfaces/premium_ui_interfaces.dart'; // Core interfaces
// export 'systems/export.dart'; // Specialized systems - implementation pending

// ============ GLASSMORPHISME ============
export 'glassmorphism.dart';

// ============ ANIMATIONS ============
export '../animations/physics_animations.dart';
export '../animations/particle_effects.dart';
export '../animations/micro_interactions.dart';

// ============ LOADING & SKELETONS ============
export '../widgets/loading/premium_skeletons.dart';
// Note: advanced_loading_widget.dart supprimé (code mort - widget non utilisé)

// ============ SERVICES ============
export '../services/premium_haptic_service.dart';

// ============ TOKENS & DESIGN SYSTEM ============
export 'border_radius_tokens.dart';
export 'elevation_system.dart';
export 'app_theme.dart';

// ============ WIDGETS COMMUNS ============
export '../widgets/common/displays/premium_card.dart';
export '../widgets/buttons/action_button.dart';

// ============ CONSTANTES PREMIUM ============

/// Configuration globale pour les fonctionnalités premium
class PremiumConfig {
  // Empêcher l'instanciation
  PremiumConfig._();

  // ========== PERFORMANCE ==========
  
  /// Durée par défaut pour les animations (optimisée 60 FPS)
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  /// Durée pour les animations physics-based
  static const Duration physicsAnimationDuration = Duration(milliseconds: 600);
  
  /// Durée pour les effets de particules
  static const Duration particleEffectDuration = Duration(seconds: 2);
  
  /// FPS cible pour les animations
  static const int targetFPS = 60;

  // ========== GLASSMORPHISME ==========
  
  /// Opacité par défaut pour le glassmorphisme
  static const double defaultGlassOpacity = 0.1;
  
  /// Blur par défaut pour les effets de verre
  static const double defaultGlassBlur = 10.0;
  
  /// Opacité du background pour les modales
  static const double modalBackgroundOpacity = 0.5;

  // ========== HAPTIC FEEDBACK ==========
  
  /// Activer les haptics par défaut
  static const bool defaultHapticsEnabled = true;
  
  /// Délai minimum entre deux feedbacks haptics (évite le spam)
  static const Duration hapticCooldown = Duration(milliseconds: 50);

  // ========== PARTICULES ==========
  
  /// Nombre de particules par défaut pour les confettis
  static const int defaultConfettiCount = 50;
  
  /// Nombre de sparkles par défaut
  static const int defaultSparkleCount = 20;
  
  /// Nombre de feux d'artifice par défaut
  static const int defaultFireworkCount = 5;

  // ========== SKELETONS ==========
  
  /// Durée de l'animation shimmer
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  
  /// Délai de transition entre loading et contenu
  static const Duration skeletonTransition = Duration(milliseconds: 300);

  // ========== PHYSIQUE ==========
  
  /// Facteur d'amortissement par défaut pour les ressorts
  static const double defaultDampingRatio = 0.8;
  
  /// Rigidité par défaut pour les animations spring
  static const double defaultStiffness = 100.0;
  
  /// Hauteur de rebond par défaut
  static const double defaultBounceHeight = 1.3;

  // ========== ACCESSIBILITÉ ==========
  
  /// Respecter les préférences d'animation réduites
  static const bool respectReducedMotion = true;
  
  /// Temps d'attente minimum pour les lecteurs d'écran
  static const Duration screenReaderDelay = Duration(milliseconds: 100);

  // ========== THRESHOLDS ==========
  
  /// Seuil de défilement pour déclencher des effets
  static const double scrollThreshold = 50.0;
  
  /// Distance de swipe minimum pour déclencher une action
  static const double swipeThreshold = 100.0;
  
  /// Vélocité minimale pour les animations physiques
  static const double minVelocity = 10.0;
}

/// Utilitaires premium pour l'application
class PremiumUtils {
  // Empêcher l'instanciation
  PremiumUtils._();

  /// Vérifie si les animations doivent être réduites
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation ||
           !PremiumConfig.respectReducedMotion;
  }

  /// Calcule la durée d'animation adaptée selon les préférences
  static Duration getAdaptiveDuration(
    BuildContext context, {
    Duration normal = PremiumConfig.defaultAnimationDuration,
    Duration reduced = const Duration(milliseconds: 100),
  }) {
    return shouldReduceMotion(context) ? reduced : normal;
  }

  /// Détermine si les effets premium doivent être activés
  static bool shouldEnablePremiumEffects(BuildContext context) {
    // Désactive sur les appareils peu puissants ou si les animations sont réduites
    final mediaQuery = MediaQuery.of(context);
    final isLowEndDevice = mediaQuery.size.width < 400 || 
                          mediaQuery.devicePixelRatio < 2.0;
    
    return !isLowEndDevice && !shouldReduceMotion(context);
  }

  /// Adapte l'intensité des effets selon la performance
  static double getEffectIntensity(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    
    if (devicePixelRatio >= 3.0) {
      return 1.0; // Intensité maximale
    } else if (devicePixelRatio >= 2.0) {
      return 0.7; // Intensité réduite
    } else {
      return 0.5; // Intensité minimale
    }
  }

  /// Calcule le nombre optimal de particules selon la performance
  static int getOptimalParticleCount(BuildContext context, int baseCount) {
    final intensity = getEffectIntensity(context);
    return (baseCount * intensity).round().clamp(5, baseCount);
  }
}

/// Extensions pour faciliter l'utilisation des composants premium
extension PremiumBuildContext on BuildContext {
  /// Affiche un succès premium
  void showPremiumSuccess(
    String message, {
    SuccessType type = SuccessType.standard,
  }) {
    PremiumUISystem.showPremiumSuccess(
      context: this,
      message: message,
      type: type,
      enableParticles: PremiumUtils.shouldEnablePremiumEffects(this),
    );
  }

  /// Affiche une erreur premium
  void showPremiumError(String message) {
    PremiumUISystem.showPremiumError(
      context: this,
      message: message,
    );
  }

  /// Affiche un avertissement premium
  void showPremiumWarning(String message) {
    PremiumUISystem.showPremiumWarning(
      context: this,
      message: message,
    );
  }

  /// Affiche un modal premium
  Future<T?> showPremiumModal<T>(Widget child) {
    return PremiumUISystem.showPremiumModal<T>(
      context: this,
      child: child,
      enablePhysics: PremiumUtils.shouldEnablePremiumEffects(this),
    );
  }

  /// Affiche un bottom sheet premium
  Future<T?> showPremiumBottomSheet<T>(Widget child) {
    return PremiumUISystem.showPremiumBottomSheet<T>(
      context: this,
      child: child,
      enablePhysics: PremiumUtils.shouldEnablePremiumEffects(this),
    );
  }

  /// Vérifie si les effets premium sont supportés
  bool get supportsPremiumEffects => PremiumUtils.shouldEnablePremiumEffects(this);

  /// Obtient l'intensité des effets pour cet appareil
  double get effectIntensity => PremiumUtils.getEffectIntensity(this);

  /// Obtient la durée d'animation adaptée
  Duration get adaptiveAnimationDuration => 
      PremiumUtils.getAdaptiveDuration(this);
}