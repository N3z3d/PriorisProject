import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Adaptateur qui implémente l'interface ILogger du domaine
/// en déléguant au LoggerService concret de l'infrastructure
///
/// Respecte le principe DIP en permettant au domaine de dépendre
/// uniquement de l'abstraction ILogger.
class LoggerAdapter implements ILogger {
  final LoggerService _loggerService;

  LoggerAdapter(this._loggerService);

  /// Factory par défaut utilisant l'instance singleton
  factory LoggerAdapter.defaultInstance() {
    return LoggerAdapter(LoggerService.instance);
  }

  @override
  void debug(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  }) {
    _loggerService.debug(
      message,
      context: context,
      correlationId: correlationId,
      data: data,
    );
  }

  @override
  void info(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  }) {
    _loggerService.info(
      message,
      context: context,
      correlationId: correlationId,
      data: data,
    );
  }

  @override
  void warning(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  }) {
    _loggerService.warning(
      message,
      context: context,
      correlationId: correlationId,
      data: data,
    );
  }

  @override
  void error(String message, {
    String? context,
    String? correlationId,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _loggerService.error(
      message,
      context: context,
      correlationId: correlationId,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void fatal(String message, {
    String? context,
    String? correlationId,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _loggerService.fatal(
      message,
      context: context,
      correlationId: correlationId,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void performance(String operation, Duration duration, {
    String? context,
    String? correlationId,
    Map<String, dynamic>? metrics,
  }) {
    _loggerService.performance(
      operation,
      duration,
      context: context,
      correlationId: correlationId,
      metrics: metrics,
    );
  }

  @override
  void userAction(String action, {
    String? context,
    String? correlationId,
    Map<String, dynamic>? properties,
  }) {
    _loggerService.userAction(
      action,
      context: context,
      correlationId: correlationId,
      properties: properties,
    );
  }
}