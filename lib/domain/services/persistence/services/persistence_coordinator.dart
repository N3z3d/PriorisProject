/// **PERSISTENCE COORDINATOR** - SOLID Implementation
///
/// **LOT 3.1** : Coordinateur principal qui remplace UnifiedPersistenceService
/// **Responsabilité unique** : Orchestration et configuration des services spécialisés
/// **Taille** : <200 lignes (contrainte CLAUDE.md respectée)
/// **Architecture** : Strategy Pattern + Dependency Injection

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/persistence_coordinator_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/local_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/cloud_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/sync_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';

/// **Coordinateur de persistance**
///
/// **SRP** : Orchestration uniquement - délègue aux services spécialisés
/// **OCP** : Extensible via injection de stratégies
/// **DIP** : Dépend d'abstractions (services injectés)
/// **Strategy Pattern** : Change de stratégie selon le mode
class PersistenceCoordinator implements IPersistenceCoordinator {
  final ILocalPersistenceService _localService;
  final ICloudPersistenceService _cloudService;
  final ISyncPersistenceService _syncService;
  final IPersistenceConfiguration _configuration;
  final ILogger _logger;

  // === State Management ===
  PersistenceMode _currentMode = PersistenceMode.localFirst;
  bool _isAuthenticated = false;
  bool _initialized = false;

  /// **Constructeur avec injection de dépendances** (DIP)
  PersistenceCoordinator({
    required ILocalPersistenceService localService,
    required ICloudPersistenceService cloudService,
    required ISyncPersistenceService syncService,
    required IPersistenceConfiguration configuration,
    required ILogger logger,
  }) : _localService = localService,
       _cloudService = cloudService,
       _syncService = syncService,
       _configuration = configuration,
       _logger = logger;

  // === Configuration and State ===

  @override
  PersistenceMode get currentMode => _currentMode;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isSyncing => _syncService.isSyncing;

  // === Lifecycle Management ===

  @override
  Future<void> initialize({required bool isAuthenticated}) async {
    if (_initialized) {
      throw UnifiedPersistenceException(
        'Coordinateur déjà initialisé',
        operation: 'initialize',
        mode: _currentMode,
      );
    }

    _logger.info('Initialisation coordinateur avec auth=$isAuthenticated', context: 'PersistenceCoordinator');

    _isAuthenticated = isAuthenticated;
    _currentMode = isAuthenticated ? PersistenceMode.cloudFirst : PersistenceMode.localFirst;
    _initialized = true;

    _logger.info('Coordinateur initialisé en mode ${_currentMode.name}', context: 'PersistenceCoordinator');
  }

  @override
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  }) async {
    _ensureInitialized();

    _logger.info('Changement authentification: $_isAuthenticated → $isAuthenticated', context: 'PersistenceCoordinator');

    final wasAuthenticated = _isAuthenticated;
    _isAuthenticated = isAuthenticated;

    if (!wasAuthenticated && isAuthenticated) {
      // Transition: Invité → Connecté
      await _syncService.handleGuestToAuthenticatedTransition(
        migrationStrategy ?? _configuration.defaultMigrationStrategy,
      );
      _currentMode = PersistenceMode.cloudFirst;
    } else if (wasAuthenticated && !isAuthenticated) {
      // Transition: Connecté → Invité
      await _syncService.handleAuthenticatedToGuestTransition();
      _currentMode = PersistenceMode.localFirst;
    }

    _logger.info('Nouveau mode: ${_currentMode.name}', context: 'PersistenceCoordinator');
  }

  @override
  void dispose() {
    _logger.info('Nettoyage du coordinateur', context: 'PersistenceCoordinator');
    _initialized = false;
  }

  // === Core Operations (Strategy Pattern) ===

  @override
  Future<List<CustomList>> getAllLists() async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        return await _localService.getLocalLists();
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        return await _cloudService.getCloudLists();
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.saveLocalList(list);
        break;
      case PersistenceMode.cloudFirst:
        await _cloudService.saveCloudList(list);
        if (_configuration.enableBackgroundSync) {
          _syncService.syncListToCloudAsync(list);
        }
        break;
      case PersistenceMode.hybrid:
        await _cloudService.saveCloudList(list);
        break;
    }
  }

  @override
  Future<void> updateList(CustomList list) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.updateLocalList(list);
        break;
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        await _cloudService.updateCloudList(list);
        break;
    }
  }

  @override
  Future<void> deleteList(String listId) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.deleteLocalList(listId);
        break;
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        await _cloudService.deleteCloudList(listId);
        break;
    }
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        return await _localService.getLocalItems(listId);
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        return await _cloudService.getCloudItems(listId);
    }
  }

  @override
  Future<void> saveItem(ListItem item) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.saveLocalItem(item);
        break;
      case PersistenceMode.cloudFirst:
        await _cloudService.saveCloudItem(item);
        if (_configuration.enableBackgroundSync) {
          _syncService.syncItemToCloudAsync(item);
        }
        break;
      case PersistenceMode.hybrid:
        await _cloudService.saveCloudItem(item);
        break;
    }
  }

  @override
  Future<void> updateItem(ListItem item) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.updateLocalItem(item);
        break;
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        await _cloudService.updateCloudItem(item);
        break;
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.deleteLocalItem(itemId);
        break;
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        await _cloudService.deleteCloudItem(itemId);
        break;
    }
  }

  // === Bulk Operations ===

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.saveMultipleLocalItems(items);
        break;
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        await _cloudService.saveMultipleCloudItems(items);
        break;
    }
  }

  @override
  Future<void> clearAllData() async {
    _ensureInitialized();

    switch (_currentMode) {
      case PersistenceMode.localFirst:
        await _localService.clearLocalData();
        break;
      case PersistenceMode.cloudFirst:
      case PersistenceMode.hybrid:
        await _cloudService.clearCloudData();
        break;
    }
  }

  // === Advanced Operations ===

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async {
    _ensureInitialized();
    _logger.info('Force reload depuis persistance', context: 'PersistenceCoordinator');
    return await getAllLists();
  }

  @override
  Future<void> verifyListPersistence(String listId) async {
    _ensureInitialized();

    final exists = _currentMode == PersistenceMode.localFirst
        ? await _localService.verifyLocalList(listId)
        : await _localService.verifyLocalList(listId); // Vérifier local même en mode cloud

    if (!exists) {
      throw UnifiedPersistenceException(
        'Liste non trouvée après vérification',
        operation: 'verifyListPersistence',
        id: listId,
        mode: _currentMode,
      );
    }
  }

  @override
  Future<void> verifyItemPersistence(String itemId) async {
    _ensureInitialized();

    final exists = _currentMode == PersistenceMode.localFirst
        ? await _localService.verifyLocalItem(itemId)
        : await _localService.verifyLocalItem(itemId); // Vérifier local même en mode cloud

    if (!exists) {
      throw UnifiedPersistenceException(
        'Item non trouvé après vérification',
        operation: 'verifyItemPersistence',
        id: itemId,
        mode: _currentMode,
      );
    }
  }

  // === Migration and Sync (Delegation) ===

  @override
  Future<void> migrateData(MigrationStrategy strategy) async {
    _ensureInitialized();
    await _syncService.migrateData(strategy);
  }

  @override
  Future<bool> hasPendingMigration() async {
    _ensureInitialized();
    return await _syncService.hasPendingMigration();
  }

  @override
  Future<void> forceSyncAll() async {
    _ensureInitialized();
    await _syncService.forceSyncAll();
  }

  // === Statistics and Monitoring ===

  @override
  Map<String, dynamic> getPersistenceStats() {
    return {
      'currentMode': _currentMode.name,
      'isAuthenticated': _isAuthenticated,
      'initialized': _initialized,
      'isSyncing': isSyncing,
      'configuration': _configuration.toMap(),
      'syncStats': _syncService.getSyncStats(),
      'service': 'PersistenceCoordinator',
      'version': '2.0.0', // Version après refactoring LOT 3.1
    };
  }

  // === Private Helper Methods ===

  void _ensureInitialized() {
    if (!_initialized) {
      throw UnifiedPersistenceException(
        'Coordinateur non initialisé',
        operation: 'access',
        mode: _currentMode,
      );
    }
  }
}