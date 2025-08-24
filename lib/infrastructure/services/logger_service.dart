import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();
  
  final Logger _logger;
  
  LoggerService._() : _logger = Logger(
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  // Constructor for testing
  LoggerService.testing(Logger logger) : _logger = logger;
  
  // Sensitive data patterns to sanitize
  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'key[:\s]*[a-zA-Z0-9_\-\.]+', caseSensitive: false),
    RegExp(r'token[:\s]*[a-zA-Z0-9_\-\.]+', caseSensitive: false),
    RegExp(r'password[:\s]*\S+', caseSensitive: false),
    RegExp(r'secret[:\s]*\S+', caseSensitive: false),
    RegExp(r'bearer\s+[a-zA-Z0-9_\-\.]+', caseSensitive: false),
  ];
  
  String _formatMessage(String message, {
    String? context,
    String? correlationId,
  }) {
    String formatted = message;
    
    // Sanitize sensitive data
    for (final pattern in _sensitivePatterns) {
      formatted = formatted.replaceAll(pattern, '***SANITIZED***');
    }
    
    // Add context
    if (context != null) {
      formatted = '[$context]${correlationId != null ? '[$correlationId]' : ''} $formatted';
    }
    
    return formatted;
  }
  
  void debug(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  }) {
    _logger.d(_formatMessage(message, context: context, correlationId: correlationId));
  }
  
  void info(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  }) {
    _logger.i(_formatMessage(message, context: context, correlationId: correlationId));
  }
  
  void warning(String message, {
    String? context,
    String? correlationId,
    dynamic data,
  }) {
    _logger.w(_formatMessage(message, context: context, correlationId: correlationId));
  }
  
  void error(String message, {
    String? context,
    String? correlationId,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      _formatMessage(message, context: context, correlationId: correlationId),
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  void fatal(String message, {
    String? context,
    String? correlationId,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.f(
      _formatMessage(message, context: context, correlationId: correlationId),
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  // Structured logging for performance metrics
  void performance(String operation, Duration duration, {
    String? context,
    String? correlationId,
    Map<String, dynamic>? metrics,
  }) {
    final data = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      if (metrics != null) ...metrics,
    };
    
    _logger.i(
      _formatMessage('Performance: $operation completed in ${duration.inMilliseconds}ms', 
                   context: context ?? 'Performance', correlationId: correlationId),
    );
  }
  
  // Structured logging for user actions
  void userAction(String action, {
    String? context,
    String? correlationId,
    Map<String, dynamic>? properties,
  }) {
    final data = {
      'action': action,
      if (properties != null) ...properties,
    };
    
    _logger.i(
      _formatMessage('User Action: $action', 
                   context: context ?? 'UserAction', correlationId: correlationId),
    );
  }
}