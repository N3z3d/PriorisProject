import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/home/widgets/desktop_sidebar.dart';
import 'package:prioris/presentation/pages/home/widgets/premium_bottom_nav.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';

import '../../test_utils/list_test_doubles.dart';

AppLocalizations _l10n(Locale locale) => lookupAppLocalizations(locale);

void main() {
  group('HomePage', () {
    setUp(_setBaseAppConfig);

    testWidgets('shows the configured pilot identity on desktop', (
      WidgetTester tester,
    ) async {
      const locale = Locale('fr');
      _setPilotAppConfig();

      await _pumpHomePage(
        tester,
        locale: locale,
      );

      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(find.byType(PremiumBottomNav), findsNothing);
      expect(find.text('Prioris Pilot Invite'), findsOneWidget);
      expect(find.text(_l10n(locale).pilotIdentityBadge), findsOneWidget);
      expect(find.text(_l10n(locale).settingsPilotStatusBody), findsOneWidget);
      expect(find.text(_l10n(locale).settingsPilotLimitsBody), findsOneWidget);
    });

    testWidgets('shows the configured pilot identity on mobile', (
      WidgetTester tester,
    ) async {
      const locale = Locale('fr');
      _setPilotAppConfig();

      await _pumpHomePage(
        tester,
        locale: locale,
        surfaceSize: const Size(390, 844),
      );

      expect(find.byType(PremiumBottomNav), findsOneWidget);
      expect(find.byType(DesktopSidebar), findsNothing);
      expect(find.text('Prioris Pilot Invite'), findsOneWidget);
      expect(find.text(_l10n(locale).pilotIdentityBadge), findsOneWidget);
      expect(find.text(_l10n(locale).settingsPilotStatusBody), findsOneWidget);
      expect(find.text(_l10n(locale).settingsPilotLimitsBody), findsOneWidget);
    });

    testWidgets('hides the pilot notice without explicit pilot metadata', (
      WidgetTester tester,
    ) async {
      const locale = Locale('fr');

      await _pumpHomePage(
        tester,
        locale: locale,
      );

      expect(find.text(_l10n(locale).pilotIdentityBadge), findsNothing);
      expect(find.text(_l10n(locale).settingsPilotStatusBody), findsNothing);
      expect(find.text(_l10n(locale).settingsPilotLimitsBody), findsNothing);
      expect(find.text('Prioris Pilot Invite'), findsNothing);
    });
  });
}

Future<void> _pumpHomePage(
  WidgetTester tester, {
  Size surfaceSize = const Size(1440, 1024),
  Locale locale = const Locale('fr'),
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        listsControllerProvider.overrideWith(
          (ref) => StubListsController(
            seededState: const ListsState.initial(),
          ),
        ),
        habitRepositoryProvider.overrideWith(
          (ref) => InMemoryHabitRepository(),
        ),
        duelSettingsStorageProvider.overrideWithValue(
          _InMemoryDuelSettingsStorage(),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const HomePage(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

class _InMemoryDuelSettingsStorage implements DuelSettingsStorage {
  DuelSettings? _stored;

  @override
  Future<DuelSettings?> load() async => _stored;

  @override
  Future<void> save(DuelSettings settings) async {
    _stored = settings;
  }
}

void _setBaseAppConfig() {
  AppConfig.setTestEnvironment(_baseAppConfigValues());
}

void _setPilotAppConfig() {
  AppConfig.setTestEnvironment({
    ..._baseAppConfigValues(),
    'PRIORIS_INSTANCE_NAME': 'Prioris Pilot Invite',
    'PRIORIS_INSTANCE_ENTRY_URL': 'https://pilot.prioris.app',
  });
}

Map<String, String> _baseAppConfigValues() => const {
      'SUPABASE_URL': 'https://tests-prioris.supabase.co',
      'SUPABASE_ANON_KEY':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.payload.signature',
      'SUPABASE_AUTH_REDIRECT_URL': 'https://tests.prioris.app/auth/callback',
      'ENVIRONMENT': 'test',
      'DEBUG_MODE': 'true',
    };
