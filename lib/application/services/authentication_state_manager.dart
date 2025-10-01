/// Authentication State Manager
/// Single Responsibility: Manage authentication state transitions only

import 'dart:async';
import '../ports/persistence_interfaces.dart';
import '../../infrastructure/services/logger_service.dart';

/// SOLID implementation of authentication state management
/// Follows Single Responsibility Principle - only handles auth state
class AuthenticationStateManager implements IAuthenticationStateManager {
  bool _isAuthenticated = false;
  PersistenceMode _currentMode = PersistenceMode.localFirst;

  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  PersistenceMode get currentMode => _currentMode;

  @override
  Stream<bool> get authenticationStateStream => _authStateController.stream;

  @override
  Future<void> updateAuthenticationState({
    required bool isAuthenticated,
    MigrationStrategy? migrationStrategy,
  }) async {
    LoggerService.instance.info(
      'Authentication state change: $_isAuthenticated → $isAuthenticated',
      context: 'AuthenticationStateManager',
    );

    final wasAuthenticated = _isAuthenticated;
    _isAuthenticated = isAuthenticated;

    // Update persistence mode based on authentication
    if (isAuthenticated) {
      _currentMode = PersistenceMode.cloudFirst;
    } else {
      _currentMode = PersistenceMode.localFirst;
    }

    // Notify listeners of state change
    _authStateController.add(isAuthenticated);

    LoggerService.instance.info(
      'New persistence mode: $_currentMode',
      context: 'AuthenticationStateManager',
    );
  }

  /// Initialize with current authentication state
  Future<void> initialize({required bool isAuthenticated}) async {
    LoggerService.instance.info(
      'Initializing with auth=$isAuthenticated',
      context: 'AuthenticationStateManager',
    );

    _isAuthenticated = isAuthenticated;
    _currentMode = isAuthenticated ? PersistenceMode.cloudFirst : PersistenceMode.localFirst;

    LoggerService.instance.info(
      'Persistence mode set to: $_currentMode',
      context: 'AuthenticationStateManager',
    );
  }

  /// Check if authentication state changed from the current state
  bool hasAuthenticationChanged(bool newState) {
    return _isAuthenticated != newState;
  }

  /// Get current authentication context for logging/debugging
  Map<String, dynamic> getAuthContext() {
    return {
      'isAuthenticated': _isAuthenticated,
      'currentMode': _currentMode.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
    LoggerService.instance.info(
      'AuthenticationStateManager disposed',
      context: 'AuthenticationStateManager',
    );
  }
}