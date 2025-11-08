part of 'advanced_cache.dart';

class _CacheRecord {
  _CacheRecord({
    required this.entry,
    required this.rawValue,
    required this.compressedValue,
    required this.compressionSavings,
    this.encodedAsJson = false,
  });

  final CacheEntry entry;
  final dynamic rawValue;
  final Uint8List? compressedValue;
  final int compressionSavings;
  final bool encodedAsJson;
  final Set<String> tags = <String>{};

  static _CacheRecord fromValue({
    required dynamic value,
    required Duration ttl,
    required int priority,
    required bool compress,
  }) {
    Uint8List? compressed;
    int savings = 0;
    dynamic storedValue = value;
    var encodeAsJson = false;

    if (compress) {
      if (value is String && value.length > 128) {
        final bytes = utf8.encode(value);
        compressed = Uint8List.fromList(_zlibCodec.encode(bytes));
        savings = bytes.length - compressed.length;
        storedValue = null;
      } else if (value is List || value is Map) {
        final jsonString = jsonEncode(value);
        final bytes = utf8.encode(jsonString);
        compressed = Uint8List.fromList(_zlibCodec.encode(bytes));
        final originalSize = CacheSizeEstimator.estimateSize(value);
        savings = max(0, originalSize - compressed.length);
        storedValue = null;
        encodeAsJson = true;
        value = jsonDecode(jsonString);
      }
    }

    final sizeBytes =
        compressed?.length ?? CacheSizeEstimator.estimateSize(value);
    final entry = CacheEntry(
      value: storedValue ?? value,
      sizeBytes: sizeBytes,
      priority: priority,
      ttl: ttl,
    );

    return _CacheRecord(
      entry: entry,
      rawValue: storedValue,
      compressedValue: compressed,
      compressionSavings: max(0, savings),
      encodedAsJson: encodeAsJson,
    );
  }

  T? readValue<T>() {
    if (compressedValue != null) {
      final decoded = utf8.decode(_zlibCodec.decode(compressedValue!));
      if (encodedAsJson) {
        final dynamic jsonValue = jsonDecode(decoded);
        if (jsonValue is List) {
          if (jsonValue.isEmpty) {
            return <dynamic>[] as T;
          }
          if (jsonValue.every((element) => element is int)) {
            return List<int>.from(jsonValue) as T;
          }
          if (jsonValue.every((element) => element is double)) {
            return List<double>.from(jsonValue) as T;
          }
          if (jsonValue.every((element) => element is String)) {
            return List<String>.from(jsonValue) as T;
          }
          return List<dynamic>.from(jsonValue) as T;
        }
        if (jsonValue is Map) {
          if (jsonValue.keys.every((element) => element is String)) {
            final map = Map<String, dynamic>.from(jsonValue as Map);
            if (map.values.every((element) => element is String)) {
              return Map<String, String>.from(map) as T;
            }
            if (map.values.every((element) => element is int)) {
              return Map<String, int>.from(map.map(
                (key, value) => MapEntry(key, value as int),
              )) as T;
            }
            if (map.values.every((element) => element is double)) {
              return Map<String, double>.from(map.map(
                (key, value) => MapEntry(key, value as double),
              )) as T;
            }
            return map as T;
          }
          return Map<dynamic, dynamic>.from(jsonValue) as T;
        }
        return jsonValue as T?;
      }
      return decoded as T?;
    }
    final value = rawValue;
    if (value == null) {
      return null;
    }
    if (value is T) {
      return value;
    }
    if (value is List) {
      if (value.isEmpty) {
        return <dynamic>[] as T;
      }
      if (value.every((element) => element is int)) {
        return List<int>.from(value) as T;
      }
      if (value.every((element) => element is double)) {
        return List<double>.from(value) as T;
      }
      if (value.every((element) => element is String)) {
        return List<String>.from(value) as T;
      }
      return List<dynamic>.from(value) as T;
    }
    if (value is Map) {
      if (value.keys.every((element) => element is String)) {
        final map = Map<String, dynamic>.from(value as Map);
        if (map.values.every((element) => element is String)) {
          return Map<String, String>.from(map) as T;
        }
        if (map.values.every((element) => element is int)) {
          return Map<String, int>.from(map.map(
            (key, value) => MapEntry(key, value as int),
          )) as T;
        }
        if (map.values.every((element) => element is double)) {
          return Map<String, double>.from(map.map(
            (key, value) => MapEntry(key, value as double),
          )) as T;
        }
        return map as T;
      }
      return Map<dynamic, dynamic>.from(value) as T;
    }
    return value as T?;
  }

  Map<String, Object?> serialize() => {
        'value': rawValue,
        'compressed': compressedValue,
        'priority': entry.priority,
        'frequency': entry.frequency,
        'createdAt': entry.createdAt.toIso8601String(),
        'lastAccessed': entry.lastAccessed.toIso8601String(),
        'expiresAt': entry.expiresAt?.toIso8601String(),
        'compressionSavings': compressionSavings,
        'encodedAsJson': encodedAsJson,
      };

  static _CacheRecord deserialize(Map<String, Object?> data) {
    Uint8List? compressed;
    final serialized = data['compressed'];
    if (serialized is Uint8List) {
      compressed = serialized;
    }
    final record = _CacheRecord(
      entry: CacheEntry(
        value: data['value'],
        sizeBytes: CacheSizeEstimator.estimateSize(data['value']),
        priority: data['priority'] as int? ?? 0,
        frequency: data['frequency'] as int? ?? 1,
        createdAt: DateTime.tryParse(data['createdAt'] as String? ?? ''),
        lastAccessed: DateTime.tryParse(data['lastAccessed'] as String? ?? ''),
        expiresAt: DateTime.tryParse(data['expiresAt'] as String? ?? ''),
      ),
      rawValue: data['value'],
      compressedValue: compressed,
      compressionSavings: data['compressionSavings'] as int? ?? 0,
      encodedAsJson: data['encodedAsJson'] as bool? ?? false,
    );
    return record;
  }
}

class _DynamicStorageAdapter {
  _DynamicStorageAdapter(this._delegate);

  final Object _delegate;

  Future<T?> get<T>(String key) async {
    return await (_delegate as dynamic).get<T>(key);
  }

  Future<void> set<T>(String key, T value) async {
    await (_delegate as dynamic).set<T>(key, value);
  }

  Future<void> remove(String key) async {
    await (_delegate as dynamic).remove(key);
  }

  Future<void> clear() async {
    await (_delegate as dynamic).clear();
  }

  Future<List<String>> keys() async {
    final result = await (_delegate as dynamic).keys();
    if (result is List) {
      return result.cast<String>();
    }
    return const [];
  }
}
