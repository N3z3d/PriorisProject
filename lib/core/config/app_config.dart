import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/core/exceptions/app_exception.dart';

import 'app_env_fallback.dart';

/// Configuration centralisée de l'application
/// Gère le chargement et l'accès aux variables d'environnement
class AppConfig {
  AppConfig._();
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();

  static final Map<String, String> _resolvedEnv = <String, String>{};
  static bool _fallbackApplied = false;

  static const List<String> _requiredVars = [
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
    'SUPABASE_AUTH_REDIRECT_URL',
  ];

  /// Initialise la configuration en mode "offline-first".
  ///
  /// - Tente de charger `.env` s'il est disponible (sans l'exiger).
  /// - Ne lève pas d'exception si le fichier est absent ou incomplet.
  /// - La disponibilité Supabase sera évaluée par `ConfigurationStateService`.
  static Future<void> initializeOfflineFirst({String? environment}) async {
    var rawEnv = <String, String>{};
    bool dotenvLoaded = false;

    try {
      await dotenv.load(fileName: '.env');
      dotenvLoaded = true;
    } catch (_) {
      LoggerService.instance.info(
        'Aucun fichier .env détecté - utilisation des valeurs de secours si disponibles',
        context: 'AppConfig',
      );
    }

    // Add loaded values to resolved env if dotenv was loaded successfully
    if (dotenvLoaded) {
      try {
        rawEnv = Map<String, String>.from(dotenv.env)
            .map((key, value) => MapEntry(key, value.trim()));
        _resolvedEnv.addAll(rawEnv);
      } catch (e) {
        LoggerService.instance.debug(
          'Error accessing dotenv after load: $e',
          context: 'AppConfig',
        );
        dotenvLoaded = false;
      }
    }

    _hydrateResolvedEnv(allowFallback: true);

    if (rawEnv.isNotEmpty) {
      try {
        _validateConfiguration(sourceEnv: rawEnv, allowFallback: false);
        LoggerService.instance
            .info('Configuration chargée depuis: .env', context: 'AppConfig');
      } catch (e) {
        LoggerService.instance.warning(
          'Configuration .env incomplète (mode hors ligne activé): $e',
          context: 'AppConfig',
        );
      }
    } else if (_fallbackApplied) {
      LoggerService.instance.info(
        'Configuration Supabase chargée depuis le fallback de développement',
        context: 'AppConfig',
      );
    }
  }

  /// Initialise la configuration en chargeant les variables d'environnement
  static Future<void> initialize({String? environment}) async {
    try {
      await dotenv.load(fileName: '.env');
      // Safely access dotenv only after successful load
      Map<String, String> rawEnv = {};
      try {
        rawEnv = Map<String, String>.from(dotenv.env)
            .map((key, value) => MapEntry(key, value.trim()));
        _resolvedEnv.addAll(rawEnv);
      } catch (e) {
        LoggerService.instance.debug(
          'Error accessing dotenv after load: $e',
          context: 'AppConfig',
        );
        // Continue with empty rawEnv
      }
      _hydrateResolvedEnv(allowFallback: false);
      _validateConfiguration(sourceEnv: rawEnv, allowFallback: false);

      LoggerService.instance
          .info('Configuration chargée depuis: .env', context: 'AppConfig');
    } catch (e) {
      LoggerService.instance.warning(
        'Fichier .env non trouvé, utilisation des valeurs de fallback',
        context: 'AppConfig',
      );

      // Use fallback values for development
      _hydrateResolvedEnv(allowFallback: true);
      _validateConfiguration(sourceEnv: AppEnvFallback.values, allowFallback: true);

      LoggerService.instance.info(
        'Configuration chargée depuis: fallback values',
        context: 'AppConfig'
      );
    }
  }

  static void _hydrateResolvedEnv({required bool allowFallback}) {
    // Store current values before clearing if they exist
    final currentValues = Map<String, String>.from(_resolvedEnv);
    _resolvedEnv.clear();

    // Restore values that were loaded from dotenv
    if (currentValues.isNotEmpty) {
      _resolvedEnv.addAll(currentValues);
    }

    _fallbackApplied = false;

    if (!allowFallback) {
      return;
    }

    if (AppEnvFallback.isEnabled && AppEnvFallback.hasValidValues) {
      for (final entry in AppEnvFallback.values.entries) {
        final current = _resolvedEnv[entry.key];
        if (current == null || current.trim().isEmpty) {
          _resolvedEnv[entry.key] = entry.value;
          _fallbackApplied = true;
        }
      }

      if (_fallbackApplied) {
        LoggerService.instance.debug(
          'Valeurs .env de secours appliquées (mode debug)',
          context: 'AppConfig',
        );
      }
    }
  }

  static Map<String, String> _snapshotEnv(Map<String, String> env) {
    return env.map((key, value) => MapEntry(key, value.trim()));
  }

  static void _validateConfiguration({
    required Map<String, String> sourceEnv,
    required bool allowFallback,
  }) {
    final missingVars = <String>[];

    for (final variable in _requiredVars) {
      final value = sourceEnv[variable]?.trim() ?? '';
      if (value.isEmpty) {
        if (allowFallback &&
            (_resolvedEnv[variable]?.trim().isNotEmpty ?? false)) {
          continue;
        }
        missingVars.add(variable);
      }
    }

    if (missingVars.isNotEmpty) {
      throw ConfigurationException(
        'Variables d\'environnement manquantes: ${missingVars.join(', ')}',
      );
    }

    final activeEnv = allowFallback ? _resolvedEnv : sourceEnv;
    final url = activeEnv['SUPABASE_URL']?.trim() ?? '';
    final key = activeEnv['SUPABASE_ANON_KEY']?.trim() ?? '';

    try {
      validateSupabaseUrl(url);
      validateSupabaseKey(key);
    } catch (e) {
      if (e is AppException) {
        LoggerService.instance.warning(
          'Configuration Supabase détectée comme placeholder - Mode hors ligne activé',
          context: 'AppConfig',
        );
        LoggerService.instance.info(
          'Pour utiliser Supabase: 1) Créez un projet sur supabase.com 2) Remplacez les valeurs dans .env',
          context: 'AppConfig',
        );
      }
    }
  }

  // === Getters pour les variables d'environnement ===

  /// URL du projet Supabase
  String get supabaseUrl {
    final url = _getOptionalEnvValue('SUPABASE_URL');
    if (url == null) {
      throw const ConfigurationException('SUPABASE_URL non configurée');
    }
    return url;
  }

  /// Clé anonyme Supabase
  String get supabaseAnonKey {
    final key = _getOptionalEnvValue('SUPABASE_ANON_KEY');
    if (key == null) {
      throw const ConfigurationException('SUPABASE_ANON_KEY non configurée');
    }
    return key;
  }

  /// URL de redirection pour l'authentification OAuth
  String get supabaseAuthRedirectUrl {
    final url = _getOptionalEnvValue('SUPABASE_AUTH_REDIRECT_URL');
    if (url == null) {
      throw const ConfigurationException(
        'SUPABASE_AUTH_REDIRECT_URL non configurée',
      );
    }
    return url;
  }

  String get environment =>
      _getOptionalEnvValue('ENVIRONMENT') ?? 'development';

  bool get isDebugMode =>
      (_getOptionalEnvValue('DEBUG_MODE') ?? 'false').toLowerCase() == 'true';

  @visibleForTesting
  static void setTestEnvironment(Map<String, String> values) {
    _instance = null;
    _resolvedEnv
      ..clear()
      ..addEntries(
        values.entries.map(
          (entry) => MapEntry(entry.key, entry.value.trim()),
        ),
      );
    _fallbackApplied = false;
  }

  static String? _getOptionalEnvValue(String key) {
    final value = _resolvedEnv[key]?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  void printConfigurationInfo() {
    LoggerService.instance
        .debug('ENVIRONMENT: $environment', context: 'AppConfig');
    LoggerService.instance
        .debug('Mode debug: $isDebugMode', context: 'AppConfig');
    if (_fallbackApplied) {
      LoggerService.instance.debug(
        'Configuration chargée depuis les valeurs fallback de développement',
        context: 'AppConfig',
      );
    }
    LoggerService.instance.debug(
        'URL Supabase: ${_maskSensitiveData(supabaseUrl)}',
        context: 'AppConfig');
    LoggerService.instance.debug(
        'Clé anonyme: ${_maskSensitiveData(supabaseAnonKey)}',
        context: 'AppConfig');
    LoggerService.instance.debug(
        'Redirect URL: ${_maskSensitiveData(supabaseAuthRedirectUrl)}',
        context: 'AppConfig');
  }

  /// Masque les données sensibles pour les logs
  String _maskSensitiveData(String data) {
    if (data.length <= 8) return '****';
    return '${data.substring(0, 4)}...${data.substring(data.length - 4)}';
  }

  // === Validation des configurations Supabase ===

  /// Valide qu'une URL Supabase n'est pas un placeholder
  static void validateSupabaseUrl(String url) {
    // Si c'est une vraie URL Supabase, pas de validation nécessaire
    if (url.contains('huxddyqkjczckagkpzef.supabase.co') ||
        url.contains('vgowxrktjzgwrfivtvse.supabase.co')) {
      return; // URL valide trouvée
    }

    // Liste des patterns de placeholder détectés
    final placeholderPatterns = [
      'your-project-id.supabase.co',
      'your-project.supabase.co',
      'example.supabase.co',
      'project-id.supabase.co',
      'localhost',
      'test.supabase.co',
    ];

    final lowercaseUrl = url.toLowerCase();

    for (final pattern in placeholderPatterns) {
      if (lowercaseUrl.contains(pattern)) {
        throw AppException.configuration(
          message:
              'URL Supabase placeholder détectée: $url (pattern: $pattern)',
          userMessage:
              'Please configure your real Supabase credentials. Visit https://supabase.com to create a project.',
          context: 'AppConfig.validateSupabaseUrl',
        );
      }
    }
  }

  /// Valide qu'une clé Supabase n'est pas un placeholder
  static void validateSupabaseKey(String key) {
    // Si c'est une vraie clé JWT Supabase, pas de validation nécessaire
    if (key.startsWith('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1eGRkeXFramN6Y2thZ2twemVm') ||
        key.startsWith('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnb3d4cmt0anpnd3JmaXZ0dnNl')) {
      return; // Clé valide trouvée
    }

    // Liste des patterns de placeholder détectés
    final placeholderPatterns = [
      'your-anon-key-here',
      'your-key-here',
      'anon-key-here',
      'example-key',
      'test-key',
      'dummy-key',
    ];

    final lowercaseKey = key.toLowerCase();

    for (final pattern in placeholderPatterns) {
      if (lowercaseKey.contains(pattern)) {
        throw AppException.configuration(
          message:
              'Clé Supabase placeholder détectée: ${key.substring(0, 12)}... (pattern: $pattern)',
          userMessage:
              'Please configure your real Supabase credentials. Visit https://supabase.com to get your anon key.',
          context: 'AppConfig.validateSupabaseKey',
        );
      }
    }

    // Valide que la clé a un format JWT basique (commence par eyJ)
    if (key.isNotEmpty && !key.startsWith('eyJ') && key.length > 10) {
      LoggerService.instance.warning(
          'Clé Supabase ne semble pas être un JWT valide',
          context: 'AppConfig.validateSupabaseKey');
    }
  }

  /// Détermine si l'application doit fonctionner en mode hors ligne uniquement
  static bool shouldEnableOfflineOnlyMode(String supabaseUrl) {
    try {
      validateSupabaseUrl(supabaseUrl);
      return false; // URL valide, peut utiliser Supabase
    } catch (e) {
      return true; // URL placeholder, utilise mode hors ligne
    }
  }

  /// Crée une configuration pour le mode hors ligne uniquement
  static OfflineOnlyConfig createOfflineOnlyConfig() {
    return OfflineOnlyConfig();
  }
}

/// Exception levée lors d'erreurs de configuration
class ConfigurationException implements Exception {
  const ConfigurationException(this.message);
  final String message;

  @override
  String toString() => 'ConfigurationException: $message';
}

/// Configuration pour le mode hors ligne uniquement
class OfflineOnlyConfig {
  /// Indique si l'application fonctionne en mode hors ligne uniquement
  bool get isOfflineOnly => true;

  /// Indique si Supabase peut être utilisé
  bool get canUseSupabase => false;

  /// Message à afficher à l'utilisateur
  String get displayMessage =>
      'Running in offline mode. To enable cloud sync, configure your Supabase credentials in .env file.';

  /// Instructions de configuration
  String get setupInstructions => '''
To enable cloud features:
1. Visit https://supabase.com and create a new project
2. Copy your project URL and anon key
3. Update .env file with your real credentials:
   SUPABASE_URL=https://your-real-project.supabase.co
   SUPABASE_ANON_KEY=your-real-anon-key

Current status: Using local storage only (Hive)
''';
}

