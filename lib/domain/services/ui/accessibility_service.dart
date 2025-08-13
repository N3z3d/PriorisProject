import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'dart:math';

/// Service pour centraliser l'accessibilité dans l'application
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // Tailles minimales pour l'accessibilité
  static const double minTouchTargetSize = 44.0;
  static const double minTouchTargetSizeLarge = 48.0;

  // Ratios de contraste WCAG
  static const double contrastRatioAA = 4.5;
  static const double contrastRatioAALarge = 3.0;
  static const double contrastRatioAAA = 7.0;

  // Focus node global pour la gestion du focus
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Génère un label d'accessibilité pour un widget
  String getAriaLabel(String base, {String? context}) {
    if (context != null && context.isNotEmpty) {
      return '$base ($context)';
    }
    return base;
  }

  /// Définit le rôle ARIA d'un widget
  String getAriaRole(String widgetType) {
    switch (widgetType) {
      case 'button':
        return 'button';
      case 'checkbox':
        return 'checkbox';
      case 'dialog':
        return 'dialog';
      case 'list':
        return 'list';
      case 'listitem':
        return 'listitem';
      case 'tab':
        return 'tab';
      case 'tabpanel':
        return 'tabpanel';
      case 'navigation':
        return 'navigation';
      case 'form':
        return 'form';
      default:
        return 'region';
    }
  }

  /// Gère le focus clavier pour un widget
  void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }

  /// Fonction utilitaire pour la luminance
  static double _linear(double channel) => channel <= 0.03928 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4).toDouble();

  /// Vérifie le contraste entre deux couleurs (ratio WCAG)
  double getContrastRatio(Color foreground, Color background) {
    double luminance(Color c) {
      final r = (c.r * 255.0).round() & 0xff;
      final g = (c.g * 255.0).round() & 0xff;
      final b = (c.b * 255.0).round() & 0xff;
      final rNorm = r / 255.0;
      final gNorm = g / 255.0;
      final bNorm = b / 255.0;
      final l = 0.2126 * _linear(rNorm) + 0.7152 * _linear(gNorm) + 0.0722 * _linear(bNorm);
      return l;
    }
    final l1 = luminance(foreground) + 0.05;
    final l2 = luminance(background) + 0.05;
    return l1 > l2 ? l1 / l2 : l2 / l1;
  }

  /// Vérifie si le contraste est suffisant (niveau AA)
  bool isContrastSufficient(Color fg, Color bg, {bool largeText = false}) {
    final ratio = getContrastRatio(fg, bg);
    return largeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Retourne la taille de police adaptée pour l'accessibilité
  double getAccessibleFontSize(double base, {bool isLarge = false}) {
    return isLarge ? base * 1.2 : base;
  }

  /// Vérifie si un élément respecte la taille minimale de touche
  bool isTouchTargetSizeValid(double width, double height, {bool isLarge = false}) {
    final minSize = isLarge ? minTouchTargetSizeLarge : minTouchTargetSize;
    return width >= minSize && height >= minSize;
  }

  /// Crée un wrapper pour assurer la taille minimale de touche
  Widget ensureMinimumTouchTarget(Widget child, {double? width, double? height}) {
    return SizedBox(
      width: width != null ? max(width, minTouchTargetSize) : minTouchTargetSize,
      height: height != null ? max(height, minTouchTargetSize) : minTouchTargetSize,
      child: child,
    );
  }

  /// Annonce un message aux lecteurs d'écran
  void announceToScreenReader(String message, {TextDirection? textDirection}) {
    SemanticsService.announce(
      message, 
      textDirection ?? TextDirection.ltr,
    );
  }

  /// Crée un widget avec les propriétés sémantiques appropriées
  Widget createSemanticWidget({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? enabled,
    bool? checked,
    bool? selected,
    bool? button,
    bool? header,
    bool? textField,
    bool? focusable,
    bool? focused,
    bool? hidden,
    bool? liveRegion,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onScrollLeft,
    VoidCallback? onScrollRight,
    VoidCallback? onScrollUp,
    VoidCallback? onScrollDown,
    int? currentValueLength,
    int? maxValueLength,
    String? increasedValue,
    String? decreasedValue,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      enabled: enabled,
      checked: checked,
      selected: selected,
      button: button,
      header: header,
      textField: textField,
      focusable: focusable,
      focused: focused,
      hidden: hidden,
      liveRegion: liveRegion,
      onTap: onTap,
      onLongPress: onLongPress,
      onScrollLeft: onScrollLeft,
      onScrollRight: onScrollRight,
      onScrollUp: onScrollUp,
      onScrollDown: onScrollDown,
      currentValueLength: currentValueLength,
      maxValueLength: maxValueLength,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  /// Vérifie si les préférences de mouvement réduit sont activées
  bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Retourne la durée d'animation adaptée aux préférences
  Duration getAccessibleAnimationDuration(BuildContext context, Duration defaultDuration) {
    return isReduceMotionEnabled(context) ? Duration.zero : defaultDuration;
  }

  /// Gère le focus pour les modales et dialogs
  void trapFocusInDialog(BuildContext context, {required Widget child}) {
    // Implementation du focus trapping pour les dialogs
    FocusScope.of(context).requestFocus();
  }

  /// Retourne le focus à l'élément précédent après fermeture d'une modale
  void returnFocusToPreviousElement(FocusNode? previousFocus) {
    if (previousFocus != null && previousFocus.context != null) {
      previousFocus.requestFocus();
    }
  }

  /// Crée un indicateur de focus visible
  BoxDecoration createFocusDecoration({
    Color? focusColor,
    double borderWidth = 2.0,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: focusColor ?? const Color(0xFF005FCC),
        width: borderWidth,
      ),
      borderRadius: borderRadius,
    );
  }

  /// Valide l'accessibilité d'un contraste de couleur avec niveau spécifique
  bool validateColorContrast(
    Color foreground,
    Color background,
    {bool isLargeText = false, String level = 'AA'}
  ) {
    final ratio = getContrastRatio(foreground, background);
    
    switch (level) {
      case 'AAA':
        return isLargeText ? ratio >= 4.5 : ratio >= 7.0;
      case 'AA':
      default:
        return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
    }
  }

  /// Génère un rapport d'accessibilité pour debug
  Map<String, dynamic> generateAccessibilityReport(BuildContext context) {
    return {
      'screenReader': MediaQuery.of(context).accessibleNavigation,
      'highContrast': MediaQuery.of(context).highContrast,
      'reduceMotion': MediaQuery.of(context).disableAnimations,
      'textScaleFactor': MediaQuery.of(context).textScaler.scale(1.0),
      'platformBrightness': MediaQuery.of(context).platformBrightness.name,
    };
  }
} 
