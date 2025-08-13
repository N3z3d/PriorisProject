import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

/// Validateur d'accessibilité pour le mode debug
class AccessibilityValidator {
  static final AccessibilityValidator _instance = AccessibilityValidator._internal();
  factory AccessibilityValidator() => _instance;
  AccessibilityValidator._internal();

  final AccessibilityService _accessibilityService = AccessibilityService();
  final List<AccessibilityIssue> _issues = [];

  /// Valide l'accessibilité d'un widget
  List<AccessibilityIssue> validateWidget({
    required BuildContext context,
    required Widget widget,
    Color? foregroundColor,
    Color? backgroundColor,
    double? fontSize,
    String? semanticLabel,
    bool? isInteractive,
    Size? size,
  }) {
    if (!kDebugMode) return [];

    final issues = <AccessibilityIssue>[];

    // Validation des contrastes
    if (foregroundColor != null && backgroundColor != null) {
      final contrastIssues = _validateColorContrast(
        foregroundColor,
        backgroundColor,
        fontSize ?? 16,
      );
      issues.addAll(contrastIssues);
    }

    // Validation des tailles de touche
    if (isInteractive == true && size != null) {
      final sizeIssues = _validateTouchTargetSize(size);
      issues.addAll(sizeIssues);
    }

    // Validation des labels sémantiques
    if (isInteractive == true) {
      final labelIssues = _validateSemanticLabels(semanticLabel);
      issues.addAll(labelIssues);
    }

    // Validation de la structure
    final structureIssues = _validateStructure(context, widget);
    issues.addAll(structureIssues);

    _issues.addAll(issues);
    return issues;
  }

  List<AccessibilityIssue> _validateColorContrast(
    Color foreground,
    Color background,
    double fontSize,
  ) {
    final issues = <AccessibilityIssue>[];
    final isLargeText = fontSize >= 18;
    final ratio = _accessibilityService.getContrastRatio(foreground, background);
    final requiredRatio = isLargeText ? 3.0 : 4.5;

    if (ratio < requiredRatio) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.contrastInsufficient,
        severity: AccessibilityIssueSeverity.error,
        message: 'Contraste insuffisant: ${ratio.toStringAsFixed(2)}:1 '
            '(requis: ${requiredRatio}:1 pour ${isLargeText ? 'texte large' : 'texte normal'})',
        wcagGuideline: 'WCAG 1.4.3 (AA)',
        recommendation: 'Ajustez les couleurs pour atteindre un ratio de ${requiredRatio}:1 minimum',
        foregroundColor: foreground,
        backgroundColor: background,
      ));
    }

    return issues;
  }

  List<AccessibilityIssue> _validateTouchTargetSize(Size size) {
    final issues = <AccessibilityIssue>[];
    const minSize = 44.0;

    if (size.width < minSize || size.height < minSize) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.touchTargetTooSmall,
        severity: AccessibilityIssueSeverity.error,
        message: 'Zone de touche trop petite: ${size.width}x${size.height}px '
            '(minimum recommandé: ${minSize}x${minSize}px)',
        wcagGuideline: 'WCAG 2.5.5 (AAA)',
        recommendation: 'Augmentez la taille de la zone cliquable à ${minSize}x${minSize}px minimum',
        targetSize: size,
      ));
    }

    return issues;
  }

  List<AccessibilityIssue> _validateSemanticLabels(String? label) {
    final issues = <AccessibilityIssue>[];

    if (label == null || label.isEmpty) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.missingSemanticLabel,
        severity: AccessibilityIssueSeverity.error,
        message: 'Label sémantique manquant pour un élément interactif',
        wcagGuideline: 'WCAG 4.1.2 (A)',
        recommendation: 'Ajoutez un label descriptif avec Semantics(label: "...")',
      ));
    } else if (label.length < 3) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.inadequateSemanticLabel,
        severity: AccessibilityIssueSeverity.warning,
        message: 'Label sémantique trop court: "$label"',
        wcagGuideline: 'WCAG 2.4.6 (AA)',
        recommendation: 'Utilisez un label plus descriptif et informatif',
      ));
    }

    return issues;
  }

  List<AccessibilityIssue> _validateStructure(BuildContext context, Widget widget) {
    final issues = <AccessibilityIssue>[];

    // Validation de l'ordre de focus
    // Cette validation serait plus complexe et nécessiterait une analyse de l'arbre de widgets
    
    return issues;
  }

  /// Génère un rapport d'accessibilité complet
  AccessibilityReport generateReport() {
    final errorCount = _issues.where((i) => i.severity == AccessibilityIssueSeverity.error).length;
    final warningCount = _issues.where((i) => i.severity == AccessibilityIssueSeverity.warning).length;
    final infoCount = _issues.where((i) => i.severity == AccessibilityIssueSeverity.info).length;

    return AccessibilityReport(
      totalIssues: _issues.length,
      errors: errorCount,
      warnings: warningCount,
      infos: infoCount,
      issues: List.from(_issues),
      timestamp: DateTime.now(),
    );
  }

  /// Efface les issues collectées
  void clearIssues() {
    _issues.clear();
  }

  /// Affiche un résumé dans la console
  void printSummary() {
    if (!kDebugMode || _issues.isEmpty) return;

    debugPrint('🔍 RAPPORT D\'ACCESSIBILITÉ');
    debugPrint('=============================');
    
    final report = generateReport();
    debugPrint('📊 Total: ${report.totalIssues} problèmes détectés');
    debugPrint('❌ Erreurs: ${report.errors}');
    debugPrint('⚠️  Avertissements: ${report.warnings}');
    debugPrint('ℹ️  Informations: ${report.infos}');
    debugPrint('');

    for (final issue in _issues) {
      final icon = issue.severity == AccessibilityIssueSeverity.error 
          ? '❌' 
          : issue.severity == AccessibilityIssueSeverity.warning 
            ? '⚠️' 
            : 'ℹ️';
      
      debugPrint('$icon ${issue.message}');
      debugPrint('   📚 ${issue.wcagGuideline}');
      debugPrint('   💡 ${issue.recommendation}');
      debugPrint('');
    }
  }
}

/// Types de problèmes d'accessibilité
enum AccessibilityIssueType {
  contrastInsufficient,
  touchTargetTooSmall,
  missingSemanticLabel,
  inadequateSemanticLabel,
  keyboardNavigationIssue,
  focusIndicatorMissing,
  structuralIssue,
}

/// Sévérité des problèmes
enum AccessibilityIssueSeverity {
  error,
  warning,
  info,
}

/// Classe représentant un problème d'accessibilité
class AccessibilityIssue {
  final AccessibilityIssueType type;
  final AccessibilityIssueSeverity severity;
  final String message;
  final String wcagGuideline;
  final String recommendation;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Size? targetSize;

  const AccessibilityIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.wcagGuideline,
    required this.recommendation,
    this.foregroundColor,
    this.backgroundColor,
    this.targetSize,
  });

  @override
  String toString() {
    return 'AccessibilityIssue(type: $type, severity: $severity, message: $message)';
  }
}

/// Rapport d'accessibilité complet
class AccessibilityReport {
  final int totalIssues;
  final int errors;
  final int warnings;
  final int infos;
  final List<AccessibilityIssue> issues;
  final DateTime timestamp;

  const AccessibilityReport({
    required this.totalIssues,
    required this.errors,
    required this.warnings,
    required this.infos,
    required this.issues,
    required this.timestamp,
  });

  /// Indique si l'application passe les tests d'accessibilité
  bool get isAccessible => errors == 0;

  /// Niveau de conformité WCAG estimé
  String get wcagLevel {
    if (errors == 0 && warnings == 0) return 'AAA';
    if (errors == 0) return 'AA';
    return 'Non conforme';
  }

  @override
  String toString() {
    return 'AccessibilityReport(totalIssues: $totalIssues, errors: $errors, '
        'warnings: $warnings, infos: $infos, wcagLevel: $wcagLevel)';
  }
}

/// Extension pour faciliter la validation
extension AccessibilityValidation on Widget {
  /// Valide l'accessibilité du widget actuel
  Widget validateAccessibility({
    required BuildContext context,
    Color? foregroundColor,
    Color? backgroundColor,
    double? fontSize,
    String? semanticLabel,
    bool? isInteractive,
    Size? size,
  }) {
    if (kDebugMode) {
      final validator = AccessibilityValidator();
      validator.validateWidget(
        context: context,
        widget: this,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        semanticLabel: semanticLabel,
        isInteractive: isInteractive,
        size: size,
      );
    }
    return this;
  }
}