import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/dashboard_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/profile_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/list_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/detail_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/settings_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/navigation_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/sheet_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/standard_skeleton_strategy.dart';

/// Factory for creating skeleton strategies
/// Single Responsibility: Create and manage skeleton strategy instances
/// Following Factory pattern and DIP (Dependency Inversion Principle)
class SkeletonStrategyFactory {
  static final SkeletonStrategyFactory _instance = SkeletonStrategyFactory._internal();
  factory SkeletonStrategyFactory() => _instance;
  SkeletonStrategyFactory._internal();

  // Strategy instances cache for reuse
  final Map<String, ISkeletonStrategy> _strategies = {};

  /// Creates or returns cached strategy instance by variant
  ISkeletonStrategy? getStrategy(String variant) {
    if (_strategies.containsKey(variant)) {
      return _strategies[variant];
    }

    final strategy = _createStrategy(variant);
    if (strategy != null) {
      _strategies[variant] = strategy;
    }

    return strategy;
  }

  /// Creates a new strategy instance based on variant
  ISkeletonStrategy? _createStrategy(String variant) {
    switch (variant) {
      case 'dashboard':
        return DashboardSkeletonStrategy();
      case 'profile':
        return ProfileSkeletonStrategy();
      case 'list':
        return ListSkeletonStrategy();
      case 'detail':
        return DetailSkeletonStrategy();
      case 'settings':
        return SettingsSkeletonStrategy();
      case 'drawer':
        return NavigationSkeletonStrategy();
      case 'sheet':
        return SheetSkeletonStrategy();
      case 'standard':
        return StandardSkeletonStrategy();
      default:
        return null;
    }
  }

  /// Returns all available strategy variants
  List<String> get availableVariants => [
    'dashboard',
    'profile',
    'list',
    'detail',
    'settings',
    'drawer',
    'sheet',
    'standard',
  ];

  /// Validates if a variant is supported
  bool supportsVariant(String variant) {
    return availableVariants.contains(variant);
  }

  /// Registers a custom strategy
  void registerStrategy(String variant, ISkeletonStrategy strategy) {
    _strategies[variant] = strategy;
  }

  /// Clears the strategy cache
  void clearCache() {
    _strategies.clear();
  }

  /// Returns all registered strategy instances
  Map<String, ISkeletonStrategy> get registeredStrategies =>
      Map.unmodifiable(_strategies);
}