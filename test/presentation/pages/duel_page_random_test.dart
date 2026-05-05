import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/priority_duel_view.dart';

final _mockTasks = [
  Task(
    id: 'task-1',
    title: 'Première tâche',
    eloScore: 1300.0,
    createdAt: DateTime(2024, 1, 1),
  ),
  Task(
    id: 'task-2',
    title: 'Deuxième tâche',
    eloScore: 1250.0,
    createdAt: DateTime(2024, 1, 2),
  ),
];

Widget _buildDuelView({bool Function()? onRandomCalled}) {
  bool randomCalled = false;
  return MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: PriorityDuelView(
        tasks: _mockTasks,
        hideEloScores: false,
        mode: DuelMode.winner,
        cardsPerRound: DuelSettings.minCardsPerRound,
        onSelectTask: (_, __) async {},
        onSubmitRanking: (_) async {},
        onSkip: () async {},
        onRandom: () async { randomCalled = true; },
        onToggleElo: () async {},
        onRefresh: () async {},
        onConfigureLists: () async {},
        onModeChanged: (_) {},
        onCardsPerRoundChanged: (_) {},
        hasAvailableLists: true,
      ),
    ),
  );
}

void main() {
  group('DuelPage - Mode Aléatoire', () {
    testWidgets('doit afficher un bouton avec icône casino dans l\'interface de duel',
        (tester) async {
      await tester.pumpWidget(_buildDuelView());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.casino_rounded), findsOneWidget);
    });

    testWidgets('doit afficher une icône casino_rounded pour le mode aléatoire',
        (tester) async {
      await tester.pumpWidget(_buildDuelView());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final randomButtons = find.widgetWithIcon(IconButton, Icons.casino_rounded);
      expect(randomButtons, findsOneWidget);
    });

    testWidgets('taper sur le bouton aléatoire déclenche le callback',
        (tester) async {
      bool randomCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: Scaffold(
            body: PriorityDuelView(
              tasks: _mockTasks,
              hideEloScores: false,
              mode: DuelMode.winner,
              cardsPerRound: DuelSettings.minCardsPerRound,
              onSelectTask: (_, __) async {},
              onSubmitRanking: (_) async {},
              onSkip: () async {},
              onRandom: () async { randomCalled = true; },
              onToggleElo: () async {},
              onRefresh: () async {},
              onConfigureLists: () async {},
              onModeChanged: (_) {},
              onCardsPerRoundChanged: (_) {},
              hasAvailableLists: true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.casino_rounded));
      await tester.pump();

      expect(randomCalled, isTrue);
    });
  });
}
