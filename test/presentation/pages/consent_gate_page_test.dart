import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/presentation/pages/consent_gate_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/localized_widget.dart';

/// Test double minimal : AuthController dont signOut() est enregistré sans
/// dépendre d'un vrai AuthService (Supabase non initialisé en test).
class _DummyAuthService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _RecordingAuthController extends AuthController {
  _RecordingAuthController() : super(_DummyAuthService());

  int signOutCalls = 0;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

/// signOut() qui échoue toujours — vérifie le feedback d'erreur (AC : ne pas
/// laisser l'utilisateur sans retour).
class _ThrowingAuthController extends AuthController {
  _ThrowingAuthController() : super(_DummyAuthService());

  int signOutCalls = 0;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    throw Exception('network');
  }
}

/// signOut() bloquant sur un completer — vérifie l'anti double-tap.
class _BlockingAuthController extends AuthController {
  _BlockingAuthController() : super(_DummyAuthService());

  int signOutCalls = 0;
  final Completer<void> completer = Completer<void>();

  @override
  Future<void> signOut() async {
    signOutCalls++;
    await completer.future;
  }
}

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

  group('ConsentGatePage — état terminal 3 choix (story 10.18)', () {
    testWidgets('affiche le message orienté action (AC4)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Que souhaitez-vous faire ?'), findsOneWidget);
    });

    testWidgets('affiche le bouton "Se déconnecter" (AC2)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Se déconnecter'), findsOneWidget);
    });

    testWidgets('tapper "Se déconnecter" appelle signOut (AC2)', (tester) async {
      final controller = _RecordingAuthController();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWithValue(controller),
          ],
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      expect(controller.signOutCalls, 1);
    });

    testWidgets('présente bien les 3 actions distinctes (AC2)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(find.text('Lire la politique de confidentialité'), findsOneWidget);
      expect(find.text("J'accepte et je continue"), findsOneWidget);
    });

    testWidgets('signOut en échec affiche un message et réactive le bouton',
        (tester) async {
      final controller = _ThrowingAuthController();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWithValue(controller)],
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      // Feedback d'erreur affiché (pas d'exception async avalée).
      expect(find.text('La déconnexion a échoué. Réessayez.'), findsOneWidget);
      // Bouton réactivé : un nouvel appui redéclenche signOut.
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(controller.signOutCalls, 2);
    });

    testWidgets('double-tap sur "Se déconnecter" ne déclenche qu\'un signOut',
        (tester) async {
      final controller = _BlockingAuthController();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWithValue(controller)],
          child: localizedApp(const ConsentGatePage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se déconnecter'));
      await tester.pump(); // _signingOut = true, bouton désactivé
      await tester.tap(find.text('Se déconnecter'), warnIfMissed: false);
      await tester.pump();

      expect(controller.signOutCalls, 1);

      controller.completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
