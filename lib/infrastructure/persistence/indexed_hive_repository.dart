import 'package:hive_flutter/hive_flutter.dart';
import 'dart:collection';

/// Repository Hive avec indexation pour performances optimales
/// 
/// Améliore drastiquement les performances de recherche et filtrage
/// en maintenant des index en mémoire pour les champs fréquemment interrogés.
class IndexedHiveRepository<T> {
  final String boxName;
  final Map<String, dynamic> Function(T) toJson;
  final T Function(Map<String, dynamic>) fromJson;
  
  late Box<Map<dynamic, dynamic>> _box;
  
  // Index structures
  final Map<String, Map<dynamic, Set<String>>> _indexes = {};
  final Map<String, Map<String, List<String>>> _textIndexes = {};
  final Map<String, SplayTreeMap<dynamic, Set<String>>> _sortedIndexes = {};
  
  // Cache pour optimisation
  final Map<String, T> _cache = {};
  // final Set<String> _dirtyKeys = {}; // TODO: Implémenter dirty tracking
  
  // Configuration
  final Set<String> indexedFields;
  final Set<String> textIndexedFields;
  final Set<String> sortedFields;
  final int maxCacheSize;
  
  IndexedHiveRepository({
    required this.boxName,
    required this.toJson,
    required this.fromJson,
    this.indexedFields = const {},
    this.textIndexedFields = const {},
    this.sortedFields = const {},
    this.maxCacheSize = 1000,
  });

  /// Initialise le repository et construit les index
  Future<void> initialize() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    await _buildIndexes();
  }

  /// Construit tous les index à partir des données existantes
  Future<void> _buildIndexes() async {
    _indexes.clear();
    _textIndexes.clear();
    _sortedIndexes.clear();
    _cache.clear();
    
    // Initialiser les structures d'index
    for (final field in indexedFields) {
      _indexes[field] = {};
    }
    for (final field in textIndexedFields) {
      _textIndexes[field] = {};
    }
    for (final field in sortedFields) {
      _sortedIndexes[field] = SplayTreeMap<dynamic, Set<String>>();
    }
    
    // Parcourir toutes les entrées et construire les index
    for (final entry in _box.toMap().entries) {
      final key = entry.key.toString();
      final data = Map<String, dynamic>.from(entry.value);
      final entity = fromJson(data);
      
      _updateIndexesForEntity(key, entity, data);
      
      // Ajouter au cache si pas trop grand
      if (_cache.length < maxCacheSize) {
        _cache[key] = entity;
      }
    }
  }

  /// Met à jour les index pour une entité
  void _updateIndexesForEntity(String key, T entity, Map<String, dynamic> data) {
    // Index standard
    for (final field in indexedFields) {
      if (data.containsKey(field)) {
        final value = data[field];
        _indexes[field]!.putIfAbsent(value, () => {}).add(key);
      }
    }
    
    // Index full-text
    for (final field in textIndexedFields) {
      if (data.containsKey(field) && data[field] is String) {
        final text = (data[field] as String).toLowerCase();
        final words = _tokenizeText(text);
        
        for (final word in words) {
          _textIndexes[field]!.putIfAbsent(word, () => []).add(key);
        }
      }
    }
    
    // Index triés
    for (final field in sortedFields) {
      if (data.containsKey(field)) {
        final value = data[field];
        _sortedIndexes[field]!.putIfAbsent(value, () => {}).add(key);
      }
    }
  }

  /// Supprime une entité des index
  void _removeFromIndexes(String key, Map<String, dynamic> data) {
    // Supprimer des index standard
    for (final field in indexedFields) {
      if (data.containsKey(field)) {
        final value = data[field];
        _indexes[field]?[value]?.remove(key);
        if (_indexes[field]?[value]?.isEmpty ?? false) {
          _indexes[field]!.remove(value);
        }
      }
    }
    
    // Supprimer des index full-text
    for (final field in textIndexedFields) {
      if (data.containsKey(field) && data[field] is String) {
        final text = (data[field] as String).toLowerCase();
        final words = _tokenizeText(text);
        
        for (final word in words) {
          _textIndexes[field]?[word]?.remove(key);
          if (_textIndexes[field]?[word]?.isEmpty ?? false) {
            _textIndexes[field]!.remove(word);
          }
        }
      }
    }
    
    // Supprimer des index triés
    for (final field in sortedFields) {
      if (data.containsKey(field)) {
        final value = data[field];
        _sortedIndexes[field]?[value]?.remove(key);
        if (_sortedIndexes[field]?[value]?.isEmpty ?? false) {
          _sortedIndexes[field]!.remove(value);
        }
      }
    }
  }

  /// Tokenise un texte pour l'indexation full-text
  List<String> _tokenizeText(String text) {
    // Tokenisation simple : découpage par espaces et ponctuation
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .toSet()
        .toList();
  }

  // ========== OPÉRATIONS CRUD AVEC INDEX ==========

  /// Crée une nouvelle entité
  Future<String> create(T entity) async {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    final data = toJson(entity);
    
    await _box.put(key, data);
    _updateIndexesForEntity(key, entity, data);
    _cache[key] = entity;
    _maintainCacheSize();
    
    return key;
  }

  /// Récupère une entité par ID (utilise le cache)
  Future<T?> getById(String id) async {
    // Vérifier le cache en premier
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    
    final data = _box.get(id);
    if (data == null) return null;
    
    final entity = fromJson(Map<String, dynamic>.from(data));
    _cache[id] = entity;
    _maintainCacheSize();
    
    return entity;
  }

  /// Met à jour une entité
  Future<bool> update(String id, T entity) async {
    final oldData = _box.get(id);
    if (oldData == null) return false;
    
    // Supprimer les anciens index
    _removeFromIndexes(id, Map<String, dynamic>.from(oldData));
    
    // Mettre à jour
    final newData = toJson(entity);
    await _box.put(id, newData);
    
    // Reconstruire les index
    _updateIndexesForEntity(id, entity, newData);
    
    // Mettre à jour le cache
    _cache[id] = entity;
    
    return true;
  }

  /// Supprime une entité
  Future<bool> delete(String id) async {
    final data = _box.get(id);
    if (data == null) return false;
    
    _removeFromIndexes(id, Map<String, dynamic>.from(data));
    await _box.delete(id);
    _cache.remove(id);
    
    return true;
  }

  // ========== REQUÊTES OPTIMISÉES PAR INDEX ==========

  /// Recherche par valeur exacte sur un champ indexé
  Future<List<T>> findByField(String field, dynamic value) async {
    if (!indexedFields.contains(field)) {
      throw ArgumentError('Field "$field" is not indexed');
    }
    
    final keys = _indexes[field]?[value] ?? {};
    final results = <T>[];
    
    for (final key in keys) {
      final entity = await getById(key);
      if (entity != null) {
        results.add(entity);
      }
    }
    
    return results;
  }

  /// Recherche full-text sur un champ
  Future<List<T>> searchText(String field, String query) async {
    if (!textIndexedFields.contains(field)) {
      throw ArgumentError('Field "$field" is not text-indexed');
    }
    
    final words = _tokenizeText(query);
    if (words.isEmpty) return [];
    
    // Trouver les documents contenant tous les mots (AND)
    Set<String>? matchingKeys;
    
    for (final word in words) {
      final keys = _textIndexes[field]?[word]?.toSet() ?? {};
      
      if (matchingKeys == null) {
        matchingKeys = keys;
      } else {
        matchingKeys = matchingKeys.intersection(keys);
      }
      
      if (matchingKeys.isEmpty) break;
    }
    
    if (matchingKeys == null || matchingKeys.isEmpty) return [];
    
    final results = <T>[];
    for (final key in matchingKeys) {
      final entity = await getById(key);
      if (entity != null) {
        results.add(entity);
      }
    }
    
    return results;
  }

  /// Recherche full-text sur plusieurs champs (OR)
  Future<List<T>> searchMultipleFields(List<String> fields, String query) async {
    final allKeys = <String>{};
    
    for (final field in fields) {
      if (textIndexedFields.contains(field)) {
        final results = await searchText(field, query);
        allKeys.addAll(results.map((e) => toJson(e)['id'] ?? ''));
      }
    }
    
    final results = <T>[];
    for (final key in allKeys) {
      final entity = await getById(key);
      if (entity != null) {
        results.add(entity);
      }
    }
    
    return results;
  }

  /// Récupère les entités triées par un champ
  Future<List<T>> getSorted(String field, {bool ascending = true}) async {
    if (!sortedFields.contains(field)) {
      throw ArgumentError('Field "$field" is not sorted-indexed');
    }
    
    final sortedIndex = _sortedIndexes[field]!;
    final results = <T>[];
    
    final entries = ascending ? sortedIndex.entries : sortedIndex.entries.toList().reversed;
    
    for (final entry in entries) {
      for (final key in entry.value) {
        final entity = await getById(key);
        if (entity != null) {
          results.add(entity);
        }
      }
    }
    
    return results;
  }

  /// Récupère une plage de valeurs sur un champ trié
  Future<List<T>> getRange(String field, dynamic min, dynamic max) async {
    if (!sortedFields.contains(field)) {
      throw ArgumentError('Field "$field" is not sorted-indexed');
    }
    
    final sortedIndex = _sortedIndexes[field]!;
    final results = <T>[];
    
    // Utiliser SplayTreeMap pour une recherche efficace de plage
    final subMap = Map.fromEntries(
      sortedIndex.entries.where((e) => 
        e.key.compareTo(min) >= 0 && e.key.compareTo(max) <= 0
      )
    );
    
    for (final entry in subMap.entries) {
      for (final key in entry.value) {
        final entity = await getById(key);
        if (entity != null) {
          results.add(entity);
        }
      }
    }
    
    return results;
  }

  /// Pagination optimisée avec index
  Future<List<T>> getPaginated({
    required int page,
    required int pageSize,
    String? sortField,
    bool ascending = true,
  }) async {
    List<String> allKeys;
    
    if (sortField != null && sortedFields.contains(sortField)) {
      // Utiliser l'index trié pour la pagination
      final sortedIndex = _sortedIndexes[sortField]!;
      allKeys = [];
      
      final entries = ascending ? sortedIndex.entries : sortedIndex.entries.toList().reversed;
      for (final entry in entries) {
        allKeys.addAll(entry.value);
      }
    } else {
      // Pagination simple sans tri
      allKeys = _box.keys.map((k) => k.toString()).toList();
    }
    
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allKeys.length);
    
    if (startIndex >= allKeys.length) return [];
    
    final pageKeys = allKeys.sublist(startIndex, endIndex);
    final results = <T>[];
    
    for (final key in pageKeys) {
      final entity = await getById(key);
      if (entity != null) {
        results.add(entity);
      }
    }
    
    return results;
  }

  /// Maintient la taille du cache sous la limite
  void _maintainCacheSize() {
    if (_cache.length > maxCacheSize) {
      // Stratégie simple : supprimer les plus anciens (FIFO)
      final keysToRemove = _cache.keys.take(_cache.length - maxCacheSize).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }
  }

  /// Vide le cache
  void clearCache() {
    _cache.clear();
  }

  /// Reconstruit tous les index (maintenance)
  Future<void> rebuildIndexes() async {
    await _buildIndexes();
  }

  /// Obtient des statistiques sur les index
  Map<String, dynamic> getIndexStats() {
    return {
      'indexes': {
        for (final field in indexedFields)
          field: {
            'uniqueValues': _indexes[field]?.length ?? 0,
            'totalEntries': _indexes[field]?.values.fold<int>(0, (sum, set) => sum + set.length) ?? 0,
          },
      },
      'textIndexes': {
        for (final field in textIndexedFields)
          field: {
            'uniqueWords': _textIndexes[field]?.length ?? 0,
            'totalEntries': _textIndexes[field]?.values.fold<int>(0, (sum, list) => sum + list.length) ?? 0,
          },
      },
      'sortedIndexes': {
        for (final field in sortedFields)
          field: {
            'uniqueValues': _sortedIndexes[field]?.length ?? 0,
            'totalEntries': _sortedIndexes[field]?.values.fold<int>(0, (sum, set) => sum + set.length) ?? 0,
          },
      },
      'cache': {
        'size': _cache.length,
        'maxSize': maxCacheSize,
        'hitRate': _cache.length / maxCacheSize,
      },
    };
  }

  /// Ferme le repository
  Future<void> close() async {
    _cache.clear();
    _indexes.clear();
    _textIndexes.clear();
    _sortedIndexes.clear();
    await _box.close();
  }
}