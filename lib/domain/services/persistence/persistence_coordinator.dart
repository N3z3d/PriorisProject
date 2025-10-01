/// **PERSISTENCE COORDINATOR** - Coordinator Pattern
///
/// **LOT 9** : Coordinateur SOLID remplaçant God Class (923 lignes)
/// **SRP** : Coordination uniquement entre services spécialisés
/// **Taille** : <200 lignes (orchestration vs implémentation)

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'services/lists_persistence_service.dart';
import 'services/items_persistence_service.dart';
import 'services/data_management_service.dart';
import 'services/migration_service.dart';
import 'services/deduplication_service.dart';
import 'interfaces/unified_persistence_interface.dart';

/// Coordinateur SOLID pour la persistance unifiée
///
/// **SRP** : Coordination uniquement - délègue aux services spécialisés
/// **OCP** : Extensible via injection de nouveaux services
/// **DIP** : Dépend d'abstractions (services injectés)
/// **COORDINATEUR** : Pattern de coordination sans logique métier
class PersistenceCoordinator implements IUnifiedPersistenceService {
  final ListsPersistenceService _listsService;
  final ItemsPersistenceService _itemsService;
  final DataManagementService _dataManagementService;
  final MigrationService _migrationService;
  final DeduplicationService _deduplicationService;
  final ILogger _logger;
  final IPersistenceConfiguration _config;

  bool _isInitialized = false;
  bool _isAuthenticated = false;

  /// **Constructeur avec injection de dépendances** (DIP)
  PersistenceCoordinator({
    required ListsPersistenceService listsService,
    required ItemsPersistenceService itemsService,
    required DataManagementService dataManagementService,
    required MigrationService migrationService,
    required DeduplicationService deduplicationService,
    required ILogger logger,
    required IPersistenceConfiguration config,
  }) : _listsService = listsService,
       _itemsService = itemsService,
       _dataManagementService = dataManagementService,
       _migrationService = migrationService,
       _deduplicationService = deduplicationService,
       _logger = logger,
       _config = config;

  @override
  IPersistenceConfiguration get configuration => _config;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isAuthenticated => _isAuthenticated;

  // ==================== LIFECYCLE ====================

  @override
  Future<void> initialize({required bool isAuthenticated}) async {
    if (_isInitialized) return;

    _logger.info('Initialisation PersistenceCoordinator', context: 'PersistenceCoordinator');

    try {
      _isAuthenticated = isAuthenticated;
      _migrationService.updateAuthenticationState(isAuthenticated);
      _isInitialized = true;

      _logger.info('PersistenceCoordinator initialisé', context: 'PersistenceCoordinator');
    } catch (e) {
      _logger.error('Erreur initialisation: $e', context: 'PersistenceCoordinator');
      rethrow;
    }
  }

  @override
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  }) async {
    _ensureInitialized();

    final previousState = _isAuthenticated;
    _isAuthenticated = isAuthenticated;

    try {
      if (!previousState && isAuthenticated) {
        // Guest → Authentifié
        await _migrationService.handleGuestToAuthenticatedTransition(
          migrationStrategy ?? _config.defaultMigrationStrategy,
        );
      } else if (previousState && !isAuthenticated) {
        // Authentifié → Guest
        await _migrationService.handleAuthenticatedToGuestTransition();
      }

      _migrationService.updateAuthenticationState(isAuthenticated);
    } catch (e) {
      _logger.error('Erreur changement état auth: $e', context: 'PersistenceCoordinator');
      rethrow;
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    _isAuthenticated = false;
    _logger.debug('PersistenceCoordinator disposé', context: 'PersistenceCoordinator');
  }

  // ==================== LISTS OPERATIONS (Délégation) ====================

  @override
  Future<List<CustomList>> getAllLists() async {
    _ensureInitialized();
    return await _listsService.getAllLists();
  }

  @override
  Future<void> saveList(CustomList list) async {
    _ensureInitialized();
    return await _listsService.saveList(list);
  }

  @override
  Future<void> updateList(CustomList list) async {
    _ensureInitialized();
    return await _listsService.updateList(list);
  }

  @override
  Future<void> deleteList(String listId) async {
    _ensureInitialized();
    return await _listsService.deleteList(listId);
  }

  @override
  Future<void> verifyListPersistence(String listId) async {
    _ensureInitialized();
    return await _listsService.verifyListPersistence(listId);
  }

  // ==================== ITEMS OPERATIONS (Délégation) ====================

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    _ensureInitialized();
    return await _itemsService.getItemsByListId(listId);
  }

  @override
  Future<void> saveItem(ListItem item) async {
    _ensureInitialized();
    return await _itemsService.saveItem(item);
  }

  @override
  Future<void> updateItem(ListItem item) async {
    _ensureInitialized();
    return await _itemsService.updateItem(item);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    _ensureInitialized();
    return await _itemsService.deleteItem(itemId);
  }

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {
    _ensureInitialized();
    return await _itemsService.saveMultipleItems(items);
  }

  @override
  Future<void> verifyItemPersistence(String itemId) async {
    _ensureInitialized();
    return await _itemsService.verifyItemPersistence(itemId);
  }

  // ==================== DATA MANAGEMENT (Délégation) ====================

  @override
  Future<void> clearAllData() async {
    _ensureInitialized();
    return await _dataManagementService.clearAllData();
  }

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async {
    _ensureInitialized();
    return await _dataManagementService.forceReloadFromPersistence();
  }

  @override
  Future<void> forceSyncAll() async {
    _ensureInitialized();
    return await _dataManagementService.forceSyncAll();
  }

  // ==================== MIGRATION (Délégation) ====================

  @override
  Future<void> migrateData(MigrationStrategy strategy) async {
    _ensureInitialized();
    return await _migrationService.migrateData(strategy);
  }

  @override
  Future<bool> hasPendingMigration() async {
    _ensureInitialized();
    return await _migrationService.hasPendingMigration();
  }

  // ==================== HELPER METHODS ====================

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PersistenceCoordinator non initialisé. Appelez initialize() d\'abord.');
    }
  }

  /// Obtient les statistiques complètes du système
  Future<Map<String, dynamic>> getSystemStatistics() async {
    _ensureInitialized();

    try {
      final dataStats = await _dataManagementService.getDataStatistics();
      final hasPendingMigration = await _migrationService.hasPendingMigration();

      return {
        ...dataStats,
        'isAuthenticated': _isAuthenticated,
        'hasPendingMigration': hasPendingMigration,
        'configuration': _config.toMap(),
        'coordinator': 'PersistenceCoordinator v1.0',
      };
    } catch (e) {
      _logger.error('Erreur statistiques système: $e', context: 'PersistenceCoordinator');
      rethrow;
    }
  }
}