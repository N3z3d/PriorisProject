import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'flyweight_ui_system.dart';
import 'intrinsic_state.dart';

/// Factory for creating and managing flyweight instances
///
/// Implements the Flyweight pattern by ensuring that flyweights with
/// identical intrinsic state are shared to optimize memory usage.
class FlyweightFactory {
  static FlyweightFactory? _instance;
  static FlyweightFactory get instance => _instance ??= FlyweightFactory();

  final Map<int, UIFlyweight> _flyweights = <int, UIFlyweight>{};
  final Queue<int> _accessOrder = Queue<int>();
  final Map<int, int> _accessCount = <int, int>{};

  int _createdCount = 0;
  final int _maxCacheSize;

  FlyweightFactory({int maxCacheSize = 1000}) : _maxCacheSize = maxCacheSize;

  /// Gets or creates a flyweight for the given intrinsic state
  UIFlyweight getFlyweight(IntrinsicState intrinsicState) {
    final key = intrinsicState.hashCode;

    // Check if flyweight already exists
    if (_flyweights.containsKey(key)) {
      _updateAccessTracking(key);
      return _flyweights[key]!;
    }

    // Check cache size and evict if necessary
    if (_flyweights.length >= _maxCacheSize) {
      _evictLeastUsed();
    }

    // Create new flyweight
    final flyweight = _createFlyweight(intrinsicState);
    _flyweights[key] = flyweight;
    _createdCount++;
    _updateAccessTracking(key);

    if (kDebugMode) {
      print('🎯 Created flyweight #$_createdCount (cache size: ${_flyweights.length})');
    }

    return flyweight;
  }

  /// Creates appropriate flyweight based on intrinsic state type
  UIFlyweight _createFlyweight(IntrinsicState intrinsicState) {
    if (intrinsicState is ButtonIntrinsicState) {
      return ButtonFlyweight(intrinsicState);
    } else if (intrinsicState is CardIntrinsicState) {
      return CardFlyweight(intrinsicState);
    } else if (intrinsicState is AnimatedIntrinsicState) {
      return AnimatedFlyweight(intrinsicState);
    } else {
      return GenericUIFlyweight(intrinsicState);
    }
  }

  /// Updates access tracking for LRU eviction
  void _updateAccessTracking(int key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
    _accessCount[key] = (_accessCount[key] ?? 0) + 1;
  }

  /// Evicts the least recently used flyweight
  void _evictLeastUsed() {
    if (_accessOrder.isEmpty) return;

    final lruKey = _accessOrder.removeFirst();
    _flyweights.remove(lruKey);
    _accessCount.remove(lruKey);

    if (kDebugMode) {
      print('🗑️ Evicted flyweight (cache size: ${_flyweights.length})');
    }
  }

  /// Gets the number of flyweights created
  int get createdCount => _createdCount;

  /// Gets the current cache size
  int getCacheSize() => _flyweights.length;

  /// Gets memory usage statistics
  MemoryStatistics getMemoryStatistics() {
    final totalRequests = _accessCount.values.fold(0, (sum, count) => sum + count);
    final uniqueFlyweights = _flyweights.length;

    return MemoryStatistics(
      totalFlyweights: uniqueFlyweights,
      totalRequests: totalRequests,
      memoryEfficiencyRatio: uniqueFlyweights > 0 ? totalRequests / uniqueFlyweights : 0.0,
      averageReuseRate: uniqueFlyweights > 0 ? totalRequests / uniqueFlyweights : 0.0,
      cacheHitRate: totalRequests > 0 ? (totalRequests - _createdCount) / totalRequests : 0.0,
      estimatedMemorySaved: _calculateMemorySavings(),
    );
  }

  /// Calculates estimated memory savings from flyweight pattern
  int _calculateMemorySavings() {
    if (_flyweights.isEmpty) return 0;

    const baseObjectSize = 128; // Estimated bytes per widget object
    final totalObjects = _accessCount.values.fold(0, (sum, count) => sum + count);
    final actualObjects = _flyweights.length;

    return (totalObjects - actualObjects) * baseObjectSize;
  }

  /// Clears all cached flyweights
  void clear() {
    _flyweights.clear();
    _accessOrder.clear();
    _accessCount.clear();
    _createdCount = 0;

    if (kDebugMode) {
      print('🧹 Cleared all flyweights');
    }
  }

  /// Gets detailed cache statistics
  Map<String, dynamic> getCacheStatistics() {
    return {
      'cache_size': _flyweights.length,
      'max_cache_size': _maxCacheSize,
      'created_count': _createdCount,
      'total_requests': _accessCount.values.fold(0, (sum, count) => sum + count),
      'cache_utilization': _maxCacheSize > 0 ? _flyweights.length / _maxCacheSize : 0.0,
      'most_used_flyweight': _getMostUsedFlyweight(),
      'access_distribution': _getAccessDistribution(),
    };
  }

  Map<String, int> _getMostUsedFlyweight() {
    if (_accessCount.isEmpty) return {};

    final mostUsed = _accessCount.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return {
      'hash_code': mostUsed.key,
      'access_count': mostUsed.value,
    };
  }

  Map<String, int> _getAccessDistribution() {
    final distribution = <String, int>{
      '1': 0,
      '2-5': 0,
      '6-10': 0,
      '11-50': 0,
      '50+': 0,
    };

    for (final count in _accessCount.values) {
      if (count == 1) {
        distribution['1'] = distribution['1']! + 1;
      } else if (count <= 5) {
        distribution['2-5'] = distribution['2-5']! + 1;
      } else if (count <= 10) {
        distribution['6-10'] = distribution['6-10']! + 1;
      } else if (count <= 50) {
        distribution['11-50'] = distribution['11-50']! + 1;
      } else {
        distribution['50+'] = distribution['50+']! + 1;
      }
    }

    return distribution;
  }

  /// Disposes the factory and clears all resources
  void dispose() {
    clear();
    _instance = null;

    if (kDebugMode) {
      print('🗑️ Flyweight factory disposed');
    }
  }
}

/// Factory for creating custom widget flyweights
class CustomWidgetFlyweightFactory {
  final Map<String, UIFlyweight> _customFlyweights = <String, UIFlyweight>{};

  /// Creates a button flyweight with specific styling
  ButtonFlyweight createButtonFlyweight(ButtonIntrinsicState intrinsicState) {
    final key = 'button_${intrinsicState.hashCode}';

    return _customFlyweights.putIfAbsent(key, () {
      return ButtonFlyweight(intrinsicState);
    }) as ButtonFlyweight;
  }

  /// Creates a card flyweight with specific styling
  CardFlyweight createCardFlyweight(CardIntrinsicState intrinsicState) {
    final key = 'card_${intrinsicState.hashCode}';

    return _customFlyweights.putIfAbsent(key, () {
      return CardFlyweight(intrinsicState);
    }) as CardFlyweight;
  }

  /// Creates an animated flyweight
  AnimatedFlyweight createAnimatedFlyweight(AnimatedIntrinsicState intrinsicState) {
    final key = 'animated_${intrinsicState.hashCode}';

    return _customFlyweights.putIfAbsent(key, () {
      return AnimatedFlyweight(intrinsicState);
    }) as AnimatedFlyweight;
  }

  /// Gets the number of cached custom flyweights
  int getCacheSize() => _customFlyweights.length;

  /// Clears all custom flyweights
  void clear() {
    _customFlyweights.clear();
  }
}

/// Factory for managing dynamic flyweight creation and cleanup
class DynamicFlyweightFactory extends FlyweightFactory {
  final Duration _cleanupInterval;
  final int _maxIdleTime;

  late final Map<int, DateTime> _lastAccess = <int, DateTime>{};

  DynamicFlyweightFactory({
    super.maxCacheSize,
    Duration cleanupInterval = const Duration(minutes: 5),
    int maxIdleTimeMinutes = 30,
  }) : _cleanupInterval = cleanupInterval,
       _maxIdleTime = maxIdleTimeMinutes {

    _startPeriodicCleanup();
  }

  @override
  UIFlyweight getFlyweight(IntrinsicState intrinsicState) {
    final key = intrinsicState.hashCode;
    _lastAccess[key] = DateTime.now();

    return super.getFlyweight(intrinsicState);
  }

  /// Starts periodic cleanup of unused flyweights
  void _startPeriodicCleanup() {
    Stream.periodic(_cleanupInterval).listen((_) {
      _cleanupUnusedFlyweights();
    });
  }

  /// Removes flyweights that haven't been accessed recently
  void _cleanupUnusedFlyweights() {
    final now = DateTime.now();
    final keysToRemove = <int>[];

    for (final entry in _lastAccess.entries) {
      final idleTime = now.difference(entry.value).inMinutes;
      if (idleTime > _maxIdleTime) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _flyweights.remove(key);
      _lastAccess.remove(key);
      _accessCount.remove(key);
      _accessOrder.remove(key);
    }

    if (keysToRemove.isNotEmpty && kDebugMode) {
      print('🧹 Cleaned up ${keysToRemove.length} idle flyweights');
    }
  }

  @override
  void dispose() {
    _lastAccess.clear();
    super.dispose();
  }
}

/// Factory for theme-aware flyweights
class ThemeAwareFlyweightFactory extends FlyweightFactory {
  final Map<String, Map<int, UIFlyweight>> _themedFlyweights =
      <String, Map<int, UIFlyweight>>{};

  String _currentTheme = 'default';

  /// Sets the current theme
  void setTheme(String theme) {
    _currentTheme = theme;
  }

  @override
  UIFlyweight getFlyweight(IntrinsicState intrinsicState) {
    final themeCache = _themedFlyweights.putIfAbsent(
      _currentTheme,
      () => <int, UIFlyweight>{},
    );

    final key = intrinsicState.hashCode;

    if (themeCache.containsKey(key)) {
      _updateAccessTracking(key);
      return themeCache[key]!;
    }

    final flyweight = _createFlyweight(intrinsicState);
    themeCache[key] = flyweight;
    _createdCount++;
    _updateAccessTracking(key);

    return flyweight;
  }

  /// Gets flyweight count for current theme
  int getThemeFlyweightCount() {
    return _themedFlyweights[_currentTheme]?.length ?? 0;
  }

  /// Gets all available themes
  List<String> getAvailableThemes() {
    return _themedFlyweights.keys.toList();
  }

  @override
  void clear() {
    _themedFlyweights.clear();
    super.clear();
  }
}

/// Statistics about flyweight memory usage
class MemoryStatistics {
  final int totalFlyweights;
  final int totalRequests;
  final double memoryEfficiencyRatio;
  final double averageReuseRate;
  final double cacheHitRate;
  final int estimatedMemorySaved;

  const MemoryStatistics({
    required this.totalFlyweights,
    required this.totalRequests,
    required this.memoryEfficiencyRatio,
    required this.averageReuseRate,
    required this.cacheHitRate,
    required this.estimatedMemorySaved,
  });

  /// Memory efficiency percentage (0-100)
  double get efficiencyPercentage => (memoryEfficiencyRatio * 100).clamp(0, 100);

  /// Cache hit rate percentage (0-100)
  double get hitRatePercentage => (cacheHitRate * 100).clamp(0, 100);

  Map<String, dynamic> toJson() {
    return {
      'total_flyweights': totalFlyweights,
      'total_requests': totalRequests,
      'memory_efficiency_ratio': memoryEfficiencyRatio,
      'average_reuse_rate': averageReuseRate,
      'cache_hit_rate': cacheHitRate,
      'estimated_memory_saved_bytes': estimatedMemorySaved,
      'efficiency_percentage': efficiencyPercentage,
      'hit_rate_percentage': hitRatePercentage,
    };
  }

  @override
  String toString() {
    return 'MemoryStatistics('
           'flyweights: $totalFlyweights, '
           'requests: $totalRequests, '
           'efficiency: ${efficiencyPercentage.toStringAsFixed(1)}%, '
           'hit rate: ${hitRatePercentage.toStringAsFixed(1)}%'
           ')';
  }
}