import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';

/// Loading skeleton adaptatif qui s'adapte au contenu
///
/// SOLID Compliance:
/// - SRP: Single responsibility - handles adaptive skeleton loading with smooth transitions
/// - OCP: Open for extension via SkeletonType enum and custom extractors
/// - LSP: Can be used anywhere a StatefulWidget is expected
/// - DIP: Depends on PremiumSkeletons abstraction for skeleton generation
class AdaptiveSkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration animationDuration;
  final SkeletonType skeletonType;

  const AdaptiveSkeletonLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.animationDuration = const Duration(milliseconds: 300),
    this.skeletonType = SkeletonType.custom,
  });

  @override
  State<AdaptiveSkeletonLoader> createState() => _AdaptiveSkeletonLoaderState();
}

class _AdaptiveSkeletonLoaderState extends State<AdaptiveSkeletonLoader>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    if (!widget.isLoading) {
      _fadeController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AdaptiveSkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      if (widget.isLoading) {
        _fadeController.reverse();
      } else {
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.isLoading)
          _buildSkeletonForType(),
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: widget.child,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonForType() {
    switch (widget.skeletonType) {
      case SkeletonType.taskCard:
        return PremiumSkeletons.taskCardSkeleton();
      case SkeletonType.habitCard:
        return PremiumSkeletons.habitCardSkeleton();
      case SkeletonType.list:
        return PremiumSkeletons.listSkeleton();
      case SkeletonType.profile:
        return PremiumSkeletons.profileSkeleton();
      case SkeletonType.chart:
        return PremiumSkeletons.chartSkeleton();
      case SkeletonType.form:
        return PremiumSkeletons.formSkeleton();
      case SkeletonType.grid:
        return PremiumSkeletons.gridSkeleton();
      case SkeletonType.custom:
        return _CustomSkeletonExtractor(child: widget.child);
    }
  }
}

/// Extracteur de skeleton personnalisé qui analyse le widget enfant
class _CustomSkeletonExtractor extends StatelessWidget {
  final Widget child;

  const _CustomSkeletonExtractor({required this.child});

  @override
  Widget build(BuildContext context) {
    // Analyse basique du type de widget et génère un skeleton approprié
    if (child is Card) {
      return PremiumSkeletons.taskCardSkeleton();
    } else if (child is ListTile) {
      return PremiumSkeletons.listSkeleton(itemCount: 1);
    } else if (child is GridView) {
      return PremiumSkeletons.gridSkeleton();
    } else {
      // Skeleton générique
      return _SkeletonContainer(
        borderRadius: BorderRadiusTokens.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(
              width: double.infinity,
              height: 20,
              borderRadius: BorderRadiusTokens.radiusXs,
            ),
            const SizedBox(height: 12),
            _SkeletonBox(
              width: 200,
              height: 16,
              borderRadius: BorderRadiusTokens.radiusXs,
            ),
            const SizedBox(height: 8),
            _SkeletonBox(
              width: 150,
              height: 16,
              borderRadius: BorderRadiusTokens.radiusXs,
            ),
          ],
        ),
      );
    }
  }
}

/// Types de skeletons prédéfinis
enum SkeletonType {
  taskCard,
  habitCard,
  list,
  profile,
  chart,
  form,
  grid,
  custom,
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
