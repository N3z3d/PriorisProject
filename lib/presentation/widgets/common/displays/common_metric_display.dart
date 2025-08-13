import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget d'affichage de métrique réutilisable pour toute l'application
/// 
/// Ce widget fournit une interface unifiée pour afficher des métriques
/// avec support pour icône, couleur et mise en évidence.
class CommonMetricDisplay extends StatelessWidget {
  /// Valeur de la métrique (obligatoire)
  final String value;
  
  /// Label de la métrique (obligatoire)
  final String label;
  
  /// Icône optionnelle à afficher
  final IconData? icon;
  
  /// Couleur personnalisée
  final Color? color;
  
  /// Mettre en évidence la métrique
  final bool isHighlighted;
  
  /// Taille de l'icône
  final double? iconSize;
  
  /// Taille de la police de la valeur
  final double? valueFontSize;
  
  /// Taille de la police du label
  final double? labelFontSize;
  
  /// Couleur du texte de la valeur
  final Color? valueColor;
  
  /// Couleur du texte du label
  final Color? labelColor;
  
  /// Espacement entre les éléments
  final double? spacing;
  
  /// Alignement du contenu
  final CrossAxisAlignment? crossAxisAlignment;
  
  /// Padding autour du widget
  final EdgeInsetsGeometry? padding;

  /// Constructeur du widget CommonMetricDisplay
  /// 
  /// [value] : La valeur de la métrique (obligatoire)
  /// [label] : Le label de la métrique (obligatoire)
  /// [icon] : L'icône à afficher (optionnel)
  /// [color] : La couleur personnalisée (optionnel)
  /// [isHighlighted] : Mettre en évidence la métrique (défaut: false)
  /// [iconSize] : Taille de l'icône (défaut: 24.0)
  /// [valueFontSize] : Taille de la police de la valeur (défaut: 24)
  /// [labelFontSize] : Taille de la police du label (défaut: 14)
  /// [valueColor] : Couleur du texte de la valeur (défaut: basé sur color ou noir)
  /// [labelColor] : Couleur du texte du label (défaut: gris)
  /// [spacing] : Espacement entre les éléments (défaut: 8.0)
  /// [crossAxisAlignment] : Alignement du contenu (défaut: CrossAxisAlignment.center)
  /// [padding] : Padding autour du widget (défaut: EdgeInsets.all(16))
  const CommonMetricDisplay({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.isHighlighted = false,
    this.iconSize,
    this.valueFontSize,
    this.labelFontSize,
    this.valueColor,
    this.labelColor,
    this.spacing,
    this.crossAxisAlignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color metricColor = color ?? AppTheme.primaryColor;
    final double iconSizeValue = iconSize ?? 24.0;
    final double valueFontSizeValue = valueFontSize ?? 24.0;
    final double labelFontSizeValue = labelFontSize ?? 14.0;
    final Color valueColorValue = valueColor ?? (isHighlighted ? metricColor : Colors.black87);
    final Color labelColorValue = labelColor ?? Colors.grey[600]!;
    final double spacingValue = spacing ?? 8.0;
    final CrossAxisAlignment crossAxisAlignmentValue = crossAxisAlignment ?? CrossAxisAlignment.center;
    final EdgeInsetsGeometry paddingValue = padding ?? const EdgeInsets.all(16);

    return Container(
      padding: paddingValue,
      decoration: isHighlighted ? BoxDecoration(
        color: metricColor.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.radiusMd,
        border: Border.all(
          color: metricColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ) : null,
      child: Column(
        crossAxisAlignment: crossAxisAlignmentValue,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône optionnelle
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSizeValue,
              color: metricColor,
            ),
            SizedBox(height: spacingValue),
          ],
          
          // Valeur
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSizeValue,
              fontWeight: FontWeight.bold,
              color: valueColorValue,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSizeValue,
              color: labelColorValue,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 
