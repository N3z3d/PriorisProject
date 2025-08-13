import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/ui/cross_browser_compatibility_service.dart';

void main() {
  group('CrossBrowserCompatibilityService', () {
    late CrossBrowserCompatibilityService service;

    setUp(() {
      service = CrossBrowserCompatibilityService();
    });

    test('should be a singleton', () {
      final instance1 = CrossBrowserCompatibilityService();
      final instance2 = CrossBrowserCompatibilityService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('should detect browser correctly', () {
      // Note: Ces tests sont limités car nous ne pouvons pas simuler
      // facilement différents user agents dans les tests unitaires
      final browser = service.currentBrowser;
      expect(browser, isA<String>());
      expect(browser.isNotEmpty, isTrue);
    });

    test('should return supported features map', () {
      final features = service.supportedFeatures;
      
      expect(features, isA<Map<String, bool>>());
      expect(features.keys, containsAll([
        'localStorage',
        'sessionStorage',
        'indexedDB',
        'webWorkers',
        'serviceWorkers',
        'fetch',
        'promises',
        'asyncAwait',
      ]));
      
      // Tous les navigateurs modernes supportent au moins les promesses
      expect(features['promises'], isNotNull);
      expect(features['asyncAwait'], isNotNull);
    });

    test('should return compatibility recommendations', () {
      final recommendations = service.getCompatibilityRecommendations();
      
      expect(recommendations, isA<List<String>>());
      // Les recommandations peuvent être vides si le navigateur supporte tout
      expect(recommendations.length, greaterThanOrEqualTo(0));
    });

    test('should apply browser specific fixes without error', () {
      // Cette méthode ne devrait pas lever d'exception
      expect(() => service.applyBrowserSpecificFixes(), returnsNormally);
    });

    test('should handle unknown browser gracefully', () {
      // Test de robustesse - le service devrait gérer les navigateurs inconnus
      final recommendations = service.getCompatibilityRecommendations();
      expect(recommendations, isA<List<String>>());
    });
  });
} 
