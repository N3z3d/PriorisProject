import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/mixins/state_management_mixin.dart';

// Test classes that use the mixins
class TestNotifier extends ChangeNotifier
    with
        LoadingStateMixin,
        ErrorHandlingMixin,
        DataStateMixin<String>,
        CompleteStateMixin<String> {}

class TestModel {
  final String id;
  final String name;

  TestModel(this.id, this.name);

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TestModel &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'TestModel(id: $id, name: $name)';
}

class TestRepositoryStateNotifier extends ChangeNotifier
    with CompleteStateMixin<List<TestModel>>, RepositoryStateMixin<TestModel> {

  @override
  String _extractId(TestModel item) => item.id;
}

void main() {
  group('LoadingStateMixin', () {
    late TestNotifier notifier;

    setUp(() {
      notifier = TestNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    group('Basic Loading State', () {
      test('should start with no loading state', () {
        expect(notifier.isLoading, isFalse);
        expect(notifier.loadingMessage, isNull);
      });

      test('should set global loading state', () {
        notifier.setLoading(true, 'Loading data...');

        expect(notifier.isLoading, isTrue);
        expect(notifier.loadingMessage, equals('Loading data...'));
      });

      test('should clear loading state', () {
        notifier.setLoading(true, 'Loading...');
        notifier.setLoading(false);

        expect(notifier.isLoading, isFalse);
        expect(notifier.loadingMessage, isNull);
      });

      test('should clear loading message when loading is false', () {
        notifier.setLoading(true, 'Loading...');
        notifier.setLoading(false, 'This should be ignored');

        expect(notifier.isLoading, isFalse);
        expect(notifier.loadingMessage, isNull);
      });
    });

    group('Operation-Specific Loading State', () {
      test('should track operation-specific loading states', () {
        notifier.setOperationLoading('create', true);
        notifier.setOperationLoading('update', true);

        expect(notifier.isOperationLoading('create'), isTrue);
        expect(notifier.isOperationLoading('update'), isTrue);
        expect(notifier.isOperationLoading('delete'), isFalse);
      });

      test('should clear specific operation loading', () {
        notifier.setOperationLoading('create', true);
        notifier.setOperationLoading('create', false);

        expect(notifier.isOperationLoading('create'), isFalse);
      });

      test('should clear all loading states', () {
        notifier.setLoading(true, 'Global loading');
        notifier.setOperationLoading('create', true);
        notifier.setOperationLoading('update', true);

        notifier.clearLoadingStates();

        expect(notifier.isLoading, isFalse);
        expect(notifier.loadingMessage, isNull);
        expect(notifier.isOperationLoading('create'), isFalse);
        expect(notifier.isOperationLoading('update'), isFalse);
      });
    });

    group('WithLoading Helper', () {
      test('should execute operation with global loading', () async {
        bool operationExecuted = false;

        await notifier.withLoading(() async {
          expect(notifier.isLoading, isTrue);
          operationExecuted = true;
        });

        expect(operationExecuted, isTrue);
        expect(notifier.isLoading, isFalse);
      });

      test('should execute operation with loading message', () async {
        await notifier.withLoading(
          () async {
            expect(notifier.loadingMessage, equals('Processing...'));
          },
          message: 'Processing...',
        );

        expect(notifier.loadingMessage, isNull);
      });

      test('should execute operation with operation-specific loading', () async {
        await notifier.withLoading(
          () async {
            expect(notifier.isOperationLoading('test-op'), isTrue);
          },
          operationKey: 'test-op',
        );

        expect(notifier.isOperationLoading('test-op'), isFalse);
      });

      test('should clear loading state even if operation throws', () async {
        try {
          await notifier.withLoading(() async {
            throw Exception('Test error');
          });
        } catch (_) {
          // Expected
        }

        expect(notifier.isLoading, isFalse);
      });

      test('should return operation result', () async {
        final result = await notifier.withLoading(() async {
          return 'Success';
        });

        expect(result, equals('Success'));
      });
    });
  });

  group('ErrorHandlingMixin', () {
    late TestNotifier notifier;

    setUp(() {
      notifier = TestNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    group('Basic Error Handling', () {
      test('should start with no errors', () {
        expect(notifier.lastError, isNull);
        expect(notifier.hasErrors, isFalse);
      });

      test('should set global error', () {
        notifier.setError('Global error');

        expect(notifier.lastError, equals('Global error'));
        expect(notifier.hasErrors, isTrue);
      });

      test('should clear global error', () {
        notifier.setError('Error');
        notifier.clearError();

        expect(notifier.lastError, isNull);
        expect(notifier.hasErrors, isFalse);
      });
    });

    group('Operation-Specific Error Handling', () {
      test('should set operation-specific errors', () {
        notifier.setOperationError('create', 'Create failed');
        notifier.setOperationError('update', 'Update failed');

        expect(notifier.getOperationError('create'), equals('Create failed'));
        expect(notifier.getOperationError('update'), equals('Update failed'));
        expect(notifier.getOperationError('delete'), isNull);
        expect(notifier.hasErrors, isTrue);
      });

      test('should clear specific operation error', () {
        notifier.setOperationError('create', 'Error');
        notifier.clearOperationError('create');

        expect(notifier.getOperationError('create'), isNull);
      });

      test('should clear operation error by setting null', () {
        notifier.setOperationError('create', 'Error');
        notifier.setOperationError('create', null);

        expect(notifier.getOperationError('create'), isNull);
      });

      test('should clear all errors', () {
        notifier.setError('Global error');
        notifier.setOperationError('create', 'Create error');
        notifier.setOperationError('update', 'Update error');

        notifier.clearAllErrors();

        expect(notifier.lastError, isNull);
        expect(notifier.getOperationError('create'), isNull);
        expect(notifier.getOperationError('update'), isNull);
        expect(notifier.hasErrors, isFalse);
      });
    });

    group('WithErrorHandling Helper', () {
      test('should execute operation and handle no errors', () async {
        final result = await notifier.withErrorHandling(() async {
          return 'Success';
        });

        expect(result, equals('Success'));
        expect(notifier.lastError, isNull);
      });

      test('should catch and handle exceptions', () async {
        final result = await notifier.withErrorHandling(() async {
          throw Exception('Test error');
        });

        expect(result, isNull);
        expect(notifier.lastError, isNotNull);
        expect(notifier.lastError, contains('Test error'));
      });

      test('should handle operation-specific errors', () async {
        await notifier.withErrorHandling(
          () async {
            throw Exception('Operation failed');
          },
          operationKey: 'test-op',
        );

        expect(notifier.getOperationError('test-op'), isNotNull);
        expect(notifier.lastError, isNull);
      });

      test('should use custom error mapper', () async {
        await notifier.withErrorHandling(
          () async {
            throw Exception('Original error');
          },
          errorMapper: (error) => 'Mapped: ${error.toString()}',
        );

        expect(notifier.lastError, startsWith('Mapped:'));
      });

      test('should clear previous errors by default', () async {
        notifier.setError('Previous error');

        await notifier.withErrorHandling(() async {
          return 'Success';
        });

        expect(notifier.lastError, isNull);
      });

      test('should optionally preserve previous errors', () async {
        notifier.setError('Previous error');

        await notifier.withErrorHandling(
          () async {
            return 'Success';
          },
          clearPreviousErrors: false,
        );

        expect(notifier.lastError, equals('Previous error'));
      });
    });
  });

  group('DataStateMixin', () {
    late TestNotifier notifier;

    setUp(() {
      notifier = TestNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    group('Basic Data Management', () {
      test('should start with no data', () {
        expect(notifier.data, isNull);
        expect(notifier.isEmpty, isFalse);
        expect(notifier.isInitialized, isFalse);
        expect(notifier.hasData, isFalse);
      });

      test('should set data', () {
        notifier.setData('Test data');

        expect(notifier.data, equals('Test data'));
        expect(notifier.isEmpty, isFalse);
        expect(notifier.isInitialized, isTrue);
        expect(notifier.hasData, isTrue);
      });

      test('should handle empty string data', () {
        notifier.setData('');

        expect(notifier.data, equals(''));
        expect(notifier.isEmpty, isTrue);
        expect(notifier.isInitialized, isTrue);
        expect(notifier.hasData, isFalse);
      });

      test('should handle null data', () {
        notifier.setData(null);

        expect(notifier.data, isNull);
        expect(notifier.isEmpty, isTrue);
        expect(notifier.isInitialized, isTrue);
        expect(notifier.hasData, isFalse);
      });

      test('should clear data', () {
        notifier.setData('Data');
        notifier.clearData();

        expect(notifier.data, isNull);
        expect(notifier.isEmpty, isFalse);
        expect(notifier.isInitialized, isFalse);
        expect(notifier.hasData, isFalse);
      });
    });

    group('Data Updates', () {
      test('should update data using function', () {
        notifier.setData('Initial');

        notifier.updateData((current) => '$current updated');

        expect(notifier.data, equals('Initial updated'));
        expect(notifier.isInitialized, isTrue);
      });

      test('should handle update with null current data', () {
        notifier.updateData((current) => current ?? 'Default');

        expect(notifier.data, equals('Default'));
        expect(notifier.isInitialized, isTrue);
      });
    });
  });

  group('CompleteStateMixin Integration', () {
    late TestNotifier notifier;

    setUp(() {
      notifier = TestNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should execute complete operation successfully', () async {
      String? capturedResult;

      await notifier.executeOperation(
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'Operation result';
        },
        onSuccess: (result) {
          capturedResult = result;
          notifier.setData(result);
        },
        loadingMessage: 'Processing...',
      );

      expect(capturedResult, equals('Operation result'));
      expect(notifier.data, equals('Operation result'));
      expect(notifier.isLoading, isFalse);
      expect(notifier.lastError, isNull);
    });

    test('should handle operation errors gracefully', () async {
      String? capturedResult;

      await notifier.executeOperation(
        () async {
          throw Exception('Operation failed');
        },
        onSuccess: (result) {
          capturedResult = result;
        },
      );

      expect(capturedResult, isNull);
      expect(notifier.lastError, isNotNull);
      expect(notifier.isLoading, isFalse);
    });

    test('should reset all state', () {
      notifier.setLoading(true);
      notifier.setError('Error');
      notifier.setData('Data');

      notifier.resetState();

      expect(notifier.isLoading, isFalse);
      expect(notifier.lastError, isNull);
      expect(notifier.data, isNull);
    });
  });

  group('RepositoryStateMixin', () {
    late TestRepositoryStateNotifier notifier;

    setUp(() {
      notifier = TestRepositoryStateNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should load all entities', () async {
      final testData = [
        TestModel('1', 'Item 1'),
        TestModel('2', 'Item 2'),
      ];

      await notifier.loadAll(() async => testData);

      expect(notifier.data, equals(testData));
      expect(notifier.hasData, isTrue);
      expect(notifier.isLoading, isFalse);
    });

    test('should create entity and add to list', () async {
      final initialData = [TestModel('1', 'Item 1')];
      notifier.setData(initialData);

      final newItem = TestModel('2', 'Item 2');

      await notifier.create(
        () async => newItem,
        refreshAfterCreate: false,
      );

      expect(notifier.data?.length, equals(2));
      expect(notifier.data?.last, equals(newItem));
    });

    test('should update entity in list', () async {
      final initialData = [
        TestModel('1', 'Item 1'),
        TestModel('2', 'Item 2'),
      ];
      notifier.setData(initialData);

      final updatedItem = TestModel('1', 'Updated Item 1');

      await notifier.update(
        '1',
        () async => updatedItem,
        refreshAfterUpdate: false,
      );

      expect(notifier.data?.first, equals(updatedItem));
      expect(notifier.data?.length, equals(2));
    });

    test('should delete entity from list', () async {
      final initialData = [
        TestModel('1', 'Item 1'),
        TestModel('2', 'Item 2'),
      ];
      notifier.setData(initialData);

      await notifier.delete(
        '1',
        () async {},
        refreshAfterDelete: false,
      );

      expect(notifier.data?.length, equals(1));
      expect(notifier.data?.first.id, equals('2'));
    });

    test('should refresh data after operations when requested', () async {
      bool refreshCalled = false;

      notifier.setData([TestModel('1', 'Item 1')]);

      await notifier.create(
        () async => TestModel('2', 'Item 2'),
        refreshAfterCreate: true,
        refreshLoader: () async {
          refreshCalled = true;
          return [
            TestModel('1', 'Item 1'),
            TestModel('2', 'Item 2'),
            TestModel('3', 'Item 3'),
          ];
        },
      );

      expect(refreshCalled, isTrue);
      expect(notifier.data?.length, equals(3));
    });
  });

  group('Notification System', () {
    late TestNotifier notifier;
    late List<String> notifications;

    setUp(() {
      notifier = TestNotifier();
      notifications = [];
      notifier.addListener(() {
        notifications.add('notified');
      });
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should notify listeners on loading state changes', () {
      notifier.setLoading(true);
      expect(notifications.isNotEmpty, isTrue);

      notifications.clear();
      notifier.setLoading(false);
      expect(notifications.isNotEmpty, isTrue);
    });

    test('should notify listeners on error state changes', () {
      notifier.setError('Error');
      expect(notifications.isNotEmpty, isTrue);

      notifications.clear();
      notifier.clearError();
      expect(notifications.isNotEmpty, isTrue);
    });

    test('should notify listeners on data changes', () {
      notifier.setData('Data');
      expect(notifications.isNotEmpty, isTrue);

      notifications.clear();
      notifier.clearData();
      expect(notifications.isNotEmpty, isTrue);
    });
  });
}
