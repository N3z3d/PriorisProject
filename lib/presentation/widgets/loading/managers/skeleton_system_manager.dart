/// SOLID Implementation: Skeleton System Manager
///
/// Manages the new SOLID skeleton architecture and provides backward compatibility.
/// RESPONSIBILITY: Replace ComplexLayoutSkeletonSystem with SOLID patterns.
/// CONSTRAINT: <150 lines as orchestration manager.

import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interfaces.dart';
import 'package:prioris/presentation/widgets/loading/systems/skeleton_system_slim.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_factory.dart';
import 'package:prioris/presentation/widgets\loading\strategies\skeleton_layout_strategies.dart';

/// Manager that replaces ComplexLayoutSkeletonSystem with SOLID architecture
/// SOLID COMPLIANCE: All principles - orchestrates SOLID components
class SkeletonSystemManager {
  static SkeletonSystemManager? _instance;
  late final ISolidSkeletonSystem _skeletonSystem;

  /// Singleton instance for global access
  static SkeletonSystemManager get instance {
    _instance ??= SkeletonSystemManager._internal();
    return _instance!;
  }

  /// Private constructor
  SkeletonSystemManager._internal() {
    _initializeSystem();
  }

  /// Initialize SOLID skeleton system
  void _initializeSystem() {
    _skeletonSystem = SkeletonSystemSlim(
      componentFactory: SkeletonComponentFactory(),
      strategyRegistry: SkeletonLayoutStrategyRegistry(),
    );
  }

  /// Create skeleton using SOLID architecture
  /// Replaces ComplexLayoutSkeletonSystem.createSkeleton()
  Widget createSkeleton({
    required String type,
    String? variant,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return _skeletonSystem.createSkeleton(
      type: type,
      variant: variant,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Backward compatibility: Dashboard page skeleton
  Widget createDashboardPageSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createSkeleton(
      type: 'dashboard_page',
      width: width,
      height: height,
      options: options,
    );
  }

  /// Backward compatibility: Profile page skeleton
  Widget createProfilePageSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createSkeleton(
      type: 'profile_page',
      width: width,
      height: height,
      options: options,
    );
  }

  /// Backward compatibility: List page skeleton
  Widget createListPageSkeleton({
    double? width,
    double? height,
    int itemCount = 5,
    Map<String, dynamic>? options,
  }) {
    final finalOptions = Map<String, dynamic>.from(options ?? {});
    finalOptions['itemCount'] = itemCount;

    return createSkeleton(
      type: 'list_page',
      width: width,
      height: height,
      options: finalOptions,
    );
  }

  /// Backward compatibility: Grid layout skeleton
  Widget createGridLayoutSkeleton({
    double? width,
    double? height,
    int crossAxisCount = 2,
    int itemCount = 6,
    Map<String, dynamic>? options,
  }) {
    final finalOptions = Map<String, dynamic>.from(options ?? {});
    finalOptions['crossAxisCount'] = crossAxisCount;
    finalOptions['itemCount'] = itemCount;

    return createSkeleton(
      type: 'grid_layout',
      width: width,
      height: height,
      options: finalOptions,
    );
  }

  /// Check if skeleton type is supported
  bool canHandle(String type) {
    return _skeletonSystem.canHandle(type);
  }

  /// Get available variants for type
  List<String> getVariantsForType(String type) {
    return _skeletonSystem.getVariantsForType(type);
  }

  /// Get all supported types
  List<String> get supportedTypes => _skeletonSystem.supportedTypes;
}