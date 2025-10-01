import 'package:flutter/material.dart';

/// Interface pour tous les systèmes de particules (Interface Segregation Principle)
/// Chaque système de particules doit implémenter cette interface
abstract class IParticleSystem {
  /// Crée un widget d'effet de particules
  /// @param trigger - Déclenche l'animation
  /// @param onComplete - Callback appelé à la fin de l'animation
  Widget createEffect({
    required bool trigger,
    VoidCallback? onComplete,
  });
}

/// Configuration de base pour tous les systèmes de particules
/// Respecte le Single Responsibility Principle
class ParticleSystemConfig {
  final Duration duration;
  final List<Color> colors;
  final int particleCount;

  const ParticleSystemConfig({
    required this.duration,
    required this.colors,
    required this.particleCount,
  });

  /// Factory pour configuration par défaut
  factory ParticleSystemConfig.defaultConfig() {
    return const ParticleSystemConfig(
      duration: Duration(seconds: 2),
      colors: [Colors.blue, Colors.purple, Colors.pink],
      particleCount: 20,
    );
  }

  /// Copie avec modifications
  ParticleSystemConfig copyWith({
    Duration? duration,
    List<Color>? colors,
    int? particleCount,
  }) {
    return ParticleSystemConfig(
      duration: duration ?? this.duration,
      colors: colors ?? this.colors,
      particleCount: particleCount ?? this.particleCount,
    );
  }
}

/// Factory interface pour la création de systèmes de particules
/// Respecte l'Open/Closed Principle
abstract class IParticleSystemFactory {
  IParticleSystem createSystem(ParticleSystemConfig config);
  String get systemType;
}

/// Types de systèmes de particules disponibles
enum ParticleSystemType {
  confetti,
  sparkle,
  fireworks,
  hearts,
  ripple,
  rain,
}

/// Registry des systèmes de particules (Dependency Inversion Principle)
class ParticleSystemRegistry {
  static final ParticleSystemRegistry _instance = ParticleSystemRegistry._internal();
  factory ParticleSystemRegistry() => _instance;
  ParticleSystemRegistry._internal();

  final Map<ParticleSystemType, IParticleSystemFactory> _factories = {};

  /// Enregistre une factory pour un type de système
  void registerFactory(ParticleSystemType type, IParticleSystemFactory factory) {
    _factories[type] = factory;
  }

  /// Crée un système de particules du type spécifié
  IParticleSystem? createSystem(ParticleSystemType type, ParticleSystemConfig config) {
    final factory = _factories[type];
    return factory?.createSystem(config);
  }

  /// Vérifie si un type de système est enregistré
  bool isRegistered(ParticleSystemType type) {
    return _factories.containsKey(type);
  }

  /// Réinitialise le registry (pour les tests)
  void clear() {
    _factories.clear();
  }
}