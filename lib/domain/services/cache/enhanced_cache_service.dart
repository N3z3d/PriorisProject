import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Entrée de cache avec métadonnées
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int sizeInBytes;
  final String? etag;
  int accessCount;
  DateTime lastAccessedAt;

  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    required this.sizeInBytes,
    this.etag,
    this.accessCount = 0,
    DateTime? lastAccessedAt,
  }) : lastAccessedAt = lastAccessedAt ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  void recordAccess() {
    accessCount++;
    lastAccessedAt = DateTime.now();
  }
}

/// Stratégies de cache
enum CacheStrategy {
  /// Cache avec durée de vie fixe
  ttl,
  /// Cache avec validation ETag
  etag,
  /// Cache avec taille limitée (LRU)
  lru,
  /// Cache avec accès fréquent (LFU)
  lfu,
}

/// Service de cache amélioré avec compression et stratégies avancées
class EnhancedCacheService {
  static final EnhancedCacheService _instance = EnhancedCacheService._internal();
  factory EnhancedCacheService() => _instance;
  EnhancedCacheService._internal();

  // Cache en mémoire avec gestion LRU
  final Map<String, CacheEntry> _memoryCache = {};
  final int _maxMemoryCacheSize = 100;
  
  // Configuration
  static const Duration defaultTTL = Duration(minutes: 15);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB

  /// Met en cache une donnée avec stratégie
  Future<void> set<T>({
    required String key,
    required T data,
    Duration? ttl,
    CacheStrategy strategy = CacheStrategy.ttl,
    String? etag,
  }) async {
    final effectiveTTL = ttl ?? defaultTTL;
    final serialized = _serialize(data);
    final sizeInBytes = _calculateSize(serialized);

    // Vérifier la taille maximale
    if (sizeInBytes > maxCacheSize) {
      if (kDebugMode) {
        debugPrint('[Cache] Item trop volumineux pour être mis en cache: $key');
      }
      return;
    }

    // Appliquer la stratégie LRU si nécessaire
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _evictLRU();
    }

    // Créer l'entrée de cache
    final entry = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(effectiveTTL),
      sizeInBytes: sizeInBytes,
      etag: etag,
    );

    _memoryCache[key] = entry;
    
    // Compression pour stockage persistant si nécessaire
    if (sizeInBytes > 1024) { // Compresser si > 1KB
      await _persistCompressed(key, serialized);
    }
  }

  /// Récupère une donnée du cache
  Future<T?> get<T>(String key, {String? etag}) async {
    // Vérifier le cache mémoire
    final entry = _memoryCache[key];
    
    if (entry != null) {
      if (!entry.isExpired) {
        // Validation ETag si fourni
        if (etag != null && entry.etag != etag) {
          _memoryCache.remove(key);
          return null;
        }
        
        entry.recordAccess();
        return entry.data as T?;
      } else {
        // Nettoyer l'entrée expirée
        _memoryCache.remove(key);
      }
    }

    // Tenter de récupérer depuis le stockage persistant
    final persistedData = await _loadCompressed<T>(key);
    if (persistedData != null) {
      // Remettre en cache mémoire
      await set(key: key, data: persistedData);
      return persistedData;
    }

    return null;
  }

  /// Invalide une entrée de cache
  void invalidate(String key) {
    _memoryCache.remove(key);
    _removePersisted(key);
  }

  /// Invalide toutes les entrées matchant un pattern
  void invalidatePattern(String pattern) {
    final regex = RegExp(pattern);
    final keysToRemove = _memoryCache.keys
        .where((key) => regex.hasMatch(key))
        .toList();
    
    for (final key in keysToRemove) {
      invalidate(key);
    }
  }

  /// Nettoie tout le cache
  void clear() {
    _memoryCache.clear();
    _clearPersisted();
  }

  /// Nettoie les entrées expirées
  void cleanExpired() {
    final keysToRemove = <String>[];
    
    _memoryCache.forEach((key, entry) {
      if (entry.isExpired) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _removePersisted(key);
    }
  }

  /// Applique la stratégie LRU
  void _evictLRU() {
    if (_memoryCache.isEmpty) return;
    
    String? lruKey;
    DateTime? oldestAccess;
    
    _memoryCache.forEach((key, entry) {
      if (oldestAccess == null || entry.lastAccessedAt.isBefore(oldestAccess!)) {
        oldestAccess = entry.lastAccessedAt;
        lruKey = key;
      }
    });
    
    if (lruKey != null) {
      _memoryCache.remove(lruKey);
      _removePersisted(lruKey!);
    }
  }


  /// Sérialise les données
  String _serialize(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Calcule la taille en octets
  int _calculateSize(String data) {
    return utf8.encode(data).length;
  }

  /// Compresse et persiste les données
  Future<void> _persistCompressed(String key, String data) async {
    try {
      final bytes = utf8.encode(data);
      final compressed = gzip.encode(bytes);
      
      // Sauvegarder de manière asynchrone
      // Note: Implémentation simplifiée, à adapter selon le système de stockage
      if (kDebugMode) {
        final compressionRatio = (1 - compressed.length / bytes.length) * 100;
        debugPrint('[Cache] Compression: ${compressionRatio.toStringAsFixed(1)}% pour $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Cache] Erreur de compression: $e');
      }
    }
  }

  /// Charge et décompresse les données
  Future<T?> _loadCompressed<T>(String key) async {
    try {
      // Note: Implémentation simplifiée
      // À adapter selon le système de stockage réel
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Cache] Erreur de décompression: $e');
      }
      return null;
    }
  }

  /// Supprime les données persistées
  void _removePersisted(String key) {
    // À implémenter selon le système de stockage
  }

  /// Nettoie tout le stockage persistant
  void _clearPersisted() {
    // À implémenter selon le système de stockage
  }

  /// Obtient les statistiques du cache
  CacheStatistics getStatistics() {
    int totalSize = 0;
    int expiredCount = 0;
    int totalAccessCount = 0;
    
    _memoryCache.forEach((key, entry) {
      totalSize += entry.sizeInBytes;
      if (entry.isExpired) expiredCount++;
      totalAccessCount += entry.accessCount;
    });
    
    return CacheStatistics(
      totalEntries: _memoryCache.length,
      totalSizeInBytes: totalSize,
      expiredEntries: expiredCount,
      totalAccessCount: totalAccessCount,
      hitRate: _calculateHitRate(),
    );
  }

  double _calculateHitRate() {
    // Implémenter le calcul du taux de succès
    return 0.0;
  }

  /// Précharge des données en arrière-plan
  Future<void> warmUp(List<String> keys, Future<dynamic> Function(String) loader) async {
    final futures = keys.map((key) async {
      final data = await loader(key);
      if (data != null) {
        await set(key: key, data: data);
      }
    });
    
    await Future.wait(futures);
  }
}

/// Statistiques du cache
class CacheStatistics {
  final int totalEntries;
  final int totalSizeInBytes;
  final int expiredEntries;
  final int totalAccessCount;
  final double hitRate;

  CacheStatistics({
    required this.totalEntries,
    required this.totalSizeInBytes,
    required this.expiredEntries,
    required this.totalAccessCount,
    required this.hitRate,
  });

  String get formattedSize {
    if (totalSizeInBytes < 1024) {
      return '$totalSizeInBytes B';
    } else if (totalSizeInBytes < 1024 * 1024) {
      return '${(totalSizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(totalSizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}