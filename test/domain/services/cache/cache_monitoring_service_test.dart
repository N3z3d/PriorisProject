import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:prioris/domain/services/cache/cache_service.dart';
import 'package:prioris/domain/services/cache/cache_monitoring_service.dart';

void main() {
  group('CacheMonitoringService', () {
    late CacheService cacheService;
    late CacheMonitoringService monitoringService;
    
    setUpAll(() async {
      await setUpTestHive();
    });
    
    setUp(() async {
      cacheService = CacheService();
      await cacheService.initialize();
      monitoringService = CacheMonitoringService(cacheService);
    });
    
    tearDown(() async {
      monitoringService.dispose();
      await cacheService.clear();
      await cacheService.dispose();
    });
    
    tearDownAll(() async {
      await Hive.close();
    });
    
    group('Initialisation', () {
      test('should initialize correctly', () {
        expect(monitoringService, isNotNull);
        expect(monitoringService.metricsHistory, isEmpty);
        expect(monitoringService.alertsHistory, isEmpty);
      });
      
      test('should provide streams', () {
        expect(monitoringService.metricsStream, isNotNull);
        expect(monitoringService.alertsStream, isNotNull);
      });
    });
    
    group('Monitoring', () {
      test('should start and stop monitoring', () async {
        expect(monitoringService.metricsHistory, isEmpty);
        
        await monitoringService.startMonitoring(interval: Duration(milliseconds: 100));
        await Future.delayed(Duration(milliseconds: 150));
        
        expect(monitoringService.metricsHistory, isNotEmpty);
        
        monitoringService.stopMonitoring();
        final initialCount = monitoringService.metricsHistory.length;
        
        await Future.delayed(Duration(milliseconds: 150));
        
        expect(monitoringService.metricsHistory.length, equals(initialCount));
      });
      
      test('should collect metrics correctly', () async {
        // Ajouter des données au cache
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        await cacheService.get('key1');
        await cacheService.get('nonexistent');
        
        final metrics = await monitoringService.collectCurrentMetrics();
        
        expect(metrics.totalEntries, 2);
        expect(metrics.hitRate, greaterThan(0.0));
        expect(metrics.timestamp, isNotNull);
        expect(metrics.diskUsageMB, greaterThan(0.0));
      });
      
      test('should limit metrics history', () async {
        await monitoringService.startMonitoring(interval: Duration(milliseconds: 10));
        
        // Attendre plus de 1000 métriques
        await Future.delayed(Duration(milliseconds: 11000));
        
        expect(monitoringService.metricsHistory.length, lessThanOrEqualTo(1000));
      });
    });
    
    group('Alertes', () {
      test('should generate disk usage alerts', () async {
        // Créer beaucoup de données pour déclencher l'alerte
        for (int i = 0; i < 100; i++) {
          await cacheService.set('key$i', 'x' * 1000); // 1KB par entrée
        }
        
        final metrics = await monitoringService.collectCurrentMetrics();
        final alerts = <CacheAlert>[];
        
        monitoringService.alertsStream.listen(alerts.add);
        
        await Future.delayed(Duration(milliseconds: 100));
        
        if (metrics.diskUsageMB > 40) {
          expect(alerts.any((a) => a.type == CacheAlertType.diskUsage), isTrue);
        }
      });
      
      test('should generate hit rate alerts', () async {
        // Créer des accès qui vont générer un hit rate faible
        await cacheService.set('key1', 'value1');
        await cacheService.get('nonexistent1');
        await cacheService.get('nonexistent2');
        await cacheService.get('nonexistent3');
        
        final alerts = <CacheAlert>[];
        monitoringService.alertsStream.listen(alerts.add);
        
        await monitoringService.collectCurrentMetrics();
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(alerts.any((a) => a.type == CacheAlertType.hitRate), isTrue);
      });
      
      test('should record errors', () {
        final alerts = <CacheAlert>[];
        monitoringService.alertsStream.listen(alerts.add);
        
        monitoringService.recordError('test_operation', 'test_error');
        
        expect(alerts.length, 1);
        expect(alerts.first.type, CacheAlertType.error);
        expect(alerts.first.message, contains('test_operation'));
        expect(alerts.first.message, contains('test_error'));
      });
      
      test('should track error count correctly', () {
        // Enregistrer plusieurs erreurs
        for (int i = 0; i < 10; i++) {
          monitoringService.recordError('operation$i', 'error$i');
        }
        
        expect(monitoringService.alertsHistory.length, 10);
      });
    });
    
    group('Rapports de performance', () {
      test('should generate performance report', () async {
        // Créer des données de test
        for (int i = 0; i < 10; i++) {
          await cacheService.set('key$i', 'value$i');
          await cacheService.get('key$i');
        }
        
        // Collecter plusieurs métriques
        for (int i = 0; i < 5; i++) {
          await monitoringService.collectCurrentMetrics();
          await Future.delayed(Duration(milliseconds: 10));
        }
        
        final report = await monitoringService.generateReport(
          period: Duration(minutes: 1),
        );
        
        expect(report.period, Duration(minutes: 1));
        expect(report.averageHitRate, greaterThan(0.0));
        expect(report.averageLatency, isNotNull);
        expect(report.totalOperations, greaterThan(0));
        expect(report.recommendations, isNotEmpty);
      });
      
      test('should handle empty report period', () async {
        final report = await monitoringService.generateReport(
          period: Duration(milliseconds: 1),
        );
        
        expect(report.averageHitRate, 0.0);
        expect(report.totalOperations, 0);
        expect(report.recommendations, isEmpty);
      });
      
      test('should analyze trends correctly', () async {
        // Créer des métriques avec une tendance dégradante
        for (int i = 0; i < 10; i++) {
          await cacheService.set('key$i', 'value$i');
        }
        
        // Collecter des métriques sur une période
        for (int i = 0; i < 10; i++) {
          await monitoringService.collectCurrentMetrics();
          await Future.delayed(Duration(milliseconds: 10));
        }
        
        final report = await monitoringService.generateReport(
          period: Duration(minutes: 1),
        );
        
        expect(report.trend, isNotNull);
      });
    });
    
    group('Vérification de santé', () {
      test('should check health correctly', () async {
        final health = await monitoringService.checkHealth();
        
        expect(health.isHealthy, isNotNull);
        expect(health.lastCheck, isNotNull);
        expect(health.metrics, isNotNull);
        expect(health.issues, isList);
      });
      
      test('should detect unhealthy state', () async {
        // Créer une situation malsaine
        for (int i = 0; i < 10; i++) {
          monitoringService.recordError('operation$i', 'error$i');
        }
        
        final health = await monitoringService.checkHealth();
        
        expect(health.issues, isNotEmpty);
      });
    });
    
    group('Streams', () {
      test('should emit metrics through stream', () async {
        final metrics = <CacheMetrics>[];
        monitoringService.metricsStream.listen(metrics.add);
        
        await monitoringService.collectCurrentMetrics();
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(metrics, isNotEmpty);
        expect(metrics.first, isA<CacheMetrics>());
      });
      
      test('should emit alerts through stream', () async {
        final alerts = <CacheAlert>[];
        monitoringService.alertsStream.listen(alerts.add);
        
        monitoringService.recordError('test', 'error');
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(alerts, isNotEmpty);
        expect(alerts.first, isA<CacheAlert>());
      });
    });
    
    group('Dispose', () {
      test('should dispose correctly', () {
        expect(() => monitoringService.dispose(), returnsNormally);
      });
      
      test('should not emit after dispose', () async {
        final metrics = <CacheMetrics>[];
        monitoringService.metricsStream.listen(metrics.add);
        
        monitoringService.dispose();
        
        await monitoringService.collectCurrentMetrics();
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(metrics, isEmpty);
      });
    });
    
    group('Performance', () {
      test('should handle rapid metric collection', () async {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          await monitoringService.collectCurrentMetrics();
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // < 5 secondes
      });
      
      test('should handle concurrent monitoring', () async {
        final futures = <Future>[];
        
        for (int i = 0; i < 10; i++) {
          futures.add(monitoringService.collectCurrentMetrics());
        }
        
        await Future.wait(futures);
        
        expect(monitoringService.metricsHistory.length, 10);
      });
    });
  });
} 
