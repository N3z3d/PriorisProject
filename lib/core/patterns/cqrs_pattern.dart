/// Command Query Responsibility Segregation (CQRS) Pattern Implementation
///
/// Single Responsibility: Commands change state, Queries read state
/// Open/Closed: Easy to add new commands/queries without modifying existing code
/// Interface Segregation: Separate interfaces for commands and queries
/// Dependency Inversion: Handlers depend on abstractions

import '../interfaces/application_interfaces.dart';

// ═══════════════════════════════════════════════════════════════════════════
// COMMAND IMPLEMENTATIONS (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base command implementation
abstract class BaseCommand<T> implements Command<T> {
  final String _id;
  final DateTime _timestamp;
  bool _executed = false;
  T? _result;
  Exception? _error;

  BaseCommand() : _id = _generateId(), _timestamp = DateTime.now();

  String get id => _id;
  DateTime get timestamp => _timestamp;
  bool get isExecuted => _executed;
  T? get result => _result;
  Exception? get error => _error;

  @override
  Future<T> execute() async {
    if (_executed) {
      throw StateError('Command already executed');
    }

    try {
      _result = await executeInternal();
      _executed = true;
      return _result!;
    } catch (e) {
      _error = e is Exception ? e : Exception(e.toString());
      _executed = true;
      rethrow;
    }
  }

  /// Internal execution logic to be implemented by concrete commands
  Future<T> executeInternal();

  @override
  bool canUndo() => _executed && _error == null;

  static String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

/// Undoable command with state preservation
abstract class UndoableCommand<T> extends BaseCommand<T> {
  Map<String, dynamic>? _previousState;

  @override
  Future<T> execute() async {
    _previousState = await captureCurrentState();
    return super.execute();
  }

  @override
  void undo() {
    if (!canUndo()) {
      throw StateError('Command cannot be undone');
    }

    if (_previousState != null) {
      restoreState(_previousState!);
    }
  }

  /// Capture state before execution for potential undo
  Future<Map<String, dynamic>> captureCurrentState();

  /// Restore state for undo operation
  void restoreState(Map<String, dynamic> state);
}

// ═══════════════════════════════════════════════════════════════════════════
// QUERY IMPLEMENTATIONS (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base query implementation
abstract class BaseQuery<T> implements Query<T> {
  final String _id;
  final DateTime _timestamp;
  final Map<String, dynamic> _parameters;

  BaseQuery([Map<String, dynamic>? parameters])
      : _id = _generateId(),
        _timestamp = DateTime.now(),
        _parameters = parameters ?? {};

  String get id => _id;
  DateTime get timestamp => _timestamp;
  Map<String, dynamic> get parameters => Map.unmodifiable(_parameters);

  @override
  Future<T> execute() => executeInternal();

  /// Internal query logic to be implemented by concrete queries
  Future<T> executeInternal();

  static String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

/// Cached query with automatic cache management
abstract class CachedQuery<T> extends BaseQuery<T> {
  final Duration _cacheExpiration;
  static final Map<String, _CacheEntry> _cache = {};

  CachedQuery({
    Map<String, dynamic>? parameters,
    Duration cacheExpiration = const Duration(minutes: 5),
  }) : _cacheExpiration = cacheExpiration, super(parameters);

  @override
  Future<T> execute() async {
    final cacheKey = _generateCacheKey();
    final cachedEntry = _cache[cacheKey];

    if (cachedEntry != null && !cachedEntry.isExpired) {
      return cachedEntry.data as T;
    }

    final result = await executeInternal();
    _cache[cacheKey] = _CacheEntry(
      data: result,
      expiresAt: DateTime.now().add(_cacheExpiration),
    );

    return result;
  }

  String _generateCacheKey() {
    final params = parameters.entries.map((e) => '${e.key}:${e.value}').join('|');
    return '${runtimeType.toString()}|$params';
  }

  /// Clear cache for this query type
  void clearCache() {
    _cache.removeWhere((key, _) => key.startsWith(runtimeType.toString()));
  }

  /// Clear all cached queries
  static void clearAllCache() {
    _cache.clear();
  }
}

/// Cache entry helper class
class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ═══════════════════════════════════════════════════════════════════════════
// COMMAND/QUERY BUS IMPLEMENTATION (OCP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Command bus for routing commands to appropriate handlers
class CommandBus {
  final Map<Type, CommandHandler> _handlers = {};

  /// Register a command handler
  void register<TCommand extends Command<TResult>, TResult>(
    CommandHandler<TCommand, TResult> handler,
  ) {
    _handlers[TCommand] = handler;
  }

  /// Execute a command through its registered handler
  Future<T> execute<T>(Command<T> command) async {
    final handler = _handlers[command.runtimeType];
    if (handler == null) {
      throw ArgumentError('No handler registered for ${command.runtimeType}');
    }

    return await handler.handle(command as Command<T>);
  }

  /// Check if a handler is registered for a command type
  bool hasHandler<T extends Command>() {
    return _handlers.containsKey(T);
  }

  /// Get all registered command types
  List<Type> get registeredCommandTypes => _handlers.keys.toList();
}

/// Query bus for routing queries to appropriate handlers
class QueryBus {
  final Map<Type, QueryHandler> _handlers = {};

  /// Register a query handler
  void register<TQuery extends Query<TResult>, TResult>(
    QueryHandler<TQuery, TResult> handler,
  ) {
    _handlers[TQuery] = handler;
  }

  /// Execute a query through its registered handler
  Future<T> execute<T>(Query<T> query) async {
    final handler = _handlers[query.runtimeType];
    if (handler == null) {
      throw ArgumentError('No handler registered for ${query.runtimeType}');
    }

    return await handler.handle(query as Query<T>);
  }

  /// Check if a handler is registered for a query type
  bool hasHandler<T extends Query>() {
    return _handlers.containsKey(T);
  }

  /// Get all registered query types
  List<Type> get registeredQueryTypes => _handlers.keys.toList();
}

// ═══════════════════════════════════════════════════════════════════════════
// MEDIATOR PATTERN IMPLEMENTATION (OCP)
// ═══════════════════════════════════════════════════════════════════════════

/// Mediator for handling both commands and queries
class Mediator {
  final CommandBus _commandBus;
  final QueryBus _queryBus;

  Mediator({
    CommandBus? commandBus,
    QueryBus? queryBus,
  }) : _commandBus = commandBus ?? CommandBus(),
        _queryBus = queryBus ?? QueryBus();

  /// Send a command
  Future<T> send<T>(Command<T> command) => _commandBus.execute(command);

  /// Send a query
  Future<T> query<T>(Query<T> query) => _queryBus.execute(query);

  /// Register command handler
  void registerCommandHandler<TCommand extends Command<TResult>, TResult>(
    CommandHandler<TCommand, TResult> handler,
  ) {
    _commandBus.register(handler);
  }

  /// Register query handler
  void registerQueryHandler<TQuery extends Query<TResult>, TResult>(
    QueryHandler<TQuery, TResult> handler,
  ) {
    _queryBus.register(handler);
  }
}