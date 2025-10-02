/// Persistence Interfaces
/// Defines contracts for persistence-related services
/// Follows Interface Segregation Principle (ISP) and Dependency Inversion Principle (DIP)

import 'dart:async';
import '../../domain/models/core/entities/custom_list.dart';
import '../../domain/models/core/entities/list_item.dart';

/// Persistence mode enum
/// Defines whether to prioritize local or cloud storage
enum PersistenceMode {
  /// Prioritize local storage (offline-first mode)
  localFirst,

  /// Prioritize cloud storage (cloud-first mode)
  cloudFirst,
}

/// Migration strategy enum
/// Defines how to handle data migration between local and cloud
enum MigrationStrategy {
  /// Migrate all local data to cloud
  migrateAll,

  /// Ask user what to do with conflicts
  askUser,

  /// Use only cloud data, discard local
  cloudOnly,

  /// Intelligently merge local and cloud data based on timestamps
  intelligentMerge,
}

/// Interface for authentication state management
/// Single Responsibility: Manage authentication state transitions only
abstract class IAuthenticationStateManager {
  /// Current authentication status
  bool get isAuthenticated;

  /// Current persistence mode
  PersistenceMode get currentMode;

  /// Stream of authentication state changes
  Stream<bool> get authenticationStateStream;

  /// Update authentication state
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  });
}

/// Interface for data migration service
/// Single Responsibility: Handle data migration between local and cloud storage
abstract class IDataMigrationService {
  /// Migrate local data to cloud
  Future<void> migrateToCloud({
    required MigrationStrategy strategy,
    required List<CustomList> localLists,
  });

  /// Migrate cloud data to local
  Future<void> migrateToLocal({
    required List<CustomList> cloudLists,
  });

  /// Resolve conflict between local and cloud lists
  CustomList resolveListConflict(CustomList local, CustomList cloud);

  /// Resolve conflict between existing and incoming items
  ListItem resolveItemConflict(ListItem existing, ListItem incoming);
}

/// Interface for deduplication service
/// Single Responsibility: Handle data deduplication and conflict resolution
abstract class IDeduplicationService {
  /// Deduplicate a list of CustomLists by ID
  List<CustomList> deduplicateLists(List<CustomList> lists);

  /// Save list with deduplication strategy (handle ID conflicts)
  Future<void> saveListWithDeduplication(
    CustomList list,
    Future<void> Function(CustomList) saveOperation,
    Future<CustomList?> Function(String) getExistingOperation,
    Future<void> Function(CustomList) updateOperation,
  );

  /// Save item with deduplication strategy (handle ID conflicts)
  Future<void> saveItemWithDeduplication(
    ListItem item,
    Future<void> Function(ListItem) addOperation,
    Future<ListItem?> Function(String) getByIdOperation,
    Future<void> Function(ListItem) updateOperation,
  );
}

/// Custom exception for persistence errors
class PersistenceException implements Exception {
  final String message;
  final String? operation;
  final Object? cause;

  PersistenceException(
    this.message, {
    this.operation,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PersistenceException: $message');
    if (operation != null) {
      buffer.write(' (operation: $operation)');
    }
    if (cause != null) {
      buffer.write(' [caused by: $cause]');
    }
    return buffer.toString();
  }
}
