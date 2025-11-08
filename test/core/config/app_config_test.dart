import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/config/app_config.dart';

void main() {
  group('AppConfig test environment overrides', () {
    setUp(() {
      AppConfig.setTestEnvironment(const {
        'SUPABASE_URL': 'https://override-prioris.supabase.co',
        'SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.override',
        'SUPABASE_AUTH_REDIRECT_URL': 'https://override/auth/callback',
        'ENVIRONMENT': 'unit-test',
        'DEBUG_MODE': 'false',
      });
    });

    test('exposes deterministic values from the injected map', () {
      final config = AppConfig.instance;

      expect(config.supabaseUrl, 'https://override-prioris.supabase.co');
      expect(config.supabaseAnonKey,
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.override');
      expect(config.supabaseAuthRedirectUrl, 'https://override/auth/callback');
      expect(config.environment, 'unit-test');
      expect(config.isDebugMode, isFalse);
    });

    test('setTestEnvironment trims whitespace', () {
      AppConfig.setTestEnvironment(const {
        'SUPABASE_URL': ' https://trim.supabase.co ',
        'SUPABASE_ANON_KEY': '  eyJ.trimmed  ',
        'SUPABASE_AUTH_REDIRECT_URL': ' https://trim/callback ',
      });

      final config = AppConfig.instance;
      expect(config.supabaseUrl, 'https://trim.supabase.co');
      expect(config.supabaseAnonKey, 'eyJ.trimmed');
      expect(config.supabaseAuthRedirectUrl, 'https://trim/callback');
    });
  });
}

