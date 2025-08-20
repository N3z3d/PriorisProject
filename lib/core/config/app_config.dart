import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      
      print('✅ Configuration chargée depuis: .env');
    } catch (e) {
      print('❌ Erreur lors du chargement de la configuration: $e');
      throw ConfigurationException('Impossible de charger la configuration: $e');
    }
  }
  
  /// Valide que toutes les variables d'environnement critiques sont présentes
  static void _validateConfiguration() {
    final requiredVars = ['SUPABASE_URL', 'SUPABASE_ANON_KEY'];
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
    print('=== Configuration App ===');
    print('Environnement: $environment');
    print('Mode debug: $isDebugMode');
    print('URL Supabase: ${_maskSensitiveData(supabaseUrl)}');
    print('Clé anonyme: ${_maskSensitiveData(supabaseAnonKey)}');
    print('========================');
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