import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_layouts.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';

void main() {
  group('DuelLayoutDispatcher', () {
    late List<Task> testTasks;

    setUp(() {
      testTasks = List.generate(
        4,
        (i) => Task(
          id: 'task-$i',
          title: 'Test Task $i',
          eloScore: 1500.0 + i * 10,
          createdAt: DateTime.now(),
        ),
      );
    });

    testWidgets('dispatches to DuelTwoCardsLayout for 2 tasks', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: DuelLayoutDispatcher(
            tasks: testTasks.take(2).toList(),
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.byType(DuelTwoCardsLayout), findsOneWidget);
    });

    testWidgets('dispatches to DuelThreeCardsLayout for 3 tasks', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: DuelLayoutDispatcher(
            tasks: testTasks.take(3).toList(),
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.byType(DuelThreeCardsLayout), findsOneWidget);
    });

    testWidgets('dispatches to DuelFourCardsLayout for 4 tasks', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: DuelLayoutDispatcher(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.byType(DuelFourCardsLayout), findsOneWidget);
    });

    testWidgets('shows error message for unsupported task count', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: DuelLayoutDispatcher(
            tasks: testTasks.take(1).toList(),
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Nombre de tâches non supporté : 1'), findsOneWidget);
    });
  });

  group('DuelTwoCardsLayout', () {
    late List<Task> testTasks;

    setUp(() {
      testTasks = List.generate(
        2,
        (i) => Task(
          id: 'task-$i',
          title: 'Test Task $i',
          eloScore: 1500.0,
          createdAt: DateTime.now(),
        ),
      );
    });

    testWidgets('renders two cards with standard size on desktop', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      final widget = MaterialApp(
        home: Scaffold(
          body: DuelTwoCardsLayout(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      // Use pump() instead of pumpAndSettle() due to infinite animations
      await tester.pump();

      expect(find.byType(DuelTaskCard), findsNWidgets(2));

      // Verify horizontal layout
      final cards = tester.widgetList<DuelTaskCard>(find.byType(DuelTaskCard));
      for (final card in cards) {
        expect(card.cardSize, DuelCardSize.standard);
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('renders two cards vertically on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final widget = MaterialApp(
        home: Scaffold(
          body: DuelTwoCardsLayout(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.byType(DuelTaskCard), findsNWidgets(2));
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });

  group('DuelThreeCardsLayout', () {
    late List<Task> testTasks;

    setUp(() {
      testTasks = List.generate(
        3,
        (i) => Task(
          id: 'task-$i',
          title: 'Test Task $i',
          eloScore: 1500.0,
          createdAt: DateTime.now(),
        ),
      );
    });

    testWidgets('renders three cards with compact3 size', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      final widget = MaterialApp(
        home: Scaffold(
          body: DuelThreeCardsLayout(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.byType(DuelTaskCard), findsNWidgets(3));

      final cards = tester.widgetList<DuelTaskCard>(find.byType(DuelTaskCard));
      for (final card in cards) {
        expect(card.cardSize, DuelCardSize.compact3);
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });

  group('DuelFourCardsLayout', () {
    late List<Task> testTasks;

    setUp(() {
      testTasks = List.generate(
        4,
        (i) => Task(
          id: 'task-$i',
          title: 'Test Task $i',
          eloScore: 1500.0,
          createdAt: DateTime.now(),
        ),
      );
    });

    testWidgets('renders four cards in grid with compact4 size on desktop', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      final widget = MaterialApp(
        home: Scaffold(
          body: DuelFourCardsLayout(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.byType(DuelTaskCard), findsNWidgets(4));
      expect(find.byType(GridView), findsOneWidget);

      final cards = tester.widgetList<DuelTaskCard>(find.byType(DuelTaskCard));
      for (final card in cards) {
        expect(card.cardSize, DuelCardSize.compact4);
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('renders grid layout on desktop without internal scroll', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      final widget = MaterialApp(
        home: Scaffold(
          body: DuelFourCardsLayout(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      // Verify grid is rendered without internal SingleChildScrollView
      // (scroll is handled by parent PriorityDuelView)
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(DuelTaskCard), findsNWidgets(4));

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('renders four cards vertically on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final widget = MaterialApp(
        home: Scaffold(
          body: DuelFourCardsLayout(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.byType(DuelTaskCard), findsNWidgets(4));
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });

  group('Card Size Consistency', () {
    testWidgets('all card sizes have consistent aspect ratios', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      // Test standard size (2 cards)
      final task = Task(
        id: 'test-task',
        title: 'Test',
        eloScore: 1500.0,
        createdAt: DateTime.now(),
      );

      final standardCard = DuelTaskCard(
        task: task,
        onTap: () {},
        hideElo: false,
        cardSize: DuelCardSize.standard,
      );

      final compact3Card = DuelTaskCard(
        task: task,
        onTap: () {},
        hideElo: false,
        cardSize: DuelCardSize.compact3,
      );

      final compact4Card = DuelTaskCard(
        task: task,
        onTap: () {},
        hideElo: false,
        cardSize: DuelCardSize.compact4,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: standardCard)));
      await tester.pump();
      expect(find.byType(DuelTaskCard), findsOneWidget);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: compact3Card)));
      await tester.pump();
      expect(find.byType(DuelTaskCard), findsOneWidget);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: compact4Card)));
      await tester.pump();
      expect(find.byType(DuelTaskCard), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });

  group('Winner Selection Callback', () {
    testWidgets('executes callback with correct winner and losers', (tester) async {
      final testTasks = List.generate(
        2,
        (i) => Task(
          id: 'task-$i',
          title: 'Test Task $i',
          eloScore: 1500.0,
          createdAt: DateTime.now(),
        ),
      );

      Task? selectedWinner;
      List<Task>? selectedLosers;

      final widget = MaterialApp(
        home: Scaffold(
          body: DuelTwoCardsLayout(
            tasks: testTasks,
            hideEloScores: false,
            onSelectWinner: (winner, losers) async {
              selectedWinner = winner;
              selectedLosers = losers;
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      // Tap first card
      await tester.tap(find.byType(DuelTaskCard).first);
      await tester.pump();

      expect(selectedWinner, testTasks[0]);
      expect(selectedLosers, [testTasks[1]]);
    });
  });
}
