/// DUPLICATION ELIMINATION - State Management Mixin
///
/// Consolidates repetitive state management patterns across controllers.
/// Eliminates boilerplate code for loading states, error handling, and data operations.

import 'package:flutter/foundation.dart';

/// Loading State Mixin
///
/// Provides standardized loading state management for controllers and services.
mixin LoadingStateMixin {
  bool _isLoading = false;
  String? _loadingMessage;
  final Map<String, bool> _operationLoadingStates = {};

  /// Current loading state
  bool get isLoading => _isLoading;

  /// Current loading message
  String? get loadingMessage => _loadingMessage;

  /// Check if specific operation is loading
  bool isOperationLoading(String operation) => _operationLoadingStates[operation] ?? false;

  /// Set global loading state
  void setLoading(bool loading, [String? message]) {
    _isLoading = loading;
    _loadingMessage = loading ? message : null;
    notifyListeners();
  }

  /// Set operation-specific loading state
  void setOperationLoading(String operation, bool loading) {
    _operationLoadingStates[operation] = loading;
    notifyListeners();
  }

  /// Execute operation with loading state
  Future<T> withLoading<T>(
    Future<T> Function() operation, {
    String? message,
    String? operationKey,
  }) async {
    try {
      if (operationKey != null) {
        setOperationLoading(operationKey, true);
      } else {
        setLoading(true, message);
      }

      return await operation();
    } finally {
      if (operationKey != null) {
        setOperationLoading(operationKey, false);
      } else {
        setLoading(false);
      }
    }
  }

  /// Clear all loading states
  void clearLoadingStates() {
    _isLoading = false;
    _loadingMessage = null;
    _operationLoadingStates.clear();
    notifyListeners();
  }

  /// Must be implemented by mixing class
  void notifyListeners();
}

/// Error Handling Mixin
///
/// Provides standardized error handling across controllers.
mixin ErrorHandlingMixin {
  String? _lastError;
  final Map<String, String> _operationErrors = {};

  /// Current error message
  String? get lastError => _lastError;

  /// Get error for specific operation
  String? getOperationError(String operation) => _operationErrors[operation];

  /// Has any errors
  bool get hasErrors => _lastError != null || _operationErrors.isNotEmpty;

  /// Set global error
  void setError(String? error) {
    _lastError = error;
    notifyListeners();
  }

  /// Set operation-specific error
  void setOperationError(String operation, String? error) {
    if (error != null) {
      _operationErrors[operation] = error;
    } else {
      _operationErrors.remove(operation);
    }
    notifyListeners();
  }

  /// Clear global error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Clear operation error
  void clearOperationError(String operation) {
    _operationErrors.remove(operation);
    notifyListeners();
  }

  /// Clear all errors
  void clearAllErrors() {
    _lastError = null;
    _operationErrors.clear();
    notifyListeners();
  }

  /// Execute operation with error handling
  Future<T?> withErrorHandling<T>(
    Future<T> Function() operation, {
    String? operationKey,
    bool clearPreviousErrors = true,
    String? Function(dynamic)? errorMapper,
  }) async {
    try {
      if (clearPreviousErrors) {
        if (operationKey != null) {
          clearOperationError(operationKey);
        } else {
          clearError();
        }
      }

      return await operation();
    } catch (error) {
      final errorMessage = errorMapper?.call(error) ?? _defaultErrorMapper(error);

      if (operationKey != null) {
        setOperationError(operationKey, errorMessage);
      } else {
        setError(errorMessage);
      }

      if (kDebugMode) {
        print('Error in ${operationKey ?? 'operation'}: $error');
      }

      return null;
    }
  }

  String _defaultErrorMapper(dynamic error) {
    if (error is Exception) {
      return error.toString();
    }
    return 'Une erreur inattendue s\'est produite';
  }

  /// Must be implemented by mixing class
  void notifyListeners();
}

/// Data State Mixin
///
/// Manages data state patterns (empty, loading, loaded, error).
mixin DataStateMixin<T> {
  T? _data;
  bool _isEmpty = false;
  bool _isInitialized = false;

  /// Current data
  T? get data => _data;

  /// Is data empty
  bool get isEmpty => _isEmpty;

  /// Is data initialized
  bool get isInitialized => _isInitialized;

  /// Has data
  bool get hasData => _data != null && !_isEmpty;

  /// Set data
  void setData(T? data) {
    _data = data;
    _isEmpty = data == null || _isDataEmpty(data);
    _isInitialized = true;
    notifyListeners();
  }

  /// Clear data
  void clearData() {
    _data = null;
    _isEmpty = false;
    _isInitialized = false;
    notifyListeners();
  }

  /// Update data without null check
  void updateData(T Function(T?) updater) {
    _data = updater(_data);
    _isEmpty = _data == null || _isDataEmpty(_data!);
    _isInitialized = true;
    notifyListeners();
  }

  /// Override to provide custom empty check
  bool _isDataEmpty(T data) {
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is String) return data.trim().isEmpty;
    return false;
  }

  /// Must be implemented by mixing class
  void notifyListeners();
}

/// Complete State Management Mixin
///
/// Combines all state management patterns.
mixin CompleteStateMixin<T> implements LoadingStateMixin, ErrorHandlingMixin, DataStateMixin<T> {
  /// Execute complete operation with loading, error handling, and data update
  Future<void> executeOperation<R>(
    Future<R> Function() operation, {
    required void Function(R) onSuccess,
    String? loadingMessage,
    String? operationKey,
    bool clearPreviousErrors = true,
    String? Function(dynamic)? errorMapper,
  }) async {
    await withLoading(
      () async {
        final result = await withErrorHandling(
          operation,
          operationKey: operationKey,
          clearPreviousErrors: clearPreviousErrors,
          errorMapper: errorMapper,
        );

        if (result != null) {
          onSuccess(result);
        }
      },
      message: loadingMessage,
      operationKey: operationKey,
    );
  }

  /// Reset all state
  void resetState() {
    clearLoadingStates();
    clearAllErrors();
    clearData();
  }
}

/// Repository State Mixin
///
/// Specialized state management for repository operations.
mixin RepositoryStateMixin<T> on CompleteStateMixin<List<T>> {
  /// Load all entities
  Future<void> loadAll(Future<List<T>> Function() loader) async {
    await executeOperation(
      loader,
      onSuccess: setData,
      loadingMessage: 'Chargement en cours...',
      operationKey: 'load_all',
    );
  }

  /// Create entity
  Future<void> create(
    Future<T> Function() creator, {
    bool refreshAfterCreate = true,
    Future<List<T>> Function()? refreshLoader,
  }) async {
    await executeOperation(
      creator,
      onSuccess: (created) {
        if (refreshAfterCreate && refreshLoader != null) {
          loadAll(refreshLoader);
        } else if (hasData) {
          setData([...data!, created]);
        }
      },
      loadingMessage: 'Création en cours...',
      operationKey: 'create',
    );
  }

  /// Update entity
  Future<void> update(
    String id,
    Future<T> Function() updater, {
    bool refreshAfterUpdate = false,
    Future<List<T>> Function()? refreshLoader,
  }) async {
    await executeOperation(
      updater,
      onSuccess: (updated) {
        if (refreshAfterUpdate && refreshLoader != null) {
          loadAll(refreshLoader);
        } else if (hasData) {
          final currentData = data!;
          final index = currentData.indexWhere((item) => _extractId(item) == id);
          if (index != -1) {
            currentData[index] = updated;
            setData([...currentData]);
          }
        }
      },
      loadingMessage: 'Mise à jour en cours...',
      operationKey: 'update',
    );
  }

  /// Delete entity
  Future<void> delete(
    String id,
    Future<void> Function() deleter, {
    bool refreshAfterDelete = false,
    Future<List<T>> Function()? refreshLoader,
  }) async {
    await executeOperation(
      deleter,
      onSuccess: (_) {
        if (refreshAfterDelete && refreshLoader != null) {
          loadAll(refreshLoader);
        } else if (hasData) {
          final filteredData = data!.where((item) => _extractId(item) != id).toList();
          setData(filteredData);
        }
      },
      loadingMessage: 'Suppression en cours...',
      operationKey: 'delete',
    );
  }

  /// Override to provide ID extraction logic
  String _extractId(T item) {
    // Default implementation - override in concrete classes
    if (item is Map && item.containsKey('id')) {
      return item['id'].toString();
    }
    return item.toString();
  }
}