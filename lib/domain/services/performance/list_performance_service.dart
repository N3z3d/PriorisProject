import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Service d'optimisation des performances pour les listes
/// 
/// Gère l'optimisation des opérations sur de gros volumes de données
/// avec pagination, cache intelligent et indexation.
class ListPerformanceService {
  static const int _defaultPageSize = 50;
  static const int _maxCacheSize = 1000;
  
  // Cache intelligent pour les opérations fréquentes
  final Map<String, List<CustomList>> _searchCache = {};
  final Map<String, List<CustomList>> _filterCache = {};
  final Map<String, double> _progressCache = {};
  
  // Index pour accélérer les recherches
  final Map<String, List<String>> _nameIndex = {};
  final Map<ListType, List<String>> _typeIndex = {};
  final Map<String, List<String>> _dateIndex = {};

  /// Optimise le chargement des listes avec pagination
  List<CustomList> getPaginatedLists(
    List<CustomList> allLists,
    int page,
    int pageSize,
  ) {
    // Gestion des paramètres invalides
    if (page < 0 || pageSize <= 0 || allLists.isEmpty) {
      return [];
    }
    
    final startIndex = page * pageSize;
    final endIndex = startIndex + pageSize;
    
    if (startIndex >= allLists.length) return [];
    
    return allLists.sublist(
      startIndex,
      endIndex > allLists.length ? allLists.length : endIndex,
    );
  }

  /// Optimise la recherche avec cache et index
  List<CustomList> optimizedSearch(
    List<CustomList> allLists,
    String query,
    {bool useCache = true}
  ) {
    if (query.isEmpty) return allLists;
    
    final cacheKey = 'search_${query.toLowerCase()}';
    
    // Vérifier le cache
    if (useCache && _searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }
    
    // Recherche optimisée avec index
    final results = _performIndexedSearch(allLists, query);
    
    // Mettre en cache (avec limite de taille)
    if (useCache && _searchCache.length < _maxCacheSize) {
      _searchCache[cacheKey] = results;
    }
    
    return results;
  }

  /// Optimise le filtrage avec cache
  List<CustomList> optimizedFilter(
    List<CustomList> allLists,
    ListType? type,
    bool showCompleted,
    bool showInProgress,
    {bool useCache = true}
  ) {
    final cacheKey = 'filter_${type?.name}_${showCompleted}_$showInProgress';
    
    // Vérifier le cache
    if (useCache && _filterCache.containsKey(cacheKey)) {
      return _filterCache[cacheKey]!;
    }
    
    // Filtrage optimisé
    final results = _performOptimizedFilter(
      allLists,
      type,
      showCompleted,
      showInProgress,
    );
    
    // Mettre en cache
    if (useCache && _filterCache.length < _maxCacheSize) {
      _filterCache[cacheKey] = results;
    }
    
    return results;
  }

  /// Calcule la progression avec cache
  double getCachedProgress(CustomList list) {
    if (_progressCache.containsKey(list.id)) {
      return _progressCache[list.id]!;
    }
    
    final progress = list.getProgress();
    _progressCache[list.id] = progress;
    
    return progress;
  }

  /// Construit les index pour accélérer les recherches
  void buildIndexes(List<CustomList> lists) {
    _nameIndex.clear();
    _typeIndex.clear();
    _dateIndex.clear();
    
    for (final list in lists) {
      // Index par nom
      final words = list.name.toLowerCase().split(' ');
      for (final word in words) {
        if (word.isNotEmpty) {
          _nameIndex.putIfAbsent(word, () => []).add(list.id);
        }
      }
      
      // Index par type
      _typeIndex.putIfAbsent(list.type, () => []).add(list.id);
      
      // Index par date (année-mois)
      final dateKey = '${list.createdAt.year}-${list.createdAt.month.toString().padLeft(2, '0')}';
      _dateIndex.putIfAbsent(dateKey, () => []).add(list.id);
    }
  }

  /// Recherche optimisée avec index
  List<CustomList> _performIndexedSearch(List<CustomList> allLists, String query) {
    final lowercaseQuery = query.toLowerCase();
    final queryWords = lowercaseQuery.split(' ');
    
    // Utiliser l'index pour accélérer la recherche
    final matchingIds = <String>{};
    
    for (final word in queryWords) {
      if (word.isNotEmpty && _nameIndex.containsKey(word)) {
        matchingIds.addAll(_nameIndex[word]!);
      }
    }
    
    // Si l'index ne donne pas de résultats, faire une recherche complète
    if (matchingIds.isEmpty) {
      return allLists.where((list) =>
        list.name.toLowerCase().contains(lowercaseQuery) ||
        list.description?.toLowerCase().contains(lowercaseQuery) == true
      ).toList();
    }
    
    // Filtrer par les IDs trouvés
    return allLists.where((list) => matchingIds.contains(list.id)).toList();
  }

  /// Filtrage optimisé
  List<CustomList> _performOptimizedFilter(
    List<CustomList> allLists,
    ListType? type,
    bool showCompleted,
    bool showInProgress,
  ) {
    return allLists.where((list) {
      // Filtre par type
      if (type != null && list.type != type) return false;
      
      // Filtre par statut
      final progress = getCachedProgress(list);
      final isCompleted = progress == 1.0;
      
      if (isCompleted && !showCompleted) return false;
      if (!isCompleted && !showInProgress) return false;
      
      return true;
    }).toList();
  }

  /// Nettoie le cache pour libérer la mémoire
  void clearCache() {
    _searchCache.clear();
    _filterCache.clear();
    _progressCache.clear();
  }

  /// Nettoie le cache des index
  void clearIndexes() {
    _nameIndex.clear();
    _typeIndex.clear();
    _dateIndex.clear();
  }

  /// Statistiques de performance
  Map<String, dynamic> getPerformanceStats() {
    return {
      'searchCacheSize': _searchCache.length,
      'filterCacheSize': _filterCache.length,
      'progressCacheSize': _progressCache.length,
      'nameIndexSize': _nameIndex.length,
      'typeIndexSize': _typeIndex.length,
      'dateIndexSize': _dateIndex.length,
      'maxCacheSize': _maxCacheSize,
      'defaultPageSize': _defaultPageSize,
    };
  }

  /// Optimise le tri pour de gros volumes
  List<CustomList> optimizedSort(
    List<CustomList> lists,
    SortOption sortOption,
  ) {
    // Utiliser un algorithme de tri optimisé selon la taille
    if (lists.length > 1000) {
      return _quickSort(lists, sortOption);
    } else {
      return _standardSort(lists, sortOption);
    }
  }

  /// Tri rapide pour gros volumes
  List<CustomList> _quickSort(List<CustomList> lists, SortOption sortOption) {
    if (lists.length <= 1) return lists;
    
    final pivot = lists[lists.length ~/ 2];
    final less = <CustomList>[];
    final equal = <CustomList>[];
    final greater = <CustomList>[];
    
    for (final list in lists) {
      final comparison = _compareLists(list, pivot, sortOption);
      if (comparison < 0) {
        less.add(list);
      } else if (comparison == 0) {
        equal.add(list);
      } else {
        greater.add(list);
      }
    }
    
    return [
      ..._quickSort(less, sortOption),
      ...equal,
      ..._quickSort(greater, sortOption),
    ];
  }

  /// Tri standard pour petits volumes
  List<CustomList> _standardSort(List<CustomList> lists, SortOption sortOption) {
    final sorted = List<CustomList>.from(lists);
    sorted.sort((a, b) => _compareLists(a, b, sortOption));
    return sorted;
  }

  /// Compare deux listes selon l'option de tri
  int _compareLists(CustomList a, CustomList b, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.NAME_ASC:
        return a.name.compareTo(b.name);
      case SortOption.NAME_DESC:
        return b.name.compareTo(a.name);
      case SortOption.DATE_CREATED_ASC:
        return a.createdAt.compareTo(b.createdAt);
      case SortOption.DATE_CREATED_DESC:
        return b.createdAt.compareTo(a.createdAt);
      case SortOption.PROGRESS_ASC:
        return getCachedProgress(a).compareTo(getCachedProgress(b));
      case SortOption.PROGRESS_DESC:
        return getCachedProgress(b).compareTo(getCachedProgress(a));
      case SortOption.ITEMS_COUNT_ASC:
        return a.items.length.compareTo(b.items.length);
      case SortOption.ITEMS_COUNT_DESC:
        return b.items.length.compareTo(a.items.length);
    }
  }
}

/// Options de tri optimisées
enum SortOption {
  NAME_ASC('Nom A-Z'),
  NAME_DESC('Nom Z-A'),
  DATE_CREATED_ASC('Plus anciennes'),
  DATE_CREATED_DESC('Plus récentes'),
  PROGRESS_ASC('Progression croissante'),
  PROGRESS_DESC('Progression décroissante'),
  ITEMS_COUNT_ASC('Moins d\'éléments'),
  ITEMS_COUNT_DESC('Plus d\'éléments');

  const SortOption(this.displayName);
  final String displayName;
} 
