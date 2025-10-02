import 'package:flutter/material.dart';

/// Premium Advanced Animation Builder - Handles complex animations
/// Responsibility: Staggered, pulse, and shake animation builders
class PremiumAdvancedAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// Creates a staggered animation for lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = defaultDuration,
    Curve curve = Curves.easeOutBack,
  }) {
    return _StaggeredListWidget(
      staggerDelay: staggerDelay,
      itemDuration: itemDuration,
      curve: curve,
      children: children,
    );
  }

  /// Creates a pulse animation
  static Widget pulse({
    required Widget child,
    bool trigger = true,
    double minScale = 0.95,
    double maxScale = 1.05,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return _PulseWidget(
      trigger: trigger,
      minScale: minScale,
      maxScale: maxScale,
      duration: duration,
      child: child,
    );
  }

  /// Creates a shake animation
  static Widget shake({
    required Widget child,
    bool trigger = false,
    double offset = 10.0,
    int count = 3,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return _ShakeWidget(
      trigger: trigger,
      offset: offset,
      count: count,
      duration: duration,
      child: child,
    );
  }
}

// ============ INTERNAL ADVANCED ANIMATION WIDGETS ============

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
    _initializeControllers();
    _createAnimations();
    _startStaggeredAnimation();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.itemDuration,
        vsync: this,
      ),
    );
  }

  void _createAnimations() {
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();
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
      children: List.generate(
        widget.children.length,
        (index) => _buildStaggeredItem(index),
      ),
    );
  }

  Widget _buildStaggeredItem(int index) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        final animationValue = _animations[index].value;
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: widget.children[index],
          ),
        );
      },
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
    _animation = _createPulseAnimation();

    if (widget.trigger) {
      _controller.repeat(reverse: true);
    }
  }

  Animation<double> _createPulseAnimation() {
    return Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_PulseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _handleTriggerChange();
    }
  }

  void _handleTriggerChange() {
    if (widget.trigger) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
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
    _controller.repeat(
      reverse: true,
      period: Duration(
        milliseconds: widget.duration.inMilliseconds ~/ (widget.count * 2),
      ),
    );

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
