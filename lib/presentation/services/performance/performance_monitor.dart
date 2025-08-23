import 'dart:async';

/// Service de monitoring des performances pour détecter et diagnostiquer
/// les problèmes de chargement de données dans l'application.
class PerformanceMonitor {
  static final Map<String, DateTime> _operationStartTimes = {};
  static final Map<String, Duration> _operationDurations = {};
  static final List<PerformanceEvent> _events = [];
  
  /// Démarre le chronométrage d'une opération
  static void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    _logEvent(PerformanceEvent(
      type: EventType.operationStart,
      operation: operationName,
      timestamp: DateTime.now(),
    ));
  }
  
  /// Termine le chronométrage d'une opération
  static void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _operationDurations[operationName] = duration;
      _operationStartTimes.remove(operationName);
      
      _logEvent(PerformanceEvent(
        type: EventType.operationEnd,
        operation: operationName,
        timestamp: DateTime.now(),
        duration: duration,
      ));
      
      // Alertes pour les opérations lentes
      if (duration > const Duration(seconds: 2)) {
        print('⚠️ Opération lente détectée: $operationName (${duration.inMilliseconds}ms)');
      }
    }
  }
  
  /// Enregistre un événement de diagnostic
  static void logDataInconsistency({
    required String operation,
    required int expectedCount,
    required int actualCount,
    String? additionalInfo,
  }) {
    _logEvent(PerformanceEvent(
      type: EventType.dataInconsistency,
      operation: operation,
      timestamp: DateTime.now(),
      metadata: {
        'expected_count': expectedCount,
        'actual_count': actualCount,
        'additional_info': additionalInfo,
      },
    ));
    
    print('🔍 Incohérence de données: $operation - Attendu: $expectedCount, Réel: $actualCount');
  }
  
  /// Enregistre un événement de cache
  static void logCacheEvent({
    required String operation,
    required bool hit,
    int? itemCount,
  }) {
    _logEvent(PerformanceEvent(
      type: EventType.cacheOperation,
      operation: operation,
      timestamp: DateTime.now(),
      metadata: {
        'cache_hit': hit,
        'item_count': itemCount,
      },
    ));
  }
  
  /// Génère un rapport de performance
  static Map<String, dynamic> generateReport() {
    final now = DateTime.now();
    final recentEvents = _events.where((e) => 
      now.difference(e.timestamp) < const Duration(minutes: 10)
    ).toList();
    
    return {
      'operation_durations': _operationDurations.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'recent_events_count': recentEvents.length,
      'data_inconsistencies': recentEvents
          .where((e) => e.type == EventType.dataInconsistency)
          .length,
      'cache_hits': recentEvents
          .where((e) => e.type == EventType.cacheOperation && e.metadata?['cache_hit'] == true)
          .length,
      'cache_misses': recentEvents
          .where((e) => e.type == EventType.cacheOperation && e.metadata?['cache_hit'] == false)
          .length,
      'slow_operations': _operationDurations.entries
          .where((e) => e.value > const Duration(seconds: 1))
          .map((e) => '${e.key}: ${e.value.inMilliseconds}ms')
          .toList(),
    };
  }
  
  /// Vide l'historique des événements
  static void clearHistory() {
    _events.clear();
    _operationDurations.clear();
  }
  
  static void _logEvent(PerformanceEvent event) {
    _events.add(event);
    
    // Garder seulement les 1000 derniers événements
    if (_events.length > 1000) {
      _events.removeRange(0, _events.length - 1000);
    }
  }
}

/// Types d'événements de performance
enum EventType {
  operationStart,
  operationEnd,
  dataInconsistency,
  cacheOperation,
}

/// Événement de performance
class PerformanceEvent {
  final EventType type;
  final String operation;
  final DateTime timestamp;
  final Duration? duration;
  final Map<String, dynamic>? metadata;
  
  PerformanceEvent({
    required this.type,
    required this.operation,
    required this.timestamp,
    this.duration,
    this.metadata,
  });
}