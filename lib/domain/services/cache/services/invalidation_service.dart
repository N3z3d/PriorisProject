/// **INVALIDATION SERVICE** - SRP Specialized Component
///
/// **LOT 10** : Service spécialisé pour invalidation cache uniquement
/// **SRP** : Responsabilité unique = Invalidation pattern-based et directe
/// **Taille** : <80 lignes (extraction depuis God Class 658 lignes)

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service spécialisé pour les opérations d'invalidation du cache
///
/// **SRP** : Invalidation uniquement (directe et par pattern)
/// **DIP** : Injecte ses dépendances (cache structures)
/// **OCP** : Extensible via nouvelles stratégies d'invalidation
class InvalidationService {
  final Map<String, dynamic> _memoryCache;
  final Map<String, Timer> _expirationTimers;

  const InvalidationService({
    required Map<String, dynamic> memoryCache,
    required Map<String, Timer> expirationTimers,
  }) : _memoryCache = memoryCache,
       _expirationTimers = expirationTimers;

  /// Invalide une clé spécifique du cache
  Future<void> invalidate(String key) async {
    // Supprimer de la mémoire
    final removed = _memoryCache.remove(key);

    // Nettoyer le timer d'expiration
    final timer = _expirationTimers.remove(key);
    timer?.cancel();

    if (kDebugMode && removed != null) {
      print('🗑️ Cache INVALIDATE: $key');
    }
  }

  /// Invalide toutes les clés correspondant à un pattern
  Future<void> invalidatePattern(String pattern) async {
    final regex = RegExp(pattern);
    final keysToInvalidate = <String>[];

    // Trouver toutes les clés correspondant au pattern
    for (final key in _memoryCache.keys) {
      if (regex.hasMatch(key)) {
        keysToInvalidate.add(key);
      }
    }

    // Invalider toutes les clés trouvées
    for (final key in keysToInvalidate) {
      await invalidate(key);
    }

    if (kDebugMode) {
      print('🎯 Cache INVALIDATE PATTERN: $pattern (${keysToInvalidate.length} keys)');
    }
  }

  /// Invalide toutes les clés avec un préfixe spécifique
  Future<void> invalidateWithPrefix(String prefix) async {
    await invalidatePattern('^$prefix.*');
  }

  /// Invalide toutes les clés avec un suffixe spécifique
  Future<void> invalidateWithSuffix(String suffix) async {
    await invalidatePattern('.*$suffix\$');
  }

  /// Invalide toutes les clés contenant une sous-chaîne
  Future<void> invalidateContaining(String substring) async {
    await invalidatePattern('.*$substring.*');
  }

  /// Invalide toutes les entrées du cache
  Future<void> invalidateAll() async {
    final keyCount = _memoryCache.length;

    // Nettoyer tous les timers
    for (final timer in _expirationTimers.values) {
      timer.cancel();
    }

    // Vider les structures
    _memoryCache.clear();
    _expirationTimers.clear();

    if (kDebugMode) {
      print('🧹 Cache INVALIDATE ALL: $keyCount keys removed');
    }
  }

  /// Obtient les statistiques d'invalidation
  Map<String, dynamic> getInvalidationStatistics() {
    return {
      'activeKeys': _memoryCache.length,
      'activeTimers': _expirationTimers.length,
      'timerMismatch': _memoryCache.length != _expirationTimers.length,
    };
  }
}