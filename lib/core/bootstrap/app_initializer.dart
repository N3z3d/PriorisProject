import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/ui/cross_browser_compatibility_service.dart';
import 'package:prioris/domain/services/core/language_service.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/presentation/services/debug/overflow_audit_service.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

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
      await _initializeServices();
      await _initializeRepositories();
      
      logger.info('Application initialization completed successfully', context: _context);
    } catch (e) {
      logger.error('Application initialization failed', context: _context, error: e);
      rethrow;
    }
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

    // Initialize Hive repositories BEFORE providers to avoid race conditions
    await HiveRepositoryRegistry.initialize();
    
    logger.debug('Repositories initialized successfully', context: _context);
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