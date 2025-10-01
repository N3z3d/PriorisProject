/// **COMPUTE EXECUTOR INTERFACE** - DIP Compliance
abstract class IComputeExecutor {
  Future<T> execute<T, P>(T Function(P) callback, P parameter);
  Future<Map<String, dynamic>> getStats();
  Future<void> dispose();
}

/// **CACHE MANAGER INTERFACE** - DIP Compliance  
abstract class ICacheManager {
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T value);
  Future<Map<String, dynamic>> getStats();
  Future<void> dispose();
}

/// **QUEUE MANAGER INTERFACE** - DIP Compliance
abstract class IQueueManager {
  Future<T> enqueue<T>(Future<T> Function() task);
  Future<Map<String, dynamic>> getStats();
  Future<void> dispose();
}