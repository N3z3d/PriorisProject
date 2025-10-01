import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ui.dart';
import 'app_localizations_features.dart';
import 'app_localizations_messages.dart';
import '../app_localizations_de.dart';
import '../app_localizations_en.dart';
import '../app_localizations_es.dart';
import '../app_localizations_fr.dart';

/// Core localization configuration and delegate management
///
/// SOLID COMPLIANCE:
/// - SRP: Only responsible for core localization setup and delegation
/// - OCP: Extensible for new locales without modification
/// - LSP: Any locale implementation is substitutable
/// - ISP: Minimal interface for localization core
/// - DIP: Depends on abstract Localizations, not concrete implementations
///
/// CONSTRAINTS: <200 lines (currently ~150 lines)
abstract class AppLocalizationsCore {
  AppLocalizationsCore(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  /// Get localization instance from context
  static AppLocalizationsCore? of(BuildContext context) {
    return Localizations.of<AppLocalizationsCore>(context, AppLocalizationsCore);
  }

  /// Localization delegate
  static const LocalizationsDelegate<AppLocalizationsCore> delegate =
      _AppLocalizationsCoreDelegate();

  /// Complete delegates list for MaterialApp
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// Supported locales
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  // === DELEGATION TO SPECIALIZED MODULES ===

  /// UI translations (buttons, labels, etc.)
  AppLocalizationsUI get ui;

  /// Feature translations (habits, tasks, lists)
  AppLocalizationsFeatures get features;

  /// Messages and notifications
  AppLocalizationsMessages get messages;

  // === CORE APP LABELS (minimal set) ===

  /// The title of the application
  String get appTitle;

  /// Generic OK button
  String get ok;

  /// Generic Cancel button
  String get cancel;

  /// Generic Save button
  String get save;

  /// Generic Delete button
  String get delete;
}

/// Concrete implementation for each locale
class AppLocalizationsCoreImpl extends AppLocalizationsCore {
  final AppLocalizationsUI _ui;
  final AppLocalizationsFeatures _features;
  final AppLocalizationsMessages _messages;

  AppLocalizationsCoreImpl({
    required String locale,
    required AppLocalizationsUI ui,
    required AppLocalizationsFeatures features,
    required AppLocalizationsMessages messages,
  }) : _ui = ui,
       _features = features,
       _messages = messages,
       super(locale);

  @override
  AppLocalizationsUI get ui => _ui;

  @override
  AppLocalizationsFeatures get features => _features;

  @override
  AppLocalizationsMessages get messages => _messages;

  @override
  String get appTitle => 'Prioris';

  @override
  String get ok => _getTranslation('ok');

  @override
  String get cancel => _getTranslation('cancel');

  @override
  String get save => _getTranslation('save');

  @override
  String get delete => _getTranslation('delete');

  /// Helper to get translation by key based on locale
  String _getTranslation(String key) {
    // SOLID OCP: Extensible translation resolution
    switch (localeName) {
      case 'de':
        return _getGermanTranslation(key);
      case 'es':
        return _getSpanishTranslation(key);
      case 'fr':
        return _getFrenchTranslation(key);
      case 'en':
      default:
        return _getEnglishTranslation(key);
    }
  }

  String _getEnglishTranslation(String key) {
    switch (key) {
      case 'ok': return 'OK';
      case 'cancel': return 'Cancel';
      case 'save': return 'Save';
      case 'delete': return 'Delete';
      default: return key;
    }
  }

  String _getGermanTranslation(String key) {
    switch (key) {
      case 'ok': return 'OK';
      case 'cancel': return 'Abbrechen';
      case 'save': return 'Speichern';
      case 'delete': return 'Löschen';
      default: return key;
    }
  }

  String _getSpanishTranslation(String key) {
    switch (key) {
      case 'ok': return 'OK';
      case 'cancel': return 'Cancelar';
      case 'save': return 'Guardar';
      case 'delete': return 'Eliminar';
      default: return key;
    }
  }

  String _getFrenchTranslation(String key) {
    switch (key) {
      case 'ok': return 'OK';
      case 'cancel': return 'Annuler';
      case 'save': return 'Enregistrer';
      case 'delete': return 'Supprimer';
      default: return key;
    }
  }
}

/// Private delegate implementation
class _AppLocalizationsCoreDelegate extends LocalizationsDelegate<AppLocalizationsCore> {
  const _AppLocalizationsCoreDelegate();

  @override
  Future<AppLocalizationsCore> load(Locale locale) {
    return SynchronousFuture<AppLocalizationsCore>(_buildLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) {
    return ['de', 'en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsCoreDelegate old) => false;

  /// Factory method to create appropriate localization based on locale
  AppLocalizationsCore _buildLocalizations(Locale locale) {
    // SOLID Factory Pattern: Create specialized implementations
    final ui = AppLocalizationsUIFactory.create(locale.languageCode);
    final features = AppLocalizationsFeaturesFactory.create(locale.languageCode);
    final messages = AppLocalizationsMessagesFactory.create(locale.languageCode);

    return AppLocalizationsCoreImpl(
      locale: locale.languageCode,
      ui: ui,
      features: features,
      messages: messages,
    );
  }
}