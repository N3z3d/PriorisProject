import 'dart:collection';
import 'dart:async';

/// Service de cache avancé avec stratégies LRU et LFU
/// 
/// Implémente plusieurs stratégies de cache pour optimiser
/// l'utilisation de la mémoire et les performances.
class AdvancedCacheService {
  static final AdvancedCacheService _instance = AdvancedCacheService._internal();
  factory AdvancedCacheService() => _instance;
  AdvancedCacheService._internal();

  // Configuration
  final int _maxMemoryMB = 50;
  final Duration _defaultTTL = const Duration(minutes: 10);
  
  // Caches avec différentes stratégies
  late final LRUCache _lruCache;
  late final LFUCache _lfuCache;
  late final TTLCache _ttlCache;
  late final AdaptiveCache _adaptiveCache;
  
  // Statistiques
  final CacheStatistics _stats = CacheStatistics();
  
  // Stratégie actuelle
  CacheStrategy _currentStrategy = CacheStrategy.adaptive;

  void initialize({
    int? maxMemoryMB,
    CacheStrategy? defaultStrategy,
  }) {
    if (maxMemoryMB != null) {
      _lruCache = LRUCache(maxSizeMB: maxMemoryMB ~/ 4);
      _lfuCache = LFUCache(maxSizeMB: maxMemoryMB ~/ 4);
      _ttlCache = TTLCache(maxSizeMB: maxMemoryMB ~/ 4);
      _adaptiveCache = AdaptiveCache(maxSizeMB: maxMemoryMB ~/ 4);
    } else {
      _lruCache = LRUCache(maxSizeMB: _maxMemoryMB ~/ 4);
      _lfuCache = LFUCache(maxSizeMB: _maxMemoryMB ~/ 4);
      _ttlCache = TTLCache(maxSizeMB: _maxMemoryMB ~/ 4);
      _adaptiveCache = AdaptiveCache(maxSizeMB: _maxMemoryMB ~/ 4);
    }
    
    if (defaultStrategy != null) {
      _currentStrategy = defaultStrategy;
    }
  }

  /// Récupère une valeur du cache
  T? get<T>(String key, {CacheStrategy? strategy}) {
    _stats.recordAccess();
    
    final cache = _getCache(strategy ?? _currentStrategy);
    final value = cache.get<T>(key);
    
    if (value != null) {
      _stats.recordHit();
    } else {
      _stats.recordMiss();
    }
    
    return value;
  }

  /// Ajoute une valeur au cache
  void set<T>(
    String key,
    T value, {
    Duration? ttl,
    CacheStrategy? strategy,
    int? priority,
  }) {
    final cache = _getCache(strategy ?? _currentStrategy);
    cache.set(key, value, ttl: ttl ?? _defaultTTL, priority: priority);
    _stats.recordWrite();
  }

  /// Récupère ou calcule une valeur
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
    CacheStrategy? strategy,
  }) async {
    final cached = get<T>(key, strategy: strategy);
    if (cached != null) return cached;
    
    final value = await compute();
    set(key, value, ttl: ttl, strategy: strategy);
    return value;
  }

  /// Invalide une entrée du cache
  void invalidate(String key) {
    _lruCache.remove(key);
    _lfuCache.remove(key);
    _ttlCache.remove(key);
    _adaptiveCache.remove(key);
    _stats.recordEviction();
  }

  /// Invalide toutes les entrées correspondant à un pattern
  void invalidatePattern(String pattern) {
    final regex = RegExp(pattern);
    
    _lruCache.removeWhere((key) => regex.hasMatch(key));
    _lfuCache.removeWhere((key) => regex.hasMatch(key));
    _ttlCache.removeWhere((key) => regex.hasMatch(key));
    _adaptiveCache.removeWhere((key) => regex.hasMatch(key));
  }

  /// Vide complètement le cache
  void clear() {
    _lruCache.clear();
    _lfuCache.clear();
    _ttlCache.clear();
    _adaptiveCache.clear();
    _stats.reset();
  }

  /// Change la stratégie de cache
  void setStrategy(CacheStrategy strategy) {
    _currentStrategy = strategy;
  }

  /// Récupère les statistiques du cache
  Map<String, dynamic> getStatistics() {
    return {
      'currentStrategy': _currentStrategy.toString(),
      'stats': _stats.toMap(),
      'lru': _lruCache.getStats(),
      'lfu': _lfuCache.getStats(),
      'ttl': _ttlCache.getStats(),
      'adaptive': _adaptiveCache.getStats(),
    };
  }

  /// Optimise le cache en supprimant les entrées inutiles
  void optimize() {
    _lruCache.optimize();
    _lfuCache.optimize();
    _ttlCache.optimize();
    _adaptiveCache.optimize();
  }

  BaseCache _getCache(CacheStrategy strategy) {
    switch (strategy) {
      case CacheStrategy.lru:
        return _lruCache;
      case CacheStrategy.lfu:
        return _lfuCache;
      case CacheStrategy.ttl:
        return _ttlCache;
      case CacheStrategy.adaptive:
        return _adaptiveCache;
    }
  }
}

/// Stratégies de cache disponibles
enum CacheStrategy {
  lru,      // Least Recently Used
  lfu,      // Least Frequently Used
  ttl,      // Time To Live
  adaptive, // Stratégie adaptative
}

/// Classe de base pour les implémentations de cache
abstract class BaseCache {
  final int maxSizeMB;
  int _currentSizeBytes = 0;
  
  BaseCache({required this.maxSizeMB});
  
  T? get<T>(String key);
  void set<T>(String key, T value, {Duration? ttl, int? priority});
  void remove(String key);
  void removeWhere(bool Function(String) test);
  void clear();
  void optimize();
  Map<String, dynamic> getStats();
  
  int _estimateSize(dynamic value) {
    // Estimation simplifiée de la taille en mémoire
    if (value == null) return 0;
    if (value is String) return value.length * 2; // UTF-16
    if (value is int) return 8;
    if (value is double) return 8;
    if (value is bool) return 1;
    if (value is List) return value.length * 8 + 24;
    if (value is Map) return value.length * 16 + 24;
    return 100; // Estimation par défaut pour les objets
  }
  
  bool _hasSpace(int sizeBytes) {
    return (_currentSizeBytes + sizeBytes) <= (maxSizeMB * 1024 * 1024);
  }
}

/// Cache LRU (Least Recently Used)
class LRUCache extends BaseCache {
  final LinkedHashMap<String, CacheEntry> _cache = LinkedHashMap();
  
  LRUCache({required super.maxSizeMB});
  
  @override
  T? get<T>(String key) {
    final entry = _cache.remove(key);
    if (entry == null) return null;
    
    // Vérifier l'expiration
    if (entry.isExpired) {
      _currentSizeBytes -= entry.sizeBytes;
      return null;
    }
    
    // Remettre à la fin (plus récent)
    _cache[key] = entry..lastAccessed = DateTime.now();
    return entry.value as T?;
  }
  
  @override
  void set<T>(String key, T value, {Duration? ttl, int? priority}) {
    final sizeBytes = _estimateSize(value);
    
    // Faire de la place si nécessaire
    while (!_hasSpace(sizeBytes) && _cache.isNotEmpty) {
      _evictOldest();
    }
    
    // Supprimer l'ancienne entrée si elle existe
    final oldEntry = _cache.remove(key);
    if (oldEntry != null) {
      _currentSizeBytes -= oldEntry.sizeBytes;
    }
    
    // Ajouter la nouvelle entrée
    _cache[key] = CacheEntry(
      value: value,
      sizeBytes: sizeBytes,
      ttl: ttl,
      priority: priority ?? 0,
    );
    _currentSizeBytes += sizeBytes;
  }
  
  void _evictOldest() {
    if (_cache.isEmpty) return;
    
    final oldestKey = _cache.keys.first;
    final entry = _cache.remove(oldestKey);
    if (entry != null) {
      _currentSizeBytes -= entry.sizeBytes;
    }
  }
  
  @override
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSizeBytes -= entry.sizeBytes;
    }
  }
  
  @override
  void removeWhere(bool Function(String) test) {
    final keysToRemove = _cache.keys.where(test).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }
  
  @override
  void clear() {
    _cache.clear();
    _currentSizeBytes = 0;
  }
  
  @override
  void optimize() {
    // Supprimer les entrées expirées
    final expiredKeys = <String>[];
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      remove(key);
    }
  }
  
  @override
  Map<String, dynamic> getStats() {
    return {
      'type': 'LRU',
      'entries': _cache.length,
      'sizeBytes': _currentSizeBytes,
      'sizeMB': _currentSizeBytes / (1024 * 1024),
      'maxSizeMB': maxSizeMB,
      'utilization': _currentSizeBytes / (maxSizeMB * 1024 * 1024),
    };
  }
}

/// Cache LFU (Least Frequently Used)
class LFUCache extends BaseCache {
  final Map<String, CacheEntry> _cache = {};
  final SplayTreeMap<int, Set<String>> _frequencyMap = SplayTreeMap();
  int _minFrequency = 0;
  
  LFUCache({required super.maxSizeMB});
  
  @override
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Vérifier l'expiration
    if (entry.isExpired) {
      remove(key);
      return null;
    }
    
    // Mettre à jour la fréquence
    _updateFrequency(key, entry);
    return entry.value as T?;
  }
  
  void _updateFrequency(String key, CacheEntry entry) {
    final oldFreq = entry.frequency;
    final newFreq = oldFreq + 1;
    
    // Retirer de l'ancienne fréquence
    _frequencyMap[oldFreq]?.remove(key);
    if (_frequencyMap[oldFreq]?.isEmpty ?? false) {
      _frequencyMap.remove(oldFreq);
      if (_minFrequency == oldFreq) {
        _minFrequency = _frequencyMap.isEmpty ? 0 : _frequencyMap.keys.first;
      }
    }
    
    // Ajouter à la nouvelle fréquence
    _frequencyMap.putIfAbsent(newFreq, () => {}).add(key);
    entry.frequency = newFreq;
    entry.lastAccessed = DateTime.now();
  }
  
  @override
  void set<T>(String key, T value, {Duration? ttl, int? priority}) {
    final sizeBytes = _estimateSize(value);
    
    // Faire de la place si nécessaire
    while (!_hasSpace(sizeBytes) && _cache.isNotEmpty) {
      _evictLeastFrequent();
    }
    
    // Supprimer l'ancienne entrée si elle existe
    if (_cache.containsKey(key)) {
      remove(key);
    }
    
    // Ajouter la nouvelle entrée
    final entry = CacheEntry(
      value: value,
      sizeBytes: sizeBytes,
      ttl: ttl,
      priority: priority ?? 0,
      frequency: 1,
    );
    
    _cache[key] = entry;
    _frequencyMap.putIfAbsent(1, () => {}).add(key);
    _minFrequency = 1;
    _currentSizeBytes += sizeBytes;
  }
  
  void _evictLeastFrequent() {
    if (_frequencyMap.isEmpty) return;
    
    final leastFreqKeys = _frequencyMap[_minFrequency];
    if (leastFreqKeys == null || leastFreqKeys.isEmpty) return;
    
    // Éviction de la plus ancienne entrée avec la fréquence minimale
    String? keyToEvict;
    DateTime? oldestTime;
    
    for (final key in leastFreqKeys) {
      final entry = _cache[key];
      if (entry != null) {
        if (oldestTime == null || entry.lastAccessed.isBefore(oldestTime)) {
          oldestTime = entry.lastAccessed;
          keyToEvict = key;
        }
      }
    }
    
    if (keyToEvict != null) {
      remove(keyToEvict);
    }
  }
  
  @override
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSizeBytes -= entry.sizeBytes;
      _frequencyMap[entry.frequency]?.remove(key);
      if (_frequencyMap[entry.frequency]?.isEmpty ?? false) {
        _frequencyMap.remove(entry.frequency);
      }
    }
  }
  
  @override
  void removeWhere(bool Function(String) test) {
    final keysToRemove = _cache.keys.where(test).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }
  
  @override
  void clear() {
    _cache.clear();
    _frequencyMap.clear();
    _currentSizeBytes = 0;
    _minFrequency = 0;
  }
  
  @override
  void optimize() {
    // Supprimer les entrées expirées
    final expiredKeys = <String>[];
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      remove(key);
    }
  }
  
  @override
  Map<String, dynamic> getStats() {
    return {
      'type': 'LFU',
      'entries': _cache.length,
      'sizeBytes': _currentSizeBytes,
      'sizeMB': _currentSizeBytes / (1024 * 1024),
      'maxSizeMB': maxSizeMB,
      'utilization': _currentSizeBytes / (maxSizeMB * 1024 * 1024),
      'frequencyDistribution': Map.fromEntries(
        _frequencyMap.entries.map((e) => MapEntry(e.key, e.value.length))
      ),
    };
  }
}

/// Cache TTL (Time To Live)
class TTLCache extends BaseCache {
  final Map<String, CacheEntry> _cache = {};
  Timer? _cleanupTimer;
  
  TTLCache({required super.maxSizeMB}) {
    // Nettoyer les entrées expirées toutes les minutes
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => optimize(),
    );
  }
  
  @override
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (entry.isExpired) {
      remove(key);
      return null;
    }
    
    entry.lastAccessed = DateTime.now();
    return entry.value as T?;
  }
  
  @override
  void set<T>(String key, T value, {Duration? ttl, int? priority}) {
    final sizeBytes = _estimateSize(value);
    
    // Faire de la place si nécessaire
    while (!_hasSpace(sizeBytes) && _cache.isNotEmpty) {
      _evictExpiredOrOldest();
    }
    
    // Supprimer l'ancienne entrée si elle existe
    final oldEntry = _cache.remove(key);
    if (oldEntry != null) {
      _currentSizeBytes -= oldEntry.sizeBytes;
    }
    
    // Ajouter la nouvelle entrée
    _cache[key] = CacheEntry(
      value: value,
      sizeBytes: sizeBytes,
      ttl: ttl ?? const Duration(minutes: 10),
      priority: priority ?? 0,
    );
    _currentSizeBytes += sizeBytes;
  }
  
  void _evictExpiredOrOldest() {
    // Chercher d'abord les entrées expirées
    String? expiredKey;
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKey = entry.key;
        break;
      }
    }
    
    if (expiredKey != null) {
      remove(expiredKey);
      return;
    }
    
    // Sinon, supprimer la plus ancienne
    if (_cache.isNotEmpty) {
      String? oldestKey;
      DateTime? oldestTime;
      
      _cache.forEach((key, entry) {
        if (oldestTime == null || entry.created.isBefore(oldestTime!)) {
          oldestTime = entry.created;
          oldestKey = key;
        }
      });
      
      if (oldestKey != null) {
        remove(oldestKey!);
      }
    }
  }
  
  @override
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSizeBytes -= entry.sizeBytes;
    }
  }
  
  @override
  void removeWhere(bool Function(String) test) {
    final keysToRemove = _cache.keys.where(test).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }
  
  @override
  void clear() {
    _cache.clear();
    _currentSizeBytes = 0;
  }
  
  @override
  void optimize() {
    final expiredKeys = <String>[];
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      remove(key);
    }
  }
  
  void dispose() {
    _cleanupTimer?.cancel();
  }
  
  @override
  Map<String, dynamic> getStats() {
    int expiredCount = 0;
    _cache.forEach((_, entry) {
      if (entry.isExpired) expiredCount++;
    });
    
    return {
      'type': 'TTL',
      'entries': _cache.length,
      'expiredEntries': expiredCount,
      'sizeBytes': _currentSizeBytes,
      'sizeMB': _currentSizeBytes / (1024 * 1024),
      'maxSizeMB': maxSizeMB,
      'utilization': _currentSizeBytes / (maxSizeMB * 1024 * 1024),
    };
  }
}

/// Cache adaptatif qui combine plusieurs stratégies
class AdaptiveCache extends BaseCache {
  final Map<String, CacheEntry> _cache = {};
  final Map<String, double> _scores = {};
  
  AdaptiveCache({required super.maxSizeMB});
  
  @override
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (entry.isExpired) {
      remove(key);
      return null;
    }
    
    // Mettre à jour le score adaptatif
    _updateScore(key, entry);
    entry.lastAccessed = DateTime.now();
    entry.frequency++;
    
    return entry.value as T?;
  }
  
  void _updateScore(String key, CacheEntry entry) {
    // Score basé sur : fréquence, récence, priorité, taille
    final now = DateTime.now();
    final age = now.difference(entry.lastAccessed).inSeconds + 1;
    final frequency = entry.frequency + 1;
    final priority = entry.priority;
    final sizeWeight = 1.0 / (entry.sizeBytes / 1024 + 1); // Favoriser les petites entrées
    
    // Formule adaptative
    final score = (frequency * 10.0) / age + 
                  (priority * 5.0) + 
                  sizeWeight * 2.0;
    
    _scores[key] = score;
  }
  
  @override
  void set<T>(String key, T value, {Duration? ttl, int? priority}) {
    final sizeBytes = _estimateSize(value);
    
    // Faire de la place si nécessaire
    while (!_hasSpace(sizeBytes) && _cache.isNotEmpty) {
      _evictLowestScore();
    }
    
    // Supprimer l'ancienne entrée si elle existe
    final oldEntry = _cache.remove(key);
    if (oldEntry != null) {
      _currentSizeBytes -= oldEntry.sizeBytes;
      _scores.remove(key);
    }
    
    // Ajouter la nouvelle entrée
    final entry = CacheEntry(
      value: value,
      sizeBytes: sizeBytes,
      ttl: ttl,
      priority: priority ?? 0,
    );
    
    _cache[key] = entry;
    _scores[key] = priority?.toDouble() ?? 1.0;
    _currentSizeBytes += sizeBytes;
  }
  
  void _evictLowestScore() {
    if (_scores.isEmpty) return;
    
    String? lowestKey;
    double lowestScore = double.infinity;
    
    _scores.forEach((key, score) {
      if (score < lowestScore) {
        lowestScore = score;
        lowestKey = key;
      }
    });
    
    if (lowestKey != null) {
      remove(lowestKey!);
    }
  }
  
  @override
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSizeBytes -= entry.sizeBytes;
      _scores.remove(key);
    }
  }
  
  @override
  void removeWhere(bool Function(String) test) {
    final keysToRemove = _cache.keys.where(test).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }
  
  @override
  void clear() {
    _cache.clear();
    _scores.clear();
    _currentSizeBytes = 0;
  }
  
  @override
  void optimize() {
    // Supprimer les entrées expirées
    final expiredKeys = <String>[];
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      remove(key);
    }
    
    // Recalculer les scores
    _cache.forEach((key, entry) {
      _updateScore(key, entry);
    });
  }
  
  @override
  Map<String, dynamic> getStats() {
    double avgScore = 0;
    if (_scores.isNotEmpty) {
      avgScore = _scores.values.reduce((a, b) => a + b) / _scores.length;
    }
    
    return {
      'type': 'Adaptive',
      'entries': _cache.length,
      'sizeBytes': _currentSizeBytes,
      'sizeMB': _currentSizeBytes / (1024 * 1024),
      'maxSizeMB': maxSizeMB,
      'utilization': _currentSizeBytes / (maxSizeMB * 1024 * 1024),
      'averageScore': avgScore,
    };
  }
}

/// Entrée de cache
class CacheEntry {
  final dynamic value;
  final int sizeBytes;
  final DateTime created;
  final DateTime? expiresAt;
  final int priority;
  DateTime lastAccessed;
  int frequency;
  
  CacheEntry({
    required this.value,
    required this.sizeBytes,
    Duration? ttl,
    this.priority = 0,
    this.frequency = 1,
  }) : created = DateTime.now(),
       lastAccessed = DateTime.now(),
       expiresAt = ttl != null ? DateTime.now().add(ttl) : null;
  
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Statistiques du cache
class CacheStatistics {
  int _totalAccesses = 0;
  int _hits = 0;
  int _misses = 0;
  int _writes = 0;
  int _evictions = 0;
  final DateTime _startTime = DateTime.now();
  
  void recordAccess() => _totalAccesses++;
  void recordHit() => _hits++;
  void recordMiss() => _misses++;
  void recordWrite() => _writes++;
  void recordEviction() => _evictions++;
  
  void reset() {
    _totalAccesses = 0;
    _hits = 0;
    _misses = 0;
    _writes = 0;
    _evictions = 0;
  }
  
  double get hitRate => _totalAccesses > 0 ? _hits / _totalAccesses : 0;
  double get missRate => _totalAccesses > 0 ? _misses / _totalAccesses : 0;
  
  Map<String, dynamic> toMap() {
    final uptime = DateTime.now().difference(_startTime);
    
    return {
      'totalAccesses': _totalAccesses,
      'hits': _hits,
      'misses': _misses,
      'writes': _writes,
      'evictions': _evictions,
      'hitRate': hitRate,
      'missRate': missRate,
      'uptimeSeconds': uptime.inSeconds,
      'requestsPerSecond': uptime.inSeconds > 0 ? _totalAccesses / uptime.inSeconds : 0,
    };
  }
}