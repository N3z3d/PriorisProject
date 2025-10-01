/// **FORM SKELETON FACTORY** - Factory Pattern Implementation
///
/// **LOT 7** : Factory pour coordonner les 7 composants spécialisés
/// **SRP** : Création et sélection des composants formulaires uniquement
/// **Factory Pattern** : Délègue la création aux composants spécialisés
/// **Taille** : <200 lignes (remplace 700 lignes God Class)

import 'package:flutter/material.dart';
import '../interfaces/form_skeleton_interface.dart';
import '../standard/standard_form_skeleton.dart';
import '../login/login_form_skeleton.dart';
import '../compact/compact_form_skeleton.dart';
import '../search/search_form_skeleton.dart';
import '../wizard/wizard_form_skeleton.dart';
import '../survey/survey_form_skeleton.dart';
import '../detailed/detailed_form_skeleton.dart';

/// Factory pour créer des skelettes de formulaires spécialisés
///
/// **Factory Pattern** : Centralise la logique de création sans connaître les implémentations
/// **SRP** : Sélection et instanciation uniquement
/// **DIP** : Dépend d'abstractions (IFormSkeletonComponent)
class FormSkeletonFactory {
  // Cache des instances pour éviter la recréation
  static final Map<String, IFormSkeletonComponent> _componentCache = {};

  /// Types de formulaires supportés par la factory
  static const List<String> supportedTypes = [
    'standard',
    'login',
    'compact',
    'search',
    'wizard',
    'survey',
    'detailed',
  ];

  /// Crée un skeleton de formulaire selon le type demandé
  ///
  /// **Factory Method** : Délègue à la méthode appropriée selon le type
  static Widget createFormSkeleton({
    required String type,
    String? variant,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final component = _getComponent(type);

    if (component == null) {
      return _createFallbackSkeleton(width, height);
    }

    if (variant != null && component.availableVariants.contains(variant)) {
      return component.createVariant(
        variant,
        width: width,
        height: height,
        options: options,
      );
    }

    return component.createSkeleton(
      width: width,
      height: height,
      options: options,
    );
  }

  /// Trouve le composant approprié pour le type de skeleton demandé
  ///
  /// **Strategy Pattern** : Sélection automatique du bon composant
  static Widget createAutoSkeleton({
    required String skeletonType,
    double? width,
    double? height,
    Map<String, dynamic>? options,
  }) {
    final component = _findBestComponent(skeletonType);

    if (component == null) {
      return _createFallbackSkeleton(width, height);
    }

    return component.createSkeleton(
      width: width,
      height: height,
      options: options,
    );
  }

  /// Obtient la liste des variants disponibles pour un type donné
  static List<String> getAvailableVariants(String type) {
    final component = _getComponent(type);
    return component?.availableVariants ?? [];
  }

  /// Vérifie si un type de skeleton est supporté
  static bool isTypeSupported(String skeletonType) {
    return _getAllComponents().any((component) => component.canHandle(skeletonType));
  }

  /// Obtient les métadonnées d'un composant
  static Map<String, dynamic> getComponentMetadata(String type) {
    final component = _getComponent(type);

    if (component == null) {
      return {'supported': false};
    }

    return {
      'supported': true,
      'componentId': component.componentId,
      'supportedTypes': component.supportedTypes,
      'availableVariants': component.availableVariants,
    };
  }

  // === MÉTHODES PRIVÉES DE FACTORY ===

  /// Obtient ou crée une instance de composant (avec cache)
  static IFormSkeletonComponent? _getComponent(String type) {
    // Vérifier le cache d'abord
    if (_componentCache.containsKey(type)) {
      return _componentCache[type];
    }

    // Créer nouvelle instance selon le type
    IFormSkeletonComponent? component;

    switch (type.toLowerCase()) {
      case 'standard':
      case 'basic':
        component = StandardFormSkeleton();
        break;
      case 'login':
      case 'auth':
      case 'signin':
        component = LoginFormSkeleton();
        break;
      case 'compact':
      case 'inline':
      case 'dense':
        component = CompactFormSkeleton();
        break;
      case 'search':
      case 'filter':
        component = SearchFormSkeleton();
        break;
      case 'wizard':
      case 'stepper':
      case 'multi_step':
        component = WizardFormSkeleton();
        break;
      case 'survey':
      case 'questionnaire':
      case 'poll':
        component = SurveyFormSkeleton();
        break;
      case 'detailed':
      case 'descriptive':
      case 'help':
        component = DetailedFormSkeleton();
        break;
    }

    // Mettre en cache si trouvé
    if (component != null) {
      _componentCache[type] = component;
    }

    return component;
  }

  /// Trouve le meilleur composant capable de gérer le type demandé
  static IFormSkeletonComponent? _findBestComponent(String skeletonType) {
    final components = _getAllComponents();

    // Recherche exacte d'abord
    for (final component in components) {
      if (component.supportedTypes.contains(skeletonType)) {
        return component;
      }
    }

    // Recherche partielle ensuite
    for (final component in components) {
      if (component.canHandle(skeletonType)) {
        return component;
      }
    }

    return null;
  }

  /// Obtient toutes les instances de composants disponibles
  static List<IFormSkeletonComponent> _getAllComponents() {
    return [
      StandardFormSkeleton(),
      LoginFormSkeleton(),
      CompactFormSkeleton(),
      SearchFormSkeleton(),
      WizardFormSkeleton(),
      SurveyFormSkeleton(),
      DetailedFormSkeleton(),
    ];
  }

  /// Crée un skeleton de fallback en cas d'échec
  static Widget _createFallbackSkeleton(double? width, double? height) {
    return SizedBox(
      width: width ?? 300,
      height: height ?? 200,
      child: const Center(
        child: Text(
          'Form skeleton not available',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  /// Nettoie le cache des composants (pour les tests ou optimisation mémoire)
  static void clearCache() {
    _componentCache.clear();
  }

  /// Statistiques d'utilisation de la factory
  static Map<String, dynamic> getFactoryStats() {
    return {
      'total_components': _getAllComponents().length,
      'cached_components': _componentCache.length,
      'supported_types': supportedTypes,
      'cache_size': _componentCache.keys.toList(),
    };
  }
}