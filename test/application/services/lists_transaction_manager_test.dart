/// TDD Tests for ListsTransactionManager
/// Follows Red → Green → Refactor methodology
/// Tests written to validate P0 critical service

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/application/services/lists_transaction_manager.dart';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'lists_transaction_manager_test.mocks.dart';

@GenerateMocks([IListsPersistenceService])
void main() {
  group('ListsTransactionManager Tests - P0 Critical Service', () {
    late ListsTransactionManager transactionManager;
    late MockIListsPersistenceService mockPersistenceService;

    setUp(() {
      mockPersistenceService = MockIListsPersistenceService();
      transactionManager = ListsTransactionManager(
        persistenceService: mockPersistenceService,
      );
    });

    group('Simple Transaction Tests', () {
      test('should complete simple transaction successfully', () async {
        // GIVEN
        var operationExecuted = false;

        // WHEN
        final result = await transactionManager.executeTransaction<String>(() async {
          operationExecuted = true;
          return 'success';
        });

        // THEN
        expect(result, equals('success'));
        expect(operationExecuted, isTrue);
      });

      test('should rollback transaction on failure', () async {
        // GIVEN
        var rollbackExecuted = false;

        // WHEN & THEN
        await expectLater(
          transactionManager.executeWithRollback<String>(
            () async => throw Exception('Operation failed'),
            () async => rollbackExecuted = true,
          ),
          throwsA(isA<Exception>()),
        );

        // Rollback should have been executed
        expect(rollbackExecuted, isTrue);
      });
    });

    group('Bulk Transaction Tests', () {
      test('should complete bulk transaction with all operations succeeding', () async {
        // GIVEN
        final executedOperations = <int>[];
        final operations = List.generate(5, (index) => () async {
          executedOperations.add(index);
        });

        // WHEN
        await transactionManager.executeBulkTransaction(operations);

        // THEN
        expect(executedOperations, equals([0, 1, 2, 3, 4]));
      });

      test('should rollback completed operations when bulk transaction fails at operation 3/5', () async {
        // GIVEN
        final executedOperations = <int>[];
        final operations = <Future<void> Function()>[
          () async => executedOperations.add(0), // Success
          () async => executedOperations.add(1), // Success
          () async => throw Exception('Failed at operation 2'), // Failure at index 2
          () async => executedOperations.add(3), // Should not execute
          () async => executedOperations.add(4), // Should not execute
        ];

        // WHEN & THEN
        await expectLater(
          transactionManager.executeBulkTransaction(operations),
          throwsA(isA<Exception>()),
        );

        // Only first 2 operations should have executed
        expect(executedOperations, equals([0, 1]));
      });
    });

    group('Timeout Handling Tests', () {
      test('should throw timeout exception when operation exceeds 30 seconds', () async {
        // GIVEN - Operation that takes longer than timeout
        final slowOperation = () async {
          await Future.delayed(Duration(seconds: 31));
          return 'should not complete';
        };

        // WHEN & THEN
        await expectLater(
          transactionManager.executeTransaction(slowOperation),
          throwsA(isA<Exception>()),
        );
      }, timeout: Timeout(Duration(seconds: 35)));

      test('should execute rollback even after timeout', () async {
        // GIVEN
        var rollbackExecuted = false;
        final slowOperation = () async {
          await Future.delayed(Duration(seconds: 31));
          return 'should not complete';
        };
        final rollback = () async => rollbackExecuted = true;

        // WHEN & THEN
        await expectLater(
          transactionManager.executeWithRollback(slowOperation, rollback),
          throwsA(isA<Exception>()),
        );

        // Rollback should still execute
        expect(rollbackExecuted, isTrue);
      }, timeout: Timeout(Duration(seconds: 35)));
    });

    group('Verification Tests', () {
      test('should verify operation successfully when entity exists', () async {
        // GIVEN
        const operationId = 'op-123';
        const entityId = 'entity-456';

        when(mockPersistenceService.verifyPersistence(entityId))
            .thenAnswer((_) async => true);

        // WHEN
        final isVerified = await transactionManager.verifyOperation(
          operationId,
          entityId,
        );

        // THEN
        expect(isVerified, isTrue);
        verify(mockPersistenceService.verifyPersistence(entityId)).called(1);
      });

      test('should return false when verification fails', () async {
        // GIVEN
        const operationId = 'op-123';
        const entityId = 'entity-456';

        when(mockPersistenceService.verifyPersistence(entityId))
            .thenAnswer((_) async => false);

        // WHEN
        final isVerified = await transactionManager.verifyOperation(
          operationId,
          entityId,
        );

        // THEN
        expect(isVerified, isFalse);
        verify(mockPersistenceService.verifyPersistence(entityId)).called(1);
      });
    });

    group('History Management Tests', () {
      test('should limit operation history to 100 operations max', () async {
        // GIVEN - Record 150 operations
        for (int i = 0; i < 150; i++) {
          transactionManager.recordOperation(
            type: 'test-$i',
            entity: 'entity-$i',
            rollbackFunction: () async {},
          );
        }

        // WHEN
        final history = transactionManager.getOperationHistory();

        // THEN - Only last 100 should be kept
        expect(history.length, lessThanOrEqualTo(100));
      });

      test('should return limited history when limit parameter provided', () async {
        // GIVEN - Record 20 operations
        for (int i = 0; i < 20; i++) {
          transactionManager.recordOperation(
            type: 'test-$i',
            entity: 'entity-$i',
            rollbackFunction: () async {},
          );
        }

        // WHEN
        final history = transactionManager.getOperationHistory(limit: 5);

        // THEN
        expect(history.length, equals(5));
      });

      test('should clear history when clearHistory called', () async {
        // GIVEN - Record some operations
        for (int i = 0; i < 10; i++) {
          transactionManager.recordOperation(
            type: 'test-$i',
            entity: 'entity-$i',
            rollbackFunction: () async {},
          );
        }

        expect(transactionManager.getOperationHistory().length, equals(10));

        // WHEN
        transactionManager.clearHistory();

        // THEN
        expect(transactionManager.getOperationHistory(), isEmpty);
      });
    });

    group('Concurrent Transactions Tests', () {
      test('should track multiple active transactions with separate contexts', () async {
        // GIVEN
        final transaction1Started = Completer<void>();
        final transaction2Started = Completer<void>();
        final continueTransaction1 = Completer<void>();
        final continueTransaction2 = Completer<void>();

        // WHEN - Start two transactions concurrently
        final future1 = transactionManager.executeTransaction<String>(() async {
          transaction1Started.complete();
          await continueTransaction1.future;
          return 'transaction-1';
        });

        final future2 = transactionManager.executeTransaction<String>(() async {
          transaction2Started.complete();
          await continueTransaction2.future;
          return 'transaction-2';
        });

        // Wait for both to start
        await transaction1Started.future;
        await transaction2Started.future;

        // THEN - Both transactions should be active
        expect(transactionManager.activeTransactionsCount, equals(2));

        // Complete transactions
        continueTransaction1.complete();
        continueTransaction2.complete();

        final results = await Future.wait([future1, future2]);
        expect(results, equals(['transaction-1', 'transaction-2']));
        expect(transactionManager.activeTransactionsCount, equals(0));
      });
    });

    group('Entity Rollback Tests', () {
      test('should delete CustomList when rolling back', () async {
        // GIVEN
        final now = DateTime.now();
        final testList = CustomList(
          id: 'list-123',
          name: 'Test List',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        when(mockPersistenceService.deleteList('list-123'))
            .thenAnswer((_) async {});

        // WHEN
        await transactionManager.rollback([testList]);

        // THEN
        verify(mockPersistenceService.deleteList('list-123')).called(1);
      });

      test('should delete ListItem when rolling back', () async {
        // GIVEN
        final testItem = ListItem(
          id: 'item-123',
          title: 'Test Item',
          listId: 'list-456',
          createdAt: DateTime.now(),
        );

        when(mockPersistenceService.deleteItem('item-123'))
            .thenAnswer((_) async {});

        // WHEN
        await transactionManager.rollback([testItem]);

        // THEN
        verify(mockPersistenceService.deleteItem('item-123')).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle empty bulk transaction gracefully', () async {
        // GIVEN
        final operations = <Future<void> Function()>[];

        // WHEN & THEN - Should not throw
        await expectLater(
          transactionManager.executeBulkTransaction(operations),
          completes,
        );
      });

      test('should handle rollback failure gracefully', () async {
        // GIVEN
        final failingRollback = () async => throw Exception('Rollback failed');

        // WHEN & THEN - Should throw original exception, not rollback exception
        await expectLater(
          transactionManager.executeWithRollback<String>(
            () async => throw Exception('Operation failed'),
            failingRollback,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Helper class for async coordination
class Completer<T> {
  final _completer = Future<T>.value;
  var _completed = false;
  T? _value;

  Future<T> get future async {
    if (_completed) return _value as T;
    return await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 10));
      return !_completed;
    }).then((_) => _value as T);
  }

  void complete([T? value]) {
    _value = value;
    _completed = true;
  }
}