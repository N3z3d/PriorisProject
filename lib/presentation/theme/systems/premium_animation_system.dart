import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';

/// Premium Animation System - Handles animations and micro-interactions following SRP
/// Responsibility: All premium animations, transitions, and physics-based interactions
class PremiumAnimationSystem implements IPremiumAnimationSystem {
  bool _isInitialized = false;

  // Animation configuration constants
  static const Duration _defaultDuration = Duration(milliseconds: 300);
  static const Duration _fastDuration = Duration(milliseconds: 150);
  static const Duration _slowDuration = Duration(milliseconds: 500);

  static const double _defaultScale = 0.95;
  static const double _defaultElasticity = 0.8;
  static const double _defaultGravity = 1.0;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ PHYSICS ANIMATIONS ============

  @override
  Widget createSpringScale({
    required Widget child,
    VoidCallback? onTap,
    double scale = _defaultScale,
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();

    if (onTap == null) {
      return child; // Return plain child if no tap callback
    }

    return PhysicsAnimations.springScale(
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget createElasticBounce({
    required Widget child,
    bool trigger = false,
    double elasticity = _defaultElasticity,
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();

    return PhysicsAnimations.elasticBounce(
      trigger: trigger,
      child: child,
    );
  }

  @override
  Widget createGravityBounce({
    required Widget child,
    bool trigger = false,
    double gravity = _defaultGravity,
    Duration duration = _slowDuration,
  }) {
    _ensureInitialized();

    return PhysicsAnimations.gravityBounce(
      trigger: trigger,
      child: child,
    );
  }

  // ============ TRANSITION ANIMATIONS ============

  @override
  Widget createFadeTransition({
    required Widget child,
    bool trigger = true,
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();

    return _FadeTransitionWidget(
      trigger: trigger,
      duration: duration,
      child: child,
    );
  }

  @override
  Widget createSlideTransition({
    required Widget child,
    bool trigger = true,
    Offset offset = const Offset(0, 1),
    Duration duration = _defaultDuration,
  }) {
    _ensureInitialized();

    return _SlideTransitionWidget(
      trigger: trigger,
      offset: offset,
      duration: duration,
      child: child,
    );
  }

  // ============ ADVANCED ANIMATIONS ============

  /// Creates a staggered animation for lists
  Widget createStaggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = _defaultDuration,
    Curve curve = Curves.easeOutBack,
  }) {
    _ensureInitialized();

    return _StaggeredListWidget(
      staggerDelay: staggerDelay,
      itemDuration: itemDuration,
      curve: curve,
      children: children,
    );
  }

  /// Creates a pulse animation
  Widget createPulse({
    required Widget child,
    bool trigger = true,
    double minScale = 0.95,
    double maxScale = 1.05,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    _ensureInitialized();

    return _PulseWidget(
      trigger: trigger,
      minScale: minScale,
      maxScale: maxScale,
      duration: duration,
      child: child,
    );
  }

  /// Creates a shake animation
  Widget createShake({
    required Widget child,
    bool trigger = false,
    double offset = 10.0,
    int count = 3,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _ensureInitialized();

    return _ShakeWidget(
      trigger: trigger,
      offset: offset,
      count: count,
      duration: duration,
      child: child,
    );
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumAnimationSystem must be initialized before use.');
    }
  }
}

// ============ INTERNAL ANIMATION WIDGETS ============

/// Internal fade transition widget
class _FadeTransitionWidget extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;

  const _FadeTransitionWidget({
    required this.child,
    required this.trigger,
    required this.duration,
  });

  @override
  State<_FadeTransitionWidget> createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<_FadeTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.trigger) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_FadeTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      if (widget.trigger) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
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
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: widget.child,
      ),
    );
  }
}

/// Internal slide transition widget
class _SlideTransitionWidget extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Offset offset;
  final Duration duration;

  const _SlideTransitionWidget({
    required this.child,
    required this.trigger,
    required this.offset,
    required this.duration,
  });

  @override
  State<_SlideTransitionWidget> createState() => _SlideTransitionWidgetState();
}

class _SlideTransitionWidgetState extends State<_SlideTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.trigger) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_SlideTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      if (widget.trigger) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// Internal staggered list widget
class _StaggeredListWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;

  const _StaggeredListWidget({
    required this.children,
    required this.staggerDelay,
    required this.itemDuration,
    required this.curve,
  });

  @override
  State<_StaggeredListWidget> createState() => _StaggeredListWidgetState();
}

class _StaggeredListWidgetState extends State<_StaggeredListWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(duration: widget.itemDuration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: controller, curve: widget.curve));
    }).toList();

    _startStaggeredAnimation();
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
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
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

/// Internal pulse widget
class _PulseWidget extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const _PulseWidget({
    required this.child,
    required this.trigger,
    required this.minScale,
    required this.maxScale,
    required this.duration,
  });

  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.trigger) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      if (widget.trigger) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
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
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: widget.child,
      ),
    );
  }
}

/// Internal shake widget
class _ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final double offset;
  final int count;
  final Duration duration;

  const _ShakeWidget({
    required this.child,
    required this.trigger,
    required this.offset,
    required this.count,
    required this.duration,
  });

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(_ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger) {
      _shake();
    }
  }

  void _shake() {
    _controller.reset();
    _controller.repeat(reverse: true, period: Duration(
      milliseconds: widget.duration.inMilliseconds ~/ (widget.count * 2),
    ));

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reset();
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
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_animation.value * widget.offset, 0),
        child: widget.child,
      ),
    );
  }
}