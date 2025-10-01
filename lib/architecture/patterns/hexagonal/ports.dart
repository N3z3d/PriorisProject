/// Hexagonal Architecture - Ports Definition
///
/// Ports define the interfaces for communication between the application core
/// and external adapters (infrastructure, UI, etc.).

import 'dart:async';

/// Primary Port - Incoming operations (API, UI)
abstract class PrimaryPort<TCommand, TResult> {
  Future<TResult> execute(TCommand command);
}

/// Secondary Port - Outgoing operations (Database, External Services)
abstract class SecondaryPort<TQuery, TResult> {
  Future<TResult> query(TQuery query);
}

/// Repository Port - Data persistence operations
abstract class RepositoryPort<TEntity, TId> {
  Future<TEntity> findById(TId id);
  Future<List<TEntity>> findAll();
  Future<TEntity> save(TEntity entity);
  Future<void> delete(TId id);
  Future<bool> exists(TId id);
}

/// Event Port - Domain event handling
abstract class EventPort<TEvent> {
  Future<void> publish(TEvent event);
  void subscribe<T extends TEvent>(Future<void> Function(T) handler);
  void unsubscribe<T extends TEvent>();
}

/// Query Port - Read operations
abstract class QueryPort<TQuery, TResult> {
  Future<TResult> handle(TQuery query);
}

/// Command Port - Write operations
abstract class CommandPort<TCommand, TResult> {
  Future<TResult> handle(TCommand command);
}

/// Notification Port - External notifications
abstract class NotificationPort<TMessage> {
  Future<void> send(TMessage message);
  Future<bool> isAvailable();
}

/// Cache Port - Caching operations
abstract class CachePort<TKey, TValue> {
  Future<TValue?> get(TKey key);
  Future<void> set(TKey key, TValue value, {Duration? ttl});
  Future<void> delete(TKey key);
  Future<void> clear();
  Future<bool> exists(TKey key);
}

/// Search Port - Search operations
abstract class SearchPort<TQuery, TResult> {
  Future<List<TResult>> search(TQuery query);
  Future<int> count(TQuery query);
}

/// Authentication Port - User authentication
abstract class AuthenticationPort {
  Future<bool> authenticate(String credentials);
  Future<void> logout();
  Future<String?> getCurrentUser();
  Future<bool> isAuthenticated();
}

/// Authorization Port - User permissions
abstract class AuthorizationPort {
  Future<bool> hasPermission(String resource, String action);
  Future<List<String>> getPermissions(String userId);
}

/// Audit Port - Audit logging
abstract class AuditPort<TAuditEvent> {
  Future<void> log(TAuditEvent event);
  Future<List<TAuditEvent>> getAuditLog({
    DateTime? from,
    DateTime? to,
    String? userId,
    String? resource,
  });
}

/// Configuration Port - Application configuration
abstract class ConfigurationPort {
  T getValue<T>(String key, {T? defaultValue});
  Future<void> setValue<T>(String key, T value);
  Future<Map<String, dynamic>> getAllSettings();
}

/// File Storage Port - File operations
abstract class FileStoragePort {
  Future<String> store(String path, List<int> data);
  Future<List<int>> retrieve(String path);
  Future<void> delete(String path);
  Future<bool> exists(String path);
  Future<List<String>> list(String directory);
}

/// Messaging Port - Message queue operations
abstract class MessagingPort<TMessage> {
  Future<void> send(String topic, TMessage message);
  void subscribe(String topic, Future<void> Function(TMessage) handler);
  Future<void> unsubscribe(String topic);
}

/// Metrics Port - Application metrics
abstract class MetricsPort {
  void increment(String metric, {Map<String, String>? tags});
  void gauge(String metric, double value, {Map<String, String>? tags});
  void histogram(String metric, double value, {Map<String, String>? tags});
  void timer(String metric, Duration duration, {Map<String, String>? tags});
}

/// Health Check Port - System health monitoring
abstract class HealthCheckPort {
  Future<bool> isHealthy();
  Future<Map<String, dynamic>> getHealthDetails();
}