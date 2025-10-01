/// Core Application Interfaces following SOLID principles
///
/// Interface Segregation Principle: Small, focused interfaces
/// Dependency Inversion Principle: Program to interfaces, not implementations

// ═══════════════════════════════════════════════════════════════════════════
// COMMAND PATTERN INTERFACES (SRP + OCP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base command interface for all operations
abstract class Command<T> {
  Future<T> execute();
  void undo();
  bool canUndo();
}

/// Query interface for read-only operations (CQRS pattern)
abstract class Query<T> {
  Future<T> execute();
}

/// Command handler interface
abstract class CommandHandler<TCommand extends Command<TResult>, TResult> {
  Future<TResult> handle(TCommand command);
}

/// Query handler interface
abstract class QueryHandler<TQuery extends Query<TResult>, TResult> {
  Future<TResult> handle(TQuery query);
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVICE INTERFACES (ISP)
// ═══════════════════════════════════════════════════════════════════════════

/// Read-only operations interface
abstract class ReadableService<T, TId> {
  Future<T?> getById(TId id);
  Future<List<T>> getAll();
}

/// Write operations interface
abstract class WritableService<T, TId> {
  Future<TId> create(T entity);
  Future<void> update(T entity);
  Future<void> delete(TId id);
}

/// Search operations interface
abstract class SearchableService<T> {
  Future<List<T>> search(String query);
  Future<List<T>> filterBy(Map<String, dynamic> criteria);
}

/// Validation interface
abstract class ValidatableService<T> {
  Future<ValidationResult> validate(T entity);
}

/// Cacheable operations interface
abstract class CacheableService<T, TId> {
  Future<void> cacheEntity(TId id, T entity);
  Future<T?> getCachedEntity(TId id);
  Future<void> invalidateCache(TId id);
  Future<void> clearCache();
}

// ═══════════════════════════════════════════════════════════════════════════
// OBSERVER PATTERN INTERFACES (OCP)
// ═══════════════════════════════════════════════════════════════════════════

/// Event interface for domain events
abstract class DomainEvent {
  String get eventId;
  DateTime get occurredAt;
  String get eventType;
  Map<String, dynamic> get payload;
}

/// Event publisher interface
abstract class EventPublisher {
  Future<void> publish(DomainEvent event);
  void subscribe<T extends DomainEvent>(EventHandler<T> handler);
  void unsubscribe<T extends DomainEvent>(EventHandler<T> handler);
}

/// Event handler interface
abstract class EventHandler<T extends DomainEvent> {
  Future<void> handle(T event);
  bool canHandle(DomainEvent event);
}

// ═══════════════════════════════════════════════════════════════════════════
// FACTORY PATTERN INTERFACES (DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Generic factory interface
abstract class Factory<T> {
  T create();
  bool canCreate(Type type);
}

/// Builder interface for complex object creation
abstract class Builder<T> {
  Builder<T> reset();
  T build();
}

// ═══════════════════════════════════════════════════════════════════════════
// STRATEGY PATTERN INTERFACES (OCP)
// ═══════════════════════════════════════════════════════════════════════════

/// Strategy context interface
abstract class StrategyContext<TStrategy> {
  void setStrategy(TStrategy strategy);
  TStrategy get currentStrategy;
}

/// Executable strategy interface
abstract class Strategy<TInput, TOutput> {
  Future<TOutput> execute(TInput input);
  bool canExecute(TInput input);
  String get name;
}

// ═══════════════════════════════════════════════════════════════════════════
// VALIDATION SUPPORT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Validation result class
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  ValidationResult.success() : this(isValid: true);

  ValidationResult.failure(List<ValidationError> errors)
      : this(isValid: false, errors: errors);
}

/// Validation error class
class ValidationError {
  final String field;
  final String message;
  final String code;

  const ValidationError({
    required this.field,
    required this.message,
    required this.code,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// ERROR HANDLING INTERFACES (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// Error handler interface
abstract class ErrorHandler {
  Future<void> handleError(Exception error, Map<String, dynamic>? context);
  bool canHandle(Exception error);
}

/// Error classifier interface
abstract class ErrorClassifier {
  ErrorSeverity classifySeverity(Exception error);
  ErrorCategory classifyCategory(Exception error);
  Map<String, dynamic> extractContext(Exception error);
}

/// Error severity levels
enum ErrorSeverity { low, medium, high, critical }

/// Error categories
enum ErrorCategory { validation, network, storage, business, system }