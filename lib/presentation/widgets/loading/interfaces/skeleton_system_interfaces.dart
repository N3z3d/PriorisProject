/// SOLID Design Pattern Interfaces for Skeleton Systems
///
/// Implements Factory, Strategy, and Composite patterns to decompose
/// complex skeleton generation into manageable, single-responsibility components.

import 'package:flutter/material.dart';

/// Factory Pattern: Creates skeleton components
/// SOLID COMPLIANCE: SRP - Single responsibility for component creation
abstract class ISkeletonComponentFactory {
  /// Create basic skeleton component
  Widget createBasicComponent({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Map<String, dynamic>? options,
  });

  /// Create animated skeleton component
  Widget createAnimatedComponent({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Duration? animationDuration,
    Map<String, dynamic>? options,
  });

  /// Get supported component types
  List<String> get supportedTypes;
}

/// Strategy Pattern: Different layout strategies
/// SOLID COMPLIANCE: SRP - Single responsibility for layout strategy
abstract class ISkeletonLayoutStrategy {
  /// Apply layout strategy to components
  Widget applyLayout({
    required List<Widget> components,
    required String layoutType,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  });

  /// Check if strategy can handle layout type
  bool canHandleLayout(String layoutType);

  /// Get strategy name
  String get strategyName;
}

/// Composite Pattern: Compose complex skeletons from simpler ones
/// SOLID COMPLIANCE: SRP - Single responsibility for composition
abstract class ISkeletonComposite {
  /// Add child skeleton component
  void addComponent(Widget component);

  /// Remove child skeleton component
  void removeComponent(Widget component);

  /// Build composite skeleton
  Widget buildComposite({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  });

  /// Get all child components
  List<Widget> get components;
}

/// Builder Pattern: Build complex skeletons step by step
/// SOLID COMPLIANCE: SRP - Single responsibility for skeleton construction
abstract class ISkeletonBuilder {
  /// Set skeleton dimensions
  ISkeletonBuilder setDimensions({double? width, double? height});

  /// Set animation properties
  ISkeletonBuilder setAnimation({
    Duration? duration,
    Curve? curve,
    bool? repeat,
  });

  /// Add components to skeleton
  ISkeletonBuilder addComponents(List<Widget> components);

  /// Set layout type
  ISkeletonBuilder setLayout(String layoutType);

  /// Build final skeleton widget
  Widget build();

  /// Reset builder to initial state
  void reset();
}

/// Configuration for skeleton variants
/// SOLID COMPLIANCE: SRP - Single responsibility for configuration
class SkeletonConfiguration {
  final String variant;
  final Map<String, dynamic> properties;
  final List<ComponentSpec> components;
  final String layoutStrategy;

  const SkeletonConfiguration({
    required this.variant,
    required this.properties,
    required this.components,
    required this.layoutStrategy,
  });
}

/// Specification for a skeleton component
/// SOLID COMPLIANCE: ISP - Interface segregation for component specs
class ComponentSpec {
  final String type;
  final double? width;
  final double? height;
  final Map<String, dynamic> properties;

  const ComponentSpec({
    required this.type,
    this.width,
    this.height,
    this.properties = const {},
  });
}

/// Abstract skeleton system following SOLID principles
/// SOLID COMPLIANCE: OCP - Open for extension, closed for modification
abstract class ISolidSkeletonSystem {
  /// System identifier
  String get systemId;

  /// Supported skeleton types
  List<String> get supportedTypes;

  /// Create skeleton using SOLID patterns
  Widget createSkeleton({
    required String type,
    String? variant,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  });

  /// Check if system can handle type
  bool canHandle(String type);

  /// Get available variants for type
  List<String> getVariantsForType(String type);
}

/// Visitor Pattern: Process skeleton components
/// SOLID COMPLIANCE: OCP - Add new operations without modifying components
abstract class ISkeletonVisitor {
  /// Visit basic skeleton component
  void visitBasicComponent(Widget component);

  /// Visit animated skeleton component
  void visitAnimatedComponent(Widget component);

  /// Visit composite skeleton
  void visitComposite(ISkeletonComposite composite);
}

/// Command Pattern: Encapsulate skeleton creation operations
/// SOLID COMPLIANCE: SRP - Single responsibility for command execution
abstract class ISkeletonCommand {
  /// Execute skeleton creation command
  Widget execute();

  /// Undo skeleton creation (if applicable)
  void undo();

  /// Check if command can be undone
  bool get canUndo;
}

/// Observer Pattern: Notify about skeleton state changes
/// SOLID COMPLIANCE: DIP - Depend on abstractions for notifications
abstract class ISkeletonObserver {
  /// Notify when skeleton creation starts
  void onSkeletonCreationStarted(String skeletonType);

  /// Notify when skeleton creation completes
  void onSkeletonCreationCompleted(String skeletonType, Widget skeleton);

  /// Notify when skeleton creation fails
  void onSkeletonCreationFailed(String skeletonType, String error);
}

/// Registry Pattern: Register and retrieve skeleton systems
/// SOLID COMPLIANCE: SRP - Single responsibility for system registration
abstract class ISkeletonSystemRegistry {
  /// Register skeleton system
  void registerSystem(ISolidSkeletonSystem system);

  /// Unregister skeleton system
  void unregisterSystem(String systemId);

  /// Get system by ID
  ISolidSkeletonSystem? getSystem(String systemId);

  /// Get system that can handle type
  ISolidSkeletonSystem? getSystemForType(String skeletonType);

  /// Get all registered systems
  List<ISolidSkeletonSystem> get allSystems;
}