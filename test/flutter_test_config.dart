import 'dart:io';

import 'package:hive/hive.dart';
import 'package:prioris/core/config/app_config.dart';

/// Configuration globale exécutée avant **tous** les tests.
Future<void> testExecutable(Future<void> Function() testMain) async {
  AppConfig.setTestEnvironment(const {
    'SUPABASE_URL': 'https://tests-prioris.supabase.co',
    'SUPABASE_ANON_KEY':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.payload.signature',
    'SUPABASE_AUTH_REDIRECT_URL': 'https://tests.prioris.app/auth/callback',
    'ENVIRONMENT': 'test',
    'DEBUG_MODE': 'true',
  });

  // Initialisation Hive dans un dossier temporaire isolé
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);

  // Exécution de la suite de tests
  await testMain();

  // Nettoyage (facultatif)
  await dir.delete(recursive: true);
}
