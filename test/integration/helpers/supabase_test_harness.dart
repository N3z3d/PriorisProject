// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Harness partagé pour les tests d'intégration Supabase réelle.
///
/// Contourne [flutter_test_config.dart] qui injecte une URL mock pour
/// tous les tests. Lit [.env] directement et appelle [Supabase.initialize]
/// sans passer par [SupabaseService].
class SupabaseTestHarness {
  SupabaseTestHarness._();

  /// Initialise Supabase depuis [.env] et authentifie le compte de test.
  ///
  /// Idempotent : ignore si Supabase est déjà initialisé.
  /// À appeler dans [setUpAll].
  static Future<void> setUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    final env = _readDotEnv();
    final creds = _readTestCredentials(env);

    if (!_isSupabaseInitialized()) {
      await Supabase.initialize(
        url: env['SUPABASE_URL']!,
        anonKey: env['SUPABASE_ANON_KEY']!,
        authOptions: FlutterAuthClientOptions(
          detectSessionInUri: false,
          localStorage: const EmptyLocalStorage(),
          pkceAsyncStorage: _InMemoryGotrueAsyncStorage(),
        ),
      );
    }

    await AuthService.instance.signIn(
      email: creds['email']!,
      password: creds['password']!,
    );
    print('SupabaseTestHarness: connecté en tant que ${creds['email']}');
  }

  /// Déconnecte le compte de test. À appeler dans [tearDownAll].
  static Future<void> tearDown() async {
    await AuthService.instance.signOut();
  }

  static bool _isSupabaseInitialized() {
    try {
      Supabase.instance; // lève StateError si non initialisé
      return true;
    } catch (_) {
      return false;
    }
  }

  static Map<String, String> _readDotEnv() {
    final file = File('.env');
    if (!file.existsSync()) {
      throw StateError('.env introuvable — lancer depuis la racine du projet');
    }
    final result = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx < 0) continue;
      result[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim();
    }
    if (!result.containsKey('SUPABASE_URL') ||
        !result.containsKey('SUPABASE_ANON_KEY')) {
      throw StateError('.env doit contenir SUPABASE_URL et SUPABASE_ANON_KEY');
    }
    return result;
  }

  /// Priorité 1 : INTEGRATION_TEST_EMAIL / INTEGRATION_TEST_PASSWORD dans .env.
  /// Priorité 2 : test/manual/test_credentials.txt (format "Email: xxx" / "Password: xxx").
  static Map<String, String> _readTestCredentials(Map<String, String> env) {
    if (env.containsKey('INTEGRATION_TEST_EMAIL') &&
        env.containsKey('INTEGRATION_TEST_PASSWORD')) {
      return {
        'email': env['INTEGRATION_TEST_EMAIL']!,
        'password': env['INTEGRATION_TEST_PASSWORD']!,
      };
    }
    return _readCredentialsTxt();
  }

  static Map<String, String> _readCredentialsTxt() {
    final file = File('test/manual/test_credentials.txt');
    if (!file.existsSync()) {
      throw StateError(
        'Credentials manquants — ajouter INTEGRATION_TEST_EMAIL + '
        'INTEGRATION_TEST_PASSWORD dans .env, '
        'ou créer test/manual/test_credentials.txt',
      );
    }
    String? email, password;
    for (final line in file.readAsLinesSync()) {
      if (line.startsWith('Email:')) email = line.substring(6).trim();
      if (line.startsWith('Password:')) password = line.substring(9).trim();
    }
    if (email == null || password == null) {
      throw StateError(
        'Format test_credentials.txt invalide — attendu :\n'
        'Email: xxx\nPassword: xxx',
      );
    }
    return {'email': email, 'password': password};
  }
}

class _InMemoryGotrueAsyncStorage implements GotrueAsyncStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async => _store.remove(key);
}
