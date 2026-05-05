import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/settings_page.dart';
import '../../helpers/localized_widget.dart';

void main() {
  group('SettingsPage i18n', () {
    testWidgets('affiche "Paramètres" en FR', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const SettingsPage(), locale: const Locale('fr')),
        ),
      );
      await tester.pump();
      expect(find.text('Paramètres'), findsOneWidget);
    });

    testWidgets('affiche "Settings" en EN', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const SettingsPage(), locale: const Locale('en')),
        ),
      );
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('contient le sélecteur de langue (CompactLanguageSelector)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const SettingsPage()),
        ),
      );
      await tester.pump();
      expect(find.text('Langue'), findsOneWidget);
    });
  });
}
