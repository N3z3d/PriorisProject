import 'dart:async';
import 'interfaces/cache_interface.dart';

/// Service responsable de la gestion des expirations de cache
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur la logique d'expiration.
class CacheExpirationService {
  final CacheInterface _cache;
  final Map<String, DateTime> _expirationTimes = {};
  final Duration _defaultTTL;
  Timer? _cleanupTimer;

  CacheExpirationService(
    this._cache, {
    Duration defaultTTL = const Duration(hours: 24),
    Duration cleanupInterval = const Duration(minutes: 15),
  }) : _defaultTTL = defaultTTL {
    _startCleanupTimer(cleanupInterval);
  }

  /// Sauvegarde avec TTL
  Future<void> setWithTTL(String key, dynamic value, {Duration? ttl}) async {
    await _cache.set(key, value);
    _expirationTimes[key] = DateTime.now().add(ttl ?? _defaultTTL);
  }

  /// Récupère une valeur si elle n'est pas expirée
  Future<T?> getIfNotExpired<T>(String key) async {
    if (_isExpired(key)) {
      await _removeExpiredEntry(key);
      return null;
    }
    return await _cache.get(key) as T?;
  }

  /// Vérifie si une clé est expirée
  bool _isExpired(String key) {
    final expiration = _expirationTimes[key];
    return expiration != null && DateTime.now().isAfter(expiration);
  }

  /// Supprime une entrée expirée
  Future<void> _removeExpiredEntry(String key) async {
    await _cache.remove(key);
    _expirationTimes.remove(key);
  }

  /// Nettoie toutes les entrées expirées
  Future<void> cleanup() async {
    final expiredKeys = _expirationTimes.entries
        .where((entry) => DateTime.now().isAfter(entry.value))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      await _removeExpiredEntry(key);
    }
  }

  /// Démarre le timer de nettoyage automatique
  void _startCleanupTimer(Duration interval) {
    _cleanupTimer = Timer.periodic(interval, (_) => cleanup());
  }

  /// Arrête le service et libère les ressources
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Obtient le nombre d'entrées avec expiration
  int get expiredEntriesCount => _expirationTimes.length;
}