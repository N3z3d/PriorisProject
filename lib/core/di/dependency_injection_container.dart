import 'dart:async';

/// Contract implemented by services that need explicit disposal when the
/// dependency container shuts down.
abstract class Disposable {
  Future<void> dispose();
}

/// Exception thrown when attempting to resolve an unregistered service.
class ServiceNotFoundException implements Exception {
  ServiceNotFoundException(this.type, this.name);

  final Type type;
  final String? name;

  @override
  String toString() {
    final buffer = StringBuffer('ServiceNotFoundException: ')
      ..write(type.toString());
    if (name != null) {
      buffer.write(" (name: '$name')");
    }
    buffer.write(' is not registered in the container.');
    return buffer.toString();
  }
}

/// Exception thrown when a circular dependency is detected while resolving.
class CircularDependencyException implements Exception {
  CircularDependencyException(this.chain);

  final List<_ServiceKey> chain;

  @override
  String toString() {
    final cycle = chain.map((key) => key.toString()).join(' -> ');
    return 'CircularDependencyException: $cycle';
  }
}

enum _ServiceLifetime { factory, singleton }

class _ServiceKey {
  const _ServiceKey(this.type, this.name);

  final Type type;
  final String? name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ServiceKey &&
        other.type == type &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(type, name);

  @override
  String toString() => name == null ? type.toString() : '${type.toString()}("$name")';
}

class _Registration {
  _Registration({
    required this.factory,
    required this.lifetime,
  });

  final Object Function() factory;
  final _ServiceLifetime lifetime;
}

/// Minimal yet expressive dependency injection container used by tests.
class DIContainer {
  final Map<_ServiceKey, _Registration> _registrations = {};
  final Map<_ServiceKey, Object> _singletonCache = {};
  final Map<_ServiceKey, Future<Object>> _asyncFactories = {};
  final Map<_ServiceKey, Object> _asyncResolved = {};
  final List<_ServiceKey> _resolutionStack = [];
  bool _isDisposed = false;

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('DIContainer has been disposed.');
    }
  }

  /// Registers a factory that produces a new instance at every resolution.
  void registerFactory<T>(
    T Function() factory, {
    String? name,
  }) {
    _ensureNotDisposed();
    final key = _ServiceKey(T, name);
    _registrations[key] = _Registration(
      factory: () => factory(),
      lifetime: _ServiceLifetime.factory,
    );
    _singletonCache.remove(key);
  }

  /// Registers a singleton that is lazily instantiated on first resolution.
  void registerSingleton<T>(
    T Function() factory, {
    String? name,
  }) {
    _ensureNotDisposed();
    final key = _ServiceKey(T, name);
    _registrations[key] = _Registration(
      factory: () => factory(),
      lifetime: _ServiceLifetime.singleton,
    );
    _singletonCache.remove(key);
  }

  /// Registers an asynchronous service. The first call to [resolveAsync]
  /// awaits the provided future and caches the resulting instance.
  void registerAsyncService<T>(
    Future<T> future, {
    String? name,
  }) {
    _ensureNotDisposed();
    final key = _ServiceKey(T, name);
    _asyncFactories[key] = future.then<Object>((value) => value);
    _asyncResolved.remove(key);
  }

  /// Resolves a service synchronously.
  T resolve<T>({String? name}) {
    _ensureNotDisposed();
    final key = _ServiceKey(T, name);
    final registration = _registrations[key];
    if (registration == null) {
      throw ServiceNotFoundException(T, name);
    }

    if (registration.lifetime == _ServiceLifetime.singleton) {
      if (_singletonCache.containsKey(key)) {
        return _singletonCache[key] as T;
      }
    }

    _pushResolving(key);
    try {
      final instance = registration.factory() as T;
      if (registration.lifetime == _ServiceLifetime.singleton) {
        _singletonCache[key] = instance as Object;
      }
      _trackDisposable(instance);
      return instance;
    } finally {
      _popResolving(key);
    }
  }

  /// Resolves an asynchronous service.
  Future<T> resolveAsync<T>({String? name}) async {
    _ensureNotDisposed();
    final key = _ServiceKey(T, name);

    if (_asyncResolved.containsKey(key)) {
      return _asyncResolved[key] as T;
    }

    final future = _asyncFactories[key];
    if (future == null) {
      throw ServiceNotFoundException(T, name);
    }

    final instance = await future;
    _asyncResolved[key] = instance;
    _trackDisposable(instance);
    return instance as T;
  }

  /// Returns whether a service registration exists.
  bool isRegistered<T>({String? name}) {
    final key = _ServiceKey(T, name);
    return _registrations.containsKey(key) ||
        _asyncFactories.containsKey(key) ||
        _asyncResolved.containsKey(key);
  }

  /// Unregisters a service.
  void unregister<T>({String? name}) {
    final key = _ServiceKey(T, name);
    _registrations.remove(key);
    final instance = _singletonCache.remove(key);
    if (instance != null) {
      _disposeInstance(instance);
    }
    final asyncInstance = _asyncResolved.remove(key);
    if (asyncInstance != null) {
      _disposeInstance(asyncInstance);
    }
    _asyncFactories.remove(key);
  }

  /// Clears all registrations without disposing the container.
  void clear() {
    _registrations.clear();
    _asyncFactories.clear();
    for (final instance in _singletonCache.values) {
      _disposeInstance(instance);
    }
    for (final instance in _asyncResolved.values) {
      _disposeInstance(instance);
    }
    _singletonCache.clear();
    _asyncResolved.clear();
  }

  /// Disposes the container and every disposable singleton.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    final List<Future<void>> disposals = [];
    for (final instance in _singletonCache.values) {
      final future = _disposeInstance(instance);
      if (future != null) {
        disposals.add(future);
      }
    }
    for (final instance in _asyncResolved.values) {
      final future = _disposeInstance(instance);
      if (future != null) {
        disposals.add(future);
      }
    }
    await Future.wait(disposals);
    clear();
  }

  void _pushResolving(_ServiceKey key) {
    if (_resolutionStack.contains(key)) {
      final cycle = List<_ServiceKey>.from(_resolutionStack)..add(key);
      throw CircularDependencyException(cycle);
    }
    _resolutionStack.add(key);
  }

  void _popResolving(_ServiceKey key) {
    if (_resolutionStack.isNotEmpty &&
        identical(_resolutionStack.last, key)) {
      _resolutionStack.removeLast();
    } else {
      _resolutionStack.remove(key);
    }
  }

  void _trackDisposable(Object instance) {
    if (instance is Disposable) {
      // keep reference in singleton cache or async resolved maps
      // disposal is handled when clearing/dispose.
    }
  }

  Future<void>? _disposeInstance(Object instance) {
    if (instance is Disposable) {
      return instance.dispose();
    }
    return null;
  }
}
