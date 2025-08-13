import 'dart:async';
import 'interfaces/cache_interface.dart';

/// Classe abstraite pour les services de cache
/// 
/// Respecte le principe Open/Closed en permettant l'extension
/// via l'héritage tout en définissant un comportement de base commun.
abstract class AbstractCacheService<T> implements CacheInterface<T> {
  
  /// Stockage interne des données
  final Map<String, T> _storage = {};
  
  /// Méta-données pour chaque entrée
  final Map<String, CacheMetadata> _metadata = {};
  
  /// Taille maximale du cache
  final int maxSize;
  
  /// Stratégie d'éviction par défaut
  final EvictionStrategy evictionStrategy;

  AbstractCacheService({
    this.maxSize = 1000,
    this.evictionStrategy = EvictionStrategy.lru,
  });

  @override
  Future<void> set(String key, T value) async {
    await beforeSet(key, value);
    
    if (_storage.length >= maxSize) {
      await evictEntries(1);
    }
    
    _storage[key] = value;
    _metadata[key] = CacheMetadata(
      accessTime: DateTime.now(),
      creationTime: DateTime.now(),
    );
    
    await afterSet(key, value);
  }

  @override
  Future<T?> get(String key) async {
    await beforeGet(key);
    
    final value = _storage[key];
    
    if (value != null) {
      // Mettre à jour le temps d'accès
      final metadata = _metadata[key];
      if (metadata != null) {
        _metadata[key] = metadata.copyWith(accessTime: DateTime.now());
      }
      await onCacheHit(key, value);
    } else {
      await onCacheMiss(key);
    }
    
    await afterGet(key, value);
    return value;
  }

  @override
  Future<void> remove(String key) async {
    await beforeRemove(key);
    
    _storage.remove(key);
    _metadata.remove(key);
    
    await afterRemove(key);
  }

  @override
  Future<bool> exists(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await beforeClear();
    
    _storage.clear();
    _metadata.clear();
    
    await afterClear();
  }

  /// Évince des entrées selon la stratégie définie
  Future<void> evictEntries(int count) async {
    final keysToEvict = selectKeysForEviction(count);
    
    for (final key in keysToEvict) {
      await remove(key);
    }
  }

  /// Sélectionne les clés à évincer selon la stratégie
  List<String> selectKeysForEviction(int count) {
    switch (evictionStrategy) {
      case EvictionStrategy.lru:
        return _selectLruKeys(count);
      case EvictionStrategy.lfu:
        return _selectLfuKeys(count);
      case EvictionStrategy.fifo:
        return _selectFifoKeys(count);
      case EvictionStrategy.random:
        return _selectRandomKeys(count);
    }
  }

  /// Sélectionne les clés les moins récemment utilisées
  List<String> _selectLruKeys(int count) {
    final sortedKeys = _metadata.entries
        .toList()
        ..sort((a, b) => a.value.accessTime.compareTo(b.value.accessTime));
    
    return sortedKeys
        .take(count)
        .map((entry) => entry.key)
        .toList();
  }

  /// Sélectionne les clés les moins fréquemment utilisées
  List<String> _selectLfuKeys(int count) {
    final sortedKeys = _metadata.entries
        .toList()
        ..sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));
    
    return sortedKeys
        .take(count)
        .map((entry) => entry.key)
        .toList();
  }

  /// Sélectionne les premières clés entrées (FIFO)
  List<String> _selectFifoKeys(int count) {
    final sortedKeys = _metadata.entries
        .toList()
        ..sort((a, b) => a.value.creationTime.compareTo(b.value.creationTime));
    
    return sortedKeys
        .take(count)
        .map((entry) => entry.key)
        .toList();
  }

  /// Sélectionne des clés aléatoirement
  List<String> _selectRandomKeys(int count) {
    final keys = _storage.keys.toList();
    keys.shuffle();
    return keys.take(count).toList();
  }

  // Méthodes hooks que les classes filles peuvent redéfinir
  
  /// Appelée avant l'insertion d'une valeur
  Future<void> beforeSet(String key, T value) async {}
  
  /// Appelée après l'insertion d'une valeur
  Future<void> afterSet(String key, T value) async {}
  
  /// Appelée avant la récupération d'une valeur
  Future<void> beforeGet(String key) async {}
  
  /// Appelée après la récupération d'une valeur
  Future<void> afterGet(String key, T? value) async {}
  
  /// Appelée avant la suppression d'une valeur
  Future<void> beforeRemove(String key) async {}
  
  /// Appelée après la suppression d'une valeur
  Future<void> afterRemove(String key) async {}
  
  /// Appelée avant le vidage du cache
  Future<void> beforeClear() async {}
  
  /// Appelée après le vidage du cache
  Future<void> afterClear() async {}
  
  /// Appelée lors d'un cache hit
  Future<void> onCacheHit(String key, T value) async {
    // Incrémenter le compteur d'accès
    final metadata = _metadata[key];
    if (metadata != null) {
      _metadata[key] = metadata.copyWith(
        accessCount: metadata.accessCount + 1,
      );
    }
  }
  
  /// Appelée lors d'un cache miss
  Future<void> onCacheMiss(String key) async {}

  /// Obtient les statistiques du cache
  CacheStatistics getStatistics() {
    return CacheStatistics(
      totalEntries: _storage.length,
      maxSize: maxSize,
      evictionStrategy: evictionStrategy,
    );
  }
}

/// Stratégies d'éviction supportées
enum EvictionStrategy {
  lru,  // Least Recently Used
  lfu,  // Least Frequently Used
  fifo, // First In, First Out
  random, // Random
}

/// Métadonnées pour chaque entrée du cache
class CacheMetadata {
  final DateTime accessTime;
  final DateTime creationTime;
  final int accessCount;

  const CacheMetadata({
    required this.accessTime,
    required this.creationTime,
    this.accessCount = 1,
  });

  CacheMetadata copyWith({
    DateTime? accessTime,
    DateTime? creationTime,
    int? accessCount,
  }) {
    return CacheMetadata(
      accessTime: accessTime ?? this.accessTime,
      creationTime: creationTime ?? this.creationTime,
      accessCount: accessCount ?? this.accessCount,
    );
  }
}

/// Statistiques du cache
class CacheStatistics {
  final int totalEntries;
  final int maxSize;
  final EvictionStrategy evictionStrategy;

  const CacheStatistics({
    required this.totalEntries,
    required this.maxSize,
    required this.evictionStrategy,
  });

  double get fillRatio => totalEntries / maxSize;
  int get availableSpace => maxSize - totalEntries;
}