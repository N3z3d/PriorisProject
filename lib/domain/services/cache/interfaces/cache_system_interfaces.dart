/// Supported cache strategies for high level components.
enum CacheStrategy { lru, lfu, ttl, adaptive }

/// Base exception raised by the caching subsystem.
class CacheException implements Exception {
  CacheException(this.message, {this.details});

  final String message;
  final Map<String, Object?>? details;

  @override
  String toString() {
    final extra =
        details == null || details!.isEmpty ? '' : ' details=${details}';
    return 'CacheException: $message$extra';
  }
}

/// Contract shared by cache entries regardless of the backing storage.
abstract class ICacheEntry {
  dynamic get value;
  int get sizeBytes;
  int get priority;
  int get frequency;
  DateTime get createdAt;
  DateTime get lastAccessed;
  DateTime? get expiresAt;
  bool get isExpired;
  int get ageInSeconds;
  double calculateAdaptiveScore();
  void updateAccess();
  void incrementFrequency();
}
