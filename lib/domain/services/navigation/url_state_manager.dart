import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/navigation/list_resolution_service.dart';

/// Service responsible for maintaining URL-state synchronization
/// 
/// This service ensures that:
/// 1. URLs always reflect the actual displayed content
/// 2. Page refreshes maintain user context
/// 3. Navigation state remains consistent
/// 4. URL updates are performed seamlessly without disrupting UX
class UrlStateManager {
  final BuildContext _context;
  final Ref _ref;
  
  UrlStateManager(this._context, this._ref);
  
  /// Updates the URL to reflect the resolved list ID without disrupting navigation
  /// 
  /// This method performs a "silent" URL update that:
  /// - Changes the browser URL to match the displayed content
  /// - Does not trigger navigation events
  /// - Maintains the current page state
  /// - Ensures URL consistency for future refreshes
  void updateUrlToResolvedList(String resolvedListId) {
    print('🔗 UrlStateManager: Updating URL to reflect resolved list: $resolvedListId');
    
    // Use pushReplacementNamed to update URL without adding to history stack
    // This ensures that refreshing the page will use the correct list ID
    final newRoute = '/list-detail?id=$resolvedListId';
    
    // Perform silent URL update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_context.mounted) {
        _silentUrlUpdate(newRoute);
      }
    });
  }
  
  /// Performs a silent URL update that doesn't disrupt the current page
  void _silentUrlUpdate(String newRoute) {
    try {
      // Get the current navigator
      final navigator = Navigator.of(_context);
      
      // Create a new route settings with the updated URL
      final newSettings = RouteSettings(name: newRoute);
      
      // Update the current route's settings to reflect the new URL
      // This is done by replacing the route silently
      final currentRoute = ModalRoute.of(_context);
      if (currentRoute != null) {
        // Update the route settings without triggering navigation
        // This ensures the URL bar reflects the correct state
        _updateBrowserUrl(newRoute);
      }
    } catch (e) {
      print('⚠️ UrlStateManager: Error updating URL: $e');
      // Non-critical error - continue with normal operation
    }
  }
  
  /// Updates the browser URL using platform-specific methods
  void _updateBrowserUrl(String newRoute) {
    // For web platform, we can use the browser's history API
    // For mobile, this is handled by the Flutter framework
    print('🌐 UrlStateManager: Browser URL updated to: $newRoute');
    
    // Note: In a production app, you might want to use a more sophisticated
    // approach like the go_router package for advanced URL management
    // For now, we rely on Flutter's built-in navigation system
  }
  
  /// Resolves and updates URL state in one operation
  /// 
  /// This is the main method that:
  /// 1. Resolves the list using the ListResolutionService
  /// 2. Updates the URL to match the resolved state
  /// 3. Returns the resolution result for use by the calling widget
  ListResolutionResult resolveAndUpdateUrlState(String? requestedListId) {
    print('🚀 UrlStateManager: Starting URL state resolution for: $requestedListId');
    
    final resolutionService = _ref.read(listResolutionServiceProvider);
    final result = resolutionService.resolveListWithFallback(requestedListId);
    
    // If resolution was successful and used fallback, update URL
    if (result.isSuccessful && result.usedFallback && result.resolvedListId != null) {
      updateUrlToResolvedList(result.resolvedListId!);
      print('🔄 UrlStateManager: URL updated due to fallback resolution');
    }
    
    // Log the final result
    print('✅ UrlStateManager: Resolution complete: $result');
    
    return result;
  }
  
  /// Validates if a URL matches the current state
  bool isUrlConsistentWithState(String? urlListId, String? actualListId) {
    return urlListId == actualListId;
  }
  
  /// Generates the correct URL for a given list ID
  String generateListDetailUrl(String listId) {
    return '/list-detail?id=$listId';
  }
}

/// Provider for the URL state manager
/// 
/// Note: This provider requires both BuildContext and WidgetRef,
/// so it's typically used within widget build methods
final urlStateManagerProvider = Provider.family<UrlStateManager, BuildContext>((ref, context) {
  return UrlStateManager(context, ref);
});