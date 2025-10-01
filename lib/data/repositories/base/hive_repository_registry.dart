import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'package:prioris/data/providers/repository_providers.dart';

/// Legacy Hive Repository Registry for backward compatibility
///
/// SOLID: Single Responsibility - Manages Hive repository lifecycle
/// Clean Code: Provides clean interface for legacy compatibility
///
/// This class is a legacy wrapper around the new DI system.
/// New code should use RepositoryManager and DI container instead.
///
/// @deprecated Use DIContainer and RepositoryManager instead
@Deprecated('Use DIContainer and RepositoryManager instead')
class HiveRepositoryRegistry {
  static HiveRepositoryRegistry? _instance;

  HiveCustomListRepository? _customListRepository;
  HiveListItemRepository? _listItemRepository;
  bool _isInitialized = false;
  bool _isDisposed = false;

  HiveRepositoryRegistry._();

  /// Gets the singleton instance
  ///
  /// SOLID: Singleton pattern for global access
  /// Clean Code: Clear error handling with specific messages
  static HiveRepositoryRegistry get instance {
    if (_instance == null) {
      throw StateError(
        'HiveRepositoryRegistry not initialized. Call initialize() first.'
      );
    }
    if (_instance!._isDisposed) {
      throw StateError(
        'HiveRepositoryRegistry has been disposed. Cannot access instance.'
      );
    }
    return _instance!;
  }

  /// Initializes the repository registry
  ///
  /// SOLID: Factory method pattern for initialization
  /// Clean Code: Idempotent operation with clear state management
  static Future<void> initialize() async {
    if (_instance != null && !_instance!._isDisposed) {
      return; // Already initialized
    }

    _instance = HiveRepositoryRegistry._();
    await _instance!._initializeRepositories();
  }

  /// Disposes all repositories and clears the registry
  ///
  /// SOLID: Proper resource cleanup following disposal pattern
  /// Clean Code: Safe disposal with error handling
  static Future<void> dispose() async {
    if (_instance == null) return;

    await _instance!._dispose();
    _instance = null;
  }

  /// Whether the registry is initialized and ready to use
  ///
  /// SOLID: Clear state query method
  /// Clean Code: Simple boolean check with no side effects
  bool get isInitialized => _isInitialized && !_isDisposed;

  /// Gets the custom list repository
  ///
  /// SOLID: Lazy initialization with proper error handling
  /// Clean Code: Clear error messages and state validation
  CustomListRepository get customListRepository {
    _throwIfNotInitialized();

    if (_customListRepository == null) {
      throw StateError(
        'CustomListRepository not available. Registry initialization may have failed.'
      );
    }

    return _customListRepository!;
  }

  /// Gets the list item repository
  ///
  /// SOLID: Lazy initialization with proper error handling
  /// Clean Code: Clear error messages and state validation
  ListItemRepository get listItemRepository {
    _throwIfNotInitialized();

    if (_listItemRepository == null) {
      throw StateError(
        'ListItemRepository not available. Registry initialization may have failed.'
      );
    }

    return _listItemRepository!;
  }

  /// Initialize repositories using the new factory system
  ///
  /// SOLID: Delegation to factory for actual creation
  /// Clean Code: Clear async initialization with error handling
  Future<void> _initializeRepositories() async {
    try {
      // Use the new RepositoryManager system for actual initialization
      await RepositoryManager.initialize();

      // Get repository instances
      final manager = RepositoryManager.instance;
      _customListRepository = await manager.getCustomListRepository() as HiveCustomListRepository;
      _listItemRepository = await manager.getListItemRepository() as HiveListItemRepository;

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Internal disposal logic
  ///
  /// SOLID: Proper resource cleanup
  /// Clean Code: Safe disposal with null checks
  Future<void> _dispose() async {
    if (_isDisposed) return;

    try {
      // Dispose repositories if they exist
      if (_customListRepository != null) {
        await _customListRepository!.dispose();
      }
      if (_listItemRepository != null) {
        await _listItemRepository!.close();
      }

      // Clean up references
      _customListRepository = null;
      _listItemRepository = null;
      _isInitialized = false;
      _isDisposed = true;

      // Dispose the underlying RepositoryManager
      await RepositoryManager.dispose();
    } catch (e) {
      // Log error but mark as disposed anyway
      // ignore: avoid_print
      print('Warning: Error during HiveRepositoryRegistry disposal: $e');
      _isDisposed = true;
    }
  }

  /// Validates that the registry is properly initialized
  ///
  /// SOLID: Single responsibility for state validation
  /// Clean Code: Clear error messages
  void _throwIfNotInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'HiveRepositoryRegistry not initialized. Call initialize() first.'
      );
    }
    if (_isDisposed) {
      throw StateError(
        'HiveRepositoryRegistry has been disposed. Cannot access repositories.'
      );
    }
  }
}