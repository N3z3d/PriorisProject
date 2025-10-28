import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// En-tête de page unifié et élégant pour toute l'application
///
/// **Design System Tokens:**
/// - Surface colorée avec effet de profondeur subtile
/// - Typographie hiérarchisée (titre + sous-titre optionnel)
/// - Actions contextuelles alignées à droite
/// - Support mode centré ou aligné à gauche
///
/// **Variantes:**
/// - Standard : titre à gauche, actions à droite
/// - Centered : titre centré avec actions en overlay
/// - Elevated : avec ombre portée pour pages scrollables
class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Titre principal de la page (obligatoire)
  final String title;

  /// Sous-titre optionnel affiché sous le titre
  final String? subtitle;

  /// Actions contextuelles (boutons, icônes)
  final List<Widget>? actions;

  /// Centre le titre au lieu de l'aligner à gauche
  final bool centerTitle;

  /// Active l'ombre portée pour indiquer le scroll
  final bool elevated;

  /// Couleur de fond (défaut: AppTheme.surfaceColor)
  final Color? backgroundColor;

  /// Widget de leading personnalisé (défaut: back button si applicable)
  final Widget? leading;

  /// Désactive le bouton retour automatique
  final bool automaticallyImplyLeading;

  /// Hauteur personnalisée (défaut: calculée selon subtitle)
  final double? preferredHeight;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.centerTitle = false,
    this.elevated = true,
    this.backgroundColor,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.preferredHeight,
  });

  /// Factory pour header centré (style Duel/Priority)
  factory PageHeader.centered({
    Key? key,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    bool elevated = false,
    Color? backgroundColor,
  }) {
    return PageHeader(
      key: key,
      title: title,
      subtitle: subtitle,
      actions: actions,
      centerTitle: true,
      elevated: elevated,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
    );
  }

  /// Factory pour header simple sans actions
  factory PageHeader.simple({
    Key? key,
    required String title,
    String? subtitle,
    bool centerTitle = false,
    Color? backgroundColor,
  }) {
    return PageHeader(
      key: key,
      title: title,
      subtitle: subtitle,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize {
    final height = preferredHeight ?? (subtitle != null ? 72.0 : 56.0);
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: _buildTitle(theme),
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions != null && actions!.isNotEmpty
          ? [
              ...actions!,
              const SizedBox(width: 8),
            ]
          : null,
      backgroundColor: backgroundColor ?? AppTheme.surfaceColor,
      elevation: elevated ? 1 : 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: elevated ? AppTheme.dividerColor.withValues(alpha: 0.15) : Colors.transparent,
      toolbarHeight: preferredSize.height,
      titleSpacing: centerTitle ? 0 : 16,
    );
  }

  Widget _buildTitle(ThemeData theme) {
    if (subtitle == null) {
      return Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.3,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// En-tête compact pour sections internes (non-AppBar)
///
/// Utilisé dans des widgets comme PriorityDuelSettingsBar
/// pour créer une cohérence visuelle sans AppBar natif
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool centerTitle;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.centerTitle = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (!centerTitle && actions != null) const SizedBox(width: 40),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  ),
                ],
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
        ],
      ),
    );
  }
}
