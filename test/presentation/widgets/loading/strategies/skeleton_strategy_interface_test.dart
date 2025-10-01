import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/strategies/skeleton_strategy_interface.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

void main() {
  group('ISkeletonStrategy Interface', () {
    test('should define required interface methods', () {
      // This test verifies that the interface is properly defined
      expect(ISkeletonStrategy, isA<Type>());
    });
  });

  group('BaseSkeletonStrategy', () {
    late TestSkeletonStrategy strategy;

    setUp(() {
      strategy = TestSkeletonStrategy();
    });

    group('Template Method Pattern', () {
      testWidgets('should execute template method correctly', (tester) async {
        final config = SkeletonConfig(
          width: 100,
          height: 200,
          options: {'test_option': 'value'},
        );

        final widget = strategy.createSkeleton(config);
        expect(widget, isA<Container>());

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.byType(Container), findsOneWidget);
      });

      test('should validate configuration before building', () {
        final validConfig = SkeletonConfig(
          options: {'valid_option': 'value'},
        );

        final invalidConfig = SkeletonConfig(
          options: {'invalid_option': 'value'},
        );

        expect(() => strategy.createSkeleton(validConfig), returnsNormally);
        expect(
          () => strategy.createSkeleton(invalidConfig),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Helper Methods', () {
      test('should get option with fallback', () {
        final options = {'existing_key': 'existing_value'};

        expect(strategy.getOption(options, 'existing_key', 'default'), equals('existing_value'));
        expect(strategy.getOption(options, 'missing_key', 'default'), equals('default'));
      });

      test('should handle different option types', () {
        final options = {
          'string_option': 'text',
          'int_option': 42,
          'bool_option': true,
          'list_option': [1, 2, 3],
        };

        expect(strategy.getOption<String>(options, 'string_option', ''), equals('text'));
        expect(strategy.getOption<int>(options, 'int_option', 0), equals(42));
        expect(strategy.getOption<bool>(options, 'bool_option', false), isTrue);
        expect(strategy.getOption<List<int>>(options, 'list_option', []), equals([1, 2, 3]));
      });

      test('should validate required options', () {
        final completeOptions = {
          'required1': 'value1',
          'required2': 'value2',
        };

        final incompleteOptions = {
          'required1': 'value1',
        };

        expect(
          () => strategy.validateRequiredOptions(completeOptions, ['required1', 'required2']),
          returnsNormally,
        );

        expect(
          () => strategy.validateRequiredOptions(incompleteOptions, ['required1', 'required2']),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Interface Compliance', () {
      test('should have correct strategy properties', () {
        expect(strategy.strategyId, equals('test_strategy'));
        expect(strategy.variant, equals('test'));
        expect(strategy.supportedOptions, contains('valid_option'));
        expect(strategy.supportedOptions, contains('test_option'));
      });

      test('should handle options correctly', () {
        expect(strategy.canHandle({'valid_option': 'value'}), isTrue);
        expect(strategy.canHandle({'invalid_option': 'value'}), isFalse);
        expect(strategy.canHandle({}), isTrue); // Default implementation returns true
      });
    });

    group('Error Handling', () {
      test('should throw descriptive error for invalid options', () {
        final invalidConfig = SkeletonConfig(
          options: {'invalid_option': 'value'},
        );

        try {
          strategy.createSkeleton(invalidConfig);
          fail('Expected ArgumentError');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('test_strategy'));
          expect(e.toString(), contains('cannot handle provided options'));
        }
      });

      test('should throw descriptive error for missing required options', () {
        try {
          strategy.validateRequiredOptions({}, ['missing_option']);
          fail('Expected ArgumentError');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('Required option "missing_option" is missing'));
          expect(e.toString(), contains('test_strategy'));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle null options gracefully', () {
        final config = SkeletonConfig(options: null);
        expect(() => strategy.createSkeleton(config), throwsA(isA<ArgumentError>()));
      });

      test('should handle empty options', () {
        final config = SkeletonConfig(options: {});
        final widget = strategy.createSkeleton(config);
        expect(widget, isA<Container>());
      });

      test('should handle null option values', () {
        final options = {'null_option': null};
        expect(strategy.getOption(options, 'null_option', 'default'), equals('default'));
      });
    });

    group('Template Method Extensibility', () {
      test('should allow subclasses to customize behavior', () {
        final customStrategy = CustomTestStrategy();
        final config = SkeletonConfig(options: {'custom_option': 'value'});

        final widget = customStrategy.createSkeleton(config);
        expect(widget, isA<Text>());
      });
    });
  });

  group('SkeletonConfig', () {
    test('should create config with default values', () {
      const config = SkeletonConfig();
      expect(config.width, isNull);
      expect(config.height, isNull);
      expect(config.options, equals({}));
      expect(config.animationDuration, isNull);
      expect(config.animationController, isNull);
    });

    test('should create config with provided values', () {
      final controller = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: TestVSync(),
      );

      final config = SkeletonConfig(
        width: 100,
        height: 200,
        options: {'key': 'value'},
        animationDuration: Duration(milliseconds: 1000),
        animationController: controller,
      );

      expect(config.width, equals(100));
      expect(config.height, equals(200));
      expect(config.options, equals({'key': 'value'}));
      expect(config.animationDuration, equals(Duration(milliseconds: 1000)));
      expect(config.animationController, equals(controller));

      controller.dispose();
    });

    test('should support copyWith method', () {
      const originalConfig = SkeletonConfig(
        width: 100,
        height: 200,
        options: {'original': 'value'},
      );

      final copiedConfig = originalConfig.copyWith(
        width: 150,
        options: {'new': 'value'},
      );

      expect(copiedConfig.width, equals(150));
      expect(copiedConfig.height, equals(200)); // Preserved from original
      expect(copiedConfig.options, equals({'new': 'value'}));
    });
  });
}

/// Test implementation of the BaseSkeletonStrategy
class TestSkeletonStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'test_strategy';

  @override
  String get variant => 'test';

  @override
  List<String> get supportedOptions => ['valid_option', 'test_option'];

  @override
  bool canHandle(Map<String, dynamic> options) {
    return !options.containsKey('invalid_option');
  }

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    return Container(
      width: config.width,
      height: config.height,
      child: Text('Test Skeleton'),
    );
  }
}

/// Custom test strategy to verify extensibility
class CustomTestStrategy extends BaseSkeletonStrategy {
  @override
  String get strategyId => 'custom_test_strategy';

  @override
  String get variant => 'custom_test';

  @override
  List<String> get supportedOptions => ['custom_option'];

  @override
  Widget buildSkeletonLayout(SkeletonConfig config) {
    return Text('Custom Skeleton');
  }
}

/// Test implementation of TickerProvider for testing
class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}