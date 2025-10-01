import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dependency_injection_container.dart';

// Domain Services
import '../../domain/services/cache/interfaces/cache_interface.dart';
import '../../domain/services/cache/cache_service.dart';
import '../../domain/services/core/interfaces/error_handler_interface.dart';
import '../../domain/services/core/error_handling_service.dart';
import '../../domain/services/core/error_classification_service.dart';
import '../../domain/services/core/error_logger_service.dart';
import '../../domain/services/core/lists_filter_service.dart';

// Data Layer
import '../../data/repositories/custom_list_repository.dart';
import '../../data/repositories/list_item_repository.dart';
import '../../data/repositories/hive_custom_list_repository.dart';
import '../../data/repositories/hive_list_item_repository.dart';

// Infrastructure Services
import '../../infrastructure/services/auth_service.dart';
import '../../infrastructure/services/logger_service.dart';

/// Service Configuration following Dependency Injection best practices
///
/// Single Responsibility: Centralized service registration
/// Dependency Inversion: All registrations use interfaces
/// Open/Closed: Can be extended with new service modules without modification
class ServiceConfiguration {
  static bool _isConfigured = false;

  /// Configures all application dependencies
  static Future<void> configure() async {
    if (_isConfigured) return;

    final container = DIContainer.instance;

    // Configure Core Services
    await _configureCoreServices(container);

    // Configure Domain Services
    _configureDomainServices(container);

    // Configure Data Services
    await _configureDataServices(container);

    // Configure Infrastructure Services
    _configureInfrastructureServices(container);

    // Configure Application Services
    _configureApplicationServices(container);

    _isConfigured = true;
  }

  /// Configures core system services
  static Future<void> _configureCoreServices(DIContainer container) async {
    // Logger Service (singleton)
    container.registerSingleton<LoggerService>(
      LoggerService.instance,
    );
  }

  /// Configures domain services
  static void _configureDomainServices(DIContainer container) {
    // Cache Service
    container.registerLazySingleton<CacheInterface<dynamic>, CacheService>(
      () => CacheService(),
    );

    // Error Handling Services
    container.registerLazySingleton<ErrorClassifierInterface, ErrorClassificationService>(
      () => ErrorClassificationService(),
    );

    container.registerLazySingleton<ErrorLoggerInterface, ErrorLoggerService>(
      () => ErrorLoggerService(),
    );

    container.registerLazySingleton<ErrorHandlerInterface, ErrorHandlingService>(
      () => ErrorHandlingService(
        container.get<ErrorClassifierInterface>(),
        container.get<ErrorLoggerInterface>(),
      ),
    );

    // Filter Service
    container.registerLazySingleton<ListsFilterService, ListsFilterService>(
      () => ListsFilterService(),
    );
  }

  /// Configures data layer services
  static Future<void> _configureDataServices(DIContainer container) async {
    // Repository Factory (following factory pattern from SOLID refactoring)
    container.registerLazySingleton<IRepositoryFactory, HiveRepositoryFactory>(
      () => HiveRepositoryFactory(),
    );

    // Repository Manager
    container.registerLazySingleton<RepositoryManager, RepositoryManager>(
      () {
        // Initialize repository manager with factory
        final factory = container.get<IRepositoryFactory>();
        return RepositoryManager._(factory);
      },
    );

    // Repositories (async registration for proper initialization)
    container.registerAsyncFactory<CustomListRepository>(
      () async {
        final manager = container.get<RepositoryManager>();
        return await manager.getCustomListRepository();
      },
    );

    container.registerAsyncFactory<ListItemRepository>(
      () async {
        final manager = container.get<RepositoryManager>();
        return await manager.getListItemRepository();
      },
    );
  }

  /// Configures infrastructure services
  static void _configureInfrastructureServices(DIContainer container) {
    // Auth Service (singleton)
    container.registerSingleton<AuthService>(
      AuthService.instance,
    );
  }

  /// Configures application services
  static void _configureApplicationServices(DIContainer container) {
    // Application services can be registered here
    // For example: Use case handlers, application services, etc.
  }

  /// Resets configuration (for testing purposes)
  static void reset() {
    _isConfigured = false;
    DIContainer.reset();
  }
}

/// Extension to integrate DI Container with Riverpod
extension DIContainerRiverpod on DIContainer {
  /// Creates a provider for a service
  Provider<T> provider<T>({String? name}) {
    return Provider<T>((ref) => get<T>(name: name));
  }

  /// Creates a future provider for an async service
  FutureProvider<T> futureProvider<T>({String? name}) {
    return FutureProvider<T>((ref) => getAsync<T>(name: name));
  }
}

/// Repository Factory interface (matches the SOLID refactoring)
abstract class IRepositoryFactory {
  Future<CustomListRepository> createCustomListRepository();
  Future<ListItemRepository> createListItemRepository();
  Future<void> dispose();
}

/// Hive Repository Factory implementation
class HiveRepositoryFactory implements IRepositoryFactory {
  final Map<Type, dynamic> _repositoryCache = {};
  bool _isDisposed = false;

  @override
  Future<CustomListRepository> createCustomListRepository() async {
    if (_isDisposed) {
      throw StateError('Factory has been disposed');
    }

    if (_repositoryCache.containsKey(HiveCustomListRepository)) {
      return _repositoryCache[HiveCustomListRepository] as HiveCustomListRepository;
    }

    final repository = HiveCustomListRepository();
    await repository.initialize();
    _repositoryCache[HiveCustomListRepository] = repository;
    return repository;
  }

  @override
  Future<ListItemRepository> createListItemRepository() async {
    if (_isDisposed) {
      throw StateError('Factory has been disposed');
    }

    if (_repositoryCache.containsKey(HiveListItemRepository)) {
      return _repositoryCache[HiveListItemRepository] as HiveListItemRepository;
    }

    final repository = HiveListItemRepository();
    await repository.initialize();
    _repositoryCache[HiveListItemRepository] = repository;
    return repository;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    for (final repository in _repositoryCache.values) {
      try {
        if (repository is HiveCustomListRepository) {
          await repository.dispose();
        } else if (repository is HiveListItemRepository) {
          await repository.close();
        }
      } catch (e) {
        // Log error but continue disposal
        print('Warning: Error disposing repository: $e');
      }
    }

    _repositoryCache.clear();
    _isDisposed = true;
  }
}

/// Repository Manager (matches the SOLID refactoring)
class RepositoryManager implements Disposable {
  final IRepositoryFactory _factory;

  RepositoryManager._(this._factory);

  Future<CustomListRepository> getCustomListRepository() =>
      _factory.createCustomListRepository();

  Future<ListItemRepository> getListItemRepository() =>
      _factory.createListItemRepository();

  @override
  Future<void> dispose() async {
    await _factory.dispose();
  }
}