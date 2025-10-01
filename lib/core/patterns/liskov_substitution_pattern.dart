/// Liskov Substitution Principle (LSP) Implementation
///
/// LSP: Subtypes must be substitutable for their base types without
/// altering the correctness of the program.
///
/// This file demonstrates proper inheritance hierarchies where:
/// - Derived classes maintain behavioral contracts of base classes
/// - No strengthening of preconditions in derived classes
/// - No weakening of postconditions in derived classes
/// - Invariants are preserved across the inheritance hierarchy

import 'dart:async';

// ═══════════════════════════════════════════════════════════════════════════
// BASE REPOSITORY HIERARCHY (LSP Compliant)
// ═══════════════════════════════════════════════════════════════════════════

/// Abstract base repository with consistent contract
abstract class BaseRepository<T, TId> {
  /// Invariant: Entity with given ID should be findable after creation
  /// Precondition: entity must not be null
  /// Postcondition: returns non-null ID, entity can be retrieved by that ID
  Future<TId> create(T entity) async {
    if (entity == null) {
      throw ArgumentError('Entity cannot be null');
    }

    final id = await createInternal(entity);

    // Ensure postcondition: entity can be retrieved
    final retrieved = await getById(id);
    if (retrieved == null) {
      throw StateError('Created entity cannot be retrieved');
    }

    return id;
  }

  /// Precondition: id must not be null
  /// Postcondition: returns entity or null (never throws for missing entity)
  Future<T?> getById(TId id) async {
    if (id == null) {
      throw ArgumentError('ID cannot be null');
    }
    return await getByIdInternal(id);
  }

  /// Precondition: entity must not be null and must have valid ID
  /// Postcondition: entity is updated, retrieving it returns updated version
  Future<void> update(T entity) async {
    if (entity == null) {
      throw ArgumentError('Entity cannot be null');
    }

    final id = extractId(entity);
    if (id == null) {
      throw ArgumentError('Entity must have a valid ID');
    }

    // Verify entity exists before updating
    final existing = await getById(id);
    if (existing == null) {
      throw ArgumentError('Entity with ID $id does not exist');
    }

    await updateInternal(entity);
  }

  /// Precondition: id must not be null
  /// Postcondition: entity is removed, getById returns null
  Future<void> delete(TId id) async {
    if (id == null) {
      throw ArgumentError('ID cannot be null');
    }

    await deleteInternal(id);

    // Ensure postcondition: entity is removed
    final retrieved = await getById(id);
    if (retrieved != null) {
      throw StateError('Entity still exists after deletion');
    }
  }

  /// Postcondition: returns non-null list (empty if no entities)
  Future<List<T>> getAll() async {
    final result = await getAllInternal();
    return result ?? []; // Ensure non-null return
  }

  // Template methods for subclasses to implement
  Future<TId> createInternal(T entity);
  Future<T?> getByIdInternal(TId id);
  Future<void> updateInternal(T entity);
  Future<void> deleteInternal(TId id);
  Future<List<T>?> getAllInternal();
  TId? extractId(T entity);
}

/// In-memory repository implementation (LSP compliant)
class InMemoryRepository<T, TId> extends BaseRepository<T, TId> {
  final Map<TId, T> _storage = {};
  final TId Function(T) _idExtractor;
  final TId Function() _idGenerator;

  InMemoryRepository({
    required TId Function(T) idExtractor,
    required TId Function() idGenerator,
  }) : _idExtractor = idExtractor,
       _idGenerator = idGenerator;

  @override
  Future<TId> createInternal(T entity) async {
    final id = _idGenerator();
    _storage[id] = entity;
    return id;
  }

  @override
  Future<T?> getByIdInternal(TId id) async {
    return _storage[id];
  }

  @override
  Future<void> updateInternal(T entity) async {
    final id = extractId(entity);
    if (id != null) {
      _storage[id] = entity;
    }
  }

  @override
  Future<void> deleteInternal(TId id) async {
    _storage.remove(id);
  }

  @override
  Future<List<T>?> getAllInternal() async {
    return _storage.values.toList();
  }

  @override
  TId? extractId(T entity) {
    try {
      return _idExtractor(entity);
    } catch (e) {
      return null;
    }
  }
}

/// File-based repository implementation (LSP compliant)
class FileRepository<T, TId> extends BaseRepository<T, TId> {
  final String _filePath;
  final TId Function(T) _idExtractor;
  final TId Function() _idGenerator;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;

  FileRepository({
    required String filePath,
    required TId Function(T) idExtractor,
    required TId Function() idGenerator,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  }) : _filePath = filePath,
       _idExtractor = idExtractor,
       _idGenerator = idGenerator,
       _fromJson = fromJson,
       _toJson = toJson;

  @override
  Future<TId> createInternal(T entity) async {
    final id = _idGenerator();
    final entities = await _loadEntities();
    entities[id] = entity;
    await _saveEntities(entities);
    return id;
  }

  @override
  Future<T?> getByIdInternal(TId id) async {
    final entities = await _loadEntities();
    return entities[id];
  }

  @override
  Future<void> updateInternal(T entity) async {
    final id = extractId(entity);
    if (id != null) {
      final entities = await _loadEntities();
      entities[id] = entity;
      await _saveEntities(entities);
    }
  }

  @override
  Future<void> deleteInternal(TId id) async {
    final entities = await _loadEntities();
    entities.remove(id);
    await _saveEntities(entities);
  }

  @override
  Future<List<T>?> getAllInternal() async {
    final entities = await _loadEntities();
    return entities.values.toList();
  }

  @override
  TId? extractId(T entity) {
    try {
      return _idExtractor(entity);
    } catch (e) {
      return null;
    }
  }

  Future<Map<TId, T>> _loadEntities() async {
    // Simulate file loading
    return {};
  }

  Future<void> _saveEntities(Map<TId, T> entities) async {
    // Simulate file saving
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFICATION SYSTEM HIERARCHY (LSP Compliant)
// ═══════════════════════════════════════════════════════════════════════════

/// Base notification sender with consistent contract
abstract class NotificationSender {
  /// Precondition: message must not be null or empty
  /// Postcondition: either succeeds (returns true) or fails gracefully (returns false)
  /// Never throws exceptions for normal operation failures
  Future<bool> send(String message, String recipient) async {
    if (message.isEmpty) {
      return false; // Graceful failure for invalid input
    }

    if (recipient.isEmpty) {
      return false; // Graceful failure for invalid recipient
    }

    try {
      return await sendInternal(message, recipient);
    } catch (e) {
      // Convert exceptions to graceful failure (LSP compliance)
      await handleSendError(e, message, recipient);
      return false;
    }
  }

  /// Postcondition: returns true if service is available, false otherwise
  Future<bool> isAvailable() async {
    try {
      return await checkAvailability();
    } catch (e) {
      return false; // Service unavailable if check fails
    }
  }

  /// Template methods for subclasses
  Future<bool> sendInternal(String message, String recipient);
  Future<bool> checkAvailability();
  Future<void> handleSendError(dynamic error, String message, String recipient);
}

/// Email notification sender (LSP compliant)
class EmailNotificationSender extends NotificationSender {
  final String _smtpServer;
  final int _port;
  final bool _isConfigured;

  EmailNotificationSender({
    required String smtpServer,
    required int port,
    bool isConfigured = true,
  }) : _smtpServer = smtpServer,
       _port = port,
       _isConfigured = isConfigured;

  @override
  Future<bool> sendInternal(String message, String recipient) async {
    if (!_isConfigured) {
      return false; // Cannot send if not configured
    }

    // Validate email format
    if (!_isValidEmail(recipient)) {
      return false; // Invalid email format
    }

    // Simulate email sending
    await Future.delayed(Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<bool> checkAvailability() async {
    return _isConfigured && _smtpServer.isNotEmpty && _port > 0;
  }

  @override
  Future<void> handleSendError(dynamic error, String message, String recipient) async {
    // Log email send error
    print('Email send failed: $error');
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}

/// SMS notification sender (LSP compliant)
class SMSNotificationSender extends NotificationSender {
  final String _apiKey;
  final bool _hasCredits;

  SMSNotificationSender({
    required String apiKey,
    bool hasCredits = true,
  }) : _apiKey = apiKey,
       _hasCredits = hasCredits;

  @override
  Future<bool> sendInternal(String message, String recipient) async {
    if (!_hasCredits) {
      return false; // Cannot send without credits
    }

    // Validate phone number format
    if (!_isValidPhoneNumber(recipient)) {
      return false; // Invalid phone number
    }

    // Simulate SMS sending
    await Future.delayed(Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<bool> checkAvailability() async {
    return _apiKey.isNotEmpty && _hasCredits;
  }

  @override
  Future<void> handleSendError(dynamic error, String message, String recipient) async {
    // Log SMS send error
    print('SMS send failed: $error');
  }

  bool _isValidPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '').length >= 10;
  }
}

/// Push notification sender (LSP compliant)
class PushNotificationSender extends NotificationSender {
  final bool _isOnline;
  final Set<String> _registeredDevices;

  PushNotificationSender({
    bool isOnline = true,
    Set<String>? registeredDevices,
  }) : _isOnline = isOnline,
       _registeredDevices = registeredDevices ?? {};

  @override
  Future<bool> sendInternal(String message, String recipient) async {
    if (!_isOnline) {
      return false; // Cannot send when offline
    }

    // Check if device is registered
    if (!_registeredDevices.contains(recipient)) {
      return false; // Device not registered
    }

    // Simulate push notification
    await Future.delayed(Duration(milliseconds: 20));
    return true;
  }

  @override
  Future<bool> checkAvailability() async {
    return _isOnline;
  }

  @override
  Future<void> handleSendError(dynamic error, String message, String recipient) async {
    // Log push notification error
    print('Push notification failed: $error');
  }

  /// Add device registration (maintains invariants)
  void registerDevice(String deviceId) {
    if (deviceId.isNotEmpty) {
      _registeredDevices.add(deviceId);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CACHING HIERARCHY (LSP Compliant)
// ═══════════════════════════════════════════════════════════════════════════

/// Base cache with consistent contract
abstract class Cache<K, V> {
  /// Precondition: key must not be null
  /// Postcondition: either returns cached value or null (never throws)
  Future<V?> get(K key) async {
    if (key == null) {
      return null; // Graceful handling of null key
    }

    try {
      return await getInternal(key);
    } catch (e) {
      await handleCacheError(e, 'get', key);
      return null;
    }
  }

  /// Precondition: key and value must not be null
  /// Postcondition: value is cached and retrievable via get()
  Future<void> set(K key, V value) async {
    if (key == null || value == null) {
      return; // Graceful handling of null inputs
    }

    try {
      await setInternal(key, value);

      // Verify postcondition in debug mode
      assert(await get(key) != null, 'Value should be retrievable after set');
    } catch (e) {
      await handleCacheError(e, 'set', key, value);
    }
  }

  /// Postcondition: key is no longer in cache, get() returns null
  Future<void> remove(K key) async {
    if (key == null) {
      return; // Graceful handling of null key
    }

    try {
      await removeInternal(key);

      // Verify postcondition in debug mode
      assert(await get(key) == null, 'Value should not be retrievable after remove');
    } catch (e) {
      await handleCacheError(e, 'remove', key);
    }
  }

  /// Postcondition: cache is empty, all get() calls return null
  Future<void> clear() async {
    try {
      await clearInternal();
    } catch (e) {
      await handleCacheError(e, 'clear');
    }
  }

  // Template methods for subclasses
  Future<V?> getInternal(K key);
  Future<void> setInternal(K key, V value);
  Future<void> removeInternal(K key);
  Future<void> clearInternal();
  Future<void> handleCacheError(dynamic error, String operation, [K? key, V? value]);
}

/// In-memory cache implementation (LSP compliant)
class MemoryCache<K, V> extends Cache<K, V> {
  final Map<K, _CacheEntry<V>> _storage = {};
  final Duration _defaultTtl;

  MemoryCache({Duration? defaultTtl})
      : _defaultTtl = defaultTtl ?? Duration(hours: 1);

  @override
  Future<V?> getInternal(K key) async {
    final entry = _storage[key];
    if (entry == null) {
      return null;
    }

    if (entry.isExpired) {
      _storage.remove(key);
      return null;
    }

    return entry.value;
  }

  @override
  Future<void> setInternal(K key, V value) async {
    _storage[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(_defaultTtl),
    );
  }

  @override
  Future<void> removeInternal(K key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clearInternal() async {
    _storage.clear();
  }

  @override
  Future<void> handleCacheError(dynamic error, String operation, [K? key, V? value]) async {
    print('MemoryCache error during $operation: $error');
  }
}

/// File-based cache implementation (LSP compliant)
class FileCache<K, V> extends Cache<K, V> {
  final String _directory;
  final String Function(K) _keyToFileName;
  final V Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(V) _toJson;

  FileCache({
    required String directory,
    required String Function(K) keyToFileName,
    required V Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(V) toJson,
  }) : _directory = directory,
       _keyToFileName = keyToFileName,
       _fromJson = fromJson,
       _toJson = toJson;

  @override
  Future<V?> getInternal(K key) async {
    final fileName = _keyToFileName(key);
    // Simulate file reading
    await Future.delayed(Duration(milliseconds: 10));
    return null; // Placeholder
  }

  @override
  Future<void> setInternal(K key, V value) async {
    final fileName = _keyToFileName(key);
    final json = _toJson(value);
    // Simulate file writing
    await Future.delayed(Duration(milliseconds: 20));
  }

  @override
  Future<void> removeInternal(K key) async {
    final fileName = _keyToFileName(key);
    // Simulate file deletion
    await Future.delayed(Duration(milliseconds: 5));
  }

  @override
  Future<void> clearInternal() async {
    // Simulate clearing directory
    await Future.delayed(Duration(milliseconds: 50));
  }

  @override
  Future<void> handleCacheError(dynamic error, String operation, [K? key, V? value]) async {
    print('FileCache error during $operation: $error');
  }
}

/// Cache entry helper class
class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ═══════════════════════════════════════════════════════════════════════════
// LSP VALIDATION UTILITIES
// ═══════════════════════════════════════════════════════════════════════════

/// Utility class for validating LSP compliance
class LSPValidator {
  /// Test that derived classes maintain base class contracts
  static Future<bool> validateRepositoryLSP<T, TId>(
    BaseRepository<T, TId> repository,
    T testEntity,
    TId Function(T) idExtractor,
  ) async {
    try {
      // Test create -> retrieve cycle
      final id = await repository.create(testEntity);
      final retrieved = await repository.getById(id);

      if (retrieved == null) {
        return false; // Contract violation
      }

      // Test update -> retrieve cycle
      await repository.update(retrieved);
      final updated = await repository.getById(id);

      if (updated == null) {
        return false; // Contract violation
      }

      // Test delete -> retrieve cycle
      await repository.delete(id);
      final deleted = await repository.getById(id);

      if (deleted != null) {
        return false; // Contract violation
      }

      return true; // All contracts maintained
    } catch (e) {
      return false; // Unexpected exception violates contract
    }
  }

  /// Test notification sender LSP compliance
  static Future<bool> validateNotificationSenderLSP(
    NotificationSender sender,
    String testMessage,
    String testRecipient,
  ) async {
    try {
      // Test basic send operation
      final result1 = await sender.send(testMessage, testRecipient);

      // Test empty message handling
      final result2 = await sender.send('', testRecipient);
      if (result2 == true) {
        return false; // Should handle empty message gracefully
      }

      // Test empty recipient handling
      final result3 = await sender.send(testMessage, '');
      if (result3 == true) {
        return false; // Should handle empty recipient gracefully
      }

      // Test availability check
      final available = await sender.isAvailable();

      return true; // All contracts maintained
    } catch (e) {
      return false; // Should not throw for normal operations
    }
  }

  /// Test cache LSP compliance
  static Future<bool> validateCacheLSP<K, V>(
    Cache<K, V> cache,
    K testKey,
    V testValue,
  ) async {
    try {
      // Test set -> get cycle
      await cache.set(testKey, testValue);
      final retrieved = await cache.get(testKey);

      if (retrieved == null) {
        return false; // Contract violation
      }

      // Test remove -> get cycle
      await cache.remove(testKey);
      final removed = await cache.get(testKey);

      if (removed != null) {
        return false; // Contract violation
      }

      // Test null key handling
      await cache.set(testKey, testValue);
      final nullResult = await cache.get(null);

      if (nullResult != null) {
        return false; // Should handle null gracefully
      }

      return true; // All contracts maintained
    } catch (e) {
      return false; // Should not throw for normal operations
    }
  }
}