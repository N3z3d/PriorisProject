import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';

/// Provider pour le service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Provider pour l'utilisateur actuel
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  return authService.authStateChanges.map((state) => state.session?.user);
});

/// Provider pour l'état de connexion
final isSignedInProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// États d'authentification pour l'UI
enum AuthUIState {
  loading,
  signedOut,
  signedIn,
  error,
}

/// Provider pour l'état UI d'authentification
final authUIStateProvider = Provider<AuthUIState>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) => user != null ? AuthUIState.signedIn : AuthUIState.signedOut,
    loading: () => AuthUIState.loading,
    error: (_, __) => AuthUIState.error,
  );
});

/// Controller pour les actions d'authentification
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

/// Controller pour gérer les actions d'authentification
class AuthController {
  final AuthService _authService;
  
  AuthController(this._authService);
  
  /// Inscription
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
  
  /// Connexion
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signIn(
      email: email,
      password: password,
    );
  }
  
  /// Connexion Google
  Future<bool> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }
  
  /// Déconnexion
  Future<void> signOut() async {
    await _authService.signOut();
  }
  
  /// Réinitialisation mot de passe
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
  
  /// Mise à jour profil
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    return await _authService.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}