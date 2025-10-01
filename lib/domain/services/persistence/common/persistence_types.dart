/// Mode de persistance adaptatif selon l'état d'authentification
enum PersistenceMode {
  /// Données stockées localement uniquement (utilisateur invité)
  localFirst,

  /// Données stockées en cloud avec backup local (utilisateur connecté)
  cloudFirst,

  /// Synchronisation intelligente entre local et cloud
  hybrid,
}

/// Stratégie de migration des données locales vers le cloud
enum MigrationStrategy {
  /// Migrer toutes les données locales vers le cloud
  migrateAll,

  /// Demander à l'utilisateur ce qu'il veut faire
  askUser,

  /// Garder uniquement les données cloud
  cloudOnly,

  /// Fusionner intelligemment les données
  intelligentMerge,
}

/// État de synchronisation
enum SyncStatus {
  /// Pas de synchronisation en cours
  idle,

  /// Synchronisation en cours
  syncing,

  /// Synchronisation réussie
  completed,

  /// Erreur de synchronisation
  failed,
}

/// Résultat d'une opération de persistance
class PersistenceResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final Duration? duration;

  const PersistenceResult({
    required this.success,
    this.data,
    this.error,
    this.duration,
  });

  factory PersistenceResult.success(T data, {Duration? duration}) {
    return PersistenceResult(
      success: true,
      data: data,
      duration: duration,
    );
  }

  factory PersistenceResult.failure(String error, {Duration? duration}) {
    return PersistenceResult<T>(
      success: false,
      error: error,
      duration: duration,
    );
  }
}

/// Configuration de persistance
class PersistenceConfig {
  final PersistenceMode mode;
  final bool enableAutoSync;
  final Duration syncInterval;
  final int maxRetries;
  final Duration retryDelay;

  const PersistenceConfig({
    this.mode = PersistenceMode.localFirst,
    this.enableAutoSync = true,
    this.syncInterval = const Duration(minutes: 5),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });
}