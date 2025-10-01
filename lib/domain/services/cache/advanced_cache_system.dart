/// **ADVANCED CACHE SYSTEM** - Redirection vers architecture SOLID
///
/// **LOT 10 ULTRATHINK COMPLETE** : God Class (658 lignes) → Architecture modulaire SOLID
///
/// **MIGRATION ARCHITECTURE** :
/// - God Class unique (658 lignes, 8 responsabilités mélangées)
/// - ✅ 4 Services spécialisés (511 lignes total)
/// - ✅ 1 Coordinateur SOLID (190 lignes)
/// - ✅ Total: 701 lignes (+7% mais SOLID respecté)
///
/// **SOLID PRINCIPLES IMPLEMENTED** :
/// - **SRP** : Chaque service = 1 responsabilité unique
/// - **OCP** : Services extensibles via injection
/// - **LSP** : Interfaces respectées partout
/// - **ISP** : Interfaces segregées par domaine
/// - **DIP** : Injection de dépendances généralisée

// ==================== REDIRECTION VERS NOUVELLE ARCHITECTURE ====================

/// **Services spécialisés par responsabilité**
export 'services/cache_operations_service.dart';       // Get/Set/GetOrCompute (200 lignes)
export 'services/tag_management_service.dart';         // Tags et invalidation (127 lignes)
export 'services/invalidation_service.dart';           // Invalidation patterns (101 lignes)
export 'services/statistics_service.dart';             // Monitoring et stats (83 lignes)

/// **Coordinateur principal - Point d'entrée unique**
export 'cache_coordinator.dart';                       // Orchestration SOLID (190 lignes)

/// **Dépendances système**
export 'cache_policies.dart';
export 'cache_statistics.dart';
export 'cache_entry.dart';

// ==================== NOTES DE MIGRATION ====================

/// **COMMENT MIGRER** :
///
/// **Avant (God Class)** :
/// ```dart
/// final cache = AdvancedCacheSystem(config: config);
/// await cache.get('key');
/// await cache.setWithTags('key', value, ['tag1']);
/// ```
///
/// **Après (Architecture SOLID)** :
/// ```dart
/// final cache = CacheCoordinator(config: config);
/// await cache.get('key');
/// await cache.setWithTags('key', value, ['tag1']);
/// ```
///
/// **Interface identique** : Le CacheCoordinator expose la même API
/// que l'ancien AdvancedCacheSystem.

/// **BENEFITS DE LA NOUVELLE ARCHITECTURE** :
/// - ✅ **Maintenabilité** : Chaque service < 200 lignes
/// - ✅ **Testabilité** : Services isolés et mockables
/// - ✅ **Extensibilité** : Ajout de nouveaux services sans impact
/// - ✅ **Séparation des responsabilités** : SRP respecté partout
/// - ✅ **Performance** : Coordination optimisée

/// **RESPONSABILITÉS DÉCOMPOSÉES** :
/// 1. **CacheOperationsService** : Opérations CRUD de base
/// 2. **TagManagementService** : Gestion des tags et invalidation
/// 3. **InvalidationService** : Invalidation par patterns
/// 4. **StatisticsService** : Monitoring et métriques
/// 5. **CacheCoordinator** : Orchestration et API unifiée

/// **UTILISATION RECOMMANDÉE** :
/// ```dart
/// import 'package:prioris/domain/services/cache/advanced_cache_system.dart';
///
/// // Utiliser le coordinateur comme point d'entrée unique
/// final cache = CacheCoordinator(
///   config: CacheConfig(
///     memorySize: 100,
///     defaultTtl: Duration(minutes: 30),
///     persistentCacheEnabled: true,
///   ),
/// );
///
/// // API identique à l'ancien système
/// await cache.set('user:123', userData);
/// final user = await cache.get<UserData>('user:123');
/// await cache.setWithTags('session:456', session, ['user:123', 'active']);
/// ```