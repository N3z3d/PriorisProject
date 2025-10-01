import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/presentation/optimization/flyweight_ui_system.dart';
import '../../../lib/presentation/optimization/flyweight_factory.dart';
import '../../../lib/presentation/optimization/intrinsic_state.dart';
import '../../../lib/presentation/optimization/extrinsic_state.dart';

void main() {
  group('FlyweightUISystem', () {
    late FlyweightFactory flyweightFactory;

    setUp(() {
      flyweightFactory = FlyweightFactory();
    });

    tearDown(() {
      flyweightFactory.dispose();
    });

    group('Flyweight Creation and Reuse', () {
      test('should reuse flyweight instances with same intrinsic state', () {
        final intrinsicState1 = IntrinsicState(
          style: TextStyle(fontSize: 16, color: Colors.black),
          iconData: Icons.star,
          decoration: BoxDecoration(color: Colors.white),
        );

        final intrinsicState2 = IntrinsicState(
          style: TextStyle(fontSize: 16, color: Colors.black),
          iconData: Icons.star,
          decoration: BoxDecoration(color: Colors.white),
        );

        final flyweight1 = flyweightFactory.getFlyweight(intrinsicState1);
        final flyweight2 = flyweightFactory.getFlyweight(intrinsicState2);

        // Should be the same instance (memory optimization)
        expect(identical(flyweight1, flyweight2), isTrue);
        expect(flyweightFactory.createdCount, equals(1));
      });

      test('should create different flyweights for different intrinsic states', () {
        final intrinsicState1 = IntrinsicState(
          style: TextStyle(fontSize: 16, color: Colors.black),
          iconData: Icons.star,
        );

        final intrinsicState2 = IntrinsicState(
          style: TextStyle(fontSize: 18, color: Colors.red), // Different
          iconData: Icons.favorite,  // Different
        );

        final flyweight1 = flyweightFactory.getFlyweight(intrinsicState1);
        final flyweight2 = flyweightFactory.getFlyweight(intrinsicState2);

        expect(identical(flyweight1, flyweight2), isFalse);
        expect(flyweightFactory.createdCount, equals(2));
      });

      test('should manage memory efficiently with many similar components', () {
        const itemCount = 1000;
        final flyweights = <UIFlyweight>[];

        // Create many UI components with only a few different styles
        for (int i = 0; i < itemCount; i++) {
          final styleIndex = i % 5; // Only 5 different styles
          final intrinsicState = IntrinsicState(
            style: TextStyle(
              fontSize: 16.0,
              color: [Colors.black, Colors.red, Colors.blue, Colors.green, Colors.orange][styleIndex],
            ),
            iconData: [Icons.star, Icons.favorite, Icons.home, Icons.settings, Icons.person][styleIndex],
          );

          flyweights.add(flyweightFactory.getFlyweight(intrinsicState));
        }

        // Should have created only 5 flyweights despite 1000 components
        expect(flyweightFactory.createdCount, equals(5));
        expect(flyweights.length, equals(itemCount));

        // Verify memory reuse
        final uniqueFlyweights = flyweights.toSet();
        expect(uniqueFlyweights.length, equals(5));
      });
    });

    group('Widget Rendering with Extrinsic State', () {
      testWidgets('should render widget with combined intrinsic and extrinsic state', (tester) async {
        final intrinsicState = IntrinsicState(
          style: TextStyle(fontSize: 16, color: Colors.black),
          iconData: Icons.star,
        );

        final extrinsicState = ExtrinsicState(
          text: 'Test Item',
          position: Offset(10, 20),
          isSelected: false,
        );

        final flyweight = flyweightFactory.getFlyweight(intrinsicState);

        final widget = flyweight.buildWidget(extrinsicState);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        // Verify the widget is rendered correctly
        expect(find.text('Test Item'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('should handle different extrinsic states with same flyweight', (tester) async {
        final intrinsicState = IntrinsicState(
          style: TextStyle(fontSize: 16, color: Colors.black),
          iconData: Icons.star,
        );

        final flyweight = flyweightFactory.getFlyweight(intrinsicState);

        // Different extrinsic states
        final states = [
          ExtrinsicState(text: 'Item 1', position: Offset(0, 0), isSelected: false),
          ExtrinsicState(text: 'Item 2', position: Offset(10, 10), isSelected: true),
          ExtrinsicState(text: 'Item 3', position: Offset(20, 20), isSelected: false),
        ];

        for (int i = 0; i < states.length; i++) {
          final widget = flyweight.buildWidget(states[i]);

          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: Column(
                key: Key('column_$i'),
                children: [widget],
              ),
            ),
          ));

          expect(find.text(states[i].text), findsOneWidget);
        }
      });
    });

    group('Performance Optimization', () {
      test('should optimize memory usage for large lists', () {
        final listOptimizer = ListItemOptimizer();

        // Create a large list with repeating patterns
        const itemCount = 5000;
        final items = <ListItemData>[];

        for (int i = 0; i < itemCount; i++) {
          items.add(ListItemData(
            id: i,
            title: 'Item $i',
            subtitle: 'Description for item $i',
            category: ['Work', 'Personal', 'Shopping', 'Health'][i % 4],
            priority: ['High', 'Medium', 'Low'][i % 3],
            isCompleted: i % 7 == 0,
          ));
        }

        final widgets = listOptimizer.optimizeList(items);

        expect(widgets.length, equals(itemCount));

        // Verify flyweight reuse (should have far fewer flyweights than items)
        final flyweightCount = listOptimizer.getUniqueflyweightCount();
        expect(flyweightCount, lessThan(20)); // Much fewer than 5000
        expect(flyweightCount, greaterThan(0));
      });

      test('should provide memory usage statistics', () {
        const itemCount = 1000;

        for (int i = 0; i < itemCount; i++) {
          final intrinsicState = IntrinsicState(
            style: TextStyle(fontSize: 16, color: Colors.values[i % Colors.values.length]),
            iconData: Icons.star,
          );
          flyweightFactory.getFlyweight(intrinsicState);
        }

        final stats = flyweightFactory.getMemoryStatistics();

        expect(stats.totalFlyweights, greaterThan(0));
        expect(stats.totalRequests, equals(itemCount));
        expect(stats.memoryEfficiencyRatio, greaterThan(0.8)); // High efficiency expected
        expect(stats.averageReuseRate, greaterThan(1.0));
      });
    });

    group('Theme Integration', () {
      testWidgets('should integrate with Flutter theme system', (tester) async {
        final themeAwareFlyweight = ThemeAwareFlyweight();

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
            home: Scaffold(
              body: themeAwareFlyweight.buildThemedWidget(
                ExtrinsicState(text: 'Themed Text', position: Offset.zero, isSelected: false),
              ),
            ),
          ),
        );

        expect(find.text('Themed Text'), findsOneWidget);

        // Verify theme integration
        final textWidget = tester.widget<Text>(find.text('Themed Text'));
        expect(textWidget.style?.fontSize, equals(18));
      });
    });

    group('Custom Widget Types', () {
      test('should support custom widget flyweights', () {
        final customFactory = CustomWidgetFlyweightFactory();

        final buttonFlyweight = customFactory.createButtonFlyweight(
          ButtonIntrinsicState(
            backgroundColor: Colors.blue,
            borderRadius: 8.0,
            elevation: 2.0,
          ),
        );

        expect(buttonFlyweight, isNotNull);
        expect(buttonFlyweight, isA<ButtonFlyweight>());

        final cardFlyweight = customFactory.createCardFlyweight(
          CardIntrinsicState(
            elevation: 4.0,
            borderRadius: 12.0,
            shadowColor: Colors.black26,
          ),
        );

        expect(cardFlyweight, isNotNull);
        expect(cardFlyweight, isA<CardFlyweight>());
      });

      testWidgets('should render custom button flyweight', (tester) async {
        final customFactory = CustomWidgetFlyweightFactory();

        final buttonFlyweight = customFactory.createButtonFlyweight(
          ButtonIntrinsicState(
            backgroundColor: Colors.blue,
            borderRadius: 8.0,
            elevation: 2.0,
          ),
        );

        final buttonWidget = buttonFlyweight.buildWidget(
          ButtonExtrinsicState(
            text: 'Custom Button',
            onPressed: () {},
            width: 120,
            height: 40,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: buttonWidget),
          ),
        );

        expect(find.text('Custom Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
      });
    });

    group('Dynamic State Management', () {
      test('should handle dynamic intrinsic state changes efficiently', () {
        final dynamicFactory = DynamicFlyweightFactory();

        // Initial state
        var intrinsicState = IntrinsicState(
          style: TextStyle(fontSize: 16, color: Colors.black),
          iconData: Icons.star,
        );

        final flyweight1 = dynamicFactory.getFlyweight(intrinsicState);
        expect(dynamicFactory.getCacheSize(), equals(1));

        // Same state - should reuse
        final flyweight2 = dynamicFactory.getFlyweight(intrinsicState);
        expect(identical(flyweight1, flyweight2), isTrue);

        // Modified state - should create new flyweight
        intrinsicState = intrinsicState.copyWith(
          style: TextStyle(fontSize: 18, color: Colors.black), // Changed font size
        );

        final flyweight3 = dynamicFactory.getFlyweight(intrinsicState);
        expect(identical(flyweight1, flyweight3), isFalse);
        expect(dynamicFactory.getCacheSize(), equals(2));
      });

      test('should clean up unused flyweights', () {
        final factory = FlyweightFactory(maxCacheSize: 5);

        // Create many flyweights
        final flyweights = <UIFlyweight>[];
        for (int i = 0; i < 10; i++) {
          final intrinsicState = IntrinsicState(
            style: TextStyle(fontSize: 16 + i.toDouble(), color: Colors.black),
            iconData: Icons.star,
          );
          flyweights.add(factory.getFlyweight(intrinsicState));
        }

        // Should have evicted older entries
        expect(factory.createdCount, lessThanOrEqualTo(5));
        expect(factory.getCacheSize(), lessThanOrEqualTo(5));
      });
    });

    group('Accessibility Integration', () {
      testWidgets('should maintain accessibility properties', (tester) async {
        final intrinsicState = IntrinsicState(
          style: TextStyle(fontSize: 16, color: Colors.black),
          iconData: Icons.star,
          semanticLabel: 'Star icon',
        );

        final extrinsicState = ExtrinsicState(
          text: 'Accessible Item',
          position: Offset.zero,
          isSelected: false,
          semanticLabel: 'Accessible list item',
        );

        final flyweight = flyweightFactory.getFlyweight(intrinsicState);
        final widget = flyweight.buildWidget(extrinsicState);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Verify semantic properties are preserved
        expect(
          tester.getSemantics(find.text('Accessible Item')),
          matchesSemantics(label: 'Accessible list item'),
        );
      });
    });

    group('Integration with Animation System', () {
      testWidgets('should support animated transitions', (tester) async {
        final animatedFactory = AnimatedFlyweightFactory();

        final flyweight = animatedFactory.createAnimatedFlyweight(
          AnimatedIntrinsicState(
            baseStyle: TextStyle(fontSize: 16, color: Colors.black),
            animationDuration: Duration(milliseconds: 300),
            animationType: AnimationType.fadeInScale,
          ),
        );

        final widget = flyweight.buildAnimatedWidget(
          AnimatedExtrinsicState(
            text: 'Animated Item',
            isVisible: true,
            animationController: AnimationController(
              duration: Duration(milliseconds: 300),
              vsync: tester,
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        expect(find.text('Animated Item'), findsOneWidget);
      });
    });
  });
}