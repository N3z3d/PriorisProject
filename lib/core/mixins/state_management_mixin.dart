import 'package:flutter/foundation.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

typedef _AsyncCallback<T> = Future<T> Function();

// Internal controllers shared across mixins
class _LoadingStateController {
  _LoadingStateController(this._notify);

  final VoidCallback _notify;
  bool _isLoading = false;
  String? _message;
  final Set<String> _operationKeys = <String>{};

  bool get isLoading => _isLoading;
  String? get message => _message;

  bool isOperationLoading(String key) => _operationKeys.contains(key);

  void setLoading(bool value, String? message) {
    if (value) {
      final changed = !_isLoading || _message != message;
      _isLoading = true;
      _message = message;
      if (changed) {
        _notify();
      }
    } else {
      if (!_isLoading && _message == null) {
        return;
      }
      _isLoading = false;
      _message = null;
      _notify();
    }
  }

  void setOperationLoading(String key, bool value) {
    final changed = value ? _operationKeys.add(key) : _operationKeys.remove(key);
    if (changed) {
      _notify();
    }
  }

  void clear() {
    if (!_isLoading && _message == null && _operationKeys.isEmpty) return;
    _isLoading = false;
    _message = null;
    if (_operationKeys.isNotEmpty) {
      _operationKeys.clear();
    }
    _notify();
  }
}

class _ErrorStateController {
  _ErrorStateController(this._notify);

  final VoidCallback _notify;
  String? _lastError;
  final Map<String, String> _operationErrors = {};

  String? get lastError => _lastError;
  bool get hasErrors => _lastError != null || _operationErrors.isNotEmpty;

  String? getOperationError(String key) => _operationErrors[key];

  void setError(String? message) {
    if (_lastError == message) return;
    _lastError = message;
    _notify();
  }

  void setOperationError(String key, String? message) {
    if (message == null) {
      if (_operationErrors.remove(key) != null) {
        _notify();
      }
    } else {
      final previous = _operationErrors[key];
      if (previous == message) return;
      _operationErrors[key] = message;
      _notify();
    }
  }

  void clearAll() {
    if (!hasErrors) return;
    _lastError = null;
    _operationErrors.clear();
    _notify();
  }
}

class _DataStateController<T> {
  _DataStateController(this._notify);

  final VoidCallback _notify;
  T? _data;
  bool _isInitialized = false;
  bool _isEmpty = false;

  T? get data => _data;
  bool get isInitialized => _isInitialized;
  bool get isEmpty => _isEmpty;
  bool get hasData => _isInitialized && !_isEmpty;

  void setData(T? value) {
    final newEmpty = _computeEmpty(value);
    final changed = !_isInitialized || _data != value || _isEmpty != newEmpty;
    _data = value;
    _isInitialized = true;
    _isEmpty = newEmpty;
    if (changed) {
      _notify();
    }
  }

  void updateData(T? Function(T? current) updater) {
    setData(updater(_data));
  }

  void clear() {
    if (_data == null && !_isInitialized && !_isEmpty) return;
    _data = null;
    _isInitialized = false;
    _isEmpty = false;
    _notify();
  }

  static bool _computeEmpty(Object? value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}

mixin LoadingStateMixin on ChangeNotifier {
  late final _LoadingStateController _loadingState =
      _LoadingStateController(notifyListeners);

  bool get isLoading => _loadingState.isLoading;
  String? get loadingMessage => _loadingState.message;

  bool isOperationLoading(String key) =>
      _loadingState.isOperationLoading(key);

  void setLoading(bool value, [String? message]) =>
      _loadingState.setLoading(value, message);

  void setOperationLoading(String key, bool value) =>
      _loadingState.setOperationLoading(key, value);

  void clearLoadingStates() => _loadingState.clear();

  Future<T> withLoading<T>(
    _AsyncCallback<T> operation, {
    String? message,
    String? operationKey,
  }) async {
    setLoading(true, message);
    if (operationKey != null) {
      setOperationLoading(operationKey, true);
    }
    try {
      return await operation();
    } finally {
      if (operationKey != null) {
        setOperationLoading(operationKey, false);
      }
      setLoading(false);
    }
  }
}

mixin ErrorHandlingMixin on ChangeNotifier {
  late final _ErrorStateController _errorState =
      _ErrorStateController(notifyListeners);

  String? get lastError => _errorState.lastError;
  bool get hasErrors => _errorState.hasErrors;

  String? getOperationError(String key) =>
      _errorState.getOperationError(key);

  void setError(String? message) => _errorState.setError(message);

  void clearError() => _errorState.setError(null);

  void setOperationError(String key, String? message) =>
      _errorState.setOperationError(key, message);

  void clearOperationError(String key) =>
      _errorState.setOperationError(key, null);

  void clearAllErrors() => _errorState.clearAll();

  Future<T?> withErrorHandling<T>(
    _AsyncCallback<T> operation, {
    String? operationKey,
    String Function(Object error)? errorMapper,
    bool clearPreviousErrors = true,
  }) async {
    if (clearPreviousErrors) {
      clearAllErrors();
    }
    try {
      final result = await operation();
      if (operationKey != null) {
        clearOperationError(operationKey);
      }
      return result;
    } catch (error, stack) {
      final mapped =
          errorMapper != null ? errorMapper(error) : error.toString();
      if (operationKey != null) {
        setOperationError(operationKey, mapped);
      } else {
        setError(mapped);
      }
      LoggerService.instance.error(
        'State operation failed',
        context: 'ErrorHandlingMixin',
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }
}

mixin DataStateMixin<T> on ChangeNotifier {
  late final _DataStateController<T> _dataState =
      _DataStateController<T>(notifyListeners);

  T? get data => _dataState.data;
  bool get isInitialized => _dataState.isInitialized;
  bool get isEmpty => _dataState.isEmpty;
  bool get hasData => _dataState.hasData;

  void setData(T? value) => _dataState.setData(value);

  void updateData(T? Function(T? current) updater) =>
      _dataState.updateData(updater);

  void clearData() => _dataState.clear();
}

mixin CompleteStateMixin<T> on ChangeNotifier
    implements LoadingStateMixin, ErrorHandlingMixin, DataStateMixin<T> {
  late final _LoadingStateController _completeLoading =
      _LoadingStateController(notifyListeners);
  late final _ErrorStateController _completeErrors =
      _ErrorStateController(notifyListeners);
  late final _DataStateController<T> _completeData =
      _DataStateController<T>(notifyListeners);

  // Loading
  bool get isLoading => _completeLoading.isLoading;
  String? get loadingMessage => _completeLoading.message;
  bool isOperationLoading(String key) =>
      _completeLoading.isOperationLoading(key);
  void setLoading(bool value, [String? message]) =>
      _completeLoading.setLoading(value, message);
  void setOperationLoading(String key, bool value) =>
      _completeLoading.setOperationLoading(key, value);
  void clearLoadingStates() => _completeLoading.clear();

  // Errors
  String? get lastError => _completeErrors.lastError;
  bool get hasErrors => _completeErrors.hasErrors;
  String? getOperationError(String key) =>
      _completeErrors.getOperationError(key);
  void setError(String? message) => _completeErrors.setError(message);
  void clearError() => _completeErrors.setError(null);
  void setOperationError(String key, String? message) =>
      _completeErrors.setOperationError(key, message);
  void clearOperationError(String key) =>
      _completeErrors.setOperationError(key, null);
  void clearAllErrors() => _completeErrors.clearAll();

  // Data
  T? get data => _completeData.data;
  bool get isInitialized => _completeData.isInitialized;
  bool get isEmpty => _completeData.isEmpty;
  bool get hasData => _completeData.hasData;
  void setData(T? value) => _completeData.setData(value);
  void updateData(T? Function(T? current) updater) =>
      _completeData.updateData(updater);
  void clearData() => _completeData.clear();

  Future<R> withLoading<R>(
    _AsyncCallback<R> operation, {
    String? message,
    String? operationKey,
  }) async {
    setLoading(true, message);
    if (operationKey != null) {
      setOperationLoading(operationKey, true);
    }
    try {
      return await operation();
    } finally {
      if (operationKey != null) {
        setOperationLoading(operationKey, false);
      }
      setLoading(false);
    }
  }

  Future<R?> withErrorHandling<R>(
    _AsyncCallback<R> operation, {
    String? operationKey,
    String Function(Object error)? errorMapper,
    bool clearPreviousErrors = true,
  }) async {
    if (clearPreviousErrors) {
      clearAllErrors();
    }
    try {
      final result = await operation();
      if (operationKey != null) {
        clearOperationError(operationKey);
      }
      return result;
    } catch (error, stack) {
      final mapped =
          errorMapper != null ? errorMapper(error) : error.toString();
      if (operationKey != null) {
        setOperationError(operationKey, mapped);
      } else {
        setError(mapped);
      }
      LoggerService.instance.error(
        'State operation failed',
        context: 'CompleteStateMixin',
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }

  Future<R?> executeOperation<R>(
    _AsyncCallback<R> operation, {
    void Function(R result)? onSuccess,
    String? loadingMessage,
    String? operationKey,
    String? errorOperationKey,
    String Function(Object error)? errorMapper,
    bool clearPreviousErrors = true,
  }) =>
      _executeStateOperation<R>(
        this,
        operation,
        onSuccess: onSuccess,
        loadingMessage: loadingMessage,
        operationKey: operationKey,
        errorOperationKey: errorOperationKey,
        errorMapper: errorMapper,
        clearPreviousErrors: clearPreviousErrors,
      );

  void resetState() => _resetState(this);
}

mixin RepositoryStateMixin<T>
    on ChangeNotifier, CompleteStateMixin<List<T>> {
  String _extractId(T item);

  Future<void> loadAll(
    Future<List<T>> Function() loader, {
    String? loadingMessage,
  }) async {
    await executeOperation<List<T>>(
      loader,
      onSuccess: setData,
      loadingMessage: loadingMessage,
      operationKey: 'loadAll',
      errorOperationKey: 'loadAll',
    );
  }

  Future<T?> create(
    Future<T> Function() creator, {
    bool refreshAfterCreate = true,
    Future<List<T>> Function()? refreshLoader,
  }) async {
    final result = await executeOperation<T>(
      creator,
      operationKey: 'create',
      errorOperationKey: 'create',
    );

    if (result == null) {
      return null;
    }

    if (refreshAfterCreate) {
      await _refreshData(
        refreshLoader,
        operationKey: 'create',
      );
    } else {
      final updated = List<T>.from(data ?? <T>[]);
      updated.add(result);
      setData(updated);
    }
    return result;
  }

  Future<T?> update(
    String id,
    Future<T> Function() updater, {
    bool refreshAfterUpdate = true,
    Future<List<T>> Function()? refreshLoader,
  }) async {
    final result = await executeOperation<T>(
      updater,
      operationKey: 'update',
      errorOperationKey: 'update',
    );

    if (result == null) {
      return null;
    }

    if (refreshAfterUpdate) {
      await _refreshData(
        refreshLoader,
        operationKey: 'update',
      );
    } else {
      final updated = List<T>.from(data ?? <T>[]);
      final index = updated.indexWhere((item) => _extractId(item) == id);
      if (index != -1) {
        updated[index] = result;
        setData(updated);
      }
    }
    return result;
  }

  Future<bool> delete(
    String id,
    Future<void> Function() deleter, {
    bool refreshAfterDelete = true,
    Future<List<T>> Function()? refreshLoader,
  }) async {
    final success = await executeOperation<bool>(
      () async {
        await deleter();
        return true;
      },
      operationKey: 'delete',
      errorOperationKey: 'delete',
    );

    if (success != true) {
      return false;
    }

    if (refreshAfterDelete) {
      await _refreshData(
        refreshLoader,
        operationKey: 'delete',
      );
    } else {
      final updated = List<T>.from(data ?? <T>[]);
      updated.removeWhere((item) => _extractId(item) == id);
      setData(updated);
    }
    return true;
  }

  Future<void> _refreshData(
    Future<List<T>> Function()? refreshLoader, {
    required String operationKey,
  }) async {
    final loader = refreshLoader;
    if (loader == null) {
      return;
    }

    final refreshed = await executeOperation<List<T>>(
      loader,
      operationKey: operationKey,
      errorOperationKey: operationKey,
      clearPreviousErrors: false,
    );

    if (refreshed != null) {
      setData(refreshed);
    }
  }
}

LoadingStateMixin _requireLoadingMixin(ChangeNotifier target) {
  if (target is LoadingStateMixin) {
    return target as LoadingStateMixin;
  }
  throw StateError(
      "State operations require the host to mix in LoadingStateMixin.");
}

ErrorHandlingMixin _requireErrorMixin(ChangeNotifier target) {
  if (target is ErrorHandlingMixin) {
    return target as ErrorHandlingMixin;
  }
  throw StateError(
      "State operations require the host to mix in ErrorHandlingMixin.");
}

DataStateMixin<dynamic> _requireDataMixin(ChangeNotifier target) {
  if (target is DataStateMixin) {
    return target as DataStateMixin<dynamic>;
  }
  throw StateError(
      "State operations require the host to mix in DataStateMixin.");
}

Future<R?> _executeStateOperation<R>(
  ChangeNotifier target,
  Future<R> Function() operation, {
  void Function(R result)? onSuccess,
  String? loadingMessage,
  String? operationKey,
  String? errorOperationKey,
  String Function(Object error)? errorMapper,
  bool clearPreviousErrors = true,
}) {
  final loading = _requireLoadingMixin(target);
  final errors = _requireErrorMixin(target);

  return loading.withLoading<R?>(
    () async {
      final result = await errors.withErrorHandling<R>(
        operation,
        operationKey: errorOperationKey ?? operationKey,
        errorMapper: errorMapper,
        clearPreviousErrors: clearPreviousErrors,
      );
      if (result != null) {
        onSuccess?.call(result);
      }
      return result;
    },
    message: loadingMessage,
    operationKey: operationKey,
  );
}

void _resetState(ChangeNotifier target) {
  final loading = _requireLoadingMixin(target);
  final errors = _requireErrorMixin(target);
  final data = _requireDataMixin(target);
  loading.clearLoadingStates();
  errors.clearAllErrors();
  data.clearData();
}

extension CompleteStateOperations<T> on DataStateMixin<T> {
  ChangeNotifier get _host {
    if (this is! ChangeNotifier) {
      throw StateError(
          "State mixins require ChangeNotifier as the host class.");
    }
    return this as ChangeNotifier;
  }

  Future<R?> executeOperation<R>(
    Future<R> Function() operation, {
    void Function(R result)? onSuccess,
    String? loadingMessage,
    String? operationKey,
    String? errorOperationKey,
    String Function(Object error)? errorMapper,
    bool clearPreviousErrors = true,
  }) =>
      _executeStateOperation<R>(
        _host,
        operation,
        onSuccess: onSuccess,
        loadingMessage: loadingMessage,
        operationKey: operationKey,
        errorOperationKey: errorOperationKey,
        errorMapper: errorMapper,
        clearPreviousErrors: clearPreviousErrors,
      );

  void resetState() => _resetState(_host);
}

