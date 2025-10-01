import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/factories/skeleton_strategy_factory.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';

/// Refactored complex layout skeleton system using Strategy pattern
/// Single Responsibility: Coordinate skeleton creation through strategies
/// Follows SRP, OCP, DIP and Strategy pattern - now under 500 lines
///
/// SOLID Compliance:
/// - SRP: Only responsible for coordinating strategy selection and execution
/// - OCP: Open for extension (new strategies) closed for modification
/// - LSP: All strategies implement ISkeletonStrategy correctly
/// - ISP: Uses focused interfaces for each concern
/// - DIP: Depends on abstractions (factory and strategy interfaces)
class ComplexLayoutSkeletonSystem implements IVariantSkeletonSystem, IAnimatedSkeletonSystem {
  final SkeletonStrategyFactory _strategyFactory = SkeletonStrategyFactory();

  @override
  String get systemId => 'complex_layout_skeleton_system';

  @override
  List<String> get supportedTypes => [
    'page_layout',
    'dashboard_page',
    'profile_page',
    'list_page',
    'detail_page',
    'settings_page',
    'navigation_drawer',
    'bottom_sheet',
  ];

  @override
  List<String> get availableVariants => _strategyFactory.availableVariants;

  @override
  Duration get defaultAnimationDuration => const Duration(milliseconds: 1500);

  @override
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'standard',
      width: width,
      height: height,
      options: options,
    );
  }

  @override
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final config = SkeletonConfig(
      width: width,
      height: height,
      options: options ?? {},
    );

    return _delegateToStrategy(variant, config);
  }

  @override
  Widget createAnimatedSkeleton({
    double? width,
    double? height,
    Duration? duration,
    AnimationController? controller,
    Map<String, dynamic>? options,
  }) {
    return createVariant(
      'standard',
      width: width,
      height: height,
      options: {
        ...options ?? {},
        'animation_duration': duration,
        'animation_controller': controller,
      },
    );
  }

  @override
  bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.endsWith('_page') ||
           skeletonType.contains('page') ||
           skeletonType.contains('layout') ||
           _strategyFactory.supportsVariant(skeletonType);
  }

  /// Delegates skeleton creation to appropriate strategy
  /// Follows Strategy pattern and DIP
  /// Method is under 50 lines as per CLAUDE.md requirements
  Widget _delegateToStrategy(String variant, SkeletonConfig config) {
    try {
      final strategy = _strategyFactory.getStrategy(variant);

      if (strategy == null) {
        throw SkeletonStrategyException(
          'Unsupported skeleton variant: $variant. '
          'Available variants: ${availableVariants.join(', ')}',
        );
      }

      if (!strategy.canHandle(config.options)) {
        throw SkeletonStrategyException(
          'Strategy $variant cannot handle provided options. '
          'Supported options: ${strategy.supportedOptions.join(', ')}',
        );
      }

      return strategy.createSkeleton(config);
    } catch (e) {
      if (e is SkeletonStrategyException) {
        rethrow;
      }
      throw SkeletonStrategyException(
        'Failed to create skeleton for variant $variant: $e',
      );
    }
  }

  /// Returns strategy information for debugging and monitoring
  Map<String, dynamic> getStrategyInfo() {
    return {
      'systemId': systemId,
      'availableVariants': availableVariants,
      'supportedTypes': supportedTypes,
      'registeredStrategies': _strategyFactory.registeredStrategies.keys.toList(),
      'defaultAnimationDuration': defaultAnimationDuration.inMilliseconds,
    };
  }

  /// Validates configuration options for a specific variant
  /// Useful for pre-validation before skeleton creation
  bool validateOptions(String variant, Map<String, dynamic> options) {
    final strategy = _strategyFactory.getStrategy(variant);
    return strategy?.canHandle(options) ?? false;
  }

  /// Returns supported options for a specific variant
  /// Useful for dynamic UI generation
  List<String> getSupportedOptions(String variant) {
    final strategy = _strategyFactory.getStrategy(variant);
    return strategy?.supportedOptions ?? [];
  }
}

/// Custom exception for skeleton strategy errors
/// Following single responsibility and clear error handling
class SkeletonStrategyException implements Exception {
  final String message;
  final String? variant;
  final Map<String, dynamic>? options;

  const SkeletonStrategyException(
    this.message, {
    this.variant,
    this.options,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SkeletonStrategyException: $message');
    if (variant != null) {
      buffer.write(' (variant: $variant)');
    }
    if (options != null && options!.isNotEmpty) {
      buffer.write(' (options: $options)');
    }
    return buffer.toString();
  }
}