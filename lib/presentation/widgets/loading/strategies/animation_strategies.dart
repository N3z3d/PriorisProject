import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/specialized_skeleton_interfaces.dart';

/// Shimmer animation strategy following Strategy pattern
/// Single Responsibility: Applies shimmer animation to skeletons
class ShimmerAnimationStrategy implements ISkeletonAnimationStrategy {
  @override
  String get strategyId => 'shimmer';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 1500);

  @override
  Widget applyAnimation(Widget skeleton, SkeletonConfig config) {
    final duration = config.animationDuration ?? defaultDuration;

    return _ShimmerWidget(
      duration: duration,
      child: skeleton,
    );
  }

  @override
  bool supportsSkeletonType(String skeletonType) {
    // Shimmer works well with all skeleton types
    return true;
  }
}

/// Pulse animation strategy following Strategy pattern
/// Single Responsibility: Applies pulse animation to skeletons
class PulseAnimationStrategy implements ISkeletonAnimationStrategy {
  @override
  String get strategyId => 'pulse';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 1200);

  @override
  Widget applyAnimation(Widget skeleton, SkeletonConfig config) {
    final duration = config.animationDuration ?? defaultDuration;

    return _PulseWidget(
      duration: duration,
      child: skeleton,
    );
  }

  @override
  bool supportsSkeletonType(String skeletonType) {
    // Pulse works well with compact skeletons
    return ['dashboard', 'list', 'settings'].contains(skeletonType);
  }
}

/// Wave animation strategy following Strategy pattern
/// Single Responsibility: Applies wave animation to skeletons
class WaveAnimationStrategy implements ISkeletonAnimationStrategy {
  @override
  String get strategyId => 'wave';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 2000);

  @override
  Widget applyAnimation(Widget skeleton, SkeletonConfig config) {
    final duration = config.animationDuration ?? defaultDuration;

    return _WaveWidget(
      duration: duration,
      child: skeleton,
    );
  }

  @override
  bool supportsSkeletonType(String skeletonType) {
    // Wave works well with profile and detail pages
    return ['profile', 'detail', 'modal'].contains(skeletonType);
  }
}

/// Fade animation strategy following Strategy pattern
/// Single Responsibility: Applies fade animation to skeletons
class FadeAnimationStrategy implements ISkeletonAnimationStrategy {
  @override
  String get strategyId => 'fade';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 800);

  @override
  Widget applyAnimation(Widget skeleton, SkeletonConfig config) {
    final duration = config.animationDuration ?? defaultDuration;

    return _FadeWidget(
      duration: duration,
      child: skeleton,
    );
  }

  @override
  bool supportsSkeletonType(String skeletonType) {
    // Fade works well with navigation and modal skeletons
    return ['navigation', 'modal', 'sheet'].contains(skeletonType);
  }
}

/// No animation strategy following Strategy pattern
/// Single Responsibility: Provides static skeletons without animation
class NoAnimationStrategy implements ISkeletonAnimationStrategy {
  @override
  String get strategyId => 'none';

  @override
  Duration get defaultDuration => Duration.zero;

  @override
  Widget applyAnimation(Widget skeleton, SkeletonConfig config) {
    return skeleton; // No animation applied
  }

  @override
  bool supportsSkeletonType(String skeletonType) {
    // No animation supports all skeleton types
    return true;
  }
}

/// Factory for creating animation strategies following Factory pattern
/// Single Responsibility: Creates animation strategy instances
class SkeletonAnimationStrategyFactory {
  static const Map<String, ISkeletonAnimationStrategy Function()> _strategies = {
    'shimmer': () => ShimmerAnimationStrategy(),
    'pulse': () => PulseAnimationStrategy(),
    'wave': () => WaveAnimationStrategy(),
    'fade': () => FadeAnimationStrategy(),
    'none': () => NoAnimationStrategy(),
  };

  /// Creates animation strategy by ID
  static ISkeletonAnimationStrategy create(String strategyId) {
    final factory = _strategies[strategyId];
    if (factory == null) {
      throw ArgumentError('Unknown animation strategy: $strategyId');
    }
    return factory();
  }

  /// Gets all available strategy IDs
  static List<String> get availableStrategies => _strategies.keys.toList();

  /// Validates if a strategy ID is supported
  static bool isStrategySupported(String strategyId) {
    return _strategies.containsKey(strategyId);
  }

  /// Gets recommended strategy for skeleton type
  static String getRecommendedStrategy(String skeletonType) {
    for (final strategyId in _strategies.keys) {
      final strategy = create(strategyId);
      if (strategy.supportsSkeletonType(skeletonType)) {
        return strategyId;
      }
    }
    return 'shimmer'; // Default fallback
  }
}

// Private animation widget implementations

class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _ShimmerWidget({
    required this.child,
    required this.duration,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _PulseWidget({
    required this.child,
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
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
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
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class _WaveWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _WaveWidget({
    required this.child,
    required this.duration,
  });

  @override
  State<_WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<_WaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.translate(
          offset: Offset(0, 10 * (0.5 - (_animation.value - 0.5).abs())),
          child: widget.child,
        );
      },
    );
  }
}

class _FadeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _FadeWidget({
    required this.child,
    required this.duration,
  });

  @override
  State<_FadeWidget> createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<_FadeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
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
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}