import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Grid skeleton system implementation - Single Responsibility: Grid-based skeletons
/// Follows SRP by handling only grid and dashboard-related skeleton patterns
class GridSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  @override
  String get systemId => 'grid_skeleton_system';

  @override
  List<String> get supportedTypes => [
    'grid_view',
    'dashboard_grid',
    'photo_grid',
    'product_grid',
    'stats_grid',
    'feature_grid',
    'masonry_grid',
  ];

  @override
  List<String> get availableVariants => [
    'standard',
    'dashboard',
    'photo',
    'product',
    'stats',
    'feature',
    'masonry',
    'compact',
  ];

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 1500);

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.endsWith('_grid') ||
           skeletonType.contains('grid') ||
           skeletonType.contains('dashboard') ||
           availableVariants.any((variant) => skeletonType.contains(variant));
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
    final config = SkeletonConfig(
      width: width,
      height: height,
      options: options ?? {},
    );

    switch (variant) {
      case 'dashboard':
        return _createDashboardGrid(config);
      case 'photo':
        return _createPhotoGrid(config);
      case 'product':
        return _createProductGrid(config);
      case 'stats':
        return _createStatsGrid(config);
      case 'feature':
        return _createFeatureGrid(config);
      case 'masonry':
        return _createMasonryGrid(config);
      case 'compact':
        return _createCompactGrid(config);
      case 'standard':
      default:
        return _createStandardGrid(config);
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
      'standard',
      width: width,
      height: height,
      options: {
        ...options ?? {},
        'animation_duration': duration,
        'animation_controller': controller,
      },
    );
  }

  /// Creates a standard grid skeleton with equal-sized items
  Widget _createStandardGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 6;
    final crossAxisCount = config.options['crossAxisCount'] ?? 2;
    final childAspectRatio = config.options['childAspectRatio']?.toDouble() ?? 1.0;
    final spacing = config.options['spacing']?.toDouble() ?? 12.0;

    return SkeletonLayoutBuilder.grid(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createStandardGridItem(
        SkeletonConfig(
          animationDuration: config.animationDuration,
          options: {'itemIndex': index},
        ),
      )),
    );
  }

  /// Creates a dashboard grid skeleton with different sized widgets
  Widget _createDashboardGrid(SkeletonConfig config) {
    final spacing = config.options['spacing']?.toDouble() ?? 16.0;

    return SkeletonLayoutBuilder.vertical(
      spacing: spacing,
      children: [
        // Top row with large metric cards
        SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(child: _createMetricCard(config, large: true)),
              SizedBox(width: spacing),
              Expanded(child: _createMetricCard(config, large: true)),
            ],
          ),
        ),

        // Second row with three smaller metrics
        SizedBox(
          height: 100,
          child: Row(
            children: List.generate(3, (index) {
              return [
                Expanded(child: _createMetricCard(config)),
                if (index < 2) SizedBox(width: spacing),
              ];
            }).expand((widgets) => widgets).toList(),
          ),
        ),

        // Chart section
        SizedBox(
          height: 200,
          child: _createChartCard(config),
        ),

        // Bottom grid with recent items
        SizedBox(
          height: 160,
          child: SkeletonLayoutBuilder.grid(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            spacing: spacing,
            children: List.generate(4, (index) => _createActivityCard(
              config,
              index: index,
            )),
          ),
        ),
      ],
    );
  }

  /// Creates a photo grid skeleton for image galleries
  Widget _createPhotoGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 12;
    final crossAxisCount = config.options['crossAxisCount'] ?? 3;
    final spacing = config.options['spacing']?.toDouble() ?? 8.0;

    return SkeletonLayoutBuilder.grid(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.0,
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createPhotoItem(
        SkeletonConfig(
          animationDuration: config.animationDuration,
          options: {'itemIndex': index},
        ),
      )),
    );
  }

  /// Creates a product grid skeleton for e-commerce
  Widget _createProductGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 8;
    final crossAxisCount = config.options['crossAxisCount'] ?? 2;
    final spacing = config.options['spacing']?.toDouble() ?? 12.0;
    final showPrice = config.options['showPrice'] ?? true;
    final showRating = config.options['showRating'] ?? true;

    return SkeletonLayoutBuilder.grid(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 0.8,
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createProductItem(
        SkeletonConfig(
          animationDuration: config.animationDuration,
          options: {
            'showPrice': showPrice,
            'showRating': showRating,
            'itemIndex': index,
          },
        ),
      )),
    );
  }

  /// Creates a stats grid skeleton for analytics
  Widget _createStatsGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 4;
    final crossAxisCount = config.options['crossAxisCount'] ?? 2;
    final spacing = config.options['spacing']?.toDouble() ?? 16.0;

    return SkeletonLayoutBuilder.grid(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.5,
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createStatsItem(
        SkeletonConfig(
          animationDuration: config.animationDuration,
          options: {'itemIndex': index},
        ),
      )),
    );
  }

  /// Creates a feature grid skeleton for app features
  Widget _createFeatureGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 6;
    final crossAxisCount = config.options['crossAxisCount'] ?? 2;
    final spacing = config.options['spacing']?.toDouble() ?? 16.0;

    return SkeletonLayoutBuilder.grid(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.2,
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createFeatureItem(
        SkeletonConfig(
          animationDuration: config.animationDuration,
          options: {'itemIndex': index},
        ),
      )),
    );
  }

  /// Creates a masonry-style grid skeleton with varying heights
  Widget _createMasonryGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 8;
    final crossAxisCount = config.options['crossAxisCount'] ?? 2;
    final spacing = config.options['spacing']?.toDouble() ?? 12.0;

    // Simulate masonry layout with varying heights
    return SkeletonLayoutBuilder.vertical(
      spacing: spacing,
      children: [
        for (int row = 0; row < (itemCount / crossAxisCount).ceil(); row++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int col = 0; col < crossAxisCount; col++)
                if (row * crossAxisCount + col < itemCount) ...[
                  Expanded(
                    child: _createMasonryItem(
                      SkeletonConfig(
                        height: _getMasonryHeight((row * crossAxisCount + col).toDouble()),
                        animationDuration: config.animationDuration,
                      ),
                    ),
                  ),
                  if (col < crossAxisCount - 1) SizedBox(width: spacing),
                ] else
                  Expanded(child: Container()),
            ],
          ),
      ],
    );
  }

  /// Creates a compact grid skeleton with smaller items
  Widget _createCompactGrid(SkeletonConfig config) {
    final itemCount = config.options['itemCount'] ?? 12;
    final crossAxisCount = config.options['crossAxisCount'] ?? 3;
    final spacing = config.options['spacing']?.toDouble() ?? 8.0;

    return SkeletonLayoutBuilder.grid(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.0,
      spacing: spacing,
      children: List.generate(itemCount, (index) => _createCompactItem(
        SkeletonConfig(
          animationDuration: config.animationDuration,
          options: {'itemIndex': index},
        ),
      )),
    );
  }

  // Individual grid item creators

  Widget _createStandardGridItem(SkeletonConfig config) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(16),
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          SkeletonShapeFactory.circular(size: 40),
          SkeletonShapeFactory.text(width: 80, height: 16),
          SkeletonShapeFactory.text(width: 60, height: 14),
        ],
      ),
    );
  }

  Widget _createMetricCard(SkeletonConfig config, {bool large = false}) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      padding: EdgeInsets.all(large ? 20 : 16),
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: large ? 16 : 12,
        children: [
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonShapeFactory.text(width: large ? 120 : 100, height: 16),
              SkeletonShapeFactory.circular(size: large ? 32 : 24),
            ],
          ),
          SkeletonShapeFactory.text(
            width: large ? 80 : 60,
            height: large ? 32 : 24,
          ),
          if (large) ...[
            SkeletonLayoutBuilder.horizontal(
              children: [
                SkeletonShapeFactory.circular(size: 16),
                const SizedBox(width: 8),
                SkeletonShapeFactory.text(width: 60, height: 14),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _createChartCard(SkeletonConfig config) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          // Chart header
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonShapeFactory.text(width: 140, height: 20),
              SkeletonShapeFactory.text(width: 80, height: 16),
            ],
          ),

          // Chart area
          Expanded(
            child: SkeletonLayoutBuilder.horizontal(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final barHeight = 40.0 + (index % 4) * 25.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SkeletonShapeFactory.rectangular(height: barHeight),
                  ),
                );
              }),
            ),
          ),

          // Chart legend
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return SkeletonLayoutBuilder.horizontal(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonShapeFactory.circular(size: 12),
                  const SizedBox(width: 6),
                  SkeletonShapeFactory.text(width: 40, height: 14),
                  if (index < 2) const SizedBox(width: 16),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _createActivityCard(SkeletonConfig config, {required int index}) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(12),
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonShapeFactory.circular(size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                SkeletonShapeFactory.text(width: double.infinity, height: 16),
                SkeletonShapeFactory.text(width: 80, height: 12),
              ],
            ),
          ),
          SkeletonShapeFactory.circular(size: 20),
        ],
      ),
    );
  }

  Widget _createPhotoItem(SkeletonConfig config) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.radiusSm,
      padding: EdgeInsets.zero,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonShapeFactory.rectangular(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _createProductItem(SkeletonConfig config) {
    final showPrice = config.options['showPrice'] ?? true;
    final showRating = config.options['showRating'] ?? true;

    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(12),
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: SkeletonShapeFactory.rectangular(
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Product details
          Expanded(
            flex: 2,
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SkeletonShapeFactory.text(width: double.infinity, height: 16),
                SkeletonShapeFactory.text(width: 120, height: 14),

                if (showRating)
                  SkeletonLayoutBuilder.horizontal(
                    children: [
                      ...List.generate(5, (index) => [
                        SkeletonShapeFactory.circular(size: 12),
                        if (index < 4) const SizedBox(width: 2),
                      ]).expand((widgets) => widgets).toList(),
                      const SizedBox(width: 8),
                      SkeletonShapeFactory.text(width: 30, height: 12),
                    ],
                  ),

                const Spacer(),

                if (showPrice)
                  SkeletonLayoutBuilder.horizontal(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonShapeFactory.text(width: 60, height: 18),
                      SkeletonShapeFactory.circular(size: 24),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createStatsItem(SkeletonConfig config) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        spacing: 16,
        children: [
          SkeletonLayoutBuilder.horizontal(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonShapeFactory.text(width: 80, height: 16),
              SkeletonShapeFactory.circular(size: 28),
            ],
          ),

          SkeletonShapeFactory.text(width: 60, height: 28),

          // Mini chart
          SizedBox(
            height: 40,
            child: SkeletonLayoutBuilder.horizontal(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (index) {
                final barHeight = 10.0 + (index % 3) * 15.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SkeletonShapeFactory.rectangular(height: barHeight),
                  ),
                );
              }),
            ),
          ),

          SkeletonLayoutBuilder.horizontal(
            children: [
              SkeletonShapeFactory.circular(size: 12),
              const SizedBox(width: 6),
              SkeletonShapeFactory.text(width: 50, height: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createFeatureItem(SkeletonConfig config) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          SkeletonShapeFactory.circular(size: 48),
          SkeletonLayoutBuilder.vertical(
            spacing: 8,
            children: [
              SkeletonShapeFactory.text(width: 100, height: 18),
              SkeletonShapeFactory.text(width: 140, height: 14),
            ],
          ),
          SkeletonShapeFactory.badge(width: 60),
        ],
      ),
    );
  }

  Widget _createMasonryItem(SkeletonConfig config) {
    return SkeletonContainer(
      height: config.height,
      borderRadius: BorderRadiusTokens.card,
      padding: const EdgeInsets.all(16),
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SkeletonShapeFactory.rectangular(
            width: double.infinity,
            height: (config.height ?? 150) * 0.6,
          ),
          SkeletonShapeFactory.text(width: double.infinity, height: 16),
          SkeletonShapeFactory.text(width: 120, height: 14),
          const Spacer(),
          SkeletonLayoutBuilder.horizontal(
            children: [
              SkeletonShapeFactory.circular(size: 20),
              const SizedBox(width: 8),
              SkeletonShapeFactory.text(width: 60, height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createCompactItem(SkeletonConfig config) {
    return SkeletonContainer(
      borderRadius: BorderRadiusTokens.radiusSm,
      padding: const EdgeInsets.all(8),
      animationDuration: config.animationDuration ?? defaultAnimationDuration,
      child: SkeletonLayoutBuilder.vertical(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          SkeletonShapeFactory.circular(size: 24),
          SkeletonShapeFactory.text(width: 50, height: 12),
        ],
      ),
    );
  }

  double _getMasonryHeight(double index) {
    // Create varied heights for masonry effect
    const heights = [120.0, 180.0, 150.0, 200.0, 140.0, 160.0, 190.0, 130.0];
    return heights[index.toInt() % heights.length];
  }
}