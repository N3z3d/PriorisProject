import 'dart:async';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/presentation/services/performance/data_consistency_service.dart';
import 'package:prioris/presentation/services/performance/performance_monitor.dart';
import '../interfaces/lists_managers_interfaces.dart';

/// Service responsable du monitoring de performance et de la cohérence des données
///
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur le suivi des performances et la validation.
///
/// Applique le principe Dependency Inversion en utilisant des services abstraits.
class ListsPerformanceMonitor implements IListsPerformanceMonitor {
  // Statistiques des opérations
  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, int> _operationCounts = {};
  final Map<String, List<Duration>> _operationDurations = {};

  // Cache pour les performances
  final Map<String, dynamic> _performanceCache = {};

  // Flags d'état
  bool _isMonitoringActive = true;

  @override
  void startOperation(String operationName) {
    if (!_isMonitoringActive) return;

    try {
      _operationStartTimes[operationName] = DateTime.now();
      _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;

      LoggerService.instance.debug(
        'Démarrage du monitoring pour l\'opération: $operationName',
        context: 'ListsPerformanceMonitor'
      );

      // Démarrer le monitoring global si disponible
      PerformanceMonitor.startOperation(operationName);
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors du démarrage du monitoring pour $operationName: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
  }

  @override
  void endOperation(String operationName) {
    if (!_isMonitoringActive) return;

    try {
      final startTime = _operationStartTimes.remove(operationName);
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);

        // Enregistrer la durée
        if (!_operationDurations.containsKey(operationName)) {
          _operationDurations[operationName] = [];
        }
        _operationDurations[operationName]!.add(duration);

        LoggerService.instance.debug(
          'Fin du monitoring pour $operationName - Durée: ${duration.inMilliseconds}ms',
          context: 'ListsPerformanceMonitor'
        );

        // Alerter si l'opération prend trop de temps
        if (duration.inMilliseconds > 2000) { // Plus de 2 secondes
          LoggerService.instance.warning(
            'Opération lente détectée: $operationName a pris ${duration.inMilliseconds}ms',
            context: 'ListsPerformanceMonitor'
          );
        }

        // Terminer le monitoring global si disponible
        PerformanceMonitor.endOperation(operationName);
      } else {
        LoggerService.instance.warning(
          'Tentative de fin de monitoring sans démarrage pour: $operationName',
          context: 'ListsPerformanceMonitor'
        );
      }
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors de la fin du monitoring pour $operationName: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
  }

  @override
  void monitorCacheOperation(String operation, bool hit) {
    try {
      final hitStatus = hit ? 'HIT' : 'MISS';
      LoggerService.instance.debug(
        'Cache $hitStatus pour l\'opération: $operation',
        context: 'ListsPerformanceMonitor'
      );

      // Enregistrer dans les statistiques
      final cacheKey = 'cache_${operation}_${hitStatus.toLowerCase()}';
      _performanceCache[cacheKey] = (_performanceCache[cacheKey] ?? 0) + 1;
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors du monitoring de cache pour $operation: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
  }

  @override
  void monitorCollectionSize(String collection, int size) {
    try {
      LoggerService.instance.debug(
        'Taille de la collection $collection: $size',
        context: 'ListsPerformanceMonitor'
      );

      // Enregistrer dans les statistiques
      _performanceCache['${collection}_size'] = size;
      _performanceCache['${collection}_last_measured'] = DateTime.now();
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors du monitoring de taille pour $collection: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
  }

  @override
  Map<String, dynamic> getDetailedMetrics() {
    try {
      final baseStats = getPerformanceStats();
      final detailedMetrics = <String, dynamic>{
        ...baseStats,
        'cache_metrics': _getCacheMetrics(),
        'collection_metrics': _getCollectionMetrics(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      return detailedMetrics;
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors de la génération des métriques détaillées: $e',
        context: 'ListsPerformanceMonitor'
      );
      return {'error': 'Failed to generate detailed metrics', 'exception': e.toString()};
    }
  }

  Map<String, dynamic> _getCacheMetrics() {
    final cacheMetrics = <String, dynamic>{};
    _performanceCache.forEach((key, value) {
      if (key.startsWith('cache_')) {
        cacheMetrics[key] = value;
      }
    });
    return cacheMetrics;
  }

  Map<String, dynamic> _getCollectionMetrics() {
    final collectionMetrics = <String, dynamic>{};
    _performanceCache.forEach((key, value) {
      if (key.endsWith('_size') || key.endsWith('_last_measured')) {
        collectionMetrics[key] = value;
      }
    });
    return collectionMetrics;
  }

  @override
  Map<String, dynamic> getPerformanceStats() {
    try {
      final stats = <String, dynamic>{};

      // Statistiques des opérations
      stats['operation_counts'] = Map<String, int>.from(_operationCounts);

      // Statistiques de durée moyenne
      final avgDurations = <String, int>{};
      _operationDurations.forEach((operation, durations) {
        if (durations.isNotEmpty) {
          final totalMs = durations.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
          avgDurations[operation] = totalMs ~/ durations.length;
        }
      });
      stats['average_durations_ms'] = avgDurations;

      // Statistiques de durée maximale
      final maxDurations = <String, int>{};
      _operationDurations.forEach((operation, durations) {
        if (durations.isNotEmpty) {
          maxDurations[operation] = durations
              .map((d) => d.inMilliseconds)
              .reduce((a, b) => a > b ? a : b);
        }
      });
      stats['max_durations_ms'] = maxDurations;

      // Opérations en cours
      stats['active_operations'] = _operationStartTimes.keys.toList();

      // Statistiques du cache
      stats['cache_info'] = Map<String, dynamic>.from(_performanceCache);

      // Statut du monitoring
      stats['monitoring_active'] = _isMonitoringActive;
      stats['stats_generated_at'] = DateTime.now().toIso8601String();

      return stats;
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors de la génération des statistiques de performance: $e',
        context: 'ListsPerformanceMonitor'
      );
      return {'error': 'Failed to generate performance stats', 'exception': e.toString()};
    }
  }

  @override
  void logError(String operation, Object error, [StackTrace? stackTrace]) {
    try {
      LoggerService.instance.error(
        'Erreur dans l\'opération $operation',
        context: 'ListsPerformanceMonitor',
        error: error
      );

      // Enregistrer dans les statistiques d'erreur
      final errorKey = '${operation}_errors';
      _performanceCache[errorKey] = (_performanceCache[errorKey] ?? 0) + 1;
      _performanceCache['last_error'] = {
        'operation': operation,
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      // Fallback vers print si le logging échoue
      print('CRITICAL: Erreur lors du logging d\'erreur: $e');
      print('Erreur originale - $operation: $error');
    }
  }

  @override
  void logInfo(String message, {String? context}) {
    try {
      LoggerService.instance.info(
        message,
        context: context ?? 'ListsPerformanceMonitor'
      );
    } catch (e) {
      print('Erreur lors du logging d\'info: $e - Message: $message');
    }
  }

  @override
  void logWarning(String message, {String? context}) {
    try {
      LoggerService.instance.warning(
        message,
        context: context ?? 'ListsPerformanceMonitor'
      );
    } catch (e) {
      print('Erreur lors du logging d\'avertissement: $e - Message: $message');
    }
  }

  /// Méthodes utilitaires pour la gestion du monitor

  /// Active ou désactive le monitoring
  void setMonitoringActive(bool active) {
    _isMonitoringActive = active;
    LoggerService.instance.info(
      'Monitoring ${active ? 'activé' : 'désactivé'}',
      context: 'ListsPerformanceMonitor'
    );
  }

  /// Nettoie les statistiques anciennes
  void cleanupOldStats({Duration maxAge = const Duration(hours: 1)}) {
    try {
      final now = DateTime.now();
      final cutoff = now.subtract(maxAge);

      // Nettoyer les durées anciennes
      _operationDurations.forEach((operation, durations) {
        _operationDurations[operation] = durations.where((duration) {
          // Approximation : garder seulement les durées récentes
          return true; // Pour le moment, on garde tout - améliorer si nécessaire
        }).toList();
      });

      LoggerService.instance.debug(
        'Nettoyage des statistiques anciennes terminé',
        context: 'ListsPerformanceMonitor'
      );
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors du nettoyage des statistiques: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
  }

  /// Réinitialise toutes les statistiques
  void resetStats() {
    try {
      _operationStartTimes.clear();
      _operationCounts.clear();
      _operationDurations.clear();
      _performanceCache.clear();

      LoggerService.instance.info(
        'Statistiques de performance réinitialisées',
        context: 'ListsPerformanceMonitor'
      );
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors de la réinitialisation des statistiques: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
  }

  /// Obtient un résumé des performances
  String getPerformanceSummary() {
    try {
      final stats = getPerformanceStats();
      final buffer = StringBuffer();

      buffer.writeln('=== Résumé des performances ===');
      buffer.writeln('Monitoring actif: ${stats['monitoring_active']}');
      buffer.writeln('Opérations actives: ${(stats['active_operations'] as List).length}');
      buffer.writeln('');

      final opCounts = stats['operation_counts'] as Map<String, int>;
      if (opCounts.isNotEmpty) {
        buffer.writeln('Nombre d\'opérations:');
        opCounts.forEach((op, count) {
          buffer.writeln('  - $op: $count');
        });
        buffer.writeln('');
      }

      final avgDurations = stats['average_durations_ms'] as Map<String, int>;
      if (avgDurations.isNotEmpty) {
        buffer.writeln('Durées moyennes (ms):');
        avgDurations.forEach((op, duration) {
          buffer.writeln('  - $op: ${duration}ms');
        });
      }

      return buffer.toString();
    } catch (e) {
      return 'Erreur lors de la génération du résumé: $e';
    }
  }
}