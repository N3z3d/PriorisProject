import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';

/// Premium Theme System - Manages colors, gradients, and theming following SRP
/// Responsibility: All theme-related styling and color management
class PremiumThemeSystem implements IPremiumThemeSystem {
  bool _isInitialized = false;

  // Premium color palette
  static const Color _premiumPrimary = Color(0xFF6366F1);
  static const Color _premiumSecondary = Color(0xFF8B5CF6);
  static const Color _premiumAccent = Color(0xFFF59E0B);
  static const Color _premiumSurface = Color(0xFFFAFAFA);
  static const Color _premiumBackground = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color _premiumPrimaryDark = Color(0xFF818CF8);
  static const Color _premiumSecondaryDark = Color(0xFFA78BFA);
  static const Color _premiumAccentDark = Color(0xFFFBBF24);
  static const Color _premiumSurfaceDark = Color(0xFF1F2937);
  static const Color _premiumBackgroundDark = Color(0xFF111827);

  // Cached gradients for performance
  LinearGradient? _primaryGradient;
  LinearGradient? _secondaryGradient;
  LinearGradient? _accentGradient;

  // Cached shadows for performance
  List<BoxShadow>? _primaryShadow;
  List<BoxShadow>? _secondaryShadow;
  List<BoxShadow>? _elevatedShadow;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Pre-compute gradients for better performance
    _primaryGradient = _createPrimaryGradient();
    _secondaryGradient = _createSecondaryGradient();
    _accentGradient = _createAccentGradient();

    // Pre-compute shadows for better performance
    _primaryShadow = _createPrimaryShadow();
    _secondaryShadow = _createSecondaryShadow();
    _elevatedShadow = _createElevatedShadow();

    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ COLOR MANAGEMENT ============

  @override
  Color getPrimaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _premiumPrimaryDark : _premiumPrimary;
  }

  @override
  Color getSecondaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _premiumSecondaryDark : _premiumSecondary;
  }

  @override
  Color getAccentColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _premiumAccentDark : _premiumAccent;
  }

  @override
  Color getSurfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _premiumSurfaceDark : _premiumSurface;
  }

  @override
  Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _premiumBackgroundDark : _premiumBackground;
  }

  // ============ GRADIENT MANAGEMENT ============

  @override
  LinearGradient getPrimaryGradient() {
    _ensureInitialized();
    return _primaryGradient!;
  }

  @override
  LinearGradient getSecondaryGradient() {
    _ensureInitialized();
    return _secondaryGradient!;
  }

  @override
  LinearGradient getAccentGradient() {
    _ensureInitialized();
    return _accentGradient!;
  }

  // ============ SHADOW MANAGEMENT ============

  @override
  List<BoxShadow> getPrimaryShadow() {
    _ensureInitialized();
    return _primaryShadow!;
  }

  @override
  List<BoxShadow> getSecondaryShadow() {
    _ensureInitialized();
    return _secondaryShadow!;
  }

  @override
  List<BoxShadow> getElevatedShadow() {
    _ensureInitialized();
    return _elevatedShadow!;
  }

  // ============ BUTTON STYLE EXTENSIONS ============

  /// Gets background color for button style
  @override
  Color getButtonBackgroundColor(BuildContext context, PremiumButtonStyle style) {
    switch (style) {
      case PremiumButtonStyle.primary:
        return getPrimaryColor(context);
      case PremiumButtonStyle.secondary:
        return getSecondaryColor(context);
      case PremiumButtonStyle.outline:
        return Colors.transparent;
      case PremiumButtonStyle.text:
        return Colors.transparent;
    }
  }

  /// Gets foreground color for button style
  @override
  Color getButtonForegroundColor(BuildContext context, PremiumButtonStyle style) {
    switch (style) {
      case PremiumButtonStyle.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case PremiumButtonStyle.secondary:
        return Theme.of(context).colorScheme.onSecondary;
      case PremiumButtonStyle.outline:
        return getPrimaryColor(context);
      case PremiumButtonStyle.text:
        return getPrimaryColor(context);
    }
  }

  /// Gets shadow color for button style
  @override
  Color getButtonShadowColor(BuildContext context, PremiumButtonStyle style) {
    switch (style) {
      case PremiumButtonStyle.primary:
        return getPrimaryColor(context).withValues(alpha: 0.3);
      case PremiumButtonStyle.secondary:
        return getSecondaryColor(context).withValues(alpha: 0.3);
      case PremiumButtonStyle.outline:
        return Colors.black.withValues(alpha: 0.1);
      case PremiumButtonStyle.text:
        return Colors.transparent;
    }
  }

  // ============ FEEDBACK COLOR EXTENSIONS ============

  /// Gets color for feedback type
  @override
  Color getFeedbackColor(BuildContext context, FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return Colors.green;
      case FeedbackType.error:
        return Theme.of(context).colorScheme.error;
      case FeedbackType.warning:
        return Colors.orange;
      case FeedbackType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// Gets icon for feedback type
  @override
  IconData getFeedbackIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
    }
  }

  // ============ PRIVATE METHODS ============

  LinearGradient _createPrimaryGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _premiumPrimary,
        _premiumSecondary,
      ],
      stops: [0.0, 1.0],
    );
  }

  LinearGradient _createSecondaryGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _premiumSecondary,
        _premiumAccent,
      ],
      stops: [0.0, 1.0],
    );
  }

  LinearGradient _createAccentGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        _premiumAccent,
        Color(0xFFF97316), // Orange-500
      ],
      stops: [0.0, 1.0],
    );
  }

  List<BoxShadow> _createPrimaryShadow() {
    return [
      BoxShadow(
        color: _premiumPrimary.withValues(alpha: 0.25),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  List<BoxShadow> _createSecondaryShadow() {
    return [
      BoxShadow(
        color: _premiumSecondary.withValues(alpha: 0.2),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];
  }

  List<BoxShadow> _createElevatedShadow() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumThemeSystem must be initialized before use.');
    }
  }
}