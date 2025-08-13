import 'package:flutter/material.dart';

/// Service pour gérer la responsivité de l'application
/// 
/// Fournit des méthodes pour adapter l'interface selon la taille d'écran
/// et gérer les très petits écrans (< 320px).
class ResponsiveService {
  static final ResponsiveService _instance = ResponsiveService._internal();
  factory ResponsiveService() => _instance;
  ResponsiveService._internal();

  /// Breakpoints pour différents types d'écrans
  static const double _extraSmallBreakpoint = 320.0;
  static const double _smallBreakpoint = 480.0;
  static const double _mediumBreakpoint = 768.0;
  static const double _largeBreakpoint = 1024.0;
  static const double _extraLargeBreakpoint = 1200.0;

  /// Détermine le type d'écran basé sur la largeur
  ScreenType getScreenType(double width) {
    if (width < _extraSmallBreakpoint) return ScreenType.extraSmall;
    if (width < _smallBreakpoint) return ScreenType.small;
    if (width < _mediumBreakpoint) return ScreenType.medium;
    if (width < _largeBreakpoint) return ScreenType.large;
    if (width < _extraLargeBreakpoint) return ScreenType.extraLarge;
    return ScreenType.ultraWide;
  }

  /// Vérifie si l'écran est très petit (< 320px)
  bool isExtraSmallScreen(double width) {
    return width < _extraSmallBreakpoint;
  }

  /// Vérifie si l'écran est petit (< 480px)
  bool isSmallScreen(double width) {
    return width < _smallBreakpoint;
  }

  /// Vérifie si l'écran est moyen (< 768px)
  bool isMediumScreen(double width) {
    return width < _mediumBreakpoint;
  }

  /// Obtient les recommandations d'adaptation pour la taille d'écran
  List<String> getResponsiveRecommendations(double width) {
    final recommendations = <String>[];
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.extraSmall:
        recommendations.addAll([
          'Écran très petit détecté - Adaptation de l\'interface',
          'Réduction de la taille des polices',
          'Simplification de la navigation',
          'Optimisation des dialogues et modales',
        ]);
        break;
      case ScreenType.small:
        recommendations.addAll([
          'Écran petit détecté - Interface mobile optimisée',
          'Navigation adaptée pour le tactile',
          'Boutons et éléments interactifs agrandis',
        ]);
        break;
      case ScreenType.medium:
        recommendations.addAll([
          'Écran moyen détecté - Interface tablette',
          'Layout adaptatif activé',
        ]);
        break;
      case ScreenType.large:
      case ScreenType.extraLarge:
      case ScreenType.ultraWide:
        recommendations.addAll([
          'Écran large détecté - Interface desktop optimisée',
          'Utilisation optimale de l\'espace disponible',
        ]);
        break;
    }

    return recommendations;
  }

  /// Obtient les paramètres de padding adaptés à la taille d'écran
  EdgeInsets getAdaptivePadding(double width) {
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.extraSmall:
        return const EdgeInsets.all(8.0);
      case ScreenType.small:
        return const EdgeInsets.all(12.0);
      case ScreenType.medium:
        return const EdgeInsets.all(16.0);
      case ScreenType.large:
        return const EdgeInsets.all(20.0);
      case ScreenType.extraLarge:
      case ScreenType.ultraWide:
        return const EdgeInsets.all(24.0);
    }
  }

  /// Obtient la taille de police adaptée à la taille d'écran
  double getAdaptiveFontSize(double baseSize, double width) {
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.extraSmall:
        return baseSize * 0.8;
      case ScreenType.small:
        return baseSize * 0.9;
      case ScreenType.medium:
        return baseSize;
      case ScreenType.large:
        return baseSize * 1.1;
      case ScreenType.extraLarge:
      case ScreenType.ultraWide:
        return baseSize * 1.2;
    }
  }

  /// Obtient la hauteur des dialogues adaptée à la taille d'écran
  double getAdaptiveDialogHeight(double width) {
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.extraSmall:
        return 0.8; // 80% de la hauteur d'écran
      case ScreenType.small:
        return 0.7; // 70% de la hauteur d'écran
      case ScreenType.medium:
        return 0.6; // 60% de la hauteur d'écran
      case ScreenType.large:
      case ScreenType.extraLarge:
      case ScreenType.ultraWide:
        return 0.5; // 50% de la hauteur d'écran
    }
  }

  /// Obtient la largeur des dialogues adaptée à la taille d'écran
  double getAdaptiveDialogWidth(double width) {
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.extraSmall:
        return 0.95; // 95% de la largeur d'écran
      case ScreenType.small:
        return 0.9; // 90% de la largeur d'écran
      case ScreenType.medium:
        return 0.8; // 80% de la largeur d'écran
      case ScreenType.large:
        return 0.6; // 60% de la largeur d'écran
      case ScreenType.extraLarge:
        return 0.5; // 50% de la largeur d'écran
      case ScreenType.ultraWide:
        return 0.4; // 40% de la largeur d'écran
    }
  }

  /// Obtient les paramètres de navigation adaptés à la taille d'écran
  NavigationConfig getAdaptiveNavigationConfig(double width) {
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.extraSmall:
        return NavigationConfig(
          useBottomNavigation: true,
          showLabels: false,
          iconSize: 20.0,
          itemCount: 3, // Réduire le nombre d'onglets
        );
      case ScreenType.small:
        return NavigationConfig(
          useBottomNavigation: true,
          showLabels: true,
          iconSize: 24.0,
          itemCount: 4,
        );
      case ScreenType.medium:
        return NavigationConfig(
          useBottomNavigation: false,
          showLabels: true,
          iconSize: 24.0,
          itemCount: 5,
        );
      case ScreenType.large:
      case ScreenType.extraLarge:
      case ScreenType.ultraWide:
        return NavigationConfig(
          useBottomNavigation: false,
          showLabels: true,
          iconSize: 28.0,
          itemCount: 5,
        );
    }
  }
}

/// Types d'écrans supportés
enum ScreenType {
  extraSmall, // < 320px
  small,      // 320px - 480px
  medium,     // 480px - 768px
  large,      // 768px - 1024px
  extraLarge, // 1024px - 1200px
  ultraWide,  // > 1200px
}

/// Configuration de navigation adaptative
class NavigationConfig {
  final bool useBottomNavigation;
  final bool showLabels;
  final double iconSize;
  final int itemCount;

  const NavigationConfig({
    required this.useBottomNavigation,
    required this.showLabels,
    required this.iconSize,
    required this.itemCount,
  });
} 
