import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/progress/habit_progress_bar.dart';

void main() {
  group('HabitProgressBar', () {
    late Habit testHabit;
    late AnimationController animationController;
    late Animation<double> progressAnimation;

    setUp(() {
      testHabit = Habit(
        id: '1',
        name: 'Test Habit',
        description: 'Test Description',
        type: HabitType.binary,
        category: 'Test Category',
        targetValue: 10.0,
        unit: 'units',
        completions: {},
      );
      
      animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: TestVSync(),
      );
      
      progressAnimation = Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ));
    });

    tearDown(() {
      animationController.dispose();
    });

    testWidgets('should display progress bar for binary habit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitProgressBar(
              habit: testHabit,
              todayValue: true,
              progressAnimation: progressAnimation,
            ),
          ),
        ),
      );

      expect(find.text('Progrès du jour'), findsOneWidget);
      expect(find.text('Terminé'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display progress bar for quantitative habit', (WidgetTester tester) async {
      final quantitativeHabit = Habit(
        id: '2',
        name: 'Quantitative Habit',
        description: 'Test Description',
        type: HabitType.quantitative,
        category: 'Test Category',
        targetValue: 10.0,
        unit: 'units',
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitProgressBar(
              habit: quantitativeHabit,
              todayValue: 5.0,
              progressAnimation: progressAnimation,
            ),
          ),
        ),
      );

      expect(find.text('Progrès du jour'), findsOneWidget);
      expect(find.text('5.0 / 10.0 units'), findsOneWidget);
    });

    testWidgets('should display correct status for incomplete binary habit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitProgressBar(
              habit: testHabit,
              todayValue: false,
              progressAnimation: progressAnimation,
            ),
          ),
        ),
      );

      expect(find.text('En attente'), findsOneWidget);
    });

    testWidgets('should display correct status for complete binary habit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitProgressBar(
              habit: testHabit,
              todayValue: true,
              progressAnimation: progressAnimation,
            ),
          ),
        ),
      );

      expect(find.text('Terminé'), findsOneWidget);
    });

    testWidgets('should handle quantitative habit with no target value', (WidgetTester tester) async {
      final habitWithoutTarget = Habit(
        id: '3',
        name: 'No Target Habit',
        description: 'Test Description',
        type: HabitType.quantitative,
        category: 'Test Category',
        targetValue: null,
        unit: 'units',
        completions: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitProgressBar(
              habit: habitWithoutTarget,
              todayValue: 5.0,
              progressAnimation: progressAnimation,
            ),
          ),
        ),
      );

      expect(find.text('5.0 / 0.0 units'), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitProgressBar(
              habit: testHabit,
              todayValue: true,
              progressAnimation: progressAnimation,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should animate progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitProgressBar(
              habit: testHabit,
              todayValue: true,
              progressAnimation: progressAnimation,
            ),
          ),
        ),
      );

      // Démarrer l'animation
      animationController.forward();
      await tester.pumpAndSettle();
      
      // Vérifier que l'animation est terminée
      expect(animationController.status, AnimationStatus.completed);
    });
  });
}

class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
} 

