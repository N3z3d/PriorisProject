import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/navigation/list_resolution_service.dart';

/// Comprehensive error handling service for navigation scenarios
/// 
/// This service provides centralized error handling for various navigation
/// edge cases including network issues, data inconsistencies, and user errors.
class NavigationErrorHandler {
  final Ref _ref;
  
  NavigationErrorHandler(this._ref);
  
  /// Handles network-related errors during list resolution
  Widget handleNetworkError(BuildContext context, dynamic error) {
    print('🌐 NavigationErrorHandler: Handling network error: $error');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: Colors.orange.withAlpha(20),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Problème de connexion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vérifiez votre connexion internet\net réessayez',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _retryWithFallback(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: const Text('Retour accueil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handles data inconsistency errors (corrupted data, missing references)
  Widget handleDataInconsistencyError(BuildContext context, dynamic error) {
    print('🗄️ NavigationErrorHandler: Handling data inconsistency: $error');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Données'),
        backgroundColor: Colors.red.withAlpha(20),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Données corrompues détectées',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Les données de cette liste semblent\nêtre corrompues ou incomplètes',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _attemptDataRecovery(context),
                  icon: const Icon(Icons.build),
                  label: const Text('Réparer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => _navigateToFirstValidList(context),
                  child: const Text('Autre liste'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handles permission errors (user doesn't have access to specific list)
  Widget handlePermissionError(BuildContext context, String listId) {
    print('🔒 NavigationErrorHandler: Handling permission error for list: $listId');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accès refusé'),
        backgroundColor: Colors.purple.withAlpha(20),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            const Text(
              'Accès non autorisé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vous n\'avez pas les permissions\npour accéder à cette liste',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navigateToFirstValidList(context),
                  icon: const Icon(Icons.list),
                  label: const Text('Mes listes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: const Text('Accueil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handles generic application errors with graceful fallback
  Widget handleGenericError(BuildContext context, dynamic error, StackTrace? stack) {
    print('💥 NavigationErrorHandler: Handling generic error: $error');
    if (stack != null) {
      print('Stack trace: $stack');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: Colors.grey.withAlpha(20),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Une erreur s\'est produite',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _sanitizeErrorMessage(error.toString()),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _retryWithFallback(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: const Text('Accueil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Determines the appropriate error handling strategy based on error type
  Widget handleError(BuildContext context, dynamic error, {StackTrace? stack, String? listId}) {
    // Network-related errors
    if (_isNetworkError(error)) {
      return handleNetworkError(context, error);
    }
    
    // Data inconsistency errors
    if (_isDataInconsistencyError(error)) {
      return handleDataInconsistencyError(context, error);
    }
    
    // Permission errors
    if (_isPermissionError(error) && listId != null) {
      return handlePermissionError(context, listId);
    }
    
    // Generic error fallback
    return handleGenericError(context, error, stack);
  }
  
  // --- Private helper methods ---
  
  /// Attempts to retry the operation with intelligent fallback
  void _retryWithFallback(BuildContext context) {
    print('🔄 NavigationErrorHandler: Retrying with fallback strategy');
    
    // Try to navigate to the first available list
    _navigateToFirstValidList(context);
  }
  
  /// Navigates to the first valid list available
  void _navigateToFirstValidList(BuildContext context) {
    try {
      final resolutionService = _ref.read(listResolutionServiceProvider);
      final result = resolutionService.resolveListWithFallback(null);
      
      if (result.isSuccessful) {
        Navigator.of(context).pushReplacementNamed(
          '/list-detail?id=${result.resolvedListId}'
        );
      } else {
        // No valid lists available, go home
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      print('⚠️ NavigationErrorHandler: Error during fallback navigation: $e');
      Navigator.of(context).pushReplacementNamed('/');
    }
  }
  
  /// Attempts to recover corrupted data
  void _attemptDataRecovery(BuildContext context) {
    print('🔧 NavigationErrorHandler: Attempting data recovery');
    
    // In a real application, this might involve:
    // 1. Clearing corrupted cache
    // 2. Re-syncing from server
    // 3. Reconstructing missing relationships
    // For now, we'll just navigate to a safe state
    
    _navigateToFirstValidList(context);
  }
  
  /// Checks if error is network-related
  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket') ||
           errorString.contains('dns');
  }
  
  /// Checks if error is data inconsistency related
  bool _isDataInconsistencyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('corrupt') ||
           errorString.contains('invalid data') ||
           errorString.contains('missing reference') ||
           errorString.contains('constraint violation');
  }
  
  /// Checks if error is permission related
  bool _isPermissionError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('permission') ||
           errorString.contains('unauthorized') ||
           errorString.contains('access denied') ||
           errorString.contains('forbidden');
  }
  
  /// Sanitizes error messages for user display
  String _sanitizeErrorMessage(String error) {
    // Remove technical details and provide user-friendly messages
    if (error.length > 100) {
      return 'Une erreur technique s\'est produite.\nVeuillez réessayer.';
    }
    
    // Remove file paths and technical stack info
    final sanitized = error
        .replaceAll(RegExp(r'at [^\s]+'), '')
        .replaceAll(RegExp(r'#\d+'), '')
        .trim();
    
    return sanitized.isEmpty ? 'Erreur inconnue' : sanitized;
  }
}

/// Provider for the navigation error handler
final navigationErrorHandlerProvider = Provider<NavigationErrorHandler>((ref) {
  return NavigationErrorHandler(ref);
});