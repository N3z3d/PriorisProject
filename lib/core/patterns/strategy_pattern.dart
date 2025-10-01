/// Strategy Pattern Implementation following SOLID principles
///
/// Open/Closed: Easy to add new strategies without modifying existing code
/// Single Responsibility: Each strategy has one algorithm
/// Interface Segregation: Specific strategy interfaces for different contexts
/// Dependency Inversion: Context depends on strategy abstractions

import '../interfaces/application_interfaces.dart';

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY CONTEXT IMPLEMENTATIONS (OCP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base strategy context with common functionality
abstract class BaseStrategyContext<TStrategy extends Strategy>
    implements StrategyContext<TStrategy> {
  TStrategy? _strategy;
  final Map<String, TStrategy> _namedStrategies = {};

  @override
  void setStrategy(TStrategy strategy) {
    _strategy = strategy;
  }

  @override
  TStrategy get currentStrategy {
    if (_strategy == null) {
      throw StateError('No strategy set');
    }
    return _strategy!;
  }

  /// Register a named strategy
  void registerStrategy(String name, TStrategy strategy) {
    _namedStrategies[name] = strategy;
  }

  /// Use a named strategy
  void useStrategy(String name) {
    final strategy = _namedStrategies[name];
    if (strategy == null) {
      throw ArgumentError('Strategy not found: $name');
    }
    setStrategy(strategy);
  }

  /// Get all registered strategy names
  List<String> get availableStrategies => _namedStrategies.keys.toList();

  /// Check if a strategy is registered
  bool hasStrategy(String name) => _namedStrategies.containsKey(name);
}

/// Auto-selecting strategy context that chooses the best strategy
abstract class AutoSelectingStrategyContext<TInput, TOutput, TStrategy extends Strategy<TInput, TOutput>>
    extends BaseStrategyContext<TStrategy> {

  /// Execute with the best available strategy for the input
  Future<TOutput> executeWithBestStrategy(TInput input) async {
    final bestStrategy = selectBestStrategy(input);
    if (bestStrategy == null) {
      throw StateError('No suitable strategy found for input');
    }

    setStrategy(bestStrategy);
    return await currentStrategy.execute(input);
  }

  /// Select the best strategy for the given input
  TStrategy? selectBestStrategy(TInput input) {
    return _namedStrategies.values
        .where((strategy) => strategy.canExecute(input))
        .fold<TStrategy?>(null, (best, current) {
          if (best == null) return current;
          return compareStrategies(best, current, input);
        });
  }

  /// Compare two strategies to determine which is better for the input
  /// Override this method to implement custom comparison logic
  TStrategy compareStrategies(TStrategy strategy1, TStrategy strategy2, TInput input) {
    // Default: prefer the first strategy
    return strategy1;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SORTING STRATEGIES (OCP Example)
// ═══════════════════════════════════════════════════════════════════════════

/// Base sorting strategy
abstract class SortingStrategy<T> implements Strategy<List<T>, List<T>> {
  @override
  String get name;

  @override
  bool canExecute(List<T> input) => input.isNotEmpty;

  @override
  Future<List<T>> execute(List<T> input) async {
    return sort(List.from(input));
  }

  /// Sort implementation to be provided by concrete strategies
  List<T> sort(List<T> items);
}

/// Quick sort strategy
class QuickSortStrategy<T extends Comparable<T>> extends SortingStrategy<T> {
  @override
  String get name => 'QuickSort';

  @override
  bool canExecute(List<T> input) {
    return super.canExecute(input) && input.length > 10; // Prefer for larger lists
  }

  @override
  List<T> sort(List<T> items) {
    if (items.length <= 1) return items;

    final pivot = items[items.length ~/ 2];
    final less = items.where((x) => x.compareTo(pivot) < 0).toList();
    final equal = items.where((x) => x.compareTo(pivot) == 0).toList();
    final greater = items.where((x) => x.compareTo(pivot) > 0).toList();

    return [...sort(less), ...equal, ...sort(greater)];
  }
}

/// Insertion sort strategy (better for small lists)
class InsertionSortStrategy<T extends Comparable<T>> extends SortingStrategy<T> {
  @override
  String get name => 'InsertionSort';

  @override
  bool canExecute(List<T> input) {
    return super.canExecute(input) && input.length <= 20; // Prefer for smaller lists
  }

  @override
  List<T> sort(List<T> items) {
    for (int i = 1; i < items.length; i++) {
      final key = items[i];
      int j = i - 1;

      while (j >= 0 && items[j].compareTo(key) > 0) {
        items[j + 1] = items[j];
        j--;
      }
      items[j + 1] = key;
    }
    return items;
  }
}

/// Sorting context that auto-selects the best sorting strategy
class SmartSortingContext<T extends Comparable<T>>
    extends AutoSelectingStrategyContext<List<T>, List<T>, SortingStrategy<T>> {

  SmartSortingContext() {
    registerStrategy('quick', QuickSortStrategy<T>());
    registerStrategy('insertion', InsertionSortStrategy<T>());
  }

  @override
  SortingStrategy<T> compareStrategies(
    SortingStrategy<T> strategy1,
    SortingStrategy<T> strategy2,
    List<T> input
  ) {
    // Prefer insertion sort for small lists, quick sort for large lists
    if (input.length <= 20) {
      return strategy1 is InsertionSortStrategy ? strategy1 : strategy2;
    } else {
      return strategy1 is QuickSortStrategy ? strategy1 : strategy2;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CACHING STRATEGIES (OCP Example)
// ═══════════════════════════════════════════════════════════════════════════

/// Cache eviction strategy interface
abstract class CacheEvictionStrategy<K, V> implements Strategy<Map<K, V>, void> {
  @override
  bool canExecute(Map<K, V> input) => input.isNotEmpty;

  @override
  Future<void> execute(Map<K, V> input) async {
    evict(input);
  }

  /// Evict items from cache
  void evict(Map<K, V> cache);
}

/// LRU (Least Recently Used) eviction strategy
class LRUEvictionStrategy<K, V> extends CacheEvictionStrategy<K, V> {
  final int maxSize;
  final Map<K, DateTime> _accessTimes = {};

  LRUEvictionStrategy({required this.maxSize});

  @override
  String get name => 'LRU';

  @override
  void evict(Map<K, V> cache) {
    while (cache.length > maxSize) {
      // Find least recently used key
      K? lruKey;
      DateTime? oldestTime;

      for (final key in cache.keys) {
        final accessTime = _accessTimes[key];
        if (accessTime != null && (oldestTime == null || accessTime.isBefore(oldestTime))) {
          oldestTime = accessTime;
          lruKey = key;
        }
      }

      if (lruKey != null) {
        cache.remove(lruKey);
        _accessTimes.remove(lruKey);
      }
    }
  }

  /// Update access time for a key
  void updateAccessTime(K key) {
    _accessTimes[key] = DateTime.now();
  }
}

/// FIFO (First In, First Out) eviction strategy
class FIFOEvictionStrategy<K, V> extends CacheEvictionStrategy<K, V> {
  final int maxSize;
  final List<K> _insertionOrder = [];

  FIFOEvictionStrategy({required this.maxSize});

  @override
  String get name => 'FIFO';

  @override
  void evict(Map<K, V> cache) {
    while (cache.length > maxSize && _insertionOrder.isNotEmpty) {
      final keyToRemove = _insertionOrder.removeAt(0);
      cache.remove(keyToRemove);
    }
  }

  /// Track insertion order
  void trackInsertion(K key) {
    _insertionOrder.add(key);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PERSISTENCE STRATEGIES (OCP Example)
// ═══════════════════════════════════════════════════════════════════════════

/// Data persistence strategy interface
abstract class PersistenceStrategy<T> implements Strategy<T, bool> {
  @override
  Future<bool> execute(T input) async {
    try {
      await persist(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Persist data implementation
  Future<void> persist(T data);

  /// Retrieve data implementation
  Future<T?> retrieve(String key);
}

/// Local storage persistence strategy
class LocalStorageStrategy<T> extends PersistenceStrategy<T> {
  @override
  String get name => 'LocalStorage';

  @override
  bool canExecute(T input) => true; // Always available

  @override
  Future<void> persist(T data) async {
    // Implementation for local storage
    await Future.delayed(Duration(milliseconds: 10)); // Simulate storage
  }

  @override
  Future<T?> retrieve(String key) async {
    // Implementation for local retrieval
    await Future.delayed(Duration(milliseconds: 5)); // Simulate retrieval
    return null; // Placeholder
  }
}

/// Cloud storage persistence strategy
class CloudStorageStrategy<T> extends PersistenceStrategy<T> {
  final bool isOnline;

  CloudStorageStrategy({required this.isOnline});

  @override
  String get name => 'CloudStorage';

  @override
  bool canExecute(T input) => isOnline; // Only available when online

  @override
  Future<void> persist(T data) async {
    if (!isOnline) {
      throw StateError('Cannot persist to cloud while offline');
    }
    // Implementation for cloud storage
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network
  }

  @override
  Future<T?> retrieve(String key) async {
    if (!isOnline) {
      throw StateError('Cannot retrieve from cloud while offline');
    }
    // Implementation for cloud retrieval
    await Future.delayed(Duration(milliseconds: 80)); // Simulate network
    return null; // Placeholder
  }
}

/// Smart persistence context that chooses the best strategy
class SmartPersistenceContext<T>
    extends AutoSelectingStrategyContext<T, bool, PersistenceStrategy<T>> {

  SmartPersistenceContext({bool isOnline = true}) {
    registerStrategy('local', LocalStorageStrategy<T>());
    registerStrategy('cloud', CloudStorageStrategy<T>(isOnline: isOnline));
  }

  @override
  PersistenceStrategy<T> compareStrategies(
    PersistenceStrategy<T> strategy1,
    PersistenceStrategy<T> strategy2,
    T input,
  ) {
    // Prefer cloud storage when available, fallback to local
    if (strategy1 is CloudStorageStrategy && strategy1.canExecute(input)) {
      return strategy1;
    }
    if (strategy2 is CloudStorageStrategy && strategy2.canExecute(input)) {
      return strategy2;
    }
    return strategy1; // Default to first strategy
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY FACTORY (Factory Pattern + Strategy Pattern)
// ═══════════════════════════════════════════════════════════════════════════

/// Factory for creating strategies based on configuration
class StrategyFactory {
  static final Map<String, Function()> _strategyCreators = {};

  /// Register a strategy creator
  static void registerStrategy<T extends Strategy>(
    String name,
    T Function() creator,
  ) {
    _strategyCreators[name] = creator;
  }

  /// Create a strategy by name
  static T createStrategy<T extends Strategy>(String name) {
    final creator = _strategyCreators[name];
    if (creator == null) {
      throw ArgumentError('Unknown strategy: $name');
    }

    final strategy = creator();
    if (strategy is! T) {
      throw ArgumentError('Strategy $name is not of type $T');
    }

    return strategy as T;
  }

  /// Get all registered strategy names
  static List<String> get availableStrategies => _strategyCreators.keys.toList();

  /// Check if a strategy is registered
  static bool hasStrategy(String name) => _strategyCreators.containsKey(name);
}