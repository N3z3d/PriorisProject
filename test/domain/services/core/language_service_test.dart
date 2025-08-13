import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/services/core/language_service.dart';

void main() {
  group('LanguageService', () {
    late LanguageService languageService;
    late Box mockBox;

    setUp(() async {
      // Initialiser Hive pour les tests
      await Hive.initFlutter();
      await Hive.openBox('test_language_settings');
      mockBox = Hive.box('test_language_settings');
      
      languageService = LanguageService();
      await languageService.initialize();
    });

    tearDown(() async {
      await mockBox.clear();
      await mockBox.close();
      await Hive.close();
    });

    group('Initialisation', () {
      test('should initialize with default locale', () {
        final currentLocale = languageService.getCurrentLocale();
        expect(currentLocale, equals(LanguageService.defaultLocale));
      });

      test('should have correct supported locales', () {
        expect(LanguageService.supportedLocales, hasLength(4));
        expect(LanguageService.supportedLocales, contains(LanguageService.defaultLocale));
        expect(LanguageService.supportedLocales, contains(const Locale('fr', 'FR')));
        expect(LanguageService.supportedLocales, contains(const Locale('es', 'ES')));
        expect(LanguageService.supportedLocales, contains(const Locale('de', 'DE')));
      });
    });

    group('getCurrentLocale', () {
      test('should return default locale when no language is set', () {
        final locale = languageService.getCurrentLocale();
        expect(locale, equals(LanguageService.defaultLocale));
      });

      test('should return saved locale when language is set', () async {
        await languageService.setLocale(const Locale('fr', 'FR'));
        final locale = languageService.getCurrentLocale();
        expect(locale, equals(const Locale('fr', 'FR')));
      });
    });

    group('setLocale', () {
      test('should save locale to storage', () async {
        const testLocale = Locale('es', 'ES');
        await languageService.setLocale(testLocale);
        
        final savedLocale = languageService.getCurrentLocale();
        expect(savedLocale, equals(testLocale));
      });

      test('should update current locale immediately', () async {
        const testLocale = Locale('de', 'DE');
        await languageService.setLocale(testLocale);
        
        final currentLocale = languageService.getCurrentLocale();
        expect(currentLocale, equals(testLocale));
      });
    });

    group('getLanguageDisplayName', () {
      test('should return correct display names for all supported languages', () {
        expect(languageService.getLanguageDisplayName(const Locale('en', 'US')), equals('English'));
        expect(languageService.getLanguageDisplayName(const Locale('fr', 'FR')), equals('Français'));
        expect(languageService.getLanguageDisplayName(const Locale('es', 'ES')), equals('Español'));
        expect(languageService.getLanguageDisplayName(const Locale('de', 'DE')), equals('Deutsch'));
      });

      test('should return English for unsupported language', () {
        expect(languageService.getLanguageDisplayName(const Locale('it', 'IT')), equals('English'));
      });
    });

    group('getLanguageFlag', () {
      test('should return correct flags for all supported languages', () {
        expect(languageService.getLanguageFlag(const Locale('en', 'US')), equals('🇺🇸'));
        expect(languageService.getLanguageFlag(const Locale('fr', 'FR')), equals('🇫🇷'));
        expect(languageService.getLanguageFlag(const Locale('es', 'ES')), equals('🇪🇸'));
        expect(languageService.getLanguageFlag(const Locale('de', 'DE')), equals('🇩🇪'));
      });

      test('should return US flag for unsupported language', () {
        expect(languageService.getLanguageFlag(const Locale('it', 'IT')), equals('🇺🇸'));
      });
    });

    group('isSupported', () {
      test('should return true for supported locales', () {
        expect(languageService.isSupported(const Locale('en', 'US')), isTrue);
        expect(languageService.isSupported(const Locale('fr', 'FR')), isTrue);
        expect(languageService.isSupported(const Locale('es', 'ES')), isTrue);
        expect(languageService.isSupported(const Locale('de', 'DE')), isTrue);
      });

      test('should return false for unsupported locales', () {
        expect(languageService.isSupported(const Locale('it', 'IT')), isFalse);
        expect(languageService.isSupported(const Locale('pt', 'BR')), isFalse);
        expect(languageService.isSupported(const Locale('ja', 'JP')), isFalse);
      });

      test('should return false for partial matches', () {
        expect(languageService.isSupported(const Locale('en', 'GB')), isFalse);
        expect(languageService.isSupported(const Locale('fr', 'CA')), isFalse);
      });
    });

    group('getSystemLocale', () {
      test('should return supported locale when system locale is supported', () {
        // Simuler un système en anglais
        final systemLocale = languageService.getSystemLocale();
        expect(LanguageService.supportedLocales, contains(systemLocale));
      });
    });

    group('detectBrowserLanguage', () {
      test('should return a supported locale', () {
        final detectedLocale = languageService.detectBrowserLanguage();
        expect(LanguageService.supportedLocales, contains(detectedLocale));
      });
    });

    group('getSupportedLanguages', () {
      test('should return all supported languages with correct information', () {
        final supportedLanguages = languageService.getSupportedLanguages();
        
        expect(supportedLanguages, hasLength(4));
        
        // Vérifier que chaque langue a les bonnes informations
        for (final languageInfo in supportedLanguages) {
          expect(languageInfo.locale, isA<Locale>());
          expect(languageInfo.displayName, isNotEmpty);
          expect(languageInfo.flag, isNotEmpty);
          expect(LanguageService.supportedLocales, contains(languageInfo.locale));
        }
      });

      test('should return unique locales', () {
        final supportedLanguages = languageService.getSupportedLanguages();
        final locales = supportedLanguages.map((info) => info.locale).toSet();
        expect(locales, hasLength(4));
      });
    });

    group('dispose', () {
      test('should close the box without error', () async {
        await expectLater(languageService.dispose(), completes);
      });
    });
  });

  group('LanguageInfo', () {
    test('should create LanguageInfo with correct properties', () {
      const locale = Locale('fr', 'FR');
      const displayName = 'Français';
      const flag = '🇫🇷';
      
      const languageInfo = LanguageInfo(
        locale: locale,
        displayName: displayName,
        flag: flag,
      );
      
      expect(languageInfo.locale, equals(locale));
      expect(languageInfo.displayName, equals(displayName));
      expect(languageInfo.flag, equals(flag));
    });

    test('should have correct toString representation', () {
      const languageInfo = LanguageInfo(
        locale: Locale('es', 'ES'),
        displayName: 'Español',
        flag: '🇪🇸',
      );
      
      expect(languageInfo.toString(), contains('LanguageInfo'));
      expect(languageInfo.toString(), contains('es_ES'));
      expect(languageInfo.toString(), contains('Español'));
      expect(languageInfo.toString(), contains('🇪🇸'));
    });

    test('should have correct equality', () {
      const languageInfo1 = LanguageInfo(
        locale: Locale('de', 'DE'),
        displayName: 'Deutsch',
        flag: '🇩🇪',
      );
      
      const languageInfo2 = LanguageInfo(
        locale: Locale('de', 'DE'),
        displayName: 'Deutsch',
        flag: '🇩🇪',
      );
      
      const languageInfo3 = LanguageInfo(
        locale: Locale('en', 'US'),
        displayName: 'English',
        flag: '🇺🇸',
      );
      
      expect(languageInfo1, equals(languageInfo2));
      expect(languageInfo1, isNot(equals(languageInfo3)));
    });

    test('should have correct hashCode', () {
      const languageInfo1 = LanguageInfo(
        locale: Locale('fr', 'FR'),
        displayName: 'Français',
        flag: '🇫🇷',
      );
      
      const languageInfo2 = LanguageInfo(
        locale: Locale('fr', 'FR'),
        displayName: 'Français',
        flag: '🇫🇷',
      );
      
      expect(languageInfo1.hashCode, equals(languageInfo2.hashCode));
    });
  });
} 
