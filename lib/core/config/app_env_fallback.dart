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
    'SUPABASE_URL': 'https://huxddyqkjczckagkpzef.supabase.co',
    'SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1eGRkeXFramN6Y2thZ2twemVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzNzk3NDgsImV4cCI6MjA0OTk1NTc0OH0.xVDGWsF5x1gMX_-c1qPKmzAHXv0IMLl2u3vppRMbaBs',
    'SUPABASE_AUTH_REDIRECT_URL': 'http://localhost:3000/auth/callback',
    'ENVIRONMENT': 'development',
    'DEBUG_MODE': 'true',
  };
}