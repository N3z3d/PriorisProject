import 'package:flutter/material.dart';

/// Premium Transition Animation Builder - Handles transition animations
/// Responsibility: Fade and slide transition builders
class PremiumTransitionAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// Creates a fade transition animation
  static Widget fade({
    required Widget child,
    bool trigger = true,
    Duration duration = defaultDuration,
  }) {
    return _FadeTransitionWidget(
      trigger: trigger,
      duration: duration,
      child: child,
    );
  }

  /// Creates a slide transition animation
  static Widget slide({
    required Widget child,
    bool trigger = true,
    Offset offset = const Offset(0, 1),
    Duration duration = defaultDuration,
  }) {
    return _SlideTransitionWidget(
      trigger: trigger,
      offset: offset,
      duration: duration,
      child: child,
    );
  }
}

// ============ INTERNAL TRANSITION WIDGETS ============

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
    _animation = _createFadeAnimation();

    if (widget.trigger) {
      _controller.forward();
    }
  }

  Animation<double> _createFadeAnimation() {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_FadeTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _handleTriggerChange();
    }
  }

  void _handleTriggerChange() {
    if (widget.trigger) {
      _controller.forward();
    } else {
      _controller.reverse();
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
    _animation = _createSlideAnimation();

    if (widget.trigger) {
      _controller.forward();
    }
  }

  Animation<Offset> _createSlideAnimation() {
    return Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_SlideTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _handleTriggerChange();
    }
  }

  void _handleTriggerChange() {
    if (widget.trigger) {
      _controller.forward();
    } else {
      _controller.reverse();
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
