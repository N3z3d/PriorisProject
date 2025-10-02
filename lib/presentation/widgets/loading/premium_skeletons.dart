import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_manager.dart';

// Exports for extracted skeleton loaders - SOLID architecture compliance
export 'package:prioris/presentation/widgets/loading/adaptive_skeleton_loader.dart';
export 'package:prioris/presentation/widgets/loading/page_skeleton_loader.dart';

/// Système de loading skeletons premium avec effets shimmer avancés
/// REFACTORED: Now uses SOLID architecture with specialized skeleton systems
/// Maintains backward compatibility while leveraging new modular design
///
/// DEPRECATED sections removed:
/// - Legacy _SkeletonContainer, _SkeletonBox (lines 192-291)
/// - AdaptiveSkeletonLoader, _CustomSkeletonExtractor, SkeletonType (lines 296-455)
/// - PageSkeletonLoader, SkeletonPageType (lines 457-610)
/// All extracted to separate files following SRP principle
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