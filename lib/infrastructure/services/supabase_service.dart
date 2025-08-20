import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

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
      
      print('✅ Supabase initialisé avec succès');
      if (config.isDebugMode) {
        print('🔧 Mode debug activé');
        config.printConfigurationInfo();
      }
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation de Supabase: $e');
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