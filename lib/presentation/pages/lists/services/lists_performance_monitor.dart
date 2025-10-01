import 'dart:async';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/presentation/services/performance/data_consistency_service.dart';
import 'package:prioris/presentation/services/performance/performance_monitor.dart';
import '../interfaces/lists_controller_interfaces.dart';

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
  Future<bool> validateDataConsistency(List<CustomList> lists) async {
    try {
      LoggerService.instance.debug(
        'Validation de la cohérence des données pour ${lists.length} listes',
        context: 'ListsPerformanceMonitor'
      );

      // Validation de base : vérifier que toutes les listes ont des IDs uniques
      final listIds = lists.map((list) => list.id).toList();
      final uniqueIds = listIds.toSet();

      if (listIds.length != uniqueIds.length) {
        logError('validateDataConsistency',
            'IDs de listes dupliqués détectés', StackTrace.current);
        return false;
      }

      // Validation des éléments : vérifier la cohérence des items
      for (final list in lists) {
        final itemIds = list.items.map((item) => item.id).toList();
        final uniqueItemIds = itemIds.toSet();

        if (itemIds.length != uniqueItemIds.length) {
          logError('validateDataConsistency',
              'IDs d\'éléments dupliqués détectés dans la liste "${list.name}"',
              StackTrace.current);
          return false;
        }

        // Vérifier que tous les items appartiennent à la bonne liste
        for (final item in list.items) {
          if (item.listId != list.id) {
            logError('validateDataConsistency',
                'Élément "${item.title}" appartient à la liste ${item.listId} mais se trouve dans la liste ${list.id}',
                StackTrace.current);
            return false;
          }
        }
      }

      LoggerService.instance.info(
        'Validation de cohérence réussie pour ${lists.length} listes',
        context: 'ListsPerformanceMonitor'
      );

      return true;
    } catch (e, stackTrace) {
      logError('validateDataConsistency', e, stackTrace);
      return false;
    }
  }

  @override
  void cacheLists(List<CustomList> lists) {
    try {
      // Utiliser le service de consistance des données pour le cache
      DataConsistencyService.cacheLists(lists);

      // Mettre à jour notre cache local pour les statistiques
      _performanceCache['cached_lists_count'] = lists.length;
      _performanceCache['last_cache_update'] = DateTime.now();

      LoggerService.instance.debug(
        'Cache mis à jour avec ${lists.length} listes',
        context: 'ListsPerformanceMonitor'
      );
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors de la mise en cache des listes: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
  }

  @override
  void invalidateCache() {
    try {
      // Invalider le cache du service de consistance des données
      DataConsistencyService.invalidateCache();

      // Nettoyer notre cache local
      _performanceCache.clear();

      LoggerService.instance.debug(
        'Cache invalidé avec succès',
        context: 'ListsPerformanceMonitor'
      );
    } catch (e) {
      LoggerService.instance.warning(
        'Erreur lors de l\'invalidation du cache: $e',
        context: 'ListsPerformanceMonitor'
      );
    }
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
  void logError(String operation, Object error, StackTrace? stackTrace) {
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