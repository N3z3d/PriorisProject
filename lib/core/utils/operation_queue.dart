import 'dart:async';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Priority levels for queued operations
enum OperationPriority {
  low(0),
  medium(1), 
  high(2),
  critical(3);
  
  const OperationPriority(this.value);
  final int value;
}

/// Represents a queued operation with retry logic
class QueuedOperation<T> {
  final String id;
  final String name;
  final Future<T> Function() operation;
  final OperationPriority priority;
  final int maxRetries;
  final Duration retryDelay;
  final Completer<T> completer = Completer<T>();
  
  int attemptCount = 0;
  DateTime? scheduledAt;
  DateTime? startedAt;
  DateTime? completedAt;
  
  QueuedOperation({
    required this.id,
    required this.name,
    required this.operation,
    this.priority = OperationPriority.medium,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  }) {
    scheduledAt = DateTime.now();
  }
  
  bool get isCompleted => completer.isCompleted;
  bool get hasRetriesLeft => attemptCount < maxRetries;
  
  Future<T> get future => completer.future;
}

/// Reliable operation queue with retry logic and error handling
/// Replaces unreliable Future.microtask() calls
class OperationQueue {
  static OperationQueue? _instance;
  static OperationQueue get instance => _instance ??= OperationQueue._();
  
  OperationQueue._();
  
  final List<QueuedOperation> _queue = [];
  final List<QueuedOperation> _processing = [];
  final List<QueuedOperation> _completed = [];
  final List<QueuedOperation> _failed = [];
  
  bool _isProcessing = false;
  int _maxConcurrentOperations = 3;
  
  /// Add operation to queue and return Future for result
  Future<T> enqueue<T>({
    required String name,
    required Future<T> Function() operation,
    String? id,
    OperationPriority priority = OperationPriority.medium,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) {
    final queuedOp = QueuedOperation<T>(
      id: id ?? '${name}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      operation: operation,
      priority: priority,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
    
    _queue.add(queuedOp);
    _queue.sort((a, b) => b.priority.value.compareTo(a.priority.value)); // High priority first
    
    LoggerService.instance.debug('Operation enqueued: ${queuedOp.name} (id: ${queuedOp.id}, priority: ${priority.name}, queue: ${_queue.length})', 
      context: 'OperationQueue');
    
    _startProcessingIfNeeded();
    
    return queuedOp.future;
  }
  
  /// Start processing queue if not already running
  void _startProcessingIfNeeded() {
    if (!_isProcessing && _queue.isNotEmpty) {
      _isProcessing = true;
      // Small delay to allow batching of operations before processing starts
      Future.delayed(const Duration(milliseconds: 10), _processQueue);
    }
  }
  
  /// Process operations from queue
  Future<void> _processQueue() async {
    while (_queue.isNotEmpty || _processing.isNotEmpty) {
      // Start new operations if we have capacity
      while (_processing.length < _maxConcurrentOperations && _queue.isNotEmpty) {
        final operation = _queue.removeAt(0);
        _processing.add(operation);
        _executeOperation(operation);
      }
      
      // Wait a bit before checking again
      await Future.delayed(Duration(milliseconds: 100));
      
      // Clean up completed operations
      _processing.removeWhere((op) => op.isCompleted);
    }
    
    _isProcessing = false;
    LoggerService.instance.debug('Queue processing completed', context: 'OperationQueue');
  }
  
  /// Execute a single operation with retry logic
  Future<void> _executeOperation<T>(QueuedOperation<T> operation) async {
    operation.startedAt = DateTime.now();
    operation.attemptCount++;
    
    LoggerService.instance.debug('Executing operation: ${operation.name} (attempt ${operation.attemptCount}, id: ${operation.id})',
      context: 'OperationQueue');
    
    try {
      final result = await operation.operation();
      operation.completedAt = DateTime.now();
      operation.completer.complete(result);
      _completed.add(operation);
      
      LoggerService.instance.info('Operation completed successfully: ${operation.name} (id: ${operation.id}, duration: ${operation.completedAt!.difference(operation.startedAt!).inMilliseconds}ms, attempts: ${operation.attemptCount})',
        context: 'OperationQueue');
      
    } catch (error, stackTrace) {
      if (operation.hasRetriesLeft) {
        // Schedule retry
        LoggerService.instance.warning('Operation failed, retrying: ${operation.name}',
          context: 'OperationQueue',
          data: {
            'id': operation.id,
            'attempt': operation.attemptCount,
            'maxRetries': operation.maxRetries,
            'error': error.toString(),
          });
        
        await Future.delayed(operation.retryDelay);
        _executeOperation(operation); // Retry
        
      } else {
        // No more retries, fail the operation
        operation.completedAt = DateTime.now();
        operation.completer.completeError(error, stackTrace);
        _failed.add(operation);
        
        LoggerService.instance.error('Operation failed after all retries: ${operation.name}',
          context: 'OperationQueue',
          error: error);
      }
    }
  }
  
  /// Get queue statistics
  Map<String, dynamic> getStatistics() => {
    'queueLength': _queue.length,
    'processing': _processing.length,
    'completed': _completed.length,
    'failed': _failed.length,
    'isProcessing': _isProcessing,
  };
  
  /// Clear queue state. When [cancelPendingOperations] is true (default),
  /// all queued/processing operations are cancelled to guarantee a clean slate.
  void cleanup({bool cancelPendingOperations = true}) {
    if (cancelPendingOperations) {
      for (final op in _queue) {
        if (!op.completer.isCompleted) {
          op.completer.completeError(
            Exception('Operation cancelled during cleanup'),
          );
        }
      }
      _queue.clear();

      for (final op in _processing) {
        if (!op.completer.isCompleted) {
          op.completer.completeError(
            Exception('Operation cancelled during cleanup'),
          );
        }
      }
      _processing.clear();
      _isProcessing = false;
    } else {
      _queue.removeWhere((op) => op.isCompleted);
      _processing.removeWhere((op) => op.isCompleted);
    }

    _completed.clear();
    _failed.clear();

    LoggerService.instance.debug(
      'Queue cleaned up (cancelPending=$cancelPendingOperations)',
      context: 'OperationQueue',
    );
  }
  
  /// Cancel all pending operations
  void cancelAll() {
    for (final op in _queue) {
      op.completer.completeError(Exception('Operation cancelled'));
    }
    _queue.clear();
    
    LoggerService.instance.warning('All pending operations cancelled', context: 'OperationQueue');
  }
}
