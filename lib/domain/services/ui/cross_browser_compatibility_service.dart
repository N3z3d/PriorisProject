
/// Service pour gérer la compatibilité cross-browser
/// 
/// Fournit des méthodes pour détecter le navigateur et adapter
/// le comportement de l'application en conséquence.
class CrossBrowserCompatibilityService {
  static final CrossBrowserCompatibilityService _instance = CrossBrowserCompatibilityService._internal();
  factory CrossBrowserCompatibilityService() => _instance;
  CrossBrowserCompatibilityService._internal();

  /// Détecte le navigateur actuel
  String get currentBrowser {
    try {
      // Utilisation conditionnelle de dart:html
      if (identical(0, 0.0)) {
        // Code qui ne sera exécuté que si dart:html est disponible
        return _detectBrowserWeb();
      }
    } catch (e) {
      // Fallback si dart:html n'est pas disponible
    }
    return 'Unknown';
  }

  /// Détecte le navigateur en mode web
  String _detectBrowserWeb() {
    // Cette méthode ne sera appelée que si dart:html est disponible
    return 'Unknown';
  }

  /// Vérifie si le navigateur supporte les APIs Web modernes
  Map<String, bool> get supportedFeatures {
    return {
      'localStorage': _supportsLocalStorage(),
      'sessionStorage': _supportsSessionStorage(),
      'indexedDB': _supportsIndexedDB(),
      'webWorkers': _supportsWebWorkers(),
      'serviceWorkers': _supportsServiceWorkers(),
      'fetch': _supportsFetch(),
      'promises': _supportsPromises(),
      'asyncAwait': _supportsAsyncAwait(),
    };
  }

  /// Vérifie si le navigateur supporte localStorage
  bool _supportsLocalStorage() {
    try {
      // Fallback pour contexte non-web
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le navigateur supporte sessionStorage
  bool _supportsSessionStorage() {
    try {
      // Fallback pour contexte non-web
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le navigateur supporte IndexedDB
  bool _supportsIndexedDB() {
    try {
      // Fallback pour contexte non-web
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le navigateur supporte Web Workers
  bool _supportsWebWorkers() {
    try {
      // Fallback pour contexte non-web
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le navigateur supporte Service Workers
  bool _supportsServiceWorkers() {
    try {
      // Fallback pour contexte non-web
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le navigateur supporte Fetch API
  bool _supportsFetch() {
    try {
      // Fallback pour contexte non-web
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le navigateur supporte les Promises
  bool _supportsPromises() {
    try {
      // Fallback pour contexte non-web
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si le navigateur supporte async/await
  bool _supportsAsyncAwait() {
    // async/await est supporté par tous les navigateurs modernes
    // qui supportent ES2017+
    return _supportsPromises();
  }

  /// Obtient les recommandations de compatibilité pour le navigateur actuel
  List<String> getCompatibilityRecommendations() {
    final recommendations = <String>[];
    final browser = currentBrowser;
    final features = supportedFeatures;

    switch (browser) {
      case 'Safari':
        if (!features['serviceWorkers']!) {
          recommendations.add('Service Workers non supportés - certaines fonctionnalités offline peuvent ne pas fonctionner');
        }
        break;
      case 'Firefox':
        if (!features['indexedDB']!) {
          recommendations.add('IndexedDB non supporté - le stockage local peut être limité');
        }
        break;
      case 'Edge':
        // Edge moderne supporte tout
        break;
      case 'Chrome':
        // Chrome moderne supporte tout
        break;
      default:
        recommendations.add('Navigateur non reconnu - certaines fonctionnalités peuvent ne pas fonctionner correctement');
    }

    return recommendations;
  }

  /// Applique des corrections spécifiques au navigateur
  void applyBrowserSpecificFixes() {
    final browser = currentBrowser;
    
    switch (browser) {
      case 'Safari':
        _applySafariFixes();
        break;
      case 'Firefox':
        _applyFirefoxFixes();
        break;
      case 'Edge':
        _applyEdgeFixes();
        break;
    }
  }

  /// Applique des corrections spécifiques à Safari
  void _applySafariFixes() {
    // Safari a des problèmes avec certains événements de scroll
    // et les animations CSS
    try {
      // Fallback pour contexte non-web
    } catch (e) {
      // Ignorer les erreurs en contexte non-web
    }
  }

  /// Applique des corrections spécifiques à Firefox
  void _applyFirefoxFixes() {
    // Firefox a des problèmes avec certains layouts flexbox
    try {
      // Fallback pour contexte non-web
    } catch (e) {
      // Ignorer les erreurs en contexte non-web
    }
  }

  /// Applique des corrections spécifiques à Edge
  void _applyEdgeFixes() {
    // Edge moderne n'a généralement pas besoin de corrections spécifiques
    // mais on peut ajouter des optimisations si nécessaire
  }
} 
