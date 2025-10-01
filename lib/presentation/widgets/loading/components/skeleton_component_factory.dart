/// SOLID Implementation: Skeleton Component Factory
///
/// Factory Pattern implementation for creating skeleton components.
/// RESPONSIBILITY: Create individual skeleton components with proper styling.
/// CONSTRAINT: <200 lines following Clean Code requirements.

import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interfaces.dart';

/// Concrete factory for skeleton components
/// SOLID COMPLIANCE: SRP - Single responsibility for component creation
class SkeletonComponentFactory implements ISkeletonComponentFactory {
  static const Duration defaultAnimationDuration = Duration(milliseconds: 1500);

  @override
  List<String> get supportedTypes => [
    'box',
    'circle',
    'line',
    'text',
    'button',
    'card',
    'avatar',
    'image',
    'icon',
  ];

  @override
  Widget createBasicComponent({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Map<String, dynamic>? options,
  }) {
    final componentType = options?['type'] ?? 'box';
    final isDark = options?['isDark'] ?? false;

    switch (componentType) {
      case 'circle':
        return _createCircleComponent(width, height, isDark);
      case 'line':
        return _createLineComponent(width, height, isDark, borderRadius);
      case 'text':
        return _createTextComponent(width, height, isDark, options);
      case 'button':
        return _createButtonComponent(width, height, isDark);
      case 'card':
        return _createCardComponent(width, height, isDark);
      case 'avatar':
        return _createAvatarComponent(width ?? height, isDark);
      case 'image':
        return _createImageComponent(width, height, isDark, borderRadius);
      case 'icon':
        return _createIconComponent(width ?? 24, isDark);
      default:
        return _createBoxComponent(width, height, isDark, borderRadius);
    }
  }

  @override
  Widget createAnimatedComponent({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Duration? animationDuration,
    Map<String, dynamic>? options,
  }) {
    final basicComponent = createBasicComponent(
      width: width,
      height: height,
      borderRadius: borderRadius,
      options: options,
    );

    return _AnimatedSkeletonWrapper(
      duration: animationDuration ?? defaultAnimationDuration,
      child: basicComponent,
    );
  }

  // --- Private component creation methods ---

  Widget _createBoxComponent(
    double? width,
    double? height,
    bool isDark,
    BorderRadius? borderRadius,
  ) {
    return Container(
      width: width,
      height: height ?? 20,
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark),
        borderRadius: borderRadius ?? BorderRadiusTokens.radiusXs,
      ),
    );
  }

  Widget _createCircleComponent(double? width, double? height, bool isDark) {
    final size = width ?? height ?? 40.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _createLineComponent(
    double? width,
    double? height,
    bool isDark,
    BorderRadius? borderRadius,
  ) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark),
        borderRadius: borderRadius ?? BorderRadiusTokens.radiusXs,
      ),
    );
  }

  Widget _createTextComponent(
    double? width,
    double? height,
    bool isDark,
    Map<String, dynamic>? options,
  ) {
    final lines = options?['lines'] ?? 1;

    if (lines == 1) {
      return _createLineComponent(width, height ?? 16, isDark, null);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final lineWidth = isLastLine ? (width ?? 200) * 0.6 : width;

        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 8.0 : 0),
          child: _createLineComponent(lineWidth, height ?? 16, isDark, null),
        );
      }),
    );
  }

  Widget _createButtonComponent(double? width, double? height, bool isDark) {
    return Container(
      width: width ?? 120,
      height: height ?? 40,
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark),
        borderRadius: BorderRadiusTokens.button,
      ),
    );
  }

  Widget _createCardComponent(double? width, double? height, bool isDark) {
    return Container(
      width: width,
      height: height ?? 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark, isCard: true),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: _getBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _createLineComponent(double.infinity, 20, isDark, null),
          const SizedBox(height: 12),
          _createLineComponent(200, 16, isDark, null),
          const SizedBox(height: 8),
          _createLineComponent(150, 16, isDark, null),
        ],
      ),
    );
  }

  Widget _createAvatarComponent(double? size, bool isDark) {
    return Container(
      width: size ?? 40,
      height: size ?? 40,
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _createImageComponent(
    double? width,
    double? height,
    bool isDark,
    BorderRadius? borderRadius,
  ) {
    return Container(
      width: width ?? 100,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark),
        borderRadius: borderRadius ?? BorderRadiusTokens.radiusSm,
      ),
      child: Icon(
        Icons.image_outlined,
        color: _getBorderColor(isDark),
        size: 24,
      ),
    );
  }

  Widget _createIconComponent(double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getSkeletonColor(isDark),
        borderRadius: BorderRadiusTokens.radiusXs,
      ),
    );
  }

  // --- Helper methods ---

  Color _getSkeletonColor(bool isDark, {bool isCard = false}) {
    if (isDark) {
      return isCard ? Colors.grey[850]! : Colors.grey[800]!;
    } else {
      return isCard ? Colors.grey[100]! : Colors.grey[300]!;
    }
  }

  Color _getBorderColor(bool isDark) {
    return isDark ? Colors.grey[700]! : Colors.grey[200]!;
  }
}

/// Animated wrapper for skeleton components
/// SOLID COMPLIANCE: SRP - Single responsibility for animation
class _AnimatedSkeletonWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _AnimatedSkeletonWrapper({
    required this.child,
    required this.duration,
  });

  @override
  State<_AnimatedSkeletonWrapper> createState() => _AnimatedSkeletonWrapperState();
}

class _AnimatedSkeletonWrapperState extends State<_AnimatedSkeletonWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
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