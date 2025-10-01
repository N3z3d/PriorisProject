/// SOLID-compliant transaction management service implementation
/// Responsibility: Handling transactions, rollbacks, and data integrity only

import 'package:uuid/uuid.dart';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Transaction operation record for rollback
class TransactionOperation {
  final String id;
  final String type;
  final dynamic entity;
  final DateTime timestamp;
  final Future<void> Function() rollbackFunction;

  TransactionOperation({
    required this.id,
    required this.type,
    required this.entity,
    required this.rollbackFunction,
  }) : timestamp = DateTime.now();
}

/// Concrete implementation of IListsTransactionManager following SRP
/// Manages transactions, rollbacks, and data integrity operations
class ListsTransactionManager implements IListsTransactionManager {
  final List<TransactionOperation> _operationHistory = [];
  final Map<String, List<TransactionOperation>> _activeTransactions = {};
  final IListsPersistenceService _persistenceService;

  static const int _maxHistorySize = 100;
  static const Duration _operationTimeout = Duration(seconds: 30);

  ListsTransactionManager({
    required IListsPersistenceService persistenceService,
  }) : _persistenceService = persistenceService {
    LoggerService.instance.debug(
      'ListsTransactionManager initialized',
      context: 'ListsTransactionManager',
    );
  }

  @override
  Future<T> executeTransaction<T>(Future<T> Function() operation) async {
    final transactionId = const Uuid().v4();
    final operations = <TransactionOperation>[];

    try {
      LoggerService.instance.debug(
        'Starting transaction: $transactionId',
        context: 'ListsTransactionManager',
      );

      _activeTransactions[transactionId] = operations;

      final result = await operation().timeout(_operationTimeout);

      // Transaction completed successfully
      _activeTransactions.remove(transactionId);
      _addOperationsToHistory(operations);

      LoggerService.instance.debug(
        'Transaction completed successfully: $transactionId',
        context: 'ListsTransactionManager',
      );

      return result;
    } catch (e) {
      LoggerService.instance.error(
        'Transaction failed, rolling back: $transactionId',
        context: 'ListsTransactionManager',
        error: e,
      );

      // Rollback all operations in reverse order
      await _rollbackOperations(operations);
      _activeTransactions.remove(transactionId);

      rethrow;
    }
  }

  @override
  Future<T> executeWithRollback<T>(
    Future<T> Function() operation,
    Future<void> Function() rollback,
  ) async {
    final operationId = const Uuid().v4();

    try {
      LoggerService.instance.debug(
        'Executing operation with rollback: $operationId',
        context: 'ListsTransactionManager',
      );

      final result = await operation().timeout(_operationTimeout);

      LoggerService.instance.debug(
        'Operation completed successfully: $operationId',
        context: 'ListsTransactionManager',
      );

      return result;
    } catch (e) {
      LoggerService.instance.error(
        'Operation failed, executing rollback: $operationId',
        context: 'ListsTransactionManager',
        error: e,
      );

      try {
        await rollback().timeout(_operationTimeout);
        LoggerService.instance.info(
          'Rollback completed successfully: $operationId',
          context: 'ListsTransactionManager',
        );
      } catch (rollbackError) {
        LoggerService.instance.error(
          'Rollback failed: $operationId',
          context: 'ListsTransactionManager',
          error: rollbackError,
        );
      }

      rethrow;
    }
  }

  @override
  Future<bool> verifyOperation(String operationId, String entityId) async {
    try {
      LoggerService.instance.debug(
        'Verifying operation: $operationId for entity: $entityId',
        context: 'ListsTransactionManager',
      );

      final isVerified = await _persistenceService.verifyPersistence(entityId);

      if (isVerified) {
        LoggerService.instance.debug(
          'Operation verified successfully: $operationId',
          context: 'ListsTransactionManager',
        );
      } else {
        LoggerService.instance.warning(
          'Operation verification failed: $operationId',
          context: 'ListsTransactionManager',
        );
      }

      return isVerified;
    } catch (e) {
      LoggerService.instance.error(
        'Error verifying operation: $operationId',
        context: 'ListsTransactionManager',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<void> rollback(List<dynamic> entitiesToRollback) async {
    try {
      LoggerService.instance.info(
        'Rolling back ${entitiesToRollback.length} entities',
        context: 'ListsTransactionManager',
      );

      for (final entity in entitiesToRollback) {
        await _rollbackEntity(entity);
      }

      LoggerService.instance.info(
        'Rollback completed for ${entitiesToRollback.length} entities',
        context: 'ListsTransactionManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Error during rollback operation',
        context: 'ListsTransactionManager',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> executeBulkTransaction(
    List<Future<void> Function()> operations,
  ) async {
    final transactionId = const Uuid().v4();
    final completedOperations = <int>[];

    try {
      LoggerService.instance.debug(
        'Starting bulk transaction: $transactionId with ${operations.length} operations',
        context: 'ListsTransactionManager',
      );

      for (int i = 0; i < operations.length; i++) {
        await operations[i]().timeout(_operationTimeout);
        completedOperations.add(i);
      }

      LoggerService.instance.debug(
        'Bulk transaction completed successfully: $transactionId',
        context: 'ListsTransactionManager',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Bulk transaction failed at operation ${completedOperations.length + 1}/${operations.length}',
        context: 'ListsTransactionManager',
        error: e,
      );

      // Rollback completed operations in reverse order
      await _rollbackBulkOperations(completedOperations);

      rethrow;
    }
  }

  /// Records a transaction operation for potential rollback
  void recordOperation({
    required String type,
    required dynamic entity,
    required Future<void> Function() rollbackFunction,
    String? transactionId,
  }) {
    final operation = TransactionOperation(
      id: const Uuid().v4(),
      type: type,
      entity: entity,
      rollbackFunction: rollbackFunction,
    );

    if (transactionId != null && _activeTransactions.containsKey(transactionId)) {
      _activeTransactions[transactionId]!.add(operation);
    } else {
      _addOperationsToHistory([operation]);
    }

    LoggerService.instance.debug(
      'Operation recorded: ${operation.type} for ${operation.id}',
      context: 'ListsTransactionManager',
    );
  }

  /// Rolls back a single entity
  Future<void> _rollbackEntity(dynamic entity) async {
    try {
      if (entity is CustomList) {
        await _persistenceService.deleteList(entity.id);
      } else if (entity is ListItem) {
        await _persistenceService.deleteItem(entity.id);
      } else {
        LoggerService.instance.warning(
          'Unknown entity type for rollback: ${entity.runtimeType}',
          context: 'ListsTransactionManager',
        );
      }
    } catch (e) {
      LoggerService.instance.error(
        'Failed to rollback entity: ${entity.runtimeType}',
        context: 'ListsTransactionManager',
        error: e,
      );
    }
  }

  /// Rolls back a list of operations
  Future<void> _rollbackOperations(List<TransactionOperation> operations) async {
    // Execute rollbacks in reverse order
    for (int i = operations.length - 1; i >= 0; i--) {
      final operation = operations[i];
      try {
        await operation.rollbackFunction().timeout(_operationTimeout);
        LoggerService.instance.debug(
          'Rollback completed for operation: ${operation.type}',
          context: 'ListsTransactionManager',
        );
      } catch (e) {
        LoggerService.instance.error(
          'Rollback failed for operation: ${operation.type}',
          context: 'ListsTransactionManager',
          error: e,
        );
      }
    }
  }

  /// Rolls back bulk operations
  Future<void> _rollbackBulkOperations(List<int> completedOperations) async {
    LoggerService.instance.info(
      'Rolling back ${completedOperations.length} completed bulk operations',
      context: 'ListsTransactionManager',
    );

    // Find and rollback completed operations
    // Note: This is a simplified implementation
    // In a real scenario, you'd need to track what each operation did
    for (final index in completedOperations.reversed) {
      LoggerService.instance.debug(
        'Attempting rollback for bulk operation $index',
        context: 'ListsTransactionManager',
      );
      // Rollback logic would depend on what the operation did
      // This is a placeholder for the actual rollback implementation
    }
  }

  /// Adds operations to history and manages history size
  void _addOperationsToHistory(List<TransactionOperation> operations) {
    _operationHistory.addAll(operations);

    // Maintain history size limit
    while (_operationHistory.length > _maxHistorySize) {
      _operationHistory.removeAt(0);
    }
  }

  /// Gets operation history for debugging/monitoring
  List<TransactionOperation> getOperationHistory({int? limit}) {
    if (limit != null && limit < _operationHistory.length) {
      return _operationHistory.sublist(_operationHistory.length - limit);
    }
    return List.unmodifiable(_operationHistory);
  }

  /// Clears operation history
  void clearHistory() {
    _operationHistory.clear();
    LoggerService.instance.debug(
      'Operation history cleared',
      context: 'ListsTransactionManager',
    );
  }

  /// Gets active transactions count
  int get activeTransactionsCount => _activeTransactions.length;

  /// Checks if a transaction is active
  bool isTransactionActive(String transactionId) {
    return _activeTransactions.containsKey(transactionId);
  }
}