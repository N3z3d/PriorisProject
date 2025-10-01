import 'package:flutter/material.dart';
import 'core/particle_system_interface.dart';
import 'systems/confetti_particle_system.dart';
import 'systems/sparkle_particle_system.dart';
import 'systems/fireworks_particle_system.dart';
import 'systems/celebration_particle_system.dart';

/// Coordinateur principal des effets de particules
/// Respecte le Single Responsibility Principle et le Dependency Inversion Principle
/// Responsabilité : Coordonner et créer les systèmes de particules
class ParticleEffectsCoordinator {
  static final ParticleEffectsCoordinator _instance = ParticleEffectsCoordinator._internal();
  factory ParticleEffectsCoordinator() => _instance;
  ParticleEffectsCoordinator._internal() {
    _registerFactories();
  }

  final ParticleSystemRegistry _registry = ParticleSystemRegistry();

  /// Enregistre toutes les factories de systèmes de particules
  void _registerFactories() {
    _registry.registerFactory(ParticleSystemType.confetti, ConfettiSystemFactory());
    _registry.registerFactory(ParticleSystemType.sparkle, SparkleSystemFactory());
    _registry.registerFactory(ParticleSystemType.fireworks, FireworksSystemFactory());

    // Enregistrer les différents types de célébration
    _registry.registerFactory(
      ParticleSystemType.hearts,
      const CelebrationSystemFactory(CelebrationType.hearts),
    );
    _registry.registerFactory(
      ParticleSystemType.ripple,
      const CelebrationSystemFactory(CelebrationType.ripple),
    );
    _registry.registerFactory(
      ParticleSystemType.rain,
      const CelebrationSystemFactory(CelebrationType.gentleRain),
    );
  }

  /// Crée un effet de confettis
  Widget createConfettiExplosion({
    required bool trigger,
    int particleCount = 50,
    Duration duration = const Duration(seconds: 3),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    final config = ParticleSystemConfig(
      duration: duration,
      colors: colors ?? _DefaultColors.confetti,
      particleCount: particleCount,
    );

    final system = _registry.createSystem(ParticleSystemType.confetti, config);
    return system?.createEffect(trigger: trigger, onComplete: onComplete)
           ?? const SizedBox.shrink();
  }

  /// Crée un effet d'étoiles scintillantes
  Widget createSparkleEffect({
    required bool trigger,
    int sparkleCount = 20,
    Duration duration = const Duration(seconds: 2),
    double maxSize = 8.0,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    final config = ParticleSystemConfig(
      duration: duration,
      colors: colors ?? _DefaultColors.sparkle,
      particleCount: sparkleCount,
    );

    final system = _registry.createSystem(ParticleSystemType.sparkle, config);
    return system?.createEffect(trigger: trigger, onComplete: onComplete)
           ?? const SizedBox.shrink();
  }

  /// Crée un effet de feux d'artifice
  Widget createFireworksEffect({
    required bool trigger,
    int fireworkCount = 5,
    Duration duration = const Duration(seconds: 4),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    final config = ParticleSystemConfig(
      duration: duration,
      colors: colors ?? _DefaultColors.fireworks,
      particleCount: fireworkCount * 20, // Converti en particleCount
    );

    final system = _registry.createSystem(ParticleSystemType.fireworks, config);
    return system?.createEffect(trigger: trigger, onComplete: onComplete)
           ?? const SizedBox.shrink();
  }

  /// Crée un effet de pluie douce
  Widget createGentleParticleRain({
    required bool trigger,
    int particleCount = 30,
    Duration duration = const Duration(seconds: 5),
    double fallSpeed = 1.0,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    final config = ParticleSystemConfig(
      duration: duration,
      colors: colors ?? _DefaultColors.gentle,
      particleCount: particleCount,
    );

    final system = _registry.createSystem(ParticleSystemType.rain, config);
    return system?.createEffect(trigger: trigger, onComplete: onComplete)
           ?? const SizedBox.shrink();
  }

  /// Crée un effet d'ondulations
  Widget createRippleEffect({
    required bool trigger,
    int rippleCount = 3,
    Duration duration = const Duration(milliseconds: 1500),
    double maxRadius = 100.0,
    Color color = Colors.blue,
    VoidCallback? onComplete,
  }) {
    final config = ParticleSystemConfig(
      duration: duration,
      colors: [color],
      particleCount: rippleCount * 5, // Converti en particleCount
    );

    final system = _registry.createSystem(ParticleSystemType.ripple, config);
    return system?.createEffect(trigger: trigger, onComplete: onComplete)
           ?? const SizedBox.shrink();
  }

  /// Crée un effet de coeurs flottants
  Widget createFloatingHearts({
    required bool trigger,
    int heartCount = 8,
    Duration duration = const Duration(seconds: 3),
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    final config = ParticleSystemConfig(
      duration: duration,
      colors: colors ?? _DefaultColors.hearts,
      particleCount: heartCount,
    );

    final system = _registry.createSystem(ParticleSystemType.hearts, config);
    return system?.createEffect(trigger: trigger, onComplete: onComplete)
           ?? const SizedBox.shrink();
  }

  /// Crée un effet personnalisé basé sur un type et une configuration
  Widget createCustomEffect({
    required ParticleSystemType type,
    required ParticleSystemConfig config,
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    final system = _registry.createSystem(type, config);
    return system?.createEffect(trigger: trigger, onComplete: onComplete)
           ?? const SizedBox.shrink();
  }

  /// Vérifie si un type d'effet est disponible
  bool isEffectAvailable(ParticleSystemType type) {
    return _registry.isRegistered(type);
  }

  /// Enregistre une nouvelle factory personnalisée
  void registerCustomFactory(ParticleSystemType type, IParticleSystemFactory factory) {
    _registry.registerFactory(type, factory);
  }

  /// Réinitialise le gestionnaire (pour les tests)
  void reset() {
    _registry.clear();
    _registerFactories();
  }
}

/// Configuration des couleurs par défaut
/// Respecte le DRY principle
class _DefaultColors {
  static const List<Color> confetti = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  static const List<Color> sparkle = [
    Colors.white,
    Colors.yellow,
    Colors.amber,
    Colors.lightBlue,
  ];

  static const List<Color> fireworks = [
    Colors.red,
    Colors.blue,
    Colors.white,
    Colors.yellow,
    Colors.purple,
  ];

  static const List<Color> gentle = [
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.pink,
    Colors.amber,
  ];

  static const List<Color> hearts = [
    Colors.pink,
    Colors.red,
    Colors.purple,
    Colors.pinkAccent,
  ];
}

/// Builder pattern pour créer des configurations complexes
class ParticleEffectBuilder {
  ParticleSystemType? _type;
  Duration _duration = const Duration(seconds: 2);
  List<Color> _colors = _DefaultColors.confetti;
  int _particleCount = 20;
  bool _trigger = false;
  VoidCallback? _onComplete;

  /// Définit le type d'effet
  ParticleEffectBuilder type(ParticleSystemType type) {
    _type = type;
    return this;
  }

  /// Définit la durée de l'effet
  ParticleEffectBuilder duration(Duration duration) {
    _duration = duration;
    return this;
  }

  /// Définit les couleurs
  ParticleEffectBuilder colors(List<Color> colors) {
    _colors = colors;
    return this;
  }

  /// Définit le nombre de particules
  ParticleEffectBuilder particleCount(int count) {
    _particleCount = count;
    return this;
  }

  /// Définit le déclencheur
  ParticleEffectBuilder trigger(bool trigger) {
    _trigger = trigger;
    return this;
  }

  /// Définit le callback de completion
  ParticleEffectBuilder onComplete(VoidCallback? onComplete) {
    _onComplete = onComplete;
    return this;
  }

  /// Construit l'effet de particules
  Widget build() {
    if (_type == null) {
      throw ArgumentError('Type must be specified');
    }

    final config = ParticleSystemConfig(
      duration: _duration,
      colors: _colors,
      particleCount: _particleCount,
    );

    return ParticleEffectsCoordinator().createCustomEffect(
      type: _type!,
      config: config,
      trigger: _trigger,
      onComplete: _onComplete,
    );
  }
}