import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/interfaces/cache_interface.dart';
import '../cache/core_cache_service.dart';
import '../cache/cache_expiration_service.dart';
import '../cache/cache_stats_service.dart';
import '../core/interfaces/error_handler_interface.dart';
import '../core/error_handling_service.dart';
import '../core/error_classification_service.dart';
import '../core/error_logger_service.dart';
import '../core/interfaces/list_service_interface.dart';
import '../core/custom_list_service.dart';
import '../../../data/providers/repository_providers.dart';

/// Providers pour les services de cache
final coreCacheServiceProvider = Provider<CacheInterface>((ref) {
  return CoreCacheService(maxSize: 1000);
});

final cacheStatsServiceProvider = Provider((ref) {
  return CacheStatsService(ref.read(coreCacheServiceProvider));
});

final cacheExpirationServiceProvider = Provider<CacheExpirationService>((ref) {
  return CacheExpirationService(
    ref.read(coreCacheServiceProvider),
    defaultTTL: const Duration(hours: 24),
  );
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

/// Providers pour les services de listes
final listCrudServiceProvider = Provider<ListCrudInterface>((ref) {
  return CustomListCrudService(ref.read(customListRepositoryProvider));
});

final listSearchServiceProvider = Provider<ListSearchInterface>((ref) {
  return CustomListSearchService(ref.read(customListRepositoryProvider));
});

final listStatsServiceProvider = Provider<ListStatsInterface>((ref) {
  return CustomListStatsService(ref.read(customListRepositoryProvider));
});

final customListServiceProvider = Provider<CustomListService>((ref) {
  return CustomListService(
    ref.read(listCrudServiceProvider),
    ref.read(listSearchServiceProvider),
    ref.read(listStatsServiceProvider),
  );
});

/// Provider pour l'instance par défaut du gestionnaire d'erreurs
/// (pour compatibilité avec le code existant)
final defaultErrorHandlerProvider = Provider<ErrorHandlingService>((ref) {
  return ErrorHandlingService.defaultInstance();
});