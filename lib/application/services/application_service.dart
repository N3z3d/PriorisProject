import 'package:flutter/foundation.dart';
import '../../domain/core/events/event_bus.dart';
import '../../domain/core/aggregates/aggregate_root.dart';

/// Interface de base pour tous les services d'application
/// 
/// Les services d'application orchestrent les cas d'usage métier
/// en utilisant les agrégats, services du domaine et repositories.
abstract class ApplicationService with EventBusPublisher {
  /// Nom du service pour l'identification
  String get serviceName;

  /// Valide les préconditions du service
  void validatePreconditions() {
    // Implémentation par défaut vide
  }

  /// Méthode template pour les opérations du service
  /// 1. Valide les préconditions
  /// 2. Exécute l'opération
  /// 3. Publie les événements des agrégats
  Future<T> executeOperation<T>(
    Future<T> Function() operation, {
    List<AggregateRoot>? aggregates,
  }) async {
    validatePreconditions();
    
    final result = await operation();
    
    // Publier les événements des agrégats modifiés
    if (aggregates != null) {
      for (final aggregate in aggregates) {
        if (aggregate.hasUncommittedEvents) {
          await publishEvents(aggregate.uncommittedEvents);
          aggregate.markEventsAsCommitted();
        }
      }
    }
    
    return result;
  }

  /// Gère les erreurs de manière uniforme
  Never handleError(Object error, StackTrace stackTrace, String operation) {
    // Log l'erreur (debug uniquement)
    if (kDebugMode) {
      debugPrint('Erreur dans $serviceName.$operation: $error');
      debugPrint('StackTrace: $stackTrace');
    }
    
    // Re-lancer l'erreur (peut être transformée si nécessaire)
    throw error;
  }

  /// Méthode utilitaire pour exécuter une opération avec gestion d'erreur
  Future<T> safeExecute<T>(
    Future<T> Function() operation,
    String operationName, {
    List<AggregateRoot>? aggregates,
  }) async {
    try {
      return await executeOperation(operation, aggregates: aggregates);
    } catch (error, stackTrace) {
      handleError(error, stackTrace, operationName);
    }
  }
}

/// Résultat d'une opération d'application avec métadonnées
class OperationResult<T> {
  final T data;
  final bool success;
  final String? message;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  const OperationResult({
    required this.data,
    this.success = true,
    this.message,
    this.warnings = const [],
    this.metadata = const {},
  });

  /// Crée un résultat de succès
  factory OperationResult.success(
    T data, {
    String? message,
    List<String> warnings = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return OperationResult(
      data: data,
      success: true,
      message: message,
      warnings: warnings,
      metadata: metadata,
    );
  }

  /// Crée un résultat d'échec
  factory OperationResult.failure(
    String message, {
    T? data,
    List<String> warnings = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return OperationResult(
      data: data as T,
      success: false,
      message: message,
      warnings: warnings,
      metadata: metadata,
    );
  }
}

/// Command pour encapsuler les données d'entrée
abstract class Command {
  /// Valide la command
  void validate() {
    // Implémentation par défaut vide
    // Les commands spécifiques peuvent override
  }
}

/// Query pour encapsuler les critères de recherche
abstract class Query {
  /// Valide la query
  void validate() {
    // Implémentation par défaut vide
    // Les queries spécifiques peuvent override
  }
}

/// Interface pour les handlers de commande
abstract class CommandHandler<TCommand extends Command, TResult> {
  Future<TResult> handle(TCommand command);
}

/// Interface pour les handlers de query
abstract class QueryHandler<TQuery extends Query, TResult> {
  Future<TResult> handle(TQuery query);
}

/// Décorateur pour ajouter de la validation aux handlers
class ValidatingCommandHandler<TCommand extends Command, TResult> 
    implements CommandHandler<TCommand, TResult> {
  final CommandHandler<TCommand, TResult> _innerHandler;

  ValidatingCommandHandler(this._innerHandler);

  @override
  Future<TResult> handle(TCommand command) async {
    command.validate();
    return await _innerHandler.handle(command);
  }
}

/// Décorateur pour ajouter du logging aux handlers
class LoggingCommandHandler<TCommand extends Command, TResult> 
    implements CommandHandler<TCommand, TResult> {
  final CommandHandler<TCommand, TResult> _innerHandler;
  final String _handlerName;

  LoggingCommandHandler(this._innerHandler, this._handlerName);

  @override
  Future<TResult> handle(TCommand command) async {
    if (kDebugMode) debugPrint('[$_handlerName] Début du traitement de ${command.runtimeType}');
    
    try {
      final result = await _innerHandler.handle(command);
      if (kDebugMode) debugPrint('[$_handlerName] Succès du traitement de ${command.runtimeType}');
      return result;
    } catch (error) {
      if (kDebugMode) debugPrint('[$_handlerName] Erreur lors du traitement de ${command.runtimeType}: $error');
      rethrow;
    }
  }
}

/// Décorateur pour ajouter du retry aux handlers
class RetryCommandHandler<TCommand extends Command, TResult> 
    implements CommandHandler<TCommand, TResult> {
  final CommandHandler<TCommand, TResult> _innerHandler;
  final int _maxRetries;
  final Duration _retryDelay;

  RetryCommandHandler(
    this._innerHandler, 
    this._maxRetries, 
    this._retryDelay,
  );

  @override
  Future<TResult> handle(TCommand command) async {
    int attempts = 0;
    
    while (attempts <= _maxRetries) {
      try {
        return await _innerHandler.handle(command);
      } catch (error) {
        attempts++;
        
        if (attempts > _maxRetries) {
          rethrow;
        }
        
        if (kDebugMode) debugPrint('Tentative $attempts/$_maxRetries échouée, retry dans ${_retryDelay.inMilliseconds}ms');
        await Future.delayed(_retryDelay);
      }
    }
    
    // Ne devrait jamais arriver, mais nécessaire pour le compilateur
    throw StateError('Échec inattendu du retry handler');
  }
}

/// Exception spécifique à la couche application
class ApplicationException implements Exception {
  final String message;
  final String? operationName;
  final Object? cause;

  const ApplicationException(
    this.message, {
    this.operationName,
    this.cause,
  });

  @override
  String toString() {
    final operation = operationName != null ? ' in $operationName' : '';
    return 'ApplicationException$operation: $message';
  }
}

/// Exception pour les validations métier
class BusinessValidationException extends ApplicationException {
  final List<String> validationErrors;

  const BusinessValidationException(
    super.message,
    this.validationErrors, {
    super.operationName,
  });
}

/// Exception pour les ressources non trouvées
class ResourceNotFoundException extends ApplicationException {
  final String resourceType;
  final String resourceId;

  const ResourceNotFoundException(this.resourceType, this.resourceId)
      : super('$resourceType with ID $resourceId not found');
}

/// Exception pour les conflits de concurrence
class ConcurrencyException extends ApplicationException {
  final String resourceType;
  final String resourceId;

  const ConcurrencyException(this.resourceType, this.resourceId)
      : super('Concurrency conflict for $resourceType $resourceId');
}