import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

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
    LoggerService.instance.info('📝 Début tentative d\'inscription', context: 'AuthService.signUp');
    LoggerService.instance.debug('Email: $email', context: 'AuthService.signUp');

    try {
      // Vérifier la configuration actuelle
      final config = AppConfig.instance;
      LoggerService.instance.debug('URL Supabase: ${config.supabaseUrl}', context: 'AuthService.signUp');

      // Vérifier si on est en mode offline
      final isOfflineMode = AppConfig.shouldEnableOfflineOnlyMode(config.supabaseUrl);
      LoggerService.instance.info('Mode offline détecté: $isOfflineMode', context: 'AuthService.signUp');

      if (isOfflineMode) {
        LoggerService.instance.warning('❌ Tentative d\'inscription bloquée - Mode offline activé', context: 'AuthService.signUp');
        throw Exception('Registration unavailable in offline mode. Please configure real Supabase credentials in .env file to enable online features.');
      }

      LoggerService.instance.info('✅ Configuration valide - Tentative d\'inscription Supabase', context: 'AuthService.signUp');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null) {
        LoggerService.instance.info('🎉 Inscription réussie pour l\'utilisateur: ${response.user!.id}', context: 'AuthService.signUp');
      } else {
        LoggerService.instance.warning('⚠️ Inscription sans utilisateur retourné', context: 'AuthService.signUp');
      }

      return response;
    } catch (e) {
      LoggerService.instance.error('❌ Erreur lors de l\'inscription: $e', context: 'AuthService.signUp', error: e);
      rethrow;
    }
  }
  
  /// Connexion par email/mot de passe
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    LoggerService.instance.info('🔐 Début tentative de connexion', context: 'AuthService.signIn');
    LoggerService.instance.debug('Email: $email', context: 'AuthService.signIn');

    try {
      // Vérifier la configuration actuelle
      final config = AppConfig.instance;
      LoggerService.instance.debug('URL Supabase: ${config.supabaseUrl}', context: 'AuthService.signIn');
      final key = config.supabaseAnonKey;
      final maskedKey = key.length > 20 ? '${key.substring(0, 20)}...' : '${key.substring(0, key.length)}...';
      LoggerService.instance.debug('Clé anonyme (tronquée): $maskedKey', context: 'AuthService.signIn');

      // Vérifier si on est en mode offline
      final isOfflineMode = AppConfig.shouldEnableOfflineOnlyMode(config.supabaseUrl);
      LoggerService.instance.info('Mode offline détecté: $isOfflineMode', context: 'AuthService.signIn');

      if (isOfflineMode) {
        LoggerService.instance.warning('❌ Tentative de connexion bloquée - Mode offline activé', context: 'AuthService.signIn');
        throw Exception('Authentication unavailable in offline mode. Please configure real Supabase credentials in .env file to enable online features.');
      }

      LoggerService.instance.info('✅ Configuration valide - Tentative de connexion Supabase', context: 'AuthService.signIn');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        LoggerService.instance.info('🎉 Connexion réussie pour l\'utilisateur: ${response.user!.id}', context: 'AuthService.signIn');
        LoggerService.instance.debug('Session valide: ${response.session != null}', context: 'AuthService.signIn');
      } else {
        LoggerService.instance.warning('⚠️ Connexion sans utilisateur retourné', context: 'AuthService.signIn');
      }

      return response;
    } catch (e) {
      LoggerService.instance.error('❌ Erreur lors de la connexion: $e', context: 'AuthService.signIn', error: e);
      LoggerService.instance.debug('Type d\'erreur: ${e.runtimeType}', context: 'AuthService.signIn');

      // Log supplémentaire pour les erreurs Supabase spécifiques
      if (e.toString().contains('AuthRetryableFetchException')) {
        LoggerService.instance.error('🔥 AuthRetryableFetchException détectée - Problème de réseau/configuration', context: 'AuthService.signIn');
        final config = AppConfig.instance;
        LoggerService.instance.error('URL utilisée: ${config.supabaseUrl}', context: 'AuthService.signIn');
      }

      rethrow;
    }
  }
  
  /// Connexion avec Google (optionnel)
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.instance.supabaseAuthRedirectUrl,
      );
      
      return response;
    } catch (e) {
      // Log OAuth error for debugging while preserving user experience
      LoggerService.instance.error('OAuth Google error', context: 'AuthService', error: e);
      return false;
    }
  }
  
  /// Déconnexion
  Future<void> signOut() async {
    LoggerService.instance.info('🚪 Début tentative de déconnexion', context: 'AuthService.signOut');

    try {
      final currentUserId = currentUser?.id;
      if (currentUserId != null) {
        LoggerService.instance.info('Déconnexion de l\'utilisateur: $currentUserId', context: 'AuthService.signOut');
      } else {
        LoggerService.instance.info('Aucun utilisateur connecté à déconnecter', context: 'AuthService.signOut');
      }

      await _supabase.auth.signOut();
      LoggerService.instance.info('✅ Déconnexion réussie', context: 'AuthService.signOut');
    } catch (e) {
      LoggerService.instance.error('❌ Erreur lors de la déconnexion: $e', context: 'AuthService.signOut', error: e);
      rethrow;
    }
  }
  
  /// Réinitialisation de mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: AppConfig.instance.supabaseAuthRedirectUrl,
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