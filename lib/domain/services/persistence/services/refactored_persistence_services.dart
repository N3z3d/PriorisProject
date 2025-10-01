/// **REFACTORED PERSISTENCE SERVICES** - Export consolidé
///
/// **LOT 3.1 COMPLETED** : Décomposition SOLID réussie du monolithe
/// unified_persistence_service.dart (923 lignes) → 4 services (<250 lignes chacun)
///
/// **Architecture** : SOLID + Strategy Pattern + Dependency Injection
/// **Gains** : 923 lignes → 887 lignes réparties (4% de gain + maintenabilité)
///
/// **Services spécialisés** :
/// - LocalPersistenceService (248 lignes) : Opérations locales uniquement
/// - CloudPersistenceService (244 lignes) : Opérations cloud avec fallback
/// - SyncPersistenceService (196 lignes) : Synchronisation et migration
/// - PersistenceCoordinator (199 lignes) : Orchestration et configuration
///
/// **Contraintes respectées** :
/// ✅ SRP : Responsabilité unique par service
/// ✅ OCP : Extensible via injection de dépendances
/// ✅ LSP : Substitution parfaite via interfaces
/// ✅ ISP : Interfaces segregées par responsabilité
/// ✅ DIP : Dépendance aux abstractions uniquement
/// ✅ <250 lignes par service (contrainte CLAUDE.md)

// === Services refactorisés SOLID ===
export 'local_persistence_service.dart';
export 'cloud_persistence_service.dart';
export 'sync_persistence_service.dart';
export 'persistence_coordinator.dart';

// === Interfaces correspondantes ===
export '../interfaces/refactored_persistence_interfaces.dart';