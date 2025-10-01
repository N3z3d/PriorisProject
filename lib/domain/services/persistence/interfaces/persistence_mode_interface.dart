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

/// Interface for managing persistence modes and authentication state
abstract class IPersistenceModeManager {
  /// Get current persistence mode
  PersistenceMode get currentMode;

  /// Get current authentication state
  bool get isAuthenticated;

  /// Initialize with authentication state
  Future<void> initialize({required bool isAuthenticated});

  /// Update authentication state and handle mode transition
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  });

  /// Stream of mode changes for reactive programming
  Stream<PersistenceMode> get modeChanges;

  /// Stream of authentication state changes
  Stream<bool> get authStateChanges;
}

/// Interface for data migration between persistence modes
abstract class IDataMigrationService {
  /// Migrate from guest (local) to authenticated (cloud) mode
  Future<void> migrateGuestToAuthenticated(MigrationStrategy strategy);

  /// Migrate from authenticated (cloud) to guest (local) mode
  Future<void> migrateAuthenticatedToGuest();

  /// Get migration progress for UI feedback
  Stream<MigrationProgress> get migrationProgress;

  /// Check if migration is currently in progress
  bool get isMigrating;
}

/// Progress information for data migration
class MigrationProgress {
  final int totalItems;
  final int completedItems;
  final String currentOperation;
  final bool isComplete;
  final String? errorMessage;

  const MigrationProgress({
    required this.totalItems,
    required this.completedItems,
    required this.currentOperation,
    required this.isComplete,
    this.errorMessage,
  });

  double get progressPercentage =>
      totalItems > 0 ? (completedItems / totalItems * 100) : 0.0;
}

/// Interface for handling persistence errors
abstract class IPersistenceErrorHandler {
  /// Handle cloud permission errors gracefully
  void handleCloudPermissionError(String operation, String id, dynamic error);

  /// Sanitize error messages for user display
  String sanitizeErrorMessage(String error);

  /// Log permission errors for monitoring
  void logPermissionError(String operation, String id, String error);

  /// Check if error is recoverable
  bool isRecoverableError(dynamic error);

  /// Get user-friendly error message
  String getUserFriendlyMessage(dynamic error);
}