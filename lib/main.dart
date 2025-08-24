import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/core/bootstrap/app_initializer.dart';
import 'package:prioris/core/bootstrap/app_lifecycle_manager.dart';
import 'package:prioris/presentation/app/prioris_app.dart';
import 'package:prioris/domain/services/core/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all core application services
  await AppInitializer.initialize();
  
  // Apply platform-specific features
  AppInitializer.initializePlatformFeatures();
  
  // Setup app lifecycle management
  final lifecycleManager = AppLifecycleManager();
  lifecycleManager.initialize();
  
  // Get language service for provider override
  final languageService = LanguageService();
  await languageService.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        languageServiceProvider.overrideWithValue(languageService),
      ],
      child: const PriorisApp(),
    ),
  );
} 

