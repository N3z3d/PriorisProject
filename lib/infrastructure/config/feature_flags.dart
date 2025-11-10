/// Feature flags for runtime configuration
///
/// Controls persistence strategy and experimental features
class FeatureFlags {
  /// Persistence mode for habits data
  ///
  /// Values:
  /// - `local`: Use Hive/in-memory storage (default, no network calls)
  /// - `supabase`: Use Supabase cloud storage (requires auth)
  ///
  /// Default: `local` to prevent network loops and ensure offline-first UX
  static const String habitsPersistence = String.fromEnvironment(
    'HABITS_PERSISTENCE',
    defaultValue: 'local',
  );

  /// Check if Supabase persistence is enabled for habits
  static bool get isSupabasePersistenceEnabled =>
      habitsPersistence.toLowerCase() == 'supabase';

  /// Check if local persistence is enabled for habits (default)
  static bool get isLocalPersistenceEnabled =>
      habitsPersistence.toLowerCase() == 'local';

  /// Validate feature flag values
  static void validateFlags() {
    final validModes = ['local', 'supabase'];
    if (!validModes.contains(habitsPersistence.toLowerCase())) {
      throw ArgumentError(
        'Invalid HABITS_PERSISTENCE value: "$habitsPersistence". '
        'Must be one of: ${validModes.join(", ")}',
      );
    }
  }

  /// Log current feature flag configuration
  static void logConfiguration() {
    print('[FeatureFlags] I: HABITS_PERSISTENCE = $habitsPersistence');
    print('[FeatureFlags] I: Supabase enabled = $isSupabasePersistenceEnabled');
    print('[FeatureFlags] I: Local enabled = $isLocalPersistenceEnabled');
  }
}
