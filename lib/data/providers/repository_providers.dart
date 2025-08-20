import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/data/repositories/interfaces/repository_interfaces.dart';
import 'package:prioris/data/providers/auth_providers.dart';

/// Provider asynchrone pour le repository Hive des listes personnalisées
/// 
/// Ce provider utilise HiveCustomListRepository pour la persistance locale
/// et s'initialise automatiquement au démarrage de l'application.
final hiveCustomListRepositoryProvider = FutureProvider<HiveCustomListRepository>((ref) async {
  final repository = HiveCustomListRepository();
  
  // Initialiser automatiquement le repository
  await repository.initialize();
  
  return repository;
});

/// Provider asynchrone pour le repository Hive des éléments de liste
/// 
/// Ce provider utilise HiveListItemRepository pour la persistance locale des items
/// et s'initialise automatiquement au démarrage de l'application.
final hiveListItemRepositoryProvider = FutureProvider<HiveListItemRepository>((ref) async {
  final repository = HiveListItemRepository();
  
  // Initialiser automatiquement le repository
  await repository.initialize();
  
  return repository;
});

/// Provider pour le repository des listes personnalisées
/// 
/// Par défaut, utilise le repository Hive pour la persistance locale.
/// Peut être remplacé par InMemoryCustomListRepository pour les tests.
final customListRepositoryProvider = Provider<CustomListRepository>((ref) {
  final hiveRepositoryAsync = ref.watch(hiveCustomListRepositoryProvider);
  
  // Retourner un repository temporaire pendant le chargement
  return hiveRepositoryAsync.when(
    data: (repository) => repository,
    loading: () => InMemoryCustomListRepository(),
    error: (error, stack) => InMemoryCustomListRepository(),
  );
});

/// Provider pour le repository des listes personnalisées (version asynchrone)
/// 
/// Utilisé quand on a besoin d'attendre l'initialisation complète
final customListRepositoryAsyncProvider = FutureProvider<CustomListRepository>((ref) async {
  final repository = await ref.watch(hiveCustomListRepositoryProvider.future);
  return repository;
});

/// Provider pour le repository des éléments de liste
/// 
/// CORRIGÉ: Utilise maintenant HiveListItemRepository pour la persistance locale
/// au lieu de InMemoryListItemRepository qui perdait les données au redémarrage.
final listItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  final hiveRepositoryAsync = ref.watch(hiveListItemRepositoryProvider);
  
  // Retourner un repository temporaire pendant le chargement
  return hiveRepositoryAsync.when(
    data: (repository) => repository,
    loading: () => InMemoryListItemRepository(),
    error: (error, stack) => InMemoryListItemRepository(),
  );
});

/// Provider pour le repository des éléments de liste (version asynchrone)
/// 
/// Utilisé quand on a besoin d'attendre l'initialisation complète
final listItemRepositoryAsyncProvider = FutureProvider<ListItemRepository>((ref) async {
  final repository = await ref.watch(hiveListItemRepositoryProvider.future);
  return repository;
});

/// Provider adaptatif pour les éléments de liste (Hive/Supabase selon auth)
final adaptiveListItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  
  // Si connecté, utilise Supabase, sinon utilise Hive pour persistance locale
  if (isSignedIn) {
    return SupabaseListItemRepository();
  } else {
    // Utilise maintenant Hive au lieu de InMemory pour la persistance
    final hiveRepositoryAsync = ref.watch(hiveListItemRepositoryProvider);
    return hiveRepositoryAsync.when(
      data: (repository) => repository,
      loading: () => InMemoryListItemRepository(),
      error: (error, stack) => InMemoryListItemRepository(),
    );
  }
});

/// Provider pour repository Supabase des éléments de liste
final supabaseListItemRepositoryProvider = Provider<SupabaseListItemRepository>((ref) {
  return SupabaseListItemRepository();
});

// ========== NOUVEAUX PROVIDERS SUPABASE ==========

/// Provider pour choisir entre repository Hive (offline) et Supabase (online)
final adaptiveCustomListRepositoryProvider = Provider<CustomListCrudRepositoryInterface>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  
  // Si connecté, utilise Supabase, sinon utilise Hive
  if (isSignedIn) {
    return SupabaseCustomListRepository();
  } else {
    // Fallback vers Hive pour mode offline
    final hiveRepoAsync = ref.watch(hiveCustomListRepositoryProvider);
    return hiveRepoAsync.when(
      data: (repo) => repo,
      loading: () => InMemoryCustomListRepository(),
      error: (_, __) => InMemoryCustomListRepository(),
    );
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