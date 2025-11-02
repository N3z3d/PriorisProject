import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/priority_duel_view.dart';

void main() {
  group('PriorityDuelView', () {
    late List<Task> tasks;

    setUp(() {
      tasks = List.generate(
        3,
        (index) => Task(
          id: 'task-${index + 1}',
          title: 'Tache ${index + 1}',
          eloScore: 1200 + index * 40,
          createdAt: DateTime(2024, 10, index + 1),
        ),
      );
    });

    Future<void> _pumpView(
      WidgetTester tester, {
      required DuelMode mode,
      required bool hideElo,
      required Future<void> Function(List<Task> ordered) onSubmitRanking,
      required VoidCallback onToggleElo,
      List<Task>? customTasks,
      int? cardsPerRound,
    }) {
      final viewTasks = customTasks ?? tasks;
      return tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: PriorityDuelView(
              tasks: viewTasks,
              hideEloScores: hideElo,
              mode: mode,
              cardsPerRound: cardsPerRound ?? viewTasks.length,
              onSelectTask: (_, __) async {},
              onSubmitRanking: onSubmitRanking,
              onSkip: () async {},
              onRandom: () async {},
              onToggleElo: () async => onToggleElo(),
              onRefresh: () async {},
              onConfigureLists: () async {},
              onModeChanged: (_) {},
              onCardsPerRoundChanged: (_) {},
              hasAvailableLists: true,
            ),
          ),
        ),
      );
    }

    testWidgets('relaye la soumission du classement selon le nouvel ordre',
        (tester) async {
      List<Task>? submittedOrder;

      await _pumpView(
        tester,
        mode: DuelMode.ranking,
        hideElo: false,
        onSubmitRanking: (ordered) async {
          submittedOrder = List<Task>.from(ordered);
        },
        onToggleElo: () {},
      );

      final listView = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );

      listView.onReorder(0, 3);
      await tester.pump();

      final context = tester.element(find.byType(PriorityDuelView));
      final localized = AppLocalizations.of(context)!;

      final submitButton = find.text(localized.duelSubmitRanking);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump();

      expect(submittedOrder, isNotNull);
      expect(
        submittedOrder!.map((task) => task.id),
        ['task-2', 'task-3', 'task-1'],
      );
    });

    testWidgets('delegue le toggle affichage Elo', (tester) async {
      var toggled = false;
      await _pumpView(
        tester,
        mode: DuelMode.winner,
        hideElo: true,
        onSubmitRanking: (_) async {},
        onToggleElo: () {
          toggled = true;
        },
      );

      // Le bouton il est maintenant dans le header (UnifiedPageHeader)
      // On cherche par icone au lieu de texte
      final eyeButton = find.ancestor(
        of: find.byIcon(Icons.visibility_rounded),
        matching: find.byType(IconButton),
      );

      await tester.tap(eyeButton);
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('affiche VS sous la consigne pour un duel a 3 cartes',
        (tester) async {
      final customTasks = List.generate(
        3,
        (index) => Task(
          id: 'task-${index + 1}',
          title: 'Carte ${index + 1}',
          eloScore: 1200 + index * 10,
          createdAt: DateTime(2024, 10, index + 1),
        ),
      );

      await _pumpView(
        tester,
        mode: DuelMode.winner,
        hideElo: true,
        onSubmitRanking: (_) async {},
        onToggleElo: () {},
        customTasks: customTasks,
        cardsPerRound: 3,
      );

      await tester.pump();

      final instructionFinder = find.text('Choisissez 1 gagnant');
      final vsFinder = find.text('VS');

      expect(instructionFinder, findsOneWidget);
      expect(vsFinder, findsOneWidget);

      final instructionRect = tester.getRect(instructionFinder);
      final vsRect = tester.getRect(vsFinder);

      expect(vsRect.top, greaterThan(instructionRect.bottom));
    });

    testWidgets('affiche VS sous la consigne pour un duel a 4 cartes',
        (tester) async {
      final customTasks = List.generate(
        4,
        (index) => Task(
          id: 'task-${index + 1}',
          title: 'Carte ${index + 1}',
          eloScore: 1200 + index * 10,
          createdAt: DateTime(2024, 10, index + 1),
        ),
      );

      await _pumpView(
        tester,
        mode: DuelMode.winner,
        hideElo: true,
        onSubmitRanking: (_) async {},
        onToggleElo: () {},
        customTasks: customTasks,
        cardsPerRound: 4,
      );

      await tester.pump();

      final instructionFinder = find.text('Choisissez 1 gagnant');
      final vsFinder = find.text('VS');

      expect(instructionFinder, findsOneWidget);
      expect(vsFinder, findsOneWidget);

      final instructionRect = tester.getRect(instructionFinder);
      final vsRect = tester.getRect(vsFinder);

      expect(vsRect.top, greaterThan(instructionRect.bottom));
    });
  });
}
