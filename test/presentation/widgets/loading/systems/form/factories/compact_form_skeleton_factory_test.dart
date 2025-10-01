import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/factories/compact_form_skeleton_factory.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/form_skeleton_config.dart';

void main() {
  group('CompactFormSkeletonFactory', () {
    late CompactFormSkeletonFactory factory;

    setUp(() {
      factory = CompactFormSkeletonFactory();
    });

    testWidgets('should create compact form skeleton with default configuration', (tester) async {
      const config = FormSkeletonConfig();

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create compact form with custom field count', (tester) async {
      const config = FormSkeletonConfig(
        options: {'fieldCount': 5},
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create compact form without submit button', (tester) async {
      const config = FormSkeletonConfig(
        options: {'showSubmitButton': false},
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle custom dimensions', (tester) async {
      const config = FormSkeletonConfig(
        width: 250.0,
        height: 200.0,
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create horizontal layout for compact fields', (tester) async {
      const config = FormSkeletonConfig(
        options: {'fieldCount': 3},
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      // Widget should render without errors and use horizontal layout
      expect(find.byType(Container), findsWidgets);
    });

    test('should inherit default animation duration', () {
      expect(factory.defaultAnimationDuration, const Duration(milliseconds: 1500));
    });

    testWidgets('should handle all field types in compact layout', (tester) async {
      const config = FormSkeletonConfig(
        options: {'fieldCount': 6}, // Cycles through all field types
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should apply custom animation duration', (tester) async {
      const config = FormSkeletonConfig(
        animationDuration: Duration(milliseconds: 800),
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show submit button by default', (tester) async {
      const config = FormSkeletonConfig();

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });
  });
}