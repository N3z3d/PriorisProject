import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Service spécialisé pour la construction des sections de contenu - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique pour la construction et styling du contenu
/// - OCP: Extensible via configuration personnalisée des sections
/// - LSP: Compatible avec les interfaces de construction de contenu
/// - ISP: Interface focalisée sur les sections de contenu uniquement
/// - DIP: Dépend des abstractions Flutter pour le layout et styling
///
/// Features:
/// - Sections de contenu avec typography premium
/// - Cartes d'information avec glassmorphisme
/// - Messages descriptifs avec hiérarchie visuelle
/// - Support des icônes et illustrations contextuelles
/// - Layouts responsifs et accessibles
/// - Gestion des couleurs thématiques
///
/// CONSTRAINTS: <150 lignes (extrait de 669 lignes)
class ContentSectionBuilder {

  /// Configuration par défaut du contenu
  static const double _defaultMainFontSize = 18.0;
  static const double _defaultSecondaryFontSize = 16.0;
  static const double _defaultSmallFontSize = 14.0;

  /// Construit une section de contenu principal
  Widget buildMainContentSection({
    required String primaryText,
    String? secondaryText,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    double primaryFontSize = _defaultMainFontSize,
    double? lineHeight,
    FontWeight primaryFontWeight = FontWeight.w600,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          primaryText,
          style: TextStyle(
            fontSize: primaryFontSize,
            color: primaryTextColor ?? Colors.grey[800],
            fontWeight: primaryFontWeight,
            height: lineHeight ?? 1.4,
          ),
        ),
        if (secondaryText != null) ...[
          const SizedBox(height: 16),
          Text(
            secondaryText,
            style: TextStyle(
              fontSize: _defaultSecondaryFontSize,
              color: secondaryTextColor ?? Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  /// Construit une carte d'information premium avec glassmorphisme
  Widget buildPremiumInfoCard({
    required IconData icon,
    required String title,
    required String description,
    Color? primaryColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    final effectivePrimaryColor = primaryColor ?? Colors.blue;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: (backgroundColor ?? effectivePrimaryColor).withOpacity(0.05),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: effectivePrimaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: effectivePrimaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCardIcon(icon, effectivePrimaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCardContent(title, description, effectivePrimaryColor),
          ),
        ],
      ),
    );
  }

  /// Construit une section de description avec multiple paragraphes
  Widget buildDescriptionSection({
    required List<String> paragraphs,
    Color? textColor,
    double fontSize = _defaultSecondaryFontSize,
    double spacing = 8.0,
    TextAlign textAlign = TextAlign.center,
    FontWeight? fontWeight,
  }) {
    return Column(
      children: paragraphs.map((paragraph) {
        final isFirst = paragraphs.indexOf(paragraph) == 0;
        return Column(
          children: [
            if (!isFirst) SizedBox(height: spacing),
            Text(
              paragraph,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor ?? Colors.grey[700],
                height: 1.4,
                fontWeight: fontWeight,
              ),
              textAlign: textAlign,
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Construit une section avec contenu flexible
  Widget buildFlexibleContentSection({
    required Widget child,
    EdgeInsetsGeometry? padding,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return Flexible(
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: [child],
        ),
      ),
    );
  }

  /// Construit une section d'avertissement avec styling spécial
  Widget buildWarningSection({
    required String warningText,
    String? additionalText,
    Color warningColor = Colors.orange,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: warningColor.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warningText,
                  style: TextStyle(
                    fontSize: _defaultSmallFontSize,
                    color: warningColor.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (additionalText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    additionalText,
                    style: TextStyle(
                      fontSize: 12,
                      color: warningColor.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === MÉTHODES PRIVÉES ===

  /// Construit l'icône de la carte d'information
  Widget _buildCardIcon(IconData icon, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: primaryColor.shade600,
        size: 24,
      ),
    );
  }

  /// Construit le contenu de la carte d'information
  Widget _buildCardContent(String title, String description, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: primaryColor.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.3,
          ),
        ),
      ],
    );
  }
}