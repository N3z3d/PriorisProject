import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Service spécialisé pour la construction des headers premium - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique pour la construction et styling des headers
/// - OCP: Extensible via configuration personnalisée des animations et couleurs
/// - LSP: Compatible avec les interfaces de construction de header
/// - ISP: Interface focalisée sur les headers uniquement
/// - DIP: Dépend des abstractions Flutter pour les animations
///
/// Features:
/// - Headers avec gradients premium adaptatifs
/// - Animations de glow synchronisées
/// - Icons avec effets de shadow dynamiques
/// - Typography premium avec letterspacing optimisé
/// - Support des thèmes clairs et sombres
/// - Gestion de l'accessibilité avec labels sémantiques
///
/// CONSTRAINTS: <150 lignes (extrait de 669 lignes)
class PremiumHeaderBuilder {

  /// Configuration par défaut des headers
  static const double _defaultIconSize = 28.0;
  static const double _defaultTitleFontSize = 22.0;
  static const double _defaultSubtitleFontSize = 14.0;

  /// Construit un header premium avec animations de glow
  Widget buildAnimatedPremiumHeader(
    BuildContext context, {
    required Animation<double> glowAnimation,
    required IconData icon,
    required String title,
    required String subtitle,
    Color? primaryColor,
    String? iconSemanticLabel,
    double iconSize = _defaultIconSize,
    EdgeInsetsGeometry? padding,
  }) {
    final effectivePrimaryColor = primaryColor ?? Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: _buildHeaderDecoration(
            context,
            effectivePrimaryColor,
            glowAnimation.value,
          ),
          child: _buildHeaderContent(
            context,
            icon: icon,
            title: title,
            subtitle: subtitle,
            primaryColor: effectivePrimaryColor,
            glowValue: glowAnimation.value,
            iconSize: iconSize,
            iconSemanticLabel: iconSemanticLabel,
          ),
        );
      },
    );
  }

  /// Construit un header statique (sans animations)
  Widget buildStaticPremiumHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? primaryColor,
    String? iconSemanticLabel,
    double iconSize = _defaultIconSize,
    EdgeInsetsGeometry? padding,
  }) {
    final effectivePrimaryColor = primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: _buildHeaderDecoration(context, effectivePrimaryColor, 0.0),
      child: _buildHeaderContent(
        context,
        icon: icon,
        title: title,
        subtitle: subtitle,
        primaryColor: effectivePrimaryColor,
        glowValue: 0.0,
        iconSize: iconSize,
        iconSemanticLabel: iconSemanticLabel,
      ),
    );
  }

  /// Construit un header pour dialog de confirmation
  Widget buildConfirmationHeader({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    String? iconSemanticLabel,
    double iconSize = 32.0,
  }) {
    return Column(
      children: [
        _buildWarningIconContainer(
          icon: icon,
          iconColor: iconColor ?? Colors.red[600]!,
          iconSemanticLabel: iconSemanticLabel,
          iconSize: iconSize,
        ),
        const SizedBox(height: 20),
        _buildConfirmationTitle(
          title: title,
          titleColor: titleColor ?? Colors.red[800]!,
        ),
      ],
    );
  }

  // === MÉTHODES PRIVÉES ===

  /// Construit la décoration du header avec gradient animé
  BoxDecoration _buildHeaderDecoration(
    BuildContext context,
    Color primaryColor,
    double glowValue,
  ) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withOpacity(0.1 + 0.05 * glowValue),
          primaryColor.withOpacity(0.05 + 0.03 * glowValue),
        ],
      ),
    );
  }

  /// Construit le contenu principal du header
  Widget _buildHeaderContent(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required double glowValue,
    required double iconSize,
    String? iconSemanticLabel,
  }) {
    return Row(
      children: [
        _buildAnimatedIconContainer(
          context,
          icon: icon,
          primaryColor: primaryColor,
          glowValue: glowValue,
          iconSize: iconSize,
          semanticLabel: iconSemanticLabel,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHeaderTexts(
            context,
            title: title,
            subtitle: subtitle,
            primaryColor: primaryColor,
          ),
        ),
      ],
    );
  }

  /// Construit le container de l'icône avec animations
  Widget _buildAnimatedIconContainer(
    BuildContext context, {
    required IconData icon,
    required Color primaryColor,
    required double glowValue,
    required double iconSize,
    String? semanticLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadiusTokens.button,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12 * (1 + glowValue * 0.5),
            spreadRadius: 2 * glowValue,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
        semanticLabel: semanticLabel,
      ),
    );
  }

  /// Construit les textes du header
  Widget _buildHeaderTexts(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _defaultTitleFontSize,
            fontWeight: FontWeight.w700,
            color: primaryColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: _defaultSubtitleFontSize,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Construit le container d'icône pour les confirmations
  Widget _buildWarningIconContainer({
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    String? iconSemanticLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
        semanticLabel: iconSemanticLabel,
      ),
    );
  }

  /// Construit le titre pour les confirmations
  Widget _buildConfirmationTitle({
    required String title,
    required Color titleColor,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: titleColor,
      ),
    );
  }
}