import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_settings_bar.dart';

void main() {
  Widget _buildHarness({
    required DuelMode mode,
    bool disableCardSelector = false,
    ValueChanged<DuelMode>? onModeChanged,
    ValueChanged<int>? onCardsChanged,
  }) {
    return MaterialApp(
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: PriorityDuelSettingsBar(
          mode: mode,
          cardsPerRound: 2,
          disableCardSelector: disableCardSelector,
          onModeChanged: onModeChanged ?? (_) {},
          onCardsChanged: onCardsChanged ?? (_) {},
        ),
      ),
    );
  }

  group('PriorityDuelSettingsBar', () {
    testWidgets('notifies when switching to ranking mode', (tester) async {
      DuelMode? selectedMode;

      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.winner,
          onModeChanged: (mode) => selectedMode = mode,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Classement'));
      await tester.pumpAndSettle();

      expect(selectedMode, DuelMode.ranking);
    });

    testWidgets('disables card selector when duel mode is winner',
        (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.winner,
          disableCardSelector: true,
        ),
      );
      await tester.pumpAndSettle();

      final cardOption =
          tester.widget<GestureDetector>(find.byKey(const ValueKey('card-count-3')));
      expect(cardOption.onTap, isNull);
    });

    testWidgets('affiche les options de mode et de cartes', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.ranking,
          disableCardSelector: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vainqueur'), findsOneWidget);
      expect(find.text('Classement'), findsOneWidget);
      expect(find.byKey(const ValueKey('card-count-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('card-count-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('card-count-4')), findsOneWidget);
      expect(find.byKey(const ValueKey('duel-mode-vainqueur')), findsOneWidget);
      expect(find.byKey(const ValueKey('duel-mode-classement')), findsOneWidget);
    });
  });
}
