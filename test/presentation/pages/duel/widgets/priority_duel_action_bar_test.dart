import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_action_bar.dart';

void main() {
  Widget _buildHarness({
    required DuelMode mode,
    required Future<void> Function() onToggleElo,
    Future<void> Function()? onSkip,
    Future<void> Function()? onRandom,
    Future<void> Function()? onSubmitRanking,
    bool hideElo = true,
  }) {
    return MaterialApp(
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: PriorityDuelActionBar(
          mode: mode,
          hideEloScores: hideElo,
          onToggleElo: onToggleElo,
          onSkip: onSkip ?? () async {},
          onRandom: onRandom ?? () async {},
          onSubmitRanking: onSubmitRanking ?? () async {},
        ),
      ),
    );
  }

  group('PriorityDuelActionBar', () {
    testWidgets('fires toggle callback when eye button tapped', (tester) async {
      var toggled = false;

      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.winner,
          onToggleElo: () async {
            toggled = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Afficher l’Élo'));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('shows submit button only in ranking mode', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.winner,
          onToggleElo: () async {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Valider le classement'), findsNothing);

      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.ranking,
          onToggleElo: () async {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Valider le classement'), findsOneWidget);
    });
  });
}
