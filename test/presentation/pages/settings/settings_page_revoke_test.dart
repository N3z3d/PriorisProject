import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/localized_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'privacy_consent_v1': true});
  });

  Widget buildSubject() {
    return ProviderScope(
      child: localizedApp(const SettingsPage()),
    );
  }

  group('SettingsPage — revoke consent tile', () {
    testWidgets('le tile "Retirer mon consentement" est visible', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer mon consentement'), findsOneWidget);
    });

    testWidgets('tapper le tile ouvre le dialog de confirmation', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Retirer mon consentement'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer votre consentement'), findsOneWidget);
    });

    testWidgets('tapper Annuler ferme le dialog sans modifier le consentement', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Retirer mon consentement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer votre consentement'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('privacy_consent_v1'), isTrue);
    });

    testWidgets('tapper Retirer appelle revoke et ferme le dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Retirer mon consentement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Retirer votre consentement'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('privacy_consent_v1'), isNull);
    });

    testWidgets('tapper Retirer ne laisse aucun snackbar visible', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Retirer mon consentement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Consentement retiré'), findsNothing);
    });
  });
}
