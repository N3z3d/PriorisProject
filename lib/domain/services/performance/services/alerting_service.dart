import 'dart:async';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Service responsable uniquement de la gestion des alertes de performance
///
/// Respecte le Single Responsibility Principle en ne gérant que
/// l'évaluation des seuils et le déclenchement des alertes
class AlertingService {
  final Map<String, AlertThreshold> _thresholds = {};
  final Map<String, Function(PerformanceAlert)> _handlers = {};
  final List<PerformanceAlert> _recentAlerts = [];
  final int _maxAlertsHistory = 1000;

  Timer? _alertsCleanupTimer;

  AlertingService() {
    _initializeDefaultThresholds();
    _startAlertsCleanup();
  }

  /// Configure un seuil d'alerte pour une métrique
  void setThreshold(String metricName, AlertThreshold threshold) {
    _thresholds[metricName] = threshold;

    LoggerService.instance.info(
      'Seuil configuré pour $metricName: warning=${threshold.warning}, critical=${threshold.critical}',
      context: 'AlertingService',
    );
  }

  /// Configure un gestionnaire d'alerte
  void setAlertHandler(String metricName, Function(PerformanceAlert) handler) {
    _handlers[metricName] = handler;

    LoggerService.instance.info(
      'Gestionnaire d\'alerte configuré pour $metricName',
      context: 'AlertingService',
    );
  }

  /// Évalue une métrique et déclenche les alertes si nécessaire
  void evaluateMetric(String metricName, double value, {Map<String, dynamic>? context}) {
    final threshold = _thresholds[metricName];
    if (threshold == null) return;

    final level = threshold.evaluateValue(value);

    if (level != AlertLevel.normal) {
      final alert = PerformanceAlert(
        metricName: metricName,
        currentValue: value,
        level: level,
        threshold: threshold,
        timestamp: DateTime.now(),
        context: context,
      );

      _triggerAlert(alert);
    }
  }

  /// Déclenche une alerte
  void _triggerAlert(PerformanceAlert alert) {
    // Ajouter à l'historique
    _recentAlerts.add(alert);
    _maintainAlertsHistory();

    // Log de l'alerte
    LoggerService.instance.warning(
      'Alerte ${alert.severity}: ${alert.metricName} = ${alert.currentValue}',
      context: 'AlertingService',
    );

    // Appeler le gestionnaire spécifique
    final handler = _handlers[alert.metricName];
    if (handler != null) {
      try {
        handler(alert);
      } catch (e) {
        LoggerService.instance.error(
          'Erreur dans le gestionnaire d\'alerte pour ${alert.metricName}',
          context: 'AlertingService',
          error: e,
        );
      }
    }

    // Appeler le gestionnaire global
    final globalHandler = _handlers['*'];
    if (globalHandler != null) {
      try {
        globalHandler(alert);
      } catch (e) {
        LoggerService.instance.error(
          'Erreur dans le gestionnaire d\'alerte global',
          context: 'AlertingService',
          error: e,
        );
      }
    }
  }

  /// Obtient les alertes récentes
  List<PerformanceAlert> getRecentAlerts({Duration? period}) {
    if (period == null) {
      return List.unmodifiable(_recentAlerts);
    }

    final cutoffTime = DateTime.now().subtract(period);
    return _recentAlerts
        .where((alert) => alert.timestamp.isAfter(cutoffTime))
        .toList();
  }

  /// Obtient les alertes par niveau
  List<PerformanceAlert> getAlertsByLevel(AlertLevel level, {Duration? period}) {
    final alerts = getRecentAlerts(period: period);
    return alerts.where((alert) => alert.level == level).toList();
  }

  /// Obtient les alertes critiques récentes
  List<PerformanceAlert> getCriticalAlerts({Duration? period}) {
    return getAlertsByLevel(AlertLevel.critical, period: period);
  }

  /// Obtient les alertes d'avertissement récentes
  List<PerformanceAlert> getWarningAlerts({Duration? period}) {
    return getAlertsByLevel(AlertLevel.warning, period: period);
  }

  /// Compte les alertes par métrique
  Map<String, int> getAlertCountsByMetric({Duration? period}) {
    final alerts = getRecentAlerts(period: period);
    final counts = <String, int>{};

    for (final alert in alerts) {
      counts[alert.metricName] = (counts[alert.metricName] ?? 0) + 1;
    }

    return counts;
  }

  /// Vérifie si une métrique est en état d'alerte
  bool isMetricInAlert(String metricName) {
    final recentAlerts = getRecentAlerts(period: const Duration(minutes: 5));
    return recentAlerts.any((alert) =>
        alert.metricName == metricName &&
        alert.level != AlertLevel.normal);
  }

  /// Obtient le niveau d'alerte actuel pour une métrique
  AlertLevel? getCurrentAlertLevel(String metricName) {
    final recentAlerts = getRecentAlerts(period: const Duration(minutes: 5));
    final metricAlerts = recentAlerts
        .where((alert) => alert.metricName == metricName)
        .toList();

    if (metricAlerts.isEmpty) return null;

    // Retourner le niveau le plus élevé
    metricAlerts.sort((a, b) => b.level.index.compareTo(a.level.index));
    return metricAlerts.first.level;
  }

  /// Efface l'historique des alertes
  void clearAlertsHistory() {
    final alertsCount = _recentAlerts.length;
    _recentAlerts.clear();

    LoggerService.instance.info(
      'Historique des alertes effacé: $alertsCount alertes supprimées',
      context: 'AlertingService',
    );
  }

  /// Supprime les gestionnaires d'alertes
  void removeAlertHandler(String metricName) {
    _handlers.remove(metricName);

    LoggerService.instance.info(
      'Gestionnaire d\'alerte supprimé pour $metricName',
      context: 'AlertingService',
    );
  }

  /// Supprime un seuil d'alerte
  void removeThreshold(String metricName) {
    _thresholds.remove(metricName);

    LoggerService.instance.info(
      'Seuil d\'alerte supprimé pour $metricName',
      context: 'AlertingService',
    );
  }

  /// Obtient tous les seuils configurés
  Map<String, AlertThreshold> getAllThresholds() {
    return Map.unmodifiable(_thresholds);
  }

  /// Génère un résumé des alertes
  Map<String, dynamic> generateAlertsSummary({Duration? period}) {
    final alerts = getRecentAlerts(period: period);
    final critical = alerts.where((a) => a.level == AlertLevel.critical).length;
    final warning = alerts.where((a) => a.level == AlertLevel.warning).length;

    return {
      'total_alerts': alerts.length,
      'critical_alerts': critical,
      'warning_alerts': warning,
      'period_hours': period?.inHours ?? 'all_time',
      'most_problematic_metrics': _getMostProblematicMetrics(alerts),
      'alert_frequency': _calculateAlertFrequency(alerts),
    };
  }

  /// Initialise les seuils par défaut
  void _initializeDefaultThresholds() {
    _thresholds.addAll({
      'operation_latency_ms': const AlertThreshold(warning: 1000, critical: 3000),
      'error_rate_percent': const AlertThreshold(warning: 5.0, critical: 15.0),
      'cache_hit_rate_percent': const AlertThreshold(warning: 60.0, critical: 40.0, inverse: true),
      'memory_usage_mb': const AlertThreshold(warning: 100.0, critical: 200.0),
      'pending_operations': const AlertThreshold(warning: 100, critical: 500),
    });

    LoggerService.instance.info(
      'Seuils par défaut initialisés: ${_thresholds.length} métriques',
      context: 'AlertingService',
    );
  }

  /// Démarre le nettoyage périodique des alertes
  void _startAlertsCleanup() {
    _alertsCleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupOldAlerts();
    });
  }

  /// Nettoie les alertes anciennes
  void _cleanupOldAlerts() {
    final cutoffTime = DateTime.now().subtract(const Duration(days: 7));
    final originalCount = _recentAlerts.length;

    _recentAlerts.removeWhere((alert) => alert.timestamp.isBefore(cutoffTime));

    final removedCount = originalCount - _recentAlerts.length;
    if (removedCount > 0) {
      LoggerService.instance.info(
        'Nettoyage des alertes anciennes: $removedCount alertes supprimées',
        context: 'AlertingService',
      );
    }
  }

  /// Maintient la taille de l'historique des alertes
  void _maintainAlertsHistory() {
    while (_recentAlerts.length > _maxAlertsHistory) {
      _recentAlerts.removeAt(0);
    }
  }

  /// Identifie les métriques les plus problématiques
  List<Map<String, dynamic>> _getMostProblematicMetrics(List<PerformanceAlert> alerts) {
    final metricIssues = <String, Map<String, int>>{};

    for (final alert in alerts) {
      metricIssues[alert.metricName] ??= {'critical': 0, 'warning': 0};

      if (alert.level == AlertLevel.critical) {
        metricIssues[alert.metricName]!['critical'] =
            metricIssues[alert.metricName]!['critical']! + 1;
      } else if (alert.level == AlertLevel.warning) {
        metricIssues[alert.metricName]!['warning'] =
            metricIssues[alert.metricName]!['warning']! + 1;
      }
    }

    final sortedMetrics = metricIssues.entries.toList()
      ..sort((a, b) {
        final scoreA = a.value['critical']! * 3 + a.value['warning']!;
        final scoreB = b.value['critical']! * 3 + b.value['warning']!;
        return scoreB.compareTo(scoreA);
      });

    return sortedMetrics.take(5).map((entry) => {
      'metric': entry.key,
      'critical_count': entry.value['critical'],
      'warning_count': entry.value['warning'],
      'total_score': entry.value['critical']! * 3 + entry.value['warning']!,
    }).toList();
  }

  /// Calcule la fréquence des alertes
  Map<String, double> _calculateAlertFrequency(List<PerformanceAlert> alerts) {
    if (alerts.isEmpty) return {};

    final oldestAlert = alerts.first.timestamp;
    final newestAlert = alerts.last.timestamp;
    final periodHours = newestAlert.difference(oldestAlert).inHours;

    if (periodHours == 0) return {};

    final frequencies = <String, double>{};
    final metricCounts = <String, int>{};

    for (final alert in alerts) {
      metricCounts[alert.metricName] = (metricCounts[alert.metricName] ?? 0) + 1;
    }

    for (final entry in metricCounts.entries) {
      frequencies[entry.key] = entry.value / periodHours;
    }

    return frequencies;
  }

  /// Dispose du service et nettoie les ressources
  void dispose() {
    _alertsCleanupTimer?.cancel();
    _handlers.clear();
    _thresholds.clear();
    _recentAlerts.clear();

    LoggerService.instance.info(
      'AlertingService disposé',
      context: 'AlertingService',
    );
  }
}

/// Seuil d'alerte pour une métrique
class AlertThreshold {
  final double warning;
  final double critical;
  final bool inverse;

  const AlertThreshold({
    required this.warning,
    required this.critical,
    this.inverse = false,
  });

  AlertLevel evaluateValue(double value) {
    if (inverse) {
      if (value <= critical) return AlertLevel.critical;
      if (value <= warning) return AlertLevel.warning;
      return AlertLevel.normal;
    } else {
      if (value >= critical) return AlertLevel.critical;
      if (value >= warning) return AlertLevel.warning;
      return AlertLevel.normal;
    }
  }
}

enum AlertLevel { normal, warning, critical }

class PerformanceAlert {
  final String metricName;
  final double currentValue;
  final AlertLevel level;
  final AlertThreshold threshold;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const PerformanceAlert({
    required this.metricName,
    required this.currentValue,
    required this.level,
    required this.threshold,
    required this.timestamp,
    this.context,
  });

  String get severity {
    switch (level) {
      case AlertLevel.warning: return 'WARNING';
      case AlertLevel.critical: return 'CRITICAL';
      case AlertLevel.normal: return 'NORMAL';
    }
  }
}