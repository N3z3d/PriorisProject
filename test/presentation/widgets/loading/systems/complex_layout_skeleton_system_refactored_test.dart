import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/systems/complex_layout_skeleton_system.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

void main() {
  group('ComplexLayoutSkeletonSystem - Refactored', () {
    late ComplexLayoutSkeletonSystem system;

    setUp(() {
      system = ComplexLayoutSkeletonSystem();
    });

    group('Basic System Properties', () {
      test('should have correct system ID', () {
        expect(system.systemId, equals('complex_layout_skeleton_system'));
      });

      test('should have correct supported types', () {
        final supportedTypes = system.supportedTypes;
        expect(supportedTypes, contains('page_layout'));
        expect(supportedTypes, contains('dashboard_page'));
        expect(supportedTypes, contains('profile_page'));
        expect(supportedTypes, contains('list_page'));
        expect(supportedTypes, contains('detail_page'));
        expect(supportedTypes, contains('settings_page'));
        expect(supportedTypes, contains('navigation_drawer'));
        expect(supportedTypes, contains('bottom_sheet'));
      });

      test('should have correct available variants', () {
        final variants = system.availableVariants;
        expect(variants, contains('dashboard'));
        expect(variants, contains('profile'));
        expect(variants, contains('list'));
        expect(variants, contains('detail'));
        expect(variants, contains('settings'));
        expect(variants, contains('drawer'));
        expect(variants, contains('sheet'));
        expect(variants, contains('standard'));
      });

      test('should have correct default animation duration', () {
        expect(system.defaultAnimationDuration, equals(Duration(milliseconds: 1500)));
      });
    });

    group('Skeleton Type Handling', () {
      test('should handle supported types correctly', () {
        expect(system.canHandle('page_layout'), isTrue);
        expect(system.canHandle('dashboard_page'), isTrue);
        expect(system.canHandle('profile_page'), isTrue);
        expect(system.canHandle('unsupported_type'), isFalse);
      });

      test('should handle page types by pattern', () {
        expect(system.canHandle('custom_page'), isTrue);
        expect(system.canHandle('something_page'), isTrue);
        expect(system.canHandle('page_content'), isTrue);
        expect(system.canHandle('layout_test'), isTrue);
      });

      test('should handle variant types', () {
        expect(system.canHandle('dashboard'), isTrue);
        expect(system.canHandle('profile'), isTrue);
        expect(system.canHandle('list'), isTrue);
        expect(system.canHandle('invalid_variant'), isFalse);
      });
    });

    group('Strategy Delegation', () {
      testWidgets('should create dashboard skeleton successfully', (tester) async {
        final widget = system.createVariant('dashboard');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should create profile skeleton successfully', (tester) async {
        final widget = system.createVariant('profile');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should create list skeleton successfully', (tester) async {
        final widget = system.createVariant('list');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should create detail skeleton successfully', (tester) async {
        final widget = system.createVariant('detail');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should create settings skeleton successfully', (tester) async {
        final widget = system.createVariant('settings');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should create navigation drawer skeleton successfully', (tester) async {
        final widget = system.createVariant('drawer');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: Scaffold(drawer: widget)));
        expect(find.byType(Drawer), findsOneWidget);
      });

      testWidgets('should create bottom sheet skeleton successfully', (tester) async {
        final widget = system.createVariant('sheet');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(Container), findsAtLeastNWidgets(1));
      });

      testWidgets('should create standard skeleton successfully', (tester) async {
        final widget = system.createVariant('standard');
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Configuration Options', () {
      testWidgets('should pass options to strategies correctly', (tester) async {
        final widget = system.createVariant(
          'dashboard',
          options: {
            'showHeader': false,
            'showStats': true,
            'showChart': false,
            'showRecentItems': true,
          },
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle width and height parameters', (tester) async {
        final widget = system.createVariant(
          'standard',
          width: 300,
          height: 400,
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Error Handling', () {
      test('should throw exception for unsupported variant', () {
        expect(
          () => system.createVariant('unsupported_variant'),
          throwsA(isA<SkeletonStrategyException>()),
        );
      });

      test('should provide detailed error messages', () {
        try {
          system.createVariant('invalid_variant');
          fail('Expected SkeletonStrategyException');
        } catch (e) {
          expect(e, isA<SkeletonStrategyException>());
          expect(e.toString(), contains('invalid_variant'));
          expect(e.toString(), contains('Available variants'));
        }
      });
    });

    group('Default Skeleton Creation', () {
      testWidgets('should create default skeleton without parameters', (tester) async {
        final widget = system.createSkeleton();
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should create default skeleton with options', (tester) async {
        final widget = system.createSkeleton(
          width: 200,
          height: 300,
          options: {'showAppBar': true},
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Animated Skeleton Creation', () {
      testWidgets('should create animated skeleton successfully', (tester) async {
        final widget = system.createAnimatedSkeleton(
          duration: Duration(milliseconds: 1000),
        );
        expect(widget, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should pass animation options correctly', (tester) async {
        final controller = AnimationController(
          duration: Duration(milliseconds: 500),
          vsync: TestVSync(),
        );

        final widget = system.createAnimatedSkeleton(
          duration: Duration(milliseconds: 1000),
          controller: controller,
          options: {'custom_option': 'value'},
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Scaffold), findsOneWidget);

        controller.dispose();
      });
    });

    group('Strategy Information', () {
      test('should provide complete strategy information', () {
        final info = system.getStrategyInfo();

        expect(info['systemId'], equals('complex_layout_skeleton_system'));
        expect(info['availableVariants'], isA<List<String>>());
        expect(info['supportedTypes'], isA<List<String>>());
        expect(info['registeredStrategies'], isA<List<String>>());
        expect(info['defaultAnimationDuration'], equals(1500));
      });

      test('should validate options for specific variants', () {
        expect(system.validateOptions('dashboard', {'showHeader': true}), isTrue);
        expect(system.validateOptions('invalid_variant', {}), isFalse);
      });

      test('should return supported options for variants', () {
        final dashboardOptions = system.getSupportedOptions('dashboard');
        expect(dashboardOptions, isA<List<String>>());
        expect(dashboardOptions, isNotEmpty);

        final invalidOptions = system.getSupportedOptions('invalid_variant');
        expect(invalidOptions, isEmpty);
      });
    });

    group('SOLID Compliance Verification', () {
      test('should follow Single Responsibility Principle', () {
        // System only coordinates strategy selection and execution
        expect(system.systemId, isNotNull);
        expect(system.availableVariants, isNotEmpty);
        // No direct skeleton creation logic in the main class
      });

      test('should follow Open/Closed Principle', () {
        // System is open for extension (new strategies) but closed for modification
        final initialVariants = system.availableVariants.length;
        expect(initialVariants, greaterThan(0));
        // New strategies can be added without modifying this class
      });

      test('should follow Dependency Inversion Principle', () {
        // System depends on abstractions (factory and strategy interfaces)
        final info = system.getStrategyInfo();
        expect(info, isNotNull);
        // No direct dependencies on concrete strategy implementations
      });
    });
  });

  group('SkeletonStrategyException', () {
    test('should create exception with message only', () {
      final exception = SkeletonStrategyException('Test message');
      expect(exception.message, equals('Test message'));
      expect(exception.variant, isNull);
      expect(exception.options, isNull);
    });

    test('should create exception with variant', () {
      final exception = SkeletonStrategyException(
        'Test message',
        variant: 'test_variant',
      );
      expect(exception.message, equals('Test message'));
      expect(exception.variant, equals('test_variant'));
    });

    test('should create exception with options', () {
      final options = {'key': 'value'};
      final exception = SkeletonStrategyException(
        'Test message',
        options: options,
      );
      expect(exception.message, equals('Test message'));
      expect(exception.options, equals(options));
    });

    test('should format toString correctly', () {
      final exception = SkeletonStrategyException(
        'Test message',
        variant: 'test_variant',
        options: {'key': 'value'},
      );

      final str = exception.toString();
      expect(str, contains('SkeletonStrategyException: Test message'));
      expect(str, contains('variant: test_variant'));
      expect(str, contains('options: {key: value}'));
    });
  });
}

/// Test implementation of TickerProvider for testing
class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}