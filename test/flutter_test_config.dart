import 'dart:io';
import 'package:hive/hive.dart';

/// Configuration globale exécutée avant **tous** les tests.
Future<void> testExecutable(Future<void> Function() testMain) async {
  // Initialisation Hive dans un dossier temporaire isolé
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);

  // Exécution de la suite de tests
  await testMain();

  // Nettoyage (facultatif)
  await dir.delete(recursive: true);
} 
