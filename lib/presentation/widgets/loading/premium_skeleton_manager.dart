import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeleton_coordinator.dart';

/// Export PremiumSkeletons for backward compatibility
export 'premium_skeletons.dart' show PremiumSkeletons;

/// Legacy adapter for PremiumSkeletonCoordinator
///
/// This class provides backward compatibility for existing code that expects
/// a PremiumSkeletonManager while internally using the new SOLID-based
/// PremiumSkeletonCoordinator architecture.
class PremiumSkeletonManager {
  static final PremiumSkeletonManager _instance = PremiumSkeletonManager._internal();
  factory PremiumSkeletonManager() => _instance;
  PremiumSkeletonManager._internal();

  final PremiumSkeletonCoordinator _coordinator = PremiumSkeletonCoordinator();

  /// Creates a skeleton variant using the new coordinator system
  Widget createSkeletonVariant(
    String systemId,
    String skeletonType, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return _coordinator.createSkeletonByType(
      skeletonType,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Creates a skeleton widget by type
  Widget createSkeletonByType(
    String skeletonType, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return _coordinator.createSkeletonByType(
      skeletonType,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Gets all available skeleton types
  List<String> get availableSkeletonTypes => _coordinator.availableSkeletonTypes;

  /// Gets all registered systems
  List<String> get registeredSystems => _coordinator.registeredSystems;

  /// Registers a new skeleton system
  void registerSystem(String systemId, system) {
    // Forward to coordinator if needed
    _coordinator.registerSystem(systemId, system);
  }

  /// Creates an adaptive skeleton wrapper.
  Widget createAdaptiveSkeleton({
    required Widget child,
    required bool isLoading,
    String? skeletonType,
    Duration animationDuration = const Duration(milliseconds: 300),
    Map<String, dynamic>? options,
  }) {
    return _coordinator.createAdaptiveSkeleton(
      child: child,
      isLoading: isLoading,
      skeletonType: skeletonType,
      animationDuration: animationDuration,
      options: options,
    );
  }

  /// Creates a smart skeleton using hint detection.
  Widget createSmartSkeleton(
    String hint, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return _coordinator.createSmartSkeleton(
      hint,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Batch creation helper.
  List<Widget> createBatchSkeletons(
    String skeletonType, {
    required int count,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return _coordinator.createBatchSkeletons(
      skeletonType,
      count: count,
      width: width,
      height: height,
      options: options,
    );
  }

  /// Returns coordinator diagnostics.
  Map<String, dynamic> getSystemInfo() => _coordinator.getSystemInfo();

  /// Checks skeleton type support.
  bool isSkeletonTypeSupported(String skeletonType) =>
      _coordinator.isSkeletonTypeSupported(skeletonType);
}
