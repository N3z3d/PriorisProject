import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/factories/skeleton_strategy_factory.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';
import 'package:prioris/presentation/widgets/loading/strategies/dashboard_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/profile_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/list_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/detail_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/settings_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/navigation_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/sheet_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/strategies/standard_skeleton_strategy.dart';

void main() {
  group('SkeletonStrategyFactory', () {
    late SkeletonStrategyFactory factory;

    setUp(() {
      factory = SkeletonStrategyFactory();
      factory.clearCache(); // Ensure clean state for each test
    });

    group('Singleton Pattern', () {
      test('should return same instance on multiple calls', () {
        final factory1 = SkeletonStrategyFactory();
        final factory2 = SkeletonStrategyFactory();
        expect(identical(factory1, factory2), isTrue);
      });
    });

    group('Strategy Creation', () {
      test('should create dashboard strategy', () {
        final strategy = factory.getStrategy('dashboard');
        expect(strategy, isA<DashboardSkeletonStrategy>());
        expect(strategy?.variant, equals('dashboard'));
        expect(strategy?.strategyId, equals('dashboard_skeleton_strategy'));
      });

      test('should create profile strategy', () {
        final strategy = factory.getStrategy('profile');
        expect(strategy, isA<ProfileSkeletonStrategy>());
        expect(strategy?.variant, equals('profile'));
        expect(strategy?.strategyId, equals('profile_skeleton_strategy'));
      });

      test('should create list strategy', () {
        final strategy = factory.getStrategy('list');
        expect(strategy, isA<ListSkeletonStrategy>());
        expect(strategy?.variant, equals('list'));
        expect(strategy?.strategyId, equals('list_skeleton_strategy'));
      });

      test('should create detail strategy', () {
        final strategy = factory.getStrategy('detail');
        expect(strategy, isA<DetailSkeletonStrategy>());
        expect(strategy?.variant, equals('detail'));
        expect(strategy?.strategyId, equals('detail_skeleton_strategy'));
      });

      test('should create settings strategy', () {
        final strategy = factory.getStrategy('settings');
        expect(strategy, isA<SettingsSkeletonStrategy>());
        expect(strategy?.variant, equals('settings'));
        expect(strategy?.strategyId, equals('settings_skeleton_strategy'));
      });

      test('should create navigation strategy', () {
        final strategy = factory.getStrategy('drawer');
        expect(strategy, isA<NavigationSkeletonStrategy>());
        expect(strategy?.variant, equals('drawer'));
        expect(strategy?.strategyId, equals('navigation_skeleton_strategy'));
      });

      test('should create sheet strategy', () {
        final strategy = factory.getStrategy('sheet');
        expect(strategy, isA<SheetSkeletonStrategy>());
        expect(strategy?.variant, equals('sheet'));
        expect(strategy?.strategyId, equals('sheet_skeleton_strategy'));
      });

      test('should create standard strategy', () {
        final strategy = factory.getStrategy('standard');
        expect(strategy, isA<StandardSkeletonStrategy>());
        expect(strategy?.variant, equals('standard'));
        expect(strategy?.strategyId, equals('standard_skeleton_strategy'));
      });

      test('should return null for unsupported variant', () {
        final strategy = factory.getStrategy('unsupported_variant');
        expect(strategy, isNull);
      });
    });

    group('Strategy Caching', () {
      test('should cache strategy instances', () {
        final strategy1 = factory.getStrategy('dashboard');
        final strategy2 = factory.getStrategy('dashboard');
        expect(identical(strategy1, strategy2), isTrue);
      });

      test('should return different instances for different variants', () {
        final dashboardStrategy = factory.getStrategy('dashboard');
        final profileStrategy = factory.getStrategy('profile');
        expect(identical(dashboardStrategy, profileStrategy), isFalse);
      });

      test('should clear cache correctly', () {
        factory.getStrategy('dashboard');
        expect(factory.registeredStrategies, isNotEmpty);

        factory.clearCache();
        expect(factory.registeredStrategies, isEmpty);
      });
    });

    group('Available Variants', () {
      test('should return all available variants', () {
        final variants = factory.availableVariants;
        expect(variants, contains('dashboard'));
        expect(variants, contains('profile'));
        expect(variants, contains('list'));
        expect(variants, contains('detail'));
        expect(variants, contains('settings'));
        expect(variants, contains('drawer'));
        expect(variants, contains('sheet'));
        expect(variants, contains('standard'));
        expect(variants.length, equals(8));
      });

      test('should support variant validation', () {
        expect(factory.supportsVariant('dashboard'), isTrue);
        expect(factory.supportsVariant('profile'), isTrue);
        expect(factory.supportsVariant('invalid_variant'), isFalse);
      });
    });

    group('Custom Strategy Registration', () {
      test('should register custom strategy', () {
        final customStrategy = MockSkeletonStrategy();
        factory.registerStrategy('custom', customStrategy);

        final retrievedStrategy = factory.getStrategy('custom');
        expect(identical(retrievedStrategy, customStrategy), isTrue);
      });

      test('should override existing strategy with registration', () {
        final originalStrategy = factory.getStrategy('dashboard');
        final customStrategy = MockSkeletonStrategy();

        factory.registerStrategy('dashboard', customStrategy);
        final newStrategy = factory.getStrategy('dashboard');

        expect(identical(newStrategy, customStrategy), isTrue);
        expect(identical(newStrategy, originalStrategy), isFalse);
      });

      test('should return registered strategies map', () {
        factory.getStrategy('dashboard');
        factory.getStrategy('profile');

        final registered = factory.registeredStrategies;
        expect(registered.keys, contains('dashboard'));
        expect(registered.keys, contains('profile'));
        expect(registered.length, equals(2));
      });
    });

    group('Error Handling', () {
      test('should handle null variant gracefully', () {
        expect(() => factory.supportsVariant(''), isFalse);
      });

      test('should handle empty variant gracefully', () {
        final strategy = factory.getStrategy('');
        expect(strategy, isNull);
      });
    });

    group('Factory Pattern Compliance', () {
      test('should encapsulate strategy creation logic', () {
        // Factory should hide the complexity of strategy instantiation
        final strategy = factory.getStrategy('dashboard');
        expect(strategy, isNotNull);
        expect(strategy, isA<ISkeletonStrategy>());
      });

      test('should provide consistent interface', () {
        for (final variant in factory.availableVariants) {
          final strategy = factory.getStrategy(variant);
          expect(strategy, isNotNull);
          expect(strategy, isA<ISkeletonStrategy>());
          expect(strategy?.variant, equals(variant));
        }
      });
    });

    group('Memory Management', () {
      test('should reuse cached instances efficiently', () {
        // Create multiple strategies and verify caching
        final variants = ['dashboard', 'profile', 'list'];
        final firstBatch = variants.map((v) => factory.getStrategy(v)).toList();
        final secondBatch = variants.map((v) => factory.getStrategy(v)).toList();

        for (int i = 0; i < variants.length; i++) {
          expect(identical(firstBatch[i], secondBatch[i]), isTrue);
        }
      });

      test('should handle cache clearing without affecting factory state', () {
        factory.getStrategy('dashboard');
        expect(factory.registeredStrategies, isNotEmpty);

        factory.clearCache();
        expect(factory.registeredStrategies, isEmpty);

        // Should still be able to create new strategies after clearing
        final newStrategy = factory.getStrategy('dashboard');
        expect(newStrategy, isNotNull);
        expect(newStrategy, isA<DashboardSkeletonStrategy>());
      });
    });
  });
}

/// Mock strategy for testing custom registration
class MockSkeletonStrategy implements ISkeletonStrategy {
  @override
  String get strategyId => 'mock_strategy';

  @override
  String get variant => 'mock';

  @override
  List<String> get supportedOptions => ['mock_option'];

  @override
  Widget createSkeleton(SkeletonConfig config) {
    return Container();
  }

  @override
  bool canHandle(Map<String, dynamic> options) => true;
}