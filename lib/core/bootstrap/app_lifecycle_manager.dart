import 'package:flutter/material.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Manages application lifecycle events and cleanup
class AppLifecycleManager with WidgetsBindingObserver {
  static const String _context = 'AppLifecycleManager';
  final LoggerService _logger = LoggerService.instance;

  /// Initialize lifecycle management
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _logger.info('App lifecycle manager initialized', context: _context);
  }

  /// Clean up lifecycle management
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logger.info('App lifecycle manager disposed', context: _context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  /// Handle app being terminated
  void _handleAppDetached() {
    _logger.info('App is being terminated', context: _context);
    
    // Perform cleanup operations
    HiveRepositoryRegistry.dispose().catchError((e) {
      _logger.warning('Error during app shutdown cleanup', context: _context);
    });
  }

  /// Handle app moving to background
  void _handleAppPaused() {
    _logger.debug('App moved to background', context: _context);
    
    // Optimize storage by compacting Hive boxes
    _compactHiveBoxes().catchError((e) {
      _logger.warning('Error during Hive compaction', context: _context);
    });
  }

  /// Handle app returning to foreground
  void _handleAppResumed() {
    _logger.debug('App returned to foreground', context: _context);
    
    // Ensure repositories are ready
    _ensureRepositoriesReady().catchError((e) {
      _logger.warning('Error during repository recovery', context: _context);
    });
  }

  /// Handle app becoming inactive (e.g., phone call)
  void _handleAppInactive() {
    _logger.debug('App became inactive', context: _context);
  }

  /// Handle app being hidden (e.g., minimized on desktop)
  void _handleAppHidden() {
    _logger.debug('App was hidden', context: _context);
  }

  /// Compact Hive boxes for storage optimization
  Future<void> _compactHiveBoxes() async {
    try {
      if (HiveRepositoryRegistry.instance.isInitialized) {
        await HiveRepositoryRegistry.instance.customListRepository.compact();
        _logger.performance('hive_compaction', const Duration(milliseconds: 50), context: _context);
      }
    } catch (e) {
      _logger.error('Hive compaction failed', context: _context, error: e);
    }
  }

  /// Ensure repositories are ready after app resume
  Future<void> _ensureRepositoriesReady() async {
    try {
      if (!HiveRepositoryRegistry.instance.isInitialized) {
        await HiveRepositoryRegistry.initialize();
        _logger.info('Repositories re-initialized after resume', context: _context);
      }
    } catch (e) {
      _logger.error('Repository recovery failed', context: _context, error: e);
    }
  }
}