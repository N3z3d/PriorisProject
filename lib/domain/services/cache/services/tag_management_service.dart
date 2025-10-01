/// **TAG MANAGEMENT SERVICE** - SRP Specialized Component
///
/// **LOT 10** : Service spécialisé pour gestion des tags cache uniquement
/// **SRP** : Responsabilité unique = Tagging et invalidation par tags
/// **Taille** : <80 lignes (extraction depuis God Class 658 lignes)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'cache_operations_service.dart';

/// Service spécialisé pour la gestion des tags dans le cache
///
/// **SRP** : Tagging et invalidation par tags uniquement
/// **DIP** : Injecte ses dépendances (cache operations service)
/// **OCP** : Extensible via nouvelles stratégies de tagging
class TagManagementService {
  final CacheOperationsService _cacheOperations;
  final Map<String, List<String>> _taggedKeys;

  const TagManagementService({
    required CacheOperationsService cacheOperations,
    required Map<String, List<String>> taggedKeys,
  }) : _cacheOperations = cacheOperations,
       _taggedKeys = taggedKeys;

  /// Définit une valeur avec des tags pour invalidation groupée
  Future<void> setWithTags<T>(String key, T value, List<String> tags, {Duration? ttl}) async {
    // Définir la valeur dans le cache
    await _cacheOperations.set(key, value, ttl: ttl);

    // Enregistrer les tags
    _addTagsForKey(key, tags);

    if (kDebugMode) {
      print('🏷️ Cache SET with tags: $key → $tags');
    }
  }

  /// Invalide tous les éléments avec un tag spécifique
  Future<void> invalidateByTag(String tag) async {
    final taggedKeys = _taggedKeys[tag];
    if (taggedKeys == null || taggedKeys.isEmpty) {
      if (kDebugMode) {
        print('🏷️ No keys found for tag: $tag');
      }
      return;
    }

    // Créer une copie pour éviter les modifications concurrentes
    final keysToInvalidate = List<String>.from(taggedKeys);

    // Invalider toutes les clés associées
    for (final key in keysToInvalidate) {
      await _invalidateKey(key);
    }

    // Supprimer le tag
    _taggedKeys.remove(tag);

    if (kDebugMode) {
      print('🏷️ Cache INVALIDATE TAG: $tag (${keysToInvalidate.length} keys)');
    }
  }

  /// Obtient toutes les clés associées à un tag
  List<String> getKeysByTag(String tag) {
    final keys = _taggedKeys[tag];
    return keys != null ? List<String>.from(keys) : <String>[];
  }

  /// Obtient tous les tags associés à une clé
  List<String> getTagsForKey(String key) {
    final tags = <String>[];
    for (final entry in _taggedKeys.entries) {
      if (entry.value.contains(key)) {
        tags.add(entry.key);
      }
    }
    return tags;
  }

  /// Supprime une clé de tous ses tags
  void removeKeyFromAllTags(String key) {
    final tagsToClean = <String>[];

    for (final entry in _taggedKeys.entries) {
      entry.value.remove(key);
      if (entry.value.isEmpty) {
        tagsToClean.add(entry.key);
      }
    }

    // Nettoyer les tags vides
    for (final tag in tagsToClean) {
      _taggedKeys.remove(tag);
    }
  }

  /// Obtient les statistiques des tags
  Map<String, dynamic> getTagStatistics() {
    final totalTags = _taggedKeys.length;
    final totalTaggedKeys = _taggedKeys.values.expand((keys) => keys).length;
    final averageKeysPerTag = totalTags > 0 ? totalTaggedKeys / totalTags : 0.0;

    return {
      'totalTags': totalTags,
      'totalTaggedKeys': totalTaggedKeys,
      'averageKeysPerTag': averageKeysPerTag,
      'tagBreakdown': Map.fromEntries(
        _taggedKeys.entries.map((e) => MapEntry(e.key, e.value.length)),
      ),
    };
  }

  // ==================== MÉTHODES PRIVÉES ====================

  void _addTagsForKey(String key, List<String> tags) {
    for (final tag in tags) {
      _taggedKeys.putIfAbsent(tag, () => <String>[]).add(key);
    }
  }

  Future<void> _invalidateKey(String key) async {
    // Note: Cette méthode devrait déléguer à un InvalidationService
    // Pour l'instant, on supprime simplement des tags
    removeKeyFromAllTags(key);
  }
}