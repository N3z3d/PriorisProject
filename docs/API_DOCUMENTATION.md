# DOCUMENTATION API - SYSTÈME DE PERSISTANCE ADAPTATIVE

## 📚 OVERVIEW

Cette documentation couvre l'API complète du système de persistance adaptative de Prioris, incluant tous les services, méthodes, modèles de données et exemples d'utilisation pratiques.

---

## 🔧 SERVICES PRINCIPAUX

### AdaptivePersistenceService

Service central orchestrant la persistance adaptative entre stockage local (Hive) et cloud (Supabase).

#### Constructor
```dart
AdaptivePersistenceService({
  required CustomListRepository localRepository,
  required SupabaseCustomListRepository cloudRepository,
  required ListItemRepository localItemRepository,
  required SupabaseListItemRepository cloudItemRepository,
  CacheService? cacheService,
  PerformanceMonitor? performanceMonitor,
})
```

#### Méthodes Principales

##### getAllLists()
Récupère toutes les listes avec stratégie adaptative.

```dart
Future<List<CustomList>> getAllLists({
  PersistenceStrategy strategy = PersistenceStrategy.ADAPTIVE,
  bool forceRefresh = false,
})
```

**Paramètres:**
- `strategy` : Stratégie de persistance (voir [PersistenceStrategy](#persistencestrategy))
- `forceRefresh` : Force la récupération depuis la source (ignore le cache)

**Retour:** `List<CustomList>` - Liste des listes personnalisées

**Exceptions:**
- `PersistenceException` : Erreur de persistance
- `NetworkException` : Erreur réseau
- `CacheException` : Erreur de cache

**Exemple:**
```dart
try {
  final lists = await adaptivePersistenceService.getAllLists(
    strategy: PersistenceStrategy.CLOUD_FIRST,
  );
  print('Loaded ${lists.length} lists');
} catch (e) {
  print('Error loading lists: $e');
}
```

##### saveCustomList()
Sauvegarde une liste avec synchronisation adaptative.

```dart
Future<void> saveCustomList(
  CustomList list, {
  SyncStrategy syncStrategy = SyncStrategy.ADAPTIVE,
  bool waitForSync = false,
})
```

**Paramètres:**
- `list` : Instance de CustomList à sauvegarder
- `syncStrategy` : Stratégie de synchronisation
- `waitForSync` : Attendre la synchronisation complète

**Exemple:**
```dart
final newList = CustomList.create(
  name: 'Ma nouvelle liste',
  type: ListType.todo,
);

await adaptivePersistenceService.saveCustomList(
  newList,
  syncStrategy: SyncStrategy.IMMEDIATE,
  waitForSync: true,
);
```

##### deleteCustomList()
Supprime une liste de tous les systèmes de persistance.

```dart
Future<void> deleteCustomList(
  String listId, {
  bool softDelete = false,
})
```

**Paramètres:**
- `listId` : Identifiant unique de la liste
- `softDelete` : Suppression logique (marque comme supprimé)

**Exemple:**
```dart
await adaptivePersistenceService.deleteCustomList(
  'list-123',
  softDelete: true, // Récupération possible
);
```

##### getAllListItems()
Récupère tous les éléments d'une liste spécifique.

```dart
Future<List<ListItem>> getAllListItems(
  String listId, {
  PersistenceStrategy strategy = PersistenceStrategy.ADAPTIVE,
})
```

##### saveListItem()
Sauvegarde un élément de liste.

```dart
Future<void> saveListItem(
  ListItem item, {
  SyncStrategy syncStrategy = SyncStrategy.ADAPTIVE,
})
```

#### Propriétés d'État

##### lastSyncStatus
```dart
SyncStatus get lastSyncStatus
```
Retourne le statut de la dernière synchronisation.

##### isOnline
```dart
bool get isOnline
```
Indique si le service cloud est accessible.

##### cacheHitRate
```dart
double get cacheHitRate
```
Taux de succès du cache (0.0 - 1.0).

#### Events et Callbacks

##### onSyncStatusChanged
```dart
Stream<SyncStatus> get onSyncStatusChanged
```
Stream des changements de statut de synchronisation.

**Exemple:**
```dart
adaptivePersistenceService.onSyncStatusChanged.listen((status) {
  switch (status) {
    case SyncStatus.syncing:
      showSyncIndicator();
      break;
    case SyncStatus.synced:
      hideSyncIndicator();
      break;
    case SyncStatus.error:
      showSyncError();
      break;
  }
});
```

---

### PerformanceOptimizedPersistenceService

Extension haute performance du service de persistance adaptative.

#### Constructor
```dart
PerformanceOptimizedPersistenceService({
  required CustomListRepository localRepository,
  required SupabaseCustomListRepository cloudRepository,
  required ListItemRepository localItemRepository,
  required SupabaseListItemRepository cloudItemRepository,
  CacheConfiguration? cacheConfig,
  BatchConfiguration? batchConfig,
  int? workerPoolSize,
})
```

#### Méthodes Optimisées

##### bulkSaveLists()
Sauvegarde multiple de listes avec batching automatique.

```dart
Future<void> bulkSaveLists(
  List<CustomList> lists, {
  int? batchSize,
  Duration? batchDelay,
  void Function(int current, int total)? onProgress,
})
```

**Exemple:**
```dart
final listsToSave = [list1, list2, list3, /* ... */];

await optimizedService.bulkSaveLists(
  listsToSave,
  batchSize: 50,
  onProgress: (current, total) {
    print('Progress: $current/$total');
  },
);
```

##### bulkDeleteLists()
Suppression multiple optimisée.

```dart
Future<void> bulkDeleteLists(
  List<String> listIds, {
  bool softDelete = false,
})
```

##### getPerformanceMetrics()
Récupère les métriques de performance en temps réel.

```dart
PerformanceMetrics getPerformanceMetrics()
```

**Retour:**
```dart
class PerformanceMetrics {
  final double cacheHitRate;        // Taux de succès cache
  final Duration averageLatency;    // Latence moyenne
  final int totalOperations;        // Total opérations
  final double errorRate;           // Taux d'erreur
  final int memoryUsageMB;         // Utilisation mémoire
  final Map<String, int> operationCounts; // Compteurs par opération
}
```

##### preloadData()
Préchargement intelligent des données populaires.

```dart
Future<void> preloadData({
  PreloadStrategy strategy = PreloadStrategy.SMART,
  int maxItems = 100,
})
```

---

### DataMigrationService

Service spécialisé dans la migration et synchronisation de données.

#### Constructor
```dart
DataMigrationService({
  required CustomListRepository localRepository,
  required SupabaseCustomListRepository cloudRepository,
  required ListItemRepository localItemRepository,
  required SupabaseListItemRepository cloudItemRepository,
  ConflictResolutionStrategy defaultStrategy = ConflictResolutionStrategy.LAST_WRITE_WINS,
})
```

#### Méthodes de Migration

##### migrateAllData()
Migration complète des données avec gestion avancée des conflits.

```dart
Future<MigrationResult> migrateAllData({
  MigrationDirection direction = MigrationDirection.BIDIRECTIONAL,
  ConflictResolutionStrategy conflictStrategy = ConflictResolutionStrategy.MERGE_COMPATIBLE,
  void Function(int current, int total)? onProgress,
  void Function(ConflictInfo conflict)? onConflict,
})
```

**Paramètres:**
- `direction` : Direction de migration (LOCAL_TO_CLOUD, CLOUD_TO_LOCAL, BIDIRECTIONAL)
- `conflictStrategy` : Stratégie de résolution des conflits
- `onProgress` : Callback de progression
- `onConflict` : Callback appelé pour chaque conflit détecté

**Exemple:**
```dart
final result = await migrationService.migrateAllData(
  direction: MigrationDirection.BIDIRECTIONAL,
  conflictStrategy: ConflictResolutionStrategy.USER_CHOICE,
  onProgress: (current, total) {
    updateProgressBar(current / total);
  },
  onConflict: (conflict) async {
    final choice = await showConflictDialog(conflict);
    conflict.resolve(choice);
  },
);

print('Migration completed: ${result.summary}');
```

##### detectConflicts()
Détection des conflits avant migration.

```dart
Future<List<ConflictInfo>> detectConflicts()
```

##### resolveConflict()
Résolution manuelle d'un conflit spécifique.

```dart
Future<void> resolveConflict(
  ConflictInfo conflict,
  ConflictResolution resolution,
)
```

---

## 📊 MODÈLES DE DONNÉES

### CustomList

Modèle principal représentant une liste personnalisée.

#### Propriétés
```dart
class CustomList {
  final String id;                    // Identifiant unique
  final String name;                  // Nom de la liste
  final String? description;          // Description optionnelle
  final ListType type;                // Type de liste
  final DateTime createdAt;           // Date de création
  final DateTime? updatedAt;          // Date de modification
  final ListSettings settings;        // Paramètres de la liste
  final ListStatistics statistics;    // Statistiques
  
  // Propriétés calculées
  int get totalTasks;                 // Nombre total de tâches
  int get completedTasks;             // Tâches terminées
  double get completionPercentage;    // Pourcentage de completion
  bool get isEmpty;                   // Liste vide
}
```

#### Constructors

##### create()
Création d'une nouvelle liste.

```dart
factory CustomList.create({
  required String name,
  String? description,
  required ListType type,
  ListSettings? settings,
})
```

##### fromJson()
Désérialisation depuis JSON.

```dart
factory CustomList.fromJson(Map<String, dynamic> json)
```

#### Méthodes

##### copyWith()
Création d'une copie modifiée (immutable).

```dart
CustomList copyWith({
  String? name,
  String? description,
  ListType? type,
  ListSettings? settings,
})
```

##### toJson()
Sérialisation vers JSON.

```dart
Map<String, dynamic> toJson()
```

##### addTask()
Ajout d'une tâche à la liste.

```dart
CustomList addTask(ListItem task)
```

---

### ListItem

Modèle représentant un élément de liste.

#### Propriétés
```dart
class ListItem {
  final String id;                    // Identifiant unique
  final String title;                 // Titre de l'item
  final String? description;          // Description détaillée
  final bool isCompleted;             // État de completion
  final Priority priority;            // Niveau de priorité
  final String listId;                // ID de la liste parent
  final DateTime createdAt;           // Date de création
  final DateTime? completedAt;        // Date de completion
  final Map<String, dynamic> metadata; // Métadonnées extensibles
}
```

#### Méthodes Principales

##### complete()
Marque l'item comme terminé.

```dart
ListItem complete()
```

##### updatePriority()
Mise à jour de la priorité.

```dart
ListItem updatePriority(Priority newPriority)
```

---

### Enumerations

#### PersistenceStrategy
Stratégies de persistance disponibles.

```dart
enum PersistenceStrategy {
  LOCAL_FIRST,    // Privilégier stockage local
  CLOUD_FIRST,    // Privilégier stockage cloud
  ADAPTIVE,       // Choix automatique selon conditions
  LOCAL_ONLY,     // Stockage local uniquement
  CLOUD_ONLY,     // Stockage cloud uniquement
}
```

#### SyncStrategy
Stratégies de synchronisation.

```dart
enum SyncStrategy {
  IMMEDIATE,      // Synchronisation immédiate
  BATCH,          // Synchronisation par lot
  DELAYED,        // Synchronisation différée
  ADAPTIVE,       // Choix automatique
  MANUAL,         // Synchronisation manuelle uniquement
}
```

#### ListType
Types de listes supportés.

```dart
enum ListType {
  todo,           // Liste de tâches
  habit,          // Liste d'habitudes
  project,        // Liste de projet
  shopping,       // Liste de courses
  custom,         // Type personnalisé
}
```

#### Priority
Niveaux de priorité.

```dart
enum Priority {
  low(1),         // Priorité basse
  medium(2),      // Priorité moyenne
  high(3),        // Priorité haute
  urgent(4);      // Priorité urgente
  
  const Priority(this.value);
  final int value;
}
```

---

## 🔄 GESTION DES ERREURS

### Hiérarchie d'Exceptions

```dart
// Exception de base
abstract class PriorisException implements Exception {
  final String message;
  final String? code;
  final dynamic cause;
  
  const PriorisException(this.message, {this.code, this.cause});
}

// Exceptions de persistance
class PersistenceException extends PriorisException {
  const PersistenceException(String message, {String? code, dynamic cause})
    : super(message, code: code, cause: cause);
}

// Exceptions réseau
class NetworkException extends PriorisException {
  const NetworkException(String message, {String? code, dynamic cause})
    : super(message, code: code, cause: cause);
}

// Exceptions de cache
class CacheException extends PriorisException {
  const CacheException(String message, {String? code, dynamic cause})
    : super(message, code: code, cause: cause);
}

// Exceptions de migration
class MigrationException extends PriorisException {
  const MigrationException(String message, {String? code, dynamic cause})
    : super(message, code: code, cause: cause);
}

// Exceptions de validation
class ValidationException extends PriorisException {
  const ValidationException(String message, {String? code, dynamic cause})
    : super(message, code: code, cause: cause);
}
```

### Gestion Recommandée

```dart
try {
  final lists = await adaptivePersistenceService.getAllLists();
  // Traitement des données
} on NetworkException catch (e) {
  // Erreur réseau - mode offline possible
  showSnackBar('Mode hors ligne activé');
  final localLists = await adaptivePersistenceService.getAllLists(
    strategy: PersistenceStrategy.LOCAL_ONLY,
  );
} on CacheException catch (e) {
  // Erreur cache - nettoyer et retenter
  await cacheService.clear();
  final lists = await adaptivePersistenceService.getAllLists(
    forceRefresh: true,
  );
} on PersistenceException catch (e) {
  // Erreur générale de persistance
  showErrorDialog('Erreur de sauvegarde: ${e.message}');
} catch (e) {
  // Erreur inattendue
  logger.error('Unexpected error: $e');
  showErrorDialog('Une erreur inattendue s\'est produite');
}
```

---

## ⚙️ CONFIGURATION

### Configuration Principale

```dart
class PersistenceConfiguration {
  // Configuration cache
  final int cacheMaxSize;              // Taille max cache
  final Duration cacheTTL;             // Time To Live
  final bool compressionEnabled;       // Compression activée
  
  // Configuration batching
  final int batchSize;                 // Taille des lots
  final Duration batchDelay;           // Délai entre lots
  final int maxConcurrentBatches;      // Lots simultanés max
  
  // Configuration réseau
  final Duration networkTimeout;       // Timeout réseau
  final int maxRetries;                // Tentatives max
  final Duration retryDelay;           // Délai entre tentatives
  
  // Configuration performance
  final int workerPoolSize;            // Nombre de workers
  final bool preloadEnabled;           // Préchargement activé
  final PreloadStrategy preloadStrategy; // Stratégie de préchargement
  
  const PersistenceConfiguration({
    this.cacheMaxSize = 1000,
    this.cacheTTL = const Duration(minutes: 15),
    this.compressionEnabled = true,
    this.batchSize = 50,
    this.batchDelay = const Duration(milliseconds: 100),
    this.maxConcurrentBatches = 3,
    this.networkTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.workerPoolSize = 4,
    this.preloadEnabled = false,
    this.preloadStrategy = PreloadStrategy.RECENT,
  });
  
  // Configurations prédéfinies
  static const development = PersistenceConfiguration(
    cacheMaxSize: 200,
    cacheTTL: Duration(minutes: 5),
    batchSize: 10,
    preloadEnabled: false,
  );
  
  static const production = PersistenceConfiguration(
    cacheMaxSize: 2000,
    cacheTTL: Duration(minutes: 30),
    batchSize: 100,
    compressionEnabled: true,
    preloadEnabled: true,
    preloadStrategy: PreloadStrategy.SMART,
  );
}
```

### Application de la Configuration

```dart
// Configuration globale
final config = AppConfig.isProduction 
  ? PersistenceConfiguration.production
  : PersistenceConfiguration.development;

// Service avec configuration personnalisée
final optimizedService = PerformanceOptimizedPersistenceService(
  localRepository: localRepo,
  cloudRepository: cloudRepo,
  localItemRepository: localItemRepo,
  cloudItemRepository: cloudItemRepo,
  cacheConfig: CacheConfiguration(
    maxSize: config.cacheMaxSize,
    ttl: config.cacheTTL,
    compressionEnabled: config.compressionEnabled,
  ),
  batchConfig: BatchConfiguration(
    size: config.batchSize,
    flushInterval: config.batchDelay,
  ),
  workerPoolSize: config.workerPoolSize,
);
```

---

## 📈 MONITORING ET MÉTRIQUES

### PerformanceMonitor API

#### Configuration des Alertes

```dart
class AlertConfiguration {
  // Seuils de latence
  static const latencyWarning = Duration(milliseconds: 500);
  static const latencyCritical = Duration(milliseconds: 2000);
  
  // Seuils cache
  static const cacheHitRateWarning = 0.7;  // 70%
  static const cacheHitRateCritical = 0.5; // 50%
  
  // Seuils mémoire
  static const memoryWarningMB = 100;
  static const memoryCriticalMB = 200;
  
  // Configuration des alertes
  static List<AlertRule> get defaultRules => [
    AlertRule(
      name: 'high_latency',
      condition: (metrics) => metrics.averageLatency > latencyWarning,
      severity: AlertSeverity.warning,
    ),
    AlertRule(
      name: 'critical_latency',
      condition: (metrics) => metrics.averageLatency > latencyCritical,
      severity: AlertSeverity.critical,
    ),
    AlertRule(
      name: 'low_cache_hit_rate',
      condition: (metrics) => metrics.cacheHitRate < cacheHitRateWarning,
      severity: AlertSeverity.warning,
    ),
  ];
}
```

#### Utilisation du Monitoring

```dart
final monitor = PerformanceMonitor.instance;

// Configuration initiale
monitor.configure(
  alertRules: AlertConfiguration.defaultRules,
  reportingInterval: Duration(minutes: 1),
  enableDetailedMetrics: true,
);

// Écoute des alertes
monitor.alerts.listen((alert) {
  switch (alert.severity) {
    case AlertSeverity.info:
      logger.info('Performance info: ${alert.message}');
      break;
    case AlertSeverity.warning:
      logger.warning('Performance warning: ${alert.message}');
      showWarningNotification(alert.message);
      break;
    case AlertSeverity.critical:
      logger.error('Performance critical: ${alert.message}');
      showCriticalAlert(alert.message);
      break;
  }
});

// Métriques personnalisées
monitor.recordCustomMetric('user_action_duration', duration);
monitor.incrementCounter('button_clicks');
```

### Métriques Disponibles

```dart
class DetailedMetrics {
  // Métriques de performance
  final Duration averageLatency;       // Latence moyenne
  final Duration p50Latency;           // Percentile 50
  final Duration p95Latency;           // Percentile 95  
  final Duration p99Latency;           // Percentile 99
  
  // Métriques de cache
  final double cacheHitRate;           // Taux de succès
  final double cacheMissRate;          // Taux d'échec
  final int cacheSize;                 // Taille actuelle
  final int cacheEvictions;            // Évictions
  
  // Métriques réseau
  final int totalRequests;             // Total requêtes
  final int successfulRequests;        // Requêtes réussies
  final int failedRequests;            // Requêtes échouées
  final double errorRate;              // Taux d'erreur
  
  // Métriques mémoire
  final int memoryUsageMB;            // Utilisation courante
  final int peakMemoryMB;             // Pic d'utilisation
  
  // Métriques business
  final int totalLists;               // Nombre total de listes
  final int totalItems;               // Nombre total d'items
  final int syncedEntities;           // Entités synchronisées
  final DateTime lastSyncTime;        // Dernière synchronisation
}
```

---

## 🔍 EXEMPLES D'UTILISATION AVANCÉS

### Cas d'Usage: Application Mobile Complète

```dart
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProviderScope(
        child: HomePage(),
      ),
    );
  }
}

// Controller principal
class TodoController extends StateNotifier<TodoState> {
  final AdaptivePersistenceService _persistenceService;
  final DataMigrationService _migrationService;
  
  TodoController(this._persistenceService, this._migrationService) 
    : super(const TodoState.initial()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    // 1. Vérification migration nécessaire
    final needsMigration = await _migrationService.detectLegacyData();
    if (needsMigration) {
      await _performMigration();
    }
    
    // 2. Chargement initial
    await loadLists();
    
    // 3. Setup synchronisation automatique
    _setupAutoSync();
  }
  
  Future<void> loadLists() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final lists = await _persistenceService.getAllLists(
        strategy: PersistenceStrategy.ADAPTIVE,
      );
      
      state = state.copyWith(
        lists: lists,
        isLoading: false,
        lastUpdateTime: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: TodoError.fromException(error),
      );
    }
  }
  
  Future<void> createList(String name, {String? description}) async {
    try {
      final newList = CustomList.create(
        name: name,
        description: description,
        type: ListType.todo,
      );
      
      await _persistenceService.saveCustomList(
        newList,
        syncStrategy: SyncStrategy.IMMEDIATE,
      );
      
      // Optimistic update
      final updatedLists = [...state.lists, newList];
      state = state.copyWith(lists: updatedLists);
      
    } catch (error) {
      state = state.copyWith(
        error: TodoError.fromException(error),
      );
      
      // Rollback sur erreur
      await loadLists();
    }
  }
  
  void _setupAutoSync() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (_persistenceService.isOnline && state.hasUnsyncedChanges) {
        await _syncPendingChanges();
      }
    });
  }
}

// Provider Riverpod
final todoControllerProvider = StateNotifierProvider<TodoController, TodoState>((ref) {
  final persistenceService = ref.watch(persistenceServiceProvider);
  final migrationService = ref.watch(migrationServiceProvider);
  return TodoController(persistenceService, migrationService);
});

// Page principale
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoControllerProvider);
    final controller = ref.read(todoControllerProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Listes'),
        actions: [
          // Indicateur de sync
          Consumer(
            builder: (context, ref, child) {
              final syncStatus = ref.watch(syncStatusProvider);
              return SyncIndicator(status: syncStatus);
            },
          ),
        ],
      ),
      body: state.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error) => ErrorWidget(
          error: error,
          onRetry: () => controller.loadLists(),
        ),
        loaded: (lists) => ListView.builder(
          itemCount: lists.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(lists[index].name),
              subtitle: Text('${lists[index].totalTasks} tâches'),
              trailing: Text('${lists[index].completionPercentage}%'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListDetailPage(listId: lists[index].id),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, controller),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Cas d'Usage: Sync Offline-Online

```dart
class OfflineSyncManager {
  final AdaptivePersistenceService _persistenceService;
  final ConnectivityService _connectivityService;
  
  OfflineSyncManager(this._persistenceService, this._connectivityService) {
    _setupConnectivityListener();
  }
  
  void _setupConnectivityListener() {
    _connectivityService.onConnectivityChanged.listen((isConnected) async {
      if (isConnected) {
        await _performOnlineSync();
      }
    });
  }
  
  Future<void> _performOnlineSync() async {
    try {
      // 1. Récupérer les données locales modifiées
      final localChanges = await _getLocalChanges();
      
      // 2. Sync vers le cloud
      for (final change in localChanges) {
        await _persistenceService.saveCustomList(
          change.entity,
          syncStrategy: SyncStrategy.IMMEDIATE,
        );
      }
      
      // 3. Récupérer les changements du cloud
      final cloudLists = await _persistenceService.getAllLists(
        strategy: PersistenceStrategy.CLOUD_ONLY,
        forceRefresh: true,
      );
      
      // 4. Merger avec les données locales
      await _mergeWithLocal(cloudLists);
      
      // 5. Marquer comme synchronisé
      await _markAsSynced(localChanges);
      
    } catch (error) {
      logger.error('Sync failed: $error');
      // Programmer une nouvelle tentative
      _scheduleRetry();
    }
  }
  
  Future<List<LocalChange>> _getLocalChanges() async {
    // Implémentation de détection des changements locaux
    return await LocalChangeTracker.getUnsyncedChanges();
  }
  
  Future<void> _mergeWithLocal(List<CustomList> cloudLists) async {
    final migrationService = GetIt.instance<DataMigrationService>();
    
    await migrationService.migrateAllData(
      direction: MigrationDirection.CLOUD_TO_LOCAL,
      conflictStrategy: ConflictResolutionStrategy.MERGE_COMPATIBLE,
    );
  }
}
```

---

Cette documentation API complète couvre tous les aspects techniques du système de persistance adaptative, fournissant aux développeurs toutes les informations nécessaires pour une intégration efficace et une utilisation optimale des fonctionnalités avancées.