import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/ui/cross_browser_compatibility_service.dart';
import 'package:prioris/domain/services/core/language_service.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/presentation/services/debug/overflow_audit_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/core/di/export.dart';
import 'package:prioris/data/repositories/base/hive_repository_registry.dart';

/// Handles all application initialization logic
class AppInitializer {
  static const String _context = 'AppInitializer';

  /// Initialize all core services and dependencies
  static Future<void> initialize() async {
    final logger = LoggerService.instance;
    logger.info('Starting application initialization', context: _context);

    try {
      await _initializeStorage();
      await _initializeConfiguration();
      await _initializeDependencyInjection();
      await _initializeServices();
      await _initializeRepositories();

      logger.info('Application initialization completed successfully', context: _context);
    } catch (e) {
      logger.error('Application initialization failed', context: _context, error: e);
      rethrow;
    }
  }

  /// Initialize Dependency Injection Container
  static Future<void> _initializeDependencyInjection() async {
    final logger = LoggerService.instance;
    logger.debug('Initializing Dependency Injection container', context: _context);

    // Initialize the DI container with all service registrations
    await DILifecycleManager.initialize();

    logger.info('DI container initialized successfully',
               context: _context,
               data: {'services_registered': 'core, domain, data, infrastructure'});
  }

  /// Initialize local storage (Hive)
  static Future<void> _initializeStorage() async {
    final logger = LoggerService.instance;
    logger.debug('Initializing local storage', context: _context);

    await Hive.initFlutter();
    
    // Register Hive adapters
    Hive.registerAdapter(CustomListAdapter());
    Hive.registerAdapter(ListItemAdapter());
    Hive.registerAdapter(ListTypeAdapter());
    
    logger.debug('Hive adapters registered successfully', context: _context);
  }

  /// Initialize app configuration
  static Future<void> _initializeConfiguration() async {
    final logger = LoggerService.instance;
    logger.debug('Loading application configuration', context: _context);

    await AppConfig.initialize();
    
    logger.info('Configuration loaded successfully', 
               context: _context, 
               data: {'environment': AppConfig.instance.environment});
  }

  /// Initialize external services
  static Future<void> _initializeServices() async {
    final logger = LoggerService.instance;
    logger.debug('Initializing external services', context: _context);

    // Initialize Supabase
    await SupabaseService.initialize();
    
    // Initialize language service
    final languageService = LanguageService();
    await languageService.initialize();
    
    logger.debug('External services initialized', context: _context);
  }

  /// Initialize repositories and data layer
  static Future<void> _initializeRepositories() async {
    final logger = LoggerService.instance;
    logger.debug('Initializing repositories', context: _context);

    // Initialize Repository Manager through DI Container
    // Repository Manager is automatically initialized when first accessed

    // BACKWARD COMPATIBILITY: Keep legacy registry for existing code
    // TODO: Remove this once all code migrated to new DI system
    try {
      await HiveRepositoryRegistry.initialize();
      logger.debug('Legacy repository registry initialized (backward compatibility)', context: _context);
    } catch (e) {
      logger.warning('Legacy repository registry initialization failed - using DI system only', context: _context);
    }

    logger.info('Repository layer initialized successfully',
               context: _context,
               data: {'di_system': true, 'legacy_support': true});
  }

  /// Initialize platform-specific features
  static void initializePlatformFeatures() {
    final logger = LoggerService.instance;
    logger.debug('Applying platform-specific features', context: _context);

    // Apply cross-browser compatibility fixes
    CrossBrowserCompatibilityService().applyBrowserSpecificFixes();
    
    // Enable overflow auditing in debug mode
    OverflowAuditService.enable();
    
    logger.debug('Platform features initialized', context: _context);
  }
}