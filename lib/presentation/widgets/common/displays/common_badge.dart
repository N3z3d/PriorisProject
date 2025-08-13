import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget badge réutilisable pour toute l'application
class CommonBadge extends StatelessWidget {
  /// Texte du badge (obligatoire)
  final String text;

  /// Label du badge (alias pour text)
  final String? label;

  /// Couleur de fond du badge
  final Color? color;

  /// Couleur du texte
  final Color? textColor;

  /// Taille de la police
  final double? fontSize;

  /// Padding autour du texte
  final EdgeInsetsGeometry? padding;

  /// Rayon de bordure
  final BorderRadius? borderRadius;

  /// Constructeur
  const CommonBadge({
    super.key,
    required this.text,
    this.label,
    this.color,
    this.textColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = color ?? AppTheme.primaryColor.withValues(alpha: 0.15);
    final Color badgeTextColor = textColor ?? _getAccessibleTextColor(badgeColor);
    final double badgeFontSize = fontSize ?? 13.0;
    final EdgeInsetsGeometry badgePadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
    final BorderRadius badgeRadius = borderRadius ?? BorderRadiusTokens.badge;

    return Semantics(
      label: label ?? text,
      child: Container(
        padding: badgePadding,
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: badgeRadius,
        ),
        child: Text(
          label ?? text,
          style: TextStyle(
            color: badgeTextColor,
            fontSize: badgeFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Calcule la couleur de texte (noir ou blanc) offrant le meilleur contraste
  Color _getAccessibleTextColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
} 
