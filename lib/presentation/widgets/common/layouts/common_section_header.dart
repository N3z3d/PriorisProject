import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget Header de section commun réutilisable pour toute l'application
/// 
/// Ce widget fournit une interface unifiée pour tous les headers de section
/// avec support optionnel pour sous-titre, icône et action.
class CommonSectionHeader extends StatelessWidget {
  /// Titre principal du header (obligatoire)
  final String title;
  
  /// Sous-titre optionnel
  final String? subtitle;
  
  /// Icône optionnelle à afficher à côté du titre
  final IconData? icon;
  
  /// Callback appelé lors du tap sur l'action
  final VoidCallback? onAction;
  
  /// Label du bouton d'action
  final String? actionLabel;
  
  /// Taille de la police du titre
  final double? titleFontSize;
  
  /// Couleur du titre
  final Color? titleColor;
  
  /// Espacement entre les éléments
  final double? spacing;

  /// Constructeur du widget CommonSectionHeader
  /// 
  /// [title] : Le titre principal (obligatoire)
  /// [subtitle] : Le sous-titre (optionnel)
  /// [icon] : L'icône à afficher (optionnel)
  /// [onAction] : Callback de l'action (optionnel)
  /// [actionLabel] : Label du bouton d'action (optionnel)
  /// [titleFontSize] : Taille de la police du titre (défaut: 18)
  /// [titleColor] : Couleur du titre (défaut: AppTheme.primaryColor)
  /// [spacing] : Espacement entre les éléments (défaut: 8)
  const CommonSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.titleFontSize,
    this.titleColor,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icône optionnelle
        if (icon != null) ...[
          Icon(
            icon,
            color: titleColor ?? AppTheme.primaryColor,
            size: titleFontSize ?? 18,
          ),
          SizedBox(width: spacing ?? 8),
        ],
        
        // Contenu principal (titre + sous-titre)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize ?? 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? AppTheme.primaryColor,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: (spacing ?? 8) / 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: (titleFontSize ?? 18) - 4,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Bouton d'action optionnel
        if (onAction != null && actionLabel != null) ...[
          SizedBox(width: spacing ?? 8),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
} 
