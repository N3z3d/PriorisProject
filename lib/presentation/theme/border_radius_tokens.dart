import 'package:flutter/material.dart';

/// Tokens de BorderRadius pour une cohérence visuelle dans l'application
/// 
/// Ces tokens définissent les rayons de bordure standardisés utilisés
/// dans toute l'application pour assurer une cohérence visuelle.
class BorderRadiusTokens {
  // Empêcher l'instanciation
  BorderRadiusTokens._();

  // ========== VALEURS DE BASE ==========
  
  /// Rayon zéro - pour les éléments sans arrondi
  static const double none = 0.0;
  
  /// Rayon extra petit - pour les éléments très subtils (badges, chips)
  static const double xs = 4.0;
  
  /// Rayon petit - pour les éléments compacts (boutons, inputs)
  static const double sm = 8.0;
  
  /// Rayon moyen - pour les cartes et conteneurs standards
  static const double md = 12.0;
  
  /// Rayon large - pour les modales et overlays
  static const double lg = 16.0;
  
  /// Rayon extra large - pour les éléments hero
  static const double xl = 20.0;
  
  /// Rayon XXL - pour les éléments très arrondis
  static const double xxl = 24.0;
  
  /// Rayon circulaire - pour les éléments complètement ronds
  static const double circular = 999.0;

  // ========== BORDER RADIUS PRÉDÉFINIS ==========
  
  /// BorderRadius zéro
  static const BorderRadius radiusNone = BorderRadius.zero;
  
  /// BorderRadius extra petit (4px)
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  
  /// BorderRadius petit (8px)
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  
  /// BorderRadius moyen (12px) - DÉFAUT pour les cartes
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  
  /// BorderRadius large (16px) - pour les modales
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  
  /// BorderRadius extra large (20px) - pour les éléments hero
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  
  /// BorderRadius XXL (24px)
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  
  /// BorderRadius circulaire complet
  static const BorderRadius radiusCircular = BorderRadius.all(Radius.circular(circular));

  // ========== BORDER RADIUS PARTIELS ==========
  
  /// BorderRadius seulement en haut - moyen
  static const BorderRadius radiusTopMd = BorderRadius.only(
    topLeft: Radius.circular(md),
    topRight: Radius.circular(md),
  );
  
  /// BorderRadius seulement en haut - large
  static const BorderRadius radiusTopLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
  
  /// BorderRadius seulement en bas - moyen
  static const BorderRadius radiusBottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );
  
  /// BorderRadius seulement en bas - large
  static const BorderRadius radiusBottomLg = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );
  
  /// BorderRadius seulement à gauche - moyen
  static const BorderRadius radiusLeftMd = BorderRadius.only(
    topLeft: Radius.circular(md),
    bottomLeft: Radius.circular(md),
  );
  
  /// BorderRadius seulement à droite - moyen
  static const BorderRadius radiusRightMd = BorderRadius.only(
    topRight: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );

  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Retourne un BorderRadius basé sur la taille sémantique
  static BorderRadius fromSize(RadiusSize size) {
    switch (size) {
      case RadiusSize.none:
        return radiusNone;
      case RadiusSize.xs:
        return radiusXs;
      case RadiusSize.sm:
        return radiusSm;
      case RadiusSize.md:
        return radiusMd;
      case RadiusSize.lg:
        return radiusLg;
      case RadiusSize.xl:
        return radiusXl;
      case RadiusSize.xxl:
        return radiusXxl;
      case RadiusSize.circular:
        return radiusCircular;
    }
  }
  
  /// Retourne une valeur de rayon basée sur la taille sémantique
  static double getValue(RadiusSize size) {
    switch (size) {
      case RadiusSize.none:
        return none;
      case RadiusSize.xs:
        return xs;
      case RadiusSize.sm:
        return sm;
      case RadiusSize.md:
        return md;
      case RadiusSize.lg:
        return lg;
      case RadiusSize.xl:
        return xl;
      case RadiusSize.xxl:
        return xxl;
      case RadiusSize.circular:
        return circular;
    }
  }

  // ========== MAPPINGS SÉMANTIQUES ==========
  
  /// Rayon pour les badges et labels
  static const BorderRadius badge = radiusXs;
  
  /// Rayon pour les chips et tags
  static const BorderRadius chip = radiusSm;
  
  /// Rayon pour les boutons standards
  static const BorderRadius button = radiusSm;
  
  /// Rayon pour les boutons arrondis
  static const BorderRadius buttonRounded = radiusMd;
  
  /// Rayon pour les champs de saisie
  static const BorderRadius input = radiusSm;
  
  /// Rayon pour les cartes standards
  static const BorderRadius card = radiusMd;
  
  /// Rayon pour les cartes premium/hero
  static const BorderRadius cardPremium = radiusLg;
  
  /// Rayon pour les modales et dialogs
  static const BorderRadius modal = radiusLg;
  
  /// Rayon pour les bottom sheets
  static const BorderRadius bottomSheet = radiusTopLg;
  
  /// Rayon pour les tooltips
  static const BorderRadius tooltip = radiusSm;
  
  /// Rayon pour les menus déroulants
  static const BorderRadius dropdown = radiusSm;
  
  /// Rayon pour les conteneurs d'images
  static const BorderRadius image = radiusMd;
  
  /// Rayon pour les avatars (circulaires)
  static const BorderRadius avatar = radiusCircular;
  
  /// Rayon pour les progress bars
  static const BorderRadius progressBar = radiusXs;
  
  /// Rayon pour les FAB (Floating Action Button)
  static const BorderRadius fab = radiusLg;
}

/// Énumération des tailles de rayon sémantiques
enum RadiusSize {
  none,
  xs,
  sm,
  md,
  lg,
  xl,
  xxl,
  circular,
}

/// Extension pour faciliter l'utilisation avec BuildContext
extension BorderRadiusExtension on BuildContext {
  /// Accès rapide aux tokens de BorderRadius
  Type get borderRadius => BorderRadiusTokens;
}