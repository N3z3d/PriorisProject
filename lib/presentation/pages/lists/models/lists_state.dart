import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Options de tri pour les listes
enum SortOption {
  NAME_ASC,
  NAME_DESC,
  DATE_CREATED_ASC,
  DATE_CREATED_DESC,
  PROGRESS_ASC,
  PROGRESS_DESC,
}

/// État immutable du controller des listes
///
/// **Responsabilité unique** : Contenir et transformer les données d'état des listes
/// **SRP compliant** : Se concentre uniquement sur la représentation des données
/// **Immutable by design** : Toutes les modifications passent par copyWith()
class ListsState {
  /// Toutes les listes chargées depuis la persistance
  final List<CustomList> lists;

  /// Listes après application des filtres de recherche et tri
  final List<CustomList> filteredLists;

  /// Terme de recherche pour filtrer les listes par nom
  final String searchQuery;

  /// Filtre par type de liste (optionnel)
  final ListType? selectedType;

  /// Afficher les listes terminées dans les résultats
  final bool showCompleted;

  /// Afficher les listes en cours dans les résultats
  final bool showInProgress;

  /// Filtre par période de création (optionnel)
  final String? selectedDateFilter;

  /// Option de tri appliquée aux résultats
  final SortOption sortOption;

  /// Indicateur de chargement en cours
  final bool isLoading;

  /// Message d'erreur (null si aucune erreur)
  final String? error;

  const ListsState({
    this.lists = const [],
    this.filteredLists = const [],
    this.searchQuery = '',
    this.selectedType,
    this.showCompleted = true,
    this.showInProgress = true,
    this.selectedDateFilter,
    this.sortOption = SortOption.NAME_ASC,
    this.isLoading = false,
    this.error,
  });

  /// **Factory constructor** - État initial vide
  const ListsState.initial() : this();

  /// **Factory constructor** - État de chargement
  const ListsState.loading() : this(isLoading: true);

  /// **Factory constructor** - État d'erreur
  const ListsState.error(String errorMessage) : this(
    isLoading: false,
    error: errorMessage,
  );

  /// **Immutable update** - Crée une copie avec de nouvelles valeurs
  ///
  /// Respecte le principe d'immutabilité pour éviter les effets de bord
  ListsState copyWith({
    List<CustomList>? lists,
    List<CustomList>? filteredLists,
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
    bool? isLoading,
    String? error,
  }) {
    return ListsState(
      lists: lists ?? this.lists,
      filteredLists: filteredLists ?? this.filteredLists,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      showCompleted: showCompleted ?? this.showCompleted,
      showInProgress: showInProgress ?? this.showInProgress,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// **Utility method** - État avec loading activé
  ListsState withLoading({bool loading = true}) {
    return copyWith(
      isLoading: loading,
      error: loading ? null : error, // Clear error when starting loading
    );
  }

  /// **Utility method** - État avec erreur
  ListsState withError(String errorMessage) {
    return copyWith(
      isLoading: false,
      error: 'Erreur: $errorMessage',
    );
  }

  /// **Utility method** - État avec erreur effacée
  ListsState withoutError() {
    return copyWith(error: null);
  }

  /// **Validation method** - Vérifie la cohérence des données
  bool get isValid {
    // Vérifications de base
    if (lists.length < filteredLists.length) return false;
    if (isLoading && error != null) return false;

    // Vérifier que filteredLists est un sous-ensemble de lists
    for (final filteredList in filteredLists) {
      if (!lists.any((list) => list.id == filteredList.id)) {
        return false;
      }
    }

    return true;
  }

  /// **Computed property** - Nombre total de listes
  int get totalListsCount => lists.length;

  /// **Computed property** - Nombre de listes filtrées
  int get filteredListsCount => filteredLists.length;

  /// **Computed property** - Indique si des filtres sont actifs
  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
           selectedType != null ||
           !showCompleted ||
           !showInProgress ||
           selectedDateFilter != null ||
           sortOption != SortOption.NAME_ASC;
  }

  /// **Computed property** - Indique si l'état est vide (aucune liste)
  bool get isEmpty => lists.isEmpty;

  /// **Computed property** - Indique si l'état a des données mais aucun résultat filtré
  bool get hasDataButNoResults => lists.isNotEmpty && filteredLists.isEmpty;

  /// **Utility method** - Recherche une liste par ID
  CustomList? findListById(String listId) {
    try {
      return lists.firstWhere((list) => list.id == listId);
    } catch (e) {
      return null;
    }
  }

  /// **Utility method** - Compte les éléments total dans toutes les listes
  int get totalItemsCount {
    return lists.fold(0, (sum, list) => sum + list.items.length);
  }

  /// **Utility method** - Compte les éléments terminés dans toutes les listes
  int get completedItemsCount {
    return lists.fold(0, (sum, list) =>
      sum + list.items.where((item) => item.isCompleted).length);
  }

  /// **Debug method** - Représentation string pour debug
  @override
  String toString() {
    return 'ListsState('
        'lists: ${lists.length}, '
        'filteredLists: ${filteredLists.length}, '
        'searchQuery: "$searchQuery", '
        'selectedType: $selectedType, '
        'showCompleted: $showCompleted, '
        'showInProgress: $showInProgress, '
        'selectedDateFilter: $selectedDateFilter, '
        'sortOption: $sortOption, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }

  /// **Equality method** - Compare deux états
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListsState &&
        _listEquals(other.lists, lists) &&
        _listEquals(other.filteredLists, filteredLists) &&
        other.searchQuery == searchQuery &&
        other.selectedType == selectedType &&
        other.showCompleted == showCompleted &&
        other.showInProgress == showInProgress &&
        other.selectedDateFilter == selectedDateFilter &&
        other.sortOption == sortOption &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  /// **Helper method** - Compare deux listes de CustomList
  bool _listEquals(List<CustomList> a, List<CustomList> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(lists.map((l) => l.id)),
      Object.hashAll(filteredLists.map((l) => l.id)),
      searchQuery,
      selectedType,
      showCompleted,
      showInProgress,
      selectedDateFilter,
      sortOption,
      isLoading,
      error,
    );
  }
}