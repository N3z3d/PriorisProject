import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Service spécialisé pour la construction des containers de dialog - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique pour la structure et styling des containers
/// - OCP: Extensible via configuration personnalisée des containers
/// - LSP: Compatible avec les interfaces de construction de dialog
/// - ISP: Interface focalisée sur la construction de containers uniquement
/// - DIP: Dépend des abstractions Flutter pour le styling
///
/// Features:
/// - Glassmorphisme avec backdrop blur optimisé
/// - Contraintes responsive pour mobile/desktop
/// - Gestion de l'accessibilité avec semantics
/// - Gradients et effets premium configurables
/// - Bordures et shadows premium
///
/// CONSTRAINTS: <150 lignes (extrait de 669 lignes)
class DialogContainerBuilder {

  /// Configuration par défaut pour les dialogs premium
  static const double _defaultMaxWidth = 400.0;
  static const double _defaultMinWidth = 320.0;
  static const double _defaultBlurSigma = 20.0;

  /// Construit le container principal avec glassmorphisme
  Widget buildGlassmorphismContainer({
    required Widget child,
    double maxWidth = _defaultMaxWidth,
    double minWidth = _defaultMinWidth,
    double blurSigma = _defaultBlurSigma,
    EdgeInsets? margin,
    List<Color>? gradientColors,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: minWidth,
        ),
        margin: margin ?? const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadiusTokens.modal,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                gradient: _buildGradient(gradientColors),
                borderRadius: borderRadius ?? BorderRadiusTokens.modal,
                border: border ?? _buildDefaultBorder(),
                boxShadow: boxShadow ?? _buildDefaultShadow(),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Construit un container pour dialog de confirmation
  Widget buildConfirmationContainer({
    required Widget child,
    double maxWidth = 350.0,
    double blurSigma = 15.0,
    Color? primaryColor,
    BorderRadius? borderRadius,
  }) {
    final effectiveColor = primaryColor ?? Colors.red;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadiusTokens.modal,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveColor.withOpacity(0.1),
                  effectiveColor.withOpacity(0.05),
                ],
              ),
              borderRadius: borderRadius ?? BorderRadiusTokens.modal,
              border: Border.all(
                color: effectiveColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Construit un AlertDialog transparent pour les confirmations
  Widget buildTransparentAlertDialog({
    required Widget content,
    BorderRadius? borderRadius,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadiusTokens.modal,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: content,
    );
  }

  // === MÉTHODES PRIVÉES ===

  /// Construit le gradient par défaut
  LinearGradient _buildGradient(List<Color>? customColors) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: customColors ?? [
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
    );
  }

  /// Construit la bordure par défaut
  Border _buildDefaultBorder() {
    return Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1.5,
    );
  }

  /// Construit les shadows par défaut
  List<BoxShadow> _buildDefaultShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 30,
        offset: const Offset(0, 15),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 60,
        offset: const Offset(0, 30),
      ),
    ];
  }
}