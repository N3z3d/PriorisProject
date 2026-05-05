import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/consent_gate_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/localized_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConsentGatePage', () {
    testWidgets('affiche le titre de consentement', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Protection de vos données'), findsOneWidget);
    });

    testWidgets('affiche le bouton "J\'accepte et je continue"', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("J'accepte et je continue"), findsOneWidget);
    });

    testWidgets('affiche le lien vers la politique de confidentialité', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lire la politique de confidentialité'), findsOneWidget);
    });
  });
}
