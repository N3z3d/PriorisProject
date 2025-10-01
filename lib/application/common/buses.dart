import 'dart:async';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Base interfaces for CQRS pattern implementation
/// 
/// Separates command (write) and query (read) operations
/// for better scalability and maintainability

// ========== COMMANDS ==========

/// Marker interface for all commands
/// Commands represent write operations that change system state
abstract class Command {
  const Command();
}

/// Handler for processing commands
abstract class CommandHandler<TCommand extends Command> {
  Future<void> handle(TCommand command);
}

/// Command bus interface for dispatching commands to handlers
abstract class CommandBus {
  Future<void> execute<TCommand extends Command>(TCommand command);
}

/// Concrete implementation of command bus
class CommandBusImpl implements CommandBus {
  final Map<Type, CommandHandler> _handlers = {};
  final List<CommandMiddleware> _middlewares = [];

  /// Register a command handler
  void register<TCommand extends Command>(CommandHandler<TCommand> handler) {
    _handlers[TCommand] = handler;
  }

  /// Add middleware for cross-cutting concerns
  void addMiddleware(CommandMiddleware middleware) {
    _middlewares.add(middleware);
  }

  @override
  Future<void> execute<TCommand extends Command>(TCommand command) async {
    final handler = _handlers[TCommand] as CommandHandler<TCommand>?;
    if (handler == null) {
      throw CommandHandlerNotFoundException(
        'No handler registered for command: ${TCommand.toString()}'
      );
    }

    // Execute middlewares and handler
    await _executeWithMiddlewares(command, handler);
  }

  Future<void> _executeWithMiddlewares<TCommand extends Command>(
    TCommand command,
    CommandHandler<TCommand> handler,
  ) async {
    var index = 0;

    Future<void> next() async {
      if (index < _middlewares.length) {
        final middleware = _middlewares[index++];
        await middleware.execute(command, next);
      } else {
        await handler.handle(command);
      }
    }

    await next();
  }
}

// ========== QUERIES ==========

/// Marker interface for all queries
/// Queries represent read operations that don't change system state
abstract class Query<TResult> {
  const Query();
}

/// Handler for processing queries
abstract class QueryHandler<TQuery extends Query<TResult>, TResult> {
  Future<TResult> handle(TQuery query);
}

/// Query bus interface for dispatching queries to handlers
abstract class QueryBus {
  Future<TResult> execute<TQuery extends Query<TResult>, TResult>(TQuery query);
}

/// Concrete implementation of query bus
class QueryBusImpl implements QueryBus {
  final Map<Type, QueryHandler> _handlers = {};
  final List<QueryMiddleware> _middlewares = [];

  /// Register a query handler
  void register<TQuery extends Query<TResult>, TResult>(
    QueryHandler<TQuery, TResult> handler,
  ) {
    _handlers[TQuery] = handler;
  }

  /// Add middleware for cross-cutting concerns
  void addMiddleware(QueryMiddleware middleware) {
    _middlewares.add(middleware);
  }

  @override
  Future<TResult> execute<TQuery extends Query<TResult>, TResult>(
    TQuery query,
  ) async {
    final handler = _handlers[TQuery] as QueryHandler<TQuery, TResult>?;
    if (handler == null) {
      throw QueryHandlerNotFoundException(
        'No handler registered for query: ${TQuery.toString()}'
      );
    }

    // Execute middlewares and handler
    return await _executeWithMiddlewares(query, handler);
  }

  Future<TResult> _executeWithMiddlewares<TQuery extends Query<TResult>, TResult>(
    TQuery query,
    QueryHandler<TQuery, TResult> handler,
  ) async {
    var index = 0;

    Future<TResult> next() async {
      if (index < _middlewares.length) {
        final middleware = _middlewares[index++];
        return await middleware.execute(query, () => next());
      } else {
        return await handler.handle(query);
      }
    }

    return await next();
  }
}

// ========== EVENTS ==========

/// Handler for processing domain events
abstract class EventHandler<TEvent> {
  Future<void> handle(TEvent event);
}

/// Event bus interface for publishing and subscribing to events
abstract class EventBus {
  Future<void> publish<TEvent>(TEvent event);
  void subscribe<TEvent>(EventHandler<TEvent> handler);
  void unsubscribe<TEvent>(EventHandler<TEvent> handler);
}

/// Concrete implementation of event bus
class EventBusImpl implements EventBus {
  final Map<Type, List<EventHandler>> _handlers = {};

  @override
  Future<void> publish<TEvent>(TEvent event) async {
    final handlers = _handlers[TEvent] ?? [];
    
    // Execute all handlers concurrently
    final futures = handlers.map((handler) => 
      (handler as EventHandler<TEvent>).handle(event)
    );
    
    await Future.wait(futures);
  }

  @override
  void subscribe<TEvent>(EventHandler<TEvent> handler) {
    _handlers[TEvent] ??= [];
    _handlers[TEvent]!.add(handler);
  }

  @override
  void unsubscribe<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _handlers[TEvent];
    if (handlers != null) {
      handlers.remove(handler);
      if (handlers.isEmpty) {
        _handlers.remove(TEvent);
      }
    }
  }
}

// ========== MIDDLEWARES ==========

/// Middleware for cross-cutting concerns in command pipeline
abstract class CommandMiddleware {
  Future<void> execute<TCommand extends Command>(
    TCommand command,
    Future<void> Function() next,
  );
}

/// Middleware for cross-cutting concerns in query pipeline
abstract class QueryMiddleware {
  Future<TResult> execute<TQuery extends Query<TResult>, TResult>(
    TQuery query,
    Future<TResult> Function() next,
  );
}

/// Logging middleware for commands
class LoggingCommandMiddleware extends CommandMiddleware {
  @override
  Future<void> execute<TCommand extends Command>(
    TCommand command,
    Future<void> Function() next,
  ) async {
    final stopwatch = Stopwatch()..start();
    LoggerService.instance.info('📨 Executing command: ${TCommand.toString()}', context: 'CommandBus');

    try {
      await next();
      stopwatch.stop();
      LoggerService.instance.info('✅ Command completed in ${stopwatch.elapsedMilliseconds}ms', context: 'CommandBus');
    } catch (e) {
      stopwatch.stop();
      LoggerService.instance.error('❌ Command failed in ${stopwatch.elapsedMilliseconds}ms: $e', context: 'CommandBus', error: e);
      rethrow;
    }
  }
}

/// Logging middleware for queries
class LoggingQueryMiddleware extends QueryMiddleware {
  @override
  Future<TResult> execute<TQuery extends Query<TResult>, TResult>(
    TQuery query,
    Future<TResult> Function() next,
  ) async {
    final stopwatch = Stopwatch()..start();
    LoggerService.instance.info('🔍 Executing query: ${TQuery.toString()}', context: 'QueryBus');

    try {
      final result = await next();
      stopwatch.stop();
      LoggerService.instance.info('✅ Query completed in ${stopwatch.elapsedMilliseconds}ms', context: 'QueryBus');
      return result;
    } catch (e) {
      stopwatch.stop();
      LoggerService.instance.error('❌ Query failed in ${stopwatch.elapsedMilliseconds}ms: $e', context: 'QueryBus', error: e);
      rethrow;
    }
  }
}

/// Validation middleware for commands
class ValidationCommandMiddleware extends CommandMiddleware {
  @override
  Future<void> execute<TCommand extends Command>(
    TCommand command,
    Future<void> Function() next,
  ) async {
    // Validate command before execution
    if (command is ValidatableCommand) {
      final errors = (command as ValidatableCommand).validate();
      if (errors.isNotEmpty) {
        throw ValidationException('Command validation failed', errors);
      }
    }
    
    await next();
  }
}

/// Interface for commands that support validation
abstract class ValidatableCommand extends Command {
  List<String> validate();
}

// ========== EXCEPTIONS ==========

class CommandHandlerNotFoundException implements Exception {
  final String message;
  CommandHandlerNotFoundException(this.message);
  
  @override
  String toString() => 'CommandHandlerNotFoundException: $message';
}

class QueryHandlerNotFoundException implements Exception {
  final String message;
  QueryHandlerNotFoundException(this.message);
  
  @override
  String toString() => 'QueryHandlerNotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  final List<String> errors;
  
  ValidationException(this.message, this.errors);
  
  @override
  String toString() => 'ValidationException: $message - ${errors.join(', ')}';
}

// ========== MEDIATOR PATTERN ==========

/// Mediator that combines all buses for convenience
class Mediator {
  final CommandBus _commandBus;
  final QueryBus _queryBus;
  final EventBus _eventBus;

  Mediator(this._commandBus, this._queryBus, this._eventBus);

  Future<void> send<TCommand extends Command>(TCommand command) {
    return _commandBus.execute(command);
  }

  Future<TResult> query<TQuery extends Query<TResult>, TResult>(TQuery query) {
    return _queryBus.execute<TQuery, TResult>(query);
  }

  Future<void> publish<TEvent>(TEvent event) {
    return _eventBus.publish(event);
  }
}