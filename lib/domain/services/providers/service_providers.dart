import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/interfaces/cache_interface.dart';
import '../cache/cache_service.dart';
import '../core/interfaces/error_handler_interface.dart';
import '../core/error_handling_service.dart';
import '../core/error_classification_service.dart';
import '../core/error_logger_service.dart';
import '../core/interfaces/list_service_interface.dart';
import '../core/custom_list_service.dart';
import '../../../data/providers/repository_providers.dart';

/// Provider pour le service de cache principal
final cacheServiceProvider = Provider<CacheInterface>((ref) {
  return CacheService();
});

/// Providers pour la gestion d'erreurs
final errorClassifierProvider = Provider<ErrorClassifierInterface>((ref) {
  return ErrorClassificationService();
});

final errorLoggerProvider = Provider<ErrorLoggerInterface>((ref) {
  return ErrorLoggerService();
});

final errorHandlerProvider = Provider<ErrorHandlerInterface>((ref) {
  return ErrorHandlingService(
    ref.read(errorClassifierProvider),
    ref.read(errorLoggerProvider),
  );
});

/// Providers pour les services de listes (async pour FutureProvider compatibility)
final listCrudServiceProvider = FutureProvider<ListCrudInterface>((ref) async {
  final repository = await ref.watch(customListRepositoryProvider.future);
  return CustomListCrudService(repository);
});

final listSearchServiceProvider = FutureProvider<ListSearchInterface>((ref) async {
  final repository = await ref.watch(customListRepositoryProvider.future);
  return CustomListSearchService(repository);
});

final listStatsServiceProvider = FutureProvider<ListStatsInterface>((ref) async {
  final repository = await ref.watch(customListRepositoryProvider.future);
  return CustomListStatsService(repository);
});

final customListServiceProvider = FutureProvider<CustomListService>((ref) async {
  final crudService = await ref.watch(listCrudServiceProvider.future);
  final searchService = await ref.watch(listSearchServiceProvider.future);
  final statsService = await ref.watch(listStatsServiceProvider.future);

  return CustomListService(
    crudService,
    searchService,
    statsService,
  );
});

/// Provider pour l'instance par défaut du gestionnaire d'erreurs
/// (pour compatibilité avec le code existant)
final defaultErrorHandlerProvider = Provider<ErrorHandlingService>((ref) {
  return ErrorHandlingService.defaultInstance();
});