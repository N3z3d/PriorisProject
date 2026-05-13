/// Valeurs de fallback pour le développement local
/// Ces valeurs sont utilisées uniquement quand le fichier .env est absent ou incomplet
class AppEnvFallback {
  static const bool _kEnabled = false; // DEV: Désactivé car vraies clés configurées

  /// Active les valeurs de fallback (uniquement en mode debug)
  static bool get isEnabled => _kEnabled;

  /// Vérifie si les valeurs de fallback sont valides
  static bool get hasValidValues => true; // DEV: Activé pour développement

  /// Valeurs de fallback pour le développement - ACTIVÉES POUR DEV
  static const Map<String, String> values = {
    'SUPABASE_URL': '',
    'SUPABASE_ANON_KEY': '',
    'SUPABASE_AUTH_REDIRECT_URL': '',
    'ENVIRONMENT': 'development',
    'DEBUG_MODE': 'true',
  };
}