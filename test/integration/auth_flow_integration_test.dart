import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/core/exceptions/app_exception.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/infrastructure/security/signup_guard.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/web_auth_callback_stabilizer.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/auth/auth_wrapper.dart';
import 'package:prioris/presentation/pages/auth/login_page.dart';
import 'package:prioris/presentation/pages/home/widgets/premium_bottom_nav.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/settings_page.dart';
import 'package:prioris/presentation/widgets/common/forms/password_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../presentation/pages/duel_page_test_support.dart';
import '../test_utils/list_test_doubles.dart';
import '../test_utils/test_data.dart';
import '../test_utils/url_launcher_test_stub.dart';

AppLocalizations _frL10n() => lookupAppLocalizations(const Locale('fr'));

void main() {
  group('Auth Flow Integration Tests', () {
    late UrlLauncherPlatform originalUrlLauncher;
    late RecordingUrlLauncherPlatform launcher;

    setUp(() {
      _setBaseAppConfig();
      originalUrlLauncher = UrlLauncherPlatform.instance;
      launcher = RecordingUrlLauncherPlatform();
      UrlLauncherPlatform.instance = launcher;
    });

    tearDown(() {
      UrlLauncherPlatform.instance = originalUrlLauncher;
    });

    testWidgets('Complete signup and login flow', (WidgetTester tester) async {
      final l10n = _frL10n();
      final authService = TestAuthService();
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(l10n.authLoginTitle), findsOneWidget);

      await tester.tap(find.text(l10n.authToggleToSignUp));
      await tester.pumpAndSettle();

      expect(find.text(l10n.authSignUpTitle), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'newuser@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(l10n.authSignUpAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await authService.signOut();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'newuser@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(l10n.authSignInAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets(
        'Signup without session shows an explicit confirmation-required state on desktop',
        (WidgetTester tester) async {
      final authService = TestAuthService(
        signUpRequiresEmailConfirmation: true,
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(LoginPage), findsOneWidget);

      await tester.tap(find.text(_frL10n().authToggleToSignUp));
      await tester.pumpAndSettle();

      await _enterCredentials(
        tester,
        email: 'pending@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignUpAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.textContaining(_frL10n().authPendingConfirmationTitle),
          findsOneWidget);
      expect(
        find.textContaining('Confirmez votre adresse email'),
        findsOneWidget,
      );
      expect(find.text(_frL10n().authSignInAction), findsOneWidget);
    });

    testWidgets(
        'Signup without session and without returned user still shows an explicit confirmation-required state',
        (WidgetTester tester) async {
      final authService = TestAuthService(
        signUpRequiresEmailConfirmation: true,
        returnUserOnPendingSignUp: false,
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(LoginPage), findsOneWidget);

      await tester.tap(find.text(_frL10n().authToggleToSignUp));
      await tester.pumpAndSettle();

      await _enterCredentials(
        tester,
        email: 'pending-without-user@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignUpAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.textContaining(_frL10n().authPendingConfirmationTitle),
          findsOneWidget);
      expect(
        find.textContaining('Confirmez votre adresse email'),
        findsOneWidget,
      );
      expect(find.text(_frL10n().authSignInAction), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error',
        (WidgetTester tester) async {
      final authService = TestAuthService(
        signInError: Exception('Invalid credentials'),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(tester, authService: authService);

      expect(find.byType(LoginPage), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'invalid@email.com',
        password: 'wrongpassword',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Offline config block shows bounded login error',
        (WidgetTester tester) async {
      final offlineMessage =
          lookupAppLocalizations(const Locale('fr')).authOfflineSignInError;
      final authService = TestAuthService(
        signInError: AppException.configuration(
          message:
              'Authentication unavailable in offline mode. Please configure real Supabase credentials in .env file to enable online features.',
          context: 'AuthService.signIn',
          metadata: const {'messageKey': 'authOfflineSignInError'},
        ),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(tester, authService: authService);

      expect(find.byType(LoginPage), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'offline@email.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(offlineMessage), findsOneWidget);
      expect(
        find.textContaining('Authentication unavailable in offline mode'),
        findsNothing,
      );
    });

    testWidgets('Offline config block shows bounded signup error',
        (WidgetTester tester) async {
      final offlineMessage =
          lookupAppLocalizations(const Locale('fr')).authOfflineSignUpError;
      final authService = TestAuthService(
        signUpError: AppException.configuration(
          message:
              'Registration unavailable in offline mode. Please configure real Supabase credentials in .env file to enable online features.',
          context: 'AuthService.signUp',
          metadata: const {'messageKey': 'authOfflineSignUpError'},
        ),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(tester, authService: authService);

      await tester.tap(find.text(_frL10n().authToggleToSignUp));
      await tester.pumpAndSettle();

      await _enterCredentials(
        tester,
        email: 'offline-signup@email.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignUpAction));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(offlineMessage), findsOneWidget);
      expect(
        find.textContaining('Registration unavailable in offline mode'),
        findsNothing,
      );
    });

    testWidgets('Forgot password dialog flow', (WidgetTester tester) async {
      final authService = TestAuthService();
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(tester, authService: authService);

      expect(find.byType(LoginPage), findsOneWidget);

      await tester.tap(find.text(_frL10n().authForgotPasswordAction));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié'), findsOneWidget);

      await tester.enterText(_textFields().last, 'test@example.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Envoyer'));
      await tester.pumpAndSettle();

      expect(find.text('Email envoyé !'), findsOneWidget);
      expect(authService.passwordResetEmails, contains('test@example.com'));
    });

    testWidgets('Form validation works correctly', (WidgetTester tester) async {
      final authService = TestAuthService();
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(tester, authService: authService);

      expect(find.byType(LoginPage), findsOneWidget);

      await tester.enterText(_textFields().first, 'invalid-email');
      await tester.enterText(_passwordField().first, '123');
      await tester.pumpAndSettle();

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer un email valide'), findsOneWidget);
      expect(
        find.text('Le mot de passe doit contenir au moins 6 caractères'),
        findsOneWidget,
      );
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Toggle between login and signup modes',
        (WidgetTester tester) async {
      final authService = TestAuthService();
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(tester, authService: authService);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(_frL10n().authLoginTitle), findsOneWidget);
      expect(find.text(_frL10n().authSignInAction), findsOneWidget);
      expect(find.text(_frL10n().authForgotPasswordAction), findsOneWidget);

      await tester.tap(find.text(_frL10n().authToggleToSignUp));
      await tester.pumpAndSettle();

      expect(find.text(_frL10n().authSignUpTitle), findsOneWidget);
      expect(find.text(_frL10n().authSignUpAction), findsOneWidget);
      expect(find.text(_frL10n().authToggleToSignIn), findsOneWidget);
      expect(find.text(_frL10n().authForgotPasswordAction), findsNothing);

      await tester.tap(find.text(_frL10n().authToggleToSignIn));
      await tester.pumpAndSettle();

      expect(find.text(_frL10n().authLoginTitle), findsOneWidget);
      expect(find.text(_frL10n().authSignInAction), findsOneWidget);
      expect(find.text(_frL10n().authForgotPasswordAction), findsOneWidget);
    });

    testWidgets('Loading state is shown during authentication',
        (WidgetTester tester) async {
      final authService = TestAuthService(
        signInDelay: const Duration(milliseconds: 300),
      );
      addTearDown(authService.dispose);

      await authService.register(
        email: 'test@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(tester, authService: authService);

      expect(find.byType(LoginPage), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'test@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pump();

      expect(find.text(_frL10n().loading), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text(_frL10n().authSignInAction), findsOneWidget);
    });

    testWidgets(
        'AuthWrapper restores a cached session before auth stream catches up',
        (WidgetTester tester) async {
      final persistedUser = _buildUser('persisted@example.com');
      final authService = TestAuthService(
        initialUser: persistedUser,
        initialAuthStateDelay: const Duration(seconds: 1),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'AuthWrapper restores a persisted session even when currentUser is not hydrated yet',
        (WidgetTester tester) async {
      final persistedUser = _buildUser('persisted-session@example.com');
      final persistedSession = Session(
        accessToken: 'token-${persistedUser.id}',
        tokenType: 'bearer',
        expiresIn: 3600,
        refreshToken: 'refresh-${persistedUser.id}',
        user: persistedUser,
      );
      final authService = TestAuthService(
        initialSession: persistedSession,
        initialAuthStateDelay: const Duration(seconds: 1),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'AuthWrapper restores a callback-created session even when token expiry is not derivable yet',
        (WidgetTester tester) async {
      final callbackUser = _buildUser('callback-session@example.com');
      final callbackSession = Session(
        accessToken: 'opaque-callback-token',
        tokenType: 'bearer',
        expiresIn: 3600,
        refreshToken: 'refresh-callback-token',
        user: callbackUser,
      );
      final authService = TestAuthService(
        initialSession: callbackSession,
        initialAuthStateDelay: const Duration(seconds: 1),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'callback session stabilization survives a reload-like bootstrap',
        (WidgetTester tester) async {
      final callbackUser = _buildUser('callback-reload@example.com');
      final callbackSession = Session(
        accessToken: 'opaque-callback-token',
        tokenType: 'bearer',
        expiresIn: 3600,
        refreshToken: 'refresh-callback-token',
        user: callbackUser,
      );
      final browserAdapter = RecordingWebAuthCallbackBrowserAdapter(
        currentUri: Uri.parse(
          'https://tests.prioris.app/auth/callback?code=one-shot-code&type=signup&next=lists',
        ),
      );

      final stabilized = await WebAuthCallbackStabilizer.stabilizeIfNeeded(
        supabaseUrl: AppConfig.instance.supabaseUrl,
        session: callbackSession,
        browserAdapter: browserAdapter,
      );

      expect(stabilized, isTrue);
      expect(browserAdapter.persistedSessions, hasLength(1));
      expect(
        browserAdapter.replacedUrls.single,
        'https://tests.prioris.app/auth/callback?next=lists',
      );

      final persistedSession = Session.fromJson(
        jsonDecode(browserAdapter.persistedSessions.single.serializedSession)
            as Map<String, dynamic>,
      );
      expect(persistedSession, isNotNull);

      final authService = TestAuthService(
        initialSession: persistedSession,
        initialAuthStateDelay: const Duration(seconds: 1),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'AuthWrapper shows a bounded auth bootstrap error on login page',
        (WidgetTester tester) async {
      final authService = TestAuthService(
        authStateError: Exception(
          'AuthRetryableFetchException: failed host lookup',
        ),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.textContaining('Problème de connexion réseau'),
        findsOneWidget,
      );
    });
    testWidgets(
        'AuthWrapper does not restore a stale cached session when bootstrap fails',
        (WidgetTester tester) async {
      final persistedUser = _buildUser('stale@example.com');
      final authService = TestAuthService(
        initialUser: persistedUser,
        forcedHasValidSession: false,
        authStateError: Exception(
          'AuthRetryableFetchException: failed host lookup',
        ),
      );
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets(
        'Login exposes personal list data on the normal controller path',
        (WidgetTester tester) async {
      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'normalflow@example.com',
        password: 'password123',
      );
      await authService.signOut();

      final customListRepository = InMemoryCustomListRepository();
      final listItemRepository = InMemoryListItemRepository();
      final personalItem = TestData.createTestListItem(
        id: 'normal-flow-item',
        title: 'Item personnel',
        listId: 'normal-flow-list',
      );
      final personalList = TestData.createEmptyTestList(
        id: 'normal-flow-list',
        name: 'Liste personnelle',
      ).copyWith(items: [personalItem]);

      await customListRepository.saveList(personalList);
      await listItemRepository.add(personalItem);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
        useRealListsDataFlow: true,
        customListRepository: customListRepository,
        listItemRepository: listItemRepository,
      );

      expect(find.byType(LoginPage), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'normalflow@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Liste personnelle'), findsOneWidget);
    });

    testWidgets(
        'Desktop login reaches a first-use shell for an empty external user',
        (WidgetTester tester) async {
      _setPilotAppConfig();

      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'firstuse-desktop@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.text('Prioris Pilot Invite'), findsOneWidget);
      expect(find.text('Pilote externe'), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'firstuse-desktop@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Prioris Pilot Invite'), findsOneWidget);
      expect(find.text('Pilote externe'), findsOneWidget);
      expect(find.text('Votre espace est pret'), findsOneWidget);
      expect(find.text('Ajouter une liste'), findsOneWidget);
      expect(find.text("Rien d'urgence pour l'instant"), findsNothing);
    });

    testWidgets(
        'Mobile login reaches a first-use shell for an empty external user',
        (WidgetTester tester) async {
      _setPilotAppConfig();

      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'firstuse-mobile@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
        viewportSize: const Size(390, 844),
      );

      expect(find.text('Prioris Pilot Invite'), findsOneWidget);
      expect(find.text('Pilote externe'), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'firstuse-mobile@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(PremiumBottomNav), findsOneWidget);
      expect(find.text('Prioris Pilot Invite'), findsOneWidget);
      expect(find.text('Pilote externe'), findsOneWidget);
      expect(find.text('Votre espace est pret'), findsOneWidget);
      expect(find.text('Ajouter une liste'), findsOneWidget);
    });

    testWidgets(
        'Mobile auth flow reaches the shell then signs out back to login',
        (WidgetTester tester) async {
      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'mobile@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
        viewportSize: const Size(390, 844),
      );

      expect(find.byType(LoginPage), findsOneWidget);

      await _enterCredentials(
        tester,
        email: 'mobile@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      final logoutButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.logout_outlined).first,
          matching: find.byType(IconButton),
        ),
      );
      logoutButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets(
        'Desktop login reaches the configured pilot feedback channel from settings',
        (WidgetTester tester) async {
      _setPilotSupportAppConfig();

      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'support-desktop@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      await _enterCredentials(
        tester,
        email: 'support-desktop@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      await _openSettingsFromShell(tester);
      await _tapSettingsAction(tester, _frL10n().feedback);

      expect(
        launcher.launchedUrls,
        ['https://pilot.prioris.app/support/form'],
      );
    });

    testWidgets(
        'Desktop login reaches pilot help and legal information from settings',
        (WidgetTester tester) async {
      _setPilotSupportAppConfig();

      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'support-legal-desktop@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      await _enterCredentials(
        tester,
        email: 'support-legal-desktop@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      await _openSettingsFromShell(tester);

      await _tapSettingsAction(tester, _frL10n().help);
      expect(
        find.textContaining('support du pilote reste manuel et borne'),
        findsOneWidget,
      );
      await tester.tap(find.text(_frL10n().close));
      await tester.pumpAndSettle();

      await _tapSettingsAction(tester, _frL10n().privacyPolicy);
      expect(
        find.textContaining('donnees necessaires au pilote'),
        findsOneWidget,
      );
      await tester.tap(find.text(_frL10n().close));
      await tester.pumpAndSettle();

      await _tapSettingsAction(tester, _frL10n().termsOfService);
      expect(
        find.textContaining('petit groupe invite'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Mobile login reaches the configured pilot feedback channel from settings',
        (WidgetTester tester) async {
      _setPilotSupportAppConfig();

      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'support-mobile@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
        viewportSize: const Size(390, 844),
      );

      await _enterCredentials(
        tester,
        email: 'support-mobile@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      await _openSettingsFromShell(tester);
      await _tapSettingsAction(tester, _frL10n().feedback);

      expect(
        launcher.launchedUrls,
        ['https://pilot.prioris.app/support/form'],
      );
    });

    testWidgets(
        'Mobile login reaches pilot help and legal information from settings',
        (WidgetTester tester) async {
      _setPilotSupportAppConfig();

      final authService = TestAuthService();
      addTearDown(authService.dispose);
      await authService.register(
        email: 'support-legal-mobile@example.com',
        password: 'password123',
      );
      await authService.signOut();

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
        viewportSize: const Size(390, 844),
      );

      await _enterCredentials(
        tester,
        email: 'support-legal-mobile@example.com',
        password: 'password123',
      );

      await tester.tap(find.text(_frL10n().authSignInAction));
      await tester.pumpAndSettle();

      await _openSettingsFromShell(tester);

      await _tapSettingsAction(tester, _frL10n().help);
      expect(
        find.textContaining('support du pilote reste manuel et borne'),
        findsOneWidget,
      );
      await tester.tap(find.text(_frL10n().close));
      await tester.pumpAndSettle();

      await _tapSettingsAction(tester, _frL10n().privacyPolicy);
      expect(
        find.textContaining('donnees necessaires au pilote'),
        findsOneWidget,
      );
      await tester.tap(find.text(_frL10n().close));
      await tester.pumpAndSettle();

      await _tapSettingsAction(tester, _frL10n().termsOfService);
      expect(
        find.textContaining('petit groupe invite'),
        findsOneWidget,
      );
    });
  });

  group('Repository Switching Tests', () {
    testWidgets('Repository switches based on auth state',
        (WidgetTester tester) async {
      final authService = TestAuthService();
      addTearDown(authService.dispose);

      await pumpAuthFlowApp(
        tester,
        authService: authService,
        useAuthWrapper: true,
      );

      expect(find.byType(LoginPage), findsOneWidget);

      authService.emitSignedIn(_buildUser('test.success@example.com'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await authService.signOut();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}

Future<void> pumpAuthFlowApp(
  WidgetTester tester, {
  required TestAuthService authService,
  bool useAuthWrapper = false,
  bool useRealListsDataFlow = false,
  InMemoryCustomListRepository? customListRepository,
  InMemoryListItemRepository? listItemRepository,
  Size viewportSize = const Size(1440, 1024),
}) async {
  tester.view.physicalSize = viewportSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final overrides = <Override>[
    authServiceProvider.overrideWithValue(authService),
    taskRepositoryProvider.overrideWith(
      (ref) => TestTaskRepository(<Task>[]),
    ),
    duelSettingsStorageProvider.overrideWithValue(
      const InMemoryDuelSettingsStorage(),
    ),
    habitRepositoryProvider.overrideWith(
      (ref) => InMemoryHabitRepository(),
    ),
  ];

  if (useRealListsDataFlow) {
    final effectiveCustomListRepository =
        customListRepository ?? InMemoryCustomListRepository();
    final effectiveListItemRepository =
        listItemRepository ?? InMemoryListItemRepository();

    overrides.addAll([
      adaptiveCustomListRepositoryProvider.overrideWith(
        (ref) async => effectiveCustomListRepository,
      ),
      adaptiveListItemRepositoryProvider.overrideWith(
        (ref) async => effectiveListItemRepository,
      ),
    ]);
  } else {
    overrides.add(
      listsControllerProvider.overrideWith(
        (ref) => StubListsController(
          seededState: const ListsState.initial(),
        ),
      ),
    );
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: useAuthWrapper ? const AuthWrapper() : const LoginPage(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> _enterCredentials(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(_textFields().first, email);
  await tester.enterText(_passwordField().first, password);
  await tester.pumpAndSettle();
}

Finder _textFields() {
  return find.byType(TextFormField);
}

Finder _passwordField() {
  return find.descendant(
    of: find.byType(PasswordTextField),
    matching: find.byType(TextFormField),
  );
}

User _buildUser(String email) {
  return User(
    id: 'user_${email.split('@').first}',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime(2024, 1, 1).toIso8601String(),
    email: email,
  );
}

class TestAuthService implements AuthService {
  TestAuthService({
    this.signInDelay = Duration.zero,
    this.signUpDelay = Duration.zero,
    this.signInError,
    this.signUpError,
    this.signUpRequiresEmailConfirmation = false,
    this.returnUserOnPendingSignUp = true,
    this.resetPasswordError,
    User? initialUser,
    Session? initialSession,
    this.initialAuthStateDelay = Duration.zero,
    this.authStateError,
    this.forcedHasValidSession,
  })  : _currentUser = initialUser,
        _currentSession = initialSession ??
            (initialUser == null ? null : _buildSession(initialUser));

  final Duration signInDelay;
  final Duration signUpDelay;
  final Object? signInError;
  final Object? signUpError;
  final bool signUpRequiresEmailConfirmation;
  final bool returnUserOnPendingSignUp;
  final Object? resetPasswordError;
  final Duration initialAuthStateDelay;
  final Object? authStateError;
  final bool? forcedHasValidSession;

  final List<String> passwordResetEmails = <String>[];
  final Map<String, String> _passwordsByEmail = <String, String>{};
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  User? _currentUser;
  Session? _currentSession;

  @override
  Stream<AuthState> get authStateChanges async* {
    if (initialAuthStateDelay > Duration.zero) {
      await Future<void>.delayed(initialAuthStateDelay);
    }
    if (authStateError != null) {
      throw authStateError!;
    }
    yield _currentAuthState();
    yield* _authStateController.stream;
  }

  @override
  User? get currentUser => _currentUser;

  @override
  User? get bootstrapUser => _currentSession?.user ?? _currentUser;

  @override
  String? get currentToken => _currentSession?.accessToken;

  @override
  bool get hasValidSession =>
      forcedHasValidSession ?? AuthService.isSessionUsable(_currentSession);

  @override
  bool get isSignedIn => _currentUser != null;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    _passwordsByEmail[email] = password;
  }

  void emitSignedIn(User user) {
    _currentUser = user;
    _currentSession = Session(
      accessToken: 'token-${user.id}',
      tokenType: 'bearer',
      expiresIn: 3600,
      refreshToken: 'refresh-${user.id}',
      user: user,
    );
    _authStateController
        .add(_currentAuthState(event: AuthChangeEvent.signedIn));
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(signInDelay);

    if (signInError != null) {
      throw signInError!;
    }

    final expectedPassword = _passwordsByEmail[email];
    if (expectedPassword == null || expectedPassword != password) {
      throw Exception('Invalid credentials');
    }

    final user = _buildUser(email);
    emitSignedIn(user);
    return AuthResponse(session: _currentSession, user: user);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    SignupAttemptMetadata metadata = const SignupAttemptMetadata(),
  }) async {
    await Future<void>.delayed(signUpDelay);

    if (signUpError != null) {
      throw signUpError!;
    }

    _passwordsByEmail[email] = password;

    final user = User(
      id: 'user_${email.split('@').first}',
      appMetadata: const {},
      userMetadata: fullName == null
          ? const {}
          : <String, dynamic>{'full_name': fullName},
      aud: 'authenticated',
      createdAt: DateTime(2024, 1, 1).toIso8601String(),
      email: email,
    );

    if (signUpRequiresEmailConfirmation) {
      _currentUser = null;
      _currentSession = null;
      return AuthResponse(
        session: null,
        user: returnUserOnPendingSignUp ? user : null,
      );
    }

    emitSignedIn(user);
    return AuthResponse(session: _currentSession, user: user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _currentSession = null;
    _authStateController.add(
      _currentAuthState(event: AuthChangeEvent.signedOut),
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    passwordResetEmails.add(email);

    if (resetPasswordError != null) {
      throw resetPasswordError!;
    }
  }

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) {
    throw UnimplementedError('updateProfile is not used in auth flow tests');
  }

  @override
  Future<AuthResponse> refreshSession() async {
    return AuthResponse(session: _currentSession, user: _currentUser);
  }

  void dispose() {
    _authStateController.close();
  }

  AuthState _currentAuthState({AuthChangeEvent? event}) {
    return AuthState(
      event ??
          (_currentUser == null
              ? AuthChangeEvent.signedOut
              : AuthChangeEvent.signedIn),
      _currentSession,
    );
  }

  static Session _buildSession(User user) {
    return Session(
      accessToken: 'token-${user.id}',
      tokenType: 'bearer',
      expiresIn: 3600,
      refreshToken: 'refresh-${user.id}',
      user: user,
    );
  }
}

class RecordingWebAuthCallbackBrowserAdapter
    extends WebAuthCallbackBrowserAdapter {
  RecordingWebAuthCallbackBrowserAdapter({required this.currentUri});

  @override
  final Uri? currentUri;

  final List<PersistedBrowserSessionRecord> persistedSessions =
      <PersistedBrowserSessionRecord>[];
  final List<String> replacedUrls = <String>[];

  @override
  Future<void> persistSession({
    required String storageKey,
    required String serializedSession,
  }) async {
    persistedSessions.add(
      PersistedBrowserSessionRecord(
        storageKey: storageKey,
        serializedSession: serializedSession,
      ),
    );
  }

  @override
  void replaceUrl(String url) {
    replacedUrls.add(url);
  }
}

class PersistedBrowserSessionRecord {
  const PersistedBrowserSessionRecord({
    required this.storageKey,
    required this.serializedSession,
  });

  final String storageKey;
  final String serializedSession;
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

void _setPilotSupportAppConfig() {
  AppConfig.setTestEnvironment({
    ..._baseAppConfigValues(),
    'PRIORIS_INSTANCE_NAME': 'Prioris Pilot Invite',
    'PRIORIS_INSTANCE_ENTRY_URL': 'https://pilot.prioris.app',
    'PRIORIS_PILOT_FEEDBACK_URL': 'https://pilot.prioris.app/support/form',
    'PRIORIS_PILOT_SUPPORT_EMAIL': 'support@prioris.app',
  });
}

Future<void> _openSettingsFromShell(WidgetTester tester) async {
  final settingsButton = tester.widgetList<IconButton>(
    find.byType(IconButton),
  ).firstWhere(
    (button) => button.tooltip == _frL10n().settings && button.onPressed != null,
  );

  settingsButton.onPressed!.call();
  await tester.pumpAndSettle();
}

Future<void> _tapSettingsAction(WidgetTester tester, String label) async {
  final actionFinder = find.descendant(
    of: find.byType(SettingsPage),
    matching: find.text(label),
  );

  await tester.scrollUntilVisible(
    actionFinder,
    240,
    scrollable: find.descendant(
      of: find.byType(SettingsPage),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.ensureVisible(actionFinder);
  await tester.pumpAndSettle();
  await tester.tap(actionFinder);
  await tester.pumpAndSettle();
}

Map<String, String> _baseAppConfigValues() {
  return const {
    'SUPABASE_URL': 'https://tests-prioris.supabase.co',
    'SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.tests-prioris',
    'SUPABASE_AUTH_REDIRECT_URL': 'https://tests.prioris.app/auth/callback',
    'ENVIRONMENT': 'test',
    'DEBUG_MODE': 'true',
  };
}
