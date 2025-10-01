/// Hexagonal Architecture - Adapters Implementation
///
/// Adapters implement the ports and handle the translation between
/// the application core and external systems.

import 'dart:async';
import 'package:prioris/architecture/patterns/hexagonal/ports.dart';

/// Base Adapter - Common functionality for all adapters
abstract class BaseAdapter {
  bool _isConnected = false;
  final Map<String, dynamic> _configuration = {};

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    // Override in concrete adapters
    _isConnected = true;
  }

  Future<void> disconnect() async {
    // Override in concrete adapters
    _isConnected = false;
  }

  void configure(Map<String, dynamic> config) {
    _configuration.addAll(config);
  }

  T getConfig<T>(String key, {T? defaultValue}) {
    return _configuration[key] as T? ?? defaultValue!;
  }
}

/// Primary Adapter - Handles incoming requests
abstract class PrimaryAdapter<TCommand, TResult>
    extends BaseAdapter implements PrimaryPort<TCommand, TResult> {

  @override
  Future<TResult> execute(TCommand command) async {
    if (!isConnected) {
      throw StateError('Adapter not connected');
    }
    return await handleCommand(command);
  }

  Future<TResult> handleCommand(TCommand command);
}

/// Secondary Adapter - Handles outgoing operations
abstract class SecondaryAdapter<TQuery, TResult>
    extends BaseAdapter implements SecondaryPort<TQuery, TResult> {

  @override
  Future<TResult> query(TQuery query) async {
    if (!isConnected) {
      throw StateError('Adapter not connected');
    }
    return await handleQuery(query);
  }

  Future<TResult> handleQuery(TQuery query);
}

/// Repository Adapter - Database operations
abstract class RepositoryAdapter<TEntity, TId>
    extends SecondaryAdapter<dynamic, dynamic> implements RepositoryPort<TEntity, TId> {

  @override
  Future<TEntity> findById(TId id) async {
    return await handleQuery('findById:$id');
  }

  @override
  Future<List<TEntity>> findAll() async {
    return await handleQuery('findAll');
  }

  @override
  Future<TEntity> save(TEntity entity) async {
    return await handleQuery('save:$entity');
  }

  @override
  Future<void> delete(TId id) async {
    await handleQuery('delete:$id');
  }

  @override
  Future<bool> exists(TId id) async {
    return await handleQuery('exists:$id');
  }
}

/// Event Adapter - Event handling
class EventAdapter<TEvent> extends BaseAdapter implements EventPort<TEvent> {
  final Map<Type, List<Future<void> Function(dynamic)>> _handlers = {};
  final StreamController<TEvent> _eventStream = StreamController.broadcast();

  @override
  Future<void> publish(TEvent event) async {
    if (!isConnected) return;

    // Publish to stream
    _eventStream.add(event);

    // Call registered handlers
    final handlers = _handlers[event.runtimeType] ?? [];
    await Future.wait(
      handlers.map((handler) => handler(event)),
    );
  }

  @override
  void subscribe<T extends TEvent>(Future<void> Function(T) handler) {
    _handlers.putIfAbsent(T, () => []).add(handler as Future<void> Function(dynamic));
  }

  @override
  void unsubscribe<T extends TEvent>() {
    _handlers.remove(T);
  }

  Stream<TEvent> get eventStream => _eventStream.stream;

  @override
  Future<void> disconnect() async {
    await _eventStream.close();
    _handlers.clear();
    await super.disconnect();
  }
}

/// Cache Adapter - In-memory caching
class CacheAdapter<TKey, TValue> extends BaseAdapter implements CachePort<TKey, TValue> {
  final Map<TKey, _CacheEntry<TValue>> _cache = {};

  @override
  Future<TValue?> get(TKey key) async {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  @override
  Future<void> set(TKey key, TValue value, {Duration? ttl}) async {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = _CacheEntry(value, expiry);
  }

  @override
  Future<void> delete(TKey key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<bool> exists(TKey key) async {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  void cleanupExpired() {
    final expired = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expired) {
      _cache.remove(key);
    }
  }
}

/// Authentication Adapter - User authentication
class AuthenticationAdapter extends BaseAdapter implements AuthenticationPort {
  String? _currentUser;

  @override
  Future<bool> authenticate(String credentials) async {
    if (!isConnected) return false;

    // Implementation specific to authentication provider
    final isValid = await validateCredentials(credentials);
    if (isValid) {
      _currentUser = extractUser(credentials);
    }
    return isValid;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<String?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _currentUser != null;
  }

  // Template methods - override in concrete implementations
  Future<bool> validateCredentials(String credentials) async {
    // Default implementation - override in concrete adapters
    return credentials.isNotEmpty;
  }

  String extractUser(String credentials) {
    // Default implementation - override in concrete adapters
    return credentials.split(':').first;
  }
}

/// Configuration Adapter - Application settings
class ConfigurationAdapter extends BaseAdapter implements ConfigurationPort {
  final Map<String, dynamic> _settings = {};

  @override
  T getValue<T>(String key, {T? defaultValue}) {
    return _settings[key] as T? ?? defaultValue!;
  }

  @override
  Future<void> setValue<T>(String key, T value) async {
    _settings[key] = value;
  }

  @override
  Future<Map<String, dynamic>> getAllSettings() async {
    return Map.from(_settings);
  }

  void loadFromMap(Map<String, dynamic> settings) {
    _settings.addAll(settings);
  }
}

/// Metrics Adapter - Application metrics
class MetricsAdapter extends BaseAdapter implements MetricsPort {
  final Map<String, double> _metrics = {};

  @override
  void increment(String metric, {Map<String, String>? tags}) {
    final key = _buildKey(metric, tags);
    _metrics[key] = (_metrics[key] ?? 0) + 1;
  }

  @override
  void gauge(String metric, double value, {Map<String, String>? tags}) {
    final key = _buildKey(metric, tags);
    _metrics[key] = value;
  }

  @override
  void histogram(String metric, double value, {Map<String, String>? tags}) {
    // Simplified histogram - in real implementation would use proper histogram
    gauge(metric, value, tags: tags);
  }

  @override
  void timer(String metric, Duration duration, {Map<String, String>? tags}) {
    gauge(metric, duration.inMilliseconds.toDouble(), tags: tags);
  }

  String _buildKey(String metric, Map<String, String>? tags) {
    if (tags == null || tags.isEmpty) return metric;

    final tagString = tags.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');

    return '$metric{$tagString}';
  }

  Map<String, double> get allMetrics => Map.from(_metrics);
}

/// Cache entry with TTL support
class _CacheEntry<T> {
  final T value;
  final DateTime? expiry;

  _CacheEntry(this.value, this.expiry);

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}