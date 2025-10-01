/// Enhanced Dependency Injection Container following SOLID principles
///
/// Single Responsibility: Manages object lifecycle and dependencies
/// Open/Closed: Easy to add new service registrations
/// Interface Segregation: Multiple registration methods for different needs
/// Dependency Inversion: High-level modules depend on this container abstraction
/// Liskov Substitution: All registered services can be substituted by their interfaces

import 'dart:async';
import '../interfaces/application_interfaces.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DEPENDENCY INJECTION INTERFACES (ISP)
// ═══════════════════════════════════════════════════════════════════════════

/// Service registration interface
abstract class ServiceRegistry {
  void registerSingleton<T, TImpl extends T>(TImpl instance);
  void registerTransient<T, TImpl extends T>(TImpl Function() factory);
  void registerScoped<T>(T Function() factory);
  void registerFactory<T>(Factory<T> factory);
}

/// Service resolution interface
abstract class ServiceLocator {
  T resolve<T>();
  T? tryResolve<T>();
  List<T> resolveAll<T>();
  bool isRegistered<T>();
}

/// Service lifecycle management interface
abstract class ServiceLifecycleManager {
  Future<void> initialize();
  Future<void> dispose();
  void beginScope();
  void endScope();
}

/// Complete DI container interface
abstract class DIContainerInterface
    implements ServiceRegistry, ServiceLocator, ServiceLifecycleManager {}

// ═══════════════════════════════════════════════════════════════════════════
// SERVICE LIFETIME ENUMS
// ═══════════════════════════════════════════════════════════════════════════

/// Service lifetime options
enum ServiceLifetime {
  singleton,  // One instance for the entire application
  transient,  // New instance every time
  scoped,     // One instance per scope
}

// ═══════════════════════════════════════════════════════════════════════════
// DEPENDENCY INJECTION CONTAINER IMPLEMENTATION (SRP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Service registration descriptor
class ServiceDescriptor<T> {
  final Type serviceType;
  final ServiceLifetime lifetime;
  final T Function()? factory;
  final T? instance;
  final Factory<T>? factoryInstance;

  ServiceDescriptor._({
    required this.serviceType,
    required this.lifetime,
    this.factory,
    this.instance,
    this.factoryInstance,
  });

  factory ServiceDescriptor.singleton(T instance) {
    return ServiceDescriptor._(
      serviceType: T,
      lifetime: ServiceLifetime.singleton,
      instance: instance,
    );
  }

  factory ServiceDescriptor.transient(T Function() factory) {
    return ServiceDescriptor._(
      serviceType: T,
      lifetime: ServiceLifetime.transient,
      factory: factory,
    );
  }

  factory ServiceDescriptor.scoped(T Function() factory) {
    return ServiceDescriptor._(
      serviceType: T,
      lifetime: ServiceLifetime.scoped,
      factory: factory,
    );
  }

  factory ServiceDescriptor.factoryBased(Factory<T> factory) {
    return ServiceDescriptor._(
      serviceType: T,
      lifetime: ServiceLifetime.transient,
      factoryInstance: factory,
    );
  }
}

/// Main Dependency Injection Container
class DIContainer implements DIContainerInterface {
  static DIContainer? _instance;
  static DIContainer get instance => _instance ??= DIContainer._();

  DIContainer._();

  final Map<Type, List<ServiceDescriptor>> _services = {};
  final Map<Type, dynamic> _singletonInstances = {};
  final Map<Type, dynamic> _scopedInstances = {};
  final List<dynamic> _disposables = [];
  bool _isDisposed = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICE REGISTRATION (SRP)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void registerSingleton<T, TImpl extends T>(TImpl instance) {
    _ensureNotDisposed();
    _addService(ServiceDescriptor<T>.singleton(instance));
    _singletonInstances[T] = instance;
    _trackDisposable(instance);
  }

  /// Register singleton with same type
  void registerSingletonInstance<T>(T instance) {
    registerSingleton<T, T>(instance);
  }

  @override
  void registerTransient<T, TImpl extends T>(TImpl Function() factory) {
    _ensureNotDisposed();
    _addService(ServiceDescriptor<T>.transient(() => factory()));
  }

  /// Register transient with same type
  void registerTransientFactory<T>(T Function() factory) {
    registerTransient<T, T>(factory);
  }

  @override
  void registerScoped<T>(T Function() factory) {
    _ensureNotDisposed();
    _addService(ServiceDescriptor<T>.scoped(factory));
  }

  @override
  void registerFactory<T>(Factory<T> factory) {
    _ensureNotDisposed();
    _addService(ServiceDescriptor<T>.factoryBased(factory));
  }

  /// Register a service with custom configuration
  void registerWithConfig<T>(
    T Function(Map<String, dynamic>) factory,
    Map<String, dynamic> config, {
    ServiceLifetime lifetime = ServiceLifetime.transient,
  }) {
    _ensureNotDisposed();

    final configuredFactory = () => factory(config);

    switch (lifetime) {
      case ServiceLifetime.singleton:
        final instance = configuredFactory();
        registerSingletonInstance<T>(instance);
        break;
      case ServiceLifetime.transient:
        registerTransientFactory<T>(configuredFactory);
        break;
      case ServiceLifetime.scoped:
        registerScoped<T>(configuredFactory);
        break;
    }
  }

  /// Add service descriptor to registry
  void _addService<T>(ServiceDescriptor<T> descriptor) {
    _services[T] = _services[T] ?? [];
    _services[T]!.add(descriptor);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICE RESOLUTION (DIP)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  T resolve<T>() {
    _ensureNotDisposed();

    final descriptors = _services[T];
    if (descriptors == null || descriptors.isEmpty) {
      throw ArgumentError('Service of type ${T.toString()} is not registered');
    }

    final descriptor = descriptors.last; // Use latest registration
    return _createInstance<T>(descriptor as ServiceDescriptor<T>);
  }

  @override
  T? tryResolve<T>() {
    try {
      return resolve<T>();
    } catch (e) {
      return null;
    }
  }

  @override
  List<T> resolveAll<T>() {
    _ensureNotDisposed();

    final descriptors = _services[T];
    if (descriptors == null) {
      return [];
    }

    return descriptors
        .cast<ServiceDescriptor<T>>()
        .map((descriptor) => _createInstance<T>(descriptor))
        .toList();
  }

  @override
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Create instance based on service descriptor
  T _createInstance<T>(ServiceDescriptor<T> descriptor) {
    switch (descriptor.lifetime) {
      case ServiceLifetime.singleton:
        return _resolveSingleton<T>(descriptor);
      case ServiceLifetime.transient:
        return _resolveTransient<T>(descriptor);
      case ServiceLifetime.scoped:
        return _resolveScoped<T>(descriptor);
    }
  }

  /// Resolve singleton instance
  T _resolveSingleton<T>(ServiceDescriptor<T> descriptor) {
    if (_singletonInstances.containsKey(T)) {
      return _singletonInstances[T] as T;
    }

    final instance = _createNewInstance<T>(descriptor);
    _singletonInstances[T] = instance;
    _trackDisposable(instance);
    return instance;
  }

  /// Resolve transient instance
  T _resolveTransient<T>(ServiceDescriptor<T> descriptor) {
    final instance = _createNewInstance<T>(descriptor);
    _trackDisposable(instance);
    return instance;
  }

  /// Resolve scoped instance
  T _resolveScoped<T>(ServiceDescriptor<T> descriptor) {
    if (_scopedInstances.containsKey(T)) {
      return _scopedInstances[T] as T;
    }

    final instance = _createNewInstance<T>(descriptor);
    _scopedInstances[T] = instance;
    _trackDisposable(instance);
    return instance;
  }

  /// Create new instance from descriptor
  T _createNewInstance<T>(ServiceDescriptor<T> descriptor) {
    if (descriptor.instance != null) {
      return descriptor.instance!;
    }

    if (descriptor.factory != null) {
      return descriptor.factory!();
    }

    if (descriptor.factoryInstance != null) {
      return descriptor.factoryInstance!.create();
    }

    throw StateError('No way to create instance for ${T.toString()}');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE MANAGEMENT (SRP)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> initialize() async {
    // Initialize all singleton services that implement initialization
    for (final instance in _singletonInstances.values) {
      if (instance is Initializable) {
        await instance.initialize();
      }
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    // Dispose all tracked disposables
    for (final disposable in _disposables.reversed) {
      if (disposable is AsyncDisposable) {
        await disposable.dispose();
      } else if (disposable is Disposable) {
        disposable.dispose();
      }
    }

    _disposables.clear();
    _singletonInstances.clear();
    _scopedInstances.clear();
    _services.clear();
    _isDisposed = true;
  }

  @override
  void beginScope() {
    _scopedInstances.clear();
  }

  @override
  void endScope() {
    // Dispose scoped instances
    for (final instance in _scopedInstances.values) {
      if (instance is Disposable) {
        instance.dispose();
      }
    }
    _scopedInstances.clear();
  }

  /// Track disposable instances
  void _trackDisposable(dynamic instance) {
    if (instance is AsyncDisposable || instance is Disposable) {
      if (!_disposables.contains(instance)) {
        _disposables.add(instance);
      }
    }
  }

  /// Ensure container is not disposed
  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('DIContainer has been disposed');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all registered service types
  List<Type> get registeredTypes => _services.keys.toList();

  /// Get registration count for a service type
  int getRegistrationCount<T>() {
    return _services[T]?.length ?? 0;
  }

  /// Clear all registrations (for testing)
  void clearRegistrations() {
    _services.clear();
    _singletonInstances.clear();
    _scopedInstances.clear();
    _disposables.clear();
  }

  /// Check if container has any registrations
  bool get hasRegistrations => _services.isNotEmpty;
}

// ═══════════════════════════════════════════════════════════════════════════
// LIFECYCLE INTERFACES (ISP)
// ═══════════════════════════════════════════════════════════════════════════

/// Interface for objects that need initialization
abstract class Initializable {
  Future<void> initialize();
}

/// Interface for synchronous disposal
abstract class Disposable {
  void dispose();
}

/// Interface for asynchronous disposal
abstract class AsyncDisposable {
  Future<void> dispose();
}

// ═══════════════════════════════════════════════════════════════════════════
// DEPENDENCY INJECTION EXTENSIONS (OCP)
// ═══════════════════════════════════════════════════════════════════════════

/// Extension methods for easier registration
extension DIContainerExtensions on DIContainer {
  /// Register a service conditionally
  void registerIf<T>(bool condition, T Function() factory, {
    ServiceLifetime lifetime = ServiceLifetime.transient,
  }) {
    if (condition) {
      switch (lifetime) {
        case ServiceLifetime.singleton:
          registerSingletonInstance<T>(factory());
          break;
        case ServiceLifetime.transient:
          registerTransientFactory<T>(factory);
          break;
        case ServiceLifetime.scoped:
          registerScoped<T>(factory);
          break;
      }
    }
  }

  /// Register multiple implementations of an interface
  void registerMultiple<T>(List<T Function()> factories, {
    ServiceLifetime lifetime = ServiceLifetime.transient,
  }) {
    for (final factory in factories) {
      switch (lifetime) {
        case ServiceLifetime.singleton:
          registerSingletonInstance<T>(factory());
          break;
        case ServiceLifetime.transient:
          registerTransientFactory<T>(factory);
          break;
        case ServiceLifetime.scoped:
          registerScoped<T>(factory);
          break;
      }
    }
  }

  /// Register with decorator pattern
  void registerDecorated<T>(
    T Function() baseFactory,
    T Function(T base) decoratorFactory, {
    ServiceLifetime lifetime = ServiceLifetime.transient,
  }) {
    final combinedFactory = () => decoratorFactory(baseFactory());

    switch (lifetime) {
      case ServiceLifetime.singleton:
        registerSingletonInstance<T>(combinedFactory());
        break;
      case ServiceLifetime.transient:
        registerTransientFactory<T>(combinedFactory);
        break;
      case ServiceLifetime.scoped:
        registerScoped<T>(combinedFactory);
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVICE LOCATOR PATTERN (Anti-pattern, but sometimes necessary)
// ═══════════════════════════════════════════════════════════════════════════

/// Static service locator for cases where DI is not possible
/// WARNING: Use sparingly, prefer constructor injection
class GlobalServiceLocator {
  static DIContainer get instance => DIContainer.instance;

  static T get<T>() => instance.resolve<T>();
  static T? tryGet<T>() => instance.tryResolve<T>();
  static List<T> getAll<T>() => instance.resolveAll<T>();
  static bool isRegistered<T>() => instance.isRegistered<T>();
}