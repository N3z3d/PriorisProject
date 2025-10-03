import 'package:flutter/material.dart';

/// Internal staggered entrance widget implementation
class StaggeredEntranceWidget extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const StaggeredEntranceWidget({
    super.key,
    required this.child,
    required this.index,
    required this.delay,
    required this.duration,
  });

  @override
  State<StaggeredEntranceWidget> createState() => _StaggeredEntranceWidgetState();
}

class _StaggeredEntranceWidgetState extends State<StaggeredEntranceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay * widget.index, () {
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
            child: widget.child,
          ),
        );
      },
    );
  }
}
