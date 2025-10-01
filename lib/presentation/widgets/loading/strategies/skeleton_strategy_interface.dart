import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Interface for skeleton creation strategies
/// Following ISP (Interface Segregation Principle) - focused interface
/// Single Responsibility: Define contract for page-specific skeleton creation
abstract class ISkeletonStrategy {
  /// Returns the strategy identifier
  String get strategyId;

  /// Returns the strategy variant name
  String get variant;

  /// Creates a skeleton widget for this strategy
  Widget createSkeleton(SkeletonConfig config);

  /// Validates if the strategy can handle the given options
  bool canHandle(Map<String, dynamic> options) => true;

  /// Returns the supported options for this strategy
  List<String> get supportedOptions;
}

/// Base abstract class for skeleton strategies
/// Following Template Method pattern for common skeleton structure
abstract class BaseSkeletonStrategy implements ISkeletonStrategy {
  @override
  Widget createSkeleton(SkeletonConfig config) {
    if (!canHandle(config.options)) {
      throw ArgumentError('Strategy ${strategyId} cannot handle provided options');
    }

    return buildSkeletonLayout(config);
  }

  /// Template method for building skeleton layout
  /// Must be implemented by concrete strategies
  Widget buildSkeletonLayout(SkeletonConfig config);

  /// Helper method to get option value with fallback
  T getOption<T>(Map<String, dynamic> options, String key, T defaultValue) {
    return options[key] as T? ?? defaultValue;
  }

  /// Helper method to validate required options
  void validateRequiredOptions(Map<String, dynamic> options, List<String> required) {
    for (final option in required) {
      if (!options.containsKey(option)) {
        throw ArgumentError('Required option "$option" is missing for strategy ${strategyId}');
      }
    }
  }
}