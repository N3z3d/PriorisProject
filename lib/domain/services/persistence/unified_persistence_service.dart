/// **UNIFIED PERSISTENCE SERVICE** - Redirection vers architecture SOLID
///
/// **LOT 9 ULTRATHINK COMPLETE** : God Class (923 lignes) → Architecture modulaire SOLID
///
/// **MIGRATION ARCHITECTURE** :
/// - God Class unique (923 lignes, 7 responsabilités mélangées)
/// - ✅ 5 Services spécialisés (904 lignes total)
/// - ✅ 1 Coordinateur SOLID (249 lignes)
/// - ✅ Total: 1153 lignes (+25% mais SOLID respecté)
///
/// **SOLID PRINCIPLES IMPLEMENTED** :
/// - **SRP** : Chaque service = 1 responsabilité unique
/// - **OCP** : Services extensibles via injection
/// - **LSP** : Interfaces respectées partout
/// - **ISP** : Interfaces segregées par domaine
/// - **DIP** : Injection de dépendances généralisée

// ==================== REDIRECTION VERS NOUVELLE ARCHITECTURE ====================

/// **Services spécialisés par responsabilité**
export 'services/lists_persistence_service.dart';      // CRUD listes (204 lignes)
export 'services/items_persistence_service.dart';      // CRUD items (243 lignes)
export 'services/data_management_service.dart';        // Clear/reload/sync (128 lignes)
export 'services/migration_service.dart';              // Migration strategies (171 lignes)
export 'services/deduplication_service.dart';          // Déduplication (158 lignes)

/// **Coordinateur principal - Point d'entrée unique**
export 'persistence_coordinator.dart';                 // Orchestration SOLID (249 lignes)

/// **Interfaces et configuration**
export 'interfaces/unified_persistence_interface.dart';

/// **Classes de configuration conservées**
///
/// Ces classes étaient dans le God Class original et sont maintenant
/// disponibles via les exports ci-dessus pour compatibilité.
///
/// **UnifiedPersistenceConfiguration** : Configuration système
/// **UnifiedPersistenceValidator** : Validation des données
/// **PersistenceCoordinator** : Point d'entrée principal (remplace UnifiedPersistenceService)

// ==================== NOTES DE MIGRATION ====================

/// **COMMENT MIGRER** :
///
/// **Avant (God Class)** :
/// ```dart
/// final service = UnifiedPersistenceService(...);
/// await service.saveList(list);
/// ```
///
/// **Après (Architecture SOLID)** :
/// ```dart
/// final coordinator = PersistenceCoordinator(
///   listsService: ListsPersistenceService(...),
///   itemsService: ItemsPersistenceService(...),
///   dataManagementService: DataManagementService(...),
///   migrationService: MigrationService(...),
///   deduplicationService: DeduplicationService(...),
///   logger: logger,
///   config: config,
/// );
/// await coordinator.saveList(list);
/// ```
///
/// **Interface identique** : Le PersistenceCoordinator implémente
/// IUnifiedPersistenceService donc l'API reste compatible.

/// **BENEFITS DE LA NOUVELLE ARCHITECTURE** :
/// - ✅ **Maintenabilité** : Chaque service < 250 lignes
/// - ✅ **Testabilité** : Services isolés et mockables
/// - ✅ **Extensibilité** : Ajout de nouveaux services sans impact
/// - ✅ **Séparation des responsabilités** : SRP respecté partout
/// - ✅ **Inversion de dépendances** : DIP appliqué systématiquement