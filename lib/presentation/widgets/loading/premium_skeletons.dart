import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Système de loading skeletons premium avec effets shimmer avancés
class PremiumSkeletons {
  /// Skeleton pour une carte de tâche
  static Widget taskCardSkeleton({
    double? width,
    double height = 120,
    bool showPriority = true,
    bool showProgress = true,
  }) {
    return _SkeletonContainer(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showPriority)
                _SkeletonBox(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadiusTokens.badge,
                ),
              const Spacer(),
              _SkeletonBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadiusTokens.radiusCircular,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SkeletonBox(
            width: double.infinity,
            height: 20,
            borderRadius: BorderRadiusTokens.radiusXs,
          ),
          const SizedBox(height: 8),
          _SkeletonBox(
            width: 200,
            height: 16,
            borderRadius: BorderRadiusTokens.radiusXs,
          ),
          const Spacer(),
          if (showProgress)
            Row(
              children: [
                Expanded(
                  child: _SkeletonBox(
                    height: 4,
                    borderRadius: BorderRadiusTokens.progressBar,
                  ),
                ),
                const SizedBox(width: 12),
                _SkeletonBox(
                  width: 40,
                  height: 16,
                  borderRadius: BorderRadiusTokens.radiusXs,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Skeleton pour une carte d'habitude
  static Widget habitCardSkeleton({
    double? width,
    double height = 140,
    bool showStreak = true,
    bool showChart = true,
  }) {
    return _SkeletonContainer(
      width: width,
      height: height,
      borderRadius: BorderRadiusTokens.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      width: double.infinity,
                      height: 18,
                      borderRadius: BorderRadiusTokens.radiusXs,
                    ),
                    const SizedBox(height: 6),
                    _SkeletonBox(
                      width: 120,
                      height: 14,
                      borderRadius: BorderRadiusTokens.radiusXs,
                    ),
                  ],
                ),
              ),
              if (showStreak)
                _SkeletonBox(
                  width: 50,
                  height: 30,
                  borderRadius: BorderRadiusTokens.radiusSm,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (showChart)
            _SkeletonBox(
              width: double.infinity,
              height: 40,
              borderRadius: BorderRadiusTokens.radiusXs,
            ),
        ],
      ),
    );
  }

  /// Skeleton pour une liste d'éléments
  static Widget listSkeleton({
    int itemCount = 5,
    double itemHeight = 80,
    double spacing = 12,
  }) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Column(
          children: [
            _SkeletonContainer(
              height: itemHeight,
              borderRadius: BorderRadiusTokens.card,
              child: Row(
                children: [
                  _SkeletonBox(
                    width: 50,
                    height: 50,
                    borderRadius: BorderRadiusTokens.radiusSm,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SkeletonBox(
                          width: double.infinity,
                          height: 18,
                          borderRadius: BorderRadiusTokens.radiusXs,
                        ),
                        const SizedBox(height: 8),
                        _SkeletonBox(
                          width: 150,
                          height: 14,
                          borderRadius: BorderRadiusTokens.radiusXs,
                        ),
                      ],
                    ),
                  ),
                  _SkeletonBox(
                    width: 80,
                    height: 32,
                    borderRadius: BorderRadiusTokens.button,
                  ),
                ],
              ),
            ),
            if (index < itemCount - 1) SizedBox(height: spacing),
          ],
        );
      }),
    );
  }

  /// Skeleton pour un profil utilisateur
  static Widget profileSkeleton({
    double avatarSize = 80,
    bool showStats = true,
  }) {
    return _SkeletonContainer(
      borderRadius: BorderRadiusTokens.card,
      child: Column(
        children: [
          _SkeletonBox(
            width: avatarSize,
            height: avatarSize,
            borderRadius: BorderRadiusTokens.radiusCircular,
          ),
          const SizedBox(height: 16),
          _SkeletonBox(
            width: 120,
            height: 20,
            borderRadius: BorderRadiusTokens.radiusXs,
          ),
          const SizedBox(height: 8),
          _SkeletonBox(
            width: 200,
            height: 16,
            borderRadius: BorderRadiusTokens.radiusXs,
          ),
          if (showStats) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return Column(
                  children: [
                    _SkeletonBox(
                      width: 40,
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
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  /// Skeleton pour un graphique
  static Widget chartSkeleton({
    double height = 200,
    bool showLegend = true,
  }) {
    return _SkeletonContainer(
      height: height,
      borderRadius: BorderRadiusTokens.card,
      child: Column(
        children: [
          if (showLegend) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SkeletonBox(
                      width: 12,
                      height: 12,
                      borderRadius: BorderRadiusTokens.radiusCircular,
                    ),
                    const SizedBox(width: 8),
                    _SkeletonBox(
                      width: 60,
                      height: 16,
                      borderRadius: BorderRadiusTokens.radiusXs,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),
          ],
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final barHeight = 40.0 + (index % 3) * 30.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _SkeletonBox(
                      height: barHeight,
                      borderRadius: BorderRadiusTokens.radiusXs,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton pour un formulaire
  static Widget formSkeleton({
    int fieldCount = 4,
    bool showSubmitButton = true,
  }) {
    return _SkeletonContainer(
      borderRadius: BorderRadiusTokens.modal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(
            width: 200,
            height: 24,
            borderRadius: BorderRadiusTokens.radiusXs,
          ),
          const SizedBox(height: 24),
          ...List.generate(fieldCount, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 100 + (index % 3) * 30.0,
                  height: 16,
                  borderRadius: BorderRadiusTokens.radiusXs,
                ),
                const SizedBox(height: 8),
                _SkeletonBox(
                  width: double.infinity,
                  height: 48,
                  borderRadius: BorderRadiusTokens.input,
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          if (showSubmitButton) ...[
            const SizedBox(height: 8),
            _SkeletonBox(
              width: double.infinity,
              height: 48,
              borderRadius: BorderRadiusTokens.button,
            ),
          ],
        ],
      ),
    );
  }

  /// Skeleton pour une grille
  static Widget gridSkeleton({
    int itemCount = 6,
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
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _SkeletonContainer(
          borderRadius: BorderRadiusTokens.card,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SkeletonBox(
                width: 40,
                height: 40,
                borderRadius: BorderRadiusTokens.radiusCircular,
              ),
              const SizedBox(height: 12),
              _SkeletonBox(
                width: 80,
                height: 16,
                borderRadius: BorderRadiusTokens.radiusXs,
              ),
              const SizedBox(height: 6),
              _SkeletonBox(
                width: 60,
                height: 14,
                borderRadius: BorderRadiusTokens.radiusXs,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Container de base pour les skeletons avec effet shimmer
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

/// Boîte skeleton de base
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

// Removed gradient transform class - now using professional solid colors

/// Loading skeleton adaptatif qui s'adapte au contenu
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

/// Widget de loading pages entières avec skeleton
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