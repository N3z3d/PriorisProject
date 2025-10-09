import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/user_data_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

/// Service providers with proper dependency injection
/// Eliminates hidden singletons and makes dependencies explicit

/// Core infrastructure services
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance; // Pending: Make this configurable too
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance; // Pending: Make this configurable too  
});

final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService.instance; // Pending: Make this injectable
});

/// Repository providers with dependency injection
final supabaseCustomListRepositoryProvider = Provider<SupabaseCustomListRepository>((ref) {
  return SupabaseCustomListRepository(
    supabaseService: ref.read(supabaseServiceProvider),
    authService: ref.read(authServiceProvider),
  );
});

final supabaseListItemRepositoryProvider = Provider<SupabaseListItemRepository>((ref) {
  return SupabaseListItemRepository(
    supabaseService: ref.read(supabaseServiceProvider),
    authService: ref.read(authServiceProvider),
  );
});

/// Interface providers - consumers depend on interfaces, not implementations
final customListRepositoryProvider = Provider<CustomListRepository>((ref) {
  // In production: return Supabase implementation
  // In tests: can easily be overridden with mocks
  return ref.read(supabaseCustomListRepositoryProvider);
});

final listItemRepositoryProvider = Provider<ListItemRepository>((ref) {
  // In production: return Supabase implementation  
  // In tests: can easily be overridden with mocks
  return ref.read(supabaseListItemRepositoryProvider);
});

/// Service providers with dependency injection
final userDataServiceProvider = Provider<UserDataService>((ref) {
  return UserDataService(
    supabaseService: ref.read(supabaseServiceProvider),
    authService: ref.read(authServiceProvider),
  );
});