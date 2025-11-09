import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_blocks.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/services/list_skeleton_service.dart';

/// List skeleton system that wraps [ListSkeletonService].
class ListSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  ListSkeletonSystem() : _service = ListSkeletonService();

  final ListSkeletonService _service;

  static const _supportedTypes = <String>{
    'list',
    'list_item',
    'standard_list',
    'conversation_list',
    'compact_list',
  };

  static const _variants = <String>{
    'standard',
    'compact',
    'conversation',
  };

  @override
  String get systemId => 'list_skeleton_system';

  @override
  List<String> get supportedTypes => _supportedTypes.toList(growable: false);

  @override
  List<String> get availableVariants => _variants.toList(growable: false);

  @override
  bool canHandle(String skeletonType) => _supportedTypes.contains(skeletonType);

  SkeletonConfig _buildConfig({
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
    final config = _buildConfig(width: width, height: height, options: options);
    return _service.createListSkeleton(config);
  }

  @override
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final mergedOptions = {...?options};
    switch (variant) {
      case 'compact':
        mergedOptions['itemCount'] ??= 5;
        mergedOptions['itemHeight'] ??= 56.0;
        mergedOptions['showSearchBar'] ??= false;
        mergedOptions['showFilters'] ??= false;
        break;
      case 'conversation':
        mergedOptions['itemCount'] ??= 8;
        mergedOptions['showSearchBar'] ??= true;
        mergedOptions['showFilters'] ??= false;
        break;
      case 'standard':
      default:
        mergedOptions['itemCount'] ??= 6;
        mergedOptions['showSearchBar'] ??= true;
        mergedOptions['showFilters'] ??= true;
        break;
    }

    final config = _buildConfig(
      width: width,
      height: height,
      options: mergedOptions,
    );

    return _service.createListSkeleton(config);
  }

  @override
  Widget createAnimatedSkeleton({
    double? width,
    double? height,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  }) {
    final config = _buildConfig(width: width, height: height, options: options);
    final child = _service.createListSkeleton(config);
    final animationDuration = duration ?? defaultAnimationDuration;

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(0, 12 * (1 - controller.value)),
            child: Opacity(opacity: controller.value.clamp(0.0, 1.0), child: child),
          );
        },
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: animationDuration,
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
    );
  }

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 300);

  /// Convenience method for tests to render list items.
  Widget createListItems({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final config = _buildConfig(width: width, height: height, options: options);
    return _service.createListItems(config);
  }
}
