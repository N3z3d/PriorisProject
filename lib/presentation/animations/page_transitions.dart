import 'package:flutter/material.dart';

/// Animations de transition personnalisées entre les pages
/// 
/// Ce fichier contient toutes les animations de transition utilisées
/// dans l'application pour créer une expérience fluide et premium.
class PageTransitions {
  PageTransitions._();

  /// Durée standard des transitions
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 450);
  static const Duration fastDuration = Duration(milliseconds: 200);

  /// Courbes d'animation standards
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;

  /// Transition Slide depuis la droite (navigation standard)
  static Route<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: defaultDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: defaultCurve)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Transition Slide depuis le bas (modales, bottom sheets)
  static Route<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: defaultDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: enterCurve)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Transition Fade (changement de contexte)
  static Route<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: defaultDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: defaultCurve),
          ),
          child: child,
        );
      },
    );
  }

  /// Transition Scale + Fade (éléments hero)
  static Route<T> scaleAndFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: slowDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.95;
        const end = 1.0;
        final scaleTween = Tween(begin: begin, end: end);
        final fadeTween = Tween(begin: 0.0, end: 1.0);

        final scaleAnimation = animation.drive(
          scaleTween.chain(CurveTween(curve: enterCurve)),
        );
        final fadeAnimation = animation.drive(
          fadeTween.chain(CurveTween(curve: defaultCurve)),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition Rotation + Scale (éléments ludiques)
  static Route<T> rotateAndScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: slowDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        final scaleTween = Tween(begin: begin, end: end);
        final rotateTween = Tween(begin: -0.05, end: 0.0);

        final scaleAnimation = animation.drive(
          scaleTween.chain(CurveTween(curve: enterCurve)),
        );
        final rotateAnimation = animation.drive(
          rotateTween.chain(CurveTween(curve: Curves.elasticOut)),
        );

        return RotationTransition(
          turns: rotateAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition SharedAxis (Material Design)
  static Route<T> sharedAxisHorizontal<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: defaultDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: _SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }

  /// Transition SharedAxis Vertical
  static Route<T> sharedAxisVertical<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: defaultDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: _SharedAxisTransitionType.vertical,
          child: child,
        );
      },
    );
  }

  /// Transition Container Transform (élément vers page)
  static Route<T> containerTransform<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: slowDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginRadius = 12.0;
        const endRadius = 0.0;
        final radiusTween = Tween(begin: beginRadius, end: endRadius);
        final fadeTween = Tween(begin: 0.0, end: 1.0);

        final radiusAnimation = animation.drive(
          radiusTween.chain(CurveTween(curve: enterCurve)),
        );
        final fadeAnimation = animation.drive(
          fadeTween.chain(CurveTween(curve: defaultCurve)),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radiusAnimation.value),
            child: child,
          ),
        );
      },
    );
  }

  /// Transition parallaxe (effet de profondeur)
  static Route<T> parallax<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: slowDuration,
      reverseTransitionDuration: defaultDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Page entrante
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final primaryTween = Tween(begin: begin, end: end);
        final primaryAnimation = animation.drive(
          primaryTween.chain(CurveTween(curve: enterCurve)),
        );

        // Page sortante (effet parallaxe)
        const secondaryBegin = Offset.zero;
        const secondaryEnd = Offset(-0.3, 0.0);
        final secondaryTween = Tween(begin: secondaryBegin, end: secondaryEnd);
        final secondaryOffsetAnimation = secondaryAnimation.drive(
          secondaryTween.chain(CurveTween(curve: exitCurve)),
        );

        return SlideTransition(
          position: primaryAnimation,
          child: SlideTransition(
            position: secondaryOffsetAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Type de transition SharedAxis
enum _SharedAxisTransitionType {
  horizontal,
  vertical,
}

/// Widget pour les transitions SharedAxis
class _SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final _SharedAxisTransitionType transitionType;
  final Widget child;

  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = transitionType == _SharedAxisTransitionType.horizontal;
    
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (context, animation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: Offset(isHorizontal ? 1.0 : 0.0, isHorizontal ? 0.0 : 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: PageTransitions.enterCurve)),
          ),
          child: FadeTransition(
            opacity: animation.drive(
              Tween<double>(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.linear),
              ),
            ),
            child: child,
          ),
        );
      },
      reverseBuilder: (context, animation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: Offset.zero,
              end: Offset(isHorizontal ? -0.3 : 0.0, isHorizontal ? 0.0 : -0.3),
            ).chain(CurveTween(curve: PageTransitions.exitCurve)),
          ),
          child: FadeTransition(
            opacity: animation.drive(
              Tween<double>(begin: 1.0, end: 0.0).chain(
                CurveTween(curve: Curves.linear),
              ),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Builder pour gérer les transitions bidirectionnelles
class DualTransitionBuilder extends StatefulWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Animation<double>, Widget?) forwardBuilder;
  final Widget Function(BuildContext, Animation<double>, Widget?) reverseBuilder;
  final Widget child;

  const DualTransitionBuilder({
    super.key,
    required this.animation,
    required this.forwardBuilder,
    required this.reverseBuilder,
    required this.child,
  });

  @override
  State<DualTransitionBuilder> createState() => _DualTransitionBuilderState();
}

class _DualTransitionBuilderState extends State<DualTransitionBuilder> {
  late AnimationStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.animation.status;
    widget.animation.addStatusListener(_statusListener);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_statusListener);
    super.dispose();
  }

  void _statusListener(AnimationStatus status) {
    if (status != _status) {
      setState(() {
        _status = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isForward = _status == AnimationStatus.forward || 
                      _status == AnimationStatus.completed;
    
    return isForward
        ? widget.forwardBuilder(context, widget.animation, widget.child)
        : widget.reverseBuilder(context, widget.animation, widget.child);
  }
}

/// Extension pour faciliter l'utilisation avec Navigator
extension NavigatorStateExtension on NavigatorState {
  /// Push avec animation slide depuis la droite
  Future<T?> pushSlideFromRight<T>(Widget page) {
    return push<T>(PageTransitions.slideFromRight<T>(page));
  }

  /// Push avec animation fade
  Future<T?> pushFade<T>(Widget page) {
    return push<T>(PageTransitions.fade<T>(page));
  }

  /// Push avec animation scale et fade
  Future<T?> pushScaleAndFade<T>(Widget page) {
    return push<T>(PageTransitions.scaleAndFade<T>(page));
  }

  /// Push avec animation parallaxe
  Future<T?> pushParallax<T>(Widget page) {
    return push<T>(PageTransitions.parallax<T>(page));
  }
}