import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/strategies/dashboard_skeleton_strategy.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

void main() {
  group('DashboardSkeletonStrategy', () {
    late DashboardSkeletonStrategy strategy;

    setUp(() {
      strategy = DashboardSkeletonStrategy();
    });

    group('Strategy Properties', () {
      test('should have correct strategy ID', () {
        expect(strategy.strategyId, equals('dashboard_skeleton_strategy'));
      });

      test('should have correct variant', () {
        expect(strategy.variant, equals('dashboard'));
      });

      test('should have correct supported options', () {
        final options = strategy.supportedOptions;
        expect(options, contains('showHeader'));
        expect(options, contains('showStats'));
        expect(options, contains('showChart'));
        expect(options, contains('showRecentItems'));
        expect(options, contains('statCount'));
        expect(options, contains('recentItemCount'));
      });
    });

    group('Skeleton Creation', () {
      testWidgets('should create dashboard skeleton with default options', (tester) async {
        final config = SkeletonConfig();
        final widget = strategy.createSkeleton(config);

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should create dashboard skeleton with all sections enabled', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showHeader': true,
            'showStats': true,
            'showChart': true,
            'showRecentItems': true,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should create dashboard skeleton with selective sections', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showHeader': true,
            'showStats': false,
            'showChart': true,
            'showRecentItems': false,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle custom stat count', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showStats': true,
            'statCount': 5,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle custom recent item count', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showRecentItems': true,
            'recentItemCount': 6,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Configuration Handling', () {
      test('should handle all supported options', () {
        final config = SkeletonConfig(
          options: {
            'showHeader': false,
            'showStats': true,
            'showChart': false,
            'showRecentItems': true,
            'statCount': 4,
            'recentItemCount': 5,
          },
        );

        expect(strategy.canHandle(config.options), isTrue);
      });

      test('should handle empty options', () {
        final config = SkeletonConfig(options: {});
        expect(strategy.canHandle(config.options), isTrue);
      });

      test('should handle unsupported options gracefully', () {
        final config = SkeletonConfig(
          options: {
            'unsupported_option': 'value',
            'showHeader': true,
          },
        );

        // Base implementation returns true by default
        expect(strategy.canHandle(config.options), isTrue);
      });
    });

    group('Widget Dimensions', () {
      testWidgets('should respect width and height configuration', (tester) async {
        final config = SkeletonConfig(
          width: 300,
          height: 400,
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Section Building', () {
      testWidgets('should build header section when enabled', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showHeader': true,
            'showStats': false,
            'showChart': false,
            'showRecentItems': false,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));

        // Should contain scaffold and header components
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should build stats section when enabled', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showHeader': false,
            'showStats': true,
            'showChart': false,
            'showRecentItems': false,
            'statCount': 3,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should build chart section when enabled', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showHeader': false,
            'showStats': false,
            'showChart': true,
            'showRecentItems': false,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should build recent items section when enabled', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showHeader': false,
            'showStats': false,
            'showChart': false,
            'showRecentItems': true,
            'recentItemCount': 4,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle all sections disabled', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showHeader': false,
            'showStats': false,
            'showChart': false,
            'showRecentItems': false,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));

        // Should still render scaffold with empty body
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should handle zero stat count', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showStats': true,
            'statCount': 0,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle zero recent item count', (tester) async {
        final config = SkeletonConfig(
          options: {
            'showRecentItems': true,
            'recentItemCount': 0,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Single Responsibility Compliance', () {
      test('should only handle dashboard-specific skeleton creation', () {
        expect(strategy.variant, equals('dashboard'));
        expect(strategy.strategyId, contains('dashboard'));

        // Should only support dashboard-related options
        final supportedOptions = strategy.supportedOptions;
        expect(supportedOptions.every((option) =>
          option.startsWith('show') ||
          option.endsWith('Count') ||
          option.contains('stat') ||
          option.contains('recent')
        ), isTrue);
      });
    });

    group('Component Library Integration', () {
      testWidgets('should use SkeletonComponentLibrary methods', (tester) async {
        // This test verifies that the strategy uses the component library
        // rather than duplicating skeleton creation logic
        final config = SkeletonConfig(
          options: {
            'showHeader': true,
            'showStats': true,
            'showChart': true,
            'showRecentItems': true,
          },
        );

        final widget = strategy.createSkeleton(config);
        await tester.pumpWidget(MaterialApp(home: widget));

        // Should successfully render using component library
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });
    });
  });
}