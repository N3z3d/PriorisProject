import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/priority_duel_view.dart';

void main() {
  group('PriorityDuelView', () {
    late Task taskA;
    late Task taskB;

    setUp(() {
      taskA = Task(
        id: 'task-a',
        title: 'Préparer la réunion',
        description: 'Lister les points prioritaires',
        eloScore: 1420,
        createdAt: DateTime(2024, 10, 10),
        category: 'Travail',
      );
      taskB = Task(
        id: 'task-b',
        title: 'Réviser la roadmap',
        description: 'Comparer avec les retours clients',
        eloScore: 1380,
        createdAt: DateTime(2024, 10, 11),
        category: 'Stratégie',
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

    testWidgets('renders header, subtitle and hint in French', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(tasks: [taskA, taskB]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode Priorité'), findsOneWidget);
      expect(find.text('Quelle tâche préférez-vous ?'), findsOneWidget);
      expect(find.text('Touchez la carte que vous souhaitez prioriser.'),
          findsOneWidget);
    });

    testWidgets('shows duel cards, VS badge and action bar', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          tasks: [taskA, taskB],
          remainingDuels: 10,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VS'), findsOneWidget);
      expect(find.text('Passer le duel'), findsOneWidget);
      expect(find.text('Aléatoire'), findsOneWidget);
      expect(find.text('Afficher l’Élo'), findsOneWidget);
      expect(
          find.textContaining('10 duels restants aujourd’hui'), findsOneWidget);

      expect(find.byKey(const ValueKey('priority-duel-card-task-a')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('priority-duel-card-task-b')),
          findsOneWidget);
    });

    testWidgets('affiche les réglages de mode et de nombre de cartes',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(tasks: [taskA, taskB]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode du duel'), findsOneWidget);
      expect(find.text('Nombre de cartes par manche'), findsOneWidget);
      expect(find.text('Vainqueur'), findsOneWidget);
      expect(find.text('Classement'), findsOneWidget);
    });

    testWidgets('montre le bouton de validation en mode classement',
        (tester) async {
      final tasks = [
        taskA,
        taskB,
        Task(
          id: 'task-c',
          title: 'Préparer la communication',
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
      await tester.pumpAndSettle();

      expect(find.text('Valider le classement'), findsOneWidget);
    });
  });
}
