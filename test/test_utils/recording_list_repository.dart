import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Operation types for recording
enum RepositoryOperation {
  getAllLists,
  getListById,
  saveList,
  updateList,
  deleteList,
  searchByName,
  searchByDescription,
  getByType,
}

/// Recorded operation entry
class OperationRecord {
  final RepositoryOperation operation;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;
  final bool succeeded;

  OperationRecord({
    required this.operation,
    required this.timestamp,
    required this.parameters,
    required this.succeeded,
  });

  @override
  String toString() => '$operation(${parameters.keys.join(', ')}) - ${succeeded ? 'OK' : 'FAIL'}';
}

/// Deterministic fake repository that records all operations
/// Enables verification of persistence behavior and rollback scenarios
class RecordingListRepository implements CustomListRepository {
  final Map<String, CustomList> _storage = {};
  final List<OperationRecord> _operationsLog = [];

  // Failure configuration
  final Map<RepositoryOperation, bool> _failureConfig = {};

  // Counters
  int _writeCount = 0;

  /// Get all recorded operations
  List<OperationRecord> get operationsLog => List.unmodifiable(_operationsLog);

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
  void setOperationFailure(RepositoryOperation operation, bool shouldFail) {
    _failureConfig[operation] = shouldFail;
  }

  /// Check if operation should fail
  bool _shouldFail(RepositoryOperation operation) {
    return _failureConfig[operation] ?? false;
  }

  /// Record operation
  void _record(RepositoryOperation operation, Map<String, dynamic> parameters, bool succeeded) {
    _operationsLog.add(OperationRecord(
      operation: operation,
      timestamp: DateTime.now(),
      parameters: parameters,
      succeeded: succeeded,
    ));
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    final succeeded = !_shouldFail(RepositoryOperation.getAllLists);
    _record(RepositoryOperation.getAllLists, {}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated getAllLists failure');
    }

    return _storage.values.toList();
  }

  @override
  Future<CustomList?> getListById(String id) async {
    final succeeded = !_shouldFail(RepositoryOperation.getListById);
    _record(RepositoryOperation.getListById, {'id': id}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated getListById failure');
    }

    return _storage[id];
  }

  @override
  Future<void> saveList(CustomList list) async {
    final succeeded = !_shouldFail(RepositoryOperation.saveList);
    _record(RepositoryOperation.saveList, {'id': list.id, 'name': list.name}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated saveList failure');
    }

    if (_storage.containsKey(list.id)) {
      throw Exception('List with id ${list.id} already exists');
    }

    _storage[list.id] = list;
    _writeCount++;
  }

  @override
  Future<void> updateList(CustomList list) async {
    final succeeded = !_shouldFail(RepositoryOperation.updateList);
    _record(RepositoryOperation.updateList, {'id': list.id, 'name': list.name}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated updateList failure');
    }

    if (!_storage.containsKey(list.id)) {
      throw Exception('List with id ${list.id} not found');
    }

    _storage[list.id] = list;
    _writeCount++;
  }

  @override
  Future<void> deleteList(String id) async {
    final succeeded = !_shouldFail(RepositoryOperation.deleteList);
    _record(RepositoryOperation.deleteList, {'id': id}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated deleteList failure');
    }

    _storage.remove(id);
    _writeCount++;
  }

  @override
  Future<List<CustomList>> searchByName(String query) async {
    final succeeded = !_shouldFail(RepositoryOperation.searchByName);
    _record(RepositoryOperation.searchByName, {'query': query}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated searchByName failure');
    }

    return _storage.values
        .where((list) => list.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<CustomList>> searchByDescription(String query) async {
    final succeeded = !_shouldFail(RepositoryOperation.searchByDescription);
    _record(RepositoryOperation.searchByDescription, {'query': query}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated searchByDescription failure');
    }

    return _storage.values
        .where((list) => (list.description ?? '').toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<CustomList>> getByType(ListType type) async {
    final succeeded = !_shouldFail(RepositoryOperation.getByType);
    _record(RepositoryOperation.getByType, {'type': type.toString()}, succeeded);

    if (!succeeded) {
      throw Exception('Simulated getByType failure');
    }

    return _storage.values.where((list) => list.type == type).toList();
  }

  // BasicCrudRepositoryInterface methods
  @override
  Future<List<CustomList>> getAll() => getAllLists();

  @override
  Future<CustomList?> getById(String id) => getListById(id);

  @override
  Future<void> save(CustomList entity) => saveList(entity);

  @override
  Future<void> update(CustomList entity) => updateList(entity);

  @override
  Future<void> delete(String id) => deleteList(id);

  // SearchableRepositoryInterface methods
  @override
  Future<List<CustomList>> searchListsByName(String query) => searchByName(query);

  @override
  Future<List<CustomList>> searchListsByDescription(String query) => searchByDescription(query);

  // FilterableRepositoryInterface methods
  @override
  Future<List<CustomList>> getListsByType(ListType type) => getByType(type);

  // CleanableRepositoryInterface methods (no-op for test fake)
  @override
  Future<void> cleanOldData(DateTime beforeDate) async {}

  // CustomListCleanRepositoryInterface methods
  @override
  Future<void> clearAll() async {
    await clearAllLists();
  }

  @override
  Future<void> clearAllLists() async {
    final allIds = _storage.keys.toList();
    for (final id in allIds) {
      await deleteList(id);
    }
  }

  // CustomListRepository methods
  @override
  Future<Map<String, dynamic>> getStats() async {
    return {
      'totalLists': _storage.length,
      'totalWriteCount': _writeCount,
      'operationsCount': _operationsLog.length,
    };
  }
}
