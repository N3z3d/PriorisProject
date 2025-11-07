import 'package:flutter/material.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Service spécialisé pour la construction des boutons d'action - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique pour la construction et styling des boutons
/// - OCP: Extensible via configuration personnalisée des boutons
/// - LSP: Compatible avec les interfaces de boutons interactifs
/// - ISP: Interface focalisée sur les boutons d'action uniquement
/// - DIP: Dépend des abstractions Flutter pour les interactions
///
/// Features:
/// - Boutons premium avec gradients et shadows
/// - Boutons destructifs avec styling d'avertissement
/// - Support des animations physiques optionnelles
/// - Gestion de l'accessibilité avec semantics
/// - Layouts responsive pour différentes tailles d'écran
/// - Support des thèmes et couleurs personnalisées
///
/// CONSTRAINTS: <200 lignes (extrait de 669 lignes)
class ActionButtonsBuilder {

  /// Configuration par défaut des boutons
  static const double _defaultFontSize = 15.0;
  static const EdgeInsets _defaultPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );

  /// Construit une rangée de boutons premium (Annuler + Action principale)
  Widget buildPremiumActionRow({
    required BuildContext context,
    required VoidCallback onCancel,
    required VoidCallback onPrimaryAction,
    required String primaryActionText,
    String cancelText = 'Annuler',
    bool enablePhysicsAnimations = true,
    bool shouldReduceMotion = false,
    Color? primaryColor,
    MainAxisAlignment alignment = MainAxisAlignment.end,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        _buildInteractiveButton(
          button: buildCancelButton(context, cancelText),
          onTap: onCancel,
          enablePhysicsAnimations: enablePhysicsAnimations,
          shouldReduceMotion: shouldReduceMotion,
        ),
        const SizedBox(width: 12),
        _buildInteractiveButton(
          button: buildPrimaryActionButton(
            context,
            primaryActionText,
            primaryColor: primaryColor,
          ),
          onTap: onPrimaryAction,
          enablePhysicsAnimations: enablePhysicsAnimations,
          shouldReduceMotion: shouldReduceMotion,
        ),
      ],
    );
  }

  /// Construit une rangée de boutons pour confirmation (Cancel + Confirm)
  Widget buildConfirmationActionRow({
    required BuildContext context,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    String cancelText = 'Annuler',
    String confirmText = 'Confirmer',
    bool enablePhysicsAnimations = true,
    Color? confirmColor,
    MainAxisAlignment alignment = MainAxisAlignment.spaceEvenly,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Expanded(
          child: _buildInteractiveButton(
            button: buildCancelButton(context, cancelText),
            onTap: onCancel,
            enablePhysicsAnimations: enablePhysicsAnimations,
            shouldReduceMotion: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInteractiveButton(
            button: buildDestructiveButton(
              context,
              confirmText,
              color: confirmColor ?? Colors.red,
            ),
            onTap: onConfirm,
            enablePhysicsAnimations: enablePhysicsAnimations,
            shouldReduceMotion: false,
          ),
        ),
      ],
    );
  }

  /// Construit un bouton d'annulation standard
  Widget buildCancelButton(
    BuildContext context,
    String text, {
    EdgeInsetsGeometry? padding,
    double fontSize = _defaultFontSize,
  }) {
    return Container(
      padding: padding ?? _defaultPadding,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadiusTokens.button,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Construit un bouton d'action principale avec gradient
  Widget buildPrimaryActionButton(
    BuildContext context,
    String text, {
    Color? primaryColor,
    EdgeInsetsGeometry? padding,
    double fontSize = _defaultFontSize,
  }) {
    final effectiveColor = primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            effectiveColor,
            effectiveColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadiusTokens.button,
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Construit un bouton destructif avec styling d'avertissement
  Widget buildDestructiveButton(
    BuildContext context,
    String text, {
    Color color = Colors.red,
    EdgeInsetsGeometry? padding,
    double fontSize = _defaultFontSize,
  }) {
    final baseColor = color;
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tone(baseColor, level: 600),
            tone(baseColor, level: 700),
          ],
        ),
        borderRadius: BorderRadiusTokens.button,
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Construit un bouton d'option destructive avec icône d'avertissement
  Widget buildDestructiveOptionButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
    IconData icon = Icons.warning_amber_rounded,
    Color color = Colors.red,
    String? semanticHint,
  }) {
    final baseColor = color;

    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.05),
        borderRadius: BorderRadiusTokens.button,
        border: Border.all(
          color: baseColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: tone(baseColor, level: 600),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: tone(baseColor, level: 700),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: tone(baseColor, level: 400),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      hint: semanticHint ?? 'Action irréversible',
      button: true,
      child: _buildInteractiveButton(
        button: content,
        onTap: onTap,
        enablePhysicsAnimations: enablePhysicsAnimations,
        shouldReduceMotion: shouldReduceMotion,
      ),
    );
  }

  // === MÉTHODES PRIVÉES ===

  /// Enrobe un bouton avec des interactions physiques optionnelles
  Widget _buildInteractiveButton({
    required Widget button,
    required VoidCallback onTap,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
    double scaleFactor = 0.98,
  }) {
    return enablePhysicsAnimations && !shouldReduceMotion
        ? PhysicsAnimations.springScale(
            onTap: onTap,
            scaleFactor: scaleFactor,
            child: button,
          )
        : GestureDetector(
            onTap: onTap,
            child: button,
          );
  }
}
