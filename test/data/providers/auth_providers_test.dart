import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';

// Generate mocks
@GenerateMocks([AuthService])
import 'auth_providers_test.mocks.dart';

void main() {
  group('Auth Providers', () {
    late ProviderContainer container;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('authServiceProvider', () {
      test('should provide AuthService instance', () {
        // Act
        final authService = container.read(authServiceProvider);

        // Assert
        expect(authService, isA<AuthService>());
      });
    });

    group('currentUserProvider', () {
      test('should provide current user when authenticated', () async {
        // Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {'full_name': 'Test User'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );

        final mockSession = Session(
          accessToken: 'token',
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: 'refresh',
          user: mockUser,
        );

        final authState = AuthState(AuthChangeEvent.signedIn, mockSession);
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.value(authState));

        // Act - Wait for the stream to emit
        final userAsync = await container.read(currentUserProvider.future);

        // Assert
        expect(userAsync, equals(mockUser));
      });

      test('should provide null when not authenticated', () async {
        // Arrange
        final authState = AuthState(AuthChangeEvent.signedOut, null);
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.value(authState));

        // Act - Wait for the stream to emit
        final userAsync = await container.read(currentUserProvider.future);

        // Assert
        expect(userAsync, isNull);
      });

      test('should handle auth state stream errors', () async {
        // Arrange
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.error(Exception('Auth error')));

        // Act & Assert
        expect(
          () => container.read(currentUserProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('isSignedInProvider', () {
      test('should return true when user is signed in', () async {
        // Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );

        final mockSession = Session(
          accessToken: 'token',
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: 'refresh',
          user: mockUser,
        );

        final authState = AuthState(AuthChangeEvent.signedIn, mockSession);
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.value(authState));

        // Wait for the provider to be ready
        await container.read(currentUserProvider.future);

        // Act
        final isSignedIn = container.read(isSignedInProvider);

        // Assert
        expect(isSignedIn, isTrue);
      });

      test('should return false when user is not signed in', () async {
        // Arrange
        final authState = AuthState(AuthChangeEvent.signedOut, null);
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.value(authState));

        // Wait for the provider to be ready
        await container.read(currentUserProvider.future);

        // Act
        final isSignedIn = container.read(isSignedInProvider);

        // Assert
        expect(isSignedIn, isFalse);
      });

      test('should return false when loading', () {
        // Arrange
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.fromFuture(
                  Future.delayed(const Duration(seconds: 1))
                      .then((_) => AuthState(AuthChangeEvent.signedOut, null)),
                ));

        // Act
        final isSignedIn = container.read(isSignedInProvider);

        // Assert
        expect(isSignedIn, isFalse);
      });

      test('should return false on error', () {
        // Arrange
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.error(Exception('Auth error')));

        // Act
        final isSignedIn = container.read(isSignedInProvider);

        // Assert
        expect(isSignedIn, isFalse);
      });
    });

    group('authStateProvider', () {
      test('should provide auth state stream', () async {
        // Arrange
        final authState = AuthState(AuthChangeEvent.signedOut, null);
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.value(authState));

        // Act - Wait for the stream to emit
        final stateAsync = await container.read(authStateProvider.future);

        // Assert
        expect(stateAsync, equals(authState));
      });
    });

    group('authUIStateProvider', () {
      test('should return signedIn when user is authenticated', () async {
        // Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );

        final mockSession = Session(
          accessToken: 'token',
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: 'refresh',
          user: mockUser,
        );

        final authState = AuthState(AuthChangeEvent.signedIn, mockSession);
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.value(authState));

        // Wait for the provider to be ready
        await container.read(currentUserProvider.future);

        // Act
        final uiState = container.read(authUIStateProvider);

        // Assert
        expect(uiState, equals(AuthUIState.signedIn));
      });

      test('should return signedOut when user is not authenticated', () async {
        // Arrange
        final authState = AuthState(AuthChangeEvent.signedOut, null);
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.value(authState));

        // Wait for the provider to be ready
        await container.read(currentUserProvider.future);

        // Act
        final uiState = container.read(authUIStateProvider);

        // Assert
        expect(uiState, equals(AuthUIState.signedOut));
      });

      test('should return loading while stream is loading', () {
        // Arrange
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.fromFuture(
                  Future.delayed(const Duration(seconds: 1))
                      .then((_) => AuthState(AuthChangeEvent.signedOut, null)),
                ));

        // Act
        final uiState = container.read(authUIStateProvider);

        // Assert
        expect(uiState, equals(AuthUIState.loading));
      });

      test('should return error on stream error', () async {
        // Arrange
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => Stream.error(Exception('Auth error')));

        // Act - Wait for the error state to propagate
        try {
          await container.read(currentUserProvider.future);
        } catch (e) {
          // Expected to throw
        }

        final uiState = container.read(authUIStateProvider);

        // Assert
        expect(uiState, equals(AuthUIState.error));
      });
    });

    group('authControllerProvider', () {
      test('should provide AuthController instance', () {
        // Act
        final controller = container.read(authControllerProvider);

        // Assert
        expect(controller, isA<AuthController>());
      });
    });

    group('AuthController', () {
      late AuthController controller;

      setUp(() {
        controller = AuthController(mockAuthService);
      });

      test('signUp should delegate to AuthService', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const fullName = 'Test User';

        final mockResponse = AuthResponse(
          session: Session(
            accessToken: 'token',
            tokenType: 'bearer',
            expiresIn: 3600,
            refreshToken: 'refresh',
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

        when(mockAuthService.signUp(
          email: email,
          password: password,
          fullName: fullName,
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await controller.signUp(
          email: email,
          password: password,
          fullName: fullName,
        );

        // Assert
        expect(result, equals(mockResponse));
        verify(mockAuthService.signUp(
          email: email,
          password: password,
          fullName: fullName,
        )).called(1);
      });

      test('signIn should delegate to AuthService', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        final mockResponse = AuthResponse(
          session: Session(
            accessToken: 'token',
            tokenType: 'bearer',
            expiresIn: 3600,
            refreshToken: 'refresh',
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

        when(mockAuthService.signIn(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await controller.signIn(
          email: email,
          password: password,
        );

        // Assert
        expect(result, equals(mockResponse));
        verify(mockAuthService.signIn(
          email: email,
          password: password,
        )).called(1);
      });

      test('signOut should delegate to AuthService', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async {});

        // Act
        await controller.signOut();

        // Assert
        verify(mockAuthService.signOut()).called(1);
      });

      test('signInWithGoogle should delegate to AuthService', () async {
        // Arrange
        when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => true);

        // Act
        final result = await controller.signInWithGoogle();

        // Assert
        expect(result, isTrue);
        verify(mockAuthService.signInWithGoogle()).called(1);
      });

      test('resetPassword should delegate to AuthService', () async {
        // Arrange
        const email = 'test@example.com';
        when(mockAuthService.resetPassword(email)).thenAnswer((_) async {});

        // Act
        await controller.resetPassword(email);

        // Assert
        verify(mockAuthService.resetPassword(email)).called(1);
      });

      test('updateProfile should delegate to AuthService', () async {
        // Arrange
        const fullName = 'Updated Name';
        const avatarUrl = 'https://example.com/avatar.jpg';

        when(mockAuthService.updateProfile(
          fullName: fullName,
          avatarUrl: avatarUrl,
        )).thenAnswer((_) async => throw UnimplementedError('Mocked'));

        // Act & Assert
        expect(
          () => controller.updateProfile(fullName: fullName, avatarUrl: avatarUrl),
          throwsA(isA<UnimplementedError>()),
        );
        
        verify(mockAuthService.updateProfile(
          fullName: fullName,
          avatarUrl: avatarUrl,
        )).called(1);
      });
    });
  });
}