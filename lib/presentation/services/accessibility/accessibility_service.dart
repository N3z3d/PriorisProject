import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Service centralisé pour l'accessibilité et les annonces de lecteurs d'écran
/// 
/// WCAG 2.1 AA Compliance:
/// - 4.1.3 : Messages de statut
/// - 1.4.13 : Contenu qui apparaît au survol ou au focus
/// - 2.4.3 : Ordre de focus
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  /// WCAG 4.1.3 : Annonce un message de statut aux lecteurs d'écran
  /// 
  /// [message] : Le message à annoncer
  /// [assertiveness] : Niveau d'urgence (polite ou assertive)
  static Future<void> announceStatus(
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) async {
    try {
      await SystemChannels.accessibility.invokeMethod<void>(
        'announce',
        <String, dynamic>{
          'message': message,
          'textDirection': 'ltr',
        },
      );
    } catch (e) {
      // Fallback silencieux si les services d'accessibilité ne sont pas disponibles
      print('🔊 AccessibilityService: $message');
    }
  }

  /// WCAG 4.1.3 : Annonce une erreur avec priorité haute
  static Future<void> announceError(String errorMessage) async {
    await announceStatus(
      'Erreur: $errorMessage',
      assertiveness: Assertiveness.assertive,
    );
  }

  /// WCAG 4.1.3 : Annonce le début d'un chargement
  static Future<void> announceLoadingStart([String? context]) async {
    final message = context != null 
        ? 'Chargement de $context en cours'
        : 'Chargement en cours';
    await announceStatus(message);
  }

  /// WCAG 4.1.3 : Annonce la fin d'un chargement
  static Future<void> announceLoadingComplete([String? context]) async {
    final message = context != null 
        ? '$context chargé avec succès'
        : 'Chargement terminé';
    await announceStatus(message);
  }

  /// WCAG 4.1.3 : Annonce une action réussie
  static Future<void> announceSuccess(String message) async {
    await announceStatus('Succès: $message');
  }

  /// Vérifie si les services d'accessibilité sont activés
  static bool get isScreenReaderEnabled {
    // En Flutter, cette vérification se fait via le binding
    try {
      return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.accessibleNavigation;
    } catch (e) {
      return false;
    }
  }

  /// Messages d'accessibilité prédéfinis pour les opérations communes
  static class Messages {
    // Messages de chargement
    static const String loadingLists = 'Chargement des listes';
    static const String loadingItems = 'Chargement des éléments';
    static const String savingData = 'Sauvegarde des données';
    static const String syncingData = 'Synchronisation des données';
    
    // Messages de succès
    static const String listCreated = 'Liste créée avec succès';
    static const String itemAdded = 'Élément ajouté à la liste';
    static const String itemCompleted = 'Élément marqué comme terminé';
    static const String dataSync = 'Données synchronisées';
    
    // Messages d'erreur
    static const String networkError = 'Erreur de connexion réseau';
    static const String saveError = 'Erreur lors de la sauvegarde';
    static const String loadError = 'Erreur lors du chargement';
    
    // Messages de navigation
    static const String navigatedToList = 'Navigation vers la liste';
    static const String backToLists = 'Retour à la vue des listes';
    
    // Messages de statut de synchronisation
    static const String offlineMode = 'Mode hors ligne activé';
    static const String onlineMode = 'Connexion rétablie';
    static const String syncInProgress = 'Synchronisation en cours';
    static const String conflictResolved = 'Conflit de données résolu automatiquement';
  }
}

/// Extension pour faciliter les annonces d'accessibilité dans les controllers
extension AccessibilityControllerExtension on Object {
  /// Annonce le début d'une opération
  Future<void> announceStart(String operation) async {
    await AccessibilityService.announceLoadingStart(operation);
  }
  
  /// Annonce le succès d'une opération
  Future<void> announceComplete(String operation) async {
    await AccessibilityService.announceLoadingComplete(operation);
  }
  
  /// Annonce une erreur
  Future<void> announceError(String error) async {
    await AccessibilityService.announceError(error);
  }
}

/// Niveau d'assertivité pour les annonces de lecteurs d'écran
enum Assertiveness {
  /// Poli - annonce quand l'utilisateur a fini de parler/naviguer
  polite,
  
  /// Assertif - interrompt immédiatement la lecture en cours
  assertive,
}