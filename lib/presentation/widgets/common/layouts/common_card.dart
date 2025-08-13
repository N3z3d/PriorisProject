import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget Card commun réutilisable pour toute l'application
/// 
/// Ce widget fournit une interface unifiée pour tous les cards de l'application
/// avec des props configurables pour s'adapter aux différents besoins.
class CommonCard extends StatelessWidget {
  /// Contenu du card
  final Widget child;
  
  /// Padding interne du card
  final EdgeInsetsGeometry? padding;
  
  /// Élévation du card (ombre)
  final double? elevation;
  
  /// Rayon de bordure du card
  final BorderRadius? borderRadius;
  
  /// Couleur de fond du card
  final Color? backgroundColor;
  
  /// Marge externe du card
  final EdgeInsetsGeometry? margin;
  
  /// Largeur du card
  final double? width;
  
  /// Hauteur du card
  final double? height;
  
  /// Callback appelé lors du tap sur le card
  final VoidCallback? onTap;

  /// Constructeur du widget CommonCard
  /// 
  /// [child] : Le contenu du card (obligatoire)
  /// [padding] : Padding interne (défaut: EdgeInsets.all(20))
  /// [elevation] : Élévation du card (défaut: 4.0)
  /// [borderRadius] : Rayon de bordure (défaut: BorderRadiusTokens.card)
  /// [backgroundColor] : Couleur de fond (défaut: Colors.white)
  /// [margin] : Marge externe (défaut: EdgeInsets.zero)
  /// [width] : Largeur fixe (optionnel)
  /// [height] : Hauteur fixe (optionnel)
  /// [onTap] : Callback de tap (optionnel)
  const CommonCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadiusTokens.card,
      ),
      color: backgroundColor ?? Colors.white,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

    // Si onTap est fourni, envelopper dans un GestureDetector
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
} 
