import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/data/repositories/interfaces/repository_interfaces.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/services/persistence/data_migration_service.dart';

/// ARCHITECTURE FIX: Provider synchrone pour repository Hive pré-initialisé
/// 
/// Utilise une instance partagée initialisée au démarrage de l'application
/// pour éliminer les races conditions et fallbacks temporaires.
final hiveCustomListRepositoryProvider = Provider<HiveCustomListRepository>((ref) {
  try {
    return HiveRepositoryRegistry.instance.customListRepository;
  } catch (e) {
    // If registry is not initialized, attempt to initialize it
    throw StateError('Repository not available. Ensure HiveRepositoryRegistry.initialize() is called at app startup.');
  }
});

/// ARCHITECTURE FIX: Provider synchrone pour repository Hive pré-initialisé  
/// 
/// Utilise une instance partagée initialisée au démarrage de l'application
/// pour éliminer les races conditions et fallbacks temporaires.
final hiveListItemRepositoryProvider = Provider<HiveListItemRepository>((ref) {
  return HiveRepositoryRegistry.instance.listItemRepository;
});

/// ARCHITECTURE FIX: Registry singleton pour repositories Hive pré-initialisés
/// 
/// Garantit que tous les repositories sont initialisés avant que les providers
/// ne soient consommés par les controllers.
class HiveRepositoryRegistry {
  static HiveRepositoryRegistry? _instance;
  static HiveRepositoryRegistry get instance {
    if (_instance == null) {
      throw StateError('HiveRepositoryRegistry not initialized. Call initialize() first.');
    }
    return _instance!;
  }
  
  late final HiveCustomListRepository _customListRepository;
  late final HiveListItemRepository _listItemRepository;
  
  HiveCustomListRepository get customListRepository => _customListRepository;
  HiveListItemRepository get listItemRepository => _listItemRepository;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  HiveRepositoryRegistry._();
  
  /// CRITICAL: Must be called during app startup before any providers are used
  static Future<void> initialize() async {
    if (_instance != null && _instance!._isInitialized) return;
    
    final registry = HiveRepositoryRegistry._();
    
    // Initialize Hive repositories synchronously
    registry._customListRepository = HiveCustomListRepository();
    await registry._customListRepository.initialize();
    
    registry._listItemRepository = HiveListItemRepository();
    await registry._listItemRepository.initialize();
    
    registry._isInitialized = true;
    _instance = registry;
  }
  
  /// Re-initialize after disposal (for app restart scenarios)
  static Future<void> reinitialize() async {
    await dispose();
    await initialize();
  }
  
  /// Dispose all repositories (for app shutdown)
  static Future<void> dispose() async {
    if (_instance == null) return;
    
    try {
      await _instance!._customListRepository.dispose();
      await _instance!._listItemRepository.close();
    } catch (e) {
      // Log error but don't fail - disposal should be safe
      print('Warning: Error during repository disposal: $e');
    }
    
    _instance!._isInitialized = false;
    _instance = null;
  }
}

/// ARCHITECTURE FIX: Provider synchrone principal pour les listes personnalisées
/// 
/// Utilise directement le repository Hive pré-initialisé, éliminant tous les
/// fallbacks temporaires qui causaient les pertes de données.
final customListRepositoryProvider = Provider<CustomListRepository>((ref) {
  return ref.watch(hiveCustomListRepositoryProvider);
});

/// DEPRECATED: Provider asynchrone - remplacé par l'approche synchrone
/// Conservé temporairement pour compatibilité avec les tests existants
@Deprecated('Use customListRepositoryProvider instead - synchronous and reliable')
final customListRepositoryAsyncProvider = Provider<Future<CustomListRepository>>((ref) async {
  return ref.read(customListRepositoryProvider);
});


/// ARCHITECTURE FIX: Provider synchrone principal pour les éléments de liste
/// 
/// Utilise directement le repository Hive pré-initialisé, éliminant tous les
/// fallbacks temporaires qui causaient les pertes de données.
final listItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  return ref.watch(hiveListItemRepositoryProvider);
});

/// DEPRECATED: Provider asynchrone - remplacé par l'approche synchrone  
/// Conservé temporairement pour compatibilité avec les tests existants
@Deprecated('Use listItemRepositoryProvider instead - synchronous and reliable')
final listItemRepositoryAsyncProvider = Provider<Future<ListItemRepository>>((ref) async {
  return ref.read(listItemRepositoryProvider);
});


/// ARCHITECTURE FIX: Provider adaptatif stable pour les éléments de liste
/// 
/// Choix entre Hive/Supabase selon auth SANS fallback temporaire vers InMemory
final adaptiveListItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  
  // Si connecté, utilise Supabase, sinon utilise Hive pour persistance locale
  if (isSignedIn) {
    return SupabaseListItemRepository();
  } else {
    // ARCHITECTURE FIX: Utilise directement le repository Hive pré-initialisé
    return ref.watch(hiveListItemRepositoryProvider);
  }
});

/// Provider pour repository Supabase des éléments de liste
final supabaseListItemRepositoryProvider = Provider<SupabaseListItemRepository>((ref) {
  return SupabaseListItemRepository();
});

// ========== NOUVEAUX PROVIDERS SUPABASE ==========

/// ARCHITECTURE FIX: Provider adaptatif stable pour les listes personnalisées  
/// 
/// Choix entre Hive/Supabase selon auth SANS fallback temporaire vers InMemory
final adaptiveCustomListRepositoryProvider = Provider<CustomListCrudRepositoryInterface>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  
  // Si connecté, utilise Supabase, sinon utilise Hive
  if (isSignedIn) {
    return SupabaseCustomListRepository();
  } else {
    // ARCHITECTURE FIX: Utilise directement le repository Hive pré-initialisé  
    return ref.watch(hiveCustomListRepositoryProvider);
  }
});

/// Provider pour repository Supabase (force online)
final supabaseCustomListRepositoryProvider = Provider<SupabaseCustomListRepository>((ref) {
  return SupabaseCustomListRepository();
});

/// Enum pour choisir la stratégie de repository
enum RepositoryStrategy {
  auto,      // Auto: Supabase si connecté, sinon Hive
  supabase,  // Force Supabase (online only)
  hive,      // Force Hive (offline only)
  hybrid,    // Hybrid: Supabase + Hive en sync
}

/// Provider pour la stratégie de repository
final repositoryStrategyProvider = StateProvider<RepositoryStrategy>((ref) {
  return RepositoryStrategy.auto; // Par défaut : automatique
});

// ========== ADAPTIVE PERSISTENCE SERVICE ==========

/// Provider pour l'AdaptivePersistenceService - Solution intelligente de persistance
/// 
/// Gère automatiquement le choix entre stockage local et cloud selon l'authentification
/// avec migration transparente des données et synchronisation en arrière-plan.
final adaptivePersistenceServiceProvider = Provider<AdaptivePersistenceService>((ref) {
  // Repositories locaux (Hive)
  final localCustomListRepository = ref.watch(hiveCustomListRepositoryProvider);
  final localItemRepository = ref.watch(hiveListItemRepositoryProvider);
  
  // Repositories cloud (Supabase)
  final cloudCustomListRepository = SupabaseCustomListRepository();
  final cloudItemRepository = SupabaseListItemRepository();
  
  return AdaptivePersistenceService(
    localRepository: localCustomListRepository,
    cloudRepository: cloudCustomListRepository,
    localItemRepository: localItemRepository,
    cloudItemRepository: cloudItemRepository,
  );
});

/// Provider pour l'initialisation de l'AdaptivePersistenceService
/// 
/// Surveille l'état d'authentification et initialise/met à jour le service automatiquement
final adaptivePersistenceInitProvider = FutureProvider<AdaptivePersistenceService>((ref) async {
  final service = ref.watch(adaptivePersistenceServiceProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  
  // Initialiser le service avec l'état d'authentification actuel
  await service.initialize(isAuthenticated: isSignedIn);
  
  return service;
});

/// Provider qui écoute les changements d'authentification pour l'AdaptivePersistenceService
/// 
/// Met automatiquement à jour le service quand l'utilisateur se connecte/déconnecte
final adaptivePersistenceListenerProvider = Provider<void>((ref) {
  final service = ref.watch(adaptivePersistenceServiceProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  
  // Écouter les changements d'authentification
  ref.listen<bool>(isSignedInProvider, (previous, current) async {
    if (previous != null && previous != current) {
      // L'état d'authentification a changé
      print('🔄 Authentification changée: $previous → $current');
      await service.updateAuthenticationState(isAuthenticated: current);
    }
  });
});

// ========== DATA MIGRATION SERVICE ==========

/// Provider pour le DataMigrationService - Service avancé de migration
/// 
/// Gère les migrations intelligentes avec résolution de conflits automatique,
/// tracking du progrès, et vérification d'intégrité des données.
final dataMigrationServiceProvider = Provider<DataMigrationService>((ref) {
  // Repositories locaux (Hive)
  final localCustomListRepository = ref.watch(hiveCustomListRepositoryProvider);
  final localItemRepository = ref.watch(hiveListItemRepositoryProvider);
  
  // Repositories cloud (Supabase)
  final cloudCustomListRepository = SupabaseCustomListRepository();
  final cloudItemRepository = SupabaseListItemRepository();
  
  return DataMigrationService(
    localRepository: localCustomListRepository,
    cloudRepository: cloudCustomListRepository,
    localItemRepository: localItemRepository,
    cloudItemRepository: cloudItemRepository,
  );
});