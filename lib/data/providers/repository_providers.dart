import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

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
/// Utilise InMemoryListItemRepository pour la gestion en mémoire des éléments.
final listItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  return InMemoryListItemRepository();
}); 
