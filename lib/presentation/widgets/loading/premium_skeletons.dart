import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_manager.dart';

/// Système de loading skeletons premium avec effets shimmer avancés
/// REFACTORED: Now uses SOLID architecture with specialized skeleton systems
/// Maintains backward compatibility while leveraging new modular design
class PremiumSkeletons {
  static final PremiumSkeletonManager _manager = PremiumSkeletonManager();
  /// Skeleton pour une carte de tâche - REFACTORED using CardSkeletonSystem
  static Widget taskCardSkeleton({
    double? width,
    double height = 120,
    bool showPriority = true,
    bool showProgress = true,
  }) {
    return _manager.createSkeletonVariant(
      'card_skeleton_system',
      'task',
      width: width,
      height: height,
      options: {
        'showPriority': showPriority,
        'showProgress': showProgress,
      },
    );
  }

  /// Skeleton pour une carte d'habitude - REFACTORED using CardSkeletonSystem
  static Widget habitCardSkeleton({
    double? width,
    double height = 140,
    bool showStreak = true,
    bool showChart = true,
  }) {
    return _manager.createSkeletonVariant(
      'card_skeleton_system',
      'habit',
      width: width,
      height: height,
      options: {
        'showStreak': showStreak,
        'showChart': showChart,
      },
    );
  }

  /// Skeleton pour une liste d'éléments - REFACTORED using ListSkeletonSystem
  static Widget listSkeleton({
    int itemCount = 5,
    double itemHeight = 80,
    double spacing = 12,
  }) {
    return _manager.createSkeletonVariant(
      'list_skeleton_system',
      'standard',
      options: {
        'itemCount': itemCount,
        'itemHeight': itemHeight,
        'spacing': spacing,
      },
    );
  }

  /// Skeleton pour un profil utilisateur - REFACTORED using CardSkeletonSystem
  static Widget profileSkeleton({
    double avatarSize = 80,
    bool showStats = true,
  }) {
    return _manager.createSkeletonVariant(
      'card_skeleton_system',
      'profile',
      options: {
        'avatarSize': avatarSize,
        'showStats': showStats,
      },
    );
  }

  /// Skeleton pour un graphique - REFACTORED using GridSkeletonSystem
  static Widget chartSkeleton({
    double height = 200,
    bool showLegend = true,
  }) {
    return _manager.createSkeletonVariant(
      'grid_skeleton_system',
      'stats',
      height: height,
      options: {
        'showLegend': showLegend,
        'itemCount': 1, // Single chart item
      },
    );
  }

  /// Skeleton pour un formulaire - REFACTORED using FormSkeletonSystem
  static Widget formSkeleton({
    int fieldCount = 4,
    bool showSubmitButton = true,
  }) {
    return _manager.createSkeletonVariant(
      'form_skeleton_system',
      'standard',
      options: {
        'fieldCount': fieldCount,
        'showSubmitButton': showSubmitButton,
      },
    );
  }

  /// Skeleton pour une grille - REFACTORED using GridSkeletonSystem
  static Widget gridSkeleton({
    int itemCount = 6,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
    double spacing = 12,
  }) {
    return _manager.createSkeletonVariant(
      'grid_skeleton_system',
      'standard',
      options: {
        'itemCount': itemCount,
        'crossAxisCount': crossAxisCount,
        'childAspectRatio': childAspectRatio,
        'spacing': spacing,
      },
    );
  }

  /// ADDED: New skeleton methods using SOLID architecture

  /// Creates adaptive skeleton that automatically detects content type
  static Widget adaptiveSkeleton({
    required Widget child,
    required bool isLoading,
    String? skeletonType,
    Duration animationDuration = const Duration(milliseconds: 300),
    Map<String, dynamic>? options,
  }) {
    return _manager.createAdaptiveSkeleton(
      child: child,
      isLoading: isLoading,
      skeletonType: skeletonType,
      animationDuration: animationDuration,
      options: options,
    );
  }

  /// Creates smart skeleton using type detection
  static Widget smartSkeleton(
    String hint, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return _manager.createSmartSkeleton(
      hint,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Creates batch skeletons for lists
  static List<Widget> batchSkeletons(
    String skeletonType, {
    required int count,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return _manager.createBatchSkeletons(
      skeletonType,
      count: count,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Access to the underlying manager for advanced usage
  static PremiumSkeletonManager get manager => _manager;

  /// Gets system information for debugging
  static Map<String, dynamic> getSystemInfo() => _manager.getSystemInfo();

  /// Validates if a skeleton type is supported
  static bool isSkeletonTypeSupported(String skeletonType) =>
      _manager.isSkeletonTypeSupported(skeletonType);
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

// LEGACY: Removed gradient transform class - now using professional solid colors

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