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
    final accessibilityService = AccessibilityService();
    
    // Vérifier les contrastes de couleurs
    final backgroundColor = _getBackgroundColor();
    final foregroundColor = _getTextColor();
    
    if (!accessibilityService.validateColorContrast(
      foregroundColor, 
      backgroundColor, 
      isLargeText: (fontSize ?? 14) >= 18
    )) {
      debugPrint('Attention: Contraste insuffisant pour le bouton "$text"');
    }
    
    final buttonStyle = _getButtonStyle().copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (states) {
          // Affiche un contour accentué lorsqu'on a le focus clavier
          if (states.contains(WidgetState.focused)) {
            return const BorderSide(color: AppTheme.accentSecondary, width: 3);
          }
          return null;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return foregroundColor.withValues(alpha: 0.2);
        }
        if (states.contains(WidgetState.hovered)) {
          return foregroundColor.withValues(alpha: 0.1);
        }
        return null;
      }),
      // Assurer une taille minimale de touche
      minimumSize: WidgetStateProperty.all(Size(
        AccessibilityService.minTouchTargetSize,
        AccessibilityService.minTouchTargetSize,
      )),
    );
    final textColor = foregroundColor;

    Widget buttonContent;
    if (isLoading) {
      buttonContent = Wrap(
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
    } else {
      buttonContent = Wrap(
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

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: tooltip ?? text,
      hint: isLoading ? (loadingText ?? 'Chargement...') : null,
      child: Container(
        constraints: BoxConstraints(
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
        child: FocusableActionDetector(
          enabled: onPressed != null && !isLoading,
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
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
        // Fond plus foncé pour améliorer le contraste
        return AppTheme.primaryColor.withValues(alpha: 0.2);
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
        // Couleur plus foncée pour améliorer le contraste
        return AppTheme.primaryColor.withValues(alpha: 0.9);
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
} 
