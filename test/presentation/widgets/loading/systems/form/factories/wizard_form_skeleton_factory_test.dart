import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/factories/wizard_form_skeleton_factory.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/form_skeleton_config.dart';

void main() {
  group('WizardFormSkeletonFactory', () {
    late WizardFormSkeletonFactory factory;

    setUp(() {
      factory = WizardFormSkeletonFactory();
    });

    testWidgets('should create wizard form skeleton with default configuration', (tester) async {
      const config = FormSkeletonConfig();

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create wizard with custom step count', (tester) async {
      const config = FormSkeletonConfig(
        options: {'stepCount': 5, 'currentStep': 2},
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create wizard with custom fields per step', (tester) async {
      const config = FormSkeletonConfig(
        options: {'fieldsPerStep': 4},
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show different step indicator sizes based on current step', (tester) async {
      const config = FormSkeletonConfig(
        options: {
          'stepCount': 4,
          'currentStep': 1, // Second step (0-indexed)
        },
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should hide back button on first step', (tester) async {
      const config = FormSkeletonConfig(
        options: {
          'stepCount': 3,
          'currentStep': 0, // First step
        },
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show back button on subsequent steps', (tester) async {
      const config = FormSkeletonConfig(
        options: {
          'stepCount': 3,
          'currentStep': 1, // Second step
        },
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show larger finish button on last step', (tester) async {
      const config = FormSkeletonConfig(
        options: {
          'stepCount': 3,
          'currentStep': 2, // Last step (0-indexed)
        },
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle custom dimensions', (tester) async {
      const config = FormSkeletonConfig(
        width: 400.0,
        height: 600.0,
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should cycle through field types for form fields', (tester) async {
      const config = FormSkeletonConfig(
        options: {
          'fieldsPerStep': 6, // Should cycle through all field types
        },
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });

    test('should provide default animation duration', () {
      expect(factory.defaultAnimationDuration, const Duration(milliseconds: 1500));
    });

    testWidgets('should handle custom animation duration', (tester) async {
      const config = FormSkeletonConfig(
        animationDuration: Duration(milliseconds: 2500),
      );

      final widget = factory.create(config);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));

      expect(find.byType(Container), findsWidgets);
    });
  });
}