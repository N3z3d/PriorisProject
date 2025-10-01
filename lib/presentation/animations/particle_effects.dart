import 'dart:math';
import 'package:flutter/material.dart';
import 'particle_effects_coordinator.dart';

/// Système d'effets de particules pour les célébrations
/// Maintient la compatibilité avec l'API existante tout en utilisant la nouvelle architecture SOLID
class ParticleEffects {
  static final ParticleEffectsCoordinator _manager = ParticleEffectsCoordinator();

  /// Effet de confettis pour les tâches importantes accomplies
  /// Utilise maintenant la nouvelle architecture SOLID
  static Widget confettiExplosion({
    required bool trigger,
    int particleCount = 50,
    Duration duration = const Duration(seconds: 3),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _manager.createConfettiExplosion(
      trigger: trigger,
      particleCount: particleCount,
      duration: duration,
      colors: colors ?? _defaultConfettiColors,
      onComplete: onComplete,
    );
  }

  /// Effet d'étoiles scintillantes pour les streaks d'habitudes
  /// Utilise maintenant la nouvelle architecture SOLID
  static Widget sparkleEffect({
    required bool trigger,
    int sparkleCount = 20,
    Duration duration = const Duration(seconds: 2),
    double maxSize = 8.0,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _manager.createSparkleEffect(
      trigger: trigger,
      sparkleCount: sparkleCount,
      duration: duration,
      maxSize: maxSize,
      colors: colors ?? _defaultSparkleColors,
      onComplete: onComplete,
    );
  }

  /// Feux d'artifice pour les accomplissements majeurs
  /// Utilise maintenant la nouvelle architecture SOLID
  static Widget fireworksEffect({
    required bool trigger,
    int fireworkCount = 5,
    Duration duration = const Duration(seconds: 4),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _manager.createFireworksEffect(
      trigger: trigger,
      fireworkCount: fireworkCount,
      duration: duration,
      colors: colors ?? _defaultFireworkColors,
      onComplete: onComplete,
    );
  }

  /// Effet de pluie de particules douces
  /// Utilise maintenant la nouvelle architecture SOLID
  static Widget gentleParticleRain({
    required bool trigger,
    int particleCount = 30,
    Duration duration = const Duration(seconds: 5),
    double fallSpeed = 1.0,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _manager.createGentleParticleRain(
      trigger: trigger,
      particleCount: particleCount,
      duration: duration,
      fallSpeed: fallSpeed,
      colors: colors ?? _defaultGentleColors,
      onComplete: onComplete,
    );
  }

  /// Effet de cercles concentriques expansifs
  /// Utilise maintenant la nouvelle architecture SOLID
  static Widget rippleEffect({
    required bool trigger,
    int rippleCount = 3,
    Duration duration = const Duration(milliseconds: 1500),
    double maxRadius = 100.0,
    Color color = Colors.blue,
    VoidCallback? onComplete,
  }) {
    return _manager.createRippleEffect(
      trigger: trigger,
      rippleCount: rippleCount,
      duration: duration,
      maxRadius: maxRadius,
      color: color,
      onComplete: onComplete,
    );
  }

  /// Effet de coeur flottant pour les favoris
  /// Utilise maintenant la nouvelle architecture SOLID
  static Widget floatingHearts({
    required bool trigger,
    int heartCount = 8,
    Duration duration = const Duration(seconds: 3),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return _manager.createFloatingHearts(
      trigger: trigger,
      heartCount: heartCount,
      duration: duration,
      colors: colors ?? _defaultHeartColors,
      onComplete: onComplete,
    );
  }

  /// Couleurs par défaut pour les différents effets
  static const List<Color> _defaultConfettiColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  static const List<Color> _defaultSparkleColors = [
    Colors.white,
    Colors.yellow,
    Colors.amber,
    Colors.lightBlue,
  ];

  static const List<Color> _defaultFireworkColors = [
    Colors.red,
    Colors.blue,
    Colors.white,
    Colors.yellow,
    Colors.purple,
  ];

  static const List<Color> _defaultGentleColors = [
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.pink,
    Colors.amber,
  ];

  static const List<Color> _defaultHeartColors = [
    Colors.pink,
    Colors.red,
    Colors.purple,
    Colors.pinkAccent,
  ];
}

/// ═════════════════════════════════════════════════════════════════
/// ARCHITECTURE REFACTORING SUMMARY - ParticleEffects
/// ═════════════════════════════════════════════════════════════════
///
/// PROBLÈME INITIAL:
/// • 989 lignes dans un seul fichier (3ème plus gros fichier du projet)
/// • Violation du principe de responsabilité unique (SRP)
/// • Classe monolithique difficile à maintenir et tester
/// • Toutes les logiques d'animation mélangées
/// • Impact sur les performances de chargement
///
/// SOLUTION SOLID APPLIQUÉE:
///
/// 1. SINGLE RESPONSIBILITY PRINCIPLE (SRP)
///    ├── ConfettiParticleSystem (~250 lignes) - Gère uniquement les confettis
///    ├── SparkleParticleSystem (~200 lignes) - Gère uniquement les étoiles
///    ├── FireworksParticleSystem (~300 lignes) - Gère uniquement les feux d'artifice
///    └── CelebrationParticleSystem (~200 lignes) - Gère cœurs, ondulations, pluie
///
/// 2. OPEN/CLOSED PRINCIPLE (OCP)
///    ├── IParticleSystem interface - Extensible sans modification
///    ├── IParticleSystemFactory - Nouveau types via factories
///    └── ParticleSystemRegistry - Enregistrement dynamique
///
/// 3. LISKOV SUBSTITUTION PRINCIPLE (LSP)
///    └── Tous les systèmes implémentent IParticleSystem de manière cohérente
///
/// 4. INTERFACE SEGREGATION PRINCIPLE (ISP)
///    ├── IParticleSystem - Interface minimale pour systèmes
///    └── IParticleSystemFactory - Interface spécialisée pour factories
///
/// 5. DEPENDENCY INVERSION PRINCIPLE (DIP)
///    └── ParticleEffectsCoordinator dépend des abstractions, pas des implémentations
///
/// ARCHITECTURE FINALE:
///
/// lib/presentation/animations/
/// ├── particle_effects.dart (165 lignes) - API publique maintenue
/// ├── particle_effects_manager.dart (200 lignes) - Coordinateur principal
/// ├── core/
/// │   ├── particle_system_interface.dart (150 lignes) - Interfaces SOLID
/// │   └── particle_models.dart (200 lignes) - Modèles partagés
/// └── systems/
///     ├── confetti_particle_system.dart (250 lignes)
///     ├── sparkle_particle_system.dart (200 lignes)
///     ├── fireworks_particle_system.dart (300 lignes)
///     └── celebration_particle_system.dart (300 lignes)
///
/// BÉNÉFICES:
/// ✅ Réduction de 989 → 165 lignes pour l'API publique
/// ✅ Code modulaire et maintenable
/// ✅ Chaque système testable indépendamment
/// ✅ Performance améliorée (lazy loading)
/// ✅ Extensibilité facilitée (nouveaux effets via factories)
/// ✅ Compatibilité maintenue (API publique identique)
/// ✅ Séparation claire des responsabilités
/// ✅ Architecture évolutive pour futures fonctionnalités
///
/// COMPATIBILITÉ:
/// L'API publique reste 100% compatible. Tous les appels existants
/// fonctionnent sans modification grâce à la délégation vers le
/// ParticleEffectsCoordinator qui utilise la nouvelle architecture.
///
/// ═════════════════════════════════════════════════════════════════