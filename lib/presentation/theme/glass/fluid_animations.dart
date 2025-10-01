import 'package:flutter/material.dart';

/// Interface pour les animations fluides - ISP Compliance
abstract class IFluidAnimations {
  Widget wave({
    required Widget child,
    Duration duration,
    double amplitude,
  });

  Widget float({
    required Widget child,
    Duration duration,
    double offset,
  });

  Widget gentleRotation({
    required Widget child,
    Duration duration,
    double angle,
  });
}

/// Gestionnaire d'animations fluides prédéfinies - SRP: Responsable uniquement de la création d'animations fluides
/// OCP: Extensible via l'interface IFluidAnimations pour de nouveaux types d'animations
/// DIP: Dépend de l'abstraction IFluidAnimations
///
/// Note: Cette classe fournit l'interface. Les implémentations sont dans animation_widgets.dart
class FluidAnimations implements IFluidAnimations {

  /// Animation de vague
  @override
  Widget wave({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double amplitude = 10.0,
  }) {
    // Cette méthode est implémentée dans FluidAnimationFactory
    // Pour éviter la dépendance circulaire, nous retournons un Placeholder
    return Placeholder(
      child: Text('WaveAnimation not implemented in base class'),
    );
  }

  /// Animation de flottement
  @override
  Widget float({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    double offset = 10.0,
  }) {
    // Cette méthode est implémentée dans FluidAnimationFactory
    // Pour éviter la dépendance circulaire, nous retournons un Placeholder
    return Placeholder(
      child: Text('FloatAnimation not implemented in base class'),
    );
  }

  /// Animation de rotation douce
  @override
  Widget gentleRotation({
    required Widget child,
    Duration duration = const Duration(seconds: 10),
    double angle = 0.05,
  }) {
    // Cette méthode est implémentée dans FluidAnimationFactory
    // Pour éviter la dépendance circulaire, nous retournons un Placeholder
    return Placeholder(
      child: Text('GentleRotationAnimation not implemented in base class'),
    );
  }
}

/// Configuration pour une animation fluide - SRP: Responsable uniquement de la configuration d'animation
/// OCP: Extensible pour ajouter de nouveaux paramètres d'animation
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final bool repeat;
  final bool reverse;

  const AnimationConfig({
    required this.duration,
    this.curve = Curves.linear,
    this.repeat = true,
    this.reverse = false,
  });

  /// Configuration par défaut pour les animations de vague
  static const AnimationConfig wave = AnimationConfig(
    duration: Duration(seconds: 3),
    curve: Curves.linear,
    repeat: true,
  );

  /// Configuration par défaut pour les animations de flottement
  static const AnimationConfig float = AnimationConfig(
    duration: Duration(seconds: 4),
    curve: Curves.easeInOut,
    repeat: true,
  );

  /// Configuration par défaut pour les rotations douces
  static const AnimationConfig gentleRotation = AnimationConfig(
    duration: Duration(seconds: 10),
    curve: Curves.easeInOut,
    repeat: true,
    reverse: true,
  );
}

/// Base abstraite pour les animations fluides - SRP: Responsable uniquement du comportement de base des animations
/// LSP: Toute sous-classe peut être substituée à cette classe de base
/// DIP: Les classes concrètes dépendent de cette abstraction
abstract class BaseFluidAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BaseFluidAnimation({
    super.key,
    required this.child,
    required this.duration,
  });

  /// Méthode template pour créer l'animation - Template Method Pattern
  Animation<double> createAnimation(AnimationController controller);

  /// Méthode template pour appliquer la transformation - Template Method Pattern
  Widget applyTransformation(Widget child, double value);
}

/// État de base pour les animations fluides - SRP: Responsable uniquement de la gestion du cycle de vie des animations
/// Template Method Pattern: Définit la structure commune pour toutes les animations fluides
abstract class BaseFluidAnimationState<T extends BaseFluidAnimation>
    extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Getter pour accéder au contrôleur depuis les sous-classes
  AnimationController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _animation = widget.createAnimation(_controller);
    _startAnimation();
  }

  /// Initialise le contrôleur d'animation - SRP: Responsable uniquement de l'initialisation du contrôleur
  void _initializeController() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  /// Démarre l'animation selon la configuration - SRP: Responsable uniquement du démarrage de l'animation
  /// Cette méthode peut être surchargée par les sous-classes pour des comportements spécifiques
  void _startAnimation() {
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return widget.applyTransformation(widget.child, _animation.value);
      },
    );
  }
}