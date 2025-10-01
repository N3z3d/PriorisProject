import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dependency_injection_container.dart';
import 'service_configuration.dart';

// Domain Services
import '../../domain/services/cache/interfaces/cache_interface.dart';
import '../../domain/services/core/interfaces/error_handler_interface.dart';
import '../../domain/services/core/lists_filter_service.dart';

// Data Layer
import '../../data/repositories/custom_list_repository.dart';
import '../../data/repositories/list_item_repository.dart';

// Infrastructure Services
import '../../infrastructure/services/auth_service.dart';
import '../../infrastructure/services/logger_service.dart';

/// Dependency Injection Providers using the DI Container
///
/// These providers integrate the DI Container with Riverpod,
/// following proper dependency injection patterns.
///
/// Benefits:
/// - Centralized dependency management
/// - Testable (can inject mocks)
/// - Follows SOLID principles
/// - Clear separation of concerns

// ========== CORE SERVICES ==========

/// Logger Service Provider
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return DIContainer.instance.get<LoggerService>();
});

// ========== DOMAIN SERVICES ==========

/// Cache Service Provider
final cacheServiceProvider = Provider<CacheInterface<dynamic>>((ref) {
  return DIContainer.instance.get<CacheInterface<dynamic>>();
});

/// Error Handler Provider
final errorHandlerProvider = Provider<ErrorHandlerInterface>((ref) {
  return DIContainer.instance.get<ErrorHandlerInterface>();
});

/// Lists Filter Service Provider
final listsFilterServiceProvider = Provider<ListsFilterService>((ref) {
  return DIContainer.instance.get<ListsFilterService>();
});

// ========== DATA SERVICES ==========

/// Repository Factory Provider
final repositoryFactoryProvider = Provider<IRepositoryFactory>((ref) {
  return DIContainer.instance.get<IRepositoryFactory>();
});

/// Repository Manager Provider
final repositoryManagerProvider = Provider<RepositoryManager>((ref) {
  return DIContainer.instance.get<RepositoryManager>();
});

/// Custom List Repository Provider (Async)
final customListRepositoryProvider = FutureProvider<CustomListRepository>((ref) async {
  return await DIContainer.instance.getAsync<CustomListRepository>();
});

/// List Item Repository Provider (Async)
final listItemRepositoryProvider = FutureProvider<ListItemRepository>((ref) async {
  return await DIContainer.instance.getAsync<ListItemRepository>();
});

// ========== INFRASTRUCTURE SERVICES ==========

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return DIContainer.instance.get<AuthService>();
});

// ========== CONVENIENCE PROVIDERS ==========

/// Synchronous wrappers for backward compatibility
/// Note: These should be phased out in favor of async providers

final customListRepositorySyncProvider = Provider<Future<CustomListRepository>>((ref) {
  return ref.watch(customListRepositoryProvider.future);
});

final listItemRepositorySyncProvider = Provider<Future<ListItemRepository>>((ref) {
  return ref.watch(listItemRepositoryProvider.future);
});

// ========== PROVIDER UTILITIES ==========

/// Provider Override Utilities for Testing
class DIProviderOverrides {
  /// Creates override for custom list repository (useful for testing)
  static Override customListRepositoryOverride(CustomListRepository mockRepository) {
    return customListRepositoryProvider.overrideWith((ref) async => mockRepository);
  }

  /// Creates override for list item repository (useful for testing)
  static Override listItemRepositoryOverride(ListItemRepository mockRepository) {
    return listItemRepositoryProvider.overrideWith((ref) async => mockRepository);
  }

  /// Creates override for auth service (useful for testing)
  static Override authServiceOverride(AuthService mockAuthService) {
    return authServiceProvider.overrideWith((ref) => mockAuthService);
  }

  /// Creates override for cache service (useful for testing)
  static Override cacheServiceOverride(CacheInterface<dynamic> mockCacheService) {
    return cacheServiceProvider.overrideWith((ref) => mockCacheService);
  }
}

/// DI Container Lifecycle Manager
class DILifecycleManager {
  static bool _initialized = false;

  /// Initializes the DI container with all services
  static Future<void> initialize() async {
    if (_initialized) return;

    await ServiceConfiguration.configure();
    _initialized = true;
  }

  /// Disposes the DI container and all services
  static Future<void> dispose() async {
    if (!_initialized) return;

    await DIContainer.instance.dispose();
    _initialized = false;
  }

  /// Resets for testing
  static void reset() {
    ServiceConfiguration.reset();
    _initialized = false;
  }

  /// Checks if the DI container is initialized
  static bool get isInitialized => _initialized;
}

/// Extension for easy service access in widgets and controllers
extension DIServiceAccess on WidgetRef {
  /// Gets a service from the DI container via provider
  T getService<T>() => read(DIContainer.instance.provider<T>());

  /// Gets an async service from the DI container via provider
  Future<T> getAsyncService<T>() => read(DIContainer.instance.futureProvider<T>().future);

  /// Watches a service from the DI container via provider
  T watchService<T>() => watch(DIContainer.instance.provider<T>());
}