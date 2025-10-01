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
}