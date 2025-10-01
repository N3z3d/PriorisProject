/// SOLID Implementation: Slim Skeleton System
///
/// Orchestrates SOLID design patterns for skeleton generation.
/// RESPONSIBILITY: Coordinate Factory, Strategy, and Composite patterns.
/// CONSTRAINT: <200 lines following Clean Code orchestration principles.

import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interfaces.dart';
import 'package:prioris/presentation/widgets\loading\components\skeleton_component_factory.dart';
import 'package:prioris/presentation\widgets\loading\strategies\skeleton_layout_strategies.dart';

/// Slim skeleton system orchestrating SOLID patterns
/// SOLID COMPLIANCE: All principles - SRP, OCP, LSP, ISP, DIP
class SkeletonSystemSlim implements ISolidSkeletonSystem {
  // SOLID dependencies injected via interfaces (DIP)
  final ISkeletonComponentFactory _componentFactory;
  final SkeletonLayoutStrategyRegistry _strategyRegistry;

  // Predefined configurations for quick skeleton generation
  final Map<String, SkeletonConfiguration> _configurations;

  @override
  String get systemId => 'skeleton_system_slim';

  @override
  List<String> get supportedTypes => [
    'dashboard_page',
    'profile_page',
    'list_page',
    'detail_page',
    'card_layout',
    'form_layout',
    'grid_layout',
    'custom',
  ];

  /// Constructor with dependency injection (SOLID DIP)
  SkeletonSystemSlim({
    ISkeletonComponentFactory? componentFactory,
    SkeletonLayoutStrategyRegistry? strategyRegistry,
  }) : _componentFactory = componentFactory ?? SkeletonComponentFactory(),
       _strategyRegistry = strategyRegistry ?? SkeletonLayoutStrategyRegistry(),
       _configurations = _initializeConfigurations();

  /// Initialize predefined skeleton configurations
  static Map<String, SkeletonConfiguration> _initializeConfigurations() {
    return {
      'dashboard_page': SkeletonConfiguration(
        variant: 'dashboard',
        layoutStrategy: 'column',
        properties: {'padding': const EdgeInsets.all(16.0), 'spacing': 24.0},
        components: [
          ComponentSpec(type: 'text', width: 200, height: 24),
          ComponentSpec(type: 'card', height: 120),
          ComponentSpec(type: 'text', width: 150, height: 20),
          ComponentSpec(type: 'card', height: 80),
        ],
      ),
      'profile_page': SkeletonConfiguration(
        variant: 'profile',
        layoutStrategy: 'column',
        properties: {'padding': const EdgeInsets.all(16.0), 'spacing': 20.0},
        components: [
          ComponentSpec(type: 'avatar', width: 80, height: 80),
          ComponentSpec(type: 'text', width: 120, height: 20),
          ComponentSpec(type: 'text', width: 100, height: 16),
          ComponentSpec(type: 'card', height: 150),
        ],
      ),
      'list_page': SkeletonConfiguration(
        variant: 'list',
        layoutStrategy: 'column',
        properties: {'padding': const EdgeInsets.all(16.0), 'spacing': 16.0},
        components: [
          ComponentSpec(type: 'text', width: double.infinity, height: 48),
          ComponentSpec(type: 'card', height: 80),
          ComponentSpec(type: 'card', height: 80),
          ComponentSpec(type: 'card', height: 80),
        ],
      ),
      'grid_layout': SkeletonConfiguration(
        variant: 'grid',
        layoutStrategy: 'grid',
        properties: {
          'padding': const EdgeInsets.all(16.0),
          'crossAxisCount': 2,
          'spacing': 16.0,
          'childAspectRatio': 1.0,
        },
        components: [
          ComponentSpec(type: 'card', height: 120),
          ComponentSpec(type: 'card', height: 120),
          ComponentSpec(type: 'card', height: 120),
          ComponentSpec(type: 'card', height: 120),
        ],
      ),
    };
  }

  @override
  bool canHandle(String type) {
    return supportedTypes.contains(type) || _configurations.containsKey(type);
  }

  @override
  List<String> getVariantsForType(String type) {
    final config = _configurations[type];
    return config != null ? [config.variant] : [];
  }

  @override
  Widget createSkeleton({
    required String type,
    String? variant,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    try {
      // Get configuration for the skeleton type
      final config = _getConfiguration(type, variant);

      // Create components using Factory pattern
      final components = _createComponents(config, options);

      // Apply layout using Strategy pattern
      final layoutStrategy = _getLayoutStrategy(config.layoutStrategy);

      final finalOptions = _mergeOptions(config.properties, options);

      return layoutStrategy.applyLayout(
        components: components,
        layoutType: config.layoutStrategy,
        width: width,
        height: height,
        options: finalOptions,
      );
    } catch (e) {
      // Return fallback skeleton on error
      return _createFallbackSkeleton(width, height, options);
    }
  }

  /// Get configuration for skeleton type
  SkeletonConfiguration _getConfiguration(String type, String? variant) {
    final config = _configurations[type];
    if (config != null) {
      return config;
    }

    // Create dynamic configuration for unknown types
    return _createDynamicConfiguration(type, variant);
  }

  /// Create components using Factory pattern
  List<Widget> _createComponents(
    SkeletonConfiguration config,
    Map<String, dynamic>? options,
  ) {
    final isDark = options?['isDark'] ?? false;
    final animate = options?['animate'] ?? true;

    return config.components.map((componentSpec) {
      final componentOptions = Map<String, dynamic>.from(componentSpec.properties);
      componentOptions['type'] = componentSpec.type;
      componentOptions['isDark'] = isDark;

      if (animate) {
        return _componentFactory.createAnimatedComponent(
          width: componentSpec.width,
          height: componentSpec.height,
          options: componentOptions,
        );
      } else {
        return _componentFactory.createBasicComponent(
          width: componentSpec.width,
          height: componentSpec.height,
          options: componentOptions,
        );
      }
    }).toList();
  }

  /// Get layout strategy by name
  ISkeletonLayoutStrategy _getLayoutStrategy(String strategyName) {
    final strategy = _strategyRegistry.getStrategy(strategyName);
    if (strategy != null) {
      return strategy;
    }

    // Fallback to column strategy
    return _strategyRegistry.getStrategy('column')!;
  }

  /// Create dynamic configuration for unknown types
  SkeletonConfiguration _createDynamicConfiguration(String type, String? variant) {
    // Simple heuristics based on type name
    if (type.contains('grid') || type.contains('dashboard')) {
      return _configurations['grid_layout']!;
    } else if (type.contains('profile') || type.contains('user')) {
      return _configurations['profile_page']!;
    } else if (type.contains('list') || type.contains('items')) {
      return _configurations['list_page']!;
    } else {
      // Default card layout
      return SkeletonConfiguration(
        variant: variant ?? 'default',
        layoutStrategy: 'column',
        properties: const {'padding': EdgeInsets.all(16.0), 'spacing': 16.0},
        components: [
          ComponentSpec(type: 'card', height: 120),
        ],
      );
    }
  }

  /// Merge configuration properties with options
  Map<String, dynamic> _mergeOptions(
    Map<String, dynamic> configProperties,
    Map<String, dynamic>? options,
  ) {
    final merged = Map<String, dynamic>.from(configProperties);
    if (options != null) {
      merged.addAll(options);
    }
    return merged;
  }

  /// Create fallback skeleton for error cases
  Widget _createFallbackSkeleton(
    double? width,
    double? height,
    Map<String, dynamic>? options,
  ) {
    final isDark = options?['isDark'] ?? false;

    return _componentFactory.createBasicComponent(
      width: width ?? 200,
      height: height ?? 100,
      options: {'type': 'card', 'isDark': isDark},
    );
  }
}