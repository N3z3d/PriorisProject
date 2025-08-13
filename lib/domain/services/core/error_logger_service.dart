import 'package:flutter/foundation.dart';
import 'interfaces/error_handler_interface.dart';

/// Service responsable du logging des erreurs
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur l'enregistrement et l'affichage des erreurs.
class ErrorLoggerService implements ErrorLoggerInterface {
  final bool _enableLogging;
  final List<LogEntry> _errorLog = [];
  final int _maxLogEntries;

  ErrorLoggerService({
    bool enableLogging = kDebugMode,
    int maxLogEntries = 100,
  }) : _enableLogging = enableLogging,
       _maxLogEntries = maxLogEntries;

  @override
  void logError(dynamic error, String? context, StackTrace? stackTrace) {
    if (!_enableLogging) return;

    final logEntry = LogEntry(
      error: error,
      context: context,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _addToLog(logEntry);
    _printError(logEntry);
  }

  /// Ajoute l'erreur au log interne
  void _addToLog(LogEntry entry) {
    _errorLog.add(entry);
    
    // Maintenir la limite du log
    if (_errorLog.length > _maxLogEntries) {
      _errorLog.removeAt(0);
    }
  }

  /// Affiche l'erreur dans la console
  void _printError(LogEntry entry) {
    final timestamp = entry.timestamp.toIso8601String();
    debugPrint('═══════════════════════════════════════════');
    debugPrint('[ERROR] $timestamp');
    if (entry.context != null) {
      debugPrint('[CONTEXT] ${entry.context}');
    }
    debugPrint('[MESSAGE] ${entry.error}');
    if (entry.stackTrace != null) {
      debugPrint('[STACK TRACE]\n${entry.stackTrace}');
    }
    debugPrint('═══════════════════════════════════════════');
  }

  /// Obtient le journal des erreurs
  List<LogEntry> get errorLog => List.unmodifiable(_errorLog);

  /// Vide le journal des erreurs
  void clearLog() {
    _errorLog.clear();
  }

  /// Obtient le nombre d'erreurs loggées
  int get errorCount => _errorLog.length;

  /// Obtient les erreurs récentes (dernières 24h)
  List<LogEntry> getRecentErrors() {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    return _errorLog
        .where((entry) => entry.timestamp.isAfter(yesterday))
        .toList();
  }

  /// Obtient les erreurs par catégorie
  Map<String, List<LogEntry>> getErrorsByCategory() {
    final Map<String, List<LogEntry>> categorized = {};
    
    for (final entry in _errorLog) {
      final category = entry.error is AppError 
          ? (entry.error as AppError).category 
          : 'UNKNOWN';
      
      categorized.putIfAbsent(category, () => []).add(entry);
    }
    
    return categorized;
  }
}

/// Entrée du journal d'erreurs
class LogEntry {
  final dynamic error;
  final String? context;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const LogEntry({
    required this.error,
    this.context,
    this.stackTrace,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LogEntry(error: $error, context: $context, timestamp: $timestamp)';
  }
}