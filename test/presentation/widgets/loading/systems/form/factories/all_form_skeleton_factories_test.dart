import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/factories/detailed_form_skeleton_factory.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/factories/survey_form_skeleton_factory.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/factories/search_form_skeleton_factory.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/factories/login_form_skeleton_factory.dart';
import 'package:prioris/presentation/widgets/loading/systems/form/form_skeleton_config.dart';

void main() {
  group('All Form Skeleton Factories', () {
    group('DetailedFormSkeletonFactory', () {
      late DetailedFormSkeletonFactory factory;

      setUp(() {
        factory = DetailedFormSkeletonFactory();
      });

      testWidgets('should create detailed form with description', (tester) async {
        const config = FormSkeletonConfig(
          options: {'showDescription': true, 'fieldCount': 5},
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should create fields with help text', (tester) async {
        const config = FormSkeletonConfig(
          options: {'fieldCount': 4},
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should show extended form actions', (tester) async {
        const config = FormSkeletonConfig();

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('SurveyFormSkeletonFactory', () {
      late SurveyFormSkeletonFactory factory;

      setUp(() {
        factory = SurveyFormSkeletonFactory();
      });

      testWidgets('should create survey with questions', (tester) async {
        const config = FormSkeletonConfig(
          options: {'questionCount': 3},
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should create different question types', (tester) async {
        const config = FormSkeletonConfig(
          options: {'questionCount': 4}, // Cycles through all question types
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should show progress section', (tester) async {
        const config = FormSkeletonConfig();

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      test('should cycle question types correctly', () {
        expect(factory.getQuestionTypeForIndex(0), 'radio');
        expect(factory.getQuestionTypeForIndex(1), 'checkbox');
        expect(factory.getQuestionTypeForIndex(2), 'text');
        expect(factory.getQuestionTypeForIndex(3), 'scale');
        expect(factory.getQuestionTypeForIndex(4), 'radio'); // Cycles back
      });
    });

    group('SearchFormSkeletonFactory', () {
      late SearchFormSkeletonFactory factory;

      setUp(() {
        factory = SearchFormSkeletonFactory();
      });

      testWidgets('should create search input with button', (tester) async {
        const config = FormSkeletonConfig();

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should create search form with filters', (tester) async {
        const config = FormSkeletonConfig(
          options: {'showFilters': true, 'filterCount': 4},
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should create search form without filters', (tester) async {
        const config = FormSkeletonConfig(
          options: {'showFilters': false},
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should use default height when not specified', (tester) async {
        const config = FormSkeletonConfig();

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('LoginFormSkeletonFactory', () {
      late LoginFormSkeletonFactory factory;

      setUp(() {
        factory = LoginFormSkeletonFactory();
      });

      testWidgets('should create login form with all sections', (tester) async {
        const config = FormSkeletonConfig(
          options: {
            'showSocialLogin': true,
            'showForgotPassword': true,
            'showSignUp': true,
          },
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should create minimal login form', (tester) async {
        const config = FormSkeletonConfig(
          options: {
            'showSocialLogin': false,
            'showForgotPassword': false,
            'showSignUp': false,
          },
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should show logo and title section', (tester) async {
        const config = FormSkeletonConfig();

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should show social login when enabled', (tester) async {
        const config = FormSkeletonConfig(
          options: {'showSocialLogin': true},
        );

        final widget = factory.create(config);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))));
        expect(find.byType(Container), findsWidgets);
      });
    });
  });

  group('Factory Inheritance Tests', () {
    test('all factories should have consistent animation duration', () {
      final factories = [
        DetailedFormSkeletonFactory(),
        SurveyFormSkeletonFactory(),
        SearchFormSkeletonFactory(),
        LoginFormSkeletonFactory(),
      ];

      for (final factory in factories) {
        expect(factory.defaultAnimationDuration, const Duration(milliseconds: 1500));
      }
    });

    test('all factories should provide consistent field type cycling', () {
      final factories = [
        DetailedFormSkeletonFactory(),
        SurveyFormSkeletonFactory(),
        SearchFormSkeletonFactory(),
        LoginFormSkeletonFactory(),
      ];

      for (final factory in factories) {
        expect(factory.getFieldTypeForIndex(0), 'text');
        expect(factory.getFieldTypeForIndex(1), 'email');
        expect(factory.getFieldTypeForIndex(6), 'text'); // Should cycle back
      }
    });
  });
}