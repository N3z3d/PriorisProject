import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Configuration centralisée de l'application
/// Gère le chargement et l'accès aux variables d'environnement
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();
  
  AppConfig._();
  
  /// Initialise la configuration en chargeant les variables d'environnement
  static Future<void> initialize({String? environment}) async {
    try {
      // Charge simplement le fichier .env principal
      await dotenv.load(fileName: '.env');
      
      // Valide que les variables critiques sont présentes
      _validateConfiguration();
      
      LoggerService.instance.info('Configuration chargée depuis: .env', context: 'AppConfig');
    } catch (e) {
      LoggerService.instance.error('Erreur lors du chargement de la configuration', context: 'AppConfig', error: e);
      throw ConfigurationException('Impossible de charger la configuration: $e');
    }
  }
  
  /// Valide que toutes les variables d'environnement critiques sont présentes
  static void _validateConfiguration() {
    final requiredVars = ['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_AUTH_REDIRECT_URL'];
    final missingVars = <String>[];
    
    for (final variable in requiredVars) {
      if (!dotenv.env.containsKey(variable) || dotenv.env[variable]?.trim().isEmpty == true) {
        missingVars.add(variable);
      }
    }
    
    if (missingVars.isNotEmpty) {
      throw ConfigurationException(
        'Variables d\'environnement manquantes: ${missingVars.join(', ')}'
      );
    }
  }
  
  // === Getters pour les variables d'environnement ===
  
  /// URL du projet Supabase
  String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    if (url.isEmpty) {
      throw ConfigurationException('SUPABASE_URL non configurée');
    }
    return url;
  }
  
  /// Clé anonyme Supabase
  String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    if (key.isEmpty) {
      throw ConfigurationException('SUPABASE_ANON_KEY non configurée');
    }
    return key;
  }
  
  /// URL de redirection pour l'authentification OAuth
  String get supabaseAuthRedirectUrl {
    final url = dotenv.env['SUPABASE_AUTH_REDIRECT_URL']?.trim() ?? '';
    if (url.isEmpty) {
      throw ConfigurationException('SUPABASE_AUTH_REDIRECT_URL non configurée');
    }
    return url;
  }
  
  /// Environnement actuel
  String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  
  /// Mode debug
  bool get isDebugMode => (dotenv.env['DEBUG_MODE'] ?? 'false').toLowerCase() == 'true';
  
  /// Vérifie si on est en mode production
  bool get isProduction => environment.toLowerCase() == 'production';
  
  /// Vérifie si on est en mode développement
  bool get isDevelopment => environment.toLowerCase() == 'development';
  
  /// Affiche les informations de configuration (sans les clés sensibles)
  void printConfigurationInfo() {
    LoggerService.instance.info('Configuration App', context: 'AppConfig');
    LoggerService.instance.debug('Environnement: $environment', context: 'AppConfig');
    LoggerService.instance.debug('Mode debug: $isDebugMode', context: 'AppConfig');
    LoggerService.instance.debug('URL Supabase: ${_maskSensitiveData(supabaseUrl)}', context: 'AppConfig');
    LoggerService.instance.debug('Clé anonyme: ${_maskSensitiveData(supabaseAnonKey)}', context: 'AppConfig');
    LoggerService.instance.debug('Redirect URL: ${_maskSensitiveData(supabaseAuthRedirectUrl)}', context: 'AppConfig');
  }
  
  /// Masque les données sensibles pour les logs
  String _maskSensitiveData(String data) {
    if (data.length <= 8) return '****';
    return '${data.substring(0, 4)}...${data.substring(data.length - 4)}';
  }
}

/// Exception levée lors d'erreurs de configuration
class ConfigurationException implements Exception {
  final String message;
  const ConfigurationException(this.message);
  
  @override
  String toString() => 'ConfigurationException: $message';
}