import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Widget d'état vide commun réutilisable pour toute l'application
/// 
/// Ce widget fournit une interface unifiée pour tous les états vides
/// avec support pour titre, sous-titre, icône et action.
class CommonEmptyState extends StatelessWidget {
  /// Titre principal de l'état vide (obligatoire)
  final String title;
  
  /// Sous-titre optionnel
  final String? subtitle;
  
  /// Icône optionnelle à afficher
  final IconData? icon;
  
  /// Callback appelé lors du tap sur l'action
  final VoidCallback? onAction;
  
  /// Label du bouton d'action
  final String? actionLabel;
  
  /// Taille de l'icône
  final double? iconSize;
  
  /// Couleur de l'icône
  final Color? iconColor;
  
  /// Taille de la police du titre
  final double? titleFontSize;
  
  /// Couleur du titre
  final Color? titleColor;
  
  /// Espacement entre les éléments
  final double? spacing;
  
  /// Alignement du contenu
  final AlignmentGeometry? alignment;
  
  /// Padding autour du widget
  final EdgeInsetsGeometry? padding;

  /// Constructeur du widget CommonEmptyState
  /// 
  /// [title] : Le titre principal (obligatoire)
  /// [subtitle] : Le sous-titre (optionnel)
  /// [icon] : L'icône à afficher (optionnel)
  /// [onAction] : Callback de l'action (optionnel)
  /// [actionLabel] : Label du bouton d'action (optionnel)
  /// [iconSize] : Taille de l'icône (défaut: 64.0)
  /// [iconColor] : Couleur de l'icône (défaut: Colors.grey[400])
  /// [titleFontSize] : Taille de la police du titre (défaut: 18)
  /// [titleColor] : Couleur du titre (défaut: Colors.grey[600])
  /// [spacing] : Espacement entre les éléments (défaut: 16.0)
  /// [alignment] : Alignement du contenu (défaut: Alignment.center)
  /// [padding] : Padding autour du widget (défaut: EdgeInsets.all(32))
  const CommonEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.iconSize,
    this.iconColor,
    this.titleFontSize,
    this.titleColor,
    this.spacing,
    this.alignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.center,
      padding: padding ?? const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Icône optionnelle
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize ?? 64.0,
              color: iconColor ?? Colors.grey[400],
            ),
            SizedBox(height: spacing ?? 16.0),
          ],
          
          // Titre
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize ?? 18,
              fontWeight: FontWeight.w600,
              color: titleColor ?? Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          // Sous-titre optionnel
          if (subtitle != null) ...[
            SizedBox(height: (spacing ?? 16.0) / 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: (titleFontSize ?? 18) - 2,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          // Bouton d'action optionnel
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: spacing ?? 16.0),
            CommonButton(
              text: actionLabel!,
              onPressed: onAction,
            ),
          ],
        ],
        ),
      ),
    );
  }
} 
