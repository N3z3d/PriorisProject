import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

/// Types de boutons disponibles
enum ButtonType {
  primary,
  secondary,
  danger,
}

/// Variantes de boutons pour compatibilité
enum CommonButtonVariant {
  primary,
  secondary,
  text,
  danger,
}

/// Widget bouton réutilisable pour toute l'application
class CommonButton extends StatelessWidget {
  /// Texte du bouton (obligatoire)
  final String text;

  /// Label du bouton (alias pour text)
  final String? label;

  /// Callback lors du tap
  final VoidCallback? onPressed;

  /// Type de bouton
  final ButtonType type;

  /// Variante de bouton (pour compatibilité)
  final CommonButtonVariant? variant;

  /// Afficher un indicateur de chargement
  final bool isLoading;

  /// Icône optionnelle
  final IconData? icon;

  /// Largeur fixe du bouton
  final double? width;

  /// Hauteur du bouton
  final double? height;

  /// Couleur personnalisée
  final Color? color;

  /// Couleur du texte
  final Color? textColor;

  /// Taille de la police
  final double? fontSize;

  /// Rayon de bordure
  final BorderRadius? borderRadius;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Tooltip du bouton
  final String? tooltip;

  /// Texte de chargement
  final String? loadingText;

  /// Constructeur
  const CommonButton({
    super.key,
    required this.text,
    this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.variant,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.color,
    this.textColor,
    this.fontSize,
    this.borderRadius,
    this.padding,
    this.tooltip,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final foregroundColor = _getTextColor();

    if (!_validateColorContrast(foregroundColor, backgroundColor)) {
      return _buildAccessibleButton();
    }

    final buttonStyle = _buildButtonStyle(foregroundColor);

    return _buildButtonWrapper(
      backgroundColor: backgroundColor,
      buttonStyle: buttonStyle,
      buttonContent: _ButtonContent(
        isLoading: isLoading,
        loadingText: loadingText,
        text: text,
        icon: icon,
        textColor: foregroundColor,
      ),
    );
  }

  /// Valide le contraste des couleurs
  bool _validateColorContrast(Color foreground, Color background) {
    final accessibilityService = AccessibilityService();

    if (!accessibilityService.validateColorContrast(
      foreground,
      background,
      isLargeText: (fontSize ?? 14) >= 18
    )) {
      debugPrint('ERREUR CRITIQUE: Contraste insuffisant détecté pour "$text" - Ratio: ${_calculateContrastRatio(foreground, background).toStringAsFixed(2)}');
      return false;
    }
    return true;
  }

  /// Construit le style du bouton avec les états interactifs
  ButtonStyle _buildButtonStyle(Color foregroundColor) {
    return _getButtonStyle().copyWith(
      side: _buildSideProperty(),
      overlayColor: _buildOverlayColor(foregroundColor),
      minimumSize: WidgetStateProperty.all(const Size(
        AccessibilityService.minTouchTargetSize,
        AccessibilityService.minTouchTargetSize,
      )),
    );
  }

  /// Construit la propriété de bordure avec focus
  WidgetStateProperty<BorderSide?> _buildSideProperty() {
    return WidgetStateProperty.resolveWith<BorderSide?>(
      (states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: AppTheme.accentSecondary, width: 3);
        }
        return null;
      },
    );
  }

  /// Construit la couleur d'overlay pour les états hover/pressed
  WidgetStateProperty<Color?> _buildOverlayColor(Color foregroundColor) {
    return WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return foregroundColor.withValues(alpha: 0.2);
      }
      if (states.contains(WidgetState.hovered)) {
        return foregroundColor.withValues(alpha: 0.1);
      }
      return null;
    });
  }

  /// Construit le wrapper du bouton avec sémantique et focus
  Widget _buildButtonWrapper({
    required Color backgroundColor,
    required ButtonStyle buttonStyle,
    required Widget buttonContent,
  }) {
    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: tooltip ?? text,
      hint: isLoading ? (loadingText ?? 'Chargement...') : null,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AccessibilityService.minTouchTargetSize,
          minHeight: AccessibilityService.minTouchTargetSize,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusTokens.button,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildFocusableButton(buttonStyle, buttonContent),
      ),
    );
  }

  /// Construit le bouton avec gestion du focus clavier
  Widget _buildFocusableButton(ButtonStyle buttonStyle, Widget buttonContent) {
    return FocusableActionDetector(
      enabled: onPressed != null && !isLoading,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            if (onPressed != null && !isLoading) {
              onPressed!();
            }
            return null;
          },
        ),
      },
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: Tooltip(
          message: tooltip ?? text,
          child: buttonContent,
        ),
      ),
    );
  }

  /// Retourne le style du bouton
  ButtonStyle _getButtonStyle() {
    final Color buttonColor = _getBackgroundColor();
    final BorderRadius buttonRadius = borderRadius ?? BorderRadiusTokens.button;
    final EdgeInsetsGeometry buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: _getTextColor(),
      padding: buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: buttonRadius,
      ),
      elevation: type == ButtonType.primary ? 2 : 0,
    );
  }

  /// Retourne la couleur du bouton selon le type
  Color _getBackgroundColor() {
    if (color != null) return color!;

    // Utiliser la variante si spécifiée
    final effectiveType = variant != null ? _convertVariantToType(variant!) : type;

    switch (effectiveType) {
      case ButtonType.primary:
        return AppTheme.primaryColor;
      case ButtonType.secondary:
        // Fond accessible avec contraste suffisant
        return AppTheme.cleanSurfaceColor;
      case ButtonType.danger:
        return Colors.red;
    }
  }

  /// Retourne la couleur du texte selon le type
  Color _getTextColor() {
    if (textColor != null) return textColor!;

    // Utiliser la variante si spécifiée
    final effectiveType = variant != null ? _convertVariantToType(variant!) : type;

    switch (effectiveType) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        // Couleur de texte garantissant contraste AA
        return AppTheme.primaryColor;
      case ButtonType.danger:
        return Colors.white;
    }
  }

  /// Convertit une variante en type de bouton
  ButtonType _convertVariantToType(CommonButtonVariant variant) {
    switch (variant) {
      case CommonButtonVariant.primary:
        return ButtonType.primary;
      case CommonButtonVariant.secondary:
        return ButtonType.secondary;
      case CommonButtonVariant.text:
        return ButtonType.secondary;
      case CommonButtonVariant.danger:
        return ButtonType.danger;
    }
  }

  /// Calcule le ratio de contraste entre deux couleurs
  double _calculateContrastRatio(Color foreground, Color background) {
    final fLuminance = _getLuminance(foreground);
    final bLuminance = _getLuminance(background);
    final lightest = fLuminance > bLuminance ? fLuminance : bLuminance;
    final darkest = fLuminance > bLuminance ? bLuminance : fLuminance;
    return (lightest + 0.05) / (darkest + 0.05);
  }

  /// Calcule la luminance d'une couleur
  double _getLuminance(Color color) {
    final r = _getRelativeLuminance((color.r * 255.0).round() / 255.0);
    final g = _getRelativeLuminance((color.g * 255.0).round() / 255.0);
    final b = _getRelativeLuminance((color.b * 255.0).round() / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calcule la luminance relative d'un composant de couleur
  double _getRelativeLuminance(double component) {
    return component <= 0.03928
        ? component / 12.92
        : ((component + 0.055) / 1.055) * ((component + 0.055) / 1.055);
  }

  /// Construit un bouton avec couleurs garanties accessibles
  Widget _buildAccessibleButton() {
    return Container(
      constraints: BoxConstraints(
        minWidth: AccessibilityService.minTouchTargetSize,
        minHeight: AccessibilityService.minTouchTargetSize,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor, // Couleur AA-conforme
          foregroundColor: Colors.white, // Contraste garanti 4.5:1+
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadiusTokens.button,
          ),
          elevation: type == ButtonType.primary ? 2 : 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize ?? 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Widget privé pour le contenu du bouton (état chargement ou normal)
class _ButtonContent extends StatelessWidget {
  final bool isLoading;
  final String? loadingText;
  final String text;
  final IconData? icon;
  final Color textColor;

  const _ButtonContent({
    required this.isLoading,
    required this.loadingText,
    required this.text,
    required this.icon,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingContent();
    }
    return _buildNormalContent();
  }

  /// Contenu affiché pendant le chargement
  Widget _buildLoadingContent() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
        SizedBox(
          width: 120,
          child: Text(
            loadingText ?? 'Chargement...',
            style: TextStyle(color: textColor),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Contenu normal du bouton
  Widget _buildNormalContent() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        if (icon != null)
          Icon(icon, size: 18, color: textColor),
        SizedBox(
          width: 120,
          child: Text(
            text,
            style: TextStyle(color: textColor),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
