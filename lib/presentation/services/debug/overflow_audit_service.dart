import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service pour auditer et corriger les overflows dans l'app
class OverflowAuditService {
  static final OverflowAuditService _instance = OverflowAuditService._internal();
  factory OverflowAuditService() => _instance;
  OverflowAuditService._internal();

  static bool _isEnabled = false;
  static final List<OverflowIssue> _detectedIssues = [];

  /// Active ou désactive l'audit automatique des overflows
  static void enable({bool enabled = true}) {
    _isEnabled = enabled;
    if (enabled && kDebugMode) {
      debugPrint('🔍 OverflowAuditService: Audit des overflows activé');
      _setupOverflowDetection();
    }
  }

  /// Configure la détection automatique des overflows
  static void _setupOverflowDetection() {
    // Intercepte les erreurs de rendu pour détecter les overflows
    FlutterError.onError = (FlutterErrorDetails details) {
      if (_isEnabled && details.exception.toString().contains('overflowed')) {
        _handleOverflowDetected(details);
      }
      FlutterError.presentError(details);
    };
  }

  /// Traite la détection d'un overflow
  static void _handleOverflowDetected(FlutterErrorDetails details) {
    final issue = OverflowIssue.fromErrorDetails(details);
    _detectedIssues.add(issue);
    
    debugPrint('🚨 OVERFLOW DÉTECTÉ:');
    debugPrint('  Widget: ${issue.widgetName}');
    debugPrint('  Taille: ${issue.overflowSize}px');
    debugPrint('  Direction: ${issue.direction}');
    debugPrint('  Stack: ${issue.stackTrace}');
  }

  /// Retourne la liste des overflows détectés
  static List<OverflowIssue> get detectedIssues => List.unmodifiable(_detectedIssues);

  /// Génère un rapport d'audit
  static String generateAuditReport() {
    if (_detectedIssues.isEmpty) {
      return '✅ Aucun overflow détecté';
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 RAPPORT D\'AUDIT DES OVERFLOWS');
    buffer.writeln('================================');
    buffer.writeln('Total: ${_detectedIssues.length} overflow(s) détecté(s)\n');

    final grouped = _groupByWidget(_detectedIssues);
    for (final entry in grouped.entries) {
      buffer.writeln('🔸 Widget: ${entry.key}');
      buffer.writeln('  Occurrences: ${entry.value.length}');
      
      final firstIssue = entry.value.first;
      buffer.writeln('  Taille moyenne: ${_calculateAverageOverflow(entry.value).toStringAsFixed(1)}px');
      buffer.writeln('  Direction: ${firstIssue.direction}');
      buffer.writeln('  Suggestions: ${firstIssue.suggestions.join(', ')}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Groupe les issues par widget
  static Map<String, List<OverflowIssue>> _groupByWidget(List<OverflowIssue> issues) {
    final grouped = <String, List<OverflowIssue>>{};
    for (final issue in issues) {
      grouped.putIfAbsent(issue.widgetName, () => []).add(issue);
    }
    return grouped;
  }

  /// Calcule l'overflow moyen
  static double _calculateAverageOverflow(List<OverflowIssue> issues) {
    if (issues.isEmpty) return 0.0;
    return issues.map((i) => i.overflowSize).reduce((a, b) => a + b) / issues.length;
  }

  /// Applique des corrections automatiques
  static Map<String, String> generateFixSuggestions() {
    final suggestions = <String, String>{};
    
    for (final issue in _detectedIssues) {
      final key = issue.widgetName;
      if (!suggestions.containsKey(key)) {
        suggestions[key] = _generateFixForWidget(issue);
      }
    }
    
    return suggestions;
  }

  static String _generateFixForWidget(OverflowIssue issue) {
    switch (issue.direction) {
      case OverflowDirection.horizontal:
        return '''
// Correction suggérée pour ${issue.widgetName}:
Wrap(
  children: [...], // ou Flexible, Expanded
)
// Ou utiliser SingleChildScrollView avec scrollDirection: Axis.horizontal
''';
      case OverflowDirection.vertical:
        return '''
// Correction suggérée pour ${issue.widgetName}:
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Flexible(child: ...), // ou Expanded
  ],
)
// Ou SizedBox(height: ...) avec contraintes
''';
      case OverflowDirection.both:
        return '''
// Correction suggérée pour ${issue.widgetName}:
SingleChildScrollView(
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ...,
  ),
)
''';
    }
  }

  /// Efface les issues détectées
  static void clearIssues() {
    _detectedIssues.clear();
    debugPrint('🧹 OverflowAuditService: Issues effacées');
  }
}

/// Représente un problème d'overflow détecté
class OverflowIssue {
  final String widgetName;
  final double overflowSize;
  final OverflowDirection direction;
  final DateTime timestamp;
  final String stackTrace;
  final List<String> suggestions;

  OverflowIssue({
    required this.widgetName,
    required this.overflowSize,
    required this.direction,
    required this.timestamp,
    required this.stackTrace,
    required this.suggestions,
  });

  factory OverflowIssue.fromErrorDetails(FlutterErrorDetails details) {
    final exception = details.exception.toString();
    final stackTrace = details.stack?.toString() ?? '';
    
    // Extraire les informations de l'erreur
    final widgetMatch = RegExp(r'RenderFlex#\w+').firstMatch(exception);
    final widgetName = widgetMatch?.group(0) ?? 'Unknown Widget';
    
    final sizeMatch = RegExp(r'overflowed by ([\d.]+) pixels').firstMatch(exception);
    final overflowSize = double.tryParse(sizeMatch?.group(1) ?? '0') ?? 0.0;
    
    final direction = _extractDirection(exception);
    
    return OverflowIssue(
      widgetName: widgetName,
      overflowSize: overflowSize,
      direction: direction,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
      suggestions: _generateSuggestions(direction),
    );
  }

  static OverflowDirection _extractDirection(String exception) {
    if (exception.contains('on the bottom') || exception.contains('on the top')) {
      return OverflowDirection.vertical;
    } else if (exception.contains('on the right') || exception.contains('on the left')) {
      return OverflowDirection.horizontal;
    }
    return OverflowDirection.both;
  }

  static List<String> _generateSuggestions(OverflowDirection direction) {
    switch (direction) {
      case OverflowDirection.horizontal:
        return ['Utiliser Flexible/Expanded', 'SingleChildScrollView horizontal', 'Wrap widget'];
      case OverflowDirection.vertical:
        return ['MainAxisSize.min', 'SizedBox avec hauteur fixe', 'Flexible/Expanded'];
      case OverflowDirection.both:
        return ['SingleChildScrollView', 'Contraintes Container', 'Responsive design'];
    }
  }

  @override
  String toString() {
    return 'OverflowIssue(widget: $widgetName, size: ${overflowSize}px, direction: $direction)';
  }
}

enum OverflowDirection {
  horizontal,
  vertical,
  both,
}

/// Extension pour activer l'audit dans main.dart
extension OverflowAuditExtension on Widget {
  Widget withOverflowAudit() {
    if (kDebugMode) {
      OverflowAuditService.enable();
    }
    return this;
  }
}