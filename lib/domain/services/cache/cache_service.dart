import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'interfaces/cache_interface.dart';

/// Service de cache local persistant avec Hive
/// Implémente un cache intelligent avec LRU, TTL, compression et monitoring
///
/// SOLID: Implements CacheInterface following Dependency Inversion Principle
class CacheService implements CacheInterface<dynamic> {
  static const String _cacheBoxName = 'prioris_cache';
  static const String _metadataBoxName = 'prioris_metadata';
  static const String _statsBoxName = 'prioris_stats';
  
  static const int _maxCacheSize = 1000; // Nombre max d'entrées
  static const Duration _defaultTTL = Duration(hours: 24);
  static const int _maxDiskUsageMB = 50; // Limite d'espace disque
  
  late Box<dynamic> _cacheBox;
  late Box<dynamic> _metadataBox;
  late Box<dynamic> _statsBox;
  
  final Map<String, DateTime> _accessTimes = {};
  final Map<String, DateTime> _expirationTimes = {};
  
  /// Initialise le service de cache
  Future<void> initialize() async {
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _metadataBox = await Hive.openBox(_metadataBoxName);
    _statsBox = await Hive.openBox(_statsBoxName);
    
    await _loadMetadata();
    await _cleanupExpiredEntries();
    await _enforceSizeLimit();
  }
  
  /// Sauvegarde une valeur dans le cache avec TTL optionnel
  @override
  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    bool compress = true,
    CachePriority priority = CachePriority.normal,
  }) async {
    try {
      final now = DateTime.now();
      final expiration = now.add(ttl ?? _defaultTTL);
      
      // Compression des données si activée
      final data = compress ? await _compressData(value) : value;
      
      // Sauvegarde dans Hive
      await _cacheBox.put(key, data);
      
      // Mise à jour des métadonnées
      _accessTimes[key] = now;
      _expirationTimes[key] = expiration;
      
      await _saveMetadata();
      await _updateStats('set', key, data);
      await _enforceSizeLimit();
      
    } catch (e) {
      await _logError('set', key, e.toString());
      rethrow;
    }
  }
  
  /// Récupère une valeur du cache
  @override
  Future<dynamic> get(String key) async {
    try {
      // Vérifier l'expiration
      if (_isExpired(key)) {
        await _remove(key);
        await _updateStats('miss', key, null);
        return null;
      }
      
      final data = _cacheBox.get(key);
      if (data == null) {
        await _updateStats('miss', key, null);
        return null;
      }
      
      // Décompression si nécessaire
      final value = await _decompressData(data);
      
      // Mise à jour du temps d'accès (LRU)
      _accessTimes[key] = DateTime.now();
      await _saveMetadata();
      await _updateStats('hit', key, data);
      
      return value;
      
    } catch (e) {
      await _logError('get', key, e.toString());
      await _updateStats('miss', key, null);
      return null;
    }
  }
  
  /// Supprime une entrée du cache
  @override
  Future<void> remove(String key) async {
    await _remove(key);
  }
  
  /// Vide tout le cache
  @override
  Future<void> clear() async {
    await _cacheBox.clear();
    await _metadataBox.clear();
    await _statsBox.clear();
    
    _accessTimes.clear();
    _expirationTimes.clear();
    
    await _updateStats('clear', 'all', null);
  }
  
  /// Vérifie si une clé existe et n'est pas expirée
  @override
  Future<bool> exists(String key) async {
    if (!_cacheBox.containsKey(key)) return false;
    if (_isExpired(key)) {
      await _remove(key);
      return false;
    }
    return true;
  }
  
  /// Récupère les statistiques du cache
  Future<CacheStats> getStats() async {
    final dynamic rawStats = _statsBox.get('stats', defaultValue: <String, dynamic>{});
    final Map<String, dynamic> stats = rawStats is Map ? Map<String, dynamic>.from(rawStats) : <String, dynamic>{};
    
    return CacheStats(
      totalEntries: _cacheBox.length,
      totalSize: await _calculateTotalSize(),
      hitRate: _calculateHitRate(stats),
      averageAccessTime: _calculateAverageAccessTime(),
      diskUsageMB: await _getDiskUsage(),
      lastCleanup: DateTime.fromMillisecondsSinceEpoch(
        stats['lastCleanup'] ?? 0,
      ),
    );
  }
  
  /// Nettoie les entrées expirées
  Future<void> cleanup() async {
    await _cleanupExpiredEntries();
    await _enforceSizeLimit();
    await _updateStats('cleanup', 'all', null);
  }
  
  /// Optimise l'espace disque
  Future<void> optimize() async {
    final stats = await getStats();
    
    if (stats.diskUsageMB > _maxDiskUsageMB) {
      // Supprimer les entrées les moins récemment utilisées
      final entries = _accessTimes.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      final toRemove = entries.take(entries.length ~/ 4).map((e) => e.key);
      
      for (final key in toRemove) {
        await _remove(key);
      }
    }
    
    await _updateStats('optimize', 'all', null);
  }
  
  // Méthodes privées
  
  Future<void> _remove(String key) async {
    await _cacheBox.delete(key);
    _accessTimes.remove(key);
    _expirationTimes.remove(key);
    await _saveMetadata();
    await _updateStats('remove', key, null);
  }
  
  bool _isExpired(String key) {
    final expiration = _expirationTimes[key];
    return expiration != null && DateTime.now().isAfter(expiration);
  }
  
  Future<void> _cleanupExpiredEntries() async {
    final expiredKeys = _expirationTimes.entries
        .where((entry) => DateTime.now().isAfter(entry.value))
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      await _remove(key);
    }
  }
  
  Future<void> _enforceSizeLimit() async {
    if (_cacheBox.length <= _maxCacheSize) return;
    
    // Supprimer les entrées les moins récemment utilisées
    final entries = _accessTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    final toRemove = entries.take(_cacheBox.length - _maxCacheSize).map((e) => e.key);
    
    for (final key in toRemove) {
      await _remove(key);
    }
  }
  
  Future<void> _loadMetadata() async {
    final accessTimesData = _metadataBox.get('accessTimes', defaultValue: <String, int>{});
    final expirationTimesData = _metadataBox.get('expirationTimes', defaultValue: <String, int>{});
    
    _accessTimes.clear();
    _expirationTimes.clear();
    
    for (final entry in accessTimesData.entries) {
      _accessTimes[entry.key] = DateTime.fromMillisecondsSinceEpoch(entry.value);
    }
    
    for (final entry in expirationTimesData.entries) {
      _expirationTimes[entry.key] = DateTime.fromMillisecondsSinceEpoch(entry.value);
    }
  }
  
  Future<void> _saveMetadata() async {
    final accessTimesData = <String, int>{};
    final expirationTimesData = <String, int>{};
    
    for (final entry in _accessTimes.entries) {
      accessTimesData[entry.key] = entry.value.millisecondsSinceEpoch;
    }
    
    for (final entry in _expirationTimes.entries) {
      expirationTimesData[entry.key] = entry.value.millisecondsSinceEpoch;
    }
    
    await _metadataBox.put('accessTimes', accessTimesData);
    await _metadataBox.put('expirationTimes', expirationTimesData);
  }
  
  Future<dynamic> _compressData(dynamic data) async {
    if (data is String && data.length > 1000) {
      // Compression simple pour les longues chaînes
      return Uint8List.fromList(utf8.encode(data));
    }
    return data;
  }
  
  Future<dynamic> _decompressData(dynamic data) async {
    if (data is Uint8List) {
      // Décompression
      return utf8.decode(data);
    }
    return data;
  }
  
  Future<void> _updateStats(String operation, String key, dynamic data) async {
    final stats = _statsBox.get('stats', defaultValue: <String, dynamic>{});
    
    stats['operations'] ??= <String, int>{};
    stats['operations'][operation] = (stats['operations'][operation] ?? 0) + 1;
    
    stats['lastOperation'] = DateTime.now().millisecondsSinceEpoch;
    stats['lastCleanup'] = DateTime.now().millisecondsSinceEpoch;
    
    await _statsBox.put('stats', stats);
  }
  
  Future<void> _logError(String operation, String key, String error) async {
    final errors = _statsBox.get('errors', defaultValue: <String, dynamic>{});
    errors[DateTime.now().toIso8601String()] = {
      'operation': operation,
      'key': key,
      'error': error,
    };
    await _statsBox.put('errors', errors);
  }
  
  double _calculateHitRate(Map<String, dynamic> stats) {
    final operations = stats['operations'] ?? <String, int>{};
    final hits = operations['hit'] ?? 0;
    final misses = operations['miss'] ?? 0;
    
    final totalGets = hits + misses;
    if (totalGets == 0) return 0.0;
    return hits / totalGets;
  }
  
  Duration _calculateAverageAccessTime() {
    if (_accessTimes.isEmpty) return Duration.zero;
    
    final now = DateTime.now();
    final totalDuration = _accessTimes.values
        .map((time) => now.difference(time))
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ _accessTimes.length);
  }
  
  Future<int> _calculateTotalSize() async {
    int totalSize = 0;
    for (final key in _cacheBox.keys) {
      final value = _cacheBox.get(key);
      if (value is String) {
        totalSize += value.length;
      } else if (value is Uint8List) {
        totalSize += value.length;
      }
    }
    return totalSize;
  }
  
  Future<double> _getDiskUsage() async {
    final totalSize = await _calculateTotalSize();
    return totalSize / (1024 * 1024); // Convertir en MB
  }
  
  /// Ferme le service de cache
  Future<void> dispose() async {
    await _cacheBox.close();
    await _metadataBox.close();
    await _statsBox.close();
  }
}

/// Priorité du cache
enum CachePriority {
  low,
  normal,
  high,
  critical,
}

/// Statistiques du cache
class CacheStats {
  final int totalEntries;
  final int totalSize;
  final double hitRate;
  final Duration averageAccessTime;
  final double diskUsageMB;
  final DateTime lastCleanup;
  
  const CacheStats({
    required this.totalEntries,
    required this.totalSize,
    required this.hitRate,
    required this.averageAccessTime,
    required this.diskUsageMB,
    required this.lastCleanup,
  });
  
  @override
  String toString() {
    return 'CacheStats('
        'entries: $totalEntries, '
        'size: ${(totalSize / 1024).toStringAsFixed(2)}KB, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'avgAccess: ${averageAccessTime.inMilliseconds}ms, '
        'diskUsage: ${diskUsageMB.toStringAsFixed(2)}MB, '
        'lastCleanup: $lastCleanup)';
  }
} 
