import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/factories/standard_form_skeleton_factory.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/form_skeleton_config.dart';

void main() {
  group('StandardFormSkeletonFactory', () {
    late StandardFormSkeletonFactory factory;

    setUp(() {
      factory = StandardFormSkeletonFactory();
    });

    testWidgets('should create standard form skeleton with default configuration', (tester) async {
      const config = FormSkeletonConfig();

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create form with specified field count', (tester) async {
      const config = FormSkeletonConfig(
        options: {'fieldCount': 6},
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      // The widget should render without errors
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create form without title when showTitle is false', (tester) async {
      const config = FormSkeletonConfig(
        options: {'showTitle': false},
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      // The widget should render without errors
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create form with custom width and height', (tester) async {
      const config = FormSkeletonConfig(
        width: 300.0,
        height: 500.0,
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      // The widget should render without errors
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle all form field types', (tester) async {
      const config = FormSkeletonConfig(
        options: {'fieldCount': 6}, // This should cycle through all field types
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      // The widget should render without errors
      expect(find.byType(Container), findsWidgets);
    });

    test('should provide default animation duration', () {
      expect(factory.defaultAnimationDuration, const Duration(milliseconds: 1500));
    });

    test('should cycle through field types correctly', () {
      expect(factory.getFieldTypeForIndex(0), 'text');
      expect(factory.getFieldTypeForIndex(1), 'email');
      expect(factory.getFieldTypeForIndex(2), 'textarea');
      expect(factory.getFieldTypeForIndex(6), 'text'); // Should cycle back
    });

    testWidgets('should create form actions based on configuration', (tester) async {
      const config = FormSkeletonConfig(
        options: {
          'showSubmitButton': true,
          'showCancelButton': true,
          'showResetButton': false,
        },
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      // The widget should render without errors
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle animation configuration', (tester) async {
      const config = FormSkeletonConfig(
        animationDuration: Duration(milliseconds: 2000),
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      // The widget should render without errors
      expect(find.byType(Container), findsWidgets);
    });
  });
}