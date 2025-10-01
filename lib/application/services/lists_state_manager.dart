/// SOLID-compliant state management service implementation
/// Responsibility: Managing state updates and notifications only

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Concrete implementation of IListsStateManager following SRP
/// Uses StateNotifier pattern for reactive state management
class ListsStateManager extends StateNotifier<ListsStateSnapshot>
    implements IListsStateManager {

  final StreamController<ListsStateSnapshot> _stateStreamController =
      StreamController<ListsStateSnapshot>.broadcast();

  bool _isDisposed = false;

  ListsStateManager() : super(const ListsStateSnapshot(
    lists: [],
    filteredLists: [],
    searchQuery: '',
    selectedType: null,
    showCompleted: true,
    showInProgress: true,
    selectedDateFilter: null,
    sortOption: SortOption.NAME_ASC,
    isLoading: false,
    error: null,
  )) {
    LoggerService.instance.debug(
      'ListsStateManager initialized',
      context: 'ListsStateManager',
    );
  }

  @override
  List<CustomList> get lists => state.lists;

  @override
  List<CustomList> get filteredLists => state.filteredLists;

  @override
  String get searchQuery => state.searchQuery;

  @override
  ListType? get selectedType => state.selectedType;

  @override
  bool get showCompleted => state.showCompleted;

  @override
  bool get showInProgress => state.showInProgress;

  @override
  String? get selectedDateFilter => state.selectedDateFilter;

  @override
  SortOption get sortOption => state.sortOption;

  @override
  bool get isLoading => state.isLoading;

  @override
  String? get error => state.error;

  @override
  bool get isActive => mounted && !_isDisposed;

  @override
  Stream<ListsStateSnapshot> get stateStream => _stateStreamController.stream;

  @override
  void updateLists(List<CustomList> lists) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(lists: lists);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Lists updated: ${lists.length} lists',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update lists',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void updateFilteredLists(List<CustomList> filteredLists) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(filteredLists: filteredLists);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Filtered lists updated: ${filteredLists.length} lists',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update filtered lists',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void updateSearchQuery(String query) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(searchQuery: query);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Search query updated: "$query"',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update search query',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void updateTypeFilter(ListType? type) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(selectedType: type);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Type filter updated: $type',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update type filter',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void updateShowCompleted(bool show) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(showCompleted: show);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Show completed updated: $show',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update show completed',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void updateShowInProgress(bool show) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(showInProgress: show);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Show in progress updated: $show',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update show in progress',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void updateDateFilter(String? filter) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(selectedDateFilter: filter);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Date filter updated: $filter',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update date filter',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void updateSortOption(SortOption option) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(sortOption: option);
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Sort option updated: $option',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update sort option',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void setLoading(bool isLoading) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(
        isLoading: isLoading,
        error: isLoading ? null : state.error, // Clear error when starting loading
      );
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Loading state updated: $isLoading',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update loading state',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  @override
  void setError(String? error) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(
        error: error,
        isLoading: false, // Stop loading when error occurs
      );
      _updateStateInternal(newState);

      if (error != null) {
        LoggerService.instance.error(
          'Error state set: $error',
          context: 'ListsStateManager',
        );
      } else {
        LoggerService.instance.debug(
          'Error state cleared',
          context: 'ListsStateManager',
        );
      }
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update error state',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  /// Convenience method to update both lists and filtered lists
  void updateListsAndFiltered(
    List<CustomList> lists,
    List<CustomList> filteredLists,
  ) {
    if (!isActive) return;

    try {
      final newState = state.copyWith(
        lists: lists,
        filteredLists: filteredLists,
      );
      _updateStateInternal(newState);

      LoggerService.instance.debug(
        'Lists and filtered lists updated: ${lists.length}/${filteredLists.length}',
        context: 'ListsStateManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update lists and filtered lists',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  /// Internal method to update state and broadcast to stream
  void _updateStateInternal(ListsStateSnapshot newState) {
    if (!isActive) return;

    try {
      state = newState;

      // Broadcast state change to stream
      if (!_stateStreamController.isClosed) {
        _stateStreamController.add(newState);
      }
    } catch (e) {
      LoggerService.instance.error(
        'Failed to update internal state',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }

  /// Safely disposes resources
  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      // Close stream controller
      if (!_stateStreamController.isClosed) {
        _stateStreamController.close();
      }

      LoggerService.instance.debug(
        'ListsStateManager disposed',
        context: 'ListsStateManager',
      );

      // Call parent dispose
      super.dispose();
    } catch (e) {
      LoggerService.instance.error(
        'Error during ListsStateManager disposal',
        context: 'ListsStateManager',
        error: e,
      );
    }
  }
}