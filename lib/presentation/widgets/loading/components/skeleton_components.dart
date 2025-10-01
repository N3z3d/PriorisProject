import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Core skeleton box component - Single Responsibility: Basic skeleton shape
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Color? color;
  final EdgeInsets margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    required this.borderRadius,
    this.color,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (isDark ? Colors.grey[800] : Colors.grey[300]),
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Enhanced skeleton container with animation - Single Responsibility: Animation management
class SkeletonContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Duration animationDuration;
  final bool enableAnimation;
  final Color? backgroundColor;
  final Color? borderColor;

  const SkeletonContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    required this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.animationDuration = const Duration(milliseconds: 1500),
    this.enableAnimation = true,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.enableAnimation) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? (isDark ? Colors.grey[850] : Colors.grey[100]),
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: widget.borderColor ?? (isDark ? Colors.grey[700]! : Colors.grey[200]!),
          width: 1,
        ),
      ),
      child: widget.enableAnimation
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return AnimatedOpacity(
                  opacity: 0.7 + (0.3 * _animationController.value),
                  duration: const Duration(milliseconds: 100),
                  child: widget.child,
                );
              },
            )
          : widget.child,
    );
  }
}

/// Factory for creating common skeleton shapes - Single Responsibility: Shape creation
class SkeletonShapeFactory {
  static SkeletonBox rectangular({
    double? width,
    double? height,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.radiusXs,
      margin: margin,
      color: color,
    );
  }

  static SkeletonBox circular({
    required double size,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: BorderRadiusTokens.radiusCircular,
      margin: margin,
      color: color,
    );
  }

  static SkeletonBox rounded({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadiusTokens.radiusSm,
      margin: margin,
      color: color,
    );
  }

  static SkeletonBox text({
    double? width,
    double height = 16,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.radiusXs,
      margin: margin,
      color: color,
    );
  }

  static SkeletonBox button({
    double? width,
    double height = 48,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.button,
      margin: margin,
      color: color,
    );
  }

  static SkeletonBox input({
    double? width,
    double height = 48,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.input,
      margin: margin,
      color: color,
    );
  }

  static SkeletonBox badge({
    double? width,
    double height = 24,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.badge,
      margin: margin,
      color: color,
    );
  }

  static SkeletonBox progressBar({
    double? width,
    double height = 4,
    EdgeInsets margin = EdgeInsets.zero,
    Color? color,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.progressBar,
      margin: margin,
      color: color,
    );
  }
}

/// Layout helper for creating common skeleton patterns - Single Responsibility: Layout patterns
class SkeletonLayoutBuilder {
  /// Creates a horizontal layout with skeleton elements
  static Widget horizontal({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = 8,
  }) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }

  /// Creates a vertical layout with skeleton elements
  static Widget vertical({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    double spacing = 8,
  }) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }

  /// Creates a grid layout with skeleton elements
  static Widget grid({
    required List<Widget> children,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
    double spacing = 12,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Creates a list layout with skeleton elements
  static Widget list({
    required List<Widget> children,
    double spacing = 12,
    bool shrinkWrap = true,
    ScrollPhysics? physics = const NeverScrollableScrollPhysics(),
  }) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => children[index],
    );
  }
}