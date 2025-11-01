import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_action_bar.dart';

void main() {
  Widget _harness({
    required DuelMode mode,
    Future<void> Function()? onSubmitRanking,
  }) {
    return MaterialApp(
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: PriorityDuelActionBar(
          mode: mode,
          onSubmitRanking: onSubmitRanking ?? () async {},
        ),
      ),
    );
  }

  group('PriorityDuelActionBar', () {
    testWidgets('render hides CTA when not in ranking mode', (tester) async {
      await tester.pumpWidget(_harness(mode: DuelMode.winner));
      await tester.pumpAndSettle();

      expect(find.text('Valider le classement'), findsNothing);
    });

    testWidgets('shows and triggers submit action in ranking mode', (tester) async {
      var submitted = false;

      await tester.pumpWidget(
        _harness(
          mode: DuelMode.ranking,
          onSubmitRanking: () async {
            submitted = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Valider le classement'), findsOneWidget);

      await tester.tap(find.text('Valider le classement'));
      await tester.pump();

      expect(submitted, isTrue);
    });
  });
}
