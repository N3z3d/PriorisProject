import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Options de tri pour les listes
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

/// Service pour filtrer et trier les listes
/// 
/// Centralise toute la logique de filtrage et de tri des listes
/// avec optimisations pour les performances.
class ListsFilterService {
  // Cache pour éviter les recalculs coûteux
  String? _lastFilterKey;
  List<CustomList> _cachedFiltered = const [];
  final Map<String, double> _progressCache = {};

  /// Applique tous les filtres et tri à une liste de listes
  List<CustomList> applyFilters(
    List<CustomList> lists, {
    String searchQuery = '',
    ListType? selectedType,
    bool showCompleted = true,
    bool showInProgress = true,
    String? selectedDateFilter,
    SortOption sortOption = SortOption.NAME_ASC,
  }) {
    // Vérification du cache
    final filterKey = _generateFilterKey(
      lists, searchQuery, selectedType, showCompleted, 
      showInProgress, selectedDateFilter, sortOption,
    );

    if (_isResultCached(filterKey)) {
      return _cachedFiltered;
    }

    // Application des filtres et tri
    final filtered = _processLists(
      lists, searchQuery, selectedType, showCompleted, 
      showInProgress, selectedDateFilter, sortOption,
    );

    // Mise à jour du cache
    _updateCache(filterKey, filtered);

    return filtered;
  }

  /// Vérifie si le résultat est déjà en cache
  bool _isResultCached(String filterKey) {
    return filterKey == _lastFilterKey;
  }

  /// Traite les listes avec filtrage et tri
  List<CustomList> _processLists(
    List<CustomList> lists,
    String searchQuery,
    ListType? selectedType,
    bool showCompleted,
    bool showInProgress,
    String? selectedDateFilter,
    SortOption sortOption,
  ) {
    // Filtrage
    var filtered = _filterLists(
      lists, searchQuery, selectedType, showCompleted, 
      showInProgress, selectedDateFilter,
    );

    // Tri
    filtered = _sortLists(filtered, sortOption);

    return filtered;
  }

  /// Met à jour le cache avec les nouveaux résultats
  void _updateCache(String filterKey, List<CustomList> filtered) {
    _lastFilterKey = filterKey;
    _cachedFiltered = filtered;
  }

  /// Filtre les listes selon les critères
  List<CustomList> _filterLists(
    List<CustomList> lists,
    String searchQuery,
    ListType? selectedType,
    bool showCompleted,
    bool showInProgress,
    String? selectedDateFilter,
  ) {
    return lists.where((list) {
      return _passesAllFilters(
        list, searchQuery, selectedType, showCompleted, 
        showInProgress, selectedDateFilter,
      );
    }).toList();
  }

  /// Vérifie si une liste passe tous les filtres
  bool _passesAllFilters(
    CustomList list,
    String searchQuery,
    ListType? selectedType,
    bool showCompleted,
    bool showInProgress,
    String? selectedDateFilter,
  ) {
    return _matchesSearchQuery(list, searchQuery) &&
           _matchesType(list, selectedType) &&
           _matchesStatus(list, showCompleted, showInProgress) &&
           _matchesDateFilter(list, selectedDateFilter);
  }

  /// Vérifie si la liste correspond à la recherche
  bool _matchesSearchQuery(CustomList list, String searchQuery) {
    if (searchQuery.isEmpty) return true;

    final query = searchQuery.toLowerCase();
    return _searchInListContent(list, query);
  }

  /// Recherche dans le contenu de la liste
  bool _searchInListContent(CustomList list, String query) {
    final matchesName = list.name.toLowerCase().contains(query);
    final matchesDescription = list.description?.toLowerCase().contains(query) ?? false;
    final matchesItems = _searchInItems(list.items, query);
    
    return matchesName || matchesDescription || matchesItems;
  }

  /// Recherche dans les éléments de la liste
  bool _searchInItems(List items, String query) {
    return items.any((item) =>
        item.title.toLowerCase().contains(query) ||
        item.description?.toLowerCase().contains(query) == true);
  }

  /// Vérifie si la liste correspond au type sélectionné
  bool _matchesType(CustomList list, ListType? selectedType) {
    return selectedType == null || list.type == selectedType;
  }

  /// Vérifie si la liste correspond aux filtres de statut
  bool _matchesStatus(CustomList list, bool showCompleted, bool showInProgress) {
    final progress = _calculateProgress(list);
    final isCompleted = progress == 1.0;
    
    if (isCompleted && !showCompleted) return false;
    if (!isCompleted && !showInProgress) return false;
    
    return true;
  }

  /// Vérifie si la liste correspond au filtre de date
  bool _matchesDateFilter(CustomList list, String? selectedDateFilter) {
    if (selectedDateFilter == null) return true;

    final now = DateTime.now();
    final listDate = list.createdAt;
    
    return _matchesDatePeriod(listDate, now, selectedDateFilter);
  }

  /// Vérifie si la date correspond à la période
  bool _matchesDatePeriod(DateTime listDate, DateTime now, String period) {
    switch (period) {
      case 'today':
        return _isSameDay(listDate, now);
      case 'week':
        return _isSameWeek(listDate, now);
      case 'month':
        return _isSameMonth(listDate, now);
      case 'year':
        return listDate.year == now.year;
      default:
        return true;
    }
  }

  /// Trie les listes selon l'option sélectionnée
  List<CustomList> _sortLists(List<CustomList> lists, SortOption sortOption) {
    final sortedLists = List<CustomList>.from(lists);
    
    switch (sortOption) {
      case SortOption.NAME_ASC:
        sortedLists.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.NAME_DESC:
        sortedLists.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.DATE_CREATED_ASC:
        sortedLists.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.DATE_CREATED_DESC:
        sortedLists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.PROGRESS_ASC:
        sortedLists.sort((a, b) => _calculateProgress(a).compareTo(_calculateProgress(b)));
        break;
      case SortOption.PROGRESS_DESC:
        sortedLists.sort((a, b) => _calculateProgress(b).compareTo(_calculateProgress(a)));
        break;
      case SortOption.ITEMS_COUNT_ASC:
        sortedLists.sort((a, b) => a.items.length.compareTo(b.items.length));
        break;
      case SortOption.ITEMS_COUNT_DESC:
        sortedLists.sort((a, b) => b.items.length.compareTo(a.items.length));
        break;
    }
    
    return sortedLists;
  }

  /// Calcule la progression d'une liste avec cache
  double _calculateProgress(CustomList list) {
    if (_progressCache.containsKey(list.id)) {
      return _progressCache[list.id]!;
    }

    final progress = list.items.isEmpty ? 0.0 : list.getProgress();
    _progressCache[list.id] = progress;
    
    return progress;
  }

  /// Génère une clé unique pour le cache
  String _generateFilterKey(
    List<CustomList> lists,
    String searchQuery,
    ListType? selectedType,
    bool showCompleted,
    bool showInProgress,
    String? selectedDateFilter,
    SortOption sortOption,
  ) {
    return [
      searchQuery,
      selectedType?.name ?? 'all',
      showCompleted,
      showInProgress,
      selectedDateFilter ?? 'all',
      sortOption.name,
      lists.hashCode,
    ].join('|');
  }

  /// Vérifie si deux dates sont le même jour
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Vérifie si deux dates sont dans la même semaine
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final week1 = date1.difference(DateTime(date1.year, 1, 1)).inDays ~/ 7;
    final week2 = date2.difference(DateTime(date2.year, 1, 1)).inDays ~/ 7;
    return date1.year == date2.year && week1 == week2;
  }

  /// Vérifie si deux dates sont dans le même mois
  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Nettoie le cache
  void clearCache() {
    _lastFilterKey = null;
    _cachedFiltered = [];
    _progressCache.clear();
  }
} 
