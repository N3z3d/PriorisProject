import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';

/// Grid skeleton system producing grid-based placeholders.
class GridSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  static const _supportedTypes = <String>{
    'grid_view',
    'dashboard_grid',
    'product_grid',
    'grid',
  };

  static const _variants = <String>{
    'standard',
    'dashboard',
    'product',
  };

  @override
  String get systemId => 'grid_skeleton_system';

  @override
  List<String> get supportedTypes => _supportedTypes.toList(growable: false);

  @override
  List<String> get availableVariants => _variants.toList(growable: false);

  @override
  bool canHandle(String skeletonType) => _supportedTypes.contains(skeletonType);

  SkeletonConfig _config({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return SkeletonConfig(
      width: width,
      height: height,
      options: options ?? const {},
    );
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'standard',
      width: width,
      height: height,
      options: options,
    );
  }

  @override
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final config = _config(width: width, height: height, options: options);
    switch (variant) {
      case 'dashboard':
        return _buildDashboardGrid(config);
      case 'product':
        return _buildProductGrid(config);
      case 'standard':
      default:
        return _buildStandardGrid(config);
    }
  }

  @override
  Widget createAnimatedSkeleton({
    double? width,
    double? height,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  }) {
    final child = createSkeleton(
      width: width,
      height: height,
      options: options,
    );
    final animationDuration = duration ?? defaultAnimationDuration;

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Transform.scale(
            scale: Tween<double>(begin: 0.95, end: 1.0).transform(controller.value),
            child: Opacity(
              opacity: controller.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: animationDuration,
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
    );
  }

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 320);

  Widget _buildGrid({
    required int itemCount,
    required int crossAxisCount,
    double childAspectRatio = 1.0,
    double spacing = 16,
    Widget Function(int index)? itemBuilder,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder?.call(index) ?? SkeletonBlocks.tile();
      },
    );
  }

  Widget _buildStandardGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] as int? ?? 6;
    final crossAxisCount = config.options['crossAxisCount'] as int? ?? 2;
    final spacing = config.options['spacing'] as double? ?? 12;
    final aspectRatio = config.options['childAspectRatio'] as double? ?? 1.0;

    return _buildGrid(
      itemCount: itemCount,
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio,
      spacing: spacing,
    );
  }

  Widget _buildDashboardGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] as int? ?? 4;
    return _buildGrid(
      itemCount: itemCount,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      spacing: 12,
      itemBuilder: (index) {
        return SkeletonBlocks.statCard();
      },
    );
  }

  Widget _buildProductGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] as int? ?? 6;
    return _buildGrid(
      itemCount: itemCount,
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      spacing: 16,
      itemBuilder: (index) {
        return SkeletonBlocks.productCard();
      },
    );
  }
}
