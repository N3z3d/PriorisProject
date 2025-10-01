import 'package:flutter/material.dart';

/// Interface defining the contract for all skeleton systems
/// Following ISP (Interface Segregation Principle) - focused interface
abstract class ISkeletonSystem {
  /// Creates a skeleton widget based on the provided configuration
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  });

  /// Returns the system identifier for dependency injection
  String get systemId;

  /// Returns supported skeleton types for this system
  List<String> get supportedTypes;

  /// Validates if the system can handle the requested skeleton type
  bool canHandle(String skeletonType);
}

/// Interface for skeleton systems that support multiple variants
abstract class IVariantSkeletonSystem extends ISkeletonSystem {
  /// Creates a skeleton variant based on type and configuration
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  });

  /// Returns available variants for this system
  List<String> get availableVariants;
}

/// Interface for skeleton systems with animation capabilities
abstract class IAnimatedSkeletonSystem extends ISkeletonSystem {
  /// Creates an animated skeleton with custom animation settings
  Widget createAnimatedSkeleton({
    double? width,
    double? height,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  });

  /// Default animation duration for this system
  Duration get defaultAnimationDuration;
}

/// Configuration class for skeleton creation
class SkeletonConfig {
  final double? width;
  final double? height;
  final Map<String, dynamic> options;
  final Duration? animationDuration;
  final AnimationController? animationController;

  const SkeletonConfig({
    this.width,
    this.height,
    this.options = const {},
    this.animationDuration,
    this.animationController,
  });

  SkeletonConfig copyWith({
    double? width,
    double? height,
    Map<String, dynamic>? options,
    Duration? animationDuration,
    AnimationController? animationController,
  }) {
    return SkeletonConfig(
      width: width ?? this.width,
      height: height ?? this.height,
      options: options ?? this.options,
      animationDuration: animationDuration ?? this.animationDuration,
      animationController: animationController ?? this.animationController,
    );
  }
}

/// Factory interface for creating skeleton systems
abstract class ISkeletonSystemFactory {
  /// Creates a skeleton system by identifier
  ISkeletonSystem? createSystem(String systemId);

  /// Registers a new skeleton system
  void registerSystem(String systemId, ISkeletonSystem system);

  /// Returns all registered system identifiers
  List<String> get registeredSystems;
}