import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'package:prioris/data/repositories/interfaces/repository_interfaces.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/data/providers/consent_providers.dart';
import 'package:prioris/data/providers/service_providers.dart';

/// SOLID: Exception personalizada para erros de inicialização
/// Clean Code: Nomes explícitos e mensagens claras
class AdaptivePersistenceInitializationException implements Exception {
  final String message;
  final Object? cause;

  const AdaptivePersistenceInitializationException(this.message, this.cause);

  @override
  String toString() => 'AdaptivePersistenceInitializationException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// SOLID: Exception personalizada para erros de inicialização do DataMigrationService
/// Clean Code: Separação de responsabilidades com exceptions específicas
class DataMigrationServiceInitializationException implements Exception {
  final String message;
  final Object? cause;

  const DataMigrationServiceInitializationException(this.message, this.cause);

  @override
  String toString() => 'DataMigrationServiceInitializationException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// SOLID-compliant factory provider
/// Dependency Inversion: Uses abstraction instead of concrete implementation
final repositoryFactoryProvider = Provider<IRepositoryFactory>((ref) {
  return HiveRepositoryFactory();
});

/// SOLID-compliant repository manager provider
/// Single Responsibility: Manages repository access through factory
final repositoryManagerProvider = Provider<RepositoryManager>((ref) {
  return RepositoryManager.instance;
});

/// SOLID-compliant Hive custom list repository provider
/// Dependency Inversion: Depends on factory abstraction
final hiveCustomListRepositoryProvider = FutureProvider<CustomListRepository>((ref) async {
  final manager = ref.watch(repositoryManagerProvider);
  return await manager.getCustomListRepository();
});

/// SOLID-compliant Hive list item repository provider
/// Dependency Inversion: Depends on factory abstraction
final hiveListItemRepositoryProvider = FutureProvider<ListItemRepository>((ref) async {
  final manager = ref.watch(repositoryManagerProvider);
  return await manager.getListItemRepository();
});

/// SOLID-compliant repository factory interface
/// Single Responsibility: Creates repositories
/// Dependency Inversion: Depends on abstractions, not concretions
abstract class IRepositoryFactory {
  Future<CustomListRepository> createCustomListRepository();
  Future<ListItemRepository> createListItemRepository();
  Future<void> dispose();
}

/// SOLID-compliant Hive repository factory
/// Single Responsibility: Creates and manages Hive repositories
/// Open/Closed: Can be extended without modification
/// Liskov Substitution: Properly implements IRepositoryFactory
class HiveRepositoryFactory implements IRepositoryFactory {
  final Map<Type, dynamic> _repositoryCache = {};
  bool _isDisposed = false;

  @override
  Future<CustomListRepository> createCustomListRepository() async {
    if (_isDisposed) {
      throw StateError('Factory has been disposed');
    }

    if (_repositoryCache.containsKey(HiveCustomListRepository)) {
      return _repositoryCache[HiveCustomListRepository] as HiveCustomListRepository;
    }

    final repository = HiveCustomListRepository();
    await repository.initialize();
    _repositoryCache[HiveCustomListRepository] = repository;
    return repository;
  }

  @override
  Future<ListItemRepository> createListItemRepository() async {
    if (_isDisposed) {
      throw StateError('Factory has been disposed');
    }

    if (_repositoryCache.containsKey(HiveListItemRepository)) {
      return _repositoryCache[HiveListItemRepository] as HiveListItemRepository;
    }

    final repository = HiveListItemRepository();
    await repository.initialize();
    _repositoryCache[HiveListItemRepository] = repository;
    return repository;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    for (final repository in _repositoryCache.values) {
      try {
        if (repository is HiveCustomListRepository) {
          await repository.dispose();
        } else if (repository is HiveListItemRepository) {
          await repository.close();
        }
      } catch (e) {
        // Log error but continue disposal
        // Pending: Replace with proper logging service
        // ignore: avoid_print
        print('Warning: Error disposing repository: $e');
      }
    }

    _repositoryCache.clear();
    _isDisposed = true;
  }
}

/// SOLID-compliant repository manager
/// Single Responsibility: Manages repository lifecycle and access
/// Dependency Inversion: Depends on IRepositoryFactory abstraction
class RepositoryManager {
  final IRepositoryFactory _factory;
  static RepositoryManager? _instance;

  RepositoryManager._(this._factory);

  static Future<void> initialize({
    IRepositoryFactory? factory,
  }) async {
    if (_instance != null) return;

    final repositoryFactory = factory ?? HiveRepositoryFactory();
    _instance = RepositoryManager._(repositoryFactory);
  }

  static RepositoryManager get instance {
    if (_instance == null) {
      throw StateError('RepositoryManager not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  Future<CustomListRepository> getCustomListRepository() =>
      _factory.createCustomListRepository();

  Future<ListItemRepository> getListItemRepository() =>
      _factory.createListItemRepository();

  static Future<void> dispose() async {
    if (_instance != null) {
      await _instance!._factory.dispose();
      _instance = null;
    }
  }
}

/// SOLID-compliant main custom list repository provider
/// Liskov Substitution: Returns consistent interface type
/// Dependency Inversion: Uses abstraction through factory
final customListRepositoryProvider = FutureProvider<CustomListRepository>((ref) async {
  return await ref.watch(hiveCustomListRepositoryProvider.future);
});

/// SOLID-compliant main list item repository provider
/// Liskov Substitution: Returns consistent interface type
/// Dependency Inversion: Uses abstraction through factory
final listItemRepositoryProvider = FutureProvider<ListItemRepository>((ref) async {
  return await ref.watch(hiveListItemRepositoryProvider.future);
});

/// Synchronous wrapper for backward compatibility
/// Note: This should be phased out in favor of async providers
final customListRepositorySyncProvider = Provider<Future<CustomListRepository>>((ref) {
  return ref.watch(customListRepositoryProvider.future);
});

/// Synchronous wrapper for backward compatibility
/// Note: This should be phased out in favor of async providers
final listItemRepositorySyncProvider = Provider<Future<ListItemRepository>>((ref) {
  return ref.watch(listItemRepositoryProvider.future);
});


/// ARCHITECTURE FIX: Provider adaptatif stable pour les éléments de liste
///
/// SOLID: Single Responsibility - délègue la sélection au service spécialisé
/// Clean Code: Provider concis utilisant le service de sélection
final adaptiveListItemRepositoryProvider = FutureProvider<ListItemRepository>((ref) async {
  final useCloud = ref.watch(useCloudRepositoryProvider);
  return await RepositorySelectionService.selectListItemRepository(ref, useCloud);
});

/// Provider synchrone pour compatibilité ascendante - À SUPPRIMER PROGRESSIVEMENT
/// Clean Code: Marquer comme dépréciée pour encourager migration vers async
@Deprecated('Use adaptiveListItemRepositoryProvider.future instead')
final adaptiveListItemRepositorySyncProvider = Provider<Future<ListItemRepository>>((ref) {
  return ref.watch(adaptiveListItemRepositoryProvider.future);
});

// Provider moved to service_providers.dart to avoid duplication
// Use supabaseListItemRepositoryProvider from service_providers.dart instead

// ========== NOUVEAUX PROVIDERS SUPABASE ==========

/// ARCHITECTURE FIX: Provider adaptatif stable pour les listes personnalisées
///
/// SOLID: Single Responsibility - délègue la sélection au service spécialisé
/// Clean Code: Provider concis utilisant le service de sélection
final adaptiveCustomListRepositoryProvider = FutureProvider<CustomListCrudRepositoryInterface>((ref) async {
  final useCloud = ref.watch(useCloudRepositoryProvider);
  return await RepositorySelectionService.selectCustomListRepository(ref, useCloud);
});

/// Provider synchrone pour compatibilité ascendante - À SUPPRIMER PROGRESSIVEMENT
/// Clean Code: Marquer comme dépréciée pour encourager migration vers async
@Deprecated('Use adaptiveCustomListRepositoryProvider.future instead')
final adaptiveCustomListRepositorySyncProvider = Provider<Future<CustomListCrudRepositoryInterface>>((ref) {
  return ref.watch(adaptiveCustomListRepositoryProvider.future);
});

// Provider moved to service_providers.dart to avoid duplication
// Use supabaseCustomListRepositoryProvider from service_providers.dart instead

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

// ========== REPOSITORY SELECTION STRATEGIES ==========

/// SOLID: Single Responsibility - determina qual repository usar baseado na auth
/// e no consentement RGPD (story 10.18).
/// Clean Code: Função pura, sem efeitos colaterais.
///
/// RGPD Art. 6.1/7.3 : sur les stratégies automatiques (auto/hybrid), aucune
/// donnée personnelle ne part vers le cloud sans consentement valide. Retirer
/// le consentement gèle donc le traitement en basculant sur le stockage local.
bool shouldUseCloudRepository(
  bool isSignedIn,
  bool hasConsent,
  RepositoryStrategy strategy,
) {
  switch (strategy) {
    case RepositoryStrategy.auto:
      return isSignedIn && hasConsent;
    case RepositoryStrategy.supabase:
      return true;
    case RepositoryStrategy.hive:
      return false;
    case RepositoryStrategy.hybrid:
      return isSignedIn && hasConsent; // cloud si authentifié ET consentant
  }
}

/// Décision cloud/local dérivée (auth + consentement + stratégie).
///
/// Provider intermédiaire : en n'exposant qu'un booléen, les repositories
/// adaptatifs ne se reconstruisent que lorsque la DÉCISION change réellement.
/// Une transition d'AsyncValue du consentement (loading→data) qui ne modifie
/// pas le booléen ne propage donc aucun rebuild (Riverpod compare par ==).
final useCloudRepositoryProvider = Provider<bool>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  final hasConsent = ref.watch(consentProvider.select((s) => s.value ?? false));
  final strategy = ref.watch(repositoryStrategyProvider);
  return shouldUseCloudRepository(isSignedIn, hasConsent, strategy);
});

/// SOLID: Single Responsibility - cria repositories seguindo estratégia
/// Clean Code: Factory method com responsabilidade única
class RepositorySelectionService {
  static Future<ListItemRepository> selectListItemRepository(
    Ref ref,
    bool useCloud,
  ) async {
    if (useCloud) {
      return ref.read(supabaseListItemRepositoryProvider);
    } else {
      return await ref.watch(hiveListItemRepositoryProvider.future);
    }
  }

  static Future<CustomListCrudRepositoryInterface> selectCustomListRepository(
    Ref ref,
    bool useCloud,
  ) async {
    if (useCloud) {
      return ref.read(supabaseCustomListRepositoryProvider);
    } else {
      return await ref.watch(hiveCustomListRepositoryProvider.future);
    }
  }
}

// ========== ADAPTIVE PERSISTENCE SERVICE ==========

/// Provider pour l'AdaptivePersistenceService - Solution intelligente de persistance
///
/// Gère automatiquement le choix entre stockage local et cloud selon l'authentification
/// avec migration transparente des données et synchronisation en arrière-plan.
/* DISABLED: Service removed during cleanup
final adaptivePersistenceServiceProvider = FutureProvider<AdaptivePersistenceService>((ref) async {
  // Repositories locaux (Hive) - attendre leur initialisation
  final localCustomListRepository = await ref.watch(hiveCustomListRepositoryProvider.future);
  final localItemRepository = await ref.watch(hiveListItemRepositoryProvider.future);

  // Repositories cloud (Supabase)
  final cloudCustomListRepository = ref.read(supabaseCustomListRepositoryProvider);
  final cloudItemRepository = ref.read(supabaseListItemRepositoryProvider);

  return AdaptivePersistenceService(
    localRepository: localCustomListRepository,
    cloudRepository: cloudCustomListRepository,
    localItemRepository: localItemRepository,
    cloudItemRepository: cloudItemRepository,
  );
});
*/ // END DISABLED adaptivePersistenceServiceProvider

/// Provider pour l'initialisation de l'AdaptivePersistenceService
/* DISABLED: Service removed during cleanup
final adaptivePersistenceInitProvider = FutureProvider<AdaptivePersistenceService>((ref) async {
  try {
    final service = await ref.watch(adaptivePersistenceServiceProvider.future);
    final isSignedIn = ref.watch(isSignedInProvider);

    // Initialiser le service avec l'état d'authentification actuel
    await service.initialize(isAuthenticated: isSignedIn);

    return service;
  } catch (error) {
    throw AdaptivePersistenceInitializationException(
      'Failed to initialize AdaptivePersistenceService',
      error,
    );
  }
});
*/ // END DISABLED adaptivePersistenceInitProvider

/// Provider qui écoute les changements d'authentification pour l'AdaptivePersistenceService
/* DISABLED: Service removed during cleanup
///
/// Met automatiquement à jour le service quand l'utilisateur se connecte/déconnecte
/// SOLID: Single Responsibility - gère uniquement l'écoute des changements d'auth
/// Clean Code: Gestion d'erreur et logging amélioré
final adaptivePersistenceListenerProvider = Provider<void>((ref) {
  // Écouter les changements d'authentification
  ref.listen<bool>(isSignedInProvider, (previous, current) async {
    if (previous != null && previous != current) {
      try {
        final service = await ref.read(adaptivePersistenceServiceProvider.future);

        // L'état d'authentification a changé
        // Pending: Replace with proper logging service
        // ignore: avoid_print
        print('🔄 Authentification changée: $previous → $current');
        await service.updateAuthenticationState(isAuthenticated: current);
      } catch (error) {
        // Pending: Replace with proper logging service
        // ignore: avoid_print
        print('⚠️ Erreur lors de la mise à jour du service de persistance: $error');
      }
    }
  });
});
*/ // END DISABLED adaptivePersistenceListenerProvider

// ========== DATA MIGRATION SERVICE ==========
// DISABLED: Service removed during cleanup