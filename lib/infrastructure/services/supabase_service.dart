import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import 'logger_service.dart';

/// Service de configuration et gestion Supabase
/// Utilise maintenant les variables d'environnement pour la sécurité
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  /// Initialise Supabase avec les variables d'environnement
  static Future<void> initialize() async {
    try {
      final config = AppConfig.instance;
      
      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
        debug: config.isDebugMode,
      );
      
      LoggerService.instance.info('Supabase initialisé avec succès', context: 'SupabaseService');
      if (config.isDebugMode) {
        LoggerService.instance.debug('Mode debug activé', context: 'SupabaseService');
        config.printConfigurationInfo();
      }
    } catch (e) {
      LoggerService.instance.error('Erreur lors de l\'initialisation de Supabase', context: 'SupabaseService', error: e);
      rethrow;
    }
  }
  
  /// Client Supabase global
  SupabaseClient get client => Supabase.instance.client;
  
  /// Client auth
  GoTrueClient get auth => client.auth;
  
  /// Base de données  
  SupabaseClient get database => client;
  
  /// Utilisateur actuel
  User? get currentUser => auth.currentUser;
  
  /// Stream des changements d'auth
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}