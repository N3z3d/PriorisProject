# GUIDE D'INTÉGRATION DÉVELOPPEUR - SYSTÈME DE PERSISTANCE ADAPTATIVE

## 🚀 DÉMARRAGE RAPIDE

### Prérequis
- **Flutter** : 3.16.0+
- **Dart** : 3.2.0+
- **IDE** : VS Code avec extensions Flutter/Dart ou Android Studio
- **Git** : Pour le contrôle de version
- **Compte Supabase** : Pour la synchronisation cloud

### Installation en 5 Minutes

#### 1. Cloner le Projet
```bash
git clone https://github.com/your-org/prioris.git
cd prioris
```

#### 2. Configuration Environnement
```bash
# Copier le template de configuration
cp .env.example .env

# Modifier .env avec vos clés Supabase
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your-anon-key-here
```

#### 3. Installation Dépendances
```bash
flutter pub get
flutter packages pub run build_runner build
```

#### 4. Lancement de l'App
```bash
flutter run
```

#### 5. Validation Rapide
```bash
# Lancer les tests essentiels
flutter test test/integration/adaptive_persistence_integration_test.dart
flutter test test/domain/services/persistence/adaptive_persistence_service_test.dart
```

---

## 🏗️ INTÉGRATION DU SYSTÈME DE PERSISTANCE

### Configuration Initiale

#### 1. Configuration du Service Principal
**Fichier** : `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialisation configuration
  await AppConfig.initialize(AppEnvironment.development);
  
  // 2. Initialisation services persistance
  await PersistenceBootstrap.initialize();
  
  // 3. Configuration monitoring
  PerformanceMonitor.instance.configure(
    enabledInDebug: true,
    alertThresholds: AlertThresholds.development(),
  );
  
  runApp(const PriorisApp());
}

class PersistenceBootstrap {
  static Future<void> initialize() async {
    // Initialisation Hive
    await Hive.initFlutter();
    Hive.registerAdapter(CustomListAdapter());
    Hive.registerAdapter(ListItemAdapter());
    
    // Initialisation Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    
    // Configuration DI
    await DependencyInjection.configure();
  }
}
```

#### 2. Injection de Dépendances
**Fichier** : `lib/infrastructure/di/dependency_injection.dart`

```dart
class DependencyInjection {
  static Future<void> configure() async {
    final getIt = GetIt.instance;
    
    // Services de base
    getIt.registerSingleton<PerformanceMonitor>(PerformanceMonitor.instance);
    getIt.registerSingleton<CacheService>(LRUCacheService(maxSize: AppConfig.cacheSize));
    
    // Repositories
    getIt.registerLazySingleton<CustomListRepository>(() => 
      HiveCustomListRepository(
        box: Hive.box<Map>('custom_lists'),
        performanceMonitor: getIt<PerformanceMonitor>(),
      )
    );
    
    getIt.registerLazySingleton<SupabaseCustomListRepository>(() =>
      SupabaseCustomListRepository(
        client: Supabase.instance.client,
        performanceMonitor: getIt<PerformanceMonitor>(),
      )
    );
    
    // Service principal adaptatif
    getIt.registerLazySingleton<AdaptivePersistenceService>(() =>
      AdaptivePersistenceService(
        localRepository: getIt<CustomListRepository>(),
        cloudRepository: getIt<SupabaseCustomListRepository>(),
        cacheService: getIt<CacheService>(),
        performanceMonitor: getIt<PerformanceMonitor>(),
      )
    );
    
    // Service optimisé pour production
    if (AppConfig.isProduction) {
      getIt.registerLazySingleton<PerformanceOptimizedPersistenceService>(() =>
        PerformanceOptimizedPersistenceService(
          localRepository: getIt<CustomListRepository>(),
          cloudRepository: getIt<SupabaseCustomListRepository>(),
          // Configuration haute performance
          cacheConfig: CacheConfiguration(
            maxSize: 2000,
            ttl: Duration(minutes: 15),
            compressionEnabled: true,
          ),
          batchConfig: BatchConfiguration(
            size: 100,
            flushInterval: Duration(milliseconds: 50),
          ),
        )
      );
    }
  }
}
```

### Utilisation dans vos Controllers

#### Contrôleur Adaptatif Simple
```dart
class MyListsController extends StateNotifier<ListsState> {
  final AdaptivePersistenceService _persistenceService;
  
  MyListsController() : 
    _persistenceService = GetIt.instance<AdaptivePersistenceService>(),
    super(const ListsState.initial());
  
  // Chargement adaptatif automatique
  Future<void> loadLists() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final lists = await _persistenceService.getAllLists(
        strategy: PersistenceStrategy.ADAPTIVE, // Choix automatique
      );
      
      state = state.copyWith(
        lists: lists,
        isLoading: false,
        syncStatus: _persistenceService.lastSyncStatus,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: AdaptiveError.fromException(error),
      );
    }
  }
  
  // Création avec sync automatique
  Future<void> createList(String name, {String? description}) async {
    try {
      final newList = CustomList.create(
        name: name,
        description: description,
        type: ListType.todo,
      );
      
      await _persistenceService.saveCustomList(
        newList,
        syncStrategy: SyncStrategy.IMMEDIATE, // Sync immédiate
      );
      
      // Rafraîchir la liste
      await loadLists();
    } catch (error) {
      // Gestion d'erreur avec feedback utilisateur
      _handleError(error);
    }
  }
}
```

#### Contrôleur Haute Performance
```dart
class HighPerformanceListsController extends StateNotifier<ListsState> {
  final PerformanceOptimizedPersistenceService _optimizedService;
  
  HighPerformanceListsController() : 
    _optimizedService = GetIt.instance<PerformanceOptimizedPersistenceService>(),
    super(const ListsState.initial());
  
  // Chargement optimisé avec cache intelligent
  Future<void> loadListsOptimized() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Le service gère automatiquement :
      // - Cache LRU avec TTL
      // - Batching des opérations
      // - Compression des données
      // - Pool de connexions
      final lists = await _optimizedService.getAllLists();
      
      state = state.copyWith(
        lists: lists,
        isLoading: false,
        performanceMetrics: _optimizedService.getPerformanceMetrics(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: AdaptiveError.fromException(error),
      );
    }
  }
  
  // Opérations batch pour gros volumes
  Future<void> bulkCreateLists(List<String> names) async {
    try {
      final newLists = names.map((name) => CustomList.create(
        name: name,
        type: ListType.todo,
      )).toList();
      
      // Sauvegarde batch automatique (50 opérations par batch)
      await _optimizedService.bulkSaveLists(newLists);
      
      await loadListsOptimized();
    } catch (error) {
      _handleError(error);
    }
  }
}
```

---

## 🔧 CONFIGURATION AVANCÉE

### Stratégies de Persistance Configurables

#### Configuration par Environnement
```dart
class PersistenceConfiguration {
  static PersistenceConfig forEnvironment(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.development:
        return PersistenceConfig(
          defaultStrategy: PersistenceStrategy.LOCAL_FIRST,
          cacheSize: 500,
          syncInterval: Duration(minutes: 5),
          enableDetailedLogging: true,
        );
      
      case AppEnvironment.staging:
        return PersistenceConfig(
          defaultStrategy: PersistenceStrategy.ADAPTIVE,
          cacheSize: 1000,
          syncInterval: Duration(minutes: 2),
          enablePerformanceMonitoring: true,
        );
      
      case AppEnvironment.production:
        return PersistenceConfig(
          defaultStrategy: PersistenceStrategy.ADAPTIVE,
          cacheSize: 2000,
          syncInterval: Duration(minutes: 1),
          enablePerformanceMonitoring: true,
          enableCompression: true,
          batchSize: 100,
        );
    }
  }
}
```

#### Configuration Runtime Adaptative
```dart
class AdaptiveConfiguration {
  static PersistenceStrategy adaptStrategy({
    required ConnectivityResult connectivity,
    required DeviceInfo device,
    required UserPreferences preferences,
  }) {
    // Mode hors ligne forcé
    if (connectivity == ConnectivityResult.none) {
      return PersistenceStrategy.LOCAL_ONLY;
    }
    
    // Appareil low-end ou données limitées
    if (device.isLowEnd || preferences.dataSaverMode) {
      return PersistenceStrategy.LOCAL_FIRST;
    }
    
    // Wi-Fi haute vitesse
    if (connectivity == ConnectivityResult.wifi && device.isHighEnd) {
      return PersistenceStrategy.CLOUD_FIRST;
    }
    
    // Configuration adaptative par défaut
    return PersistenceStrategy.ADAPTIVE;
  }
}
```

### Migration de Données

#### Service de Migration Automatique
```dart
class DataMigrationGuide {
  static Future<void> migrateFromLegacySystem() async {
    final migrationService = DataMigrationService(
      localRepository: GetIt.instance<CustomListRepository>(),
      cloudRepository: GetIt.instance<SupabaseCustomListRepository>(),
    );
    
    // 1. Détection des données legacy
    final hasLegacyData = await migrationService.detectLegacyData();
    if (!hasLegacyData) return;
    
    // 2. Sauvegarde avant migration
    await migrationService.createBackup();
    
    try {
      // 3. Migration progressive avec feedback
      await migrationService.migrateData(
        onProgress: (current, total) {
          print('Migration: $current/$total');
        },
        batchSize: 50, // Traitement par lots
      );
      
      // 4. Validation des données migrées
      final validationResults = await migrationService.validateMigration();
      if (!validationResults.isValid) {
        throw MigrationException('Migration validation failed: ${validationResults.issues}');
      }
      
      // 5. Nettoyage des données legacy
      await migrationService.cleanupLegacyData();
      
    } catch (error) {
      // 6. Rollback en cas d'échec
      await migrationService.rollbackMigration();
      rethrow;
    }
  }
}
```

---

## 📊 MONITORING ET DEBUGGING

### Configuration du Monitoring

#### Setup Development
```dart
void setupDevelopmentMonitoring() {
  final monitor = PerformanceMonitor.instance;
  
  // Seuils d'alerte pour développement
  monitor.configureAlerts([
    AlertRule(
      name: 'high_latency_dev',
      condition: (metrics) => metrics.averageLatency.inMilliseconds > 500,
      severity: AlertSeverity.warning,
    ),
    AlertRule(
      name: 'cache_miss_dev',
      condition: (metrics) => metrics.cacheHitRate < 0.5,
      severity: AlertSeverity.info,
    ),
  ]);
  
  // Handler d'alertes pour développement
  monitor.alerts.listen((alert) {
    print('🚨 Performance Alert: ${alert.rule.name}');
    print('   Operation: ${alert.operationName}');
    print('   Details: ${alert.details}');
    
    // En développement, afficher dans l'UI
    if (kDebugMode) {
      _showDebugAlert(alert);
    }
  });
}
```

#### Dashboard Intégré
```dart
class PerformanceDashboardWidget extends StatelessWidget {
  const PerformanceDashboardWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PerformanceReport>(
      stream: PerformanceMonitor.instance.reportStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        final report = snapshot.data!;
        
        return Column(
          children: [
            // Métriques principales
            Row(
              children: [
                MetricCard(
                  title: 'Avg Latency',
                  value: '${report.averageLatency.inMilliseconds}ms',
                  color: _getLatencyColor(report.averageLatency),
                ),
                MetricCard(
                  title: 'Cache Hit Rate',
                  value: '${(report.cacheHitRate * 100).toInt()}%',
                  color: _getCacheColor(report.cacheHitRate),
                ),
                MetricCard(
                  title: 'Error Rate',
                  value: '${(report.errorRate * 100).toInt()}%',
                  color: _getErrorColor(report.errorRate),
                ),
              ],
            ),
            
            // Graphiques temps réel
            PerformanceChart(data: report.operationMetrics),
            
            // Recommandations
            if (report.recommendations.isNotEmpty)
              RecommendationsPanel(recommendations: report.recommendations),
          ],
        );
      },
    );
  }
}
```

### Debugging Avancé

#### Logs Structurés
```dart
class AdaptiveLogger {
  static const _logger = Logger('AdaptivePersistence');
  
  static void logOperation(
    String operation,
    Duration duration,
    Map<String, dynamic> context,
  ) {
    _logger.info('Operation: $operation', {
      'duration_ms': duration.inMilliseconds,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static void logError(
    String operation,
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) {
    _logger.severe('Error in $operation: $error', error, stackTrace);
    
    // En développement, crash analytics
    if (kDebugMode) {
      CrashAnalytics.recordError(
        error,
        stackTrace,
        context: {
          'operation': operation,
          ...context,
        },
      );
    }
  }
}
```

#### Outils de Debug
```dart
class PersistenceDebugTools {
  // Inspection de l'état du cache
  static Map<String, dynamic> inspectCache() {
    final cacheService = GetIt.instance<CacheService>();
    
    return {
      'size': cacheService.size,
      'hit_rate': cacheService.hitRate,
      'entries': cacheService.keys.take(10).toList(),
      'memory_usage_mb': cacheService.memoryUsageMB,
    };
  }
  
  // Simulation de pannes réseau
  static void simulateNetworkFailure(Duration duration) {
    final cloudRepository = GetIt.instance<SupabaseCustomListRepository>();
    cloudRepository.simulateFailure(duration);
  }
  
  // Réinitialisation complète du cache
  static Future<void> resetAllCaches() async {
    final cacheService = GetIt.instance<CacheService>();
    await cacheService.clear();
    
    final persistenceService = GetIt.instance<AdaptivePersistenceService>();
    await persistenceService.invalidateAllCaches();
  }
  
  // Génération de données de test
  static Future<void> generateTestData(int count) async {
    final persistenceService = GetIt.instance<AdaptivePersistenceService>();
    
    for (int i = 0; i < count; i++) {
      final testList = CustomList.create(
        name: 'Test List $i',
        description: 'Generated test data #$i',
        type: ListType.todo,
      );
      
      await persistenceService.saveCustomList(testList);
    }
  }
}
```

---

## 🧪 TESTS ET VALIDATION

### Tests d'Intégration Rapides

#### Test de Base du Système
```dart
// test/integration/quick_integration_test.dart
void main() {
  group('Quick Integration Tests', () {
    late AdaptivePersistenceService service;
    
    setUpAll(() async {
      await TestUtils.initializeTestEnvironment();
      service = GetIt.instance<AdaptivePersistenceService>();
    });
    
    testWidgets('Basic CRUD operations work', (tester) async {
      // Create
      final testList = CustomList.create(
        name: 'Integration Test List',
        type: ListType.todo,
      );
      
      await service.saveCustomList(testList);
      
      // Read
      final retrievedLists = await service.getAllLists();
      expect(retrievedLists, hasLength(greaterThan(0)));
      
      final foundList = retrievedLists.firstWhere(
        (l) => l.name == testList.name,
      );
      expect(foundList.id, equals(testList.id));
      
      // Update
      final updatedList = foundList.copyWith(
        description: 'Updated description',
      );
      await service.saveCustomList(updatedList);
      
      // Delete
      await service.deleteCustomList(foundList.id);
      
      final finalLists = await service.getAllLists();
      expect(finalLists.any((l) => l.id == foundList.id), isFalse);
    });
    
    testWidgets('Adaptive strategy switches correctly', (tester) async {
      // Test avec connectivité
      await service.getAllLists(strategy: PersistenceStrategy.CLOUD_FIRST);
      expect(service.lastUsedStrategy, PersistenceStrategy.CLOUD_FIRST);
      
      // Simuler panne réseau
      TestUtils.simulateNetworkFailure();
      
      await service.getAllLists(strategy: PersistenceStrategy.ADAPTIVE);
      expect(service.lastUsedStrategy, PersistenceStrategy.LOCAL_ONLY);
    });
  });
}
```

#### Tests de Performance
```dart
// test/performance/basic_performance_test.dart
void main() {
  group('Basic Performance Tests', () {
    late PerformanceOptimizedPersistenceService optimizedService;
    
    setUpAll(() async {
      await TestUtils.initializeTestEnvironment();
      optimizedService = GetIt.instance<PerformanceOptimizedPersistenceService>();
    });
    
    test('Cache improves performance significantly', () async {
      const iterations = 10;
      
      // Premier call pour warmer le cache
      await optimizedService.getAllLists();
      
      // Mesure avec cache
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < iterations; i++) {
        await optimizedService.getAllLists();
      }
      stopwatch.stop();
      
      final avgLatencyWithCache = stopwatch.elapsed.inMilliseconds / iterations;
      
      // Le cache devrait réduire la latence à <50ms en moyenne
      expect(avgLatencyWithCache, lessThan(50));
    });
    
    test('Batch operations are efficient', () async {
      final testLists = List.generate(100, (i) => CustomList.create(
        name: 'Batch Test List $i',
        type: ListType.todo,
      ));
      
      final stopwatch = Stopwatch()..start();
      await optimizedService.bulkSaveLists(testLists);
      stopwatch.stop();
      
      // 100 listes sauvegardées en moins de 2 secondes
      expect(stopwatch.elapsed.inSeconds, lessThan(2));
    });
  });
}
```

### Validation Continue

#### CI/CD Integration
```yaml
# .github/workflows/integration_tests.yml
name: Integration Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run integration tests
        run: |
          flutter test test/integration/
          flutter test test/performance/ --coverage
      
      - name: Check performance benchmarks
        run: |
          flutter test test/performance/basic_performance_test.dart
          # Fail if performance regressions detected
```

---

## 🔧 CUSTOMISATION ET EXTENSIONS

### Extending le Système

#### Créer un Nouveau Repository
```dart
// lib/data/repositories/my_custom_repository.dart
class MyCustomRepository implements CustomListRepository {
  final MyExternalService _externalService;
  final PerformanceMonitor _performanceMonitor;
  
  MyCustomRepository(this._externalService, this._performanceMonitor);
  
  @override
  Future<List<CustomList>> getAllCustomLists() async {
    return await _performanceMonitor.measureOperation(
      'my_custom_getAllLists',
      () async {
        final data = await _externalService.fetchLists();
        return data.map((d) => CustomList.fromJson(d)).toList();
      },
    );
  }
  
  // ... autres méthodes
}

// Configuration dans DI
class DependencyInjection {
  static Future<void> configure() async {
    // ... configuration existante
    
    // Ajout de votre repository personnalisé
    getIt.registerLazySingleton<MyCustomRepository>(() =>
      MyCustomRepository(
        MyExternalService(),
        getIt<PerformanceMonitor>(),
      )
    );
    
    // Utilisation dans le service adaptatif
    getIt.registerLazySingleton<AdaptivePersistenceService>(() =>
      AdaptivePersistenceService(
        localRepository: getIt<CustomListRepository>(),
        cloudRepository: getIt<SupabaseCustomListRepository>(),
        customRepositories: [
          getIt<MyCustomRepository>(), // Votre repository personnalisé
        ],
      )
    );
  }
}
```

#### Stratégies de Cache Personnalisées
```dart
class CustomCacheStrategy implements CacheStrategy {
  @override
  Duration getTTL(String key, dynamic data) {
    // TTL adaptatif selon le type de données
    if (key.startsWith('user_')) {
      return Duration(hours: 1); // Données utilisateur changent peu
    } else if (key.startsWith('realtime_')) {
      return Duration(minutes: 1); // Données temps réel
    }
    return Duration(minutes: 15); // Défaut
  }
  
  @override
  bool shouldCache(String key, dynamic data) {
    // Logique personnalisée de mise en cache
    return data != null && _getDataSize(data) < 1024 * 1024; // <1MB
  }
}
```

### Hooks et Events

#### System Event Hooks
```dart
class PersistenceEventHooks {
  static void setupHooks() {
    final persistenceService = GetIt.instance<AdaptivePersistenceService>();
    
    // Hook avant sauvegarde
    persistenceService.onBeforeSave.listen((event) {
      print('About to save: ${event.entity.name}');
      
      // Analytics
      Analytics.track('data_save_attempt', {
        'entity_type': event.entity.runtimeType.toString(),
        'strategy': event.strategy.toString(),
      });
    });
    
    // Hook après sauvegarde
    persistenceService.onAfterSave.listen((event) {
      print('Successfully saved: ${event.entity.name}');
      
      // Synchronisation tierce
      if (event.wasCloudSave) {
        ThirdPartyService.syncData(event.entity);
      }
    });
    
    // Hook sur erreur
    persistenceService.onError.listen((error) {
      print('Persistence error: ${error.message}');
      
      // Reporting automatique
      ErrorReporting.report(error.exception, context: {
        'operation': error.operation,
        'strategy': error.strategy?.toString(),
      });
    });
  }
}
```

---

## 📚 RÉFÉRENCE API RAPIDE

### Services Principaux

#### AdaptivePersistenceService
```dart
// Chargement adaptatif
final lists = await service.getAllLists(
  strategy: PersistenceStrategy.ADAPTIVE, // AUTO | LOCAL_FIRST | CLOUD_FIRST
);

// Sauvegarde avec stratégie
await service.saveCustomList(
  myList,
  syncStrategy: SyncStrategy.IMMEDIATE, // IMMEDIATE | BATCH | DELAYED
);

// Suppression sécurisée
await service.deleteCustomList(listId);

// État de synchronisation
final syncStatus = service.getSyncStatus();
final lastSync = service.getLastSyncTime();
```

#### PerformanceOptimizedPersistenceService
```dart
// Toutes les méthodes AdaptivePersistenceService + optimisations

// Opérations batch
await optimizedService.bulkSaveLists(listOfLists);
await optimizedService.bulkDeleteLists(listOfIds);

// Métriques performance
final metrics = optimizedService.getPerformanceMetrics();
print('Cache hit rate: ${metrics.cacheHitRate}%');
print('Average latency: ${metrics.averageLatency}ms');

// Configuration à chaud
optimizedService.updateConfiguration(
  cacheSize: 1500,
  batchSize: 75,
);
```

#### DataMigrationService
```dart
final migrationService = GetIt.instance<DataMigrationService>();

// Détection de données à migrer
final needsMigration = await migrationService.detectLegacyData();

// Migration avec feedback
await migrationService.migrateData(
  onProgress: (current, total) => print('$current/$total'),
  conflictResolution: ConflictResolutionStrategy.MERGE_COMPATIBLE,
);

// Validation post-migration
final result = await migrationService.validateMigration();
if (!result.isValid) {
  print('Issues: ${result.issues}');
}
```

### Modèles de Données

#### CustomList
```dart
// Création
final list = CustomList.create(
  name: 'Ma Liste',
  description: 'Description optionnelle',
  type: ListType.todo, // todo | habit | project
);

// Modification immutable
final updatedList = list.copyWith(
  name: 'Nouveau nom',
  description: 'Nouvelle description',
);

// Propriétés
print('${list.name} - ${list.totalTasks} tâches');
print('Progression: ${list.completionPercentage}%');
```

#### Configuration
```dart
// Configuration environnement
AppConfig.initialize(AppEnvironment.production);

// Variables disponibles
final supabaseUrl = AppConfig.supabaseUrl;
final isProduction = AppConfig.isProduction;
final cacheSize = AppConfig.cacheSize;
```

---

## ⚡ OPTIMISATIONS RECOMMANDÉES

### Performance Best Practices

#### 1. Utilisation du Cache
```dart
// ✅ BON - Utiliser le service optimisé pour gros volumes
final optimizedService = GetIt.instance<PerformanceOptimizedPersistenceService>();
final lists = await optimizedService.getAllLists(); // Cache automatique

// ❌ ÉVITER - Calls répétés sans cache
for (int i = 0; i < 10; i++) {
  await basicService.getAllLists(); // 10 calls réseau inutiles
}
```

#### 2. Opérations Batch
```dart
// ✅ BON - Opérations groupées
await optimizedService.bulkSaveLists([list1, list2, list3]);

// ❌ ÉVITER - Sauvegardes individuelles
await service.saveCustomList(list1);
await service.saveCustomList(list2);
await service.saveCustomList(list3);
```

#### 3. Stratégies Adaptatives
```dart
// ✅ BON - Laisser le système choisir
final lists = await service.getAllLists(
  strategy: PersistenceStrategy.ADAPTIVE,
);

// ❌ ÉVITER - Forcer cloud en cas de connectivité faible
final lists = await service.getAllLists(
  strategy: PersistenceStrategy.CLOUD_ONLY, // Peut échouer
);
```

### Memory Best Practices

#### 1. Gestion des Streams
```dart
class MyController extends StateNotifier<MyState> {
  StreamSubscription? _syncSubscription;
  
  @override
  void dispose() {
    // ✅ OBLIGATOIRE - Annuler les subscriptions
    _syncSubscription?.cancel();
    super.dispose();
  }
}
```

#### 2. Configuration du Cache
```dart
// Configuration adaptée à l'environnement
final cacheConfig = CacheConfiguration(
  maxSize: AppConfig.isLowEndDevice ? 200 : 1000,
  ttl: Duration(minutes: AppConfig.isProduction ? 15 : 5),
);
```

---

## 🚨 TROUBLESHOOTING

### Problèmes Courants

#### "Repository not found" Error
```dart
// Solution: Vérifier l'injection de dépendances
await DependencyInjection.configure(); // Avant utilisation

// Debug: Lister les services enregistrés
print('Registered services: ${GetIt.instance.allReady()}');
```

#### Performance Dégradée
```dart
// Solution: Vérifier les métriques
final metrics = PerformanceMonitor.instance.getCurrentMetrics();
print('Cache hit rate: ${metrics.cacheHitRate}');

// Si <80%, nettoyer le cache
await GetIt.instance<CacheService>().clear();
```

#### Conflits de Synchronisation
```dart
// Solution: Vérifier la stratégie de résolution
final migrationService = GetIt.instance<DataMigrationService>();
final conflicts = await migrationService.detectConflicts();

if (conflicts.isNotEmpty) {
  // Résoudre manuellement ou changer la stratégie
  await migrationService.resolveConflicts(
    conflicts,
    ConflictResolutionStrategy.LAST_WRITE_WINS,
  );
}
```

### Logs et Debugging

#### Activation des Logs Détaillés
```dart
// main.dart - Mode debug
void main() {
  if (kDebugMode) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
  
  runApp(MyApp());
}
```

#### Dashboard de Debug
```dart
// Widget pour afficher l'état du système
class DebugDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug Dashboard')),
      body: Column(
        children: [
          // État cache
          FutureBuilder(
            future: PersistenceDebugTools.inspectCache(),
            builder: (context, snapshot) => Text('Cache: ${snapshot.data}'),
          ),
          
          // Boutons d'action
          ElevatedButton(
            onPressed: () => PersistenceDebugTools.resetAllCaches(),
            child: Text('Clear All Caches'),
          ),
          
          ElevatedButton(
            onPressed: () => PersistenceDebugTools.generateTestData(10),
            child: Text('Generate Test Data'),
          ),
        ],
      ),
    );
  }
}
```

Cette documentation vous permet d'intégrer rapidement et efficacement le système de persistance adaptative dans votre flux de développement, avec tous les outils nécessaires pour le monitoring, debugging et optimisation.