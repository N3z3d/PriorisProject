import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/data/providers/service_providers.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';

/// Providers Clean - Élimination des problèmes Riverpod
/// 
/// Cette approche clean évite les modifications croisées de providers
/// pendant l'initialisation en utilisant des providers simples et indépendants.

// ========== PROVIDERS DE BASE - SIMPLES ET STABLES ==========

/// Provider Hive Custom List Repository - Simple et Direct
final hiveCustomListRepositoryProvider = Provider<HiveCustomListRepository>((ref) {
  return HiveCustomListRepository();
});

/// Provider Hive List Item Repository - Simple et Direct  
final hiveListItemRepositoryProvider = Provider<HiveListItemRepository>((ref) {
  return HiveListItemRepository();
});

// Providers moved to service_providers.dart to avoid duplication and ensure proper dependency injection
// Use supabaseCustomListRepositoryProvider and supabaseListItemRepositoryProvider from service_providers.dart

// ========== PROVIDERS ADAPTATIFS - SANS MODIFICATION CROISÉE ==========

/// Provider adaptatif pour Custom Lists - READ ONLY
/// 
/// N'initie AUCUNE modification d'autres providers
/// Se contente de sélectionner le repository approprié selon l'auth
final adaptiveCustomListRepositoryProvider = Provider<CustomListRepository>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  
  if (isSignedIn) {
    return ref.watch(supabaseCustomListRepositoryProvider);
  } else {
    return ref.watch(hiveCustomListRepositoryProvider);
  }
});

/// Provider adaptatif pour List Items - READ ONLY
/// 
/// N'initie AUCUNE modification d'autres providers  
/// Se contente de sélectionner le repository approprié selon l'auth
final adaptiveListItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);
  
  if (isSignedIn) {
    return ref.watch(supabaseListItemRepositoryProvider);
  } else {
    return ref.watch(hiveListItemRepositoryProvider);
  }
});

// ========== ADAPTIVE PERSISTENCE SERVICE - CLEAN ==========

/// Provider clean pour AdaptivePersistenceService
/// 
/// Crée le service SANS déclencher d'initialization automatique
/// L'initialization sera faite manuellement par le controller
final adaptivePersistenceServiceProvider = Provider<AdaptivePersistenceService>((ref) {
  final localCustomListRepository = ref.watch(hiveCustomListRepositoryProvider);
  final localItemRepository = ref.watch(hiveListItemRepositoryProvider);
  final cloudCustomListRepository = ref.watch(supabaseCustomListRepositoryProvider);
  final cloudItemRepository = ref.watch(supabaseListItemRepositoryProvider);
  
  // CLEAN: Juste créer le service, PAS d'initialization automatique
  return AdaptivePersistenceService(
    localRepository: localCustomListRepository,
    cloudRepository: cloudCustomListRepository,
    localItemRepository: localItemRepository,
    cloudItemRepository: cloudItemRepository,
  );
});

// ========== PROVIDERS LEGACY POUR COMPATIBILITÉ ==========

/// Provider principal pour Custom Lists (rétrocompatible)
final customListRepositoryProvider = Provider<CustomListRepository>((ref) {
  return ref.watch(adaptiveCustomListRepositoryProvider);
});

/// Provider principal pour List Items (rétrocompatible)
final listItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  return ref.watch(adaptiveListItemRepositoryProvider);
});

// ========== ÉTAT DE STRATÉGIE - SIMPLE ==========

/// Provider pour la stratégie de repository - Simple StateProvider
final repositoryStrategyProvider = StateProvider<RepositoryStrategy>((ref) {
  return RepositoryStrategy.auto;
});

/// Enum pour choisir la stratégie de repository
enum RepositoryStrategy {
  auto,      // Auto: Supabase si connecté, sinon Hive
  supabase,  // Force Supabase (online only)
  hive,      // Force Hive (offline only)
}