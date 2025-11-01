import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_instruction.dart';
import 'package:prioris/presentation/pages/duel/widgets/priority_duel_view.dart';
import 'package:prioris/presentation/widgets/common/headers/unified_page_header.dart';

void main() {
  group('PriorityDuelView', () {
    late Task taskA;
    late Task taskB;

    setUp(() {
      taskA = Task(
        id: 'task-a',
        title: 'Preparer la reunion',
        description: 'Lister les points prioritaires',
        eloScore: 1420,
        createdAt: DateTime(2024, 10, 10),
        category: 'Travail',
      );
      taskB = Task(
        id: 'task-b',
        title: 'Reviser la roadmap',
        description: 'Comparer avec les retours clients',
        eloScore: 1380,
        createdAt: DateTime(2024, 10, 11),
        category: 'Strategie',
      );
    });

    Widget _buildTestApp({
      required List<Task> tasks,
      bool hideElo = true,
      int? remainingDuels,
      DuelMode mode = DuelMode.winner,
      int cardsPerRound = 2,
    }) {
      return MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PriorityDuelView(
            tasks: tasks,
            hideEloScores: hideElo,
            mode: mode,
            cardsPerRound: cardsPerRound,
            onSelectTask: (_, __) async {},
            onSubmitRanking: (_) async {},
            onSkip: () async {},
            onRandom: () async {},
            onToggleElo: () async {},
            onRefresh: () async {},
            onConfigureLists: () async {},
            onModeChanged: (_) {},
            onCardsPerRoundChanged: (_) {},
            hasAvailableLists: true,
            remainingDuelsToday: remainingDuels,
          ),
        ),
      );
    }

    testWidgets('renders header, summary and hint in French', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(tasks: [taskA, taskB]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(UnifiedPageHeader), findsOneWidget);
      expect(find.text('Duel'), findsOneWidget);
      final context = tester.element(find.byType(PriorityDuelView));
      final localized = AppLocalizations.of(context)!;
      final summary =
          localized.duelModeSummary(localized.duelModeWinner, 2);
      expect(find.text(summary), findsWidgets);
      expect(find.byType(PriorityDuelInstruction), findsOneWidget);
    });

    testWidgets('shows duel cards, VS badge and action bar', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          tasks: [taskA, taskB],
          remainingDuels: 10,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final context = tester.element(find.byType(PriorityDuelView));
      final localized = AppLocalizations.of(context)!;
      expect(find.text('VS'), findsOneWidget);
      expect(find.byTooltip(localized.duelShowElo), findsOneWidget);
      expect(find.byTooltip(localized.duelSkipAction), findsOneWidget);
      expect(find.byTooltip(localized.duelRandomAction), findsOneWidget);
      expect(find.byTooltip(localized.duelConfigureLists), findsOneWidget);
      expect(find.text(localized.duelRemainingDuels(10)), findsOneWidget);

      expect(find.byKey(const ValueKey('duel-card-task-a')), findsOneWidget);
      expect(find.byKey(const ValueKey('duel-card-task-b')), findsOneWidget);
    });

    testWidgets('affiche les reglages de mode et de nombre de cartes',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(tasks: [taskA, taskB]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final context = tester.element(find.byType(PriorityDuelView));
      final localized = AppLocalizations.of(context)!;

      expect(find.text(localized.duelModeLabel), findsOneWidget);
      expect(find.text(localized.duelCardsPerRoundLabel), findsOneWidget);
      expect(find.text(localized.duelModeWinner), findsOneWidget);
      expect(find.text(localized.duelModeRanking), findsOneWidget);
      expect(find.byKey(const ValueKey('duel-mode-vainqueur')), findsOneWidget);
      expect(find.byKey(const ValueKey('duel-mode-classement')), findsOneWidget);
      expect(find.byKey(const ValueKey('card-count-2')), findsOneWidget);
    });

    testWidgets('montre le bouton de validation en mode classement',
        (tester) async {
      final tasks = [
        taskA,
        taskB,
        Task(
          id: 'task-c',
          title: 'Preparer la communication',
          eloScore: 1310,
          createdAt: DateTime(2024, 10, 12),
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          tasks: tasks,
          mode: DuelMode.ranking,
          cardsPerRound: 3,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final context = tester.element(find.byType(PriorityDuelView));
      final localized = AppLocalizations.of(context)!;

      expect(find.text(localized.duelSubmitRanking), findsOneWidget);
    });

    testWidgets('affiche toutes les cartes sans overflow sur grand ecran',
        (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1440, 900);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      final tasks = [
        taskA,
        taskB,
        Task(
          id: 'task-c',
          title: 'Analyser les risques',
          eloScore: 1350,
          createdAt: DateTime(2024, 10, 12),
        ),
        Task(
          id: 'task-d',
          title: 'Planifier la prochaine iteration',
          eloScore: 1305,
          createdAt: DateTime(2024, 10, 13),
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          tasks: tasks,
          mode: DuelMode.winner,
          cardsPerRound: 4,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      for (final task in tasks) {
        expect(find.text(task.title), findsOneWidget);
      }
    });
  });
}


