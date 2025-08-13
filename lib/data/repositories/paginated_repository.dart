import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Classe pour gérer les résultats paginés
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  })  : hasNextPage = (currentPage * pageSize) < totalCount,
        hasPreviousPage = currentPage > 1;

  int get totalPages => (totalCount / pageSize).ceil();
}

/// Repository avec support de pagination native
class PaginatedListRepository {
  final Box<CustomList> _box;
  
  // Cache pour améliorer les performances
  List<CustomList>? _cachedLists;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  PaginatedListRepository(this._box);

  /// Invalide le cache
  void invalidateCache() {
    _cachedLists = null;
    _cacheTimestamp = null;
  }

  /// Vérifie si le cache est valide
  bool _isCacheValid() {
    if (_cachedLists == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheValidity;
  }

  /// Récupère les listes avec pagination
  Future<PaginatedResult<CustomList>> getPaginatedLists({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? category,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
    SortOrder sortOrder = SortOrder.dateDescending,
  }) async {
    // Utiliser le cache si valide
    List<CustomList> allLists;
    if (_isCacheValid()) {
      allLists = _cachedLists!;
    } else {
      allLists = _box.values.toList();
      _cachedLists = allLists;
      _cacheTimestamp = DateTime.now();
    }

    // Appliquer les filtres
    var filteredLists = _applyFilters(
      allLists,
      searchQuery: searchQuery,
      category: category,
      isCompleted: isCompleted,
      startDate: startDate,
      endDate: endDate,
    );

    // Trier les résultats
    filteredLists = _applySorting(filteredLists, sortOrder);

    // Calculer la pagination
    final totalCount = filteredLists.length;
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    // Extraire la page demandée
    final paginatedLists = filteredLists.sublist(
      startIndex,
      endIndex > totalCount ? totalCount : endIndex,
    );

    return PaginatedResult(
      items: paginatedLists,
      totalCount: totalCount,
      currentPage: page,
      pageSize: pageSize,
    );
  }

  /// Récupère les éléments d'une liste avec pagination
  Future<PaginatedResult<ListItem>> getPaginatedListItems({
    required String listId,
    int page = 1,
    int pageSize = 50,
    String? searchQuery,
    bool? isCompleted,
    SortOrder sortOrder = SortOrder.priorityDescending,
  }) async {
    final list = _box.get(listId);
    if (list == null) {
      return PaginatedResult(
        items: [],
        totalCount: 0,
        currentPage: page,
        pageSize: pageSize,
      );
    }

    // Filtrer les éléments
    var items = list.items.where((item) {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!item.title.toLowerCase().contains(query) &&
            !(item.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      if (isCompleted != null && item.isCompleted != isCompleted) {
        return false;
      }
      return true;
    }).toList();

    // Trier les éléments
    items = _sortItems(items, sortOrder);

    // Paginer
    final totalCount = items.length;
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    final paginatedItems = items.sublist(
      startIndex,
      endIndex > totalCount ? totalCount : endIndex,
    );

    return PaginatedResult(
      items: paginatedItems,
      totalCount: totalCount,
      currentPage: page,
      pageSize: pageSize,
    );
  }

  /// Applique les filtres sur les listes
  List<CustomList> _applyFilters(
    List<CustomList> lists, {
    String? searchQuery,
    String? category,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return lists.where((list) {
      // Filtre par recherche
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!list.name.toLowerCase().contains(query) &&
            !(list.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filtre par catégorie (via le type)
      if (category != null) {
        if (list.type.name != category) {
          return false;
        }
      }

      // Filtre par état de complétion
      if (isCompleted != null) {
        final listCompleted = list.items.isNotEmpty &&
            list.items.every((item) => item.isCompleted);
        if (listCompleted != isCompleted) {
          return false;
        }
      }

      // Filtre par date
      if (startDate != null && list.createdAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && list.createdAt.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Applique le tri sur les listes
  List<CustomList> _applySorting(List<CustomList> lists, SortOrder sortOrder) {
    final sortedLists = List<CustomList>.from(lists);

    switch (sortOrder) {
      case SortOrder.dateAscending:
        sortedLists.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOrder.dateDescending:
        sortedLists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOrder.nameAscending:
        sortedLists.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOrder.nameDescending:
        sortedLists.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOrder.progressAscending:
        sortedLists.sort((a, b) {
          final progressA = _calculateProgress(a);
          final progressB = _calculateProgress(b);
          return progressA.compareTo(progressB);
        });
        break;
      case SortOrder.progressDescending:
        sortedLists.sort((a, b) {
          final progressA = _calculateProgress(a);
          final progressB = _calculateProgress(b);
          return progressB.compareTo(progressA);
        });
        break;
      default:
        break;
    }

    return sortedLists;
  }

  /// Trie les éléments d'une liste
  List<ListItem> _sortItems(List<ListItem> items, SortOrder sortOrder) {
    final sortedItems = List<ListItem>.from(items);

    switch (sortOrder) {
      case SortOrder.priorityAscending:
        sortedItems.sort((a, b) => a.eloScore.compareTo(b.eloScore));
        break;
      case SortOrder.priorityDescending:
        sortedItems.sort((a, b) => b.eloScore.compareTo(a.eloScore));
        break;
      case SortOrder.dateAscending:
        sortedItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOrder.dateDescending:
        sortedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOrder.nameAscending:
        sortedItems.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOrder.nameDescending:
        sortedItems.sort((a, b) => b.title.compareTo(a.title));
        break;
      default:
        break;
    }

    return sortedItems;
  }

  /// Calcule la progression d'une liste
  double _calculateProgress(CustomList list) {
    if (list.items.isEmpty) return 0.0;
    final completedCount = list.items.where((item) => item.isCompleted).length;
    return completedCount / list.items.length;
  }

  /// Méthode optimisée pour compter les éléments
  Future<int> countItems({
    String? listId,
    bool? isCompleted,
  }) async {
    if (listId != null) {
      final list = _box.get(listId);
      if (list == null) return 0;
      
      if (isCompleted != null) {
        return list.items.where((item) => item.isCompleted == isCompleted).length;
      }
      return list.items.length;
    }

    // Compter tous les éléments de toutes les listes
    int count = 0;
    for (final list in _box.values) {
      if (isCompleted != null) {
        count += list.items.where((item) => item.isCompleted == isCompleted).length;
      } else {
        count += list.items.length;
      }
    }
    return count;
  }

  /// Précharge les données pour améliorer les performances
  Future<void> preloadData() async {
    if (!_isCacheValid()) {
      _cachedLists = _box.values.toList();
      _cacheTimestamp = DateTime.now();
    }
  }
}

/// Énumération pour les ordres de tri
enum SortOrder {
  dateAscending,
  dateDescending,
  nameAscending,
  nameDescending,
  priorityAscending,
  priorityDescending,
  progressAscending,
  progressDescending,
}