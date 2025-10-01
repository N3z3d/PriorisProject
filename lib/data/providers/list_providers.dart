import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/providers/clean_repository_providers.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';

/// Configuration des filtres et tri pour les listes
class ListsConfig {
  final String searchQuery;
  final ListType? typeFilter;
  final bool showCompleted;
  final bool showInProgress;
  final String? dateFilter;
  final String sortBy;
  final Map<String, dynamic> advancedFilters;

  const ListsConfig({
    this.searchQuery = '',
    this.typeFilter,
    this.showCompleted = true,
    this.showInProgress = true,
    this.dateFilter,
    this.sortBy = 'date',
    this.advancedFilters = const {},
  });

  ListsConfig copyWith({
    String? searchQuery,
    ListType? typeFilter,
    bool? showCompleted,
    bool? showInProgress,
    String? dateFilter,
    String? sortBy,
    Map<String, dynamic>? advancedFilters,
  }) {
    return ListsConfig(
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      showCompleted: showCompleted ?? this.showCompleted,
      showInProgress: showInProgress ?? this.showInProgress,
      dateFilter: dateFilter ?? this.dateFilter,
      sortBy: sortBy ?? this.sortBy,
      advancedFilters: advancedFilters ?? this.advancedFilters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListsConfig &&
        other.searchQuery == searchQuery &&
        other.typeFilter == typeFilter &&
        other.showCompleted == showCompleted &&
        other.showInProgress == showInProgress &&
        other.dateFilter == dateFilter &&
        other.sortBy == sortBy &&
        other.advancedFilters.toString() == advancedFilters.toString();
  }

  @override
  int get hashCode {
    return Object.hash(
      searchQuery,
      typeFilter,
      showCompleted,
      showInProgress,
      dateFilter,
      sortBy,
      advancedFilters.toString(),
    );
  }
}

/// État consolidé des listes avec cache intelligent
class ConsolidatedListsState {
  final List<CustomList> rawLists;
  final List<CustomList> processedLists;
  final ListsConfig config;
  final Map<String, dynamic> statistics;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  const ConsolidatedListsState({
    this.rawLists = const [],
    this.processedLists = const [],
    this.config = const ListsConfig(),
    this.statistics = const {},
    this.isLoading = false,
    this.error,
    required this.lastUpdated,
  });

  ConsolidatedListsState copyWith({
    List<CustomList>? rawLists,
    List<CustomList>? processedLists,
    ListsConfig? config,
    Map<String, dynamic>? statistics,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return ConsolidatedListsState(
      rawLists: rawLists ?? this.rawLists,
      processedLists: processedLists ?? this.processedLists,
      config: config ?? this.config,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// StateNotifier consolidé pour gérer tous les aspects des listes
class ConsolidatedListsNotifier extends StateNotifier<ConsolidatedListsState> {
  final ListsFilterService _filterService;
  final Ref _ref;

  ConsolidatedListsNotifier(this._ref)
      : _filterService = ListsFilterService(),
        super(ConsolidatedListsState(lastUpdated: DateTime.now()));

  /// Charge les listes depuis le repository
  Future<void> loadLists() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final repository = _ref.read(customListRepositoryProvider);
      final lists = await repository.getAllLists();
      
      await _updateListsAndProcess(lists);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Met à jour la configuration et recalcule
  void updateConfig(ListsConfig newConfig) {
    if (state.config == newConfig) return;
    
    state = state.copyWith(config: newConfig);
    _processLists();
  }

  /// Met à jour les listes et recalcule tout
  Future<void> _updateListsAndProcess(List<CustomList> newLists) async {
    final statistics = _calculateStatistics(newLists);
    
    state = state.copyWith(
      rawLists: newLists,
      statistics: statistics,
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
    
    _processLists();
  }

  /// Traite les listes selon la configuration actuelle
  void _processLists() {
    final processed = _applyFiltersAndSort(state.rawLists, state.config);
    state = state.copyWith(processedLists: processed);
  }

  /// Applique filtres et tri
  List<CustomList> _applyFiltersAndSort(List<CustomList> lists, ListsConfig config) {
    var result = List<CustomList>.from(lists);

    // Recherche textuelle
    if (config.searchQuery.isNotEmpty) {
      final query = config.searchQuery.toLowerCase();
      result = result.where((list) =>
          list.name.toLowerCase().contains(query) ||
          (list.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filtre par type
    if (config.typeFilter != null) {
      result = result.where((list) => list.type == config.typeFilter).toList();
    }

    // Filtre par statut de complétion
    result = result.where((list) {
      if (!config.showCompleted && list.isCompleted) return false;
      if (!config.showInProgress && !list.isCompleted) return false;
      return true;
    }).toList();

    // Filtres avancés
    for (final entry in config.advancedFilters.entries) {
      result = _applyAdvancedFilter(result, entry.key, entry.value);
    }

    // Tri
    _sortLists(result, config.sortBy);

    return result;
  }

  /// Applique un filtre avancé spécifique
  List<CustomList> _applyAdvancedFilter(List<CustomList> lists, String filterType, dynamic value) {
    switch (filterType) {
      case 'minProgress':
        return lists.where((l) => l.getProgress() >= (value as double)).toList();
      case 'maxProgress':
        return lists.where((l) => l.getProgress() <= (value as double)).toList();
      case 'minItems':
        return lists.where((l) => l.itemCount >= (value as int)).toList();
      case 'maxItems':
        return lists.where((l) => l.itemCount <= (value as int)).toList();
      case 'isCompleted':
        return lists.where((l) => l.isCompleted == (value as bool)).toList();
      default:
        return lists;
    }
  }

  /// Trie les listes selon le critère
  void _sortLists(List<CustomList> lists, String sortBy) {
    switch (sortBy) {
      case 'progress':
        lists.sort((a, b) => b.getProgress().compareTo(a.getProgress()));
        break;
      case 'progress_asc':
        lists.sort((a, b) => a.getProgress().compareTo(b.getProgress()));
        break;
      case 'date':
        lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'date_asc':
        lists.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'updated':
        lists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'updated_asc':
        lists.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'items':
        lists.sort((a, b) => b.itemCount.compareTo(a.itemCount));
        break;
      case 'items_asc':
        lists.sort((a, b) => a.itemCount.compareTo(b.itemCount));
        break;
      case 'name':
        lists.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        lists.sort((a, b) => b.name.compareTo(a.name));
        break;
      default:
        lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  /// Calcule les statistiques globales et par type
  Map<String, dynamic> _calculateStatistics(List<CustomList> lists) {
    if (lists.isEmpty) {
      return {
        'global': {
          'totalLists': 0,
          'totalItems': 0,
          'completedItems': 0,
          'averageProgress': 0.0,
        },
        'byType': <String, Map<String, dynamic>>{},
      };
    }

    // Statistiques globales
    final totalLists = lists.length;
    final totalItems = lists.fold<int>(0, (sum, l) => sum + l.itemCount);
    final completedItems = lists.fold<int>(0, (sum, l) => sum + l.completedCount);
    final avgProgress = lists.map((l) => l.getProgress()).reduce((a, b) => a + b) / totalLists;

    // Statistiques par type
    final statsByType = <String, Map<String, dynamic>>{};
    for (final type in ListType.values) {
      final typeLists = lists.where((l) => l.type == type).toList();
      final typeTotal = typeLists.length;
      
      if (typeTotal > 0) {
        final typeTotalItems = typeLists.fold<int>(0, (sum, l) => sum + l.itemCount);
        final typeCompletedItems = typeLists.fold<int>(0, (sum, l) => sum + l.completedCount);
        final typeAvgProgress = typeLists.map((l) => l.getProgress()).reduce((a, b) => a + b) / typeTotal;
        
        statsByType[type.name] = {
          'totalLists': typeTotal,
          'totalItems': typeTotalItems,
          'completedItems': typeCompletedItems,
          'averageProgress': typeAvgProgress,
        };
      }
    }

    return {
      'global': {
        'totalLists': totalLists,
        'totalItems': totalItems,
        'completedItems': completedItems,
        'averageProgress': avgProgress,
      },
      'byType': statsByType,
    };
  }

  @override
  void dispose() {
    _filterService.clearCache();
    super.dispose();
  }
}

// ============================================================================
// PROVIDERS CONSOLIDÉS (4 providers au lieu de 17)
// ============================================================================

/// 1. Provider principal : StateNotifier consolidé
final consolidatedListsProvider = StateNotifierProvider<ConsolidatedListsNotifier, ConsolidatedListsState>((ref) {
  return ConsolidatedListsNotifier(ref);
});

/// 2. Provider pour les listes filtrées et triées (le plus utilisé)
final processedListsProvider = Provider<List<CustomList>>((ref) {
  return ref.watch(consolidatedListsProvider).processedLists;
});

/// 3. Provider pour les statistiques (global + par type)
final listsStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(consolidatedListsProvider).statistics;
});

/// 4. Provider pour la configuration actuelle des filtres/tri
final listsConfigProvider = Provider<ListsConfig>((ref) {
  return ref.watch(consolidatedListsProvider).config;
});

// ============================================================================
// ALIASES DE COMPATIBILITÉ (pour la migration progressive)
// ============================================================================





// ============================================================================
// HELPERS POUR L'UTILISATION MODERNE
// ============================================================================

/// Extension pour simplifier l'utilisation du provider consolidé
extension ConsolidatedListsProviderX on WidgetRef {
  /// Charge les listes si pas encore fait
  void loadListsIfNeeded() {
    final state = read(consolidatedListsProvider);
    if (state.rawLists.isEmpty && !state.isLoading) {
      read(consolidatedListsProvider.notifier).loadLists();
    }
  }

  /// Met à jour la recherche
  void updateSearch(String query) {
    final currentConfig = read(consolidatedListsProvider).config;
    read(consolidatedListsProvider.notifier).updateConfig(
      currentConfig.copyWith(searchQuery: query),
    );
  }

  /// Met à jour le filtre par type
  void updateTypeFilter(ListType? type) {
    final currentConfig = read(consolidatedListsProvider).config;
    read(consolidatedListsProvider.notifier).updateConfig(
      currentConfig.copyWith(typeFilter: type),
    );
  }

  /// Met à jour le tri
  void updateSort(String sortBy) {
    final currentConfig = read(consolidatedListsProvider).config;
    read(consolidatedListsProvider.notifier).updateConfig(
      currentConfig.copyWith(sortBy: sortBy),
    );
  }

  /// Applique des filtres avancés
  void updateAdvancedFilters(Map<String, dynamic> filters) {
    final currentConfig = read(consolidatedListsProvider).config;
    read(consolidatedListsProvider.notifier).updateConfig(
      currentConfig.copyWith(advancedFilters: filters),
    );
  }

  /// Obtient les statistiques pour un type spécifique
  Map<String, dynamic>? getStatsForType(ListType type) {
    final stats = read(listsStatisticsProvider);
    final byType = stats['byType'] as Map<String, dynamic>? ?? {};
    return byType[type.name] as Map<String, dynamic>?;
  }
}