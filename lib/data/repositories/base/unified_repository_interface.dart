/// DUPLICATION ELIMINATION - Unified Repository Interface
///
/// Consolidates all repository interfaces into a single, comprehensive base.
/// Eliminates duplication across multiple repository interface files.

/// Base Repository Interface
/// Generic CRUD operations for all entity types
abstract class IBaseRepository<T, ID> {
  Future<T> save(T entity);
  Future<T?> findById(ID id);
  Future<List<T>> findAll();
  Future<void> deleteById(ID id);
  Future<bool> existsById(ID id);
  Future<int> count();
  Future<void> clear();
}

/// Batch Operations Interface
/// For repositories that support batch operations
abstract class IBatchRepository<T> {
  Future<List<T>> saveAll(List<T> entities);
  Future<void> deleteAll(List<T> entities);
  Future<List<T>> findAllByIds(List<String> ids);
}

/// Search Repository Interface
/// For repositories that support advanced search
abstract class ISearchRepository<T> {
  Future<List<T>> search(String query);
  Future<List<T>> findByField(String fieldName, dynamic value);
  Future<List<T>> findByMultipleFields(Map<String, dynamic> criteria);
}

/// Paginated Repository Interface
/// For repositories that support pagination
abstract class IPaginatedRepository<T> {
  Future<Page<T>> findPaginated({
    int page = 0,
    int size = 10,
    String? sortBy,
    bool ascending = true,
  });
}

/// Page wrapper for paginated results
class Page<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  const Page({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Full Repository Interface
/// Combines all repository capabilities
abstract class IFullRepository<T, ID>
    implements IBaseRepository<T, ID>,
               IBatchRepository<T>,
               ISearchRepository<T>,
               IPaginatedRepository<T> {

  /// Repository metadata
  String get repositoryName;
  String get entityType;

  /// Health check
  Future<bool> isHealthy();

  /// Initialize repository
  Future<void> initialize();

  /// Dispose resources
  Future<void> dispose();
}

/// Audit Repository Interface
/// For entities that track creation/modification
abstract class IAuditRepository<T> {
  Future<List<T>> findCreatedAfter(DateTime date);
  Future<List<T>> findModifiedAfter(DateTime date);
  Future<List<T>> findCreatedBetween(DateTime start, DateTime end);
}

/// Soft Delete Repository Interface
/// For repositories that support soft deletion
abstract class ISoftDeleteRepository<T> {
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<List<T>> findDeleted();
  Future<List<T>> findNotDeleted();
  Future<void> permanentDelete(String id);
}

/// Event Sourcing Repository Interface
/// For repositories that support event sourcing
abstract class IEventRepository<T> {
  Future<void> saveEvent(String aggregateId, Map<String, dynamic> event);
  Future<List<Map<String, dynamic>>> getEvents(String aggregateId);
  Future<void> saveSnapshot(String aggregateId, T snapshot);
  Future<T?> getSnapshot(String aggregateId);
}

/// Repository Factory Interface
/// For creating different types of repositories
abstract class IRepositoryFactory {
  IBaseRepository<T, ID> createRepository<T, ID>();
  IFullRepository<T, ID> createFullRepository<T, ID>();
}

/// Repository Configuration
class RepositoryConfig {
  final String connectionString;
  final int maxConnections;
  final Duration timeout;
  final bool enableCaching;
  final bool enableAuditing;
  final bool enableSoftDelete;

  const RepositoryConfig({
    required this.connectionString,
    this.maxConnections = 10,
    this.timeout = const Duration(seconds: 30),
    this.enableCaching = true,
    this.enableAuditing = false,
    this.enableSoftDelete = false,
  });
}

/// Repository Exception Types
class RepositoryException implements Exception {
  final String message;
  final String? operation;
  final dynamic originalError;

  const RepositoryException(
    this.message, {
    this.operation,
    this.originalError,
  });

  @override
  String toString() => 'RepositoryException($operation): $message';
}

class EntityNotFoundException extends RepositoryException {
  EntityNotFoundException(String entityType, String id)
      : super('$entityType with id $id not found', operation: 'findById');
}

class DuplicateEntityException extends RepositoryException {
  DuplicateEntityException(String entityType, String identifier)
      : super('$entityType with identifier $identifier already exists', operation: 'save');
}

class ConcurrencyException extends RepositoryException {
  ConcurrencyException(String entityType, String id)
      : super('$entityType with id $id was modified by another process', operation: 'update');
}