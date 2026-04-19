import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/infrastructure/services/web_auth_callback_stabilizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service d'initialisation et d'acces Supabase.
class SupabaseService {
  SupabaseService._();

  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  static set instance(SupabaseService service) {
    _instance = service;
  }

  /// Initialise Supabase a partir de la configuration applicative.
  static Future<void> initialize() async {
    try {
      final config = AppConfig.instance;

      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
        debug: config.isDebugMode,
      );

      final callbackSessionStabilized =
          await WebAuthCallbackStabilizer.stabilizeIfNeeded(
        supabaseUrl: config.supabaseUrl,
        session: Supabase.instance.client.auth.currentSession,
      );

      LoggerService.instance
          .info('Supabase initialise', context: 'SupabaseService');
      if (callbackSessionStabilized) {
        LoggerService.instance.info(
          'Session de callback web stabilisee avant le bootstrap UI',
          context: 'SupabaseService',
        );
      }
      if (config.isDebugMode) {
        LoggerService.instance
            .debug('Mode debug actif', context: 'SupabaseService');
        config.printConfigurationInfo();
      }
    } catch (error, stack) {
      LoggerService.instance.error(
        'Erreur lors de l\'initialisation Supabase',
        context: 'SupabaseService',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Client Supabase principal.
  SupabaseClient get client => Supabase.instance.client;

  /// Client d'authentification.
  GoTrueClient get auth => client.auth;

  /// Alias base de donnees (identique a [client]).
  SupabaseClient get database => client;

  /// Utilisateur courant.
  User? get currentUser => auth.currentUser;

  /// Flux des changements d'etat d'authentification.
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}
