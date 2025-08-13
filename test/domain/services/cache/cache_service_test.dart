import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:prioris/domain/services/cache/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;
    
    setUpAll(() async {
      await setUpTestHive();
    });
    
    setUp(() async {
      cacheService = CacheService();
      await cacheService.initialize();
    });
    
    tearDown(() async {
      try {
        await cacheService.clear();
      } catch (_) {
        // Ignorer si déjà fermé
      }
    });
    
    tearDownAll(() async {
      await Hive.close();
    });
    
    group('Initialisation', () {
      test('should initialize successfully', () async {
        expect(cacheService, isNotNull);
        final stats = await cacheService.getStats();
        expect(stats.totalEntries, 0);
        expect(stats.hitRate, 0.0);
      });
      
      test('should handle multiple initializations', () async {
        final service1 = CacheService();
        final service2 = CacheService();
        
        await service1.initialize();
        await service2.initialize();
        
        await service1.dispose();
        await service2.dispose();
      });
    });
    
    group('Opérations de base', () {
      test('should set and get string value', () async {
        const key = 'test_string';
        const value = 'Hello World';
        
        await cacheService.set(key, value);
        final result = await cacheService.get<String>(key);
        
        expect(result, equals(value));
      });
      
      test('should set and get complex object', () async {
        const key = 'test_map';
        final value = {
          'id': 'test-id',
          'name': 'Test List',
          'type': 'SHOPPING',
          'items': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        await cacheService.set(key, value);
        final result = await cacheService.get<Map<String, dynamic>>(key);
        
        expect(result, isNotNull);
        expect(result!['id'], equals(value['id']));
        expect(result['name'], equals(value['name']));
        expect(result['type'], equals(value['type']));
      });
      
      test('should handle null values', () async {
        const key = 'test_null';
        
        await cacheService.set(key, null);
        final result = await cacheService.get(key);
        
        expect(result, isNull);
      });
      
      test('should remove entry', () async {
        const key = 'test_remove';
        const value = 'test';
        
        await cacheService.set(key, value);
        expect(await cacheService.exists(key), isTrue);
        
        await cacheService.remove(key);
        expect(await cacheService.exists(key), isFalse);
      });
      
      test('should clear all entries', () async {
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        
        expect(await cacheService.getStats(), predicate<CacheStats>(
          (stats) => stats.totalEntries == 2,
        ));
        
        await cacheService.clear();
        
        final stats = await cacheService.getStats();
        expect(stats.totalEntries, 0);
        expect(stats.totalSize, 0);
      });
    });
    
    group('TTL et expiration', () {
      test('should respect TTL', () async {
        const key = 'test_ttl';
        const value = 'test';
        
        await cacheService.set(key, value, ttl: Duration(milliseconds: 100));
        expect(await cacheService.get(key), equals(value));
        
        // Attendre l'expiration
        await Future.delayed(Duration(milliseconds: 150));
        
        expect(await cacheService.get(key), isNull);
        expect(await cacheService.exists(key), isFalse);
      });
      
      test('should handle different TTL values', () async {
        await cacheService.set('key1', 'value1', ttl: Duration(seconds: 1));
        await cacheService.set('key2', 'value2', ttl: Duration(hours: 1));
        
        await Future.delayed(Duration(milliseconds: 1100));
        
        expect(await cacheService.get('key1'), isNull);
        expect(await cacheService.get('key2'), equals('value2'));
      });
      
      test('should cleanup expired entries', () async {
        await cacheService.set('expired1', 'value1', ttl: Duration(milliseconds: 50));
        await cacheService.set('expired2', 'value2', ttl: Duration(milliseconds: 50));
        await cacheService.set('valid', 'value3', ttl: Duration(hours: 1));
        
        await Future.delayed(Duration(milliseconds: 100));
        await cacheService.cleanup();
        
        expect(await cacheService.get('expired1'), isNull);
        expect(await cacheService.get('expired2'), isNull);
        expect(await cacheService.get('valid'), equals('value3'));
      });
    });
    
    group('Compression', () {
      test('should compress large strings', () async {
        const key = 'test_compression';
        final largeString = 'x' * 2000; // String de 2000 caractères
        
        await cacheService.set(key, largeString, compress: true);
        final result = await cacheService.get<String>(key);
        
        expect(result, equals(largeString));
      });
      
      test('should not compress small strings', () async {
        const key = 'test_no_compression';
        const smallString = 'Hello'; // String de 5 caractères
        
        await cacheService.set(key, smallString, compress: true);
        final result = await cacheService.get<String>(key);
        
        expect(result, equals(smallString));
      });
      
      test('should handle compression disabled', () async {
        const key = 'test_no_compression_disabled';
        final largeString = 'x' * 2000;
        
        await cacheService.set(key, largeString, compress: false);
        final result = await cacheService.get<String>(key);
        
        expect(result, equals(largeString));
      });
    });
    
    group('Limite de taille', () {
      test('should enforce size limit', () async {
        // Remplir le cache au-delà de la limite
        for (int i = 0; i < 1100; i++) {
          await cacheService.set('key$i', 'value$i');
        }
        
        final stats = await cacheService.getStats();
        expect(stats.totalEntries, lessThanOrEqualTo(1000));
      });
      
      test('should remove least recently used entries', () async {
        // Créer des entrées avec des temps d'accès différents
        await cacheService.set('old1', 'value1');
        await cacheService.set('old2', 'value2');
        
        await Future.delayed(Duration(milliseconds: 10));
        
        await cacheService.set('recent1', 'value3');
        await cacheService.set('recent2', 'value4');
        
        // Accéder aux entrées récentes pour mettre à jour leur temps d'accès
        await cacheService.get('recent1');
        await cacheService.get('recent2');
        
        // Remplir le cache pour déclencher la suppression LRU
        for (int i = 0; i < 1000; i++) {
          await cacheService.set('key$i', 'value$i');
        }
        
        // Les entrées anciennes devraient être supprimées
        expect(await cacheService.get('old1'), isNull);
        expect(await cacheService.get('old2'), isNull);
      });
    });
    
    group('Statistiques', () {
      test('should track operations correctly', () async {
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        await cacheService.get('key1');
        await cacheService.get('key2');
        await cacheService.get('nonexistent');
        
        final stats = await cacheService.getStats();
        
        expect(stats.totalEntries, 2);
        expect(stats.hitRate, greaterThan(0.0));
        expect(stats.lastCleanup, isNotNull);
      });
      
      test('should calculate hit rate correctly', () async {
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        
        // 2 gets réussis, 1 échoué
        await cacheService.get('key1');
        await cacheService.get('key2');
        await cacheService.get('nonexistent');
        
        final stats = await cacheService.getStats();
        expect(stats.hitRate, closeTo(0.67, 0.1)); // 2/3 = 0.67
      });
      
      test('should track disk usage', () async {
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        
        final stats = await cacheService.getStats();
        expect(stats.diskUsageMB, greaterThan(0.0));
        expect(stats.totalSize, greaterThan(0));
      });
    });
    
    group('Optimisation', () {
      test('should optimize when disk usage is high', () async {
        // Créer beaucoup de données pour simuler un usage élevé
        for (int i = 0; i < 500; i++) {
          await cacheService.set('key$i', 'x' * 1000); // 1KB par entrée
        }
        
        await cacheService.optimize();
        
        final stats = await cacheService.getStats();
        expect(stats.diskUsageMB, lessThan(50.0)); // Limite de 50MB
      });
    });
    
    group('Gestion d\'erreurs', () {
      test('should handle errors gracefully', () async {
        // Tester avec des données valides
        await cacheService.set('valid', {'test': 'data'}); // Objet sérialisable
        
        // Le service ne devrait pas planter
        expect(cacheService, isNotNull);
      });
      
      test('should handle concurrent access', () async {
        final futures = <Future>[];
        
        for (int i = 0; i < 10; i++) {
          futures.add(cacheService.set('key$i', 'value$i'));
        }
        
        await Future.wait(futures);
        
        final stats = await cacheService.getStats();
        expect(stats.totalEntries, 10);
      });
    });
    
    group('Performance', () {
      test('should handle large number of operations quickly', () async {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          await cacheService.set('key$i', 'value$i');
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // < 5 secondes
      });
      
      test('should retrieve data quickly', () async {
        await cacheService.set('test', 'value');
        
        final stopwatch = Stopwatch()..start();
        await cacheService.get('test');
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // < 100ms
      });
    });
  });
} 

