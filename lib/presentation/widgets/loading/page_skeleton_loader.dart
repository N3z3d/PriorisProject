import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';

/// Widget de loading pages entières avec skeleton
///
/// SOLID Compliance:
/// - SRP: Single responsibility - handles full page skeleton loading states
/// - OCP: Open for extension via SkeletonPageType enum
/// - DIP: Depends on PremiumSkeletons abstraction, not concrete implementations
class PageSkeletonLoader extends StatelessWidget {
  final SkeletonPageType pageType;

  const PageSkeletonLoader({
    super.key,
    required this.pageType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildPageSkeleton(),
        ),
      ),
    );
  }

  Widget _buildPageSkeleton() {
    switch (pageType) {
      case SkeletonPageType.dashboard:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _SkeletonBox(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadiusTokens.radiusCircular,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(
                        width: 120,
                        height: 20,
                        borderRadius: BorderRadiusTokens.radiusXs,
                      ),
                      const SizedBox(height: 4),
                      _SkeletonBox(
                        width: 80,
                        height: 16,
                        borderRadius: BorderRadiusTokens.radiusXs,
                      ),
                    ],
                  ),
                ),
                _SkeletonBox(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadiusTokens.radiusCircular,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Stats cards
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                    child: _SkeletonContainer(
                      height: 80,
                      borderRadius: BorderRadiusTokens.card,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SkeletonBox(
                            width: 30,
                            height: 24,
                            borderRadius: BorderRadiusTokens.radiusXs,
                          ),
                          const SizedBox(height: 8),
                          _SkeletonBox(
                            width: 60,
                            height: 16,
                            borderRadius: BorderRadiusTokens.radiusXs,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Chart
            PremiumSkeletons.chartSkeleton(height: 200),
            const SizedBox(height: 24),
            // Recent items
            Expanded(
              child: PremiumSkeletons.listSkeleton(itemCount: 3),
            ),
          ],
        );
      case SkeletonPageType.list:
        return Column(
          children: [
            // Search bar
            _SkeletonBox(
              width: double.infinity,
              height: 48,
              borderRadius: BorderRadiusTokens.input,
            ),
            const SizedBox(height: 16),
            // Filters
            Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                  child: _SkeletonBox(
                    width: 80,
                    height: 32,
                    borderRadius: BorderRadiusTokens.chip,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // List items
            Expanded(
              child: PremiumSkeletons.listSkeleton(itemCount: 6),
            ),
          ],
        );
      case SkeletonPageType.profile:
        return Column(
          children: [
            PremiumSkeletons.profileSkeleton(avatarSize: 100, showStats: true),
            const SizedBox(height: 32),
            PremiumSkeletons.chartSkeleton(height: 150, showLegend: false),
            const SizedBox(height: 24),
            Expanded(
              child: PremiumSkeletons.listSkeleton(itemCount: 4, itemHeight: 60),
            ),
          ],
        );
    }
  }
}

/// Types de pages skeleton
enum SkeletonPageType {
  dashboard,
  list,
  profile,
}

/// LEGACY: Boîte skeleton de base
/// DEPRECATED: Use SkeletonBox from skeleton_components.dart instead
/// Kept for backward compatibility only
class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const _SkeletonBox({
    this.width,
    this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: borderRadius,
      ),
    );
  }
}

/// LEGACY: Container de base pour les skeletons avec effet shimmer
/// DEPRECATED: Use SkeletonContainer from skeleton_components.dart instead
/// Kept for backward compatibility only
class _SkeletonContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  const _SkeletonContainer({
    required this.child,
    this.width,
    this.height,
    required this.borderRadius,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<_SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<_SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
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
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Professional subtle opacity animation instead of gradient shimmer
          return AnimatedOpacity(
            opacity: 0.7 + (0.3 * _animationController.value),
            duration: const Duration(milliseconds: 100),
            child: widget.child,
          );
        },
      ),
    );
  }
}
