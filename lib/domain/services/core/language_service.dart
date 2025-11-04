import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Service de gestion des langues pour l'internationalisation
class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';
  static Locale _defaultSystemLocaleProvider() => PlatformDispatcher.instance.locale;

  final Locale Function() _systemLocaleProvider;

  /// Langues supportées par l'application
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
    Locale('es', 'ES'), // Espagnol
    Locale('de', 'DE'), // Allemand
  ];

  /// Langue par défaut
  static const Locale defaultLocale = Locale('fr', 'FR');

  /// Box Hive pour la persistance
  Box? _box;

  LanguageService({Locale Function()? systemLocaleProvider})
      : _systemLocaleProvider =
            systemLocaleProvider ?? _defaultSystemLocaleProvider;

  /// Initialise le service
  Future<void> initialize() async {
    _box = await Hive.openBox('language_settings');
  }

  /// Obtient la langue actuelle
  Locale getCurrentLocale() {
    final box = _box;
    if (box == null || !box.isOpen) {
      return defaultLocale;
    }
    final languageCode =
        box.get(_languageCodeKey, defaultValue: defaultLocale.languageCode);
    final countryCode =
        box.get(_countryCodeKey, defaultValue: defaultLocale.countryCode);
    return Locale(languageCode, countryCode);
  }

  /// Définit la langue
  Future<void> setLocale(Locale locale) async {
    final box = _box;
    if (box == null || !box.isOpen) {
      return;
    }
    await box.put(_languageCodeKey, locale.languageCode);
    await box.put(_countryCodeKey, locale.countryCode);
    await box.put(_languageKey, '${locale.languageCode}_${locale.countryCode}');
  }

  /// Obtient le nom de la langue pour l'affichage
  String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
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
      case 'fr':
        return '🇫🇷';
      case 'en':
        return '🇺🇸';
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
        supported.countryCode == locale.countryCode);
  }

  /// Obtient la langue du système
  Locale getSystemLocale() {
    final systemLocale = _systemLocaleProvider();
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
    return supportedLocales
        .map((locale) => LanguageInfo(
              locale: locale,
              displayName: getLanguageDisplayName(locale),
              flag: getLanguageFlag(locale),
            ))
        .toList();
  }

  /// Ferme le service
  Future<void> dispose() async {
    final box = _box;
    if (box != null && box.isOpen) {
      await box.close();
    }
    _box = null;
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
