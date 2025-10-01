import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Card skeleton system implementation - Single Responsibility: Card-based skeletons
/// Follows SRP by handling only card-related skeleton patterns
class CardSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  @override
  String get systemId => 'card_skeleton_system';

  @override
  List<String> get supportedTypes => [
    'task_card',
    'habit_card',
    'profile_card',
    'metric_card',
    'feature_card',
    'simple_card',
  ];

  @override
  List<String> get availableVariants => [
    'task',
    'habit',
    'profile',
    'metric',
    'feature',
    'simple',
  ];

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 1500);

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.endsWith('_card') ||
           availableVariants.any((variant) => skeletonType.contains(variant));
  }

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'simple',
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
    final config = SkeletonConfig(
      width: width,
      height: height,
      options: options ?? {},
    );

    switch (variant) {
      case 'task':
        return _createTaskCard(config);
      case 'habit':
        return _createHabitCard(config);
      case 'profile':
        return _createProfileCard(config);
      case 'metric':
        return _createMetricCard(config);
      case 'feature':
        return _createFeatureCard(config);
      case 'simple':
      default:
        return _createSimpleCard(config);
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
    return createVariant(
      'simple',
      width: width,
      height: height,
      options: {
        ...options ?? {},
        'animation_duration': duration,
        'animation_controller': controller,
      },
    );
  }

  /// Creates a task card skeleton with priority, progress, and actions
  Widget _createTaskCard(SkeletonConfig config) {
    final showPriority = config.options['showPriority'] ?? true;
    final showProgress = config.options['showProgress'] ?? true;
    final showActions = config.options['showActions'] ?? false;

    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 120,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Header row with priority badge and action
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showPriority)
                SkeletonShapeFactory.badge(width: 60),
              SkeletonShapeFactory.circular(size: 24),
            ],
          ),

          // Title and description
          SkeletonLayoutBuilder.vertical(
            spacing: 8,
            children: [
              SkeletonShapeFactory.text(width: double.infinity, height: 20),
              SkeletonShapeFactory.text(width: 200, height: 16),
            ],
          ),

          const Spacer(),

          // Progress section
          if (showProgress)
            SkeletonLayoutBuilder.horizontal(
              children: [
                Expanded(child: SkeletonShapeFactory.progressBar()),
                const SizedBox(width: 12),
                SkeletonShapeFactory.text(width: 40),
              ],
            ),

          // Action buttons
          if (showActions)
            SkeletonLayoutBuilder.horizontal(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                SkeletonShapeFactory.button(width: 80, height: 32),
                SkeletonShapeFactory.button(width: 80, height: 32),
              ],
            ),
        ],
      ),
    );
  }

  /// Creates a habit card skeleton with icon, streak, and chart
  Widget _createHabitCard(SkeletonConfig config) {
    final showStreak = config.options['showStreak'] ?? true;
    final showChart = config.options['showChart'] ?? true;

    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 140,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Header with icon, title, and streak
          SkeletonLayoutBuilder.horizontal(
            children: [
              SkeletonShapeFactory.circular(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLayoutBuilder.vertical(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    SkeletonShapeFactory.text(width: double.infinity, height: 18),
                    SkeletonShapeFactory.text(width: 120, height: 14),
                  ],
                ),
              ),
              if (showStreak)
                SkeletonShapeFactory.rounded(width: 50, height: 30),
            ],
          ),

          // Chart area
          if (showChart)
            SkeletonShapeFactory.rectangular(
              width: double.infinity,
              height: 40,
            ),
        ],
      ),
    );
  }

  /// Creates a profile card skeleton with avatar and stats
  Widget _createProfileCard(SkeletonConfig config) {
    final avatarSize = config.options['avatarSize']?.toDouble() ?? 80.0;
    final showStats = config.options['showStats'] ?? true;

    return SkeletonContainer(
      width: config.width,
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          SkeletonShapeFactory.circular(size: avatarSize),
          SkeletonShapeFactory.text(width: 120, height: 20),
          SkeletonShapeFactory.text(width: 200, height: 16),

          if (showStats) ...[
            const SizedBox(height: 8),
            SkeletonLayoutBuilder.horizontal(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return SkeletonLayoutBuilder.vertical(
                  children: [
                    SkeletonShapeFactory.text(width: 40, height: 24),
                    SkeletonShapeFactory.text(width: 60, height: 16),
                  ],
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  /// Creates a metric card skeleton for displaying statistics
  Widget _createMetricCard(SkeletonConfig config) {
    final showIcon = config.options['showIcon'] ?? true;
    final showTrend = config.options['showTrend'] ?? false;

    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 100,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          if (showIcon)
            SkeletonShapeFactory.circular(size: 32),

          SkeletonLayoutBuilder.vertical(
            spacing: 6,
            children: [
              SkeletonShapeFactory.text(width: 60, height: 28), // Value
              SkeletonShapeFactory.text(width: 80, height: 16), // Label
            ],
          ),

          if (showTrend)
            SkeletonLayoutBuilder.horizontal(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonShapeFactory.circular(size: 16), // Trend icon
                const SizedBox(width: 4),
                SkeletonShapeFactory.text(width: 40, height: 14), // Percentage
              ],
            ),
        ],
      ),
    );
  }

  /// Creates a feature card skeleton for app features/options
  Widget _createFeatureCard(SkeletonConfig config) {
    final showDescription = config.options['showDescription'] ?? true;
    final showBadge = config.options['showBadge'] ?? false;

    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 120,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Header with icon and badge
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonShapeFactory.circular(size: 48),
              if (showBadge)
                SkeletonShapeFactory.badge(width: 50),
            ],
          ),

          // Title
          SkeletonShapeFactory.text(width: double.infinity, height: 20),

          // Description
          if (showDescription) ...[
            SkeletonShapeFactory.text(width: double.infinity, height: 16),
            SkeletonShapeFactory.text(width: 180, height: 16),
          ],

          const Spacer(),

          // Action indicator
          SkeletonShapeFactory.circular(size: 20),
        ],
      ),
    );
  }

  /// Creates a simple card skeleton - basic layout
  Widget _createSimpleCard(SkeletonConfig config) {
    return SkeletonContainer(
      width: config.width,
      height: config.height ?? 80,
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SkeletonShapeFactory.text(width: double.infinity, height: 20),
          SkeletonShapeFactory.text(width: 200, height: 16),
          SkeletonShapeFactory.text(width: 150, height: 16),
        ],
      ),
    );
  }
}