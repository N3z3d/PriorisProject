import 'package:meta/meta.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/infrastructure/security/signup_guard.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service d'authentification avec Supabase.
class AuthService {
  static AuthService? _instance;
  static AuthService get instance =>
      _instance ??= AuthService._internal(
        supabaseService: SupabaseService.instance,
        logger: LoggerService.instance,
      );

  @visibleForTesting
  static void configureForTesting({
    required SupabaseService supabaseService,
    LoggerService? logger,
  }) {
    _instance = AuthService._internal(
      supabaseService: supabaseService,
      logger: logger ?? LoggerService.instance,
    );
  }

  AuthService._internal({
    required SupabaseService supabaseService,
    required LoggerService logger,
  })  : _supabase = supabaseService,
        _logger = logger;

  final SupabaseService _supabase;
  final LoggerService _logger;

  /// Utilisateur actuellement connecte.
  User? get currentUser => _supabase.currentUser;

  /// Flux des changements d'etat d'authentification.
  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;

  /// Indique si un utilisateur est connecte.
  bool get isSignedIn => currentUser != null;

  /// Inscription email / mot de passe avec garde anti-bot.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    SignupAttemptMetadata metadata = const SignupAttemptMetadata(),
  }) async {
    _logger.info('Debut inscription', context: 'AuthService.signUp');
    _logger.debug('Email candidat: $email', context: 'AuthService.signUp');

    try {
      await SignupGuard.instance.ensureCanSignUp(metadata);

      final config = AppConfig.instance;
      _logger.debug('URL Supabase: ${config.supabaseUrl}', context: 'AuthService.signUp');

      final isOffline = AppConfig.shouldEnableOfflineOnlyMode(config.supabaseUrl);
      _logger.info('Mode hors ligne detecte: $isOffline', context: 'AuthService.signUp');
      if (isOffline) {
        _logger.warning('Inscription bloquee: mode hors ligne actif', context: 'AuthService.signUp');
        throw Exception(
          'Registration unavailable in offline mode. Please configure real Supabase credentials in .env file to enable online features.',
        );
      }

      _logger.info('Tentative d\'inscription Supabase', context: 'AuthService.signUp');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null) {
        _logger.info('Inscription reussie pour ${response.user!.id}', context: 'AuthService.signUp');
      } else {
        _logger.warning('Inscription sans utilisateur retourne', context: 'AuthService.signUp');
      }

      await SignupGuard.instance.recordSuccessfulSignup();
      return response;
    } on SignupThrottledException {
      rethrow;
    } catch (error, stack) {
      _logger.error(
        'Erreur lors de l\'inscription',
        context: 'AuthService.signUp',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Connexion email / mot de passe.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _logger.info('Debut connexion', context: 'AuthService.signIn');
    _logger.debug('Email: $email', context: 'AuthService.signIn');

    try {
      final config = AppConfig.instance;
      _logger.debug('URL Supabase: ${config.supabaseUrl}', context: 'AuthService.signIn');
      final anonKey = config.supabaseAnonKey;
      final maskedKey = anonKey.length > 20 ? '${anonKey.substring(0, 20)}...' : '$anonKey...';
      _logger.debug('Cle anonyme tronquee: $maskedKey', context: 'AuthService.signIn');

      final isOffline = AppConfig.shouldEnableOfflineOnlyMode(config.supabaseUrl);
      _logger.info('Mode hors ligne detecte: $isOffline', context: 'AuthService.signIn');
      if (isOffline) {
        _logger.warning('Connexion bloquee: mode hors ligne actif', context: 'AuthService.signIn');
        throw Exception(
          'Authentication unavailable in offline mode. Please configure real Supabase credentials in .env file to enable online features.',
        );
      }

      _logger.info('Tentative de connexion Supabase', context: 'AuthService.signIn');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _logger.info('Connexion reussie pour ${response.user!.id}', context: 'AuthService.signIn');
        _logger.debug('Session valide: ${response.session != null}', context: 'AuthService.signIn');
      } else {
        _logger.warning('Connexion sans utilisateur retourne', context: 'AuthService.signIn');
      }

      return response;
    } catch (error, stack) {
      _logger.error(
        'Erreur lors de la connexion',
        context: 'AuthService.signIn',
        error: error,
        stackTrace: stack,
      );

      final message = error.toString();
      if (message.contains('AuthRetryableFetchException')) {
        _logger.error(
          'AuthRetryableFetchException detectee - verifier la connectivite',
          context: 'AuthService.signIn',
          error: error,
          stackTrace: stack,
        );
        _logger.error('URL utilisee: ${AppConfig.instance.supabaseUrl}', context: 'AuthService.signIn');
      }

      rethrow;
    }
  }

  /// Connexion OAuth (Google).
  Future<bool> signInWithGoogle() async {
    try {
      final redirect = AppConfig.instance.supabaseAuthRedirectUrl;
      return await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirect,
      );
    } catch (error, stack) {
      _logger.error('Erreur OAuth Google', context: 'AuthService.signInWithGoogle', error: error, stackTrace: stack);
      return false;
    }
  }

  /// Deconnexion utilisateur.
  Future<void> signOut() async {
    _logger.info('Debut deconnexion', context: 'AuthService.signOut');

    try {
      final currentUserId = currentUser?.id;
      if (currentUserId != null) {
        _logger.info('Deconnexion de l\'utilisateur: $currentUserId', context: 'AuthService.signOut');
      } else {
        _logger.info('Aucun utilisateur a deconnecter', context: 'AuthService.signOut');
      }

      await _supabase.auth.signOut();
      _logger.info('Deconnexion reussie', context: 'AuthService.signOut');
    } catch (error, stack) {
      _logger.error(
        'Erreur lors de la deconnexion',
        context: 'AuthService.signOut',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Demande de reinitialisation de mot de passe.
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConfig.instance.supabaseAuthRedirectUrl,
    );
  }

  /// Mise a jour du profil utilisateur.
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          if (fullName != null) 'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ),
    );

    return response;
  }

  /// Token JWT en cours.
  String? get currentToken => _supabase.auth.currentSession?.accessToken;

  /// Session valide (non expiree).
  bool get hasValidSession {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    return session.expiresAt != null && session.expiresAt! > now;
  }

  /// Rafraichit la session.
  Future<AuthResponse> refreshSession() async {
    return _supabase.auth.refreshSession();
  }
}
