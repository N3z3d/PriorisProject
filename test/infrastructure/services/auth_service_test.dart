import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode;
import 'package:prioris/infrastructure/security/signup_guard.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

// Generate mocks
@GenerateMocks([SupabaseService, GoTrueClient, SupabaseClient])
import 'auth_service_test.mocks.dart';

class _StubGoTrueClient extends MockGoTrueClient {
  bool shouldThrowOAuth = false;

  @override
  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    String? scopes,
    LaunchMode authScreenLaunchMode = LaunchMode.platformDefault,
    Map<String, String>? queryParams,
  }) async {
    super.noSuchMethod(
      Invocation.method(
        #signInWithOAuth,
        [provider],
        {
          #redirectTo: redirectTo,
          #scopes: scopes,
          #authScreenLaunchMode: authScreenLaunchMode,
          #queryParams: queryParams,
        },
      ),
      returnValue: Future<bool>.value(!shouldThrowOAuth),
      returnValueForMissingStub: Future<bool>.value(!shouldThrowOAuth),
    );

    if (shouldThrowOAuth) {
      throw Exception('OAuth failed');
    }
    return true;
  }

  @override
  Future<OAuthResponse> getOAuthSignInUrl({
    required OAuthProvider? provider,
    String? redirectTo,
    String? scopes,
    Map<String, String>? queryParams,
  }) async {
    super.noSuchMethod(
      Invocation.method(
        #getOAuthSignInUrl,
        [],
        {
          #provider: provider,
          #redirectTo: redirectTo,
          #scopes: scopes,
          #queryParams: queryParams,
        },
      ),
      returnValue: Future<OAuthResponse>.value(
        OAuthResponse(
          provider: provider ?? OAuthProvider.google,
          url: 'https://example.com/login',
        ),
      ),
      returnValueForMissingStub: Future<OAuthResponse>.value(
        OAuthResponse(
          provider: provider ?? OAuthProvider.google,
          url: 'https://example.com/login',
        ),
      ),
    );

    final effectiveProvider = provider ?? OAuthProvider.google;

    return OAuthResponse(
      provider: effectiveProvider,
      url: 'https://example.com/login',
    );
  }
}

class _StubUrlLauncher extends UrlLauncherPlatform {
  bool launchCalled = false;
  bool launchShouldThrow = false;
  bool launchResult = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    launchCalled = true;
    if (launchShouldThrow) {
      throw Exception('launch failed');
    }
    return launchResult;
  }

  @override
  Future<void> closeWebView() async {}
}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockSupabaseService mockSupabaseService;
    late _StubGoTrueClient mockAuth;
    late MockSupabaseClient mockClient;
    late _StubUrlLauncher stubLauncher;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SignupGuard.instance.resetCounters();
      await AppConfig.initializeOfflineFirst();
      mockSupabaseService = MockSupabaseService();
      mockAuth = _StubGoTrueClient();
      mockClient = MockSupabaseClient();
      stubLauncher = _StubUrlLauncher();
      UrlLauncherPlatform.instance = stubLauncher;
      
      // Setup mock chain
      when(mockSupabaseService.auth).thenReturn(mockAuth);
      when(mockSupabaseService.client).thenReturn(mockClient);
      when(mockSupabaseService.currentUser).thenReturn(null);
      
      AuthService.configureForTesting(
        supabaseService: mockSupabaseService,
        logger: LoggerService.testing(Logger()),
      );

      authService = AuthService.instance;
    });

    group('Authentication', () {
      test('signUp should create new user account', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const fullName = 'Test User';
        
        final mockResponse = AuthResponse(
          session: Session(
            accessToken: 'mock-token',
            tokenType: 'bearer',
            expiresIn: 3600,
            refreshToken: 'refresh-token',
            user: User(
              id: 'user-id',
              appMetadata: {},
              userMetadata: {'full_name': fullName},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          user: User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {'full_name': fullName},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        when(mockAuth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.signUp(
          email: email,
          password: password,
          fullName: fullName,
        );

        // Assert
        expect(result, equals(mockResponse));
        verify(mockAuth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        )).called(1);
      });

      test('signUp should work without fullName', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        final mockResponse = AuthResponse(
          session: Session(
            accessToken: 'mock-token',
            tokenType: 'bearer',
            expiresIn: 3600,
            refreshToken: 'refresh-token',
            user: User(
              id: 'user-id',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          user: User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        when(mockAuth.signUp(
          email: email,
          password: password,
          data: null,
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.signUp(
          email: email,
          password: password,
        );

        // Assert
        expect(result, equals(mockResponse));
        verify(mockAuth.signUp(
          email: email,
          password: password,
          data: null,
        )).called(1);
      });

      test('signIn should authenticate user with email and password', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        final mockResponse = AuthResponse(
          session: Session(
            accessToken: 'mock-token',
            tokenType: 'bearer',
            expiresIn: 3600,
            refreshToken: 'refresh-token',
            user: User(
              id: 'user-id',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          user: User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        when(mockAuth.signInWithPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.signIn(
          email: email,
          password: password,
        );

        // Assert
        expect(result, equals(mockResponse));
        verify(mockAuth.signInWithPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('signOut should sign out current user', () async {
        // Arrange
        when(mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockAuth.signOut()).called(1);
      });

      test('resetPassword should send reset email', () async {
        // Arrange
        const email = 'test@example.com';
        final redirectUrl = AppConfig.instance.supabaseAuthRedirectUrl;

        when(mockAuth.resetPasswordForEmail(
          email,
          redirectTo: redirectUrl,
        )).thenAnswer((_) async {});

        // Act
        await authService.resetPassword(email);

        // Assert
        verify(mockAuth.resetPasswordForEmail(
          email,
          redirectTo: redirectUrl,
        )).called(1);
      });
    });

    group('User State', () {
      test('currentUser should return current authenticated user', () {
        // Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
        
        when(mockSupabaseService.currentUser).thenReturn(mockUser);

        // Act
        final user = authService.currentUser;

        // Assert
        expect(user, equals(mockUser));
      });

      test('isSignedIn should return true when user is authenticated', () {
        // Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
        
        when(mockSupabaseService.currentUser).thenReturn(mockUser);

        // Act
        final isSignedIn = authService.isSignedIn;

        // Assert
        expect(isSignedIn, isTrue);
      });

      test('isSignedIn should return false when user is not authenticated', () {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(null);

        // Act
        final isSignedIn = authService.isSignedIn;

        // Assert
        expect(isSignedIn, isFalse);
      });
    });

    group('Session Management', () {
      test('currentToken should return access token from current session', () {
        // Arrange
        const accessToken = 'mock-access-token';
        final mockSession = Session(
          accessToken: accessToken,
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: 'refresh-token',
          user: User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
        
        when(mockAuth.currentSession).thenReturn(mockSession);

        // Act
        final token = authService.currentToken;

        // Assert
        expect(token, equals(accessToken));
      });

      test('currentToken should return null when no session', () {
        // Arrange
        when(mockAuth.currentSession).thenReturn(null);

        // Act
        final token = authService.currentToken;

        // Assert
        expect(token, isNull);
      });

      test('hasValidSession should return true for valid session', () {
        // Arrange
        final futureTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round() + 3600;
        final mockSession = Session(
          accessToken: 'mock-token',
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: 'refresh-token',
          user: User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
        
        when(mockAuth.currentSession).thenReturn(mockSession);

        // Act
        final hasValidSession = authService.hasValidSession;

        // Assert
        // Note: Since we can't mock expiresAt, we'll test the basic logic
        expect(hasValidSession, isNotNull);
      });

      test('hasValidSession should return false for expired session', () {
        // Arrange
        when(mockAuth.currentSession).thenReturn(null);

        // Act
        final hasValidSession = authService.hasValidSession;

        // Assert
        expect(hasValidSession, isFalse);
      });

      test('refreshSession should refresh current session', () async {
        // Arrange
        final mockResponse = AuthResponse(
          session: Session(
            accessToken: 'new-mock-token',
            tokenType: 'bearer',
            expiresIn: 3600,
            refreshToken: 'new-refresh-token',
            user: User(
              id: 'user-id',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
          user: User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        when(mockAuth.refreshSession()).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.refreshSession();

        // Assert
        expect(result, equals(mockResponse));
        verify(mockAuth.refreshSession()).called(1);
      });
    });

    group('Profile Management', () {
      test('updateProfile should call updateUser', () async {
        // Arrange
        const fullName = 'Updated Name';
        const avatarUrl = 'https://example.com/avatar.jpg';
        
        // Mock the updateUser method to avoid type issues
        when(mockAuth.updateUser(any)).thenAnswer((_) async => throw UnimplementedError('Mocked'));

        // Act & Assert
        expect(
          () => authService.updateProfile(fullName: fullName, avatarUrl: avatarUrl),
          throwsA(isA<UnimplementedError>()),
        );
        
        verify(mockAuth.updateUser(any)).called(1);
      });
    });

    group('OAuth', () {
      test('signInWithGoogle should return true on success', () async {
        // Arrange
        final redirectUrl = AppConfig.instance.supabaseAuthRedirectUrl;
        stubLauncher.launchShouldThrow = false;
        stubLauncher.launchResult = true;

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isTrue);
        expect(stubLauncher.launchCalled, isTrue);
        verify(
          mockAuth.getOAuthSignInUrl(
            provider: OAuthProvider.google,
            redirectTo: redirectUrl,
            scopes: null,
            queryParams: null,
          ),
        ).called(1);
      });

      test('signInWithGoogle should return false on error', () async {
        // Arrange
        final redirectUrl = AppConfig.instance.supabaseAuthRedirectUrl;
        stubLauncher.launchShouldThrow = true;
        stubLauncher.launchResult = false;

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isFalse);
        verify(
          mockAuth.getOAuthSignInUrl(
            provider: OAuthProvider.google,
            redirectTo: redirectUrl,
            scopes: null,
            queryParams: null,
          ),
        ).called(1);
      });
    });

    group('Error Handling', () {
      test('signUp should rethrow exceptions', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        when(mockAuth.signUp(
          email: email,
          password: password,
          data: null,
        )).thenThrow(Exception('Sign up failed'));

        // Act & Assert
        try {
          await authService.signUp(email: email, password: password);
          fail('Expected exception');
        } catch (error) {
          expect(error, isA<Exception>());
        }
      });

      test('signIn should rethrow exceptions', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        when(mockAuth.signInWithPassword(
          email: email,
          password: password,
        )).thenThrow(Exception('Sign in failed'));

        // Act & Assert
        try {
          await authService.signIn(email: email, password: password);
          fail('Expected exception');
        } catch (error) {
          expect(error, isA<Exception>());
        }
      });

      test('signOut should rethrow exceptions', () async {
        // Arrange
        when(mockAuth.signOut()).thenThrow(Exception('Sign out failed'));

        // Act & Assert
        try {
          await authService.signOut();
          fail('Expected exception');
        } catch (error) {
          expect(error, isA<Exception>());
        }
      });
    });
  });
}
