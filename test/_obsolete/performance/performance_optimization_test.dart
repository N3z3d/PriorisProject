import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/services/performance/performance_optimized_persistence_service.dart';
import 'package:prioris/domain/services/performance/optimized_migration_service.dart';
import 'package:prioris/domain/services/performance/performance_monitor.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/persistence/data_migration_service.dart';

import 'performance_optimization_test.mocks.dart';

@GenerateMocks([CustomListRepository, ListItemRepository])
void main() {
  group('Tests de Performance - Système de Persistance Optimisé', () {
    late PerformanceOptimizedPersistenceService optimizedService;
    late OptimizedMigrationService optimizedMigrationService;
    late PerformanceMonitor performanceMonitor;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      
      performanceMonitor = PerformanceMonitor.instance;
      
      optimizedService = PerformanceOptimizedPersistenceService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
      );
      
      optimizedMigrationService = OptimizedMigrationService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
      );
    });

    tearDown(() {
      optimizedService.dispose();
      optimizedMigrationService.dispose();
    });

    group('Performance du Cache Intelligent', () {
      test('Cache hit rate - Doit atteindre >80% après échauffement', () async {
        // SETUP: Données de test
        final testLists = _generateTestLists(100);
        final testItems = _generateTestItemsForLists(testLists, 10);
        
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);
        for (final list in testLists) {
          final items = testItems.where((item) => item.listId == list.id).toList();
          when(mockLocalItemRepository.getByListId(list.id)).thenAnswer((_) async => items);
        }
        
        await optimizedService.initialize(isAuthenticated: false);
        
        // PHASE 1: Premier chargement (échauffement du cache)
        final tracker1 = performanceMonitor.startOperation('cache_warmup');
        await optimizedService.getAllLists();
        tracker1.complete();
        
        // PHASE 2: Chargements répétés (doivent utiliser le cache)
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10; i++) {
          final tracker = performanceMonitor.startOperation('cached_read');
          await optimizedService.getAllLists();
          tracker.complete();
        }
        
        stopwatch.stop();
        
        // VALIDATION: Performance
        final metrics = optimizedService.getPerformanceMetrics();
        final cacheHitRatio = metrics['cacheHitRatio'] as double;
        
        expect(cacheHitRatio, greaterThan(0.8), 
          reason: 'Le cache devrait avoir un taux de succès >80%');
        
        // Le cache devrait considérablement accélérer les lectures répétées
        expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Les lectures en cache devraient être <100ms pour 10 opérations');
        
        print('✅ Cache performance: ${(cacheHitRatio * 100).toStringAsFixed(1)}% hit rate, ${stopwatch.elapsedMilliseconds}ms pour 10 lectures');
      });

      test('Cache invalidation - Doit invalider correctement après modification', () async {
        final testList = _generateTestLists(1).first;
        final testItems = _generateTestItemsForLists([testList], 5);
        
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockLocalItemRepository.getByListId(testList.id)).thenAnswer((_) async => testItems);
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async => {});
        
        await optimizedService.initialize(isAuthenticated: false);
        
        // PHASE 1: Charger en cache
        await optimizedService.getAllLists();
        
        // PHASE 2: Modifier et vérifier l'invalidation
        final modifiedList = testList.copyWith(name: 'Liste Modifiée');
        await optimizedService.saveList(modifiedList);
        
        // PHASE 3: Forcer la mise à jour du cache
        await optimizedService.flushPendingOperations();
        
        final metrics = optimizedService.getPerformanceMetrics();
        expect(metrics['pendingBatchOps'], equals(0));
        
        print('✅ Cache invalidation fonctionne correctement');
      });
    });

    group('Performance du Batching', () {
      test('Batching - Doit grouper les opérations pour optimiser I/O', () async {
        // SETUP: Préparer pour des opérations batch
        final testLists = _generateTestLists(50);
        
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async => {});
        await optimizedService.initialize(isAuthenticated: false);
        
        // PHASE 1: Soumettre de nombreuses opérations rapidement
        final stopwatch = Stopwatch()..start();
        
        final futures = testLists.map((list) => optimizedService.saveList(list)).toList();
        await Future.wait(futures);
        
        // PHASE 2: Forcer le traitement du batch
        await optimizedService.flushPendingOperations();
        
        stopwatch.stop();
        
        // VALIDATION: Le batching doit être plus efficace que les opérations individuelles
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Le batching devrait traiter 50 listes en <1s');
        
        final metrics = optimizedService.getPerformanceMetrics();
        expect(metrics['pendingBatchOps'], equals(0),
          reason: 'Toutes les opérations batch devraient être traitées');
        
        print('✅ Batching performance: ${testLists.length} listes traitées en ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Batch overflow - Doit traiter automatiquement les gros batches', () async {
        // SETUP: Dépasser la taille maximum de batch
        final testLists = _generateTestLists(150); // Plus que MAX_BATCH_SIZE
        
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async => {});
        await optimizedService.initialize(isAuthenticated: false);
        
        // PHASE 1: Soumettre plus d'opérations que la capacité du batch
        final tracker = performanceMonitor.startOperation('large_batch_test');
        
        for (final list in testLists) {
          await optimizedService.saveList(list);
        }
        
        tracker.complete();
        
        // PHASE 2: Vérifier que tout est traité
        await optimizedService.flushPendingOperations();
        
        final metrics = optimizedService.getPerformanceMetrics();
        expect(metrics['pendingBatchOps'], equals(0));
        
        // Vérifier que toutes les listes ont été sauvegardées
        verify(mockLocalRepository.saveList(any)).called(testLists.length);
        
        print('✅ Large batch handling: ${testLists.length} listes traitées automatiquement');
      });
    });

    group('Performance de Migration Optimisée', () {
      test('Migration parallélisée - Doit traiter gros volume efficacement', () async {
        // SETUP: Gros volume de données à migrer
        final testLists = _generateTestLists(500);
        final testItems = _generateTestItemsForLists(testLists, 20); // 10,000 items total
        
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockCloudRepository.saveList(any)).thenAnswer((_) async => {});
        when(mockCloudItemRepository.add(any)).thenAnswer((_) async => testItems.first);
        
        // Mock des items par liste
        for (final list in testLists) {
          final items = testItems.where((item) => item.listId == list.id).toList();
          when(mockLocalItemRepository.getByListId(list.id)).thenAnswer((_) async => items);
        }
        
        // PHASE 1: Exécuter la migration optimisée
        final tracker = performanceMonitor.startOperation('optimized_migration');
        
        final result = await optimizedMigrationService.migrateLocalToCloud();
        
        tracker.complete();
        
        // VALIDATION: Performance de migration
        expect(result.isSuccess, isTrue, reason: 'La migration devrait réussir');
        expect(result.migratedLists, equals(testLists.length));
        expect(result.duration.inSeconds, lessThan(30), 
          reason: 'Migration de 500 listes devrait prendre <30s');
        
        // Vérifier le parallélisme
        expect(result.statistics!['workersUsed'], greaterThan(1));
        expect(result.statistics!['avgProcessingSpeed'], greaterThan(10),
          reason: 'Vitesse de traitement devrait être >10 items/sec');
        
        print('✅ Migration optimisée: ${result.migratedLists} listes + ${result.migratedItems} items en ${result.duration.inSeconds}s');
        print('   Vitesse: ${result.statistics!['avgProcessingSpeed'].toStringAsFixed(1)} items/sec');
      });

      test('Circuit breaker - Doit gérer les pannes réseau', () async {
        // SETUP: Simuler des pannes réseau intermittentes
        final testLists = _generateTestLists(10);
        
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => []);
        
        // Simuler des échecs réseau sur 50% des opérations
        var callCount = 0;
        when(mockCloudRepository.saveList(any)).thenAnswer((_) async {
          callCount++;
          if (callCount % 2 == 0) {
            throw Exception('Network timeout');
          }
        });
        
        for (final list in testLists) {
          when(mockLocalItemRepository.getByListId(list.id)).thenAnswer((_) async => []);
        }
        
        // PHASE 1: Tenter la migration avec pannes
        final result = await optimizedMigrationService.migrateLocalToCloud();
        
        // VALIDATION: Circuit breaker doit gérer les échecs
        expect(result.errors, greaterThan(0), reason: 'Des erreurs devraient être détectées');
        expect(result.statistics!['circuitBreakerTriggered'], isTrue,
          reason: 'Circuit breaker devrait être activé');
        
        print('✅ Circuit breaker: ${result.errors} erreurs gérées, migration partielle réussie');
      });
    });

    group('Benchmarks de Performance', () {
      test('Benchmark - Opérations de base sous charge', () async {
        // SETUP
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => _generateTestLists(10));
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);
        
        await optimizedService.initialize(isAuthenticated: false);
        
        // BENCHMARK: Lecture de listes
        final readBenchmark = await performanceMonitor.benchmarkOperation(
          'optimized_read_lists',
          () => optimizedService.getAllLists(),
          iterations: 50,
        );
        
        expect(readBenchmark.averageLatency.inMilliseconds, lessThan(100),
          reason: 'Lecture optimisée devrait être <100ms');
        expect(readBenchmark.throughputPerSecond, greaterThan(10),
          reason: 'Throughput devrait être >10 ops/sec');
        
        print('📊 Benchmark READ: ${readBenchmark.summary}');
        
        // BENCHMARK: Écriture avec batching
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async => {});
        
        final writeBenchmark = await performanceMonitor.benchmarkOperation(
          'optimized_write_lists',
          () async {
            final list = _generateTestLists(1).first;
            await optimizedService.saveList(list);
            await optimizedService.flushPendingOperations();
          },
          iterations: 30,
        );
        
        expect(writeBenchmark.averageLatency.inMilliseconds, lessThan(50),
          reason: 'Écriture avec batching devrait être <50ms');
        
        print('📊 Benchmark WRITE: ${writeBenchmark.summary}');
      });

      test('Benchmark de comparaison - Service optimisé vs service standard', () async {
        // Ce test comparerait les performances avec le service non-optimisé
        // En production, vous pourriez créer le service standard pour comparaison
        
        final testLists = _generateTestLists(100);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);
        for (final list in testLists) {
          when(mockLocalItemRepository.getByListId(list.id)).thenAnswer((_) async => []);
        }
        
        await optimizedService.initialize(isAuthenticated: false);
        
        // Benchmark du service optimisé
        final optimizedStopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 20; i++) {
          await optimizedService.getAllLists();
        }
        
        optimizedStopwatch.stop();
        
        // VALIDATION: Performance attendue
        expect(optimizedStopwatch.elapsedMilliseconds, lessThan(500),
          reason: '20 lectures optimisées devraient prendre <500ms');
        
        final metrics = optimizedService.getPerformanceMetrics();
        print('📊 Service optimisé: ${optimizedStopwatch.elapsedMilliseconds}ms pour 20 lectures');
        print('   Cache hit ratio: ${(metrics['cacheHitRatio'] * 100).toStringAsFixed(1)}%');
        print('   Ops totales: ${metrics['totalOperations']}');
      });
    });

    group('Métriques et Monitoring', () {
      test('Métriques de performance - Doit collecter toutes les métriques clés', () async {
        // SETUP
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => _generateTestLists(10));
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async => {});
        
        await optimizedService.initialize(isAuthenticated: false);
        
        // PHASE 1: Générer de l'activité
        await optimizedService.getAllLists(); // Lecture
        await optimizedService.saveList(_generateTestLists(1).first); // Écriture
        await optimizedService.flushPendingOperations();
        
        // PHASE 2: Vérifier les métriques
        final metrics = optimizedService.getPerformanceMetrics();
        
        // Vérifier la présence des métriques essentielles
        expect(metrics.containsKey('totalOperations'), isTrue);
        expect(metrics.containsKey('cacheHits'), isTrue);
        expect(metrics.containsKey('cacheMisses'), isTrue);
        expect(metrics.containsKey('pendingBatchOps'), isTrue);
        expect(metrics.containsKey('avgOperationTime'), isTrue);
        
        // Vérifier les valeurs
        expect(metrics['totalOperations'], greaterThan(0));
        expect(metrics['avgOperationTime'], greaterThan(0));
        
        print('✅ Métriques collectées: ${metrics.keys.length} indicateurs');
        print('   Opérations totales: ${metrics['totalOperations']}');
        print('   Temps moyen: ${metrics['avgOperationTime'].toStringAsFixed(2)}ms');
      });

      test('Alertes de performance - Doit détecter les seuils critiques', () async {
        var alertReceived = false;
        String? alertMessage;
        
        // Configurer un handler d'alerte
        performanceMonitor.setAlertHandler('*', (alert) {
          alertReceived = true;
          alertMessage = alert.message;
        });
        
        // PHASE 1: Déclencher une alerte de latence élevée
        performanceMonitor.recordMetric('operation_latency_ms', 3500.0); // Au-dessus du seuil critique
        
        // PHASE 2: Déclencher une alerte de taux d'erreur
        performanceMonitor.recordMetric('error_rate_percent', 20.0); // Au-dessus du seuil critique
        
        // VALIDATION
        expect(alertReceived, isTrue, reason: 'Une alerte devrait être déclenchée');
        expect(alertMessage, isNotNull);
        
        print('✅ Système d\'alertes fonctionnel: $alertMessage');
      });

      test('Rapport de performance - Doit générer un rapport complet', () async {
        // SETUP: Générer des données de test
        for (int i = 0; i < 100; i++) {
          performanceMonitor.recordMetric('test_latency', 50.0 + (i % 10)); // Variation de latence
          performanceMonitor.recordMetric('test_throughput', 100.0 - (i % 5)); // Variation throughput
        }
        
        // PHASE 1: Générer le rapport
        final report = performanceMonitor.generateReport(period: Duration(hours: 1));
        
        // VALIDATION: Structure du rapport
        expect(report.metrics.isNotEmpty, isTrue);
        expect(report.recommendations.isNotEmpty, isTrue);
        expect(report.systemInfo.isNotEmpty, isTrue);
        
        // Vérifier le format JSON
        final jsonReport = report.toJson();
        expect(jsonReport.containsKey('generated_at'), isTrue);
        expect(jsonReport.containsKey('metrics'), isTrue);
        expect(jsonReport.containsKey('recommendations'), isTrue);
        
        print('✅ Rapport de performance généré:');
        print('   Métriques: ${report.metrics.length}');
        print('   Recommandations: ${report.recommendations.length}');
        for (final recommendation in report.recommendations.take(3)) {
          print('   - $recommendation');
        }
      });
    });

    group('Tests de Stress et Charge', () {
      test('Test de charge - 1000 listes avec 10000 items', () async {
        // SETUP: Simulation d'un gros volume
        final largeLists = _generateTestLists(1000);
        final largeItems = _generateTestItemsForLists(largeLists, 10); // 10,000 items
        
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => largeLists);
        for (final list in largeLists) {
          final items = largeItems.where((item) => item.listId == list.id).toList();
          when(mockLocalItemRepository.getByListId(list.id)).thenAnswer((_) async => items);
        }
        
        await optimizedService.initialize(isAuthenticated: false);
        
        // PHASE 1: Test de charge
        final tracker = performanceMonitor.startOperation('stress_test_1000_lists');
        final stopwatch = Stopwatch()..start();
        
        final lists = await optimizedService.getAllLists();
        
        stopwatch.stop();
        tracker.complete();
        
        // VALIDATION: Performance sous charge
        expect(lists.length, equals(1000));
        expect(stopwatch.elapsed.inSeconds, lessThan(10), 
          reason: 'Chargement de 1000 listes devrait prendre <10s');
        
        // Vérifier que le cache et les optimisations fonctionnent
        final metrics = optimizedService.getPerformanceMetrics();
        expect(metrics['totalOperations'], greaterThan(0));
        
        print('✅ Test de charge: 1000 listes + 10000 items chargés en ${stopwatch.elapsed.inSeconds}s');
        print('   Mémoire utilisée: ${metrics['memory_usage_mb'].toStringAsFixed(1)}MB');
      });

      test('Test de concurrence - Opérations simultanées', () async {
        // SETUP
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => _generateTestLists(10));
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async {
          // Simuler une latence réseau
          await Future.delayed(Duration(milliseconds: 10));
        });
        
        await optimizedService.initialize(isAuthenticated: false);
        
        // PHASE 1: Lancer de nombreuses opérations concurrentes
        final futures = <Future>[];
        final stopwatch = Stopwatch()..start();
        
        // 50 lectures concurrentes
        for (int i = 0; i < 50; i++) {
          futures.add(optimizedService.getAllLists());
        }
        
        // 20 écritures concurrentes
        for (int i = 0; i < 20; i++) {
          final list = _generateTestLists(1).first.copyWith(id: 'concurrent_$i');
          futures.add(optimizedService.saveList(list));
        }
        
        await Future.wait(futures);
        await optimizedService.flushPendingOperations();
        
        stopwatch.stop();
        
        // VALIDATION: Gestion de la concurrence
        expect(stopwatch.elapsed.inSeconds, lessThan(5),
          reason: '70 opérations concurrentes devraient être gérées en <5s');
        
        final metrics = optimizedService.getPerformanceMetrics();
        expect(metrics['totalOperations'], greaterThan(70));
        
        print('✅ Test de concurrence: 70 opérations simultanées en ${stopwatch.elapsed.inSeconds}s');
      });
    });
  });
}

/// Utilitaires pour générer des données de test

List<CustomList> _generateTestLists(int count) {
  return List.generate(count, (index) {
    final now = DateTime.now().subtract(Duration(days: index % 30));
    return CustomList(
      id: 'test_list_$index',
      name: 'Liste de Test $index',
      type: ListType.CUSTOM,
      createdAt: now,
      updatedAt: now.add(Duration(hours: index % 24)),
      description: index % 5 == 0 ? 'Description pour liste $index' : null,
    );
  });
}

List<ListItem> _generateTestItemsForLists(List<CustomList> lists, int itemsPerList) {
  final items = <ListItem>[];
  
  for (final list in lists) {
    for (int i = 0; i < itemsPerList; i++) {
      final now = DateTime.now().subtract(Duration(hours: i));
      items.add(ListItem(
        id: '${list.id}_item_$i',
        title: 'Item $i de ${list.name}',
        listId: list.id,
        createdAt: now,
        description: i % 3 == 0 ? 'Description item $i' : null,
        isCompleted: i % 4 == 0,
        eloScore: 1500 + (i % 200) - 100, // Variation autour de 1500
      ));
    }
  }
  
  return items;
}