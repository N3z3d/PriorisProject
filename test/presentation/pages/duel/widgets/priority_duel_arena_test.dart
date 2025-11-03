import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_arena.dart';

void main() {
  group('PriorityWinnerArena', () {
    late Task taskA;
    late Task taskB;

    setUp(() {
      taskA = Task(
        id: 'task-a',
        title: 'Tâche A',
        description: 'Description',
        eloScore: 1400,
        createdAt: DateTime(2024, 10, 1),
      );
      taskB = Task(
        id: 'task-b',
        title: 'Tâche B',
        description: 'Description',
        eloScore: 1350,
        createdAt: DateTime(2024, 10, 2),
      );
    });

    Future<void> _pumpArena(
      WidgetTester tester, {
      required Future<void> Function(Task winner, Task loser) onSelect,
      bool hideElo = true,
      List<Task>? customTasks,
      Size? viewportSize,
    }) {
      final tasks = customTasks ?? [taskA, taskB];
      return tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SizedBox(
              width: viewportSize?.width,
              height: viewportSize?.height,
              child: PriorityWinnerArena(
                tasks: tasks,
                hideEloScores: hideElo,
                onSelectTask: onSelect,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('relaye le vainqueur et le perdant lors du tap', (tester) async {
      Task? winner;
      Task? loser;

      await _pumpArena(
        tester,
        onSelect: (selectedWinner, selectedLoser) async {
          winner = selectedWinner;
          loser = selectedLoser;
        },
      );

      await tester.tap(find.byKey(const ValueKey('duel-card-task-a')));
      await tester.pump();

      expect(winner, equals(taskA));
      expect(loser, equals(taskB));
    });

    testWidgets('masque les scores Elo quand demandé', (tester) async {
      await _pumpArena(
        tester,
        onSelect: (_, __) async {},
        hideElo: true,
      );
      await tester.pump();

      expect(find.textContaining('ELO'), findsNothing);
    });

    testWidgets(
        'utilise une disposition en grille reguliere pour 4 cartes sur grand ecran',
        (tester) async {
      final tasks = List.generate(
        4,
        (index) => Task(
          id: 'task-$index',
          title: 'Carte $index',
          eloScore: 1200 + (index * 20),
          createdAt: DateTime(2024, 10, index + 1),
        ),
      );

      await _pumpArena(
        tester,
        onSelect: (_, __) async {},
        customTasks: tasks,
        viewportSize: const Size(1280, 800),
      );
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets(
        'centre verticalement le contenu des cartes pour la disposition desktop a 3 cartes',
        (tester) async {
      final tasks = List.generate(
        3,
        (index) => Task(
          id: 'task-$index',
          title: 'Carte $index',
          eloScore: 1300 + index * 20,
          createdAt: DateTime(2024, 10, index + 1),
        ),
      );

      await _pumpArena(
        tester,
        onSelect: (_, __) async {},
        customTasks: tasks,
        viewportSize: const Size(1280, 800),
      );
      await tester.pump();

      final cardFinder = find.byKey(const ValueKey('duel-card-task-0'));
      final cardRect = tester.getRect(cardFinder);
      final titleFinder = find.descendant(
        of: cardFinder,
        matching: find.text('Carte 0'),
      );
      final titleRect = tester.getRect(titleFinder);

      final verticalOffset =
          (cardRect.center.dy - titleRect.center.dy).abs();

      expect(verticalOffset, lessThan(12),
          reason:
              'Le titre doit rester visuellement centré dans la carte (offset actuel: $verticalOffset)');
    });

    testWidgets(
        'aligne regulierement les cartes sur deux lignes pour le layout 4 cartes standard desktop',
        (tester) async {
      final tasks = List.generate(
        4,
        (index) => Task(
          id: 'task-$index',
          title: 'Carte $index',
          eloScore: 1200 + index * 10,
          createdAt: DateTime(2024, 10, index + 1),
        ),
      );

      await _pumpArena(
        tester,
        onSelect: (_, __) async {},
        customTasks: tasks,
        viewportSize: const Size(1200, 800),
      );
      await tester.pump();

      final topPositions = <int>{};
      for (var i = 0; i < tasks.length; i++) {
        final rect =
            tester.getRect(find.byKey(ValueKey('duel-card-task-$i')));
        topPositions.add(rect.top.round());
      }

      expect(topPositions.length, 2,
          reason:
              'Le layout doit afficher deux lignes régulières de cartes (tops: $topPositions)');
    });
  });

  group('PriorityRankingArena', () {
    late List<Task> tasks;

    setUp(() {
      tasks = List.generate(
        3,
        (index) => Task(
          id: 'task-${index + 1}',
          title: 'Tâche ${index + 1}',
          eloScore: 1300 + (index * 25),
          createdAt: DateTime(2024, 10, index + 1),
        ),
      );
    });

    Future<void> _pumpArena(
      WidgetTester tester, {
      required void Function(int oldIndex, int newIndex) onReorder,
      bool hideElo = false,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: PriorityRankingArena(
              tasks: tasks,
              hideEloScores: hideElo,
              onReorder: onReorder,
            ),
          ),
        ),
      );
    }

    testWidgets('expose le callback de réordonnancement', (tester) async {
      int? oldIndex;
      int? newIndex;

      await _pumpArena(
        tester,
        onReorder: (from, to) {
          oldIndex = from;
          newIndex = to;
        },
      );

      final listView = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );

      listView.onReorder(0, 2);

      expect(oldIndex, 0);
      expect(newIndex, 2);
    });

    testWidgets('affiche les scores Elo lorsque visibles', (tester) async {
      await _pumpArena(
        tester,
        hideElo: false,
        onReorder: (_, __) {},
      );

      expect(find.textContaining('ELO'), findsWidgets);
    });
  });
}
