library;

/// Interfaces pour le pattern Repository
/// 
/// Définit les contrats pour les différents types de repositories
/// selon les principes SOLID (Interface Segregation).

/// Interface de base pour les opérations CRUD
abstract class ICrudRepository<T, ID> {
  Future<ID> create(T entity);
  Future<T?> getById(ID id);
  Future<List<T>> getAll();
  Future<bool> update(ID id, T entity);
  Future<bool> delete(ID id);
  Future<void> deleteAll();
  Future<bool> exists(ID id);
  Future<int> count();
}

/// Interface pour les repositories avec recherche
abstract class ISearchableRepository<T> {
  Future<List<T>> search(String query);
  Future<List<T>> where(bool Function(T) predicate);
  Future<T?> firstWhere(bool Function(T) predicate, {T? Function()? orElse});
}

/// Interface pour les repositories avec filtrage
abstract class IFilterableRepository<T> {
  Future<List<T>> filter(Map<String, dynamic> filters);
  Future<List<T>> filterByType(String type);
  Future<List<T>> filterByStatus(String status);
  Future<List<T>> filterByDateRange(DateTime start, DateTime end);
}

/// Interface pour les repositories avec tri
abstract class ISortableRepository<T> {
  Future<List<T>> sortBy(String field, {bool ascending = true});
  Future<List<T>> sortByMultiple(List<SortCriteria> criteria);
}

/// Interface pour les repositories avec pagination
abstract class IPaginableRepository<T> {
  Future<PaginatedResult<T>> getPaginated({
    required int page,
    required int pageSize,
  });
  Future<int> getTotalPages(int pageSize);
}

/// Interface pour les repositories avec cache
abstract class ICacheableRepository<T, ID> {
  Future<T?> getFromCache(ID id);
  Future<void> addToCache(ID id, T entity);
  Future<void> removeFromCache(ID id);
  Future<void> clearCache();
  bool isCached(ID id);
}

/// Interface pour les repositories avec transactions
abstract class ITransactionalRepository<T> {
  Future<void> beginTransaction();
  Future<void> commitTransaction();
  Future<void> rollbackTransaction();
  Future<R> executeInTransaction<R>(Future<R> Function() operation);
}

/// Interface pour les repositories avec observation
abstract class IObservableRepository<T> {
  Stream<RepositoryEvent<T>> watch({String? key});
  Stream<List<T>> watchAll();
  void notifyChange(RepositoryEvent<T> event);
}

/// Interface pour les repositories avec validation
abstract class IValidatableRepository<T> {
  Future<bool> validate(T entity);
  Future<List<String>> getValidationErrors(T entity);
  Future<T> sanitize(T entity);
}

/// Interface pour les repositories avec audit
abstract class IAuditableRepository<T, ID> {
  Future<AuditLog<T>> getAuditLog(ID id);
  Future<List<AuditEntry<T>>> getAuditHistory(ID id);
  Future<void> logChange(ID id, T before, T after, String userId);
}

/// Interface pour les repositories avec synchronisation
abstract class ISyncableRepository<T, ID> {
  Future<void> syncWithRemote();
  Future<List<T>> getPendingSync();
  Future<void> markAsSynced(ID id);
  Future<DateTime?> getLastSyncTime();
  bool needsSync(ID id);
}

/// Interface pour les repositories avec import/export
abstract class IImportExportRepository<T> {
  Future<void> importFromJson(String json);
  Future<String> exportToJson();
  Future<void> importFromCsv(String csv);
  Future<String> exportToCsv();
  Future<void> backup();
  Future<void> restore(String backupData);
}

/// Interface complète combinant plusieurs capacités
abstract class IFullRepository<T, ID> 
    implements 
        ICrudRepository<T, ID>,
        ISearchableRepository<T>,
        IFilterableRepository<T>,
        ISortableRepository<T>,
        IPaginableRepository<T>,
        IObservableRepository<T> {}

// ========== MODÈLES DE SUPPORT ==========

/// Critère de tri
class SortCriteria {
  final String field;
  final bool ascending;

  const SortCriteria({
    required this.field,
    this.ascending = true,
  });
}

/// Résultat paginé
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResult.empty() {
    return PaginatedResult<T>(
      items: [],
      page: 0,
      pageSize: 0,
      totalItems: 0,
      totalPages: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }
}

/// Événement du repository
class RepositoryEvent<T> {
  final RepositoryEventType type;
  final T? entity;
  final String? key;
  final DateTime timestamp;

  RepositoryEvent({
    required this.type,
    this.entity,
    this.key,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Type d'événement du repository
enum RepositoryEventType {
  created,
  updated,
  deleted,
  cleared,
}

/// Entrée d'audit
class AuditEntry<T> {
  final DateTime timestamp;
  final String action;
  final T? before;
  final T? after;
  final String userId;
  final Map<String, dynamic>? metadata;

  const AuditEntry({
    required this.timestamp,
    required this.action,
    this.before,
    this.after,
    required this.userId,
    this.metadata,
  });
}

/// Journal d'audit
class AuditLog<T> {
  final List<AuditEntry<T>> entries;
  final DateTime? firstChange;
  final DateTime? lastChange;
  final int totalChanges;

  const AuditLog({
    required this.entries,
    this.firstChange,
    this.lastChange,
    required this.totalChanges,
  });

  factory AuditLog.empty() {
    return AuditLog<T>(
      entries: [],
      totalChanges: 0,
    );
  }
}

// ========== INTERFACES SPÉCIFIQUES ==========

/// Interface spécifique pour CustomListRepository
abstract class CustomListRepositoryInterface {
  Future<String> create(Object list);
  Future<Object?> getById(String id);
  Future<List<Object>> getAll();
  Future<void> update(Object list);
  Future<void> delete(String id);
  Future<List<Object>> getByType(String type);
}