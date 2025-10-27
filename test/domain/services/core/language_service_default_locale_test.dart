import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/core/language_service.dart';

void main() {
  group('LanguageService default locale', () {
    test('defaultLocale is French', () {
      expect(
        LanguageService.defaultLocale,
        const Locale('fr', 'FR'),
      );
    });

    test('getCurrentLocale falls back to French when storage is unavailable',
        () {
      final service = LanguageService();

      expect(
        service.getCurrentLocale(),
        const Locale('fr', 'FR'),
      );
    });

    test('currentLocaleProvider publishes French locale by default', () {
      final container = ProviderContainer(
        overrides: [
          languageServiceProvider.overrideWithValue(LanguageService()),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(currentLocaleProvider),
        const Locale('fr', 'FR'),
      );
    });
  });
}
