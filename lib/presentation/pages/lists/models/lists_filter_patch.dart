import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'lists_state.dart';

/// Représente un patch des filtres appliqués au `ListsState`.
class ListsFilterPatch {
  final String? searchQuery;
  final ListType? selectedType;
  final bool? showCompleted;
  final bool? showInProgress;
  final String? selectedDateFilter;
  final SortOption? sortOption;

  const ListsFilterPatch({
    this.searchQuery,
    this.selectedType,
    this.showCompleted,
    this.showInProgress,
    this.selectedDateFilter,
    this.sortOption,
  });

  factory ListsFilterPatch.search(String query) =>
      ListsFilterPatch(searchQuery: query);

  factory ListsFilterPatch.type(ListType? type) =>
      ListsFilterPatch(selectedType: type);

  factory ListsFilterPatch.showCompleted(bool value) =>
      ListsFilterPatch(showCompleted: value);

  factory ListsFilterPatch.showInProgress(bool value) =>
      ListsFilterPatch(showInProgress: value);

  factory ListsFilterPatch.dateFilter(String? filter) =>
      ListsFilterPatch(selectedDateFilter: filter);

  factory ListsFilterPatch.sort(SortOption option) =>
      ListsFilterPatch(sortOption: option);

  ListsFilterPatch copyWith({
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
  }) {
    return ListsFilterPatch(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      showCompleted: showCompleted ?? this.showCompleted,
      showInProgress: showInProgress ?? this.showInProgress,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
