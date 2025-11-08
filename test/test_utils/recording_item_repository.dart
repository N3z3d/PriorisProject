import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Operation types for recording
enum ItemOperation {
  getById,
  getByListId,
  add,
  update,
  delete,
}

/// Recorded operation entry
class ItemOperationRecord {
  final ItemOperation operation;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;
  final bool succeeded;

  ItemOperationRecord({
    required this.operation,
    required this.timestamp,
    required this.parameters,
    required this.succeeded,
  });

  @override
  String toString() => '$operation(${parameters.keys.join(', ')}) - ${succeeded ? 'OK' : 'FAIL'}';
}

/// Deterministic fake item repository that records all operations
class RecordingItemRepository implements ListItemRepository {
  final Map<String, ListItem> _storage = {};
  final List<ItemOperationRecord> _operationsLog = [];
  final Map<ItemOperation, bool> _failureConfig = {};

  int _writeCount = 0;

  /// Get all recorded operations
  List<ItemOperationRecord> get operationsLog => List.unmodifiable(_operationsLog);

  /// Get write operation count
  int get writeCount => _writeCount;

  /// Clear all data and logs
  void clear() {
    _storage.clear();
    _operationsLog.clear();
    _writeCount = 0;
  }

  /// Clear only operation logs (keep storage data)
  void clearLogs() {
    _operationsLog.clear();
    _writeCount = 0;
  }

  /// Configure operation to fail
  void setOperationFailure(ItemOperation operation, bool shouldFail) {
    _failureConfig[operation] = shouldFail;
  }

  bool _shouldFail(ItemOperation operation) {
    return _failureConfig[operation] ?? false;
  }

  void _record(ItemOperation operation, Map<String, dynamic> parameters, bool succeeded) {
    _operationsLog.add(ItemOperationRecord(
      operation: operation,
      timestamp: DateTime.now(),
      parameters: parameters,
      succeeded: succeeded,
    ));
  }

  @override
  Future<ListItem?> getById(String id) async {
    final succeeded = !_shouldFail(ItemOperation.getById);
    _record(ItemOperation.getById, {'id': id}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated getById failure');
    }

    return _storage[id];
  }

  @override
  Future<List<ListItem>> getByListId(String listId) async {
    final succeeded = !_shouldFail(ItemOperation.getByListId);
    _record(ItemOperation.getByListId, {'listId': listId}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated getByListId failure');
    }

    return _storage.values.where((item) => item.listId == listId).toList();
  }

  @override
  Future<List<ListItem>> getAll() async {
    final succeeded = !_shouldFail(ItemOperation.getByListId);
    _record(ItemOperation.getByListId, {}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated getAll failure');
    }

    return _storage.values.toList();
  }

  @override
  Future<ListItem> add(ListItem item) async {
    final succeeded = !_shouldFail(ItemOperation.add);
    _record(ItemOperation.add, {'id': item.id, 'listId': item.listId}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated add failure');
    }

    if (_storage.containsKey(item.id)) {
      throw Exception('Item with id ${item.id} already exists');
    }

    _storage[item.id] = item;
    _writeCount++;
    return item;
  }

  @override
  Future<ListItem> update(ListItem item) async {
    final succeeded = !_shouldFail(ItemOperation.update);
    _record(ItemOperation.update, {'id': item.id, 'listId': item.listId}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated update failure');
    }

    if (!_storage.containsKey(item.id)) {
      throw Exception('Item with id ${item.id} not found');
    }

    _storage[item.id] = item;
    _writeCount++;
    return item;
  }

  @override
  Future<void> delete(String id) async {
    final succeeded = !_shouldFail(ItemOperation.delete);
    _record(ItemOperation.delete, {'id': id}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated delete failure');
    }

    _storage.remove(id);
    _writeCount++;
  }
}
