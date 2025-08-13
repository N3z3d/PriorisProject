import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/ui/responsive_service.dart';

void main() {
  group('ResponsiveService', () {
    late ResponsiveService service;

    setUp(() {
      service = ResponsiveService();
    });

    test('should be a singleton', () {
      final instance1 = ResponsiveService();
      final instance2 = ResponsiveService();
      expect(identical(instance1, instance2), isTrue);
    });

    group('getScreenType', () {
      test('should return extraSmall for width < 320', () {
        expect(service.getScreenType(319), equals(ScreenType.extraSmall));
        expect(service.getScreenType(320), equals(ScreenType.small));
      });

      test('should return small for width 320-480', () {
        expect(service.getScreenType(320), equals(ScreenType.small));
        expect(service.getScreenType(479), equals(ScreenType.small));
        expect(service.getScreenType(480), equals(ScreenType.medium));
      });

      test('should return medium for width 480-768', () {
        expect(service.getScreenType(480), equals(ScreenType.medium));
        expect(service.getScreenType(767), equals(ScreenType.medium));
        expect(service.getScreenType(768), equals(ScreenType.large));
      });

      test('should return large for width 768-1024', () {
        expect(service.getScreenType(768), equals(ScreenType.large));
        expect(service.getScreenType(1023), equals(ScreenType.large));
        expect(service.getScreenType(1024), equals(ScreenType.extraLarge));
      });

      test('should return extraLarge for width 1024-1200', () {
        expect(service.getScreenType(1024), equals(ScreenType.extraLarge));
        expect(service.getScreenType(1199), equals(ScreenType.extraLarge));
        expect(service.getScreenType(1200), equals(ScreenType.ultraWide));
      });

      test('should return ultraWide for width > 1200', () {
        expect(service.getScreenType(1200), equals(ScreenType.ultraWide));
        expect(service.getScreenType(1920), equals(ScreenType.ultraWide));
      });
    });

    group('isExtraSmallScreen', () {
      test('should return true for width < 320', () {
        expect(service.isExtraSmallScreen(319), isTrue);
        expect(service.isExtraSmallScreen(320), isFalse);
      });
    });

    group('isSmallScreen', () {
      test('should return true for width < 480', () {
        expect(service.isSmallScreen(479), isTrue);
        expect(service.isSmallScreen(480), isFalse);
      });
    });

    group('isMediumScreen', () {
      test('should return true for width < 768', () {
        expect(service.isMediumScreen(767), isTrue);
        expect(service.isMediumScreen(768), isFalse);
      });
    });

    group('getResponsiveRecommendations', () {
      test('should return recommendations for extraSmall screen', () {
        final recommendations = service.getResponsiveRecommendations(319);
        expect(recommendations, contains('Écran très petit détecté - Adaptation de l\'interface'));
        expect(recommendations, contains('Réduction de la taille des polices'));
      });

      test('should return recommendations for small screen', () {
        final recommendations = service.getResponsiveRecommendations(400);
        expect(recommendations, contains('Écran petit détecté - Interface mobile optimisée'));
        expect(recommendations, contains('Navigation adaptée pour le tactile'));
      });

      test('should return recommendations for large screen', () {
        final recommendations = service.getResponsiveRecommendations(1024);
        expect(recommendations, contains('Écran large détecté - Interface desktop optimisée'));
      });
    });

    group('getAdaptivePadding', () {
      test('should return correct padding for different screen sizes', () {
        expect(service.getAdaptivePadding(319), equals(const EdgeInsets.all(8.0)));
        expect(service.getAdaptivePadding(400), equals(const EdgeInsets.all(12.0)));
        expect(service.getAdaptivePadding(600), equals(const EdgeInsets.all(16.0)));
        expect(service.getAdaptivePadding(900), equals(const EdgeInsets.all(20.0)));
        expect(service.getAdaptivePadding(1200), equals(const EdgeInsets.all(24.0)));
      });
    });

    group('getAdaptiveFontSize', () {
      test('should return correct font size for different screen sizes', () {
        const baseSize = 16.0;
        
        expect(service.getAdaptiveFontSize(baseSize, 319), equals(12.8)); // 0.8 * 16
        expect(service.getAdaptiveFontSize(baseSize, 400), equals(14.4)); // 0.9 * 16
        expect(service.getAdaptiveFontSize(baseSize, 600), equals(16.0)); // 1.0 * 16
        expect(service.getAdaptiveFontSize(baseSize, 900), equals(17.6)); // 1.1 * 16
        expect(service.getAdaptiveFontSize(baseSize, 1200), equals(19.2)); // 1.2 * 16
      });
    });

    group('getAdaptiveDialogHeight', () {
      test('should return correct dialog height for different screen sizes', () {
        expect(service.getAdaptiveDialogHeight(319), equals(0.8));
        expect(service.getAdaptiveDialogHeight(400), equals(0.7));
        expect(service.getAdaptiveDialogHeight(600), equals(0.6));
        expect(service.getAdaptiveDialogHeight(900), equals(0.5));
        expect(service.getAdaptiveDialogHeight(1200), equals(0.5));
      });
    });

    group('getAdaptiveDialogWidth', () {
      test('should return correct dialog width for different screen sizes', () {
        expect(service.getAdaptiveDialogWidth(319), equals(0.95));
        expect(service.getAdaptiveDialogWidth(400), equals(0.9));
        expect(service.getAdaptiveDialogWidth(600), equals(0.8));
        expect(service.getAdaptiveDialogWidth(900), equals(0.6));
        expect(service.getAdaptiveDialogWidth(1200), equals(0.4)); // ultraWide, not extraLarge
        expect(service.getAdaptiveDialogWidth(1920), equals(0.4));
      });
    });

    group('getAdaptiveNavigationConfig', () {
      test('should return correct navigation config for extraSmall screen', () {
        final config = service.getAdaptiveNavigationConfig(319);
        expect(config.useBottomNavigation, isTrue);
        expect(config.showLabels, isFalse);
        expect(config.iconSize, equals(20.0));
        expect(config.itemCount, equals(3));
      });

      test('should return correct navigation config for small screen', () {
        final config = service.getAdaptiveNavigationConfig(400);
        expect(config.useBottomNavigation, isTrue);
        expect(config.showLabels, isTrue);
        expect(config.iconSize, equals(24.0));
        expect(config.itemCount, equals(4));
      });

      test('should return correct navigation config for large screen', () {
        final config = service.getAdaptiveNavigationConfig(900);
        expect(config.useBottomNavigation, isFalse);
        expect(config.showLabels, isTrue);
        expect(config.iconSize, equals(28.0));
        expect(config.itemCount, equals(5));
      });
    });
  });
} 
