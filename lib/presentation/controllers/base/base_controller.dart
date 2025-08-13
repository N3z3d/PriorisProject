import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// État de base pour tous les controllers
@immutable
abstract class BaseState {
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const BaseState({
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  bool get hasError => error != null;
  bool get isReady => !isLoading && !hasError;
}

/// Controller de base avec gestion d'état et d'erreurs
abstract class BaseController<T extends BaseState> extends StateNotifier<T> {
  BaseController(super.initialState);

  /// Met à jour l'état de chargement
  void setLoading(bool loading) {
    state = updateState(state, isLoading: loading, error: null) as T;
  }

  /// Met à jour l'erreur
  void setError(String? error) {
    state = updateState(state, isLoading: false, error: error) as T;
  }

  /// Réinitialise l'erreur
  void clearError() {
    state = updateState(state, error: null) as T;
  }

  /// Exécute une opération asynchrone avec gestion d'erreur
  Future<R?> executeAsync<R>(
    Future<R> Function() operation, {
    bool showLoading = true,
    String? errorMessage,
  }) async {
    try {
      if (showLoading) setLoading(true);
      final result = await operation();
      if (showLoading) setLoading(false);
      return result;
    } catch (e) {
      setError(errorMessage ?? 'Une erreur est survenue: $e');
      return null;
    }
  }

  /// Méthode abstraite pour mettre à jour l'état
  /// Doit être implémentée par les sous-classes
  BaseState updateState(
    T currentState, {
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  });

  /// Rafraîchit les données
  Future<void> refresh() async {
    // À implémenter par les sous-classes si nécessaire
  }

  /// Nettoie les ressources
  @override
  void dispose() {
    // Nettoyer les ressources si nécessaire
    super.dispose();
  }
}

/// Mixin pour ajouter la pagination aux controllers
mixin PaginationMixin<T extends BaseState> on BaseController<T> {
  int _currentPage = 0;
  int _pageSize = 20;
  bool _hasMore = true;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMore => _hasMore;

  void resetPagination() {
    _currentPage = 0;
    _hasMore = true;
  }

  void setPageSize(int size) {
    _pageSize = size;
    resetPagination();
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || state.isLoading) return;
    
    await executeAsync(() async {
      final items = await fetchPage(_currentPage, _pageSize);
      if (items.length < _pageSize) {
        _hasMore = false;
      }
      _currentPage++;
      onPageLoaded(items);
    });
  }

  /// À implémenter par les classes qui utilisent ce mixin
  Future<List<dynamic>> fetchPage(int page, int pageSize);
  void onPageLoaded(List<dynamic> items);
}

/// Mixin pour ajouter la recherche aux controllers
mixin SearchMixin<T extends BaseState> on BaseController<T> {
  String _searchQuery = '';
  Duration _debounceD = const Duration(milliseconds: 300);
  DateTime? _lastSearchTime;

  String get searchQuery => _searchQuery;

  Future<void> search(String query) async {
    _searchQuery = query;
    _lastSearchTime = DateTime.now();
    final searchTime = _lastSearchTime;
    
    // Debounce
    await Future.delayed(_debounceD);
    
    // Si une nouvelle recherche a été lancée, annuler celle-ci
    if (_lastSearchTime != searchTime) return;
    
    await executeAsync(() => performSearch(query));
  }

  void clearSearch() {
    _searchQuery = '';
    onSearchCleared();
  }

  void setDebounceDuration(Duration duration) {
    _debounceD = duration;
  }

  /// À implémenter par les classes qui utilisent ce mixin
  Future<void> performSearch(String query);
  void onSearchCleared();
}

/// Mixin pour ajouter le filtrage aux controllers
mixin FilterMixin<T extends BaseState> on BaseController<T> {
  Map<String, dynamic> _filters = {};

  Map<String, dynamic> get filters => Map.unmodifiable(_filters);

  void setFilter(String key, dynamic value) {
    _filters[key] = value;
    onFiltersChanged(_filters);
  }

  void removeFilter(String key) {
    _filters.remove(key);
    onFiltersChanged(_filters);
  }

  void clearFilters() {
    _filters.clear();
    onFiltersChanged(_filters);
  }

  void setFilters(Map<String, dynamic> newFilters) {
    _filters = Map.from(newFilters);
    onFiltersChanged(_filters);
  }

  bool hasFilter(String key) => _filters.containsKey(key);
  
  dynamic getFilter(String key) => _filters[key];

  /// À implémenter par les classes qui utilisent ce mixin
  void onFiltersChanged(Map<String, dynamic> filters);
}

/// Mixin pour ajouter le tri aux controllers
mixin SortMixin<T extends BaseState> on BaseController<T> {
  String _sortField = 'createdAt';
  bool _ascending = false;

  String get sortField => _sortField;
  bool get ascending => _ascending;

  void setSortField(String field, {bool? ascending}) {
    if (_sortField == field && ascending == null) {
      // Si on clique sur le même champ, inverser l'ordre
      _ascending = !_ascending;
    } else {
      _sortField = field;
      _ascending = ascending ?? false;
    }
    onSortChanged(_sortField, _ascending);
  }

  void toggleSortOrder() {
    _ascending = !_ascending;
    onSortChanged(_sortField, _ascending);
  }

  /// À implémenter par les classes qui utilisent ce mixin
  void onSortChanged(String field, bool ascending);
}

/// Controller avec toutes les fonctionnalités
abstract class FullFeaturedController<T extends BaseState> extends BaseController<T>
    with PaginationMixin<T>, SearchMixin<T>, FilterMixin<T>, SortMixin<T> {
  
  FullFeaturedController(super.initialState);

  /// Réinitialise tout (pagination, recherche, filtres, tri)
  void resetAll() {
    resetPagination();
    clearSearch();
    clearFilters();
    setSortField('createdAt', ascending: false);
  }
}