import 'dart:math';

import 'package:prioris/domain/services/cache/cache_policies.dart';
import 'package:prioris/domain/services/cache/interfaces/cache_system_interfaces.dart';

class CachePolicyEngine {
  CachePolicyEngine({
    required CacheStrategy strategy,
    required Duration defaultTTL,
  })  : _strategy = strategy,
        _defaultTTL = defaultTTL;

  final CacheStrategy _strategy;
  final Duration _defaultTTL;

  int _evictionCount = 0;
  int _ttlExpirationCount = 0;
  int _policyViolationCount = 0;

  final Map<String, int> _frequency = {};
  final Map<String, double> _adaptiveScores = {};
  final Set<String> _registeredKeys = <String>{};

  CacheStrategy get strategy => _strategy;

  void updateEntryOnCreate(String key, ICacheEntry entry) {
    _registeredKeys.add(key);
    if (_strategy == CacheStrategy.lfu || _strategy == CacheStrategy.adaptive) {
      _frequency[key] = entry.frequency;
    }
    if (_strategy == CacheStrategy.adaptive) {
      _adaptiveScores[key] = entry.calculateAdaptiveScore();
    }
  }

  void updateEntryOnAccess(String key, ICacheEntry entry) {
    entry.updateAccess();
    if (_strategy == CacheStrategy.lfu || _strategy == CacheStrategy.adaptive) {
      entry.incrementFrequency();
      _frequency[key] = entry.frequency;
    }
    if (_strategy == CacheStrategy.adaptive) {
      _adaptiveScores[key] = entry.calculateAdaptiveScore();
    }
  }

  void removeEntry(String key, ICacheEntry entry) {
    _registeredKeys.remove(key);
    _frequency.remove(key);
    _adaptiveScores.remove(key);
    _evictionCount += 1;
  }

  String? getEvictionCandidate(Map<String, ICacheEntry> entries) {
    if (entries.isEmpty) {
      return null;
    }
    switch (_strategy) {
      case CacheStrategy.lru:
        return entries.entries
            .reduce((a, b) => a.value.lastAccessed.isAfter(b.value.lastAccessed) ? b : a)
            .key;
      case CacheStrategy.lfu:
        return entries.entries
            .reduce((a, b) => a.value.frequency <= b.value.frequency ? a : b)
            .key;
      case CacheStrategy.ttl:
        final expired = entries.entries.where((e) => e.value.isExpired).toList();
        if (expired.isNotEmpty) {
          _ttlExpirationCount += 1;
          return expired.first.key;
        }
        return entries.entries
            .reduce((a, b) =>
                (a.value.expiresAt ?? DateTime.now()).isBefore(b.value.expiresAt ?? DateTime.now())
                    ? a
                    : b)
            .key;
      case CacheStrategy.adaptive:
        return entries.entries
            .reduce((a, b) =>
                a.value.calculateAdaptiveScore() <= b.value.calculateAdaptiveScore() ? a : b)
            .key;
    }
  }

  bool shouldEvict(String key, ICacheEntry entry) {
    if (_strategy != CacheStrategy.ttl) {
      return false;
    }
    final expired = entry.isExpired;
    if (expired) {
      _ttlExpirationCount += 1;
    }
    return expired;
  }

  Map<String, Object?> getPolicyStats() {
    final stats = <String, Object?>{
      'strategy': _strategy.name,
      'defaultTTL': _defaultTTL.inMilliseconds,
      'evictionCount': _evictionCount,
      'ttlExpirationCount': _ttlExpirationCount,
      'policyViolationCount': _policyViolationCount,
    };

    if (_strategy == CacheStrategy.lfu) {
      stats['minFrequency'] =
          _frequency.values.isEmpty ? 0 : _frequency.values.reduce(min);
      stats['frequencyDistribution'] = Map<String, int>.fromEntries(
        _frequency.entries.map((e) => MapEntry(e.key, e.value)),
      );
      stats['totalTrackedEntries'] = _frequency.length;
    }

    if (_strategy == CacheStrategy.adaptive) {
      final scores = _adaptiveScores.values.toList();
      stats['averageScore'] =
          scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
      stats['maxScore'] = scores.isEmpty ? 0.0 : scores.reduce(max);
      stats['minScore'] = scores.isEmpty ? 0.0 : scores.reduce(min);
      stats['scoredEntries'] = scores.length;
      stats['scoreDistribution'] = {
        'low': scores.where((score) => score < 25).length,
        'medium': scores.where((score) => score >= 25 && score < 60).length,
        'high': scores.where((score) => score >= 60).length,
      };
    }

    return stats;
  }

  void optimize() {
    if (_strategy == CacheStrategy.lfu) {
      _frequency.removeWhere((_, freq) => freq <= 0);
    }
    if (_strategy == CacheStrategy.adaptive) {
      _adaptiveScores
          .updateAll((_, value) => double.parse(value.toStringAsFixed(2)));
    }
  }

  void reset() {
    _evictionCount = 0;
    _ttlExpirationCount = 0;
    _policyViolationCount = 0;
    _frequency.clear();
    _adaptiveScores.clear();
    _registeredKeys.clear();
  }

  bool validatePolicy(Map<String, ICacheEntry> entries) {
    if (_strategy == CacheStrategy.lfu || _strategy == CacheStrategy.adaptive) {
      final missing = entries.keys.where((key) => !_registeredKeys.contains(key));
      if (missing.isNotEmpty) {
        _policyViolationCount += 1;
        return false;
      }
    }
    return true;
  }
}
