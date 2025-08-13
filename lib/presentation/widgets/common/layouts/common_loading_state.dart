import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget d'état de chargement commun réutilisable pour toute l'application
/// 
/// Ce widget fournit une interface unifiée pour tous les états de chargement
/// avec support pour message personnalisable, taille et couleur.
class CommonLoadingState extends StatelessWidget {
  /// Message optionnel à afficher sous l'indicateur de chargement
  final String? message;
  
  /// Taille de l'indicateur de chargement
  final double? size;
  
  /// Couleur de l'indicateur de chargement
  final Color? color;
  
  /// Espacement entre l'indicateur et le message
  final double? spacing;
  
  /// Alignement du contenu
  final AlignmentGeometry? alignment;
  
  /// Padding autour du widget
  final EdgeInsetsGeometry? padding;

  /// Constructeur du widget CommonLoadingState
  /// 
  /// [message] : Message à afficher sous l'indicateur (optionnel)
  /// [size] : Taille de l'indicateur (défaut: 24.0)
  /// [color] : Couleur de l'indicateur (défaut: AppTheme.primaryColor)
  /// [spacing] : Espacement entre l'indicateur et le message (défaut: 16.0)
  /// [alignment] : Alignement du contenu (défaut: Alignment.center)
  /// [padding] : Padding autour du widget (défaut: EdgeInsets.all(20))
  const CommonLoadingState({
    super.key,
    this.message,
    this.size,
    this.color,
    this.spacing,
    this.alignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.center,
      padding: padding ?? const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur de chargement
          SizedBox(
            width: size ?? 24.0,
            height: size ?? 24.0,
            child: CircularProgressIndicator(
              strokeWidth: (size ?? 24.0) / 8,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primaryColor,
              ),
            ),
          ),
          
          // Message optionnel
          if (message != null) ...[
            SizedBox(height: spacing ?? 16.0),
            Text(
              message!,
              style: TextStyle(
                color: color ?? AppTheme.primaryColor,
                fontSize: (size ?? 24.0) / 2,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 
