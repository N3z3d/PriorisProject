import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../models/lists_state.dart';
import '../interfaces/lists_managers_interfaces.dart';

/// **Strategy + Chain of Responsibility Pattern** pour le filtrage optimisé
///
/// **Single Responsibility Principle (SRP)** : Se concentre uniquement sur le filtrage et tri
/// **Open/Closed Principle (OCP)** : Extensible pour de nouveaux filtres sans modification
/// **Performance optimized** : Cache et optimisations pour grandes collections
class ListsFilterManager implements IListsFilterManager {
  // === Cache pour améliorer les performances ===
  final Map<String, List<CustomList>> _filterCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // === Statistiques de performance ===
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalFilterOperations = 0;

  @override
  List<CustomList> applyFilters(List<CustomList> lists, ListsState state) {
    _totalFilterOperations++;

    // Génération de clé de cache basée sur l'état complet
    final cacheKey = _generateCacheKey(lists, state);

    // Vérifier le cache d'abord
    final cachedResult = _getFromCache(cacheKey);
    if (cachedResult != null) {
      _cacheHits++;
      LoggerService.instance.debug(
        'Cache hit pour filtrage - ${cachedResult.length} résultats',
        context: 'ListsFilterManager',
      );
      return cachedResult;
    }

    _cacheMisses++;

    try {
      LoggerService.instance.debug(
        'Application des filtres: ${lists.length} listes, searchQuery="${state.searchQuery}"',
        context: 'ListsFilterManager',
      );

      // **Chain of Responsibility Pattern** - Application séquentielle des filtres
      var filteredLists = lists;

      // Filtre 1: Recherche textuelle (plus discriminant en premier)
      if (state.searchQuery.isNotEmpty) {
        filteredLists = filterBySearchQuery(filteredLists, state.searchQuery);
      }

      // Filtre 2: Type de liste
      if (state.selectedType != null) {
        filteredLists = filterByType(filteredLists, state.selectedType.toString());
      }

      // Filtre 3: Statut (terminé/en cours)
      filteredLists = filterByStatus(
        filteredLists,
        showCompleted: state.showCompleted,
        showInProgress: state.showInProgress,
      );

      // Filtre 4: Date
      if (state.selectedDateFilter != null) {
        filteredLists = filterByDate(filteredLists, state.selectedDateFilter);
      }

      // Dernière étape: Tri
      filteredLists = sortLists(filteredLists, state.sortOption);

      // Mise en cache du résultat
      _putInCache(cacheKey, filteredLists);

      LoggerService.instance.debug(
        'Filtrage terminé: ${filteredLists.length} listes filtrées',
        context: 'ListsFilterManager',
      );

      return filteredLists;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de l\'application des filtres',
        context: 'ListsFilterManager',
        error: e,
      );
      // En cas d'erreur, retourner la liste complète
      return lists;
    }
  }

  @override
  List<CustomList> filterBySearchQuery(List<CustomList> lists, String searchQuery) {
    if (searchQuery.isEmpty) return lists;

    final query = searchQuery.toLowerCase().trim();

    return lists.where((list) {
      // Recherche dans le nom de la liste
      if (list.name.toLowerCase().contains(query)) return true;

      // Recherche dans la description si disponible
      if (list.description?.toLowerCase().contains(query) == true) return true;

      // Recherche dans les éléments de la liste
      return list.items.any((item) =>
          item.title.toLowerCase().contains(query) ||
          (item.description?.toLowerCase().contains(query) == true));
    }).toList();
  }

  @override
  List<CustomList> filterByType(List<CustomList> lists, String? selectedType) {
    if (selectedType == null || selectedType.isEmpty) return lists;

    try {
      final typeEnum = ListType.values.firstWhere(
        (type) => type.toString() == selectedType,
      );

      return lists.where((list) => list.type == typeEnum).toList();
    } catch (e) {
      LoggerService.instance.warning(
        'Type de liste invalide: $selectedType',
        context: 'ListsFilterManager',
      );
      return lists;
    }
  }

  @override
  List<CustomList> filterByStatus(
    List<CustomList> lists, {
    required bool showCompleted,
    required bool showInProgress,
  }) {
    // Si les deux sont activés ou désactivés, pas de filtrage
    if (showCompleted == showInProgress) return lists;

    return lists.where((list) {
      final isCompleted = _isListCompleted(list);

      if (showCompleted && !showInProgress) {
        return isCompleted;
      } else if (!showCompleted && showInProgress) {
        return !isCompleted;
      }

      return true; // Fallback
    }).toList();
  }

  @override
  List<CustomList> filterByDate(List<CustomList> lists, String? dateFilter) {
    if (dateFilter == null || dateFilter.isEmpty) return lists;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return lists.where((list) {
      switch (dateFilter.toLowerCase()) {
        case 'today':
          return _isSameDay(list.createdAt, today);
        case 'week':
          final weekAgo = today.subtract(const Duration(days: 7));
          return list.createdAt.isAfter(weekAgo);
        case 'month':
          final monthAgo = DateTime(today.year, today.month - 1, today.day);
          return list.createdAt.isAfter(monthAgo);
        case 'year':
          final yearAgo = DateTime(today.year - 1, today.month, today.day);
          return list.createdAt.isAfter(yearAgo);
        default:
          return true;
      }
    }).toList();
  }

  @override
  List<CustomList> sortLists(List<CustomList> lists, SortOption sortOption) {
    // Copie défensive pour éviter de modifier la liste originale
    final sortedLists = List<CustomList>.from(lists);

    switch (sortOption) {
      case SortOption.NAME_ASC:
        sortedLists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.NAME_DESC:
        sortedLists.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.DATE_CREATED_ASC:
        sortedLists.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.DATE_CREATED_DESC:
        sortedLists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.PROGRESS_ASC:
        sortedLists.sort((a, b) => _getListProgress(a).compareTo(_getListProgress(b)));
        break;
      case SortOption.PROGRESS_DESC:
        sortedLists.sort((a, b) => _getListProgress(b).compareTo(_getListProgress(a)));
        break;
    }

    return sortedLists;
  }

  @override
  void clearCache() {
    _filterCache.clear();
    _cacheTimestamps.clear();

    LoggerService.instance.debug(
      'Cache de filtrage effacé',
      context: 'ListsFilterManager',
    );
  }

  @override
  List<CustomList> applyOptimizedFilters(List<CustomList> lists, ListsState state) {
    // Pour de très grandes collections (>1000 listes), utiliser des optimisations
    if (lists.length > 1000) {
      return _applyOptimizedLargeCollection(lists, state);
    }

    // Pour des collections normales, utiliser le filtrage standard
    return applyFilters(lists, state);
  }

  /// Obtient les statistiques de performance du cache
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _filterCache.length,
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate': _cacheHits / (_cacheHits + _cacheMisses),
      'totalFilterOperations': _totalFilterOperations,
    };
  }

  /// Réinitialise les statistiques
  void resetStats() {
    _cacheHits = 0;
    _cacheMisses = 0;
    _totalFilterOperations = 0;

    LoggerService.instance.debug(
      'Statistiques de filtrage réinitialisées',
      context: 'ListsFilterManager',
    );
  }

  // === Private Methods ===

  /// Génère une clé de cache basée sur les paramètres de filtrage
  String _generateCacheKey(List<CustomList> lists, ListsState state) {
    final listIds = lists.map((l) => l.id).join(',');
    final listHash = listIds.hashCode.toString();

    return 'filter_${listHash}_'
        '${state.searchQuery}_'
        '${state.selectedType}_'
        '${state.showCompleted}_'
        '${state.showInProgress}_'
        '${state.selectedDateFilter}_'
        '${state.sortOption}';
  }

  /// Récupère un résultat du cache s'il est valide
  List<CustomList>? _getFromCache(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    // Vérifier si le cache n'a pas expiré
    if (DateTime.now().difference(timestamp) > _cacheTimeout) {
      _filterCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _filterCache[key];
  }

  /// Met un résultat en cache
  void _putInCache(String key, List<CustomList> result) {
    _filterCache[key] = List.from(result); // Copie défensive
    _cacheTimestamps[key] = DateTime.now();

    // Nettoyage du cache si trop grand
    if (_filterCache.length > 100) {
      _cleanupExpiredCache();
    }
  }

  /// Nettoie les entrées expirées du cache
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheTimeout) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _filterCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      LoggerService.instance.debug(
        'Cache nettoyé: ${expiredKeys.length} entrées expirées supprimées',
        context: 'ListsFilterManager',
      );
    }
  }

  /// Vérifie si une liste est considérée comme terminée
  bool _isListCompleted(CustomList list) {
    if (list.items.isEmpty) return false;
    return list.items.every((item) => item.isCompleted);
  }

  /// Calcule le pourcentage de progression d'une liste
  double _getListProgress(CustomList list) {
    if (list.items.isEmpty) return 0.0;
    final completedItems = list.items.where((item) => item.isCompleted).length;
    return completedItems / list.items.length;
  }

  /// Vérifie si deux DateTime sont le même jour
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Applique des filtres optimisés pour de grandes collections
  List<CustomList> _applyOptimizedLargeCollection(List<CustomList> lists, ListsState state) {
    LoggerService.instance.info(
      'Application de filtres optimisés pour grande collection: ${lists.length} listes',
      context: 'ListsFilterManager',
    );

    // Pour de grandes collections, on peut paralléliser ou utiliser des index
    // Ici on applique d'abord les filtres les plus discriminants

    var result = lists;

    // Commencer par le filtre de recherche (souvent le plus discriminant)
    if (state.searchQuery.isNotEmpty) {
      result = filterBySearchQuery(result, state.searchQuery);
      // Si la recherche réduit drastiquement, appliquer le reste normalement
      if (result.length < 100) {
        return applyFilters(result, state);
      }
    }

    // Continuer avec les autres filtres
    if (state.selectedType != null) {
      result = filterByType(result, state.selectedType.toString());
    }

    result = filterByStatus(
      result,
      showCompleted: state.showCompleted,
      showInProgress: state.showInProgress,
    );

    if (state.selectedDateFilter != null) {
      result = filterByDate(result, state.selectedDateFilter);
    }

    result = sortLists(result, state.sortOption);

    LoggerService.instance.info(
      'Filtrage optimisé terminé: ${result.length} résultats',
      context: 'ListsFilterManager',
    );

    return result;
  }
}