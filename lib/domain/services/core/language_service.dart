import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service de gestion des langues pour l'internationalisation
class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';
  
  /// Langues supportées par l'application
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // Anglais
    Locale('fr', 'FR'), // Français
    Locale('es', 'ES'), // Espagnol
    Locale('de', 'DE'), // Allemand
  ];
  
  /// Langue par défaut
  static const Locale defaultLocale = Locale('en', 'US');
  
  /// Box Hive pour la persistance
  late Box _box;
  
  /// Initialise le service
  Future<void> initialize() async {
    _box = await Hive.openBox('language_settings');
  }
  
  /// Obtient la langue actuelle
  Locale getCurrentLocale() {
    try {
      final languageCode = _box.get(_languageCodeKey, defaultValue: defaultLocale.languageCode);
      final countryCode = _box.get(_countryCodeKey, defaultValue: defaultLocale.countryCode);
      return Locale(languageCode, countryCode);
    } catch (e) {
      // Fallback pour les tests ou si Hive n'est pas initialisé
      return defaultLocale;
    }
  }
  
  /// Définit la langue
  Future<void> setLocale(Locale locale) async {
    try {
      await _box.put(_languageCodeKey, locale.languageCode);
      await _box.put(_countryCodeKey, locale.countryCode);
      await _box.put(_languageKey, '${locale.languageCode}_${locale.countryCode}');
    } catch (e) {
      // Ignorer les erreurs dans les tests
    }
  }
  
  /// Obtient le nom de la langue pour l'affichage
  String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }
  
  /// Obtient le drapeau de la langue (emoji)
  String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'es':
        return '🇪🇸';
      case 'de':
        return '🇩🇪';
      default:
        return '🇺🇸';
    }
  }
  
  /// Vérifie si une langue est supportée
  bool isSupported(Locale locale) {
    return supportedLocales.any((supported) => 
      supported.languageCode == locale.languageCode &&
      supported.countryCode == locale.countryCode
    );
  }
  
  /// Obtient la langue du système
  Locale getSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    if (isSupported(systemLocale)) {
      return systemLocale;
    }
    return defaultLocale;
  }
  
  /// Détecte automatiquement la langue du navigateur
  Locale detectBrowserLanguage() {
    final systemLocale = getSystemLocale();
    return systemLocale;
  }
  
  /// Obtient toutes les langues supportées avec leurs informations
  List<LanguageInfo> getSupportedLanguages() {
    return supportedLocales.map((locale) => LanguageInfo(
      locale: locale,
      displayName: getLanguageDisplayName(locale),
      flag: getLanguageFlag(locale),
    )).toList();
  }
  
  /// Ferme le service
  Future<void> dispose() async {
    await _box.close();
  }
}

/// Informations sur une langue
class LanguageInfo {
  final Locale locale;
  final String displayName;
  final String flag;
  
  const LanguageInfo({
    required this.locale,
    required this.displayName,
    required this.flag,
  });
  
  @override
  String toString() {
    return 'LanguageInfo(locale: $locale, displayName: $displayName, flag: $flag)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageInfo &&
        other.locale == locale &&
        other.displayName == displayName &&
        other.flag == flag;
  }
  
  @override
  int get hashCode {
    return locale.hashCode ^ displayName.hashCode ^ flag.hashCode;
  }
}

/// Provider pour le service de langue
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});

/// Provider pour la langue actuelle
final currentLocaleProvider = StateProvider<Locale>((ref) {
  final languageService = ref.read(languageServiceProvider);
  return languageService.getCurrentLocale();
});

/// Provider pour les langues supportées
final supportedLanguagesProvider = Provider<List<LanguageInfo>>((ref) {
  final languageService = ref.read(languageServiceProvider);
  return languageService.getSupportedLanguages();
}); 
