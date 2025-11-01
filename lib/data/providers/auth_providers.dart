import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/infrastructure/security/signup_guard.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider pour le service d'authentification.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Provider pour l'utilisateur actuel.
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((state) => state.session?.user);
});

/// Provider pour l'etat de connexion.
final isSignedInProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider pour l'etat d'authentification.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Etats d'authentification pour l'UI.
enum AuthUIState {
  loading,
  signedOut,
  signedIn,
  error,
}

/// Provider pour l'etat UI d'authentification.
final authUIStateProvider = Provider<AuthUIState>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user != null ? AuthUIState.signedIn : AuthUIState.signedOut,
    loading: () => AuthUIState.loading,
    error: (_, __) => AuthUIState.error,
  );
});

/// Controller pour les actions d'authentification.
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

/// Controller pour gerer les actions d'authentification.
class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  /// Inscription.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    SignupAttemptMetadata metadata = const SignupAttemptMetadata(),
  }) async {
    return _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      metadata: metadata,
    );
  }

  /// Connexion.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _authService.signIn(
      email: email,
      password: password,
    );
  }

  /// Connexion Google.
  Future<bool> signInWithGoogle() async {
    return _authService.signInWithGoogle();
  }

  /// Deconnexion.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Reinitialisation mot de passe.
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  /// Mise a jour du profil.
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    return _authService.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}
