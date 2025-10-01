import 'dart:math';
import 'package:flutter/material.dart';
import 'fluid_animations.dart';

/// Widget d'animation de vague - SRP: Responsable uniquement de l'animation de vague
/// LSP: Peut être substitué par BaseFluidAnimation
/// OCP: Fermé à la modification, ouvert à l'extension via composition
class WaveAnimation extends BaseFluidAnimation {
  final double amplitude;

  const WaveAnimation({
    super.key,
    required super.child,
    required super.duration,
    required this.amplitude,
  });

  @override
  Animation<double> createAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));
  }

  @override
  Widget applyTransformation(Widget child, double value) {
    return Transform.translate(
      offset: Offset(
        sin(value) * amplitude,
        0,
      ),
      child: child,
    );
  }

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

/// État de l'animation de vague - SRP: Responsable uniquement de la gestion de l'état de l'animation de vague
class _WaveAnimationState extends BaseFluidAnimationState<WaveAnimation> {
  // Hérite du comportement de base sans modification
}

/// Widget d'animation de flottement - SRP: Responsable uniquement de l'animation de flottement
/// LSP: Peut être substitué par BaseFluidAnimation
/// OCP: Fermé à la modification, ouvert à l'extension via composition
class FloatAnimation extends BaseFluidAnimation {
  final double offset;

  const FloatAnimation({
    super.key,
    required super.child,
    required super.duration,
    required this.offset,
  });

  @override
  Animation<double> createAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget applyTransformation(Widget child, double value) {
    return Transform.translate(
      offset: Offset(
        0,
        sin(value) * offset,
      ),
      child: child,
    );
  }

  @override
  State<FloatAnimation> createState() => _FloatAnimationState();
}

/// État de l'animation de flottement - SRP: Responsable uniquement de la gestion de l'état de l'animation de flottement
class _FloatAnimationState extends BaseFluidAnimationState<FloatAnimation> {
  // Hérite du comportement de base sans modification
}

/// Widget d'animation de rotation douce - SRP: Responsable uniquement de l'animation de rotation
/// LSP: Peut être substitué par BaseFluidAnimation
/// OCP: Fermé à la modification, ouvert à l'extension via composition
class GentleRotationAnimation extends BaseFluidAnimation {
  final double angle;

  const GentleRotationAnimation({
    super.key,
    required super.child,
    required super.duration,
    required this.angle,
  });

  @override
  Animation<double> createAnimation(AnimationController controller) {
    return Tween<double>(
      begin: -angle,
      end: angle,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget applyTransformation(Widget child, double value) {
    return Transform.rotate(
      angle: value,
      child: child,
    );
  }

  @override
  State<GentleRotationAnimation> createState() => _GentleRotationAnimationState();
}

/// État de l'animation de rotation douce - SRP: Responsable uniquement de la gestion de l'état de l'animation de rotation
/// Override du comportement de base pour une rotation bidirectionnelle
class _GentleRotationAnimationState extends BaseFluidAnimationState<GentleRotationAnimation> {
  @override
  void _startAnimation() {
    // Rotation bidirectionnelle pour l'animation douce
    controller.repeat(reverse: true);
  }
}

/// Factory pour créer des animations fluides - SRP: Responsable uniquement de la création d'animations
/// OCP: Extensible pour de nouveaux types d'animations via de nouvelles méthodes
/// DIP: Dépend des abstractions des widgets d'animation
class FluidAnimationFactory {

  /// Crée une animation de vague avec paramètres personnalisés
  static Widget createWave({
    required Widget child,
    Duration? duration,
    double? amplitude,
    AnimationConfig? config,
  }) {
    final effectiveConfig = config ?? AnimationConfig.wave;
    return WaveAnimation(
      duration: duration ?? effectiveConfig.duration,
      amplitude: amplitude ?? 10.0,
      child: child,
    );
  }

  /// Crée une animation de flottement avec paramètres personnalisés
  static Widget createFloat({
    required Widget child,
    Duration? duration,
    double? offset,
    AnimationConfig? config,
  }) {
    final effectiveConfig = config ?? AnimationConfig.float;
    return FloatAnimation(
      duration: duration ?? effectiveConfig.duration,
      offset: offset ?? 10.0,
      child: child,
    );
  }

  /// Crée une animation de rotation douce avec paramètres personnalisés
  static Widget createGentleRotation({
    required Widget child,
    Duration? duration,
    double? angle,
    AnimationConfig? config,
  }) {
    final effectiveConfig = config ?? AnimationConfig.gentleRotation;
    return GentleRotationAnimation(
      duration: duration ?? effectiveConfig.duration,
      angle: angle ?? 0.05,
      child: child,
    );
  }

  /// Crée une combinaison d'animations fluides
  static Widget createCombined({
    required Widget child,
    bool enableWave = false,
    bool enableFloat = false,
    bool enableRotation = false,
    AnimationConfig? waveConfig,
    AnimationConfig? floatConfig,
    AnimationConfig? rotationConfig,
  }) {
    Widget result = child;

    if (enableWave) {
      result = createWave(
        child: result,
        config: waveConfig,
      );
    }

    if (enableFloat) {
      result = createFloat(
        child: result,
        config: floatConfig,
      );
    }

    if (enableRotation) {
      result = createGentleRotation(
        child: result,
        config: rotationConfig,
      );
    }

    return result;
  }
}