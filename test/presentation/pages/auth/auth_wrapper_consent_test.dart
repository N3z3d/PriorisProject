import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:prioris/domain/services/core/consent_service.dart';
import 'package:prioris/presentation/pages/auth/auth_wrapper.dart';
import 'package:prioris/presentation/pages/consent_gate_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/localized_widget.dart';

// Service dont hasAcceptedConsent() ne se résout jamais — maintient l'état loading
class _BlockingConsentService extends ConsentService {
  @override
  Future<bool> hasAcceptedConsent() => Completer<bool>().future;
}

void main() {
  group('AuthWrapper — gate de consentement', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('signedIn + hasConsent=true → HomePage (pas ConsentGatePage)', (tester) async {
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': true});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUIStateProvider.overrideWithValue(AuthUIState.signedIn),
          ],
          child: localizedApp(const AuthWrapper()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ConsentGatePage), findsNothing);
    });

    testWidgets('signedIn + hasConsent=false → ConsentGatePage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUIStateProvider.overrideWithValue(AuthUIState.signedIn),
          ],
          child: localizedApp(const AuthWrapper()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ConsentGatePage), findsOneWidget);
    });

    testWidgets('signedIn + consentProvider loading → spinner', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUIStateProvider.overrideWithValue(AuthUIState.signedIn),
            consentServiceProvider.overrideWithValue(_BlockingConsentService()),
          ],
          child: localizedApp(const AuthWrapper()),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('signedOut → pas de ConsentGatePage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUIStateProvider.overrideWithValue(AuthUIState.signedOut),
          ],
          child: localizedApp(const AuthWrapper()),
        ),
      );
      await tester.pump();
      expect(find.byType(ConsentGatePage), findsNothing);
    });
  });
}
