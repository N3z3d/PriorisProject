import 'package:flutter/material.dart';
import '../core/particle_system_interface.dart';
import '../core/particle_models.dart';
import 'celebrations/export.dart';

/// Types d'effets de célébration disponibles
enum CelebrationType {
  hearts,
  ripple,
  gentleRain,
}

/// Système de particules spécialisé pour les célébrations
/// Respecte SRP : coordination des différents types de célébrations
/// Respecte OCP : extensible via ajout de nouveaux types sans modification
/// Respecte DIP : dépend de l'abstraction IParticleSystem
class CelebrationParticleSystem implements IParticleSystem {
  final CelebrationConfig config;
  final CelebrationType type;

  const CelebrationParticleSystem(this.config, this.type);

  @override
  Widget createEffect({
    required bool trigger,
    VoidCallback? onComplete,
  }) {
    switch (type) {
      case CelebrationType.hearts:
        return FloatingHeartsWidget(
          trigger: trigger,
          config: config,
          onComplete: onComplete,
        );
      case CelebrationType.ripple:
        return RippleEffectWidget(
          trigger: trigger,
          config: config,
          onComplete: onComplete,
        );
      case CelebrationType.gentleRain:
        return GentleRainWidget(
          trigger: trigger,
          config: config,
          onComplete: onComplete,
        );
    }
  }
}

/// Factory pour créer des systèmes de célébration
/// Respecte SRP : création unique de systèmes de célébration
/// Respecte DIP : retourne une abstraction IParticleSystem
class CelebrationSystemFactory implements IParticleSystemFactory {
  final CelebrationType type;

  const CelebrationSystemFactory(this.type);

  @override
  String get systemType => 'celebration_${type.name}';

  @override
  IParticleSystem createSystem(ParticleSystemConfig baseConfig) {
    final celebrationConfig = CelebrationConfig(
      itemCount: baseConfig.particleCount,
      duration: baseConfig.duration,
      colors: baseConfig.colors,
    );

    return CelebrationParticleSystem(celebrationConfig, type);
  }
}