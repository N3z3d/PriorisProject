/// SOLID-compliant loading management service implementation
/// Responsibility: Managing loading states and execution context only

import 'dart:async';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Loading operation context
class LoadingOperation {
  final String id;
  final String description;
  final DateTime startTime;
  final Completer<void> completer;

  LoadingOperation({
    required this.id,
    required this.description,
  }) : startTime = DateTime.now(),
       completer = Completer<void>();

  Duration get duration => DateTime.now().difference(startTime);
  bool get isCompleted => completer.isCompleted;
}

/// Concrete implementation of IListsLoadingManager following SRP
/// Manages loading states and provides safe execution context
class ListsLoadingManager implements IListsLoadingManager {
  bool _isLoading = false;
  bool _isDisposed = false;
  final Map<String, LoadingOperation> _activeOperations = {};

  static const Duration _operationTimeout = Duration(seconds: 30);
  static const int _maxConcurrentOperations = 5;

  final StreamController<bool> _loadingStateController =
      StreamController<bool>.broadcast();

  ListsLoadingManager() {
    LoggerService.instance.debug(
      'ListsLoadingManager initialized',
      context: 'ListsLoadingManager',
    );
  }

  @override
  bool get isLoading => _isLoading;

  @override
  bool get canExecute => !_isDisposed && _activeOperations.length < _maxConcurrentOperations;

  /// Stream of loading state changes
  Stream<bool> get loadingStateStream => _loadingStateController.stream;

  /// Gets count of active operations
  int get activeOperationsCount => _activeOperations.length;

  /// Gets list of active operation descriptions
  List<String> get activeOperationDescriptions =>
      _activeOperations.values.map((op) => op.description).toList();

  @override
  Future<T> executeWithLoading<T>(Future<T> Function() operation) async {
    if (!canExecute) {
      throw StateError('Cannot execute operation: manager disposed or too many concurrent operations');
    }

    final operationId = DateTime.now().microsecondsSinceEpoch.toString();
    final loadingOperation = LoadingOperation(
      id: operationId,
      description: 'Lists operation $operationId',
    );

    try {
      _startOperation(loadingOperation);

      LoggerService.instance.debug(
        'Starting operation: ${loadingOperation.description}',
        context: 'ListsLoadingManager',
      );

      final result = await operation().timeout(_operationTimeout);

      LoggerService.instance.debug(
        'Operation completed: ${loadingOperation.description} (${loadingOperation.duration.inMilliseconds}ms)',
        context: 'ListsLoadingManager',
      );

      return result;
    } catch (e) {
      LoggerService.instance.error(
        'Operation failed: ${loadingOperation.description} (${loadingOperation.duration.inMilliseconds}ms)',
        context: 'ListsLoadingManager',
        error: e,
      );
      rethrow;
    } finally {
      _completeOperation(operationId);
    }
  }

  @override
  void setLoading(bool isLoading) {
    if (_isDisposed) return;

    if (_isLoading != isLoading) {
      _isLoading = isLoading;

      LoggerService.instance.debug(
        'Loading state changed: $isLoading',
        context: 'ListsLoadingManager',
      );

      // Broadcast loading state change
      if (!_loadingStateController.isClosed) {
        _loadingStateController.add(isLoading);
      }
    }
  }

  /// Executes multiple operations with loading management
  Future<List<T>> executeMultipleWithLoading<T>(
    List<Future<T> Function()> operations,
  ) async {
    if (!canExecute) {
      throw StateError('Cannot execute operations: manager disposed or too many concurrent operations');
    }

    if (operations.length > _maxConcurrentOperations) {
      throw ArgumentError('Too many operations: ${operations.length} > $_maxConcurrentOperations');
    }

    final results = <T>[];
    final failures = <dynamic>[];

    try {
      setLoading(true);

      LoggerService.instance.debug(
        'Starting ${operations.length} concurrent operations',
        context: 'ListsLoadingManager',
      );

      for (int i = 0; i < operations.length; i++) {
        try {
          final result = await executeWithLoading(operations[i]);
          results.add(result);
        } catch (e) {
          failures.add(e);
          LoggerService.instance.error(
            'Operation $i failed in batch execution',
            context: 'ListsLoadingManager',
            error: e,
          );
        }
      }

      if (failures.isNotEmpty) {
        throw AggregateException(
          'Some operations failed: ${failures.length}/${operations.length}',
          failures,
        );
      }

      LoggerService.instance.debug(
        'All ${operations.length} operations completed successfully',
        context: 'ListsLoadingManager',
      );

      return results;
    } finally {
      setLoading(false);
    }
  }

  /// Executes operation with custom timeout
  Future<T> executeWithTimeout<T>(
    Future<T> Function() operation,
    Duration timeout,
  ) async {
    if (!canExecute) {
      throw StateError('Cannot execute operation: manager disposed');
    }

    final operationId = DateTime.now().microsecondsSinceEpoch.toString();
    final loadingOperation = LoadingOperation(
      id: operationId,
      description: 'Timed operation $operationId',
    );

    try {
      _startOperation(loadingOperation);

      LoggerService.instance.debug(
        'Starting timed operation: ${loadingOperation.description} (timeout: ${timeout.inSeconds}s)',
        context: 'ListsLoadingManager',
      );

      final result = await operation().timeout(timeout);

      LoggerService.instance.debug(
        'Timed operation completed: ${loadingOperation.description} (${loadingOperation.duration.inMilliseconds}ms)',
        context: 'ListsLoadingManager',
      );

      return result;
    } catch (e) {
      LoggerService.instance.error(
        'Timed operation failed: ${loadingOperation.description} (${loadingOperation.duration.inMilliseconds}ms)',
        context: 'ListsLoadingManager',
        error: e,
      );
      rethrow;
    } finally {
      _completeOperation(operationId);
    }
  }

  /// Checks if specific operation type is already running
  bool isOperationTypeRunning(String operationType) {
    return _activeOperations.values
        .any((op) => op.description.contains(operationType));
  }

  /// Cancels all active operations
  Future<void> cancelAllOperations() async {
    if (_activeOperations.isEmpty) return;

    LoggerService.instance.warning(
      'Cancelling ${_activeOperations.length} active operations',
      context: 'ListsLoadingManager',
    );

    final operationsToCancel = List.from(_activeOperations.keys);

    for (final operationId in operationsToCancel) {
      _completeOperation(operationId);
    }

    setLoading(false);
  }

  /// Gets operation statistics
  Map<String, dynamic> getOperationStatistics() {
    final now = DateTime.now();
    final operationDurations = _activeOperations.values
        .map((op) => now.difference(op.startTime).inMilliseconds)
        .toList();

    return {
      'activeOperations': _activeOperations.length,
      'isLoading': _isLoading,
      'canExecute': canExecute,
      'maxConcurrentOperations': _maxConcurrentOperations,
      'averageDuration': operationDurations.isEmpty
          ? 0
          : operationDurations.reduce((a, b) => a + b) / operationDurations.length,
      'longestRunningDuration': operationDurations.isEmpty
          ? 0
          : operationDurations.reduce((a, b) => a > b ? a : b),
    };
  }

  /// Starts tracking an operation
  void _startOperation(LoadingOperation operation) {
    _activeOperations[operation.id] = operation;

    // Set loading state if this is the first operation
    if (_activeOperations.length == 1) {
      setLoading(true);
    }
  }

  /// Completes and removes an operation
  void _completeOperation(String operationId) {
    final operation = _activeOperations.remove(operationId);

    if (operation != null && !operation.isCompleted) {
      operation.completer.complete();
    }

    // Clear loading state if no more operations
    if (_activeOperations.isEmpty) {
      setLoading(false);
    }
  }

  /// Disposes the loading manager
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    LoggerService.instance.debug(
      'Disposing ListsLoadingManager',
      context: 'ListsLoadingManager',
    );

    // Cancel all active operations
    cancelAllOperations();

    // Close stream controller
    if (!_loadingStateController.isClosed) {
      _loadingStateController.close();
    }

    LoggerService.instance.debug(
      'ListsLoadingManager disposed',
      context: 'ListsLoadingManager',
    );
  }
}

/// Exception for aggregating multiple operation failures
class AggregateException implements Exception {
  final String message;
  final List<dynamic> innerExceptions;

  AggregateException(this.message, this.innerExceptions);

  @override
  String toString() {
    return 'AggregateException: $message\nInner exceptions: ${innerExceptions.length}';
  }
}