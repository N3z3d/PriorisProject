import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';

/// Service responsible for intelligent list resolution with fallback strategies
/// 
/// This service implements smart URL state management by:
/// 1. Resolving specific list IDs when available
/// 2. Falling back to the first available list when ID is invalid/missing
/// 3. Providing consistent error handling for edge cases
/// 4. Maintaining URL-state synchronization
class ListResolutionService {
  final Ref _ref;
  
  ListResolutionService(this._ref);
  
  /// Resolves a list ID using intelligent fallback strategy
  /// 
  /// Resolution Strategy:
  /// 1. If [requestedListId] is valid and found -> return that list
  /// 2. If [requestedListId] is invalid/null -> return first available list  
  /// 3. If no lists available -> return null (handled by caller)
  /// 
  /// Returns [ListResolutionResult] containing:
  /// - The resolved list (or null if no lists available)
  /// - The resolved list ID for URL updating
  /// - Whether a fallback was used
  ListResolutionResult resolveListWithFallback(String? requestedListId) {
    final listsState = _ref.read(listsControllerProvider);
    final availableLists = listsState.lists;
    
    // Log resolution attempt
    print('🎯 ListResolutionService: Resolving listId="$requestedListId"');
    print('🎯 Available lists: ${availableLists.length}');
    
    // Edge case: No lists available
    if (availableLists.isEmpty) {
      print('⚠️ ListResolutionService: No lists available for resolution');
      return ListResolutionResult(
        resolvedList: null,
        resolvedListId: null,
        usedFallback: false,
        fallbackReason: 'No lists available in the system',
      );
    }
    
    // Try to find requested list if ID provided
    if (requestedListId != null && requestedListId.isNotEmpty) {
      final requestedList = availableLists
          .firstWhereOrNull((list) => list.id == requestedListId);
          
      if (requestedList != null) {
        print('✅ ListResolutionService: Found requested list "${requestedList.name}"');
        return ListResolutionResult(
          resolvedList: requestedList,
          resolvedListId: requestedListId,
          usedFallback: false,
        );
      } else {
        print('⚠️ ListResolutionService: Requested list "$requestedListId" not found, using fallback');
      }
    }
    
    // Fallback: Use first available list
    final firstList = availableLists.first;
    print('🔄 ListResolutionService: Using fallback list "${firstList.name}" (${firstList.id})');
    
    return ListResolutionResult(
      resolvedList: firstList,
      resolvedListId: firstList.id,
      usedFallback: true,
      fallbackReason: requestedListId == null || requestedListId.isEmpty
          ? 'No list ID provided in URL'
          : 'Requested list "$requestedListId" not found',
    );
  }
  
  /// Checks if lists are available for resolution
  bool get hasAvailableLists {
    final listsState = _ref.read(listsControllerProvider);
    return listsState.lists.isNotEmpty;
  }
  
  /// Gets the total number of available lists
  int get availableListsCount {
    final listsState = _ref.read(listsControllerProvider);
    return listsState.lists.length;
  }
  
  /// Gets all available list IDs for validation
  List<String> get availableListIds {
    final listsState = _ref.read(listsControllerProvider);
    return listsState.lists.map((list) => list.id).toList();
  }
}

/// Result of list resolution containing all necessary information
/// for URL state management and UI updates
class ListResolutionResult {
  /// The resolved list (null if no lists available)
  final CustomList? resolvedList;
  
  /// The resolved list ID for URL updating
  final String? resolvedListId;
  
  /// Whether fallback logic was used
  final bool usedFallback;
  
  /// Human-readable reason for fallback (for debugging/logging)
  final String? fallbackReason;
  
  const ListResolutionResult({
    required this.resolvedList,
    required this.resolvedListId,
    required this.usedFallback,
    this.fallbackReason,
  });
  
  /// Whether the resolution was successful
  bool get isSuccessful => resolvedList != null;
  
  /// Whether this represents a "no lists available" state
  bool get isNoListsAvailable => !isSuccessful && !usedFallback;
  
  @override
  String toString() {
    return 'ListResolutionResult('
        'list: ${resolvedList?.name ?? 'null'}, '
        'id: $resolvedListId, '
        'fallback: $usedFallback'
        '${fallbackReason != null ? ', reason: $fallbackReason' : ''}'
        ')';
  }
}

/// Provider for the list resolution service
final listResolutionServiceProvider = Provider<ListResolutionService>((ref) {
  return ListResolutionService(ref);
});
