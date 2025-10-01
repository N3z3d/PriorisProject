import 'dart:async';

/// Dependency Injection Container following SOLID principles
///
/// Single Responsibility: Manages service registration and resolution
/// Open/Closed: Can be extended with new service types without modification
/// Dependency Inversion: Clients depend on abstractions, not this container
class DIContainer {
  static DIContainer? _instance;
  static DIContainer get instance {
    _instance ??= DIContainer._();
    return _instance!;
  }

  DIContainer._();

  final Map<Object, _ServiceRegistration> _services = {};
  final Map<Object, dynamic> _singletonInstances = {};
  final List<Object> _resolutionStack = [];

  bool _isDisposed = false;

  /// Registers a factory that creates a new instance each time
  void registerFactory<TInterface, TImplementation extends TInterface>(
    TImplementation Function() factory, {
    String? name,
  }) {
    _throwIfDisposed();
    final key = _getServiceKey<TInterface>(name);
    _services[key] = _ServiceRegistration(
      factory: factory,
      lifecycle: ServiceLifecycle.transient,
      name: name,
    );
  }

  /// Registers a singleton instance
  void registerSingleton<TInterface>(
    TInterface instance, {
    String? name,
  }) {
    _throwIfDisposed();
    final key = _getServiceKey<TInterface>(name);
    _services[key] = _ServiceRegistration(
      factory: () => instance,
      lifecycle: ServiceLifecycle.singleton,
      name: name,
    );
    _singletonInstances[key] = instance;
  }

  /// Registers a lazy singleton that will be created on first access
  void registerLazySingleton<TInterface, TImplementation extends TInterface>(
    TImplementation Function() factory, {
    String? name,
  }) {
    _throwIfDisposed();
    final key = _getServiceKey<TInterface>(name);
    _services[key] = _ServiceRegistration(
      factory: factory,
      lifecycle: ServiceLifecycle.singleton,
      name: name,
    );
  }

  /// Registers an async factory
  void registerAsyncFactory<TInterface>(
    Future<TInterface> Function() factory, {
    String? name,
  }) {
    _throwIfDisposed();
    final key = _getServiceKey<TInterface>(name);
    _services[key] = _ServiceRegistration(
      asyncFactory: factory,
      lifecycle: ServiceLifecycle.transient,
      name: name,
    );
  }

  /// Resolves a service by type
  T get<T>({String? name}) {
    _throwIfDisposed();
    final key = _getServiceKey<T>(name);
    return _resolve<T>(key);
  }

  /// Resolves an async service
  Future<T> getAsync<T>({String? name}) async {
    _throwIfDisposed();
    final key = _getServiceKey<T>(name);
    return await _resolveAsync<T>(key);
  }

  /// Checks if a service is registered
  bool isRegistered<T>({String? name}) {
    final key = _getServiceKey<T>(name);
    return _services.containsKey(key);
  }

  /// Unregisters a service
  void unregister<T>({String? name}) {
    _throwIfDisposed();
    final key = _getServiceKey<T>(name);
    _services.remove(key);
    _singletonInstances.remove(key);
  }

  /// Clears all registrations
  void clear() {
    _throwIfDisposed();
    _services.clear();
    _singletonInstances.clear();
  }

  /// Disposes all disposable singletons and clears the container
  Future<void> dispose() async {
    if (_isDisposed) return;

    // Dispose all disposable singletons
    final disposeFutures = <Future>[];
    for (final instance in _singletonInstances.values) {
      if (instance is Disposable) {
        disposeFutures.add(instance.dispose());
      }
    }

    await Future.wait(disposeFutures);

    _services.clear();
    _singletonInstances.clear();
    _isDisposed = true;
  }

  /// Resets the container (for testing purposes)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }

  T _resolve<T>(Object key) {
    // Check for circular dependencies
    if (_resolutionStack.contains(key)) {
      throw CircularDependencyException(
        'Circular dependency detected: ${_resolutionStack.join(' -> ')} -> $key',
      );
    }

    final registration = _services[key];
    if (registration == null) {
      throw ServiceNotFoundException('Service of type $key is not registered');
    }

    _resolutionStack.add(key);

    try {
      // Return singleton instance if already created
      if (registration.lifecycle == ServiceLifecycle.singleton) {
        final existingInstance = _singletonInstances[key];
        if (existingInstance != null) {
          return existingInstance as T;
        }

        // Create and cache singleton
        final instance = registration.factory!() as T;
        _singletonInstances[key] = instance;
        return instance;
      }

      // Create transient instance
      return registration.factory!() as T;
    } finally {
      _resolutionStack.remove(key);
    }
  }

  Future<T> _resolveAsync<T>(Object key) async {
    final registration = _services[key];
    if (registration == null) {
      throw ServiceNotFoundException('Service of type $key is not registered');
    }

    if (registration.asyncFactory != null) {
      return await registration.asyncFactory!() as T;
    }

    // Fallback to synchronous resolution
    return _resolve<T>(key);
  }

  Object _getServiceKey<T>(String? name) {
    return name == null ? T : _NamedType<T>(name);
  }

  void _throwIfDisposed() {
    if (_isDisposed) {
      throw StateError('DIContainer has been disposed');
    }
  }
}

/// Service registration information
class _ServiceRegistration {
  final dynamic Function()? factory;
  final Future<dynamic> Function()? asyncFactory;
  final ServiceLifecycle lifecycle;
  final String? name;

  const _ServiceRegistration({
    this.factory,
    this.asyncFactory,
    required this.lifecycle,
    this.name,
  });
}

/// Service lifecycle types
enum ServiceLifecycle {
  /// New instance created each time
  transient,

  /// Single instance shared across the application
  singleton,
}

/// Named type for named registrations
class _NamedType<T> {
  final String name;
  const _NamedType(this.name);

  @override
  bool operator ==(Object other) {
    return other is _NamedType<T> && other.name == name;
  }

  @override
  int get hashCode => T.hashCode ^ name.hashCode;

  @override
  String toString() => '${T.toString()}($name)';
}

/// Interface for disposable services
abstract class Disposable {
  Future<void> dispose();
}

/// Exception thrown when a service is not found
class ServiceNotFoundException implements Exception {
  final String message;
  const ServiceNotFoundException(this.message);

  @override
  String toString() => 'ServiceNotFoundException: $message';
}

/// Exception thrown when circular dependencies are detected
class CircularDependencyException implements Exception {
  final String message;
  const CircularDependencyException(this.message);

  @override
  String toString() => 'CircularDependencyException: $message';
}