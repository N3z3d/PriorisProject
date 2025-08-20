import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';

/// Service d'authentification avec Supabase
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();
  
  final _supabase = SupabaseService.instance;
  
  /// Utilisateur connecté
  User? get currentUser => _supabase.currentUser;
  
  /// Stream des changements d'authentification
  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;
  
  /// Vérifie si un utilisateur est connecté
  bool get isSignedIn => currentUser != null;
  
  /// Inscription par email/mot de passe
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Connexion par email/mot de passe
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Connexion avec Google (optionnel)
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://vgowxrktjzgwrfivtvse.supabase.co/auth/v1/callback',
      );
      
      return response;
    } catch (e) {
      // TODO: Remplacer par un logger approprié
      return false;
    }
  }
  
  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Réinitialisation de mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://vgowxrktjzgwrfivtvse.supabase.co/auth/v1/callback',
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mise à jour du profil utilisateur
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (fullName != null) 'full_name': fullName,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Obtenir le token JWT actuel
  String? get currentToken => _supabase.auth.currentSession?.accessToken;
  
  /// Vérifier si la session est valide
  bool get hasValidSession {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    return session.expiresAt != null && session.expiresAt! > now;
  }
  
  /// Rafraîchir la session
  Future<AuthResponse> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}