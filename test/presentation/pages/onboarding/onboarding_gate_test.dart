import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_flow_page.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_gate.dart';

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('fr'),
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingGate(),
    ),
  );
}

void main() {
  group('OnboardingGate', () {
    testWidgets('shouldShow=true → affiche OnboardingFlowPage', (tester) async {
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider.overrideWith((ref) async => true),
      ]));
      await tester.pump(); // résout le FutureProvider

      expect(find.byType(OnboardingFlowPage), findsOneWidget);
    });

    testWidgets('chargement → spinner', (tester) async {
      // Completer jamais complété : reste en loading sans timer pendant.
      final pending = Completer<bool>();
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider.overrideWith((ref) => pending.future),
      ]));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OnboardingFlowPage), findsNothing);
    });

    testWidgets('shouldShow=false → onboarding non affiché', (tester) async {
      await tester.pumpWidget(_wrap([
        shouldShowOnboardingProvider.overrideWith((ref) async => false),
      ]));
      await tester.pump();

      expect(find.byType(OnboardingFlowPage), findsNothing);
    });
  });
}
