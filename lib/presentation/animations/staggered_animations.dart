import 'package:flutter/material.dart';

/// Animations décalées (staggered) pour les listes et grilles
/// 
/// Crée un effet d'apparition progressive des éléments pour une
/// expérience visuelle plus dynamique et engageante.
class StaggeredAnimations {
  StaggeredAnimations._();

  /// Durée de base pour chaque élément
  static const Duration itemDuration = Duration(milliseconds: 225);
  
  /// Délai entre chaque élément
  static const Duration staggerDelay = Duration(milliseconds: 50);
  
  /// Durée maximale totale (pour éviter des animations trop longues)
  static const Duration maxTotalDuration = Duration(milliseconds: 1500);
  
  /// Courbe d'animation standard
  static const Curve itemCurve = Curves.easeOutCubic;
}

/// Widget pour animer une liste avec effet staggered
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration? itemDuration;
  final Duration? staggerDelay;
  final Curve? curve;
  final Axis direction;
  final bool reverse;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDuration,
    this.staggerDelay,
    this.curve,
    this.direction = Axis.vertical,
    this.reverse = false,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    final itemDuration = widget.itemDuration ?? StaggeredAnimations.itemDuration;
    final curve = widget.curve ?? StaggeredAnimations.itemCurve;
    
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: itemDuration,
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: curve,
      ));
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      final isHorizontal = widget.direction == Axis.horizontal;
      final begin = Offset(
        isHorizontal ? (widget.reverse ? -0.3 : 0.3) : 0.0,
        isHorizontal ? 0.0 : (widget.reverse ? -0.3 : 0.3),
      );
      
      return Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: curve,
      ));
    }).toList();
  }

  void _startAnimations() async {
    final staggerDelay = widget.staggerDelay ?? StaggeredAnimations.staggerDelay;
    
    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) break;
      
      // Limiter le délai total pour éviter des animations trop longues
      final totalDelay = staggerDelay * i;
      if (totalDelay > StaggeredAnimations.maxTotalDuration) {
        // Démarrer tous les éléments restants en même temps
        for (int j = i; j < _controllers.length; j++) {
          _controllers[j].forward();
        }
        break;
      }
      
      await Future.delayed(staggerDelay);
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

/// Widget pour animer un élément individuel avec délai
class StaggeredItemAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? itemDuration;
  final Duration? staggerDelay;
  final Curve? curve;
  final bool slideFromRight;

  const StaggeredItemAnimation({
    super.key,
    required this.child,
    required this.index,
    this.itemDuration,
    this.staggerDelay,
    this.curve,
    this.slideFromRight = false,
  });

  @override
  State<StaggeredItemAnimation> createState() => _StaggeredItemAnimationState();
}

class _StaggeredItemAnimationState extends State<StaggeredItemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    final itemDuration = widget.itemDuration ?? StaggeredAnimations.itemDuration;
    final staggerDelay = widget.staggerDelay ?? StaggeredAnimations.staggerDelay;
    final curve = widget.curve ?? StaggeredAnimations.itemCurve;
    
    _controller = AnimationController(
      duration: itemDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.slideFromRight ? 0.2 : -0.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));

    // Démarrer l'animation après le délai approprié
    Future.delayed(staggerDelay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Widget pour créer une grille avec animations staggered
class StaggeredGridAnimation extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final Duration? itemDuration;
  final Duration? staggerDelay;
  final Curve? curve;

  const StaggeredGridAnimation({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.itemDuration,
    this.staggerDelay,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return StaggeredItemAnimation(
          index: index,
          itemDuration: itemDuration,
          staggerDelay: staggerDelay,
          curve: curve,
          child: children[index],
        );
      },
    );
  }
}

/// Mixin pour ajouter facilement des animations staggered à un widget
/// Note: La classe utilisant ce mixin doit aussi inclure `TickerProviderStateMixin`
mixin StaggeredAnimationMixin<T extends StatefulWidget> on State<T> {
  late List<AnimationController> staggerControllers;
  late List<Animation<double>> staggerAnimations;
  
  void initStaggeredAnimation(int itemCount, {Duration? itemDuration, Curve? curve, required TickerProvider vsync}) {
    final duration = itemDuration ?? StaggeredAnimations.itemDuration;
    final animCurve = curve ?? StaggeredAnimations.itemCurve;
    
    staggerControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        duration: duration,
        vsync: vsync,
      ),
    );

    staggerAnimations = staggerControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: animCurve,
      ));
    }).toList();
  }

  Future<void> playStaggeredAnimation({Duration? staggerDelay}) async {
    final delay = staggerDelay ?? StaggeredAnimations.staggerDelay;
    
    for (int i = 0; i < staggerControllers.length; i++) {
      if (!mounted) break;
      
      final totalDelay = delay * i;
      if (totalDelay > StaggeredAnimations.maxTotalDuration) {
        for (int j = i; j < staggerControllers.length; j++) {
          staggerControllers[j].forward();
        }
        break;
      }
      
      await Future.delayed(delay);
      if (mounted) {
        staggerControllers[i].forward();
      }
    }
  }

  void reverseStaggeredAnimation({Duration? staggerDelay}) async {
    final delay = staggerDelay ?? StaggeredAnimations.staggerDelay;
    
    for (int i = staggerControllers.length - 1; i >= 0; i--) {
      if (!mounted) break;
      
      await Future.delayed(delay);
      if (mounted) {
        staggerControllers[i].reverse();
      }
    }
  }

  void disposeStaggeredAnimation() {
    for (final controller in staggerControllers) {
      controller.dispose();
    }
  }
}