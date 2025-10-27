import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_settings_bar.dart';

void main() {
  Widget _buildHarness({
    required DuelMode mode,
    required bool hasAvailableLists,
    bool disableCardSelector = false,
    ValueChanged<DuelMode>? onModeChanged,
    ValueChanged<int>? onCardsChanged,
    Future<void> Function()? onConfigureLists,
    Future<void> Function()? onRefresh,
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
          hasAvailableLists: hasAvailableLists,
          onModeChanged: onModeChanged ?? (_) {},
          onCardsChanged: onCardsChanged ?? (_) {},
          onConfigureLists: onConfigureLists ?? () async {},
          onRefresh: onRefresh ?? () async {},
        ),
      ),
    );
  }

  group('PriorityDuelSettingsBar', () {
    testWidgets('disables list configuration when no lists', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.winner,
          hasAvailableLists: false,
        ),
      );
      await tester.pumpAndSettle();

      final localized = AppLocalizations.of(
        tester.element(find.byType(PriorityDuelSettingsBar)),
      )!;
      final iconButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(localized.duelNoAvailableLists),
          matching: find.byType(IconButton),
        ),
      );
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('notifies when switching to ranking mode', (tester) async {
      DuelMode? selectedMode;

      await tester.pumpWidget(
        _buildHarness(
          mode: DuelMode.winner,
          hasAvailableLists: true,
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
          hasAvailableLists: true,
          disableCardSelector: true,
        ),
      );
      await tester.pumpAndSettle();

      final dropdown =
          tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>));
      expect(dropdown.onChanged, isNull);
    });
  });
}
