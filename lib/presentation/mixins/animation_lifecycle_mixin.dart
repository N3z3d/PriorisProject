import 'package:flutter/material.dart';

/// Mixin pour gérer le cycle de vie des AnimationControllers
/// Assure la disposition correcte et l'arrêt des animations
mixin AnimationLifecycleMixin<T extends StatefulWidget> on State<T> {
  final List<AnimationController> _controllers = [];
  bool _isVisible = true;

  /// Enregistre un AnimationController pour la gestion automatique
  void registerAnimationController(AnimationController controller) {
    _controllers.add(controller);
  }

  /// Démarre toutes les animations enregistrées
  void startAllAnimations() {
    if (!_isVisible) return;
    for (final controller in _controllers) {
      if (!controller.isAnimating) {
        controller.forward();
      }
    }
  }

  /// Arrête toutes les animations enregistrées
  void stopAllAnimations() {
    for (final controller in _controllers) {
      controller.stop();
    }
  }

  /// Réinitialise toutes les animations
  void resetAllAnimations() {
    for (final controller in _controllers) {
      controller.reset();
    }
  }

  /// Gère la visibilité du widget
  void onVisibilityChanged(bool visible) {
    _isVisible = visible;
    if (visible) {
      startAllAnimations();
    } else {
      stopAllAnimations();
    }
  }

  @override
  void dispose() {
    // Arrêter et disposer tous les controllers
    for (final controller in _controllers) {
      controller.stop();
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}

/// Widget pour détecter la visibilité et gérer les animations
class VisibilityAwareAnimationWidget extends StatefulWidget {
  final Widget child;
  final Function(bool visible)? onVisibilityChanged;

  const VisibilityAwareAnimationWidget({
    super.key,
    required this.child,
    this.onVisibilityChanged,
  });

  @override
  State<VisibilityAwareAnimationWidget> createState() => 
      _VisibilityAwareAnimationWidgetState();
}

class _VisibilityAwareAnimationWidgetState 
    extends State<VisibilityAwareAnimationWidget> 
    with WidgetsBindingObserver {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkVisibility();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isVisible = state == AppLifecycleState.resumed;
    if (_isVisible != isVisible) {
      setState(() {
        _isVisible = isVisible;
      });
      widget.onVisibilityChanged?.call(isVisible);
    }
  }

  void _checkVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final renderObject = context.findRenderObject();
      if (renderObject != null) {
        final isVisible = renderObject.attached;
        if (_isVisible != isVisible) {
          setState(() {
            _isVisible = isVisible;
          });
          widget.onVisibilityChanged?.call(isVisible);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension pour faciliter l'utilisation des AnimationControllers
extension AnimationControllerExtension on AnimationController {
  /// Répète l'animation de manière sûre
  void safeRepeat({bool? reverse, double? min, double? max}) {
    if (!isDisposed) {
      repeat(reverse: reverse ?? false, min: min, max: max);
    }
  }

  /// Avance l'animation de manière sûre
  TickerFuture safeForward({double? from}) {
    if (!isDisposed) {
      return forward(from: from);
    }
    return TickerFuture.complete();
  }

  /// Inverse l'animation de manière sûre
  TickerFuture safeReverse({double? from}) {
    if (!isDisposed) {
      return reverse(from: from);
    }
    return TickerFuture.complete();
  }

  /// Arrête l'animation de manière sûre
  void safeStop({bool canceled = true}) {
    if (!isDisposed) {
      stop(canceled: canceled);
    }
  }

  /// Réinitialise l'animation de manière sûre
  void safeReset() {
    if (!isDisposed) {
      reset();
    }
  }

  /// Vérifie si le controller est disposé
  bool get isDisposed {
    try {
      // Si on peut accéder à la valeur, le controller n'est pas disposé
      final _ = value;
      return false;
    } catch (_) {
      // Si une exception est levée, le controller est disposé
      return true;
    }
  }
}