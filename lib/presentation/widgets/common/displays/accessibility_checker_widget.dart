import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

/// Widget qui vérifie automatiquement l'accessibilité de ses enfants
class AccessibilityCheckerWidget extends StatefulWidget {
  /// Widget enfant à vérifier
  final Widget child;

  /// Couleur de premier plan pour la vérification des contrastes
  final Color? foregroundColor;

  /// Couleur d'arrière-plan pour la vérification des contrastes
  final Color? backgroundColor;

  /// Taille de police pour déterminer les seuils de contraste
  final double? fontSize;

  /// Active/désactive la vérification en mode debug
  final bool enableDebugChecks;

  /// Callback appelé en cas de violation d'accessibilité
  final Function(List<AccessibilityViolation>)? onViolationsFound;

  const AccessibilityCheckerWidget({
    super.key,
    required this.child,
    this.foregroundColor,
    this.backgroundColor,
    this.fontSize,
    this.enableDebugChecks = true,
    this.onViolationsFound,
  });

  @override
  State<AccessibilityCheckerWidget> createState() => _AccessibilityCheckerWidgetState();
}

class _AccessibilityCheckerWidgetState extends State<AccessibilityCheckerWidget> {
  final AccessibilityService _accessibilityService = AccessibilityService();
  List<AccessibilityViolation> _violations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performAccessibilityCheck();
    });
  }

  @override
  void didUpdateWidget(AccessibilityCheckerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.foregroundColor != widget.foregroundColor ||
        oldWidget.backgroundColor != widget.backgroundColor ||
        oldWidget.fontSize != widget.fontSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performAccessibilityCheck();
      });
    }
  }

  void _performAccessibilityCheck() {
    if (!widget.enableDebugChecks || !kDebugMode) return;

    final violations = <AccessibilityViolation>[];

    // Vérification des contrastes de couleurs
    if (widget.foregroundColor != null && widget.backgroundColor != null) {
      final isLargeText = (widget.fontSize ?? 16) >= 18;
      final contrastRatio = _accessibilityService.getContrastRatio(
        widget.foregroundColor!,
        widget.backgroundColor!,
      );

      final requiredRatio = isLargeText ? 3.0 : 4.5;
      
      if (contrastRatio < requiredRatio) {
        violations.add(AccessibilityViolation(
          type: AccessibilityViolationType.contrastInsufficient,
          message: 'Contraste insuffisant: ${contrastRatio.toStringAsFixed(2)}:1 '
              '(requis: $requiredRatio:1)',
          severity: AccessibilityViolationSeverity.error,
          guideline: 'WCAG 1.4.3 (AA)',
        ));
      }
    }

    setState(() {
      _violations = violations;
    });

    if (violations.isNotEmpty && widget.onViolationsFound != null) {
      widget.onViolationsFound!(violations);
    }

    // Afficher les violations dans la console en mode debug
    for (final violation in violations) {
      debugPrint('🚨 ACCESSIBILITÉ: ${violation.message} [${violation.guideline}]');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // En mode debug, ajouter des indicateurs visuels pour les violations
    if (kDebugMode && widget.enableDebugChecks && _violations.isNotEmpty) {
      child = Stack(
        children: [
          child,
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}

/// Types de violations d'accessibilité
enum AccessibilityViolationType {
  contrastInsufficient,
  touchTargetTooSmall,
  missingSemanticLabel,
  keyboardNavigationIssue,
  focusIndicatorMissing,
}

/// Sévérité des violations
enum AccessibilityViolationSeverity {
  error,
  warning,
  info,
}

/// Classe représentant une violation d'accessibilité
class AccessibilityViolation {
  final AccessibilityViolationType type;
  final String message;
  final AccessibilityViolationSeverity severity;
  final String guideline;

  const AccessibilityViolation({
    required this.type,
    required this.message,
    required this.severity,
    required this.guideline,
  });

  @override
  String toString() {
    return 'AccessibilityViolation(type: $type, message: $message, severity: $severity, guideline: $guideline)';
  }
}

/// Widget d'aide pour les développeurs en mode debug
class AccessibilityDebugPanel extends StatelessWidget {
  final List<AccessibilityViolation> violations;
  final VoidCallback? onDismiss;

  const AccessibilityDebugPanel({
    super.key,
    required this.violations,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || violations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: _buildPanel(context),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            ..._buildViolationMessages(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.accessibility_new, color: Colors.red),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Violations d'accessibilite detectees',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        if (onDismiss != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
            iconSize: 16,
          ),
      ],
    );
  }

  List<Widget> _buildViolationMessages() {
    return violations
        .map((violation) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '- ${violation.message}',
                style: const TextStyle(fontSize: 12),
              ),
            ))
        .toList();
  }
}
