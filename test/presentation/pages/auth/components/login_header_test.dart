import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/auth/components/login_header.dart';

void main() {
  setUp(() {
    AppConfig.setTestEnvironment(const {
      'SUPABASE_URL': 'https://pilot.supabase.co',
      'SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.pilot',
      'SUPABASE_AUTH_REDIRECT_URL': 'https://pilot/auth/callback',
    });
  });

  Widget buildHarness(Widget child) {
    return MaterialApp(
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  testWidgets(
    'affiche le repere pilote quand une instance publique explicite est configuree',
    (tester) async {
      AppConfig.setTestEnvironment(const {
        'SUPABASE_URL': 'https://pilot.supabase.co',
        'SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.pilot',
        'SUPABASE_AUTH_REDIRECT_URL': 'https://pilot/auth/callback',
        'PRIORIS_INSTANCE_NAME': 'Pilot externe Prioris',
        'PRIORIS_INSTANCE_ENTRY_URL': 'https://n3z3d.github.io/PriorisProject/',
      });

      await tester.pumpWidget(buildHarness(const LoginHeader(isSignUp: false)));

      expect(find.text('Connectez-vous'), findsOneWidget);
      expect(find.text('Pilote externe'), findsOneWidget);
      expect(find.text('Pilot externe Prioris'), findsOneWidget);
    },
  );

  testWidgets(
    'n affiche pas le repere pilote sans metadata d instance explicite',
    (tester) async {
      await tester.pumpWidget(buildHarness(const LoginHeader(isSignUp: true)));

      expect(find.text('Creer un compte'), findsOneWidget);
      expect(find.text('Pilote externe'), findsNothing);
    },
  );
}
