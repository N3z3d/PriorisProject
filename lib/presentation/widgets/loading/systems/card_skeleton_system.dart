import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_blocks.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Card skeleton system used by PremiumSkeletonCoordinator.
class CardSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  CardSkeletonSystem()
      : _defaultConfig = const SkeletonConfig();

  final SkeletonConfig _defaultConfig;

  static const _supportedTypes = <String>{
    'task_card',
    'habit_card',
    'profile_card',
    'simple_card',
    'card',
  };

  static const _variants = <String>{
    'task',
    'habit',
    'profile',
    'simple',
  };

  @override
  String get systemId => 'card_skeleton_system';

  @override
  List<String> get supportedTypes => _supportedTypes.toList(growable: false);

  @override
  List<String> get availableVariants => _variants.toList(growable: false);

  @override
  bool canHandle(String skeletonType) => _supportedTypes.contains(skeletonType);

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'task',
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
    final resolvedOptions = {...?_defaultConfig.options, ...?options};
    final effectiveWidth = width ?? resolvedOptions['width'] as double? ?? double.infinity;
    final effectiveHeight = height ?? resolvedOptions['height'] as double? ?? 140.0;

    switch (variant) {
      case 'habit':
        return _buildHabitCard(effectiveWidth, effectiveHeight, resolvedOptions);
      case 'profile':
        return _buildProfileCard(effectiveWidth, effectiveHeight, resolvedOptions);
      case 'simple':
        return _buildSimpleCard(effectiveWidth, effectiveHeight);
      case 'task':
      default:
        return _buildTaskCard(effectiveWidth, effectiveHeight, resolvedOptions);
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
    final configDuration = duration ?? defaultAnimationDuration;
    final child = createSkeleton(
      width: width,
      height: height,
      options: options,
    );

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Opacity(
            opacity: controller.value.clamp(0.0, 1.0),
            child: child,
          );
        },
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: configDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: child,
        );
      },
    );
  }

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 450);

  Widget _buildCardShell(double width, double height, List<Widget> children) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  Widget _buildTaskCard(double width, double height, Map<String, dynamic> options) {
    final showPriority = options['showPriority'] as bool? ?? true;
    final showProgress = options['showProgress'] as bool? ?? true;

    return _buildCardShell(width, height, [
      SkeletonLayoutBuilder.vertical(
        spacing: 8,
        children: [
          SkeletonShapeFactory.text(height: 18),
          SkeletonShapeFactory.text(width: width * 0.6, height: 14),
        ],
      ),
      if (showProgress)
        SkeletonShapeFactory.progressBar(
          width: width,
          height: 6,
          margin: const EdgeInsets.symmetric(vertical: 12),
        ),
      if (showPriority)
        SkeletonLayoutBuilder.horizontal(
          spacing: 8,
          children: List.generate(
            3,
            (_) => SkeletonShapeFactory.badge(width: 60, height: 24),
          ),
        ),
    ]);
  }

  Widget _buildHabitCard(double width, double height, Map<String, dynamic> options) {
    final showStreak = options['showStreak'] as bool? ?? true;
    final showChart = options['showChart'] as bool? ?? true;

    return _buildCardShell(width, height, [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              spacing: 6,
              children: [
                SkeletonShapeFactory.text(height: 18),
                SkeletonShapeFactory.text(width: width * 0.4, height: 14),
              ],
            ),
          ),
          SkeletonShapeFactory.circular(size: 36),
        ],
      ),
      if (showChart)
        Container(
          height: 64,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      if (showStreak)
        SkeletonLayoutBuilder.horizontal(
          spacing: 12,
          children: List.generate(
            3,
            (_) => SkeletonShapeFactory.text(width: 48, height: 14),
          ),
        ),
    ]);
  }

  Widget _buildProfileCard(double width, double height, Map<String, dynamic> options) {
    final showStats = options['showStats'] as bool? ?? true;

    return _buildCardShell(width, height, [
      Row(
        children: [
          SkeletonShapeFactory.circular(size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              spacing: 6,
              children: [
                SkeletonShapeFactory.text(height: 18),
                SkeletonShapeFactory.text(width: width * 0.4, height: 14),
              ],
            ),
          ),
        ],
      ),
      SkeletonShapeFactory.text(height: 14, width: width * 0.8),
      SkeletonShapeFactory.text(height: 14, width: width * 0.7),
      if (showStats)
        SkeletonLayoutBuilder.horizontal(
          spacing: 12,
          children: List.generate(
            3,
            (_) => SkeletonShapeFactory.text(width: 48, height: 14),
          ),
        ),
    ]);
  }

  Widget _buildSimpleCard(double width, double height) {
    return _buildCardShell(width, height, [
      SkeletonShapeFactory.text(height: 18, width: width * 0.7),
      SkeletonShapeFactory.text(height: 14, width: width * 0.9),
      SkeletonShapeFactory.text(height: 14, width: width * 0.8),
      SkeletonShapeFactory.progressBar(width: width, height: 6),
    ]);
  }
}
