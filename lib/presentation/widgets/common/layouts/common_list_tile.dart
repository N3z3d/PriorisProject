import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget ListTile réutilisable pour toute l'application
class CommonListTile extends StatelessWidget {
  /// Titre principal (obligatoire)
  final String title;

  /// Sous-titre optionnel
  final String? subtitle;

  /// Widget à gauche (icône, avatar...)
  final Widget? leading;

  /// Widget à droite (icône, switch...)
  final Widget? trailing;

  /// Callback lors du tap
  final VoidCallback? onTap;

  /// Indique si l'élément est sélectionné
  final bool isSelected;

  /// Couleur de fond si sélectionné
  final Color? selectedColor;

  /// Couleur du texte du titre
  final Color? titleColor;

  /// Couleur du texte du sous-titre
  final Color? subtitleColor;

  /// Padding autour du tile
  final EdgeInsetsGeometry? padding;

  /// Constructeur
  const CommonListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.titleColor,
    this.subtitleColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected
        ? (selectedColor ?? AppTheme.primaryColor.withValues(alpha: 0.08))
        : Colors.transparent;
    final Color titleTextColor = titleColor ?? Colors.black87;
    final Color subtitleTextColor = subtitleColor ?? Colors.grey[600]!;
    final EdgeInsetsGeometry tilePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return Material(
      color: bgColor,
      borderRadius: BorderRadiusTokens.radiusSm,
      child: InkWell(
        borderRadius: BorderRadiusTokens.radiusSm,
        onTap: onTap,
        child: Padding(
          padding: tilePadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: titleTextColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
} 
