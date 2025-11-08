import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/security/signup_guard.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_utils/fake_go_true_client.dart';

// Generate mocks for SupabaseService and SupabaseClient
@GenerateMocks([SupabaseService, SupabaseClient])
import 'auth_flow_test.mocks.dart';

void main() {
  group('Auth Flow Tests - Deterministic', () {
    late AuthService authService;
    late MockSupabaseService mockSupabaseService;
    late FakeGoTrueClient fakeAuth;
    late MockSupabaseClient mockClient;

    setUp(() async {
      // Initialize test environment
      SharedPreferences.setMockInitialValues({});
      await SignupGuard.instance.resetCounters();
      await AppConfig.initializeOfflineFirst();

      // Create deterministic fakes
      mockSupabaseService = MockSupabaseService();
      fakeAuth = FakeGoTrueClient();
      mockClient = MockSupabaseClient();

      // Setup mock chain
      when(mockSupabaseService.auth).thenReturn(fakeAuth);
      when(mockSupabaseService.client).thenReturn(mockClient);
      when(mockSupabaseService.currentUser).thenAnswer((_) => fakeAuth.currentUser);

      // Configure AuthService with fakes
      AuthService.configureForTesting(
        supabaseService: mockSupabaseService,
        logger: LoggerService.testing(Logger()),
      );

      authService = AuthService.instance;
    });

    tearDown(() {
      fakeAuth.clear();
    });

    group('Complete signup flow', () {
      test('Doit inscrire un nouvel utilisateur avec succ\u00e8s', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'secure_password_123';
        const fullName = 'New User';

        fakeAuth.clearLogs();

        // Act
        final response = await authService.signUp(
          email: email,
          password: password,
          fullName: fullName,
        );

        // Assert - AuthResponse
        expect(response.user, isNotNull);
        expect(response.user!.email, equals(email));
        expect(response.user!.userMetadata?['full_name'], equals(fullName));
        expect(response.session, isNotNull);
        expect(response.session!.accessToken, isNotEmpty);

        // Assert - Token determinism
        expect(response.session!.accessToken, startsWith('fake_access_token_'));
        expect(response.session!.refreshToken, startsWith('fake_refresh_token_'));

        // Assert - Operations log
        final signUpOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.signUp);
        expect(signUpOps.length, 1);
        expect(signUpOps.first.parameters['email'], equals(email));
        expect(signUpOps.first.succeeded, true);

        // Assert - User is now signed in
        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser!.email, equals(email));
        expect(authService.isSignedIn, true);
      });

      test('Doit \u00e9chouer lors de l\'inscription d\'un utilisateur existant', () async {
        // Arrange - Create initial user
        const email = 'existing@example.com';
        const password = 'password123';

        await authService.signUp(email: email, password: password);
        fakeAuth.clearLogs();

        // Act & Assert - Attempt duplicate signup
        try {
          await authService.signUp(email: email, password: password);
          fail('Should have thrown exception');
        } catch (e) {
          // Expected exception
          expect(e.toString(), contains('already exists'));
        }

        // Assert - Operation was attempted but failed
        final signUpOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.signUp);
        expect(signUpOps.length, 1);
        expect(signUpOps.first.succeeded, false);
      });
    });

    group('Login with credentials', () {
      setUp(() async {
        // Create test user for login tests
        await authService.signUp(
          email: 'test@example.com',
          password: 'password123',
        );
        await authService.signOut();
        fakeAuth.clearLogs();
      });

      test('Doit se connecter avec des identifiants valides', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        // Act
        final response = await authService.signIn(
          email: email,
          password: password,
        );

        // Assert - AuthResponse
        expect(response.user, isNotNull);
        expect(response.user!.email, equals(email));
        expect(response.session, isNotNull);
        expect(response.session!.accessToken, isNotEmpty);

        // Assert - Token determinism
        expect(response.session!.accessToken, startsWith('fake_access_token_'));

        // Assert - Operations log
        final signInOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.signInWithPassword);
        expect(signInOps.length, 1);
        expect(signInOps.first.parameters['email'], equals(email));
        expect(signInOps.first.succeeded, true);

        // Assert - User is now signed in
        expect(authService.currentUser, isNotNull);
        expect(authService.isSignedIn, true);
      });

      test('Doit \u00e9chouer avec des identifiants invalides', () async {
        // Arrange
        const email = 'test@example.com';
        const wrongPassword = 'wrong_password';

        // Act & Assert
        try {
          await authService.signIn(
            email: email,
            password: wrongPassword,
          );
          fail('Should have thrown exception');
        } catch (e) {
          // Expected exception
          expect(e.toString(), contains('Invalid credentials'));
        }

        // Assert - Operation was attempted but failed
        final signInOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.signInWithPassword);
        expect(signInOps.length, 1);
        expect(signInOps.first.succeeded, false);

        // Assert - User is not signed in
        expect(authService.currentUser, isNull);
        expect(authService.isSignedIn, false);
      });

      test('Doit \u00e9chouer pour un utilisateur inexistant', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const password = 'password123';

        // Act & Assert
        try {
          await authService.signIn(
            email: email,
            password: password,
          );
          fail('Should have thrown exception');
        } catch (e) {
          // Expected exception
          expect(e.toString(), contains('not found'));
        }

        // Assert - User is not signed in
        expect(authService.currentUser, isNull);
        expect(authService.isSignedIn, false);
      });
    });

    group('Logout flow', () {
      setUp(() async {
        // Sign in test user
        await authService.signUp(
          email: 'logout@example.com',
          password: 'password123',
        );
        fakeAuth.clearLogs();
      });

      test('Doit d\u00e9connecter l\'utilisateur courant', () async {
        // Arrange - Verify user is signed in
        expect(authService.isSignedIn, true);
        final userIdBeforeSignOut = authService.currentUser!.id;

        // Act
        await authService.signOut();

        // Assert - User is signed out
        expect(authService.currentUser, isNull);
        expect(authService.isSignedIn, false);
        expect(authService.currentToken, isNull);

        // Assert - Operations log
        final signOutOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.signOut);
        expect(signOutOps.length, 1);
        expect(signOutOps.first.succeeded, true);

        // Assert - Verify user ID was recorded before sign out
        expect(userIdBeforeSignOut, isNotEmpty);
      });

      test('Doit g\u00e9rer la d\u00e9connexion avec erreur', () async {
        // Arrange
        fakeAuth.setOperationFailure(AuthOperation.signOut, true);

        // Act & Assert
        try {
          await authService.signOut();
          fail('Should have thrown exception');
        } catch (e) {
          // Expected exception
          expect(e.toString(), contains('signOut failure'));
        }

        // Assert - Operation was attempted but failed
        final signOutOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.signOut);
        expect(signOutOps.length, 1);
        expect(signOutOps.first.succeeded, false);
      });
    });

    group('Password reset flow', () {
      test('Doit envoyer un email de r\u00e9initialisation', () async {
        // Arrange
        const email = 'reset@example.com';

        // Pre-create user
        await authService.signUp(email: email, password: 'oldpassword');
        fakeAuth.clearLogs();

        // Act
        await authService.resetPassword(email);

        // Assert - Operations log
        final resetOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.resetPasswordForEmail);
        expect(resetOps.length, 1);
        expect(resetOps.first.parameters['email'], equals(email));
        expect(resetOps.first.succeeded, true);
      });

      test('Doit g\u00e9rer silencieusement un email inexistant (s\u00e9curit\u00e9)', () async {
        // Arrange
        const email = 'nonexistent@example.com';

        // Act - Should not throw (security: don't reveal user existence)
        await authService.resetPassword(email);

        // Assert - Operation recorded
        final resetOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.resetPasswordForEmail);
        expect(resetOps.length, 1);
        expect(resetOps.first.parameters['email'], equals(email));
        expect(resetOps.first.succeeded, true);
      });
    });

    group('Session management', () {
      setUp(() async {
        // Sign in test user
        await authService.signUp(
          email: 'session@example.com',
          password: 'password123',
        );
        fakeAuth.clearLogs();
      });

      test('Doit rafra\u00eechir la session avec succ\u00e8s', () async {
        // Arrange
        final oldToken = authService.currentToken;
        expect(oldToken, isNotNull);

        // Act
        final response = await authService.refreshSession();

        // Assert - New session created
        expect(response.session, isNotNull);
        expect(response.session!.accessToken, isNotEmpty);
        expect(response.session!.accessToken, isNot(equals(oldToken)));

        // Assert - Token still deterministic
        expect(response.session!.accessToken, startsWith('fake_access_token_'));

        // Assert - Operations log
        final refreshOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.refreshSession);
        expect(refreshOps.length, 1);
        expect(refreshOps.first.succeeded, true);
      });

      test('Doit d\u00e9tecter une session valide', () {
        // Assert - Session is valid (not expired)
        expect(authService.hasValidSession, true);
      });

      test('Doit d\u00e9tecter l\'absence de session apr\u00e8s d\u00e9connexion', () async {
        // Act
        await authService.signOut();

        // Assert - No valid session
        expect(authService.hasValidSession, false);
      });
    });

    group('Profile management', () {
      setUp(() async {
        // Sign in test user
        await authService.signUp(
          email: 'profile@example.com',
          password: 'password123',
          fullName: 'Initial Name',
        );
        fakeAuth.clearLogs();
      });

      test('Doit mettre \u00e0 jour le profil utilisateur', () async {
        // Arrange
        const newFullName = 'Updated Name';
        const avatarUrl = 'https://example.com/avatar.jpg';

        // Act
        final response = await authService.updateProfile(
          fullName: newFullName,
          avatarUrl: avatarUrl,
        );

        // Assert - User updated
        expect(response.user, isNotNull);
        expect(response.user!.userMetadata?['full_name'], equals(newFullName));
        expect(response.user!.userMetadata?['avatar_url'], equals(avatarUrl));

        // Assert - Current user reflects changes
        expect(authService.currentUser!.userMetadata?['full_name'],
            equals(newFullName));

        // Assert - Operations log
        final updateOps = fakeAuth.operationsLog
            .where((op) => op.operation == AuthOperation.updateUser);
        expect(updateOps.length, 1);
        expect(updateOps.first.succeeded, true);
      });
    });
  });
}
